import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class EditText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int? maxLine;
  final int? maxLength;
  final bool? isEnable;
  final bool? isisTextCapitalizationEnabled;
  final bool showLable;
  final double? lableFontSize;
  final bool? showSuffixIcon;
  final Widget? suffixIcon;
  final Widget? ontap;
  final bool? readOnly;
  final double? fontSize;
  final Color? filledColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool obscureText;

  GlobalKey<State<StatefulWidget>> keyValue =
      GlobalKey<State<StatefulWidget>>();
  EditText({
    super.key,
    required this.keyValue,
    required this.controller,
    this.label = "",
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLine,
    this.maxLength,
    this.readOnly,
    this.isisTextCapitalizationEnabled = false,
    required this.isEnable,
    this.showLable = false,
    this.lableFontSize = 16,
    this.showSuffixIcon = false,
    this.ontap,
    this.suffixIcon,
    this.textInputAction = TextInputAction.done,
    this.fontSize = 14,
    this.filledColor,
    this.textColor,
    this.textStyle,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
        final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final Color focusBorderColor = isDarkMode ? Colors.white70 : AppThemeUtilities.blackColor;
    final bool isFieldEnabled = isEnable ?? true;
    final bool isFieldReadOnly = readOnly ?? !isFieldEnabled;
    final bool shouldAllowInputStyle = isFieldEnabled || isFieldReadOnly;


final Color finalBgColor = filledColor ?? 
        (isFieldEnabled 
            ? AppThemeUtilities.appTextFieldFilledColor 
            : hintColor.withOpacity(0.1));
    return Wrap(
      children: [
        Visibility(
          visible: showLable,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: AppConstants.FontWeight_Medium,
                fontSize: lableFontSize ?? 16,
                color: textColor,
              ),
            ),
          ),
        ),
        TextField(
          onTap: () {
            ensureVisibleOnTextArea(textfieldKey: keyValue);
          },
          textCapitalization: isisTextCapitalizationEnabled!?TextCapitalization.characters:TextCapitalization.none,
          textInputAction: textInputAction,
          enabled: shouldAllowInputStyle,
          readOnly: isFieldReadOnly,
          //maxLines: maxLine,
          maxLines: obscureText ? 1 : maxLine,
          maxLength: maxLength,
          obscureText: obscureText,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          controller: controller,
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: textColor,
              fontSize: fontSize,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: hintColor,
              fontWeight: AppConstants.FontWeight_Regular,
              fontSize: fontSize,
            ),
            suffixIcon: showSuffixIcon! ? suffixIcon : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color:focusBorderColor,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: AppThemeUtilities.blackColor,
              ),
            ),
            contentPadding: const EdgeInsets.all(15),
            fillColor: finalBgColor,
            filled: true,
            counterText: "",
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          cursorColor: AppThemeUtilities.blackColor,
          style: textStyle ?? GoogleFonts.poppins(
            fontSize: fontSize,fontWeight: AppConstants.FontWeight_Medium,
            decorationColor: AppThemeUtilities.blackColor,
            color: textColor ?? AppThemeUtilities.blackColor,
          ),
        ),
      ],
    );
  }

  Future<void> ensureVisibleOnTextArea({
    required GlobalKey textfieldKey,
  }) async {
    final keyContext = textfieldKey.currentContext;
    if (keyContext != null) {
      await Future.delayed(const Duration(milliseconds: 500)).then(
        (value) => Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 200),
          curve: Curves.decelerate,
        ),
      );
      // Optional if doesnt work with the first
      // await Future.delayed(const Duration(milliseconds: 500)).then(
      //   (value) => Scrollable.ensureVisible(
      //     keyContext,
      //     duration: const Duration(milliseconds: 200),
      //     curve: Curves.decelerate,
      //   ),
      // );
    }
  }
}
