import 'dart:ui';

import 'package:berrytalks/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';

extension DesigantionStatusExtension on DesigantionStatus {


  static DesigantionStatus fromRoleString(String? role) {
    if (role == null) return DesigantionStatus.agent; 

    switch (role.toUpperCase()) {
      case 'ROLE_SUPERVISOR':
        return DesigantionStatus.teamLead; 
      case 'ROLE_ADMIN':
        return DesigantionStatus.seniorAgent; 
      case 'ROLE_AGENT':
        return DesigantionStatus.agent;
      default:
        return DesigantionStatus.agent; 
    }
  }

  String get title {
    switch (this) {
      case DesigantionStatus.seniorAgent:
        return "Admin";

      case DesigantionStatus.teamLead:
        return "Team Lead";

      case DesigantionStatus.agent:
        return "Agent";

      // case DesigantionStatus.facebook:
      //   return "Facebook";

      // case SocialPlatform.instagram:
      //   return "Instagram";

      // case SocialPlatform.sms:
      //   return "SMS";

      // case SocialPlatform.wechat:
      //   return "WeChat";
    }
  }

  Color get color {
    switch (this) {
      case DesigantionStatus.seniorAgent:
        return AppThemeUtilities.HexToColor("#25D466");

      case DesigantionStatus.teamLead:
        return AppThemeUtilities.HexToColor("#673AB6");

      case DesigantionStatus.agent:
        return AppThemeUtilities.HexToColor("#006efe");

      // case SocialPlatform.instagram:
      //   return AppThemeUtilities.HexToColor("#E5487C");

      // case SocialPlatform.sms:
      //   return AppThemeUtilities.HexToColor("#b0bbcd");

      // case SocialPlatform.wechat:
      //   return AppThemeUtilities.HexToColor("#080808");
    }
  }
}