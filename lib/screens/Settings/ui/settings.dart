import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/Buttons/RippleButton.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/button/Button.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart';
import 'package:berrytalks/screens/Settings/widgets/Apparance_card/appearance_card.dart';
import 'package:berrytalks/screens/Settings/widgets/Avabilty_Status_card/avability_status_card.dart';
import 'package:berrytalks/screens/Settings/widgets/Notifications_card/notifications_card.dart';
import 'package:berrytalks/screens/Settings/widgets/Profile_Card/profile_Card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Home_screen/widget/status/agent_availability_status.dart';
import '../../Home_screen/widget/status/status_dropdown_controller.dart';

class SettingScreen extends StatefulWidget {
  final VoidCallback onLogoutPressed;
  const SettingScreen({super.key, required this.onLogoutPressed});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final bool isScrollable = false;
  final isFullScreen = true;
  bool isBackEnable = true;
  StatusDropdownController statusController = StatusDropdownController(initialStatus: AgentAvailabilityStatus.online);

  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(SettingInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    //final settingBloc = BlocProvider.of<SettingBloc>(context, listen: false);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final backgroundColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    return BlocConsumer<SettingBloc, SettingState>(
      listenWhen: (previous, current) => current is SettingActionState,
      buildWhen: (previous, current) => current is! SettingActionState,
     // bloc: settingBloc,
      listener: (context, state) {
        
        if (state is LoadingState) {
          AppUtilities.showLoadingDialog(context);
        }
        else if (state is LoadingSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        else if (state is BackPressActionState) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(HOME_ROUTE); 
          }
        }
        else if (state is LogoutSuccessActionState) {
          context.go(LOGIN_ROUTE); 
        }
        else if (state is SettingLoadedState) {
          AppUtilities.showSuccessSnackBar(
            context, 
            title: "Success",
            message: "Status updated successfully!",
          );
        }
        else if (state is LoadingErrorState) {
          AppUtilities.showErrorSnackBar(
            context,
            title: state.errorTitle,
            message: state.errorMsg,
          );
        }
      },

      builder: (BuildContext context, SettingState state) {
        final profile = state.agentProfile;
        if (profile != null) {
          statusController.setStatusFromApi(profile.status);
        }
        return BaseScreen(
          onPanUpdate: () {
            BlocProvider.of<SettingBloc>(context).add(BackPressActionEvent());
          },
          onWillPop: () {
            BlocProvider.of<SettingBloc>(context).add(BackPressActionEvent());
          },
          isScrollable: isScrollable,
          isFullScreen: isFullScreen,
          routeName: SETTING_ROUTE,
          appBar: AppBar(
            toolbarHeight: 66,
            leadingWidth: 40,
            foregroundColor: textColor,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            bottomOpacity: 0.1,
            elevation: 1,
            shadowColor: cardColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () {
                  BlocProvider.of<SettingBloc>(
                    context,
                  ).add(BackPressActionEvent());
                },
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                  style: GoogleFonts.poppins(
                    fontWeight: AppConstants.FontWeight_Semibold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          screenIndex: 4,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: cardColor,

            child: Container(
              margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
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
                    margin: EdgeInsets.only(
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
                    child: ProfileCard(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
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
                    child: AvailabilityStatusCard(statusController: statusController,onStatusChanged: (status) {
                      context.read<SettingBloc>().add(
                        ChangeStatusEvent(status: status.apiValue),
                      );
                    },),
                  ),
                  Container(
                    margin: EdgeInsets.only(
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
                    child: NotificationsCard(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
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
                    child: AppearanceCard(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 0,
                      top: 10,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    child: RippleButton(
                      onPressed: widget.onLogoutPressed,

                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: 20,
                          top: 0,
                          right: 20,
                          bottom: 0,
                        ),
                        padding: EdgeInsets.only(
                          left: 0,
                          top: 12,
                          right: 0,
                          bottom: 12,
                        ),
                        child: Button.withIcon(
                          text: "Log out",
                          textColor: AppThemeUtilities.HexToColor("#f8f9fa"),
                          color: AppThemeUtilities.HexToColor("#ef4343"),
                          isEnable: true,
                          showPrefix: true,
                          onPressed: () async {
                            await AppUtilities.logOut(
                              context: context,
                              msg: "Are you sure you want to log out?",
                              onLogOut: () async {
                                context.pop();
                                BlocProvider.of<SettingBloc>(
                                  context,
                                ).add(LogoutSubmitEvent());
                              },
                            );
                          },
                          icon: Icons.logout,
                        ),
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
