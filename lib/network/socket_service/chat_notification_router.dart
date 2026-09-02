import 'dart:developer' as developer;

import 'package:berrytalks/services/storage/SharedPrefrences.dart';

import 'active_chat_tracker.dart';
import 'message_sound_player.dart';
import 'websocket_service.dart';

/// WhatsApp-style router for incoming `notification-response` socket messages.
///
/// Decision matrix (foreground, socket connected):
///
/// | Where the user is        | Message for open chat | Message for other chat |
/// |--------------------------|-----------------------|------------------------|
/// | Home screen (no chat)    | push notification     | push notification      |
/// | Inside Chat B            | sound only, no push   | push notification      |
///
/// The actual "show notification" step is delegated to the injectable
/// [PushNotificationService] plug point (your custom SDK later). The in-chat
/// "same chat" case only plays a short system sound, like WhatsApp.
class ChatNotificationRouter {
  ChatNotificationRouter._();

  static final ChatNotificationRouter instance = ChatNotificationRouter._();

  final ActiveChatTracker _activeChat = ActiveChatTracker.instance;
  final WebSocketService _ws = WebSocketService();

  /// Handler that actually opens a chat for a customer [number]. Registered by
  /// the Home screen (which owns the contact list + navigation).
  void Function(String number)? _chatOpener;

  /// Buffers a tap that arrives before the opener is ready (e.g. cold start
  /// from a terminated app), flushed as soon as [registerChatOpener] runs.
  String? _pendingOpenNumber;

  /// Home screen registers how to open a chat here. Any tap that arrived
  /// before registration is replayed immediately.
  void registerChatOpener(void Function(String number) opener) {
    _chatOpener = opener;
    final pending = _pendingOpenNumber;
    if (pending != null) {
      _pendingOpenNumber = null;
      opener(pending);
    }
  }

  void unregisterChatOpener() {
    _chatOpener = null;
  }

  /// Called when the user taps a notification. Opens the matching chat.
  void handleNotificationTap(String? number) {
    final normalized = ActiveChatTracker.normalize(number);
    if (normalized == null || normalized.isEmpty) {
      developer.log('ChatNotification: tap ignored — no number in payload');
      return;
    }
    developer.log('ChatNotification: tap -> open chat for $normalized');
    final opener = _chatOpener;
    if (opener != null) {
      opener(normalized);
    } else {
      _pendingOpenNumber = normalized;
    }
  }

  /// Entry point for the `notification-response` listener.
  Future<void> handleNotificationResponse(Map<String, dynamic> json) async {
    // If the message targets the chat the user is already viewing, WhatsApp
    // does not raise a banner — it just plays a subtle sound.
    if (_activeChat.isForActiveChat(json)) {
      developer.log(
        'ChatNotification: message for the OPEN chat -> sound only, no push',
      );
      _playInChatSound();
      return;
    }

    final isPushEnabled = await SharedPrefData.getPushNotificationPreference();
    if (!isPushEnabled) {
      developer.log('ChatNotification: Push is disabled in settings. Router dropped the notification.');
      return;
    }

    // Otherwise (on Home, or a message from a different chat) surface it.
    developer.log(
      ' ChatNotification: message for another/no open chat -> push notification',
    );
    _showNotification(json);
  }

  void _playInChatSound() {
    // WhatsApp-style in-chat tone. Debounced in the player so it won't double
    // up with the chat screen's own `send-message-data-response` sound.
    MessageSoundPlayer.instance.playNewMessageTone();
  }

  void _showNotification(Map<String, dynamic> json) {
    // Routed through the injectable plug point so your custom notification SDK
    // renders the banner. No-op until a real service is injected.
    _ws.notificationService.showMessageNotification(json);
  }
}
