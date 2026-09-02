import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import '../../../../../network/ApiClient.dart';


class TeamListApiCall {
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
      return TeamContactApiModel(success: false, message: "Dio Exception", data: null, code: e.response?.statusCode ?? 400,);
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return TeamContactApiModel(success: false, message: "Something went wrong", data: null, code: 500);
    }
  }


Future<TeamContactApiModel?> fetchInternalChatDetails({required int page}) async {
  final token = await SharedPrefData.getAccessToken();
  final apiService = ApiClient().apiService;

  try {
    final api = await apiService.getInternalChatDetails("Bearer $token", page);
    
    AppUtilities.appLogging(
      type: LoggingType.info,
      message: "INTERNAL CHAT DETAILS RESPONSE =====>>> ${api.response.data}",
      stackTrace: null,
    );

    if (api.response.statusCode == 200 && api.response.data != null) {
      return TeamContactApiModel.fromJson(api.response.data);
    } else {
      return TeamContactApiModel(
        success: false, 
        message: "Failed to load chat details", 
        code: api.response.statusCode, 
        data: null,
      );
    }
  } catch (e, stacktrace) {
    AppUtilities.appLogging(
      type: LoggingType.error, 
      message: "Exception in fetchInternalChatDetails: ${e.toString()}", 
      stackTrace: stacktrace,
    );
    return TeamContactApiModel(
      success: false, 
      message: "Something went wrong: $e", 
      data: null, 
      code: 500,
    );
  }
}
}