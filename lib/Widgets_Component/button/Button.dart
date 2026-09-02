import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/extentions/HexColor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  final Color textColor;
  final Color? color;
  final String imagePath;
  final bool isEnable;
  final bool showPrefix;
  final bool isImage;
  final bool? isBorderStyle;
  final IconData? icon;
  final bool isImageAssets;
  final ButtonStyle style;

  Button({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    this.color,
    this.isEnable = false,
    this.showPrefix = false,
    this.isImage = false,
    this.isImageAssets = true,
    this.isBorderStyle = false,
    this.imagePath = "",
    this.icon,
    ButtonStyle? style,
  }): style = style ?? _defaultStyle(color ?? AppThemeUtilities.appButtonBGColor);


  const Button.withCustomStyle({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.textColor,
    this.isEnable = false,
    this.showPrefix = false,
    this.isImage = false,
    this.isImageAssets = true,
    this.isBorderStyle = false,
    this.imagePath = "",
    this.icon,
    required this.style,
  });

  Button.withBorderStyle({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    this.color,
    this.isEnable = false,
    this.showPrefix = false,
    this.isImage = false,
    this.isImageAssets = true,
    this.isBorderStyle = true,
    this.imagePath = "",
    this.icon,
    ButtonStyle? style,
  }):style = style ?? _borderStyle(color ?? AppThemeUtilities.appButtonBGColor);

  const Button.withIconCustomStyle({
    super.key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    this.color,
    this.isEnable = false,
    this.showPrefix = false,
    this.isImage = false,
    this.isImageAssets = true,
    this.isBorderStyle = false,
    this.imagePath = "",
    required this.icon,
    required this.style,
  });

  Button.withImage({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.textColor,
    required this.showPrefix,
    required this.imagePath, 
    this.isEnable = false,
    this.isImage = true, 
    this.isImageAssets = true,
    this.isBorderStyle = false,
    this.icon,
    ButtonStyle? style,
  }): style = style ?? _defaultStyle(color!);

  Button.withIcon({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.textColor,
    required this.showPrefix,
    this.isEnable = false,
    this.imagePath = "",
    this.isImage = false, 
    this.isImageAssets = false,
    this.isBorderStyle = false,
    required this.icon,
    ButtonStyle? style,
  }): style = style ?? _defaultStyle(color!);


  static double borderRadius = 12;

  static ButtonStyle _defaultStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero, 
      fixedSize: const Size(double.maxFinite / 2, 50),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 0.9,
            color: backgroundColor
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ButtonStyle _borderStyle(Color borderColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero, 
      fixedSize: const Size(double.maxFinite / 2, 50),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 0.9,
          color: borderColor
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnable?onPressed:null,
      style: style,
      child: Ink(
        decoration: BoxDecoration(
          gradient: isBorderStyle! ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppThemeUtilities.whiteColor,
              AppThemeUtilities.whiteColor,
            ],
          ):
          isEnable
              ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color == null ? AppThemeUtilities.buttonBGGradientStartColor : color!,
              color == null ? AppThemeUtilities.buttonBGGradientEndColor : color!,
            ],
          )
              : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color == null ? HexColor.fromHex("#B6CDE0") : color!,
              color == null ? HexColor.fromHex("#B6CDE0") : color!,
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: isEnable? color ?? AppThemeUtilities.appButtonBGColor:AppThemeUtilities.HexToColor("#B6CDE0"), width: 1)
        ),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Visibility(
                    visible: showPrefix,
                    child: isImage?isImageAssets?Image.asset(imagePath, width: 24, height: 24,):Image.network(imagePath, width: 24, height: 24,):Icon(icon, color: textColor, size: 24,),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 0),
                    child: Text(
                      text,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isBorderStyle==true? isEnable?textColor:AppThemeUtilities.HexToColor("#B6CDE0"): textColor
                      ),
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}
