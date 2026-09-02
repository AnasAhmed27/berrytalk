import 'package:berrytalks/Widgets_Component/Buttons/RippleButton.dart';
import 'package:berrytalks/Widgets_Component/Email_feild/EmailFeildText.dart';
import 'package:berrytalks/Widgets_Component/Password_feild/PasswordFeildText.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class LoginCredentialsCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;

  const LoginCredentialsCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color subtitleColor = AppThemeUtilities.getTimeColor(context);

    return Container(
      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      padding: const EdgeInsets.only(left: 20, top: 25, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: borderColor, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: Text(
              "Sign in to your account",
              style: TextStyle(
                fontFamily: AppConstants.FontFamily_SFPro,
                color: textColor,
                fontWeight: AppConstants.FontWeight_Bold,
                fontSize: 22,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: Text(
              "Enter your credentials to continue",
              style: TextStyle(
                fontWeight: AppConstants.FontWeight_Medium,
                fontFamily: AppConstants.FontFamily_SFPro,
                fontSize: 16,
                color: subtitleColor,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: EmailInputField(controller: emailController),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: PasswordInputField(controller: passwordController),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 20, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: RippleButton(
              onPressed: onLoginPressed,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                padding: EdgeInsets.only(
                  left: 0,
                  top: 12,
                  right: 0,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: AppThemeUtilities.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontFamily: AppConstants.FontFamily_SFPro,
                    fontSize: 16,
                    fontWeight: AppConstants.FontWeight_Medium,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
