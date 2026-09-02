part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable(explicitToJson: true)
class ChatDetailsApiModel extends BaseResponseModel {
  final ChatData? data;

  ChatDetailsApiModel({
    required super.success,
    required super.message,
    required super.code,
    required this.data,
  });

  factory ChatDetailsApiModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);
    json['success'] = base.success; 
    json['message'] = base.message;
    json['code'] = base.code;
    return _$ChatDetailsApiModelFromJson(json);
  }

  Map<String, dynamic> toJson() => {
        'status': success ? 1 : 0,
        'message': message,
        'code': code,
        'data': data?.toJson(),
      };
}

@JsonSerializable(explicitToJson: true)
class ChatData {
  final ConversationData? conversation;
  
  final ChatContactData? contact; 
  
  @JsonKey(name: 'inboxes')
  final List<InboxMessage>? inboxes;

  ChatData({this.conversation, this.contact, this.inboxes});

  factory ChatData.fromJson(Map<String, dynamic> json) =>
      _$ChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDataToJson(this);
}

@JsonSerializable()
class ConversationData {
  final String? id;
  final String? companyPublicId;
  final String? chanelId; 
  final String? number;
  final String? status;
  final String? agent;
  final dynamic isAgentAssign; 
  final dynamic isResolved;
  final String? timeStamp;
  final String? customerPublicId;
  final String? publicId;
  final String? entryPointId;
  final String? agentId;
  final String? agentName;
  final String? customerName;
  final bool? isExpired;
  final String? expiration;

  ConversationData({
    this.id,
    this.companyPublicId,
    this.chanelId,
    this.number,
    this.status,
    this.agent,
    this.isAgentAssign,
    this.isResolved,
    this.timeStamp,
    this.customerPublicId,
    this.publicId,
    this.entryPointId,
    this.agentId,
    this.agentName,
    this.customerName,
    this.isExpired,
    this.expiration,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) =>
      _$ConversationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDataToJson(this);

  DateTime? get expiryDateTime {
    if (expiration == null || expiration!.isEmpty) return null;
    final int? parsedSeconds = int.tryParse(expiration!);
    if (parsedSeconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(parsedSeconds * 1000);
    }
    return DateTime.tryParse(expiration!);
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
}

@JsonSerializable()
class InboxMessage {
  final String? id;
  final String? messageId;
  final String? messageType;
  final String? contactNumber;
  final String? body;
  final String? timestamp;
  final String? contactName;
  final String? recipientNumber;
  final dynamic conversationId;
  final dynamic isSent;
  final String? messageStatus;
  final String? filePath;
  final String? caption;
  final String? retryMessage; // original message publicId
final String? replyToBody;  // display ke liye — locally set hoga
final String? replyToType;  // text/media

// Reaction ke liye  
final String? reaction; 
final String? publicId;
final InboxMessage? replyToMessage;


  InboxMessage({
    this.id,
    this.messageId,
    this.messageType,
    this.contactNumber,
    this.body,
    this.timestamp,
    this.contactName,
    this.recipientNumber,
    this.conversationId,
    this.isSent,
    this.messageStatus,
    this.filePath,  
    this.caption,
    this.retryMessage,
     this.replyToMessage, 
    this.replyToBody,
    this.replyToType,
    this.reaction,
    this.publicId,
  });

  

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    final msg = _$InboxMessageFromJson(json);
    // WhatsApp may return relative paths (`assets/123.ogg`) — make them absolute.
    return InboxMessage(
      id: msg.id,
      messageId: msg.messageId,
      messageType: msg.messageType,
      contactNumber: msg.contactNumber,
      body: msg.body,
      timestamp: msg.timestamp,
      contactName: msg.contactName,
      recipientNumber: msg.recipientNumber,
      conversationId: msg.conversationId,
      isSent: msg.isSent,
      messageStatus: msg.messageStatus,
      filePath: MediaUrlResolver.resolve(msg.filePath),
      caption: msg.caption,
      retryMessage : msg.retryMessage,
      replyToBody: msg.replyToBody, 
      replyToType: msg.replyToType,
      reaction: msg.reaction,
      publicId: msg.publicId,
     
      
    );
  }

  Map<String, dynamic> toJson() => _$InboxMessageToJson(this);

  bool get isReadStatus {
    return messageStatus?.trim().toLowerCase() == 'read';
  }

  bool get isSentStatus {
    return messageStatus?.trim().toLowerCase() == 'sent';
  }
  
  bool get wasSentByMe {
    if (isSent == null) return false;
    return isSent.toString().toLowerCase() == 'true';
  }

  String get formattedMessageTime {
    if (timestamp == null || timestamp!.isEmpty) return "";

    try {
      DateTime dateTime;
      final int? parsedInt = int.tryParse(timestamp!);
      if (parsedInt != null) {
        int ts = parsedInt;
        if (timestamp!.length == 10) {
          ts *= 1000; 
        }
        dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
      } else {
        dateTime = DateTime.parse(timestamp!);
      }

      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print("Error parsing message timestamp: $e");
      return ""; 
    }
  }
}

@JsonSerializable(explicitToJson: true)
class ChatContactData {
  final int? id;
  final String? publicId;
  final String? firstName;
  final String? lastName;
  final String? mobileNumber;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? gender;
  final String? channelId;
  final List<ChatContactTag>? contactTags; 
  final bool? isActive;
  final String? currentChatStatus;

