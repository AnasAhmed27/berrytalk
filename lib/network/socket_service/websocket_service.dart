// =============================================================================
// WebSocketService - Production grade, copy-paste ready singleton.
//
// HOW TO USE THIS IN ANY FLUTTER PROJECT:
//   1. Copy this file into your project (e.g. lib/services/websocket_service.dart).
//   2. Add these dependencies to pubspec.yaml:
//        web_socket_channel: ^3.0.3
//        connectivity_plus: ^6.1.0
//      then run: flutter pub get
//   3. Use it from anywhere (it is a global singleton):
//
//        final ws = WebSocketService();
//        ws.setParams(
//          url: ApiConfig.socketUrl,
//          token: 'YOUR_JWT_TOKEN',
//        );
//        ws.setAuthCredentials(username: 'user', password: 'pass');
//        ws.messages.listen((json) => print('message: $json'));
//        // OR per-screen, per-type:
//        ws.onType('update-chat-list').listen((json) => ...);
//        await ws.start(); // connects + starts background monitor
//
// Because it is a singleton, calling WebSocketService() in any screen/class
// always returns the SAME instance, so the socket connects only ONCE for the
// whole app no matter how many screens use it.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:berrytalks/network/ApiConfig.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'push_notification_service.dart';
import 'socket_message_types.dart';

/// Immutable status event broadcast to every [WebSocketService.statusStream]
/// listener (each screen can subscribe independently).
class WebSocketStatusUpdate {
  const WebSocketStatusUpdate({required this.status, required this.message});

  final WebSocketStatus status;
  final String message;
}

/// High level connection state of the socket, useful to drive UI.
enum WebSocketStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  noInternet,
}

/// Called with every JSON payload received from the socket.
typedef WebSocketMessageCallback = void Function(Map<String, dynamic> json);

/// Called whenever the connection status changes, with a human readable
/// message you can show to the user (toast/snackbar/banner).
typedef WebSocketStatusCallback = void Function(
  WebSocketStatus status,
  String message,
);

