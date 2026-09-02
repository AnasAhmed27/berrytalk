import 'dart:async';

import 'package:flutter/widgets.dart';

import 'websocket_service.dart';

/// Mixin for [StatefulWidget] screens that need their own socket listener.
///
/// Each screen subscribes only to the event types it cares about. Subscriptions
/// are cancelled automatically in [dispose] — no leaks, no overwriting other
/// screens' listeners.
///
/// Example (Home screen):
/// ```dart
/// class _HomeScreenState extends State<HomeScreen> with SocketScreenListener {
///   @override
///   void initState() {
///     super.initState();
///     listenSocketType('update-chat-list', _onChatListUpdate);
///   }
///
///   void _onChatListUpdate(Map<String, dynamic> msg) { ... }
/// }
/// ```
mixin SocketScreenListener<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription<dynamic>> _socketSubscriptions = [];
  bool _socketListenerDisposed = false;

  WebSocketService get socket => WebSocketService();

  /// Listen to ALL socket messages on this screen.
  StreamSubscription<Map<String, dynamic>> listenSocketMessages(
    void Function(Map<String, dynamic> message) handler,
  ) {
    final sub = socket.messages.listen((message) {
      if (_socketListenerDisposed || !mounted) return;
      handler(message);
    });
    _socketSubscriptions.add(sub);
    return sub;
  }

  /// Listen to a single message [type] on this screen.
  StreamSubscription<Map<String, dynamic>> listenSocketType(
    String type,
    void Function(Map<String, dynamic> message) handler,
  ) {
    final sub = socket.onType(type).listen((message) {
      if (_socketListenerDisposed || !mounted) return;
      handler(message);
    });
    _socketSubscriptions.add(sub);
    return sub;
  }

  /// Listen to several message [types] on this screen.
  StreamSubscription<Map<String, dynamic>> listenSocketTypes(
    Set<String> types,
    void Function(Map<String, dynamic> message) handler,
  ) {
    final sub = socket.onTypes(types).listen((message) {
      if (_socketListenerDisposed || !mounted) return;
      handler(message);
    });
    _socketSubscriptions.add(sub);
    return sub;
  }

  /// Listen to connection status changes on this screen.
  StreamSubscription<WebSocketStatusUpdate> listenSocketStatus(
    void Function(WebSocketStatusUpdate update) handler,
  ) {
    final sub = socket.statusStream.listen((update) {
      if (_socketListenerDisposed || !mounted) return;
      handler(update);
    });
    _socketSubscriptions.add(sub);
    return sub;
  }

  @override
  void dispose() {
    _socketListenerDisposed = true;
    for (final sub in _socketSubscriptions) {
      sub.cancel();
    }
    _socketSubscriptions.clear();
    super.dispose();
  }
}
