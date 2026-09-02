part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginInitialEvent extends LoginEvent {}

final class BackPressActionEvent extends LoginEvent {}

final class LoadingEvent extends LoginEvent {}

final class LoginLoadingSuccessState extends LoginEvent {}

final class LoadingErrorEvent extends LoginEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

final class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitEvent(this.email, this.password);
}

