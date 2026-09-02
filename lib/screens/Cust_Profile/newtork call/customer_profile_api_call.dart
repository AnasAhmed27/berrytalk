import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import '../../../../../network/ApiClient.dart'; 

class CompanyProfileApiCall {
  Future<CompanyProfileApiModel?> fetchCompanyProfile() async {
    final token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      final api = await apiService.getCompanyProfile("$token");

      AppUtilities.appLogging(
        type: LoggingType.info,
        message: "COMPANY PROFILE RESPONSE =====>>> ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200) {
        final responseMap = api.response.data as Map<String, dynamic>;
        return CompanyProfileApiModel.fromJson(responseMap);
      } else {
        return CompanyProfileApiModel(
          status: api.response.statusCode ?? 0,
          message: "Failed to load company profile",
          data: null,
        );
      }
    } on DioException catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return CompanyProfileApiModel(
        status: 0,
        message: "Dio Exception: ${e.message}",
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: e.toString(),
        stackTrace: stacktrace,
      );
      return CompanyProfileApiModel(
        status: 0,
        message: "Something went wrong",
        data: null,
      );
    }
  }
}