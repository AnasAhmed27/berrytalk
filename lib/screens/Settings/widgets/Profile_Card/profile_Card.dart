import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        final profile = state.agentProfile;
        String initials = "OO";
        if (profile != null) {
          final fChar = (profile.firstName != null && profile.firstName!.isNotEmpty) ? profile.firstName![0] : "";
          final lChar = (profile.lastName != null && profile.lastName!.isNotEmpty) ? profile.lastName![0] : "";
          initials = "$fChar$lChar".toUpperCase();
          if (initials.isEmpty) initials = "BT"; 
        }
        return Container(
          margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // onTap: () {
            //   //context.push('/profile-details');
            //   print("Profile card pressed - Navigating to details");
            // },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                top: 15,
                right: 15,
                bottom: 15,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 15,
                      right: 15,
                      bottom: 15,
                    ),

                    decoration: BoxDecoration(
                      color: AppThemeUtilities.getAvatarBgColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: AppConstants.FontWeight_Semibold,
                          color: AppThemeUtilities.HexToColor("#27A365"),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                              profile?.fullName ?? "Loading Profile...",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: AppConstants.FontWeight_Semibold,
                                color: textColor,
                              ),
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(
                              left: 0,
                              top: 2,
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
                              profile?.agentType ?? "Please wait...",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: AppConstants.FontWeight_Regular,
                                color: hintColor,
                              ),
                            ),
                          ),

                          Container(
                            margin: const EdgeInsets.only(
                              left: 0,
                              top: 2,
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
                              profile?.email ?? "...",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: AppConstants.FontWeight_Regular,
                                color: hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
