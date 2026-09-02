part of 'package:berrytalks/network/ApiService.dart';

@JsonSerializable()
class TeamChatDetailsApiModel {
  final int? status;
  final String? message;
  final TeamChatData? data;

  TeamChatDetailsApiModel({this.status, this.message, this.data});

  factory TeamChatDetailsApiModel.fromJson(Map<String, dynamic> json) =>
      _$TeamChatDetailsApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamChatDetailsApiModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TeamChatData {
  @JsonKey(name: 'content')
  final List<TeamMessage>? content;
  final int? totalElements;
  final int? totalPages;
  final bool? last;

  TeamChatData({this.content, this.totalElements, this.totalPages, this.last});

  factory TeamChatData.fromJson(Map<String, dynamic> json) =>
      _$TeamChatDataFromJson(json);

  Map<String, dynamic> toJson() => _$TeamChatDataToJson(this);
}

@JsonSerializable()
class TeamMessage {
  final String? id;
  final String? type;
  final String? textBody;
  final String? senderAgentId;
  final String? recipientAgentId;
  final String? name;
  final String? timestamp;
  final String? filePath;
  final dynamic messageStatus;

  TeamMessage({
    this.id,
    this.type,
    this.textBody,
    this.senderAgentId,
    this.recipientAgentId,
    this.name,
    this.timestamp,
    this.filePath,
    this.messageStatus,
  });

  factory TeamMessage.fromJson(Map<String, dynamic> json) =>
      _$TeamMessageFromJson(json);

  Map<String, dynamic> toJson() => _$TeamMessageToJson(this);

  TeamMessage copyWith({
    String? id,
    String? type,
    String? textBody,
    String? senderAgentId,
    String? recipientAgentId,
    String? name,
    String? timestamp,
    String? filePath,
    dynamic messageStatus,
  }) {
    return TeamMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      textBody: textBody ?? this.textBody,
      senderAgentId: senderAgentId ?? this.senderAgentId,
      recipientAgentId: recipientAgentId ?? this.recipientAgentId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      filePath: filePath ?? this.filePath,
      messageStatus: messageStatus ?? this.messageStatus,
    );
  }

  bool get isReadStatus {
    if (messageStatus is bool) return messageStatus == true;
    return messageStatus?.toString().toLowerCase() == 'true';
  }

  bool wasSentByMe(String currentAgentId) {
    return senderAgentId == currentAgentId;
  }

  String get formattedMessageTime {
    if (timestamp == null || timestamp!.isEmpty) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }

    try {
      int ts = int.parse(timestamp!);
      if (timestamp!.length == 10) {
        ts *= 1000;
      }
      final dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      print("Error parsing team message timestamp: $e");
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }
}

@JsonSerializable()
class TeamSendMessageResponseModel {
  final int? status;
  final String? message;
  final bool? data;

  TeamSendMessageResponseModel({this.status, this.message, this.data});

  factory TeamSendMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TeamSendMessageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamSendMessageResponseModelToJson(this);
}

@JsonSerializable()
class TeamSendMessageRequest {
  final String type;
  final String textBody;
  final String name;
  final String recipientAgentId;

  TeamSendMessageRequest({
    required this.type,
    required this.textBody,
    required this.name,
    required this.recipientAgentId,
  });

  factory TeamSendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$TeamSendMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TeamSendMessageRequestToJson(this);
}
