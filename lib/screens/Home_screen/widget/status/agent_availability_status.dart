import 'package:flutter/material.dart';

/// Agent availability options shown in [StatusDropdown].
enum AgentAvailabilityStatus {
  online('Online', 'ONLINE', Colors.green),
  away('Away', 'AWAY', Colors.orange);
  // busy('Busy', 'BUSY', Colors.red),
  // offline('Offline', 'OFFLINE', Colors.grey);

  const AgentAvailabilityStatus(this.label, this.apiValue, this.color);

  /// UI label, e.g. "Online".
  final String label;

  /// API / socket value, e.g. "ONLINE".
  final String apiValue;

  /// Status dot color in the dropdown.
  final Color color;

  /// Resolve from API profile value (`ONLINE`, `AWAY`, `Online`, etc.).
  static AgentAvailabilityStatus fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return online;

    final normalized = value.trim().toUpperCase();
    for (final status in values) {
      if (status.apiValue == normalized ||
          status.label.toUpperCase() == normalized) {
        return status;
      }
    }
    return online;
  }
}
