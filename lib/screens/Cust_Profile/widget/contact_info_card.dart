import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class ContactInfoCard extends StatelessWidget {
  final String email;
  final String phone;
  final String location;

  const ContactInfoCard({
    super.key,
    required this.email,
    required this.phone,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
        final Color currentBgColor = AppThemeUtilities.getCardColor(context); 
    final Color textColor = AppThemeUtilities.getTextColor(context);
   // final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    return Container(
      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 20),

      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),

      decoration: BoxDecoration(
        color: currentBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontFamily: AppConstants.FontFamily_SFPro,
              fontSize: 15,
              fontWeight: AppConstants.FontWeight_Medium,
              color: textColor,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

            padding: const EdgeInsets.only(
              left: 0,
              top: 18,
              right: 0,
              bottom: 0,
            ),
          ),
          _buildInfoRow(Icons.mail_outline_rounded, 'Email', email, context),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

            padding: const EdgeInsets.only(
              left: 0,
              top: 16,
              right: 0,
              bottom: 0,
            ),
          ),
          _buildInfoRow(Icons.phone_outlined, 'Phone', phone, context),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

            padding: const EdgeInsets.only(
              left: 0,
              top: 16,
              right: 0,
              bottom: 0,
            ),
          ),
          _buildInfoRow(Icons.location_on_outlined, 'Location', location, context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
        final Color hintColor = AppThemeUtilities.getTimeColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        Container(
          margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

          padding: const EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              Container(
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),

                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: AppConstants.FontWeight_Medium,
                  color: hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
