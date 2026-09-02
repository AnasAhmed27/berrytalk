import 'dart:io';

import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiClient.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:dio/dio.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';

class TeamChatApiCall {
  Future<TeamChatDetailsApiModel?> fetchTeamChatDetails({
    required String recipientAgentId,
    int page = 0,
    int size = 20,
  }) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final apiModel = await apiService.getTeamChatDetails(
        token: "Bearer $token",
        recipientAgentId: recipientAgentId,
        page: page,
        size: size,
      );

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "TEAM CHAT DETAILS RESPONSE =====>>> ${apiModel?.toJson()}",
        stackTrace: null,
      );

      if (apiModel != null &&
          (apiModel.status == 200 || apiModel.status == 1)) {
        return apiModel;
      } else {
        return TeamChatDetailsApiModel(
          status: apiModel?.status ?? 400,
          message: apiModel?.message ?? "Failed to load team chat details",
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );

      return TeamChatDetailsApiModel(
        status: e.response?.statusCode ?? 400,
        message: "Dio Exception: ${e.message}",
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamChatDetailsApiModel(
        status: 500,
        message: "Something went wrong: $e",
        data: null,
      );
    }
  }

  Future<TeamSendMessageResponseModel?> sendTeamMessage({
    required String type,
    required String textBody,
    required String name,
    required String recipientAgentId,
    File? file,
  }) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    // final Map<String, dynamic> body = {
    //   "type": type,
    //   "textBody": textBody,
    //   "name": name,
    //   "recipientAgentId": recipientAgentId,
    // };
    dynamic requestBody;
    if (file != null) {
      String fileName = file.path.split('/').last;
      requestBody = FormData.fromMap({
        "type": type,
        "textBody": textBody,
        "name": name,
        "recipientAgentId": recipientAgentId,
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ), // <-- File attach ho gayi
      });
    } else {
      // Agar file nahi hai (simple text message hai), toh purana simple map chala jayega
      requestBody = {
        "type": type,
        "textBody": textBody,
        "name": name,
        "recipientAgentId": recipientAgentId,
      };
    }

    try {
      final authHeader = (token ?? '').startsWith('Bearer ')
          ? token!
          : 'Bearer ${token ?? ''}';

      final apiModel = await apiService.sendTeamMessage(
        authHeader,
        requestBody,
      );

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "SEND TEAM MESSAGE RESPONSE =====>>> ${apiModel.toJson()}",
        stackTrace: null,
      );

      if (apiModel.status == 200 ||
          apiModel.status == 201 ||
          apiModel.status == 1) {
        return apiModel;
      } else {
        return TeamSendMessageResponseModel(
          status: apiModel.status ?? 400,
          message: apiModel.message ?? "Failed to send message",
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamSendMessageResponseModel(
        status: e.response?.statusCode ?? 400,
        message: "Dio Exception: ${e.message}",
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamSendMessageResponseModel(
        status: 500,
        message: "Something went wrong: $e",
        data: null,
      );
    }
  }
}
