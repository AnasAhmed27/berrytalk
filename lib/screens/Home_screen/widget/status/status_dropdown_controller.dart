import 'package:flutter/foundation.dart';

import 'agent_availability_status.dart';

/// Controls [StatusDropdown] from outside the widget tree (similar to
/// [TextEditingController]).
///
/// Example:
/// ```dart
/// final controller = StatusDropdownController();
/// StatusDropdown(controller: controller, onStatusChanged: (s) { ... });
/// controller.setStatus(AgentAvailabilityStatus.away);
/// controller.setStatusFromApi('AWAY');
/// ```
class StatusDropdownController extends ChangeNotifier {
  StatusDropdownController({AgentAvailabilityStatus? initialStatus})
      : _status = initialStatus ?? AgentAvailabilityStatus.online;

  AgentAvailabilityStatus _status;

  AgentAvailabilityStatus get status => _status;

  /// Set status using the enum (preferred).
  void setStatus(AgentAvailabilityStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  /// Set status from an API string, e.g. `"AWAY"`.
  void setStatusFromApi(String? apiValue) {
    setStatus(AgentAvailabilityStatus.fromApi(apiValue));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
