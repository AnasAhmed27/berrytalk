import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/services/theme/app_theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    

    return BlocBuilder<AppThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final darkMode = themeMode == ThemeMode.dark;

        return Container(
          margin: const EdgeInsets.only(left: 20, top: 8, right: 20, bottom: 8),
          padding: const EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: cardColor,

            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 16,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: Text(
                  "Appearance",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: AppConstants.FontWeight_Semibold,
                    color: textColor,
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 2,
                          ),
                          padding: const EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                          ),
                          child: Text(
                            "Dark Mode",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: AppConstants.FontWeight_Semibold,
                              color: textColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                          ),
                          padding: const EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                          ),
                          child: Text(
                            "Control app theme appearance",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: AppConstants.FontWeight_Regular,
                              color: hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    child: CupertinoSwitch(
                      value: darkMode,
                      activeTrackColor: AppThemeUtilities.HexToColor("#29A869"),
                      onChanged: (val) {
                        context.read<AppThemeCubit>().setDarkModeEnabled(val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
