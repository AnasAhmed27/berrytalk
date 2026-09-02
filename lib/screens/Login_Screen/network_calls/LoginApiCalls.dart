import 'dart:io';

import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Enum/permission_enum.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/internet/utils_network/NetworkUtils.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';
import '../../../network/ApiClient.dart';
import '../../../network/ApiService.dart';

class LoginApiCall {
  Future<LoginModel?> clientLogin({
    required String email,
    required String password,
  }) async {
    bool canReachServer = await NetworkUtils.isServerReachable();
    if (!canReachServer) {
      return LoginModel(
        success: false,
        message: NetworkUtils.restrictedNetworkMessage,
        code: NetworkUtils.restrictedNetworkCode,
        data: null,
      );
    }

    String? token = await SharedPrefData.getAccessToken();
    final apiService = ApiClient().apiService;

    try {
      Map<String, dynamic> map = {"email": email, "password": password};

      //final api = await apiService.login(token!, map);
      final api = await apiService.login(token ?? "", map);
      final responseData = api.response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception("API response data is null");
      }

      final int serverStatus = responseData['status'] ?? 0;
      final Map<String, dynamic>? innerData =
          responseData['data'] as Map<String, dynamic>?;
      final String? extractedToken =
          innerData?['accessToken'] ?? innerData?['token'];

      LoginModel model = LoginModel.fromJson(responseData);

      AppUtilities.appLogging(
        type: LoggingType.info,
        message:
            "LoginDataModel API RESPONSE ========>>> response: ${api.response.data}",
        stackTrace: null,
      );

      if (api.response.statusCode == 200 && serverStatus == 1) {
        print(
          "LoginDataModel API RESPONSE ========>>> token: ${extractedToken ?? 'No Token'}",
        );

        if (extractedToken != null && extractedToken.isNotEmpty) {
          await SharedPrefData.saveAccessToken(extractedToken);
          await SharedPrefData.saveAccessOnlyToken(extractedToken);
          await SharedPrefData.saveTokenExpiry(
            (DateTime.now().millisecondsSinceEpoch + 3600 * 1000).toInt(),
          );
          print("LoginApiCall: New Access Token Saved.");
        }

        try {
          final permissionApi = await apiService.getUserPermissions(
            extractedToken ?? "",
          );
          final permissionData =
              permissionApi.response.data as Map<String, dynamic>?;

          if (permissionData != null && permissionData['status'] == 0) {
            final List<dynamic> permissionsList = permissionData['data'] ?? [];

            bool hasAccess = permissionsList.any((element) {
              final String pName = element['name'] ?? '';
              return pName == AppPermission.liveChatManager.value ||
                  pName == AppPermission.chatBotManager.value ||
                   pName == AppPermission.liveChatagent.value ||  
                   pName == AppPermission.agent.value ;
            });

            if (!hasAccess) {
              print("ACCESS DENIED: Required permissions missing.");
              await SharedPrefData.removeAll();

              return LoginModel(
                success: true,
                message:
                    "Permission denied. Please contact support to enable this permission.",
                code: 403,
                data: null,
              );
            }
          } else {
            throw Exception("Failed to validate user permissions");
          }
        } catch (permissionException) {
          print("Permission API Exception: $permissionException");
          await SharedPrefData.removeAll();
          return LoginModel(
            success: false,
            message: "Authentication failed during permission verification.",
            code: 400,
            data: null,
          );
        }

        return LoginModel(
          success: true,
          message: model.message,
          code: model.code ?? 200,
          data: model.data,
        );
      } else {
        print("TERMINAL ERROR: API Success but Server returned status 0");
        return LoginModel(
          success: false,
          message: model.message,
          code: model.code ?? api.response.statusCode ?? 400,
          data: model.data,
        );
      }
    } on DioException catch (e, stacktrace) {
      String finalErrorMsg = "An unexpected network error occurred.";
      int finalStatusCode = e.response?.statusCode ?? 500;
      final responseMap = e.response?.data as Map<String, dynamic>?;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.error is SocketException) {
        finalErrorMsg = NetworkUtils.restrictedNetworkMessage;
        finalStatusCode = NetworkUtils.restrictedNetworkCode;
      } else if (responseMap != null && responseMap.containsKey('message')) {
        finalErrorMsg = responseMap['message'] ?? finalErrorMsg;
        finalStatusCode = responseMap['code'] ?? finalStatusCode;
      }

      AppUtilities.appLogging(
        type: LoggingType.warning,
        message:
            'Error! statusCode: ${responseMap?['code'] ?? e.response?.statusCode}, statusMessage: ${responseMap?['message'] ?? ''}',
        error: 'Server Side Stack Trace ==> ${responseMap?["stack"] ?? ''}',
        stackTrace: stacktrace,
      );

      return LoginModel(
        success: false,
        message: responseMap?['message'] ?? "Invalid credentials",
        code: responseMap?['code'] ?? e.response?.statusCode ?? 500,
        data: null,
      );
    } catch (e, stacktrace) {
      AppUtilities.appLogging(
        type: LoggingType.error,
        message: "Unexpected code breakdown in LoginApiCall",
        error: e.toString(),
        stackTrace: stacktrace,
      );

      final String systemCrashMsg = AppUtilities.apiStatusCodeTitleMsg(
        NetworkUtils.fatalExceptionCode,
      )["msg"];

      return LoginModel(
        success: false,
        message: systemCrashMsg,
        code: 8113,
        data: null,
      );
    }
  }
}

