import 'package:berrytalks/Widgets_Component/EditText.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordInputField({super.key, required this.controller});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  final GlobalKey _passwordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditText(
          keyValue: _passwordKey,
          controller: widget.controller,
          label: "Password",
          hintText: "********",
          obscureText: _obscureText,
          showLable: true,
          isEnable: true,
          filledColor: cardColor,
          textColor: textColor,
          showSuffixIcon: true,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppThemeUtilities.appgreyColor,
            ),
          ),
        ),
      ],
    );
  }
}
