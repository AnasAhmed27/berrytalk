import 'dart:developer' as developer;

import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'active_chat_tracker.dart';
import 'chat_notification_router.dart';
import 'push_notification_service.dart';

/// Real, dependency-backed implementation of [PushNotificationService] using
/// `flutter_local_notifications`. Shows a local banner for incoming socket
/// `notification-response` messages while the app is running.
///
/// This is a stand-in until the custom push SDK is wired in — swap it by
/// injecting a different [PushNotificationService] into `WebSocketService`.
class LocalPushNotificationService implements PushNotificationService {
  LocalPushNotificationService();

  static const _channelId = 'berrytalks_messages';
  static const _channelName = 'Messages';
  static const _channelDescription = 'New chat message notifications';

  static const _silentChannelId = 'berrytalks_messages_silent';
  static const _silentChannelName = 'Silent Messages';
  static const _silentChannelDescription = 'Silent chat message notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _idCounter = 0;

  /// notification id → normalized customer number (for per-chat dismiss).
  final Map<int, String> _idToNumber = {};

  Future<bool> requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidImplementation?.requestNotificationsPermission();

    // iOS ke liye permission request
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final bool? iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (granted ?? false) || (iosGranted ?? false);
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // App launched from a terminated state by tapping a notification.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _onNotificationTapped(launchDetails!.notificationResponse);
    }

    // Android 13+ needs a runtime POST_NOTIFICATIONS grant.
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
      ),
    );

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _silentChannelId,
        _silentChannelName,
        description: _silentChannelDescription,
        importance: Importance.low, // Low importance minimizes intrusive sound/banners
        playSound: false,
        enableVibration: false,
      ),
    );

    _initialized = true;
  }

  

  @override
  Future<void> registerDeviceToken({String? authToken}) async {
    // Local notifications need no server token.
  }

  /// Routes a notification tap to the chat opener. The payload carries the
  /// customer's number so the router can open the exact chat.
  void _onNotificationTapped(NotificationResponse? response) {
    final number = response?.payload;
    if (number == null || number.isEmpty) return;
    ChatNotificationRouter.instance.handleNotificationTap(number);
  }

  @override
  Future<void> showMessageNotification(Map<String, dynamic> message) async {
    final isPushEnabled = await SharedPrefData.getPushNotificationPreference();
    if (!isPushEnabled) {
      developer.log('LocalPushNotificationService: Ignored. Push notifications are disabled in settings.');
      return;
    }

    final isSoundEnabled = await SharedPrefData.getSoundAlertsPreference();
    if (!_initialized) await initialize();

    final data = message['data'];
    final content = data is Map
        ? (data['notificationContent']?.toString() ??
              data['message']?.toString())
        : null;
    final title = message['message']?.toString() ?? 'New message';
    final body = content ?? 'You have received a new message';

    // Customer number carried as payload so a tap can open the exact chat.
    final payload = ActiveChatTracker.instance.numberFromNotification(message);

    // Unique id so multiple messages stack instead of replacing each other.
    final id = (_idCounter = (_idCounter + 1) % 2147483647);

    final activeChannelId = isSoundEnabled ? _channelId : _silentChannelId;
    final activeChannelName = isSoundEnabled ? _channelName : _silentChannelName;
    final activeChannelDescription = isSoundEnabled ? _channelDescription : _silentChannelDescription;
    final activeImportance = isSoundEnabled ? Importance.high : Importance.low;
    final activePriority = isSoundEnabled ? Priority.high : Priority.low;

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
           activeChannelId,
            activeChannelName,
            channelDescription: activeChannelDescription,
            importance: activeImportance,
            priority: activePriority,
            playSound: isSoundEnabled,
            enableVibration: isSoundEnabled,
            ticker: 'New message',
          ),
          // present* flags let the banner + sound show while the iOS app is in
          // the foreground (default iOS behaviour is to suppress it).
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
           presentSound: isSoundEnabled,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: payload,
      );

      if (payload != null && payload.isNotEmpty) {
        _idToNumber[id] = payload;
      }
    } catch (e) {
      developer.log('LocalPushNotificationService: show failed -> $e');
    }
  }

  @override
  Future<void> dismissNotificationsForCustomer(String number) async {
    if (!_initialized) return;

    final target = ActiveChatTracker.normalize(number);
    if (target == null || target.isEmpty) return;

    final idsToCancel = <int>[];
    _idToNumber.forEach((id, storedNumber) {
      if (storedNumber == target) idsToCancel.add(id);
    });

    for (final id in idsToCancel) {
      try {
        await _plugin.cancel(id: id);
      } catch (e) {
        developer.log(
          'LocalPushNotificationService: cancel id=$id failed -> $e',
        );
      }
      _idToNumber.remove(id);
    }

    if (idsToCancel.isNotEmpty) {
      developer.log(
        'LocalPushNotificationService: dismissed ${idsToCancel.length} '
        'notification(s) for $target',
      );
    }
  }

  @override
  Future<void> dispose() async {
    _idToNumber.clear();
    await _plugin.cancelAll();
  }
}
