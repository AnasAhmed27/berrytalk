part of 'settings_bloc.dart';

@immutable
sealed class SettingState {
  final bool pushNotifications;
  final bool soundAlerts;
  final bool darkMode;
  final AgentProfileData? agentProfile;

  const SettingState({
    this.pushNotifications = true,
    this.soundAlerts = true,
    this.darkMode = false,
    this.agentProfile,
  });
}

sealed class SettingActionState extends SettingState {
  SettingActionState({
    super.pushNotifications,
    super.soundAlerts,
    super.darkMode,
    super.agentProfile,
  });
}

final class SettingInitialState extends SettingState {
  SettingInitialState({
    super.pushNotifications,
    super.soundAlerts,
    super.darkMode,
    super.agentProfile,
  });
}

final class BackPressActionState extends SettingActionState {
  BackPressActionState({
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}

final class LoadingState extends SettingActionState {
  LoadingState({
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}

final class LoadingSuccessState extends SettingActionState {
  LoadingSuccessState({
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}

final class LogoutSuccessActionState extends SettingActionState {
  LogoutSuccessActionState({
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}

final class LoadingErrorState extends SettingActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({
    required this.errorTitle,
    required this.errorMsg,
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}

final class SettingLoadedState extends SettingState {
  SettingLoadedState({
    required super.pushNotifications,
    required super.soundAlerts,
    required super.darkMode,
    super.agentProfile,
  });
}
