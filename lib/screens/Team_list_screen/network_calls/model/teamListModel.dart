part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable(createToJson: false)
class TeamContactApiModel extends BaseResponseModel {
  final List<TeamContactData>? data;

  TeamContactApiModel({
    required super.success,
    required super.message,
    required super.code,
    this.data,
  });

  factory TeamContactApiModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final bool isSuccess = rawStatus == 1 || rawStatus == true;
    final String? msg = json['message'];
    final int statusCode = json['code'] ?? (isSuccess ? 200 : 400);

    List<TeamContactData>? parsedData;
    
    if (json['data'] != null) {
      final dataField = json['data'];
      
      if (dataField is List) {
        parsedData = dataField
            .map((e) => TeamContactData.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (dataField is Map<String, dynamic>) {
        if (dataField['content'] != null && dataField['content'] is List) {
          final contentList = dataField['content'] as List;
          parsedData = contentList
              .map((e) => TeamContactData.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else if (dataField is Map) {
        final content = dataField['content'];
        if (content is List) {
          parsedData = content
              .map((e) => TeamContactData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
    }

    return TeamContactApiModel(
      success: isSuccess,
      message: msg ?? "",
      code: statusCode,
      data: parsedData,
    );
  }
}

@JsonSerializable()
class TeamContactData {
  final String? publicId; 
  final String? companyPublicId;
  final String? status;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? profilePic;
  final String? phoneNumberWork;
  final String? senderAgentId;
  final String? recipientAgentId;
  final String? agentId;
  final String? customerName;
  final String? lastMessage;
  final String? timestamp;
  final int? recipientUnReadCount;
  final int? senderUnReadCount;
  final String? conversationId;

  TeamContactData({
    this.publicId,
    this.companyPublicId,
    this.status,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.profilePic,
    this.phoneNumberWork,
    this.senderAgentId,
    this.recipientAgentId,
    this.agentId,
    this.customerName,
    this.lastMessage,
    this.timestamp,
    this.recipientUnReadCount,
    this.senderUnReadCount,
    this.conversationId,
  });

  factory TeamContactData.fromJson(Map<String, dynamic> json) =>
      _$TeamContactDataFromJson(json);

  Map<String, dynamic> toJson() => _$TeamContactDataToJson(this);


  String get formattedTime {
    if (timestamp == null || timestamp!.isEmpty) return "";
    try {
      int ts = int.parse(timestamp!);
      if (timestamp!.length == 10) ts *= 1000;
      
      DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(ts);
      DateTime now = DateTime.now();
      Duration difference = now.difference(msgTime);

      if (difference.inSeconds < 60) return "Just now";
      if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
      if (difference.inHours < 24 && msgTime.day == now.day) return "${difference.inHours}h ago";
      
      DateTime yesterday = now.subtract(const Duration(days: 1));
      if (msgTime.day == yesterday.day && 
          msgTime.month == yesterday.month && 
          msgTime.year == yesterday.year) {
        return "Yesterday";
      }
      if (difference.inDays < 7) return "${difference.inDays} days ago";
      
      return "${msgTime.day.toString().padLeft(2, '0')}/${msgTime.month.toString().padLeft(2, '0')}/${msgTime.year}";
    } catch (e) {
      return "";
    }
  }

  String get displayName {
    if (firstName != null || lastName != null) {
      return "${firstName ?? ''} ${lastName ?? ''}".trim();
    }
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!;
    }
    return "Unknown Agent / User";
  }

  String get displayRole {
    if (role == null) return "";
    return role!.replaceAll("ROLE_", "");
  }

  bool get isOnline {
    return status?.toUpperCase() == "ONLINE";
  }

  int get calculatedUnreadCount {
    return recipientUnReadCount ?? 0;
  }
}