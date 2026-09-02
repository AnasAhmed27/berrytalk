import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class ConversationTeamCard extends StatelessWidget {
  final String name;
  final String designation;
  final Color statusColor;
  final VoidCallback? onTap;

  const ConversationTeamCard({
    super.key,
    required this.name,
    required this.designation,
    required this.statusColor,
    this.onTap,
  });

String get initials {
    if (name.trim().isEmpty) return "?";

    List<String> parts = name.trim().split(RegExp(r'\s+'));
    
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    
    if (name.trim().length >= 2) {
      return name.trim().substring(0, 2).toUpperCase();
    }
    return name.trim().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color designationColor = AppThemeUtilities.getdesignationColor(
      context,
    );

    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.black12,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
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
                    backgroundColor: AppThemeUtilities.getAvatarBgColor(context),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: AppThemeUtilities.HexToColor("#16A249"),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: currentBgColor,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: statusColor,
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
                    margin: const EdgeInsets.only(
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
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    child: Text(
                      designation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: designationColor, fontSize: 14),
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