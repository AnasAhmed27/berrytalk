import 'package:flutter/material.dart';


class HorizontalColorLoadingBar extends StatefulWidget {
  const HorizontalColorLoadingBar({super.key});

  static const Color green = Color(0xFF59BD7B);
  static const Color blue = Color(0xFF00599B);
  static const Color orange = Color(0xFFF5A623);

  @override
  State<HorizontalColorLoadingBar> createState() =>
      _HorizontalColorLoadingBarState();
}

class _HorizontalColorLoadingBarState extends State<HorizontalColorLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3.5, 
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HorizontalColorLoadingPainter(
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalColorLoadingPainter extends CustomPainter {
  _HorizontalColorLoadingPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.grey.withOpacity(0.08);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

   
    final double shift = animationValue * size.width * 2;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: const [
          HorizontalColorLoadingBar.green,
          HorizontalColorLoadingBar.blue,
          HorizontalColorLoadingBar.orange,
          HorizontalColorLoadingBar.green, 
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(
        Rect.fromLTWH(
          -size.width + shift, 
          0,
          size.width * 1.5,   
          size.height,
        ),
      );

    final double activeWidth = size.width;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, activeWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HorizontalColorLoadingPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}