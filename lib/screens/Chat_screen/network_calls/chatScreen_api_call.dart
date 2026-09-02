// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'dart:io';
// import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
// import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
// import 'package:berrytalks/Widgets_Component/Utils/MediaAttachmentPolicy.dart';
// import 'package:berrytalks/network/ApiService.dart';
// import 'package:berrytalks/services/storage/SharedPrefrences.dart';
// import 'package:dio/dio.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:retrofit/retrofit.dart';
// import '../../../../../network/ApiClient.dart';


// class ChatDetailsApiCall {
//   //========================== FETCH CHAT LIST==================================
//   Future<ChatDetailsApiModel?> fetchChatDetails({
//     required String number,
//     required String companyPublicId,
//     required String agentId,
//     required String channelId,
//     int page = 0,
//   }) async {
//     final token = await SharedPrefData.getAccessToken();
//     final apiService = ApiClient().apiService;

//     try {
//       final api = await apiService.getChatDetails(
//         "$token",
//         number,
//         companyPublicId,
//         agentId,
//         channelId,
//         page,
//       );

//       AppUtilities.appLogging(
//         type: LoggingType.info,
//         message: "CHAT DETAILS RESPONSE =====>>> ${api.response.data}",
//         stackTrace: null,
//       );

//       if (api.response.statusCode == 200) {
//         final responseMap = api.response.data as Map<String, dynamic>;
//         return ChatDetailsApiModel.fromJson(responseMap);
//       } else {
//         return ChatDetailsApiModel(
//           success: false,
//           message: "Failed to load chat details",
//           code: api.response.statusCode ?? 200,
//           data: null,
//         );
//       }
//     } on DioException catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return ChatDetailsApiModel(
//         success: false,
//         message: "Dio Exception: ${e.message}",
//         data: null,
//         code: 200,
//       );
//     } catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return ChatDetailsApiModel(
//         success: false,
//         message: "Something went wrong",
//         data: null,
//         code: 200,
//       );
//     }
//   }
// //======================= TRANSFER CHAT ===========================
//   Future<TransferChatBaseModel> transferChat({
//     required String assignAgentId,
//     required String channelId,
//     required String companyId,
//     required String currentAgentId,
//     required String phoneNumber,
//     String transferReason = "Chat Transfer",
//   }) async {
//     final token = await SharedPrefData.getAccessToken();
//     final apiService = ApiClient().apiService;

//     final Map<String, dynamic> body = {
//       "assignAgentId": assignAgentId,
//       "chanelId": channelId,
//       "companyId": companyId,
//       "currentAgentId": currentAgentId,
//       "phoneNumber": phoneNumber,
//       "transferReason": transferReason,
//     };

//     try {
//       final api = await apiService.transferChat("$token", body);

//       AppUtilities.appLogging(
//         type: LoggingType.info,
//         message: "TRANSFER CHAT RESPONSE =====>>> ${api.response.data}",
//         stackTrace: null,
//       );

//       if (api.response.statusCode == 200 && api.response.data != null) {
//         final responseMap = api.response.data as Map<String, dynamic>;
//         return TransferChatBaseModel.fromJson(responseMap);
//       } else {
//         return TransferChatBaseModel(
//           success: false,
//           message: "Failed to transfer chat from server",
//         );
//       }
//     } on DioException catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return TransferChatBaseModel(
//         success: false,
//         message: "Dio Exception: ${e.message}",
//       );
//     } catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return TransferChatBaseModel(
//         success: false,
//         message: "Something went wrong: $e",
//       );
//     }
//   }

// //======================= TEAM CONTACT LIST=====================================
//   Future<TeamContactApiModel?> fetchTeamContactList({required int page}) async {
//     final token = await SharedPrefData.getAccessToken();
//     final apiService = ApiClient().apiService;

//     try {
//       final api = await apiService.getTeamContactList("$token", page);

//       AppUtilities.appLogging(
//         type: LoggingType.info,
//         message: "CHAT CONTACT LIST RESPONSE =====>>> ${api.response.data}",
//         stackTrace: null,
//       );

