import 'package:berrytalks/Widgets_Component/EditText.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditText(
          keyValue: GlobalKey(),
          controller: controller,
          label: "Email",
          hintText: "agent@berrytalks.com",
          keyboardType: TextInputType.emailAddress,
          showLable: true,
          maxLine: 1,
          isEnable: true,
          filledColor: cardColor,
          textColor: textColor,
          fontSize: 14,
        ),
      ],
    );
  }
}
