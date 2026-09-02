import 'package:flutter/material.dart';

import '../extentions/HexColor.dart';

class RippleButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  final Color? rippleColor;
  final EdgeInsets padding;
  const RippleButton({super.key,
    required this.onPressed,
    required this.child,
    this.rippleColor,
    this.padding = const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
  });

  static Color _defaultRippleColor(){
    return HexColor.fromHex("#B6CDE0").withValues(alpha: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, 
      child: InkWell(
        onTap: onPressed,
        overlayColor: WidgetStateProperty.all(onPressed!=null?(rippleColor ?? _defaultRippleColor()):Colors.transparent),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