//       if (api.response.statusCode == 200) {
//         return TeamContactApiModel.fromJson(api.response.data);
//       } else {
//         return TeamContactApiModel(
//           success: false,
//           message: "Failed to load contacts",
//           code: api.response.statusCode,
//           data: null,
//         );
//       }
//     } on DioException catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return TeamContactApiModel(
//         success: false,
//         message: "Dio Exception",
//         data: null,
//         code: e.response?.statusCode ?? 400,
//       );
//     } catch (e, stacktrace) {
//       AppUtilities.appLogging(
//         type: LoggingType.error,
//         message: e.toString(),
//         stackTrace: stacktrace,
//       );
//       return TeamContactApiModel(
//         success: false,
//         message: "Something went wrong",
//         data: null,
//         code: 500,
//       );
//     }
//   }

// //============================ UPDATE CHAT STATUS ============================
//   Future<UpdateChatStatusBaseModel> updateChatStatus({
//   required String chatStatus,
//   required String companyId,
//   required String currentAgentId,
//   required String phoneNumber,
//   required String conversationId,
// }) async {
//   final token = await SharedPrefData.getAccessToken();
//   final apiService = ApiClient().apiService;

//   final requestItem = UpdateChatStatusRequestModel(
//     chatStatus: chatStatus,
//     companyId: companyId,
//     currentAgentId: currentAgentId,
//     phoneNumber: phoneNumber,
//     conversationId: conversationId,
//   );

//   final List<UpdateChatStatusRequestModel> body = [requestItem];

//   try {
//     print("[API] Calling updateChatStatus for conversationId: $conversationId");

//     final responseModel = await apiService.updateChatStatus(body);

//     AppUtilities.appLogging(
//       type: LoggingType.info,
//       message: "UPDATE CHAT STATUS SUCCESS: ${responseModel.message}", 
//       stackTrace: null,
//     );

//     return UpdateChatStatusBaseModel(
//       success: responseModel.success, 
//       message: responseModel.message,
//       data: responseModel,
//     );
//   } on DioException catch (e, stacktrace) {
//     AppUtilities.appLogging(
//       type: LoggingType.error,
//       message: e.toString(),
//       stackTrace: stacktrace,
//     );
//     return UpdateChatStatusBaseModel(
//       success: false,
//       message: "Dio Exception: ${e.message}",
//       data: null,
//     );
//   } catch (e, stacktrace) {
//     AppUtilities.appLogging(
//       type: LoggingType.error,
//       message: e.toString(),
//       stackTrace: stacktrace,
//     );
//     return UpdateChatStatusBaseModel(
//       success: false,
//       message: "Something went wrong: $e",
//       data: null,
//     );
//   }
// }


// //============================== UPLOAD DOCUMENT ===============================
// Future<UploadDocumentApiModel?> uploadChatDocument({
//   required String filePath,
//   required String agentPublicId,
//   required String companyId,
//   String channelId = '',
//   String mediaStream = '',
// }) async {
//   final String? tokenNullable = await SharedPrefData.getAccessToken();
//   final String token = tokenNullable ?? '';
//   final apiService = ApiClient().apiService;

//   try {
//     final file = File(filePath);
//     if (!await file.exists()) {
//       developer.log('UPLOAD_FILE: file missing at $filePath');
//       return UploadDocumentApiModel(
//         totalRequested: 1,
//         totalSuccess: 0,
//         totalFailed: 1,
//         results: [
//           UploadResultData(
//             success: false,
//             errorMessage: 'File not found on device.',
//           ),
//         ],
//       );
//     }

//     // Safety net — primary check is in ChatBloc before optimistic UI.
//     final String stream = mediaStream.isNotEmpty
//         ? mediaStream
//         : _inferStreamFromPath(filePath);
//     final policyError = await MediaAttachmentPolicy.validateBeforeUpload(
//       file: file,
//       channelId: channelId,
//       stream: stream,
//     );
//     if (policyError != null) {
//       developer.log('UPLOAD blocked by policy: $policyError');
//       return UploadDocumentApiModel(
//         totalRequested: 1,
//         totalSuccess: 0,
//         totalFailed: 1,
//         results: [
//           UploadResultData(
//             success: false,
//             errorMessage: policyError,
//           ),
//         ],
//       );
//     }

