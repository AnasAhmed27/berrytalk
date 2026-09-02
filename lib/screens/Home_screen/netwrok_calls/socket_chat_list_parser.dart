import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/network/socket_service/socket_message_types.dart';

/// Parses the Omni socket `contact-list-update` payload into [ContactData] items.
///
/// Expected wire format:
/// ```json
/// {
///   "type": "contact-list-update",
///   "message": "Contact List updated",
///   "data": [ { "id": "...", "agentId": "...", ... } ]
/// }
/// ```
class SocketChatListParser {
  const SocketChatListParser._();

  /// Returns `null` when the payload is empty or indicates failure.
  /// Returns an empty list when parsing succeeded but the server sent zero items.
  static List<ContactData>? parse(Map<String, dynamic> socketMessage) {
    final type = socketMessage['type'];
    if (type is String &&
        type != SocketMessageType.contactListUpdate &&
        type != SocketMessageType.updateChatList) {
      return null;
    }

    final dynamic data = socketMessage['data'];
    if (data == null) return null;

    if (data is List) {
      return _parseContactList(data);
    }

    if (data is Map<String, dynamic>) {
      return _parseFromMap(data);
    }

    return null;
  }

  static List<ContactData>? _parseFromMap(Map<String, dynamic> data) {
    if (data['data'] is List) {
      final success = data['success'];
      if (success == false) return null;
      return _parseContactList(data['data'] as List);
    }

    for (final key in ['contacts', 'chatList', 'items', 'conversations']) {
      if (data[key] is List) {
        return _parseContactList(data[key] as List);
      }
    }

    return null;
  }

  static List<ContactData> _parseContactList(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => ContactData.fromJson(_normalizeContactItem(item)))
        .toList();
  }

  /// Maps socket-only field names to the [ContactData] REST model shape.
  static Map<String, dynamic> _normalizeContactItem(Map<dynamic, dynamic> item) {
    final normalized = Map<String, dynamic>.from(item);

    // Socket payload uses `agentId`; REST / [ContactData] uses `agentPublicId`.
    normalized['agentPublicId'] ??=
        item['agentId'] ?? item['agentPublicId'];

    // Ensure string timestamps (socket may send numeric epoch seconds).
    final timeStamp = normalized['timeStamp'];
    if (timeStamp != null && timeStamp is! String) {
      normalized['timeStamp'] = timeStamp.toString();
    }

    return normalized;
  }
}
