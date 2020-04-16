import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'circle.dart';

class CirclePainter extends CustomPainter {
  Offset currentPosition;
  List<Circle> circles;
  ui.Image maskImage;

  CirclePainter({this.circles, this.currentPosition, this.maskImage});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    for (var i = 0; i < circles.length; i++) {
      circles[i].draw(path, currentPosition);
    }
    canvas.clipPath(path);

    canvas.drawImageRect(
        maskImage,
        Rect.fromLTRB(
            0.0, 0.0, maskImage.width.toDouble(), maskImage.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}