//     final int fileSize = await file.length();
//     final MediaType? contentType = _contentTypeForPath(filePath);
//     developer.log(
//       'UPLOAD_FILE: path=$filePath size=$fileSize '
//       'contentType=${contentType?.mimeType} channel=$channelId stream=$stream',
//     );

//     final String uniqueFileName = _uniqueUploadFileName(filePath);

//     // Read bytes + explicit part Content-Type so backend/Meta don't see
//     // application/octet-stream (common cause of WhatsApp media failure).
//     final MultipartFile fileToUpload = MultipartFile.fromBytes(
//       await file.readAsBytes(),
//       filename: uniqueFileName,
//       contentType: contentType,
//     );

//     developer.log(
//       'Uploading: $uniqueFileName | Agent: $agentPublicId | Company: $companyId',
//     );

//     final api = await apiService.uploadDocument(
//       token.startsWith('Bearer ') ? token : 'Bearer $token',
//       'application/json, text/plain, */*',
//       agentPublicId,
//       companyId,
//       [fileToUpload],
//     );

//     developer.log('Upload raw response: ${api.response.data}');
//     return _parseUploadResponse(api.response.data);
//   } on DioException catch (e) {
//     developer.log("Upload Dio error status: ${e.response?.statusCode}");
//     developer.log("Upload Dio error data: ${e.response?.data}");

//     if (e.response?.data != null) {
//       try {
//         final responseData = e.response!.data;
//         final Map<String, dynamic> responseMap =
//             Map<String, dynamic>.from(responseData as Map);
//         final model = UploadDocumentApiModel.fromJson(responseMap);

//         if (model.results != null && model.results!.isNotEmpty) {
//           final result = model.results!.first;

//           if (result.errorMessage != null &&
//               result.errorMessage!.toLowerCase().contains("already exists")) {
            
//             developer.log("File already exists - retrying with unique name");
            
//             return _retryUploadWithUniqueName(
//               filePath: filePath,
//               agentPublicId: agentPublicId,
//               companyId: companyId,
//               token: token, 
//               apiService: apiService,
//             );
//           }
//         }
//       } catch (parseError) {
//         developer.log("Parse error: $parseError");
//       }
//     }
//     return null;
//   } catch (e, stacktrace) {
//     developer.log("Upload error: $e", stackTrace: stacktrace);
//     return null;
//   }
// }

// //================== RETRYING UPLOAD WITH UNIQUE NAME/ID ========================
// Future<UploadDocumentApiModel?> _retryUploadWithUniqueName({
//   required String filePath,
//   required String agentPublicId,
//   required String companyId,
//   required String token,
//   required dynamic apiService,
// }) async {
//   try {
//     final String originalName = filePath.split('/').last;
//     final String extension = originalName.contains('.')
//         ? originalName.split('.').last
//         : 'jpg';
    
//     final String retryFileName = 
//         'file_${DateTime.now().millisecondsSinceEpoch}.$extension';

//     developer.log("Retrying with unique name: $retryFileName");

//     MultipartFile retryFile = await MultipartFile.fromFile(
//       filePath,
//       filename: retryFileName,
//       contentType: _contentTypeForPath(filePath),
//     );

//     final retryApi = await apiService.uploadDocument(
//       token.startsWith("Bearer ") ? token : "Bearer $token",
//       "application/json, text/plain, */*",
//       agentPublicId,
//       companyId,
//       [retryFile],
//     );

//     developer.log("Retry upload response: ${retryApi.response.data}");
//     return _parseUploadResponse(retryApi.response.data);

//   } catch (e) {
//     developer.log("Retry upload failed: $e");
//     return null;
//   }
// }


// //=========================== UPLOAD RESPONSE PARSE (CLEANED) ================================
// UploadDocumentApiModel? _parseUploadResponse(dynamic responseData) {
//   if (responseData == null) return null;

