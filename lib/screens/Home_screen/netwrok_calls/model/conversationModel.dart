part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable()
class ChatContactApiModel extends BaseResponseModel {
  final List<ContactData>? data;

  ChatContactApiModel({
    required super.success,
    required super.message,
    required super.code,
    required this.data,
  });

  factory ChatContactApiModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);
    json['success'] = base.success; 
    json['message'] = base.message;
    json['code'] = base.code;
    return _$ChatContactApiModelFromJson(json);
  }

  Map<String, dynamic> toJson() => {
        'status': success ? 1 : 0,
        'message': message,
        'code': code,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

@JsonSerializable(explicitToJson: true)
class ContactData {
 final String? id;

  /// Conversation public id — used as `conversationId` on the socket.
  final String? publicId;
  
  @JsonKey(name: "companyPublicId") 
  final String? companyPublicId; 

  @JsonKey(name: "agentPublicId")  
  final String? agentPublicId;

  @JsonKey(name: "customerName")
  final String? customerName;
  final String? number;
  final String? lastMessage;
  final String? chanelId;
  final String? timeStamp;
  final dynamic unReadCount;
  final String? status;
  final String? isResolved;

  ContactData({
   this.id,
    this.publicId,
    this.companyPublicId, 
    this.agentPublicId,   
    this.customerName,
    this.number,
    this.lastMessage,
    this.chanelId,
    this.timeStamp,
    this.unReadCount,
    this.status,
    this.isResolved,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    // REST/socket often send `agentId`; model field is `agentPublicId`.
    final normalized = Map<String, dynamic>.from(json);
    normalized['agentPublicId'] ??=
        json['agentId'] ?? json['agentPublicId'];
    return _$ContactDataFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$ContactDataToJson(this);



String get formattedTime {
  if (timeStamp == null || timeStamp!.trim().isEmpty) return "";
  
  try {
    DateTime msgTime;
    

    int? ts = int.tryParse(timeStamp!);
    if (ts != null) {
      if (timeStamp!.length == 10) {
        ts *= 1000;
      }
      msgTime = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
    } else {
    
      msgTime = DateTime.parse(timeStamp!).toLocal();
    }
    
    final DateTime now = DateTime.now().toLocal();
 
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime messageDay = DateTime(msgTime.year, msgTime.month, msgTime.day);
    
    final Duration difference = today.difference(messageDay);
    final int differenceInDays = difference.inDays;


    if (differenceInDays == 0) {
      final Duration timeDiff = now.difference(msgTime);
      
      if (timeDiff.inSeconds < 60) {
        return "Just now";
      }
      if (timeDiff.inMinutes < 60) {
        return "${timeDiff.inMinutes}m ago";
      }
      return "${timeDiff.inHours}h ago";
    }
    

    if (differenceInDays == 1) {
      return "Yesterday";
    }
    
    if (differenceInDays > 1 && differenceInDays <= 7) {
      return "$differenceInDays days ago";
    }
    
    return "${msgTime.day.toString().padLeft(2, '0')}/${msgTime.month.toString().padLeft(2, '0')}/${msgTime.year}";
    
  } catch (e) {
   
    return "";
  }
}

  String get displayName {
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!;
    }
    if (number != null && number!.trim().isNotEmpty) {
      return number!;
    }
    return number ?? "Unknown User";
  }

  SocialPlatform get platform {
  String channel = (chanelId ?? '').toLowerCase();
  if (channel.contains('whatsapp')) return SocialPlatform.whatsapp;
  if (channel.contains('email')) return SocialPlatform.email;
  if (channel.contains('facebook') || channel.contains('messenger')) return SocialPlatform.facebook;
  if (channel.contains('instagram') || channel.contains('ig')) return SocialPlatform.instagram;
  if (channel.contains('wechat')) return SocialPlatform.wechat;
  if (channel.contains('twitter')) return SocialPlatform.twitter;
    return SocialPlatform.sms; 
}

  int get calculatedUnreadCount {
    if (unReadCount == null) return 0;
    if (unReadCount is int) return unReadCount;
    return int.tryParse(unReadCount.toString()) ?? 0;
  }

  bool get isChatResolved {
    if (isResolved == null) return false;
    return isResolved!.toLowerCase().trim() == "true";
  }
}