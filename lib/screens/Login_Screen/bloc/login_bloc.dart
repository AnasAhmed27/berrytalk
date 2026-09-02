import 'dart:async';

import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Login_Screen/network_calls/LoginApiCalls.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    on<LoginInitialEvent>(_onLoginInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoginLoadingSuccessState>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<LoginSubmitEvent>(_onLoginSubmitEvent);
  }

  FutureOr<void> _onLoginInitialEvent(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitialState());
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(BackPressActionState());
  }

  FutureOr<void> _onLoadingEvent(LoadingEvent event, Emitter<LoginState> emit) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoginLoadingSuccessState event,
    Emitter<LoginState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }

//   Future<void> _onLoginSubmitEvent(
//     LoginSubmitEvent event,
//     Emitter<LoginState> emit,
//   ) async {
//     AppUtilities.appLogging(
//     type: LoggingType.info,
//     message: "LOGIN BUTTON CLICKED for email: ${event.email.trim()}",
//   );
//     print("LOGIN BUTTON CLICKED");

//     emit(LoadingState());

//     try {
//       final LoginApiCall loginApiCall = LoginApiCall();
//       final LoginModel? response = await loginApiCall.clientLogin(
//         email: event.email.trim(),
//         password: event.password.trim(),
//       );

//       emit(LoadingSuccessState());

//       if (response == null) {
//       emit(
//         LoadingErrorState(
//           errorTitle: "Network Error",
//           errorMsg: "Unable to reach server. Please try again later.",
//         ),
//       );
//       return;
//     }

//       if (response.message == "Display: Token Error") {
//       emit(
//         LoadingErrorState(
//           errorTitle: "Authentication Error",
//           errorMsg: "Token Error: Please check authentication.",
//         ),
//       );
//       return;
//     }

//     if (response.code == 403) {
//       emit(
//         PermissionDeniedActionState(
//           errorTitle: "Access Restricted",
//           errorMsg: response.message.isNotEmpty 
//               ? response.message 
//               : "You do not have the necessary permissions to access this feature. Please contact your administrator.",
//         ),
//       );
//       return;
//     }

//       if (response.success) {
//       await SharedPrefData.saveUserEmail(event.email.trim());
//       await SharedPrefData.saveUserPassword(event.password.trim());
//       await SharedPrefData.saveIsUserLogin(true);

//       if (response.data != null) {
//        // await SharedPrefData.saveUserDetails(response.data!);
//       }

//       emit(SubmitDataSuccessState());
//     }
//     else {
//       String errorTitle = "Login Failed";
//       String errorMsg = response.message.isNotEmpty 
//           ? response.message 
//           : "Invalid Email or Password";

//       if (response.code != null) {
//         final titleMap = AppUtilities.apiStatusCodeTitleMsg(response.code!);
//         if (titleMap.containsKey("Title")) {
//           errorTitle = titleMap["Title"] ?? "Login Failed";
//         }
//       }
//       emit(
//         LoadingErrorState(
//           errorTitle: errorTitle, 
//           errorMsg: errorMsg,
//         ),
//       );
//     }
//     } catch (e, stacktrace) {
//       AppUtilities.appLogging(
//       type: LoggingType.error,
//       message: 'Exception Occurred in Login BLoC: $e',
//       error: e,
//       stackTrace: stacktrace,
//     );
//       emit(LoadingSuccessState());
//       emit(
//         LoadingErrorState(
//           errorTitle: "Something went wrong",
//           errorMsg: "something went wrong\n Exception: $e",
//         ),
//       );
//     }
//   }
// }


Future<void> _onLoginSubmitEvent(
  LoginSubmitEvent event,
  Emitter<LoginState> emit,
) async {
  AppUtilities.appLogging(
    type: LoggingType.info,
    message: "LOGIN BUTTON CLICKED for email: ${event.email.trim()}",
  );

  emit(LoadingState());

  try {
    final LoginApiCall loginApiCall = LoginApiCall();
    
    final LoginModel? response = await loginApiCall
        .clientLogin(
          email: event.email.trim(),
          password: event.password.trim(),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw TimeoutException("Server is taking too long to respond.");
          },
        );

    emit(LoadingSuccessState());

    if (response == null) {
      emit(
        LoadingErrorState(
          errorTitle: "Gateway Error",
          errorMsg: "No response received from the server. Please try again later.",
        ),
      );
      return;
    }

    if (response.message == "Display: Token Error") {
      emit(
        LoadingErrorState(
          errorTitle: "Authentication Error",
          errorMsg: "Token Error: Please check your credentials or authentication status.",
        ),
      );
      return;
    }

    if (response.code == 403) {
      emit(
        PermissionDeniedActionState(
          errorTitle: "Access Restricted",
          errorMsg: response.message.isNotEmpty 
              ? response.message 
              : "You do not have the necessary permissions to access this feature.",
        ),
      );
      return;
    }

    if (response.success) {
      await SharedPrefData.saveUserEmail(event.email.trim());
      await SharedPrefData.saveUserPassword(event.password.trim());
      await SharedPrefData.saveIsUserLogin(true);

      emit(SubmitDataSuccessState());
    } else {
      String errorTitle = "Gateway Error";
      String errorMsg = response.message.isNotEmpty 
          ? response.message 
          : "A site error occurred. Please try again after a few moments.";

      if (response.code != null) {
        final titleMap = AppUtilities.apiStatusCodeTitleMsg(response.code!);
        if (titleMap.containsKey("Title")) {
          errorTitle = titleMap["Title"] ?? "Gateway Error";
        }
      }

      emit(
        LoadingErrorState(
          errorTitle: errorTitle, 
          errorMsg: errorMsg,
        ),
      );
    }
  } on TimeoutException catch (e) {
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: 'Timeout Occurred: $e',
    );
    emit(LoadingSuccessState());
    emit(
      LoadingErrorState(
        errorTitle: "Gateway Timeout",
        errorMsg: "Server is not responding. This appears to be a gateway issue. Please try again shortly.",
      ),
    );
  } catch (e, stacktrace) {
    AppUtilities.appLogging(
      type: LoggingType.error,
      message: 'Exception Occurred in Login BLoC: $e',
      error: e,
      stackTrace: stacktrace,
    );
    emit(LoadingSuccessState());
    emit(
      LoadingErrorState(
        errorTitle: "Gateway Error",
        errorMsg: "An unexpected site error occurred. Please try again later.",
      ),
    );
  }
}
}