//   try {
//     final Map<String, dynamic> responseMap =
//         Map<String, dynamic>.from(responseData as Map);
    
//     return UploadDocumentApiModel.fromJson(responseMap);
//   } catch (e) {
//     developer.log("Parse error: $e");
//     return null;
//   }
// }

// /// MIME for multipart upload — WhatsApp rejects mismatched types (error 131053).
// /// See: https://developers.facebook.com/documentation/business-messaging/whatsapp/business-phone-numbers/media#supported-media-types
// MediaType? _contentTypeForPath(String filePath) {
//   final name = filePath.split('/').last.toLowerCase();
//   final ext = name.contains('.') ? name.split('.').last : '';
//   switch (ext) {
//     case 'mp4':
//       return MediaType('video', 'mp4');
//     case '3gp':
//     case '3gpp':
//       return MediaType('video', '3gpp');
//     case 'jpg':
//     case 'jpeg':
//       return MediaType('image', 'jpeg');
//     case 'png':
//       return MediaType('image', 'png');
//     case 'webp':
//       return MediaType('image', 'webp');
//     case 'ogg':
//     case 'opus':
//       return MediaType('audio', 'ogg');
//     case 'mp3':
//       return MediaType('audio', 'mpeg');
//     case 'm4a':
//       return MediaType('audio', 'mp4');
//     case 'aac':
//       return MediaType('audio', 'aac');
//     case 'amr':
//       return MediaType('audio', 'amr');
//     case 'pdf':
//       return MediaType('application', 'pdf');
//     case 'txt':
//       return MediaType('text', 'plain');
//     default:
//       return null;
//   }
// }

// /// Clean upload filename: `{timestamp}.{ext}` (WhatsApp-friendly extension).
// String _uniqueUploadFileName(String filePath) {
//   final original = filePath.split('/').last;
//   final ext = original.contains('.')
//       ? original.split('.').last.toLowerCase()
//       : 'bin';
//   return '${DateTime.now().millisecondsSinceEpoch}.$ext';
// }

// String _inferStreamFromPath(String filePath) {
//   final lower = filePath.toLowerCase();
//   if (lower.endsWith('.jpg') ||
//       lower.endsWith('.jpeg') ||
//       lower.endsWith('.png') ||
//       lower.endsWith('.webp') ||
//       lower.endsWith('.gif')) {
//     return 'image';
//   }
//   if (lower.endsWith('.mp4') ||
//       lower.endsWith('.3gp') ||
//       lower.endsWith('.3gpp') ||
//       lower.endsWith('.mov') ||
//       lower.endsWith('.mkv') ||
//       lower.endsWith('.webm')) {
//     return 'video';
//   }
//   if (lower.endsWith('.mp3') ||
//       lower.endsWith('.m4a') ||
//       lower.endsWith('.ogg') ||
//       lower.endsWith('.aac') ||
//       lower.endsWith('.wav') ||
//       lower.endsWith('.amr')) {
//     return 'audio';
//   }
//   return 'document';
// }

// //=================== SEND MESSAGE ================================

// Future<SendMessageBaseModel> sendMessage({
//   required String type,
//   required String phoneNumber,
//   required String textBody,
//   required String recipientNumber,
//   required String chanelId,
//   required String name,
//   required String agentId,
//   required String conversationId,
//   String? fileId,
//   /// API stream key: `audio` | `image` | `video` | `document`
//   String? mediaStream, String? filePath,
// }) async {
//   final token = await SharedPrefData.getAccessToken();
//   final apiService = ApiClient().apiService;

//   final Map<String, dynamic> body;

