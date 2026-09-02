import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';

/// Plays the WhatsApp-style "new message" tone for incoming chat messages.
///
/// A short debounce prevents a double sound when both the `notification-response`
/// and `send-message-data-response` events arrive for the same message.
class MessageSoundPlayer {
  MessageSoundPlayer._();

  static final MessageSoundPlayer instance = MessageSoundPlayer._();

  static const _asset = 'sounds/new_messag_notification_sound.wav';

  final AudioPlayer _player = AudioPlayer(playerId: 'new_message_tone');
  DateTime? _lastPlayed;

  /// Plays the new-message tone (ignored if fired again within 500ms).
  Future<void> playNewMessageTone() async {
    final isSoundEnabled = await SharedPrefData.getSoundAlertsPreference();
    if (!isSoundEnabled) {
      developer.log('MessageSoundPlayer: Ignored. Sound alerts are disabled in settings.');
      return;
    }
    final now = DateTime.now();
    if (_lastPlayed != null &&
        now.difference(_lastPlayed!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastPlayed = now;

    try {
      await _player.stop();
      await _player.play(AssetSource(_asset));
    } catch (e) {
      developer.log('MessageSoundPlayer: failed to play tone -> $e');
    }
  }
}
