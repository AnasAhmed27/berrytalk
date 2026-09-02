import 'dart:async';
import 'dart:ui';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage/SharedPrefrences.dart'; 
import 'ApiService.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<QueuedRequest> _queue = [];
  final VoidCallback onLogout;
  final VoidCallback onTokenExpire;

  TokenRefreshInterceptor(this.dio, {required this.onLogout, required this.onTokenExpire});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isAuthCall(options)) {
      print("TokenInterceptor: Login call detected, skipping authorization header attachment.");
      return handler.next(options);
    }
    final token = await SharedPrefData.getAccessToken();
    final expireIn = await SharedPrefData.getTokenExpiry();
    print("TokenInterceptor: onRequest ExpireIn: $expireIn, Token: $token");
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = token;
    }
    handler.next(options);
  }

 @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isAuthCall(err.requestOptions)) {
      print("TokenInterceptor: Login failed, passing directly to UI.");
      handler.next(err);
      return;
    }
    

    if (!_shouldRefresh(err)) {
      handler.next(err);
      return; 
    }

    final completer = Completer<Response>();
    _queue.add(QueuedRequest(requestOptions: err.requestOptions, completer: completer));

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        bool isExpired = await SharedPrefData.isTokenExpired();
        if (isExpired || err.response?.statusCode == 401 || err.response?.statusCode == 403) {
          // await _refresh(err.response?.statusCode ?? 401);
          await _handleForceLogout(err.response?.statusCode ?? 401);
          onTokenExpire();
        } else {
          await _retryQueue();
        }
      } catch (e) {
        await _handleForceLogout(err.response?.statusCode ?? 401); 
      } finally {
        _isRefreshing = false;
      }
    }

    try {
      final response = await completer.future;
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.cancel) {
          return; 
        }
        handler.reject(e);
      } else {
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: e.toString(),
          type: DioExceptionType.unknown,
        ));
      }
    }
  }

  bool _shouldRefresh(DioException err) {
    return err.response?.statusCode == 404 || err.response?.statusCode == 403;
  }

  bool _isAuthCall(RequestOptions req) {
    final path = req.path.toLowerCase();
    return path.contains('/auth/client/login') || path.contains('login');
  }

  Future<void> _refresh(int statusCode) async {
    final savedEmail = await SharedPrefData.getUserEmail() ?? "";
    final savedPassword = await SharedPrefData.getUserPassword() ?? "";
    String? Token = await SharedPrefData.getAccessToken();

    if (Token == null || Token.isEmpty) {
      await _handleForceLogout(statusCode);
      return;
    }

    if (Token.startsWith("Bearer ")) {
      Token = Token.replaceFirst("Bearer ", "").trim();
    }

    Map<String, dynamic> map = {
      "email": savedEmail.isNotEmpty ? savedEmail : "",
      "password": savedPassword.isNotEmpty ? savedPassword : ""
    };

    try {
      final resp = await ApiService(Dio()).login(Token, map); 
      final responseData = resp.response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw Exception("Refresh API response data is null");
      }

      final innerData = responseData['data'] as Map<String, dynamic>?;
      final String? newToken = innerData?['accessToken'];
      final int expires = 3600; 

      if (newToken != null && newToken.isNotEmpty) {
        await SharedPrefData.saveAccessToken(newToken);
        await SharedPrefData.saveTokenExpiry((DateTime.now().millisecondsSinceEpoch + expires * 1000).toInt());
        await _retryQueue(); 
      } else {
        await _handleForceLogout(statusCode);
      }
    } catch (e) {
      await _handleForceLogout(statusCode);
    }
  }

  Future<void> _retryQueue() async {
    final token = await SharedPrefData.getAccessToken();
    for (var q in _queue) {
      q.requestOptions.headers['Authorization'] = "$token";
      q.completer.complete(await dio.fetch(q.requestOptions));
    }
    _queue.clear();
  }

 void _failQueue() {
  
      for (var q in _queue) {
        q.completer.completeError(DioException(
          requestOptions: q.requestOptions,
          error: "Token refresh failed, user logged out.",
          type: DioExceptionType.cancel,
        ));
      }

  }

  Future<void> _handleForceLogout(int code) async {
    AppUtilities.autoLogOut(statusCode: code, onLogOut: (){
      print("[AUTO LOGOUT] - Postman collision or unauthorized session detected.");
      _failQueue();
    });
  }
}

class QueuedRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;
  QueuedRequest({required this.requestOptions, required this.completer});
}