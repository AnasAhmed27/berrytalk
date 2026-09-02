import 'dart:convert';

import 'package:berrytalks/network/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefData {
  static final String appAccessToken = "appAccessToken";
  static final String appAccessOnlyToken = "appAccessOnlyToken";
  static final String appUserData = "UserData";
  //static final String appFCMToken = "appFCMToken";
  static final String isUserLogin = "isUserLogin";
  static final String appTokenExpiry = "appTokenExpiry";
  static final String userPassword = "userPassword";
  static final String userEmail = "userEmail";
  static final String isDarkModeActive = "isDarkModeActive";
  static final String appThemePreference = "appThemePreference";
  static final String agentPublicId = "agentPublicId";
  static final String companyProfileData = "companyProfileData";
  static const String isPushNotificationEnabled = "isPushNotificationEnabled";
  static const String isSoundAlertsEnabled = "isSoundAlertsEnabled";

   // ==================== Agent Public ID ====================
  static Future<void> saveAgentPublicId(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(agentPublicId, value);
  }

  static Future<String?> getAgentPublicId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(agentPublicId);
  }

  // ==================== Company Profile ====================
  static Future<void> saveCompanyProfileData(CompanyProfileData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(companyProfileData, jsonEncode(data.toJson()));
  }

  static Future<CompanyProfileData?> getCompanyProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(companyProfileData);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CompanyProfileData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ==================== Email & Password Management ====================
  static Future<void> saveUserEmail(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmail, value);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmail);
  }

  // ==================== Password Management ====================
  static Future<void> saveUserPassword(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userPassword, value);
  }

  static Future<String?> getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPassword);
  }

  // ==================== Clear Storage ====================
  static Future<void> removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userPassword);
    await prefs.remove(appUserData);
    await prefs.remove(appTokenExpiry);
    await prefs.remove(appAccessToken);
    await prefs.remove(isUserLogin);
  }

  static Future<void> remove(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(value);
  }
  // SharedPrefData class ke andar yeh generic method replace/add karein
static Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  // Saari string keys remove karein
  await prefs.remove(userPassword);
  await prefs.remove(appUserData);
  await prefs.remove(appTokenExpiry);
  await prefs.remove(appAccessToken);
  await prefs.remove(agentPublicId);
  await prefs.remove(companyProfileData);
  await prefs.remove(userEmail);
  
  // Login status explicitly false karein
  await prefs.setBool(isUserLogin, false);
  print("[Cache Cleaner]: Complete app preferences and credentials cleared successfully.");
}

  // ==================== Access Token & Expiry ====================
  
  static Future<void> saveAccessTokenWithExpiry(String token, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appAccessToken, "Bearer $token");

    final expiryEpoch = DateTime.now().millisecondsSinceEpoch + (expiresInSeconds * 1000);
    await prefs.setInt(appTokenExpiry, expiryEpoch);
  }

  static Future<void> saveAccessToken(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(appAccessToken, "Bearer $value");
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(appAccessToken);
  }

  static Future<void> saveAccessOnlyToken(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(appAccessOnlyToken, value);
  }

  static Future<String?> getAccessOnlyToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(appAccessOnlyToken);
  }

  static Future<void> saveTokenExpiry(int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(appTokenExpiry, value);
  }

  static Future<int?> getTokenExpiry() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(appTokenExpiry);
  }

  static Future<bool> isTokenExpired() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final expiry = sharedPreferences.getInt(appTokenExpiry);

    if (expiry == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    print("Token expiry: $expiry, now: $now");

    return now >= expiry;
  }

  // ==================== FCM Token Management ====================
  // static Future<void> saveFCMToken(String value) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   await sharedPreferences.setString(appFCMToken, value);
  // }

  // static Future<String?> getFCMToken() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.getString(appFCMToken);
  // }

  // ==================== Login State Status ====================
  static Future<void> saveIsUserLogin(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(isUserLogin, value);
  }

  static Future<bool?> getIsUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(isUserLogin) ?? false;
  }

  // ==================== Push Notification Preference ====================
static Future<void> savePushNotificationPreference(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(isPushNotificationEnabled, value);
}

static Future<bool> getPushNotificationPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(isPushNotificationEnabled) ?? true;
}

// ==================== Sound Alerts Preference ====================
static Future<void> saveSoundAlertsPreference(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(isSoundAlertsEnabled, value);
}

static Future<bool> getSoundAlertsPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Default 'true' fallback
  return prefs.getBool(isSoundAlertsEnabled) ?? true;
}

  // ==================== Theme Management ====================

  /// Persist the user's theme choice (`light`, `dark`, or `system`).
  static Future<bool> saveThemePreference(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(appThemePreference, value);
    await prefs.setBool(isDarkModeActive, mode == ThemeMode.dark);
    return true;
  }

  /// Load saved theme; falls back to legacy bool, then light mode.
  static Future<ThemeMode> getThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(appThemePreference);
    if (stored != null) {
      return switch (stored) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
    }

    final legacyDark = prefs.getBool(isDarkModeActive);
    return (legacyDark ?? false) ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<bool> saveThemeMode(bool value) async {
    return saveThemePreference(value ? ThemeMode.dark : ThemeMode.light);
  }

  static Future<bool> getThemeMode() async {
    return (await getThemePreference()) == ThemeMode.dark;
  }
}