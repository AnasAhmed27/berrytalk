import 'package:berrytalks/network/ApiService.dart';
import 'package:dio/dio.dart';
import 'token_refresh_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  late final ApiService apiService;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio();
    dio.interceptors.add(TokenRefreshInterceptor(
      dio,
      onLogout: () { print("===============>> Logout <<===============");  /*AuthEventBus().fireForceLogout();*/},
      onTokenExpire: () { print("===============>> Token Expired <<===============");  /*AuthEventBus().fireForceLogout();*/},
    ));
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, error: true));
  dio.interceptors.add(LogInterceptor(
  requestBody: true, 
  responseBody: true, 
  error: true,
  logPrint: (object) {
    final logStr = object.toString();
    if (logStr.contains('[request cancelled]') || logStr.contains('Session expired or unauthorized')) {
      return; 
    }
    print(object); 
  },
));

    apiService = ApiService(dio);
  }
}