//   // Same shape as Postman / portal:
//   // {"type":"media","stream":"video",...,"video":{"fileId":"..."}}
//   if (type == 'media' &&
//       fileId != null &&
//       fileId.isNotEmpty &&
//       mediaStream != null &&
//       mediaStream.isNotEmpty) {
//     final String stream = mediaStream.trim();
//     final String id = fileId.trim();
//     body = {
//       'type': 'media',
//       'stream': stream,
//       'phoneNumber': phoneNumber,
//       'textBody': textBody,
//       'recipientNumber': recipientNumber,
//       'chanelId': chanelId,
//       'name': name,
//       'agentId': agentId,
//       'conversationId': conversationId,
//       stream: <String, dynamic>{'fileId': id},
//     };
//   } else {
//     body = {
//       'type': 'text',
//       'phoneNumber': phoneNumber,
//       'textBody': textBody,
//       'recipientNumber': recipientNumber,
//       'chanelId': chanelId,
//       'name': name,
//       'agentId': agentId,
//       'conversationId': conversationId,
//     };
//   }

//   final encoded = jsonEncode(body);
//   developer.log('====== SEND MESSAGE BODY (JSON) ======');
//   developer.log(encoded);
//   developer.log('======================================');

//   try {
//     final authHeader =
//         (token ?? '').startsWith('Bearer ') ? token! : 'Bearer ${token ?? ''}';
//     final responseModel = await apiService.sendMessage(authHeader, body);

//     return SendMessageBaseModel(
//       success: responseModel.status == 1,
//       message: responseModel.message,
//       dataResponse: responseModel.data == true,
//     );
//   } on DioException catch (e, stacktrace) {
//     developer.log('Send message Dio error: ${e.response?.data}');
//     AppUtilities.appLogging(
//       type: LoggingType.error,
//       message: e.toString(),
//       stackTrace: stacktrace,
//     );
//     return SendMessageBaseModel(
//       success: false,
//       message: 'Dio Exception: ${e.message}',
//       dataResponse: false,
//     );
//   } catch (e, stacktrace) {
//     AppUtilities.appLogging(
//       type: LoggingType.error,
//       message: e.toString(),
//       stackTrace: stacktrace,
//     );
//     return SendMessageBaseModel(
//       success: false,
//       message: 'Something went wrong: $e',
//       dataResponse: false,
//     );
//   }
// }

// }



import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaAttachmentPolicy.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../../network/ApiClient.dart';