class WebSocketService with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // Singleton boilerplate
  // ---------------------------------------------------------------------------
  WebSocketService._internal() {
    // Observe the app lifecycle so we can close the socket cleanly when the
    // app is terminated (e.g. swiped away from the recent-apps list).
    WidgetsBinding.instance.addObserver(this);
  }

  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  bool _lifecycleObserverRegistered = true;

  // ---------------------------------------------------------------------------
  // App lifecycle
  // ---------------------------------------------------------------------------

  /// Production lifecycle strategy (matches WhatsApp/Slack/Signal behaviour):
  ///   - resumed   : app is in the foreground -> (re)connect + heartbeat.
  ///   - inactive  : transient (call, app-switcher, notif shade) -> ignore.
  ///   - paused    : app is backgrounded -> start a short grace timer; if the
  ///                 user does not come back within [_backgroundGraceDuration]
  ///                 we gracefully close the socket (saves battery/data and
  ///                 lets the server clean up). Messages while backgrounded are
  ///                 meant to arrive via push notifications instead.
  ///   - detached  : app is being killed (e.g. swiped from recents) ->
  ///                 best-effort clean close.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isInForeground = true;
        _backgroundGraceTimer?.cancel();
        _backgroundGraceTimer = null;
        _resumeConnection();
        break;
      case AppLifecycleState.paused:
        _isInForeground = false;
        _backgroundGraceTimer?.cancel();
        _backgroundGraceTimer = Timer(_backgroundGraceDuration, () {
          disconnect();
        });
        break;
      case AppLifecycleState.detached:
        _isInForeground = false;
        _backgroundGraceTimer?.cancel();
        _backgroundGraceTimer = null;
        disconnect();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Transient states: do nothing (avoids connect/disconnect churn).
        break;
    }
  }

  /// Reconnect when the app returns to the foreground, but only if it makes
  /// sense to (params configured, not already connected, not mid-connect).
  void _resumeConnection() {
    if (_url == null || _url!.isEmpty) return; // setParams() not called yet.
    _manuallyClosed = false;
    if (isConnected || _connecting) return;
    startConnectionMonitor();
    connect();
  }

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------
  String? _url;
  String? _token;
  String? _authUsername;
  String? _authPassword;

  /// Broadcast stream controllers — every screen/listener gets its own
  /// subscription; none overwrite each other (WhatsApp/Slack pattern).
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketStatusUpdate> _statusController =
      StreamController<WebSocketStatusUpdate>.broadcast();

  /// Legacy single-callback subscriptions (kept for backward compatibility).
  StreamSubscription<Map<String, dynamic>>? _legacyMessageSub;
  StreamSubscription<WebSocketStatusUpdate>? _legacyStatusSub;

  /// Interval for the background "is it alive?" safety-net monitor.
  Duration _monitorInterval = const Duration(minutes: 3);

  /// Interval for the keep-alive heartbeat ping (sent while connected).
  ///
  /// IMPORTANT: this MUST be safely below the server's session idle-timeout.
  /// The server here times out at 3 minutes, so we ping every 2 minutes to
  /// leave room for one failed ping + reconnect before the session dies.
  Duration _heartbeatInterval = const Duration(minutes: 2);

  /// How long we wait for a `ping-response` (pong) after sending a `ping`
  /// before we consider the socket dead and force a reconnect.
  Duration _pongTimeout = const Duration(seconds: 30);

  /// After the app is backgrounded we wait this long before closing the socket
  /// (avoids churn on quick app-switches / opening the notification shade).
  Duration _backgroundGraceDuration = const Duration(seconds: 30);

  /// Delay between automatic reconnection attempts (exponential backoff caps
  /// this value, see [_currentBackoff]).
  Duration _baseReconnectDelay = const Duration(seconds: 2);
  Duration _maxReconnectDelay = const Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Runtime state
  // ---------------------------------------------------------------------------
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _monitorTimer;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimer;
  Timer? _backgroundGraceTimer;

  /// Pluggable push/notification provider. No-op until a real SDK is injected
  /// via [setNotificationService]. Used to surface messages that arrive while
  /// the app is not in the foreground.
  PushNotificationService _notificationService =
      const NoopPushNotificationService();

  WebSocketStatus _status = WebSocketStatus.idle;
  bool _manuallyClosed = false;
  bool _hasInternet = true;
  bool _isInForeground = true;
  bool _connecting = false;
  int _reconnectAttempts = 0;

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------
  bool get isConnected =>
      _channel != null && _status == WebSocketStatus.connected;

  WebSocketStatus get status => _status;

  /// Every incoming socket JSON payload. Subscribe once per screen/feature;
  /// cancel the [StreamSubscription] in [State.dispose].
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Every connection status change. Same multi-listener semantics as [messages].
  Stream<WebSocketStatusUpdate> get statusStream => _statusController.stream;

  /// Filter [messages] down to a single server `type` string.
  Stream<Map<String, dynamic>> onType(String type) =>
      messages.where((m) => m['type'] == type);

  /// Filter [messages] down to several server `type` values.
  Stream<Map<String, dynamic>> onTypes(Set<String> types) =>
      messages.where((m) => m['type'] is String && types.contains(m['type']));

  /// True while the app is in the foreground.
  bool get isInForeground => _isInForeground;

  /// The currently injected notification provider (no-op by default).
  PushNotificationService get notificationService => _notificationService;

  /// Inject your custom notification SDK wrapper. Call this once at startup
  /// (before/after [setParams]) when your SDK is ready.
  void setNotificationService(PushNotificationService service) {
    _notificationService = service;
  }

  // ---------------------------------------------------------------------------
  // Configuration API
  // ---------------------------------------------------------------------------

  /// Configure connection parameters. Call this once before [start]/[connect].
  void setParams({
    String? url = ApiConfig.socketUrl,
    String? token,
    Duration? monitorInterval,
    Duration? heartbeatInterval,
    Duration? pongTimeout,
    Duration? backgroundGraceDuration,
    Duration? baseReconnectDelay,
    Duration? maxReconnectDelay,
  }) {
    _url = url;
    _token = token;
    if (monitorInterval != null) _monitorInterval = monitorInterval;
    if (heartbeatInterval != null) _heartbeatInterval = heartbeatInterval;
    if (pongTimeout != null) _pongTimeout = pongTimeout;
    if (backgroundGraceDuration != null) {
      _backgroundGraceDuration = backgroundGraceDuration;
    }
    if (baseReconnectDelay != null) _baseReconnectDelay = baseReconnectDelay;
    if (maxReconnectDelay != null) _maxReconnectDelay = maxReconnectDelay;

    print("Socket_Connection_Stats: from service Token: $token");
  }

  /// Socket auth credentials. When set, the service auto-responds to
  /// `auth-request` centrally so individual screens do not have to.
  void setAuthCredentials({required String username, required String password}) {
    _authUsername = username;
    _authPassword = password;
  }

  /// Subscribe to all messages. Returns a [StreamSubscription] you MUST cancel
  /// (or use [SocketScreenListener] mixin which cancels for you).
  StreamSubscription<Map<String, dynamic>> subscribeMessages(
    void Function(Map<String, dynamic> message) onData,
  ) =>
      messages.listen(onData);

  /// Subscribe to a single message [type].
  StreamSubscription<Map<String, dynamic>> subscribeType(
    String type,
    void Function(Map<String, dynamic> message) onData,
  ) =>
      onType(type).listen(onData);

  /// Subscribe to connection status updates.
  StreamSubscription<WebSocketStatusUpdate> subscribeStatus(
    void Function(WebSocketStatusUpdate update) onData,
  ) =>
      statusStream.listen(onData);

  /// @deprecated Use [messages], [onType], or [subscribeType] instead.
  /// Kept for backward compatibility — registers ONE listener that is replaced
  /// on every call (same old behaviour).
  @Deprecated('Use messages / onType / subscribeType for multi-listener support')
  void setOnMessage(WebSocketMessageCallback callback) {
    _legacyMessageSub?.cancel();
    _legacyMessageSub = messages.listen(callback);
  }

  /// @deprecated Use [statusStream] or [subscribeStatus] instead.
  @Deprecated('Use statusStream / subscribeStatus for multi-listener support')
  void setOnStatus(WebSocketStatusCallback callback) {
    _legacyStatusSub?.cancel();
    _legacyStatusSub = statusStream.listen(
      (update) => callback(update.status, update.message),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle API
  // ---------------------------------------------------------------------------

  /// One-shot entry point: connects, starts the connectivity watcher and the
  /// background monitor. Safe to call multiple times.
  Future<void> start() async {
    _manuallyClosed = false;
    _startConnectivityWatcher();
    startConnectionMonitor();
    await connect();
  }

  /// Connect to the WebSocket server and start listening for messages.
  Future<void> connect() async {
    if (_url == null || _url!.isEmpty) {
      throw StateError('WebSocket URL is not set. Call setParams() first.');
    }

    // Guard against overlapping connect() calls (e.g. resume + monitor racing).
    if (_connecting) return;
    _connecting = true;
    try {
      // Don't try to open a socket when there is clearly no network.
      _hasInternet = await _checkInternet();
      if (!_hasInternet) {
        _updateStatus(
          WebSocketStatus.noInternet,
          'No internet connection. Waiting for network to reconnect…',
        );
        return;
      }

      await _teardownChannel();
      _manuallyClosed = false;
      _updateStatus(WebSocketStatus.connecting, 'Connecting…');

      _channel = WebSocketChannel.connect(Uri.parse(_url!));

      _socketSub = _channel!.stream.listen(
        _handleIncomingMessage,
        onError: _handleSocketError,
        onDone: _handleSocketDone,
        cancelOnError: false,
      );

      // Wait until the channel is actually open. The server will then send an
      // `auth-request`; the app layer answers it with `authenticateUser(...)`.
      // We do NOT ping here (that would be out of protocol, before auth).
      await _channel!.ready;
      _reconnectAttempts = 0;
      _updateStatus(WebSocketStatus.connected, 'Connected');
      _startHeartbeat();
    } catch (e) {
      _updateStatus(
        WebSocketStatus.disconnected,
        'Failed to connect: $e',
      );
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  /// Close the socket on purpose and stop all background work.
  Future<void> disconnect() async {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    await _teardownChannel();
    _updateStatus(WebSocketStatus.disconnected, 'Disconnected');
  }

  /// Fully dispose the service (use on app shutdown).
  Future<void> dispose() async {
    stopConnectionMonitor();
    _backgroundGraceTimer?.cancel();
    _backgroundGraceTimer = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    if (_lifecycleObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleObserverRegistered = false;
    }
    await _legacyMessageSub?.cancel();
    _legacyMessageSub = null;
    await _legacyStatusSub?.cancel();
    _legacyStatusSub = null;
    await disconnect();
    if (!_messageController.isClosed) await _messageController.close();
    if (!_statusController.isClosed) await _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Background monitor (the "is the socket alive?" service)
  // ---------------------------------------------------------------------------

  /// Starts a background service that, on every [_monitorInterval] tick:
  ///   - if the socket is connected  -> sends a keep-alive ping and reports it
  ///     is still connected;
  ///   - if the socket is NOT connected -> attempts to (re)connect / ping.
  void startConnectionMonitor() {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(_monitorInterval, (_) => _monitorTick());
  }

  void stopConnectionMonitor() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// Manually run a single health check. Returns true if the socket is
  /// currently connected, false otherwise (and triggers a recovery attempt).
  Future<bool> checkConnection() async {
    return _monitorTick();
  }

  Future<bool> _monitorTick() async {
    if (_manuallyClosed) return false;

    if (isConnected) {
      // Healthy: the dedicated heartbeat timer already keeps the connection
      // warm with pings, so the monitor must NOT reconnect here. Doing so is
      // what was tearing the socket down and re-opening it every interval.
      _updateStatus(WebSocketStatus.connected, 'Connected', notifyOnSame: false);
      return true;
    }

    // Not connected: figure out why and recover.
    _hasInternet = await _checkInternet();
    if (!_hasInternet) {
      _updateStatus(
        WebSocketStatus.noInternet,
        'Socket disconnected: no internet connection.',
      );
      return false;
    }

    _updateStatus(WebSocketStatus.reconnecting, 'Reconnecting socket…');
    await connect();
    return isConnected;
  }

  // ---------------------------------------------------------------------------
  // Internet connectivity watcher
  // ---------------------------------------------------------------------------
  void _startConnectivityWatcher() {
    _connectivitySub?.cancel();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _handleConnectivityChange(List<ConnectivityResult> results,) async {
    final bool offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);

    if (offline) {
      _hasInternet = false;
      _updateStatus(
        WebSocketStatus.noInternet,
        'Internet connection lost. Socket disconnected.',
      );
      await _teardownChannel();
      return;
    }

    // Network interface is back; verify real reachability before reconnecting.
    final bool reachable = await _checkInternet();
    if (!reachable) return;

    _hasInternet = true;
    if (!isConnected && !_manuallyClosed) {
      _updateStatus(
        WebSocketStatus.reconnecting,
        'Internet restored. Reconnecting socket…',
      );
      await connect();
      if (isConnected) {
        _updateStatus(
          WebSocketStatus.connected,
          'Internet restored. Socket reconnected.',
        );
      }
    }
  }

  /// Real reachability check (network interface present AND host reachable).
  Future<bool> _checkInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final bool hasInterface = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      if (!hasInterface) return false;
    } catch (_) {
      // If the plugin is unavailable, fall through to the lookup below.
    }

    try {
      final lookup = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Reconnect with exponential backoff
  // ---------------------------------------------------------------------------
  void _scheduleReconnect() {
    if (_manuallyClosed) return;
    _reconnectTimer?.cancel();

    final delay = _currentBackoff();
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, () async {
      if (_manuallyClosed) return;
      if (!await _checkInternet()) {
        _updateStatus(
          WebSocketStatus.noInternet,
          'No internet connection. Waiting for network to reconnect…',
        );
        return;
      }
      _updateStatus(WebSocketStatus.reconnecting, 'Reconnecting socket…');
      await connect();
    });
  }

  Duration _currentBackoff() {
    final multiplier = 1 << _reconnectAttempts.clamp(0, 4); // 1,2,4,8,16
    final ms = _baseReconnectDelay.inMilliseconds * multiplier;
    return Duration(
      milliseconds: ms.clamp(
        _baseReconnectDelay.inMilliseconds,
        _maxReconnectDelay.inMilliseconds,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Messaging
  // ---------------------------------------------------------------------------

  /// Send the keep-alive ping with the configured token and arm the pong
  /// watchdog. The server is expected to answer with a `ping-response`, which
  /// [_handleIncomingMessage] uses to disarm the watchdog.
  void sendPing() {
    if (!isConnected) return;
    send({
      'type': SocketMessageType.ping,
      'data': {'token': _token},
    });
    _armPongWatchdog();
  }

  // ---------------------------------------------------------------------------
  // Heartbeat (keeps the server session alive) + pong watchdog
  // ---------------------------------------------------------------------------

  /// Start sending a keep-alive `ping` every [_heartbeatInterval] while the
  /// socket is connected. This interval is kept below the server's 3-minute
  /// idle-timeout so the session never expires under a live connection.
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_manuallyClosed || !isConnected) return;
      sendPing();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pongTimer?.cancel();
    _pongTimer = null;
  }

  /// Expect a `ping-response` within [_pongTimeout]; if it never arrives the
  /// socket is silently dead, so tear it down and reconnect.
  void _armPongWatchdog() {
    _pongTimer?.cancel();
    _pongTimer = Timer(_pongTimeout, () async {
      if (_manuallyClosed) return;
      _updateStatus(
        WebSocketStatus.reconnecting,
        'No ping-response from server. Reconnecting socket…',
      );
      await connect();
    });
  }

  void _onPongReceived() {
    _pongTimer?.cancel();
    _pongTimer = null;
  }

  /// While the app is NOT in the foreground, route real (non-protocol) messages
  /// to the notification provider so the user is alerted. This is the plug
  /// point for your custom notification SDK (no-op until one is injected).
  ///
  /// NOTE: once your SDK delivers messages via real background push, the socket
  /// will normally be closed in the background and this path only covers the
  /// short grace window before disconnect.
  void _maybeNotifyInBackground(Map<String, dynamic> message) {
    if (_isInForeground) return;
    const protocolTypes = {
      'ping-response',
      'auth-request',
      'auth-status',
      'error',
    };
    final type = message['type'];
    if (type is String && protocolTypes.contains(type)) return;
    // Fire-and-forget; the no-op implementation does nothing.
    _notificationService.showMessageNotification(message);
  }

  void authenticateUser(String username, String password){
    send({
      "type": "auth",
      "data": {
        "username": username,
        "password": password
      }
    });
  }

  /// Send any JSON message over the socket. Silently no-ops if not connected
  /// so callers never crash; check [isConnected] if you need certainty.
  void send(Map<String, dynamic> message) {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode(message));
    } catch (_) {
      // Sink may be closing; ignore and let the monitor recover.
    }
  }

  // ---------------------------------------------------------------------------
  // Internal handlers
  // ---------------------------------------------------------------------------

  /// Broadcast a parsed message to every stream listener and run central
  /// protocol handlers (auth, pong watchdog, background notifications).
  void _dispatchMessage(Map<String, dynamic> message) {
    final type = message['type'];

    if (type == SocketMessageType.pingResponse) {
      _onPongReceived();
    }

    if (type == SocketMessageType.authRequest &&
        _authUsername != null &&
        _authPassword != null) {
      authenticateUser(_authUsername!, _authPassword!);
    }

    _maybeNotifyInBackground(message);

    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data as String);
      if (decoded is Map<String, dynamic>) {
        _dispatchMessage(decoded);
      } else {
        _dispatchMessage({'type': SocketMessageType.raw, 'data': decoded});
      }
    } catch (_) {
      _dispatchMessage({
        'type': SocketMessageType.raw,
        'data': {'message': data.toString()},
      });
    }
  }

  void _handleSocketError(Object error) {
    _dispatchMessage({
      'type': SocketMessageType.error,
      'data': {'message': error.toString()},
    });
    _updateStatus(WebSocketStatus.disconnected, 'Connection error: $error');
    _scheduleReconnect();
  }

  void _handleSocketDone() {
    _channel = null;
    if (_manuallyClosed) return;
    _updateStatus(WebSocketStatus.disconnected, 'Socket closed by server.');
    _scheduleReconnect();
  }

  Future<void> _teardownChannel() async {
    _stopHeartbeat();
    await _socketSub?.cancel();
    _socketSub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _updateStatus(
    WebSocketStatus status,
    String message, {
    bool notifyOnSame = true,
  }) {
    if (!notifyOnSame && status == _status) return;
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(
        WebSocketStatusUpdate(status: status, message: message),
      );
    }
  }
}
