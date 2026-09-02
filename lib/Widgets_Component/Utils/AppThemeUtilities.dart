

import 'package:flutter/material.dart';
import '../extentions/HexColor.dart';
import 'AppConstants.dart';

class AppThemeUtilities{
  static Color appdarkthemeColor = HexColor.fromHex(AppConstants.appdarkthemeColor);
  static Color buttonColor = HexColor.fromHex(AppConstants.buttonColor);
  static Color appScreenBGColor = HexColor.fromHex(AppConstants.appScreenBGColor);
  static Color appBGColor = HexColor.fromHex(AppConstants.appBGColor);
  static Color appBorderColor = HexColor.fromHex(AppConstants.appBorderColor);
  static Color appPrimaryBGColor = HexColor.fromHex(AppConstants.appPrimaryBGColor);
  static Color appSecondaryBGColor = HexColor.fromHex(AppConstants.appSecondaryBGColor);
  static Color appgreyColor = HexColor.fromHex(AppConstants.appgreyColor);
  static Color appGreyBorderColor = HexColor.fromHex(AppConstants.appGreyBorderColor);
  static Color greenShade = HexColor.fromHex(AppConstants.greenShade);
  static Color appButtonBGColor = HexColor.fromHex(AppConstants.appButtonBGColor);
  static Color buttonBGGradientStartColor = HexColor.fromHex(AppConstants.buttonBGGradientStartColor);

  static Color buttonBGGradientEndColor = HexColor.fromHex(AppConstants.buttonBGGradientEndColor);
  // static Color appTextBGColor = HexColor.fromHex(AppConstants.textBGColor);
  // static Color appTextColor = HexColor.fromHex(AppConstants.textColor);
  static Color bigTextColor = HexColor.fromHex(AppConstants.bigTextColor);
  // static Color blueTextColor = HexColor.fromHex(AppConstants.blueTextColor);
  static Color appTextFieldLableColor = HexColor.fromHex(AppConstants.textFieldLableColor);
  static Color appTextFieldBorderColor = HexColor.fromHex(AppConstants.appTextFieldBorderColor);
  static Color appTextFieldEnabledBorderColor = HexColor.fromHex(AppConstants.appTextFieldEnabledBorderColor);
  static Color appTextFieldFocusBorderColor = HexColor.fromHex(AppConstants.appTextFieldFocusBorderColor);
  static Color appTextFieldFilledColor = HexColor.fromHex(AppConstants.appTextFieldFilledColor);
  static Color appTextFieldCursorColor = HexColor.fromHex(AppConstants.appTextFieldCursorColor);
  static Color appTextFieldHintColor = HexColor.fromHex(AppConstants.textFieldHintColor);
  static Color appTextFieldTextColor = HexColor.fromHex(AppConstants.appTextFieldTextColor);
  // static Color appTextSecondaryColor = HexColor.fromHex(AppConstants.textSecondaryColor);
  // static Color appTextFieldBgColor = HexColor.fromHex(AppConstants.textFieldBgColor);
  // static Color appPasswordFieldHintColor = HexColor.fromHex(AppConstants.appPasswordFieldHintColor);
  // static Color appPasswordFieldTextColor = HexColor.fromHex(AppConstants.appPasswordFieldTextColor);
  // static Color appBottomNavigationColor = HexColor.fromHex(AppConstants.appBottomNavigationColor);
  static Color blackColor = HexColor.fromHex(AppConstants.blackColor);
  static Color whiteColor = HexColor.fromHex(AppConstants.whiteColor);
  static Color transparent = Colors.transparent;

  static Color HexToColor(String colorCode){
    Color color = HexColor.fromHex(colorCode);
    return color;
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: greenShade,
      scaffoldBackgroundColor: const Color(0xFFF8FCF9), 
      cardColor: Colors.white,
      dividerColor: const Color(0xE0CFD0D1),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
     
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF808080), fontSize: 14),
      ),
    );
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF00B074), 
      scaffoldBackgroundColor: const Color(0xFF121212), 
      cardColor: const Color(0xFF1E1E1E), 
      dividerColor: const Color(0xFF2D2D2D), 
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFFB3B3B3), fontSize: 14), 
      ),
    );
  }

  static Color getCardColor(BuildContext context) => Theme.of(context).cardColor;
  static Color getTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppThemeUtilities.HexToColor("C4C4C4") : blackColor;
  static Color getAvatarBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E352F) : greenShade;
  static Color getMessageColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB3B3B3) : appGreyBorderColor;
  static Color getTimeColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9E9E9E) : const Color(0xFF808080);
  static Color getAppBarShadowColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFCFD0D1);
  static Color getStatusColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppThemeUtilities.HexToColor("#ADADAD") : blackColor;
  static Color getdesignationColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppThemeUtilities.HexToColor("#707070") : const Color(0xFF808080);
  static Color getTrackingColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppThemeUtilities.HexToColor("#f9fafb"): Colors.transparent ;
  static Color getButtonColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? AppThemeUtilities.HexToColor("#3D3D3D") : AppThemeUtilities.HexToColor("#F0F2F4");

 
}