class ChatDetailsApiCall {
  //========================== FETCH CHAT LIST==================================
  Future<ChatDetailsApiModel?> fetchChatDetails({
    required String number,
    required String companyPublicId,
    required String agentId,
    required String channelId,
    int page = 0,
  }) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.getChatDetails(
        "$token",
        number,
        companyPublicId,
        agentId,
        channelId,
        page,
      );

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "CHAT DETAILS RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200) {
        final responseMap = api.response.data as Map<String, dynamic>;
        return ChatDetailsApiModel.fromJson(responseMap);
      } else {
        return ChatDetailsApiModel(
          success: false,
          message: "Failed to load chat details",
          code: api.response.statusCode ?? 200,
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return ChatDetailsApiModel(
        success: false,
        message: "Dio Exception: ${e.message}",
        data: null,
        code: 200,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return ChatDetailsApiModel(
        success: false,
        message: "Something went wrong",
        data: null,
        code: 200,
      );
    }
  }
//======================= TRANSFER CHAT ===========================
  Future<TransferChatBaseModel> transferChat({
    required String assignAgentId,
    required String channelId,
    required String companyId,
    required String currentAgentId,
    required String phoneNumber,
    String transferReason = "Chat Transfer",
  }) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    final Map<String, dynamic> body = {
      "assignAgentId": assignAgentId,
      "chanelId": channelId,
      "companyId": companyId,
      "currentAgentId": currentAgentId,
      "phoneNumber": phoneNumber,
      "transferReason": transferReason,
    };

    try {
      final api = await apiService.transferChat("$token", body);

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "TRANSFER CHAT RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200 && api.response.data != null) {
        final responseMap = api.response.data as Map<String, dynamic>;
        return TransferChatBaseModel.fromJson(responseMap);
      } else {
        return TransferChatBaseModel(
          success: false,
          message: "Failed to transfer chat from server",
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TransferChatBaseModel(
        success: false,
        message: "Dio Exception: ${e.message}",
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TransferChatBaseModel(
        success: false,
        message: "Something went wrong: $e",
      );
    }
  }

//======================= TEAM CONTACT LIST=====================================
  Future<TeamContactApiModel?> fetchTeamContactList({required int page}) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.getTeamContactList("$token", page);

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "CHAT CONTACT LIST RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200) {
        return TeamContactApiModel.fromJson(api.response.data);
      } else {
        return TeamContactApiModel(
          success: false,
          message: "Failed to load contacts",
          code: api.response.statusCode,
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamContactApiModel(
        success: false,
        message: "Dio Exception",
        data: null,
        code: e.response?.statusCode ?? 400,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamContactApiModel(
        success: false,
        message: "Something went wrong",
        data: null,
        code: 500,
      );
    }
  }

//============================ UPDATE CHAT STATUS ============================
  Future<UpdateChatStatusBaseModel> updateChatStatus({
  required String chatStatus,
  required String companyId,
  required String currentAgentId,
  required String phoneNumber,
  required String conversationId,
}) async {
  final token = await SharedPrefData.getAccessToken();
  final apiService = ApiClient().apiService;

  final requestItem = UpdateChatStatusRequestModel(
    chatStatus: chatStatus,
    companyId: companyId,
    currentAgentId: currentAgentId,
    phoneNumber: phoneNumber,
    conversationId: conversationId,
  );

  final List<UpdateChatStatusRequestModel> body = [requestItem];

  try {
    print("[API] Calling updateChatStatus for conversationId: $conversationId");

    final responseModel = await apiService.updateChatStatus(body);

    AppUtilities.appLogging(
      type: LoggingType.info,
      message: "UPDATE CHAT STATUS SUCCESS: ${responseModel.message}", 
      stackTrace: null,
    );

    return UpdateChatStatusBaseModel(
      success: responseModel.success, 
      message: responseModel.message,
      data: responseModel,
    );
  } on DioException catch (e, stacktrace) {
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: e.toString(),
      stackTrace: stacktrace,
    );
    return UpdateChatStatusBaseModel(
      success: false,
      message: "Dio Exception: ${e.message}",
      data: null,
    );
  } catch (e, stacktrace) {
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: e.toString(),
      stackTrace: stacktrace,
    );
    return UpdateChatStatusBaseModel(
      success: false,
      message: "Something went wrong: $e",
      data: null,
    );
  }
}


//============================== UPLOAD DOCUMENT ===============================
Future<UploadDocumentApiModel?> uploadChatDocument({
  required String filePath,
  required String agentPublicId,
  required String companyId,
  String channelId = '',
  String mediaStream = '',
}) async {
  final String? tokenNullable = await SharedPrefData.getAccessToken();
  final String token = tokenNullable ?? '';
  final apiService = ApiClient().apiService;

  try {
    final file = File(filePath);
    if (!await file.exists()) {
      developer.log('UPLOAD_FILE: file missing at $filePath');
      return UploadDocumentApiModel(
        totalRequested: 1,
        totalSuccess: 0,
        totalFailed: 1,
        results: [
          UploadResultData(
            success: false,
            errorMessage: 'File not found on device.',
          ),
        ],
      );
    }

    // Safety net — primary check is in ChatBloc before optimistic UI.
    final String stream = mediaStream.isNotEmpty
        ? mediaStream
        : _inferStreamFromPath(filePath);
    final policyError = await MediaAttachmentPolicy.validateBeforeUpload(
      file: file,
      channelId: channelId,
      stream: stream,
    );
    if (policyError != null) {
      developer.log('UPLOAD blocked by policy: $policyError');
      return UploadDocumentApiModel(
        totalRequested: 1,
        totalSuccess: 0,
        totalFailed: 1,
        results: [
          UploadResultData(
            success: false,
            errorMessage: policyError,
          ),
        ],
      );
    }

    final int fileSize = await file.length();
    final MediaType? contentType = _contentTypeForPath(filePath);
    developer.log(
      'UPLOAD_FILE: path=$filePath size=$fileSize '
      'contentType=${contentType?.mimeType} channel=$channelId stream=$stream',
    );

    final String uniqueFileName = _uniqueUploadFileName(filePath);

    // Read bytes + explicit part Content-Type so backend/Meta don't see
    // application/octet-stream (common cause of WhatsApp media failure).
    final MultipartFile fileToUpload = MultipartFile.fromBytes(
      await file.readAsBytes(),
      filename: uniqueFileName,
      contentType: contentType,
    );

    developer.log(
      'Uploading: $uniqueFileName | Agent: $agentPublicId | Company: $companyId',
    );

    final api = await apiService.uploadDocument(
      token.startsWith('Bearer ') ? token : 'Bearer $token',
      'application/json, text/plain, */*',
      agentPublicId,
      companyId,
      [fileToUpload],
    );

    developer.log('Upload raw response: ${api.response.data}');
    return _parseUploadResponse(api.response.data);
  } on DioException catch (e) {
    developer.log("Upload Dio error status: ${e.response?.statusCode}");
    developer.log("Upload Dio error data: ${e.response?.data}");

    if (e.response?.data != null) {
      try {
        final responseData = e.response!.data;
        final Map<String, dynamic> responseMap =
            Map<String, dynamic>.from(responseData as Map);
        final model = UploadDocumentApiModel.fromJson(responseMap);

        if (model.results != null && model.results!.isNotEmpty) {
          final result = model.results!.first;

          if (result.errorMessage != null &&
              result.errorMessage!.toLowerCase().contains("already exists")) {
            
            developer.log("File already exists - retrying with unique name");
            
            return _retryUploadWithUniqueName(
              filePath: filePath,
              agentPublicId: agentPublicId,
              companyId: companyId,
              token: token, 
              apiService: apiService,
            );
          }
        }
      } catch (parseError) {
        developer.log("Parse error: $parseError");
      }
    }
    return null;
  } catch (e, stacktrace) {
    developer.log("Upload error: $e", stackTrace: stacktrace);
    return null;
  }
}

