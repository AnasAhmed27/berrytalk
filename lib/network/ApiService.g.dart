// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiService.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  code: (json['code'] as num?)?.toInt(),
  data: json['data'] == null
      ? null
      : LoginModelData.fromJson(json['data'] as Map<String, dynamic>),
);

LoginModelData _$LoginModelDataFromJson(Map<String, dynamic> json) =>
    LoginModelData(
      token: json['token'] as String?,
      type: json['type'] as String?,
      accessToken: json['accessToken'] as String?,
      userDataResponses: json['userDataResponses'],
    );

Map<String, dynamic> _$LoginModelDataToJson(LoginModelData instance) =>
    <String, dynamic>{
      'token': instance.token,
      'type': instance.type,
      'accessToken': instance.accessToken,
      'userDataResponses': instance.userDataResponses,
    };

ChatContactApiModel _$ChatContactApiModelFromJson(Map<String, dynamic> json) =>
    ChatContactApiModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: (json['code'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ContactData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatContactApiModelToJson(
  ChatContactApiModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

ContactData _$ContactDataFromJson(Map<String, dynamic> json) => ContactData(
  id: json['id'] as String?,
  publicId: json['publicId'] as String?,
  companyPublicId: json['companyPublicId'] as String?,
  agentPublicId: json['agentPublicId'] as String?,
  customerName: json['customerName'] as String?,
  number: json['number'] as String?,
  lastMessage: json['lastMessage'] as String?,
  chanelId: json['chanelId'] as String?,
  timeStamp: json['timeStamp'] as String?,
  unReadCount: json['unReadCount'],
  status: json['status'] as String?,
  isResolved: json['isResolved'] as String?,
);

Map<String, dynamic> _$ContactDataToJson(ContactData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicId': instance.publicId,
      'companyPublicId': instance.companyPublicId,
      'agentPublicId': instance.agentPublicId,
      'customerName': instance.customerName,
      'number': instance.number,
      'lastMessage': instance.lastMessage,
      'chanelId': instance.chanelId,
      'timeStamp': instance.timeStamp,
      'unReadCount': instance.unReadCount,
      'status': instance.status,
      'isResolved': instance.isResolved,
    };

TeamContactApiModel _$TeamContactApiModelFromJson(Map<String, dynamic> json) =>
    TeamContactApiModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: (json['code'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TeamContactData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TeamContactData _$TeamContactDataFromJson(Map<String, dynamic> json) =>
    TeamContactData(
      publicId: json['publicId'] as String?,
      companyPublicId: json['companyPublicId'] as String?,
      status: json['status'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String?,
      profilePic: json['profilePic'] as String?,
      phoneNumberWork: json['phoneNumberWork'] as String?,
      senderAgentId: json['senderAgentId'] as String?,
      recipientAgentId: json['recipientAgentId'] as String?,
      agentId: json['agentId'] as String?,
      customerName: json['customerName'] as String?,
      lastMessage: json['lastMessage'] as String?,
      timestamp: json['timestamp'] as String?,
      recipientUnReadCount: (json['recipientUnReadCount'] as num?)?.toInt(),
      senderUnReadCount: (json['senderUnReadCount'] as num?)?.toInt(),
      conversationId: json['conversationId'] as String?,
    );

Map<String, dynamic> _$TeamContactDataToJson(TeamContactData instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'companyPublicId': instance.companyPublicId,
      'status': instance.status,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'profilePic': instance.profilePic,
      'phoneNumberWork': instance.phoneNumberWork,
      'senderAgentId': instance.senderAgentId,
      'recipientAgentId': instance.recipientAgentId,
      'agentId': instance.agentId,
      'customerName': instance.customerName,
      'lastMessage': instance.lastMessage,
      'timestamp': instance.timestamp,
      'recipientUnReadCount': instance.recipientUnReadCount,
      'senderUnReadCount': instance.senderUnReadCount,
      'conversationId': instance.conversationId,
    };

AgentProfileModel _$AgentProfileModelFromJson(Map<String, dynamic> json) =>
    AgentProfileModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : AgentProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

AgentProfileData _$AgentProfileDataFromJson(Map<String, dynamic> json) =>
    AgentProfileData(
      publicId: json['publicId'] as String?,
      companyPublicId: json['companyPublicId'] as String?,
      phoneNumberWork: json['phoneNumberWork'] as String?,
      status: json['status'] as String?,
      agentType: json['agentType'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AgentProfileDataToJson(AgentProfileData instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'companyPublicId': instance.companyPublicId,
      'phoneNumberWork': instance.phoneNumberWork,
      'status': instance.status,
      'agentType': instance.agentType,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'imageUrl': instance.imageUrl,
      'role': instance.role,
    };

StatusChangeResponseModel _$StatusChangeResponseModelFromJson(
  Map<String, dynamic> json,
) => StatusChangeResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  code: (json['code'] as num?)?.toInt(),
  data: json['data'],
);

ChatDetailsApiModel _$ChatDetailsApiModelFromJson(Map<String, dynamic> json) =>
    ChatDetailsApiModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : ChatData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatDetailsApiModelToJson(
  ChatDetailsApiModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'code': instance.code,
  'data': instance.data?.toJson(),
};

ChatData _$ChatDataFromJson(Map<String, dynamic> json) => ChatData(
  conversation: json['conversation'] == null
      ? null
      : ConversationData.fromJson(json['conversation'] as Map<String, dynamic>),
  contact: json['contact'] == null
      ? null
      : ChatContactData.fromJson(json['contact'] as Map<String, dynamic>),
  inboxes: (json['inboxes'] as List<dynamic>?)
      ?.map((e) => InboxMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatDataToJson(ChatData instance) => <String, dynamic>{
  'conversation': instance.conversation?.toJson(),
  'contact': instance.contact?.toJson(),
  'inboxes': instance.inboxes?.map((e) => e.toJson()).toList(),
};

ConversationData _$ConversationDataFromJson(Map<String, dynamic> json) =>
    ConversationData(
      id: json['id'] as String?,
      companyPublicId: json['companyPublicId'] as String?,
      chanelId: json['chanelId'] as String?,
      number: json['number'] as String?,
      status: json['status'] as String?,
      agent: json['agent'] as String?,
      isAgentAssign: json['isAgentAssign'],
      isResolved: json['isResolved'],
      timeStamp: json['timeStamp'] as String?,
      customerPublicId: json['customerPublicId'] as String?,
      publicId: json['publicId'] as String?,
      entryPointId: json['entryPointId'] as String?,
      agentId: json['agentId'] as String?,
      agentName: json['agentName'] as String?,
      customerName: json['customerName'] as String?,
      isExpired: json['isExpired'] as bool?,
      expiration: json['expiration'] as String?,
    );

Map<String, dynamic> _$ConversationDataToJson(ConversationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyPublicId': instance.companyPublicId,
      'chanelId': instance.chanelId,
      'number': instance.number,
      'status': instance.status,
      'agent': instance.agent,
      'isAgentAssign': instance.isAgentAssign,
      'isResolved': instance.isResolved,
      'timeStamp': instance.timeStamp,
      'customerPublicId': instance.customerPublicId,
      'publicId': instance.publicId,
      'entryPointId': instance.entryPointId,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'customerName': instance.customerName,
      'isExpired': instance.isExpired,
      'expiration': instance.expiration,
    };

InboxMessage _$InboxMessageFromJson(Map<String, dynamic> json) => InboxMessage(
  id: json['id'] as String?,
  messageId: json['messageId'] as String?,
  messageType: json['messageType'] as String?,
  contactNumber: json['contactNumber'] as String?,
  body: json['body'] as String?,
  timestamp: json['timestamp'] as String?,
  contactName: json['contactName'] as String?,
  recipientNumber: json['recipientNumber'] as String?,
  conversationId: json['conversationId'],
  isSent: json['isSent'],
  messageStatus: json['messageStatus'] as String?,
  filePath: json['filePath'] as String?,
  caption: json['caption'] as String?,
);

Map<String, dynamic> _$InboxMessageToJson(InboxMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'messageType': instance.messageType,
      'contactNumber': instance.contactNumber,
      'body': instance.body,
      'timestamp': instance.timestamp,
      'contactName': instance.contactName,
      'recipientNumber': instance.recipientNumber,
      'conversationId': instance.conversationId,
      'isSent': instance.isSent,
      'messageStatus': instance.messageStatus,
      'filePath': instance.filePath,
      'caption': instance.caption,
    };

ChatContactData _$ChatContactDataFromJson(Map<String, dynamic> json) =>
    ChatContactData(
      id: (json['id'] as num?)?.toInt(),
      publicId: json['publicId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      gender: json['gender'] as String?,
      channelId: json['channelId'] as String?,
      contactTags: (json['contactTags'] as List<dynamic>?)
          ?.map((e) => ChatContactTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool?,
      currentChatStatus: json['currentChatStatus'] as String?,
    );

Map<String, dynamic> _$ChatContactDataToJson(ChatContactData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicId': instance.publicId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'mobileNumber': instance.mobileNumber,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'gender': instance.gender,
      'channelId': instance.channelId,
      'contactTags': instance.contactTags?.map((e) => e.toJson()).toList(),
      'isActive': instance.isActive,
      'currentChatStatus': instance.currentChatStatus,
    };

ChatContactTag _$ChatContactTagFromJson(Map<String, dynamic> json) =>
    ChatContactTag(
      id: (json['id'] as num?)?.toInt(),
      tagName: json['tagName'] as String?,
      tagPrefix: json['tagPrefix'] as String?,
      companyPublicId: json['companyPublicId'] as String?,
      isDeleted: json['isDeleted'] as bool?,
    );

Map<String, dynamic> _$ChatContactTagToJson(ChatContactTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tagName': instance.tagName,
      'tagPrefix': instance.tagPrefix,
      'companyPublicId': instance.companyPublicId,
      'isDeleted': instance.isDeleted,
    };

TransferChatResponseModel _$TransferChatResponseModelFromJson(
  Map<String, dynamic> json,
) => TransferChatResponseModel(
  status: (json['status'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'],
  prop: json['prop'] as String?,
);

SendMessageResponseModel _$SendMessageResponseModelFromJson(
  Map<String, dynamic> json,
) => SendMessageResponseModel(
  status: (json['status'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] as bool?,
);

UpdateChatStatusResponseModel _$UpdateChatStatusResponseModelFromJson(
  Map<String, dynamic> json,
) => UpdateChatStatusResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  code: (json['code'] as num?)?.toInt(),
  data: json['data'],
);

UpdateChatStatusRequestModel _$UpdateChatStatusRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateChatStatusRequestModel(
  chatStatus: json['chatStatus'] as String?,
  companyId: json['companyId'] as String?,
  currentAgentId: json['currentAgentId'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  conversationId: json['conversationId'] as String?,
);

Map<String, dynamic> _$UpdateChatStatusRequestModelToJson(
  UpdateChatStatusRequestModel instance,
) => <String, dynamic>{
  'chatStatus': instance.chatStatus,
  'companyId': instance.companyId,
  'currentAgentId': instance.currentAgentId,
  'phoneNumber': instance.phoneNumber,
  'conversationId': instance.conversationId,
};

UploadDocumentApiModel _$UploadDocumentApiModelFromJson(
  Map<String, dynamic> json,
) => UploadDocumentApiModel(
  totalRequested: (json['totalRequested'] as num?)?.toInt(),
  totalSuccess: (json['totalSuccess'] as num?)?.toInt(),
  totalFailed: (json['totalFailed'] as num?)?.toInt(),
  results: (json['results'] as List<dynamic>?)
      ?.map((e) => UploadResultData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UploadDocumentApiModelToJson(
  UploadDocumentApiModel instance,
) => <String, dynamic>{
  'totalRequested': instance.totalRequested,
  'totalSuccess': instance.totalSuccess,
  'totalFailed': instance.totalFailed,
  'results': instance.results?.map((e) => e.toJson()).toList(),
};

UploadResultData _$UploadResultDataFromJson(Map<String, dynamic> json) =>
    UploadResultData(
      originalFileName: json['originalFileName'] as String?,
      success: json['success'] as bool?,
      fileId: json['fileId'] as String?,
      filePath: json['filePath'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$UploadResultDataToJson(UploadResultData instance) =>
    <String, dynamic>{
      'originalFileName': instance.originalFileName,
      'success': instance.success,
      'fileId': instance.fileId,
      'filePath': instance.filePath,
      'errorMessage': instance.errorMessage,
    };

TeamChatDetailsApiModel _$TeamChatDetailsApiModelFromJson(
  Map<String, dynamic> json,
) => TeamChatDetailsApiModel(
  status: (json['status'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : TeamChatData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TeamChatDetailsApiModelToJson(
  TeamChatDetailsApiModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': instance.data,
};

TeamChatData _$TeamChatDataFromJson(Map<String, dynamic> json) => TeamChatData(
  content: (json['content'] as List<dynamic>?)
      ?.map((e) => TeamMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalElements: (json['totalElements'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  last: json['last'] as bool?,
);

Map<String, dynamic> _$TeamChatDataToJson(TeamChatData instance) =>
    <String, dynamic>{
      'content': instance.content?.map((e) => e.toJson()).toList(),
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };

TeamMessage _$TeamMessageFromJson(Map<String, dynamic> json) => TeamMessage(
  id: json['id'] as String?,
  type: json['type'] as String?,
  textBody: json['textBody'] as String?,
  senderAgentId: json['senderAgentId'] as String?,
  recipientAgentId: json['recipientAgentId'] as String?,
  name: json['name'] as String?,
  timestamp: json['timestamp'] as String?,
  filePath: json['filePath'] as String?,
  messageStatus: json['messageStatus'],
);

Map<String, dynamic> _$TeamMessageToJson(TeamMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'textBody': instance.textBody,
      'senderAgentId': instance.senderAgentId,
      'recipientAgentId': instance.recipientAgentId,
      'name': instance.name,
      'timestamp': instance.timestamp,
      'filePath': instance.filePath,
      'messageStatus': instance.messageStatus,
    };

TeamSendMessageResponseModel _$TeamSendMessageResponseModelFromJson(
  Map<String, dynamic> json,
) => TeamSendMessageResponseModel(
  status: (json['status'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] as bool?,
);

Map<String, dynamic> _$TeamSendMessageResponseModelToJson(
  TeamSendMessageResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': instance.data,
};

TeamSendMessageRequest _$TeamSendMessageRequestFromJson(
  Map<String, dynamic> json,
) => TeamSendMessageRequest(
  type: json['type'] as String,
  textBody: json['textBody'] as String,
  name: json['name'] as String,
  recipientAgentId: json['recipientAgentId'] as String,
);

Map<String, dynamic> _$TeamSendMessageRequestToJson(
  TeamSendMessageRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'textBody': instance.textBody,
  'name': instance.name,
  'recipientAgentId': instance.recipientAgentId,
};

CompanyProfileApiModel _$CompanyProfileApiModelFromJson(
  Map<String, dynamic> json,
) => CompanyProfileApiModel(
  status: json['status'] as num?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CompanyProfileData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CompanyProfileApiModelToJson(
  CompanyProfileApiModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

CompanyProfileData _$CompanyProfileDataFromJson(Map<String, dynamic> json) =>
    CompanyProfileData(
      ccId: (json['ccId'] as num?)?.toInt(),
      publicId: json['publicId'] as String?,
      companyName: json['companyName'] as String?,
      businessNumber: json['businessNumber'] as String?,
      email: json['email'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      industry: json['industry'] as String?,
      type: json['type'] as String?,
      domain: json['domain'] as String?,
      isVerified: json['isVerified'] as bool?,
      activeApps: (json['activeApps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CompanyProfileDataToJson(CompanyProfileData instance) =>
    <String, dynamic>{
      'ccId': instance.ccId,
      'publicId': instance.publicId,
      'companyName': instance.companyName,
      'businessNumber': instance.businessNumber,
      'email': instance.email,
      'whatsappNumber': instance.whatsappNumber,
      'industry': instance.industry,
      'type': instance.type,
      'domain': instance.domain,
      'isVerified': instance.isVerified,
      'activeApps': instance.activeApps,
    };

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://qaomni.convexinteractive.com/api';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<LoginModel>> login(
    String token,
    Map<String, dynamic> map,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(map);
    final _options = _setStreamType<HttpResponse<LoginModel>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/auth/client/login',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late LoginModel _value;
    try {
      _value = LoginModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getUserPermissions(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<dynamic>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/auth/user-permission',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ChatContactApiModel>> getChatContactList(
    String token,
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ChatContactApiModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/chat/contactList/ALL',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ChatContactApiModel _value;
    try {
      _value = ChatContactApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<TeamContactApiModel>> getTeamContactList(
    String token,
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<TeamContactApiModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/agent/list/AGENT',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TeamContactApiModel _value;
    try {
      _value = TeamContactApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<TeamContactApiModel>> getInternalChatDetails(
    String token,
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<TeamContactApiModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/internal-chat/details',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TeamContactApiModel _value;
    try {
      _value = TeamContactApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<AgentProfileModel>> getAgentProfile(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<AgentProfileModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/agent/profile',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AgentProfileModel _value;
    try {
      _value = AgentProfileModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> getChatDetails(
    String token,
    String number,
    String companyPublicId,
    String agentId,
    String channelId,
    int page,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<dynamic>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/chat/details/${number}/${companyPublicId}/${agentId}/${channelId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<TeamChatDetailsApiModel?> getTeamChatDetails({
    required String token,
    required String recipientAgentId,
    int page = 0,
    int size = 20,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page, r'size': size};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<TeamChatDetailsApiModel?>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/internal-chat/details/${recipientAgentId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>?>(_options);
    late TeamChatDetailsApiModel? _value;
    try {
      _value = _result.data == null
          ? null
          : TeamChatDetailsApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<HttpResponse<CompanyProfileApiModel>> getCompanyProfile(
    String token,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<CompanyProfileApiModel>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/company/get',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CompanyProfileApiModel _value;
    try {
      _value = CompanyProfileApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<TransferChatResponseModel>> transferChat(
    String token,
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<HttpResponse<TransferChatResponseModel>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/chat/transfer-chat',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TransferChatResponseModel _value;
    try {
      _value = TransferChatResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<TeamSendMessageResponseModel> sendTeamMessage(
    String token,
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<TeamSendMessageResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/internal-chat/send',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TeamSendMessageResponseModel _value;
    try {
      _value = TeamSendMessageResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SendMessageResponseModel> sendMessage(
    String token,
    Map<String, dynamic> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body);
    final _options = _setStreamType<SendMessageResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/chat/send-message',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SendMessageResponseModel _value;
    try {
      _value = SendMessageResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<HttpResponse<StatusChangeResponseModel>> changeAgentStatus(
    String status,
    String publicId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<StatusChangeResponseModel>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/agent/changeStatus/${status}/${publicId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late StatusChangeResponseModel _value;
    try {
      _value = StatusChangeResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<UpdateChatStatusResponseModel> updateChatStatus(
    List<UpdateChatStatusRequestModel> body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = body.map((e) => e.toJson()).toList();
    final _options = _setStreamType<UpdateChatStatusResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/chat/update-chat-status',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UpdateChatStatusResponseModel _value;
    try {
      _value = UpdateChatStatusResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<HttpResponse<UploadDocumentApiModel>> uploadDocument(
    String token,
    String accept,
    String agentPublicId,
    String companyId,
    List<MultipartFile> files,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'agentPublicId': agentPublicId,
      r'companyId': companyId,
    };
    final _headers = <String, dynamic>{
      r'Authorization': token,
      r'Accept': accept,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = FormData();
    _data.files.addAll(files.map((i) => MapEntry('files', i)));
    final _options = _setStreamType<HttpResponse<UploadDocumentApiModel>>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/media/upload/bulk',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UploadDocumentApiModel _value;
    try {
      _value = UploadDocumentApiModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
