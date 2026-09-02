import 'dart:io';

/// Platform media size limits for BerryTalks outbound attachments.
///
/// Sources:
/// - WhatsApp Cloud API supported media types
///   https://developers.facebook.com/documentation/business-messaging/whatsapp/business-phone-numbers/media#supported-media-types
/// - Facebook / Instagram messaging automation guidelines (conservative caps)
class MediaAttachmentPolicy {
  MediaAttachmentPolicy._();

  static const int _kb = 1024;
  static const int _mb = 1024 * 1024;

  /// Validates [file] against [channelId] + resolved [stream]
  /// (`image` | `video` | `audio` | `document`).
  ///
  /// Returns `null` when OK, otherwise a user-facing error message.
  static Future<String?> validateBeforeUpload({
    required File file,
    required String channelId,
    required String stream,
  }) async {
    if (!await file.exists()) {
      return 'File not found on device.';
    }

    final int bytes = await file.length();
    if (bytes <= 0) {
      return 'This file is empty and cannot be sent.';
    }

    final String channel = _normalizeChannel(channelId);
    final String kind = stream.toLowerCase().trim();
    final int maxBytes = maxBytesFor(channel: channel, stream: kind);
    final String platformLabel = _platformLabel(channel);
    final String kindLabel = _kindLabel(kind);

    if (bytes > maxBytes) {
      final actual = _formatSize(bytes);
      final allowed = _formatSize(maxBytes);
      return '$kindLabel is $actual. $platformLabel allows max $allowed. '
          'Please choose a smaller file.';
    }

    // WhatsApp Cloud API only accepts these video containers.
    if (channel == 'whatsapp' && kind == 'video') {
      final lower = file.path.toLowerCase();
      final okExt = lower.endsWith('.mp4') ||
          lower.endsWith('.3gp') ||
          lower.endsWith('.3gpp');
      if (!okExt) {
        return 'WhatsApp only supports MP4 or 3GP videos (H.264 + AAC).';
      }
    }

    return null;
  }

  static int maxBytesFor({
    required String channel,
    required String stream,
  }) {
    final c = _normalizeChannel(channel);
    final s = stream.toLowerCase().trim();

    switch (c) {
      case 'whatsapp':
        switch (s) {
          case 'image':
            return 5 * _mb;
          case 'video':
          case 'audio':
            return 16 * _mb;
          case 'document':
          default:
            return 100 * _mb;
        }
      case 'facebook':
        switch (s) {
          case 'image':
            return 8 * _mb;
          case 'video':
          case 'audio':
          case 'document':
          default:
            return 25 * _mb;
        }
      case 'instagram':
        switch (s) {
          case 'image':
            return 8 * _mb;
          case 'video':
          case 'audio':
          case 'document':
          default:
            return 25 * _mb;
        }
      default:
        // Unknown channel — keep a safe shared ceiling.
        switch (s) {
          case 'image':
            return 8 * _mb;
          case 'video':
          case 'audio':
            return 16 * _mb;
          default:
            return 25 * _mb;
        }
    }
  }

  static String _normalizeChannel(String channelId) {
    final c = channelId.trim().toLowerCase();
    if (c.contains('whatsapp') || c == 'wa') return 'whatsapp';
    if (c.contains('facebook') || c == 'fb' || c == 'page') return 'facebook';
    if (c.contains('instagram') || c == 'ig') return 'instagram';
    return c;
  }

  static String _platformLabel(String channel) {
    switch (channel) {
      case 'whatsapp':
        return 'WhatsApp';
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      default:
        return 'This channel';
    }
  }

  static String _kindLabel(String stream) {
    switch (stream) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'document':
        return 'Document';
      default:
        return 'Attachment';
    }
  }

  static String _formatSize(int bytes) {
    if (bytes >= _mb) {
      final mb = bytes / _mb;
      final text = mb >= 10 ? mb.toStringAsFixed(0) : mb.toStringAsFixed(1);
      return '${text}MB';
    }
    final kb = (bytes / _kb).ceil();
    return '${kb}KB';
  }
}
