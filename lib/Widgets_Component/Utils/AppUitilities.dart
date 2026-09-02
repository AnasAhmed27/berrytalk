import 'dart:ui';

import 'package:berrytalks/Widgets_Component/Enum/LoggingType.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';

import '../../main.dart';
import '../../services/storage/SharedPrefrences.dart';

class AppUtilities {
    

  // ================= SUCCESS SNACKBAR =================

static void showSuccessSnackBar(BuildContext context, {required String title, required String message, IconData icon = Icons.check_circle,}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);

    if (messenger == null) return;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Container(
          margin: const EdgeInsets.only(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
          ),
          padding: const EdgeInsets.only(
            left: 15,
            top: 15,
            right: 15,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.9),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.green, size: 22),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 15,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      
                      Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


// ================= LOGOUT DIALOG =================

  static Future<void> logOut({required BuildContext context, required String msg, required VoidCallback onLogOut,}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "LogoutDialog",
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: AlertDialog(
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            16,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 20,
                  right: 0,
                  bottom: 0,
                ),
              ),

              const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 10,
                  right: 0,
                  bottom: 0,
                ),
              ),

              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).hintColor.withOpacity(0.7),
                  height: 1.4,
                ),
              ),

              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 24,
                  right: 0,
                  bottom: 0,
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                  ),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: onLogOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Yes, Log out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

static Future<void> autoLogOut({required int statusCode, required VoidCallback onLogOut,}) async{
  if (statusCode == 401 || statusCode == 403 || statusCode == 404){
    await SharedPrefData.saveIsUserLogin(false);
    await SharedPrefData.saveUserPassword("");

    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(LOGIN_ROUTE);
      onLogOut.call();
    }
  }
}

  // ================= ERROR SNACKBAR =================

  static void showErrorSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.error,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);

    if (messenger == null) return;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       // behavior: SnackBarBehavior.floating,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),

        content: Container(
           margin: EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                        right: 10,
                        bottom: 10,
                      ),

          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.10),

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: Colors.red.withOpacity(0.9), width: 1.2),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Icon(icon, color: Colors.red, size: 22),

             Container(
                margin: const EdgeInsets.only(
                  left: 10, 
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
              ),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                   Container(
                      margin: const EdgeInsets.only(
                        left: 0, 
                        top: 3, 
                        right: 0, 
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0, 
                        top: 0, 
                        right: 0, 
                        bottom: 0,
                      ),
                    ),

                    Text(
                      message,
                      style:  TextStyle(
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOADING DIALOG =================

  static Future<void> showLoadingDialog(BuildContext context) async {
    showGeneralDialog(
      context: context,

      barrierDismissible: false,

      barrierLabel: "Loader",

      barrierColor: Colors.black.withOpacity(0.20),

      transitionDuration: const Duration(milliseconds: 800),

      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,

          child: Scaffold(
            backgroundColor: Colors.transparent,

            body: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),

              child: Container(
                color: Colors.black.withOpacity(0.15),

                child: Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.green,
                    secondRingColor: Colors.orange,
                    thirdRingColor: Colors.blue,
                    size: 55,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //================= LOGGING TYPE ===============================

   static void appLogging({String? tag, required LoggingType type, required String message, StackTrace? stackTrace, Object? error}){
    if(kDebugMode){
      var logger = Logger();
      switch(type){
        case LoggingType.info:
          logger.i("${tag??"OkHttp"}: $message",stackTrace: stackTrace);
          break;
        case LoggingType.warning:
          logger.w("${tag??"OkHttp"}: $message", stackTrace: stackTrace);
          break;
        case LoggingType.error:
          if(stackTrace != null){
            logger.e("${tag??"OkHttp"}: $message", error: error, stackTrace: stackTrace);
          }else{
            logger.e("${tag??"OkHttp"}: $message", error: error);
          }
          break;
        case LoggingType.verbose:
          logger.t("${tag??"OkHttp"}: $message",stackTrace: stackTrace);
          break;
        case LoggingType.debug:
          logger.d("${tag??"OkHttp"}: $message",stackTrace: stackTrace);
          break;
      }
    }
  }

  //================== ERROR TYPE =======================================

  
  static Map<String, dynamic> apiStatusCodeTitleMsg(int code) {
    switch (code) {
      case 200:
        return {"Title": "Success", "msg": "Your request was successful."};
      case 201:
        return {"Title": "Resource Created", "msg": "The resource has been created successfully."};
      case 204:
        return {"Title": "No Content", "msg": "The request was successful, but there is no content to return."};
      case 400:
        return {"Title": "Bad Request", "msg": "Your request was invalid. Please check your input and try again."};
      case 401:
      case 403:
        return {"Title": "Unauthorized", "msg": "You do not have permission or your session has expired."};
      case 404:
        return {"Title": "Data Not Found", "msg": "The requested resource could not be found on the server."};
      case 419:
        return {"Title": "Session Expired", "msg": "Your session has expired. Please send a new request and try again."};
      case 422:
        return {"Title": "Validation Error", "msg": "The server understood your request, but validation failed."};
      case 3118:
        return {"Title": "No Internet Connection", "msg": "No Internet Connection detected. Please check your socket/wi-fi connection."};
      case 500:
      default:
        return {"Title": "Server Error", "msg": "Something went wrong with the API Response. Code: $code"};
    }
  }



  //================ HIDE KEYBOARD =============================
    static void hideKeyboard(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    // FocusScopeNode currentFocus = FocusScope.of(context);
    
    // if (!currentFocus.hasPrimaryFocus) {
    //   currentFocus.unfocus();
    // }
  }

  //=============== EMAIL PATTERN ============================

  static bool isEmailValid(String email) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return regex.hasMatch(email.trim().toLowerCase()); 
  }

  //================= PASSOWRD PATTERN =============================

  static bool isPasswordValid(String password) {
    const pattern = r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$&*]).{8,}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  //================== DATE GROUPING ================================
  String getGroupDateLabel(String dateStr) {
  try {
    // Agar aapka date format ISO string hai to DateTime.parse chal jaye ga
    DateTime msgDate = DateTime.parse(dateStr).toLocal();
    DateTime now = DateTime.now();
    
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime compareDate = DateTime(msgDate.year, msgDate.month, msgDate.day);

    if (compareDate == today) {
      return "Today";
    } else if (compareDate == yesterday) {
      return "Yesterday";
    } else {
      // Custom format: 12 July 2026
      const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      return "${msgDate.day} ${months[msgDate.month - 1]} ${msgDate.year}";
    }
  } catch (e) {
    return dateStr; // Fallback agar parse na ho sake
  }
}
}


