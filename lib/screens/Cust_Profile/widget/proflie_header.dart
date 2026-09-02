import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final List<String> tags;
  const ProfileHeader({super.key, required this.name, required this.tags});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = AppThemeUtilities.getTextColor(context);

    final Color avatarColor = AppThemeUtilities.getAvatarBgColor(context);
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 20),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 50,
              top: 50,
              right: 50,
              bottom: 50,
            ),

            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 10),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: AppConstants.FontWeight_MediumItalic,
              color: textColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 4, right: 0, bottom: 10),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: tags
                .map(
                  (tag) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentBgColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: AppConstants.FontWeight_Medium,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
