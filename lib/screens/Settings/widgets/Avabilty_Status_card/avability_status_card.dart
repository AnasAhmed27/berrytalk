import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Home_screen/widget/status_dropdown.dart';
import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailabilityStatusCard extends StatefulWidget {
  final StatusDropdownController statusController;
  final StatusChangedCallback onStatusChanged;
  const AvailabilityStatusCard({super.key, required this.statusController, required this.onStatusChanged});

  @override
  State<AvailabilityStatusCard> createState() => _AvailabilityStatusCardState();
}

class _AvailabilityStatusCardState extends State<AvailabilityStatusCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /*if (_syncedFromProfile) return;

    final apiStatus = context.read<SettingBloc>().state.agentProfile?.status;
    if (apiStatus != null && apiStatus.isNotEmpty) {
      _statusController.setStatusFromApi(apiStatus);
    }
    _syncedFromProfile = true;*/
  }

  @override
  void dispose() {
    widget.statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);

    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
      padding: const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: Text(
              "Availability Status",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: AppConstants.FontWeight_Semibold,
                color: textColor,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 0, top: 4, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: Text(
              "Control when you receive new conversations",
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
              top: 16,
              right: 0,
              bottom: 0,
            ),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: StatusDropdown(
              controller: widget.statusController,
              initialStatus: widget.statusController.status,
              onStatusChanged: widget.onStatusChanged,
            ),
          ),
        ],
      ),
    );
  }
}
