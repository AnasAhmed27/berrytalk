import 'package:bloc/bloc.dart';

import 'agent_availability_status.dart';

/// Local state for [StatusDropdown]. Rebuilds only this widget subtree —
/// no [State.setState] on the parent screen.
class StatusDropdownCubit extends Cubit<AgentAvailabilityStatus> {
  StatusDropdownCubit(AgentAvailabilityStatus initial) : super(initial);

  void select(AgentAvailabilityStatus status) {
    if (state == status) return;
    emit(status);
  }
}
