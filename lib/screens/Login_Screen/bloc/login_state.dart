part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

sealed class LoginActionState extends LoginState {}

final class LoginInitialState extends LoginState {}

final class BackPressActionState extends LoginActionState {}

final class LoadingState extends LoginActionState {}

final class LoadingSuccessState extends LoginActionState {}

final class LoadingErrorState extends LoginActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}

class PermissionDeniedActionState extends LoginActionState {
  final String errorTitle;
  final String errorMsg;

  PermissionDeniedActionState({
    required this.errorTitle,
    required this.errorMsg,
  });
}

final class SubmitDataSuccessState extends LoginActionState {}
