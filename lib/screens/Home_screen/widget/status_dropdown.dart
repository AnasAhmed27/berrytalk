import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Home_screen/widget/status/agent_availability_status.dart';
import 'package:berrytalks/screens/Home_screen/widget/status/status_dropdown_controller.dart';
import 'package:berrytalks/screens/Home_screen/widget/status/status_dropdown_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'status/agent_availability_status.dart';
export 'status/status_dropdown_controller.dart';

typedef StatusChangedCallback = void Function(AgentAvailabilityStatus status);

/// Reusable agent status dropdown. Fully self-managed via
/// [StatusDropdownCubit] — no dependency on [SettingBloc] or parent
/// [setState].
///
/// Example:
/// ```dart
/// final controller = StatusDropdownController(
///   initialStatus: AgentAvailabilityStatus.online,
/// );
///
/// StatusDropdown(
///   controller: controller,
///   initialStatus: AgentAvailabilityStatus.online,
///   onStatusChanged: (status) {
///     // your logic here
///   },
/// );
/// ```
class StatusDropdown extends StatefulWidget {
  const StatusDropdown({
    super.key,
    required this.controller,
    required this.initialStatus,
    required this.onStatusChanged,
  });

  /// External controller to read/set status programmatically.
  final StatusDropdownController controller;

  /// Initial selected status when the widget is first built.
  final AgentAvailabilityStatus initialStatus;

  /// Fired when the user picks a **different** status from the dropdown.
  /// Re-selecting the current status does not invoke this callback.
  final StatusChangedCallback onStatusChanged;

  @override
  State<StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown> {
  late final StatusDropdownCubit _cubit;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    widget.controller.setStatus(widget.initialStatus);
    _cubit = StatusDropdownCubit(widget.initialStatus);
    _attachController();
  }

  @override
  void didUpdateWidget(StatusDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController();
    }
    if (oldWidget.initialStatus != widget.initialStatus) {
      _cubit.select(widget.initialStatus);
      widget.controller.setStatus(widget.initialStatus);
    }
  }

  void _detachController() {
    if (_controllerListener != null) {
      widget.controller.removeListener(_controllerListener!);
      _controllerListener = null;
    }
  }

  void _attachController() {
    _controllerListener = () {
      _cubit.select(widget.controller.status);
    };
    widget.controller.addListener(_controllerListener!);
    _cubit.select(widget.controller.status);
  }

  @override
  void dispose() {
    _detachController();
    _cubit.close();
    super.dispose();
  }

  void _handleSelection(AgentAvailabilityStatus status) {
    if (_cubit.state == status) return;

    _cubit.select(status);
    widget.controller.setStatus(status);
    widget.onStatusChanged(status);
  }

  @override
  Widget build(BuildContext context) {
    final currentBgColor = AppThemeUtilities.getCardColor(context);
    final textColor = AppThemeUtilities.getTextColor(context);
    final borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<StatusDropdownCubit, AgentAvailabilityStatus>(
        builder: (context, selectedStatus) {
          return PopupMenuButton<AgentAvailabilityStatus>(
            padding: EdgeInsets.zero,
            color: currentBgColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: _handleSelection,
            itemBuilder: (context) {
              final options = AgentAvailabilityStatus.values;
              return List.generate(options.length, (index) {
                final status = options[index];

                return PopupMenuItem<AgentAvailabilityStatus>(
                  value: status,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: status.color,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                status.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != options.length - 1)
                        Divider(height: 1, thickness: 1, color: borderColor),
                    ],
                  ),
                );
              });
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 6,
                  backgroundColor: selectedStatus.color,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    selectedStatus.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemeUtilities.appGreyBorderColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppThemeUtilities.appGreyBorderColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
