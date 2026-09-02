import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class PermissionDeniedDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onContactSupport; 

  const PermissionDeniedDialog({
    super.key,
    required this.title,
    required this.message,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color statusColor = AppThemeUtilities.getStatusColor(context); 
    final Color currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color subtitleColor = AppThemeUtilities.getTimeColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: currentBgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: borderColor.withOpacity(0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppThemeUtilities.HexToColor("#000000").withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 20.0),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gpp_bad_rounded,
                color: statusColor,
                size: 40,
              ),
            ),

            Container(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 20,
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 28.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  
                  Container(
                    width: 12.0,
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                  ),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: statusColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onContactSupport ?? () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Get Help",
                        style: TextStyle(
                          color: AppThemeUtilities.HexToColor("#FFFFFF"),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
