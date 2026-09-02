import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/network/socket_service/local_push_notification_service.dart';
import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        bool isPushEnabled = true;
        bool isSoundEnabled = true;
        bool darkMode = false;
        if (state is SettingInitialState) {
          isPushEnabled = state.pushNotifications;
          isSoundEnabled = state.soundAlerts;
          darkMode = state.darkMode;
        } else if (state is SettingLoadedState) {
          isPushEnabled = state.pushNotifications;
          isSoundEnabled = state.soundAlerts;
          darkMode = state.darkMode;
        }

        return Container(
          margin: const EdgeInsets.only(
            left: 20,
            top: 10,
            right: 20,
            bottom: 10,
          ),
          padding: const EdgeInsets.only(
            left: 15,
            top: 15,
            right: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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
                  "Notifications",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: AppConstants.FontWeight_Semibold,
                    color: textColor,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 10,
                  right: 0,
                  bottom: 10,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: _buildSwitchRow(
                  context: context,
                  title: "Push Notifications",
                  subtitle: "Receive alerts for new messages",
                  value: isPushEnabled,
                  darkMode: darkMode,

                  onChanged: (val) async {
                    if (val == true) {
                      final pushService = LocalPushNotificationService();
                      bool isGranted = await pushService
                          .requestNotificationPermission();

                      if (isGranted) {
                        context.read<SettingBloc>().add(
                          TogglePushNotificationEvent(true),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enable notifications in Settings to receive alerts.",
                            ),
                          ),
                        );
                      }
                    } else {
                      context.read<SettingBloc>().add(
                        TogglePushNotificationEvent(false),
                      );
                    }
                  },
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 12,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: Divider(height: 1, thickness: 0.5, color: borderColor),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 10,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: _buildSwitchRow(
                  context: context,
                  title: "Sound Alerts",
                  subtitle: "Receive alerts for new messages",
                  value: isSoundEnabled,
                  darkMode: darkMode,
                  onChanged: (val) {
                    context.read<SettingBloc>().add(ToggleSoundAlertEvent(val));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required bool darkMode,
    required ValueChanged<bool> onChanged,
  }) {
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);

    return Container(
      margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

      child: Row(
        children: [
          Expanded(
            child: Container(
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
                      title,
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
                      subtitle,
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
              value: value,
              activeTrackColor: AppThemeUtilities.HexToColor("#29A869"),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