//================== RETRYING UPLOAD WITH UNIQUE NAME/ID ========================
Future<UploadDocumentApiModel?> _retryUploadWithUniqueName({
  required String filePath,
  required String agentPublicId,
  required String companyId,
  required String token,
  required dynamic apiService,
}) async {
  try {
    final String originalName = filePath.split('/').last;
    final String extension = originalName.contains('.')
        ? originalName.split('.').last
        : 'jpg';
    
    final String retryFileName = 
        'file_${DateTime.now().millisecondsSinceEpoch}.$extension';

    developer.log("Retrying with unique name: $retryFileName");

    MultipartFile retryFile = await MultipartFile.fromFile(
      filePath,
      filename: retryFileName,
      contentType: _contentTypeForPath(filePath),
    );

    final retryApi = await apiService.uploadDocument(
      token.startsWith("Bearer ") ? token : "Bearer $token",
      "application/json, text/plain, */*",
      agentPublicId,
      companyId,
      [retryFile],
    );

    developer.log("Retry upload response: ${retryApi.response.data}");
    return _parseUploadResponse(retryApi.response.data);

  } catch (e) {
    developer.log("Retry upload failed: $e");
    return null;
  }
}


//=========================== UPLOAD RESPONSE PARSE (CLEANED) ================================
UploadDocumentApiModel? _parseUploadResponse(dynamic responseData) {
  if (responseData == null) return null;

  try {
    final Map<String, dynamic> responseMap =
        Map<String, dynamic>.from(responseData as Map);
    
    return UploadDocumentApiModel.fromJson(responseMap);
  } catch (e) {
    developer.log("Parse error: $e");
    return null;
  }
}

/// MIME for multipart upload — WhatsApp rejects mismatched types (error 131053).
/// See: https://developers.facebook.com/documentation/business-messaging/whatsapp/business-phone-numbers/media#supported-media-types
MediaType? _contentTypeForPath(String filePath) {
  final name = filePath.split('/').last.toLowerCase();
  final ext = name.contains('.') ? name.split('.').last : '';
  switch (ext) {
    case 'mp4':
      return MediaType('video', 'mp4');
    case '3gp':
    case '3gpp':
      return MediaType('video', '3gpp');
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'webp':
      return MediaType('image', 'webp');
    case 'ogg':
    case 'opus':
      return MediaType('audio', 'ogg');
    case 'mp3':
      return MediaType('audio', 'mpeg');
    case 'm4a':
      return MediaType('audio', 'mp4');
    case 'aac':
      return MediaType('audio', 'aac');
    case 'amr':
      return MediaType('audio', 'amr');
    case 'pdf':
      return MediaType('application', 'pdf');
    case 'txt':
      return MediaType('text', 'plain');
    default:
      return null;
  }
}

