// =============================================================================
// PushNotificationService - SDK-agnostic contract for delivering messages while
// the app is in the background / killed (when the WebSocket is disconnected).
//
// WHY THIS EXISTS NOW (feasibility scaffold):
//   The production strategy is: keep the socket only while the app is in the
//   foreground; while the app is backgrounded the socket is closed and the
//   server should deliver messages via PUSH notifications instead.
//
//   You said you'll plug in your OWN custom notification SDK later (not
//   Firebase). This interface is that plug point. Today it is backed by a
//   no-op implementation so nothing changes at runtime; when your SDK is
//   ready you simply:
//
//     1. Create a class that `implements PushNotificationService` and wraps
//        your SDK (init, token registration, showing notifications).
//     2. Inject it once at startup:
//
//          WebSocketService().setNotificationService(MyCustomPushService());
//          await WebSocketService().notificationService.initialize();
//          await WebSocketService().notificationService
//              .registerDeviceToken(authToken: token);
//
//   No other code needs to change.
// =============================================================================

/// Contract that a background/push notification provider must fulfil.
abstract class PushNotificationService {
  /// One-time setup: request permissions, create channels, init the SDK, etc.
  Future<void> initialize();

  /// Register / refresh this device's push token with your backend so the
  /// server can deliver messages while the app is backgrounded or killed.
  Future<void> registerDeviceToken({String? authToken});

  /// Show a user-visible notification for an incoming message payload.
  ///
  /// The [message] map is the same JSON shape the socket delivers, so your
  /// custom SDK can format the title/body however it likes.
  Future<void> showMessageNotification(Map<String, dynamic> message);

  /// Clears device notifications for [number] when the user opens that chat.
  Future<void> dismissNotificationsForCustomer(String number);

  /// Cleanup on logout / app shutdown (unregister token, dispose SDK).
  Future<void> dispose();
}

/// Safe default used until the real SDK is wired in. Intentionally does
/// nothing so the app behaves exactly as before push notifications are added.
class NoopPushNotificationService implements PushNotificationService {
  const NoopPushNotificationService();

  @override
  Future<void> initialize() async {
    // TODO: replace with your custom notification SDK init.
  }

  @override
  Future<void> registerDeviceToken({String? authToken}) async {
    // TODO: send the device push token to your backend here.
  }

  @override
  Future<void> showMessageNotification(Map<String, dynamic> message) async {
    // TODO: render a local/push notification from `message` here.
  }

  @override
  Future<void> dismissNotificationsForCustomer(String number) async {}

  @override
  Future<void> dispose() async {
    // TODO: unregister token / dispose SDK resources here.
  }
}
