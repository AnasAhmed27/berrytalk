import 'package:flutter/material.dart';

enum UserStatus {
  online,
  offline,
}

extension UserStatusExtension on UserStatus {
  static UserStatus fromString(String? status) {
    if (status == null) return UserStatus.offline;
    
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return UserStatus.online;
      case 'OFFLINE':
        return UserStatus.offline;
      default:
        return UserStatus.offline;
    }
  }

  Color get statusColor {
    switch (this) {
      case UserStatus.offline:
        return Colors.grey.shade400;
      case UserStatus.online:
        return const Color(0xFF25D466); 
    }
  }
}