/// Clean upload filename: `{timestamp}.{ext}` (WhatsApp-friendly extension).
String _uniqueUploadFileName(String filePath) {
  final original = filePath.split('/').last;
  final ext = original.contains('.')
      ? original.split('.').last.toLowerCase()
      : 'bin';
  return '${DateTime.now().millisecondsSinceEpoch}.$ext';
}

String _inferStreamFromPath(String filePath) {
  final lower = filePath.toLowerCase();
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif')) {
    return 'image';
  }
  if (lower.endsWith('.mp4') ||
      lower.endsWith('.3gp') ||
      lower.endsWith('.3gpp') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm')) {
    return 'video';
  }
  if (lower.endsWith('.mp3') ||
      lower.endsWith('.m4a') ||
      lower.endsWith('.ogg') ||
      lower.endsWith('.aac') ||
      lower.endsWith('.wav') ||
      lower.endsWith('.amr')) {
    return 'audio';
  }
  return 'document';
}

//=================== SEND MESSAGE ================================

Future<SendMessageBaseModel> sendMessage({
  required String type,
  required String phoneNumber,
  required String textBody,
  required String recipientNumber,
  required String chanelId,
  required String name,
  required String agentId,
  required String conversationId,
  String? fileId,
  /// API stream key: `audio` | `image` | `video` | `document`
  String? mediaStream,
}) async {
  final token = await SharedPrefData.getAccessToken();
  final apiService = ApiClient().apiService;

  final Map<String, dynamic> body;

  // Same shape as Postman / portal:
  // {"type":"media","stream":"video",...,"video":{"fileId":"..."}}
  if (type == 'media' &&
      fileId != null &&
      fileId.isNotEmpty &&
      mediaStream != null &&
      mediaStream.isNotEmpty) {
    final String stream = mediaStream.trim();
    final String id = fileId.trim();
    body = {
      'type': 'media',
      'stream': stream,
      'phoneNumber': phoneNumber,
      'textBody': textBody,
      'recipientNumber': recipientNumber,
      'chanelId': chanelId,
      'name': name,
      'agentId': agentId,
      'conversationId': conversationId,
      stream: <String, dynamic>{'fileId': id},
    };
  } else {
    body = {
      'type': 'text',
      'phoneNumber': phoneNumber,
      'textBody': textBody,
      'recipientNumber': recipientNumber,
      'chanelId': chanelId,
      'name': name,
      'agentId': agentId,
      'conversationId': conversationId,
    };
  }

  final encoded = jsonEncode(body);
  developer.log('====== SEND MESSAGE BODY (JSON) ======');
  developer.log(encoded);
  developer.log('======================================');

  try {
    final authHeader =
        (token ?? '').startsWith('Bearer ') ? token! : 'Bearer ${token ?? ''}';
    final responseModel = await apiService.sendMessage(authHeader, body);

    return SendMessageBaseModel(
      success: responseModel.status == 1,
      message: responseModel.message,
      dataResponse: responseModel.data == true,
    );
  } on DioException catch (e, stacktrace) {
    developer.log('Send message Dio error: ${e.response?.data}');
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: e.toString(),
      stackTrace: stacktrace,
    );
    return SendMessageBaseModel(
      success: false,
      message: 'Dio Exception: ${e.message}',
      dataResponse: false,
    );
  } catch (e, stacktrace) {
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: e.toString(),
      stackTrace: stacktrace,
    );
    return SendMessageBaseModel(
      success: false,
      message: 'Something went wrong: $e',
      dataResponse: false,
    );
  }
}

}
