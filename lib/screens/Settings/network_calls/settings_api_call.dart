import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import '../../../../../network/ApiClient.dart'; 

class AgentProfileApiCall {
  Future<AgentProfileModel?> fetchAgentProfile() async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.getAgentProfile("$token");

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "AGENT PROFILE RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200) {
        return api.data;
      } else {
        return AgentProfileModel(
          success: false,
          message: "Failed to load profile",
          code: api.response.statusCode ?? 500,
          data: null, 
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return AgentProfileModel(
        success: false,
        message: "Dio Exception: ${e.message}",
        code: e.response?.statusCode ?? 400,
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return AgentProfileModel(
        success: false,
        message: "Something went wrong",
        code: 500,
        data: null,
      );
    }
  }


  Future<StatusChangeResponseModel?> updateAgentStatus(String status, String publicId) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.changeAgentStatus(status.toUpperCase(), publicId);

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "CHANGE STATUS RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200) {
        return api.data; 
      } else {
        return StatusChangeResponseModel(
          success: false,
          message: "Failed to update status",
          code: api.response.statusCode ?? 500,
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return StatusChangeResponseModel(
        success: false,
        message: "Dio Exception: ${e.message}",
        code: e.response?.statusCode ?? 400,
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return StatusChangeResponseModel(
        success: false,
        message: "Something went wrong",
        code: 500,
        data: null,
      );
    }
  }

}