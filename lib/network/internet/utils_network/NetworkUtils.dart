import 'dart:io';

import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/network/ApiConfig.dart';

class NetworkUtils {
  static const int restrictedNetworkCode = 999;
  static const int fatalExceptionCode = 8113;
  static Future<bool> isServerReachable() async {
    try {
      final result = await InternetAddress.lookup(ApiConfig.hostName)
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; 
      }
      return false;
    } catch (_) {
      return false; 
    }
  }

  
static String get restrictedNetworkMessage {
    return AppUtilities.apiStatusCodeTitleMsg(restrictedNetworkCode)["msg"] ?? "";
  }
}