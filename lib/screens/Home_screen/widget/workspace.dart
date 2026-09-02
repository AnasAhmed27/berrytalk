import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Home_screen/widget/status_dropdown.dart';
import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WorkspaceHeader extends StatefulWidget {
  final StatusDropdownController statusController;
  final StatusChangedCallback onStatusChanged;
  const WorkspaceHeader({super.key, required this.statusController, required this.onStatusChanged});

  @override
  State<WorkspaceHeader> createState() => _WorkspaceHeaderState();
}

class _WorkspaceHeaderState extends State<WorkspaceHeader> {
  // bool _syncedFromProfile = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // if (_syncedFromProfile) return;
    //
    // final apiStatus = context.read<SettingBloc>().state.agentProfile?.status;
    // if (apiStatus != null && apiStatus.isNotEmpty) {
    //   _statusController.setStatusFromApi(apiStatus);
    // }
    // _syncedFromProfile = true;
  }

  @override
  void dispose() {
    widget.statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color subtitleColor = AppThemeUtilities.getTimeColor(context);

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: Row(
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
                      child: SvgPicture.asset(AppImages.homelogo, height: 20),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 5,
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
                        "Berry Talks",
                        style: TextStyle(
                          fontFamily: AppConstants.FontFamily_SFPro,
                          fontWeight: AppConstants.FontWeight_Bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
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
                child: Text(
                  "Agent Workspace",
                  style: TextStyle(
                    fontFamily: AppConstants.FontFamily_SFPro,
                    fontWeight: AppConstants.FontWeight_Medium,
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                        right: 10,
                        bottom: 10,
                      ),
                      child: StatusDropdown(
                        controller: widget.statusController,
                        initialStatus: widget.statusController.status,
                        onStatusChanged: widget.onStatusChanged,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                        right: 10,
                        bottom: 10,
                      ),
                      child: InkWell(
                        onTap: () {
                          context.go(SETTING_ROUTE);
                        },
                        child: Icon(
                          Icons.settings_outlined,
                          color: AppThemeUtilities.appGreyBorderColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
