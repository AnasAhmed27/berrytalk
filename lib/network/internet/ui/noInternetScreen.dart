import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);

    return Scaffold(
      backgroundColor: currentBgColor,
      body: Container(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 40.0,
          bottom: 40.0,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 100,
                color: Colors.redAccent,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "Connection Lost!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(
                bottom: 40.0,
                left: 10.0,
                right: 10.0,
              ),
              child: const Text(
                "Oops, it looks like you're offline! Please check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: onRetry,
                child: const Text(
                  "Retry Connection",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
