import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import '../../../../../network/ApiClient.dart';


class ChatContactApiCall {
  Future<ChatContactApiModel?> fetchContactList({required int page}) async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.getChatContactList("$token", page);

      // AppUtilities.appLogging(
      //   type: LoggingType.info,
      //   message: "CHAT CONTACT LIST RESPONSE =====>>> ${api.response.data}",
      //   stackTrace: null,
      // );

      if (api.response.statusCode == 200) {
        return ChatContactApiModel.fromJson(api.response.data);
      } else {
        return ChatContactApiModel(
          success: false,
          message: "Failed to load contacts",
          code: 200,
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return ChatContactApiModel(success: false, message: "Dio Exception", data: null, code: 200);
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return ChatContactApiModel(success: false, message: "Something went wrong", data: null, code: 200);
    }
  }
}