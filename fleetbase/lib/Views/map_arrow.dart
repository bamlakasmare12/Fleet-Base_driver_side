import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  final Color color;
  final double size;

  const ArrowPainter({
    this.color = Colors.blue,
    this.size = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.75);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ArrowPainter) {
      return oldDelegate.color != color || oldDelegate.size != size;
    }
    return false;
  }
}