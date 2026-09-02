/// Tracks which conversation the user currently has OPEN on screen.
///
/// This is the single source of truth used by [ChatNotificationRouter] to
/// decide, WhatsApp-style, whether an incoming `notification-response` should
/// pop a push notification or just play an in-chat sound:
///
///   * No chat open (Home screen)        -> push notification for every message
///   * Chat B open, message is for B      -> sound only, NO notification
///   * Chat B open, message is for A / C   -> push notification
///
/// The Chat screen registers itself in `initState` and clears it in `dispose`,
/// so the tracker always reflects the top-most chat (or `null` when none).
class ActiveChatTracker {
  ActiveChatTracker._();

  static final ActiveChatTracker instance = ActiveChatTracker._();

  // Normalized digits of the customer's number — the reliable identifier that
  // appears in both the open-chat contact and the notification payload.
  String? _number;

  /// Marks a chat as currently open on screen.
  void setActiveChat({String? number}) {
    _number = _normalizeNumber(number);
  }

  /// Clears the active chat (call from the chat screen's `dispose`).
  void clear() {
    _number = null;
  }

  bool get hasActiveChat => _number != null && _number!.isNotEmpty;

  /// Whether the given [notification] payload belongs to the chat that is
  /// currently open on screen.
  bool isForActiveChat(Map<String, dynamic> notification) {
    if (!hasActiveChat) return false;
    final incoming = numberFromNotification(notification);
    if (incoming == null || incoming.isEmpty) return false;
    return incoming == _number;
  }

  /// Normalizes a raw phone number to digits-only for reliable comparison.
  static String? normalize(String? raw) => _normalizeNumber(raw);

  /// Pulls the customer's number out of a socket notification payload.
  ///
  /// The Omni `notification-response` has no dedicated number field; the
  /// sender's number is embedded at the end of `notificationContent`, e.g.
  /// `"You have received a new message from923152931575"`. We also fall back to
  /// common explicit fields in case the server shape changes later.
  String? numberFromNotification(Map<String, dynamic> json) {
    final candidates = <String>[
      'number',
      'phoneNumber',
      'recipientNumber',
      'contactNumber',
      'from',
      'sender',
      'msisdn',
    ];

    for (final map in _searchMaps(json)) {
      for (final key in candidates) {
        final value = map[key];
        final normalized = _normalizeNumber(value?.toString());
        if (normalized != null && normalized.isNotEmpty) return normalized;
      }

      // Parse the phone-number-like digit run out of the human-readable text.
      for (final textKey in const ['notificationContent', 'message']) {
        final fromText = _numberFromText(map[textKey]?.toString());
        if (fromText != null) return fromText;
      }
    }
    return null;
  }

  /// Extracts the longest 7+ digit run from a free-text string (a phone number).
  String? _numberFromText(String? text) {
    if (text == null || text.isEmpty) return null;
    final matches = RegExp(r'\d{7,}').allMatches(text).map((m) => m.group(0)!);
    String? longest;
    for (final m in matches) {
      if (longest == null || m.length > longest.length) longest = m;
    }
    return longest;
  }

  /// Returns the payload map plus any nested `data` maps to search through.
  List<Map<String, dynamic>> _searchMaps(Map<String, dynamic> json) {
    final maps = <Map<String, dynamic>>[json];
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      maps.add(data);
      final inner = data['data'];
      if (inner is Map<String, dynamic>) maps.add(inner);
    }
    return maps;
  }

  static String? _normalizeNumber(String? raw) {
    final cleaned = _clean(raw);
    if (cleaned == null) return null;
    final digits = cleaned.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? cleaned : digits;
  }

  static String? _clean(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }
}
