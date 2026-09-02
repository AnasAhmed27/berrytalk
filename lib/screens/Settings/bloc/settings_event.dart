part of 'settings_bloc.dart';

@immutable
sealed class SettingEvent {}

final class SettingInitialEvent extends SettingEvent {}

final class BackPressActionEvent extends SettingEvent {}

final class LoadingEvent extends SettingEvent {}

final class LoadingSuccessEvent extends SettingEvent {}

final class LoadingErrorEvent extends SettingEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

class ChangeStatusEvent extends SettingEvent {
  final String status;
  ChangeStatusEvent({required this.status});
}

final class TogglePushNotificationEvent extends SettingEvent {
  final bool value;

  TogglePushNotificationEvent(this.value);
}

final class ToggleSoundAlertEvent extends SettingEvent {
  final bool value;

  ToggleSoundAlertEvent(this.value);
}

final class ToggleDarkModeEvent extends SettingEvent {
  final bool value;

  ToggleDarkModeEvent(this.value);
}

final class FetchAgentProfileEvent extends SettingEvent {}

final class LogoutSubmitEvent extends SettingEvent {}
