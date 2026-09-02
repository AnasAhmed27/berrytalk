import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Enum/extensions.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class ConversationCard extends StatelessWidget {
  final String name;
  final String message;
  final SocialPlatform platform;
  final String time;
  final int unreadCount;
  final String status;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.name,
    required this.message,
    required this.platform,
    required this.time,
    required this.status,
    this.unreadCount = 0,
    required this.onTap,
  });

 String get initials {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      return "?"; 
    }

    List<String> parts = cleanedName.split(" ");
    
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    
    final int takeLength = cleanedName.length < 2 ? cleanedName.length : 2;
    return cleanedName.substring(0, takeLength).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color statusColor = AppThemeUtilities.getStatusColor(context);
    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 10,
          right: 20,
          bottom: 10,
        ),

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor),
          ),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 25,

                    backgroundColor: AppThemeUtilities.getAvatarBgColor(
                      context,
                    ),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: AppThemeUtilities.HexToColor("#16A249"),
                        fontWeight: AppConstants.FontWeight_Semibold,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -2.0,
                    right: -2.0,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 3.0,
                        bottom: 3.0,
                        left: 3.0,
                        right: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: currentBgColor, 
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        platform.iconPath, 
                        width: platform.iconSize, 
                        height: platform.iconSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: 10,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 10,
                      right: 0,
                      bottom: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: AppConstants.FontWeight_Medium,
                              fontSize: 16,
                              color: AppThemeUtilities.getTextColor(context),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 5,
                            top: 5,
                            right: 0,
                            bottom: 0,
                          ),
                          padding: const EdgeInsets.only(
                            left: 0,
                            top: 5,
                            right: 5,
                            bottom: 0,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: AppThemeUtilities.getTimeColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
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
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppThemeUtilities.getMessageColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      left: 10,
                      top: 5,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 3,
                      right: 10,
                      bottom: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: AppConstants.FontWeight_Bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (unreadCount > 0)
              Container(
                margin: EdgeInsets.only(left: 0, top: 15, right: 0, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 5,
                  top: 5,
                  right: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: AppThemeUtilities.HexToColor("#16a249"),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                  padding: const EdgeInsets.only(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: TextStyle(
                      color: AppThemeUtilities.HexToColor("#f8fcf9"),
                      fontSize: 14,
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
