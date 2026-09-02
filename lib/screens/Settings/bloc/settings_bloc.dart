import 'dart:async';

import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Settings/network_calls/settings_api_call.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  bool pushNotifications = true;
  bool soundAlerts = true;
  bool darkMode = false;
  AgentProfileData? agentProfile;
  

  final AgentProfileApiCall _profileApiCall = AgentProfileApiCall();

  SettingBloc({bool initialDarkMode = false})
    : darkMode = initialDarkMode,
      super(SettingInitialState(darkMode: initialDarkMode)) {
    on<SettingInitialEvent>(_onSettingInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoadingSuccessEvent>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<TogglePushNotificationEvent>(_onTogglePushNotificationEvent);
    on<ToggleSoundAlertEvent>(_onToggleSoundAlertEvent);
    on<ToggleDarkModeEvent>(_onToggleDarkModeEvent);
    on<FetchAgentProfileEvent>(_onFetchAgentProfileEvent);
    on<LogoutSubmitEvent>(_onLogoutSubmitEvent);
    on<ChangeStatusEvent>(_onChangeStatusEvent);
  }

Future<void> _onChangeStatusEvent(ChangeStatusEvent event, Emitter<SettingState> emit,) async {
  final profile = agentProfile;
  if (profile == null) {
    return;
  }


  try {
    emit(
      LoadingState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );

    final response = await _profileApiCall.updateAgentStatus(
      event.status ?? '', 
      profile.publicId ?? '', 
    );

    emit(LoadingSuccessState(
      pushNotifications: pushNotifications,
      soundAlerts: soundAlerts,
      darkMode: darkMode,
      agentProfile: agentProfile,
    ));

    if (response != null && response.success) {
      print("[BLOC] Server updated successfully: ${event.status}");

      agentProfile = AgentProfileData(
        publicId: profile.publicId,
        companyPublicId: profile.companyPublicId,
        phoneNumberWork: profile.phoneNumberWork,
        agentType: profile.agentType,
        email: profile.email,
        firstName: profile.firstName,
        lastName: profile.lastName,
        imageUrl: profile.imageUrl,
        role: profile.role,
        status: event.status, 
      );


      emit(SettingLoadedState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ));
    }
    else {
      final errorMsg = response?.message ?? "Failed to update status";

      emit(LoadingErrorState(
        errorTitle: "Status Update Failed",
        errorMsg: errorMsg,
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ));
    }
  } catch (e) {
    
    emit(LoadingSuccessState(
      pushNotifications: pushNotifications,
      soundAlerts: soundAlerts,
      darkMode: darkMode,
      agentProfile: agentProfile,
    ));
    emit(LoadingErrorState(
      errorTitle: "Error",
      errorMsg: "Something went wrong while updating status.",
      pushNotifications: pushNotifications,
      soundAlerts: soundAlerts,
      darkMode: darkMode,
      agentProfile: agentProfile,
    ));
  }
}
  

  Future<void> _onFetchAgentProfileEvent(
    FetchAgentProfileEvent event,
    Emitter<SettingState> emit,
  ) async {
    final response = await _profileApiCall.fetchAgentProfile();
    if (response != null && response.success && response.data != null) {
      agentProfile = response.data;
      emit(
        SettingLoadedState(
          pushNotifications: pushNotifications,
          soundAlerts: soundAlerts,
          darkMode: darkMode,
          agentProfile: agentProfile,
        ),
      );
    }
  }

  Future<void> _onSettingInitialEvent(
    SettingInitialEvent event,
    Emitter<SettingState> emit,
  ) async {
    pushNotifications = await SharedPrefData.getPushNotificationPreference();
    soundAlerts = await SharedPrefData.getSoundAlertsPreference();
    emit(
      SettingInitialState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
    add(FetchAgentProfileEvent());
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<SettingState> emit,
  ) {
    emit(
      BackPressActionState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  FutureOr<void> _onLogoutSubmitEvent(
    LogoutSubmitEvent event,
    Emitter<SettingState> emit,
  ) async {
    emit(
      LoadingState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );

    try {
      await SharedPrefData.removeAll();
      await Future.delayed(const Duration(seconds: 1));

      emit(
        LoadingSuccessState(
          pushNotifications: pushNotifications,
          soundAlerts: soundAlerts,
          darkMode: darkMode,
          agentProfile: agentProfile,
        ),
      );

      emit(
        LogoutSuccessActionState(
          pushNotifications: pushNotifications,
          soundAlerts: soundAlerts,
          darkMode: darkMode,
          agentProfile: agentProfile,
        ),
      );
    } catch (e) {
      emit(
        LoadingErrorState(
          errorTitle: "Logout Failed",
          errorMsg: "Something went wrong. Please try again.",
          pushNotifications: pushNotifications,
          soundAlerts: soundAlerts,
          darkMode: darkMode,
          agentProfile: agentProfile,
        ),
      );
    }
  }

  FutureOr<void> _onLoadingEvent(
    LoadingEvent event,
    Emitter<SettingState> emit,
  ) {
    emit(
      LoadingState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoadingSuccessEvent event,
    Emitter<SettingState> emit,
  ) {
    emit(
      LoadingSuccessState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<SettingState> emit,
  ) {
    emit(
      LoadingErrorState(
        errorTitle: event.errorTitle,
        errorMsg: event.errorMsg,
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  FutureOr<void> _onTogglePushNotificationEvent(
    TogglePushNotificationEvent event,
    Emitter<SettingState> emit,
  ) async{
    pushNotifications = event.value;
    await SharedPrefData.savePushNotificationPreference(pushNotifications);
    emit(
      SettingLoadedState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  FutureOr<void> _onToggleSoundAlertEvent(
    ToggleSoundAlertEvent event,
    Emitter<SettingState> emit,
  ) async{
    soundAlerts = event.value;
    await SharedPrefData.saveSoundAlertsPreference(soundAlerts);
    emit(
      SettingLoadedState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }

  Future<void> _onToggleDarkModeEvent(
    ToggleDarkModeEvent event,
    Emitter<SettingState> emit,
  ) async {
    // Theme is owned by [AppThemeCubit] at the app root. Keep this handler so
    // older call-sites still compile; delegate persistence to the cubit.
    darkMode = event.value;
    await SharedPrefData.saveThemeMode(darkMode);
    emit(
      SettingLoadedState(
        pushNotifications: pushNotifications,
        soundAlerts: soundAlerts,
        darkMode: darkMode,
        agentProfile: agentProfile,
      ),
    );
  }
}