  ChatContactData({
    this.id,
    this.publicId,
    this.firstName,
    this.lastName,
    this.mobileNumber,
    this.email,
    this.address,
    this.city,
    this.state,
    this.country,
    this.gender,
    this.channelId,
    this.contactTags,
    this.isActive,
    this.currentChatStatus,
  });

  factory ChatContactData.fromJson(Map<String, dynamic> json) =>
      _$ChatContactDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatContactDataToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }
}

@JsonSerializable()
class ChatContactTag {
  final int? id;
  final String? tagName;
  final String? tagPrefix;
  final String? companyPublicId;
  final bool? isDeleted;

  ChatContactTag({
    this.id,
    this.tagName,
    this.tagPrefix,
    this.companyPublicId,
    this.isDeleted,
  });

  factory ChatContactTag.fromJson(Map<String, dynamic> json) =>
      _$ChatContactTagFromJson(json);

  Map<String, dynamic> toJson() => _$ChatContactTagToJson(this);
}

@JsonSerializable(createToJson: false)
class TransferChatResponseModel {
  final int? status;
  final String? message;
  final dynamic data;
  final String? prop;

  TransferChatResponseModel({
    this.status,
    this.message,
    this.data,
    this.prop,
  });

  factory TransferChatResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransferChatResponseModelFromJson(json);
}

class TransferChatBaseModel {
  final bool success;
  final String? message;
  final TransferChatResponseModel? data;

  TransferChatBaseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory TransferChatBaseModel.fromJson(Map<String, dynamic> json) {
    return TransferChatBaseModel(
      success: json['status'] == 1,
      message: json['message'],
      data: json['data'] != null 
          ? TransferChatResponseModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

@JsonSerializable(createToJson: false)
class SendMessageResponseModel {
  final int? status;
  final String? message;
  final bool? data; 

  SendMessageResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseModelFromJson(json);
}

class SendMessageBaseModel {
  final bool success;
  final String? message;
  final bool dataResponse;

  SendMessageBaseModel({
    required this.success,
    this.message,
    required this.dataResponse,
  });

  factory SendMessageBaseModel.fromJson(Map<String, dynamic> json) {
    return SendMessageBaseModel(
      success: json['status'] == 1,
      message: json['message'],
      dataResponse: json['data'] == true,
    );
  }
}

@JsonSerializable(createToJson: false)
class UpdateChatStatusResponseModel extends BaseResponseModel {
  final dynamic data; 

  UpdateChatStatusResponseModel({
    required super.success,
    required super.message,
    required super.code,
    required this.data,
  });

  factory UpdateChatStatusResponseModel.fromJson(Map<String, dynamic> json) {
    final base = BaseResponseModel.fromMap(json);
    json['success'] = base.success; 
    json['message'] = base.message;
    json['code'] = base.code;
    return _$UpdateChatStatusResponseModelFromJson(json);
  }
}

class UpdateChatStatusBaseModel {
  final bool success;
  final String? message;
  final UpdateChatStatusResponseModel? data;

  UpdateChatStatusBaseModel({
    required this.success,
    this.message,
    this.data,
  });
}

@JsonSerializable()
class UpdateChatStatusRequestModel {
  final String? chatStatus;
  final String? companyId;
  final String? currentAgentId;
  final String? phoneNumber;
  final String? conversationId;

  UpdateChatStatusRequestModel({
    this.chatStatus,
    this.companyId,
    this.currentAgentId,
    this.phoneNumber,
    this.conversationId,
  });

  factory UpdateChatStatusRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateChatStatusRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateChatStatusRequestModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UploadDocumentApiModel {
  final int? totalRequested;
  final int? totalSuccess;
  final int? totalFailed;
  final List<UploadResultData>? results;

  UploadDocumentApiModel({
    this.totalRequested,
    this.totalSuccess,
    this.totalFailed,
    this.results,
  });

  factory UploadDocumentApiModel.fromJson(Map<String, dynamic> json) =>
      _$UploadDocumentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UploadDocumentApiModelToJson(this);
}

@JsonSerializable()
class UploadResultData {
  final String? originalFileName;
  final bool? success;
  final String? fileId;
  final String? filePath;
  final String? errorMessage;

  UploadResultData({
    this.originalFileName,
    this.success,
    this.fileId,
    this.filePath,
    this.errorMessage,
  });

  factory UploadResultData.fromJson(Map<String, dynamic> json) =>
      _$UploadResultDataFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResultDataToJson(this);
}