import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide theme controller. Loaded once before [runApp] and provided at the
/// root so theme persists across cold starts (WhatsApp/Telegram pattern).
class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit(ThemeMode initial) : super(initial);

  static Future<ThemeMode> loadSavedTheme() => SharedPrefData.getThemePreference();

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    await SharedPrefData.saveThemePreference(mode);
    emit(mode);
  }

  Future<void> setDarkModeEnabled(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
