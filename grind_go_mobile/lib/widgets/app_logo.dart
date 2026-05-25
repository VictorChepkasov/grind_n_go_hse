import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Стилизованный логотип (заглушка под mascotte из макета).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(),
        child: Center(
          child: Icon(
            Icons.local_cafe_rounded,
            size: size * 0.28,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = AppColors.error;
    final w = size.width;
    final h = size.height;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.22, w * 0.7, h * 0.55),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(body, bodyPaint);

    canvas.drawCircle(
      Offset(w * 0.28, h * 0.78),
      w * 0.09,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.78),
      w * 0.09,
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
