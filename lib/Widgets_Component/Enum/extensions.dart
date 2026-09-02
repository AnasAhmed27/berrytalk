import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';

extension SocialPlatformExtension on SocialPlatform {

  String get title {
    switch (this) {
      case SocialPlatform.whatsapp:
        return "WhatsApp";

      case SocialPlatform.email:
        return "Email";

      case SocialPlatform.facebook:
        return "Facebook";

      case SocialPlatform.instagram:
        return "Instagram";

      case SocialPlatform.sms:
        return "SMS";

      case SocialPlatform.wechat:
        return "WeChat";

      case SocialPlatform.twitter:
        return "twitter";
    }
  }

  String get iconPath {
    switch (this) {
      case SocialPlatform.whatsapp:
        return AppImages.whatsapp;

      case SocialPlatform.email:
        return AppImages.email;

      case SocialPlatform.facebook:
        return AppImages.messenger;

      case SocialPlatform.instagram:
        return AppImages.ig;

      case SocialPlatform.sms:
        return AppImages.sms;

      case SocialPlatform.wechat:
        return AppImages.wechat;

      case SocialPlatform.twitter:
        return AppImages.twitter;
    }
  }

  double get iconSize {
    switch (this) {
      case SocialPlatform.whatsapp:
        return 15;

      case SocialPlatform.email:
        return 15;

      case SocialPlatform.facebook:
        return 15;

      case SocialPlatform.instagram:
        return 15;

      case SocialPlatform.sms:
        return 15;

      case SocialPlatform.wechat:
        return 15; 

      case SocialPlatform.twitter:
      return 15;
    }
  }
}