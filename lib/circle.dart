import 'package:flutter/material.dart';
import 'constants.dart';

class Circle {
  Offset position;
  double _radius;
  double radius;

  Circle({this.position, this.radius}) : _radius = radius;

  void draw(Path path, Offset currentPosition) {
    double distance = (currentPosition - position).distance;
    double normalizeDistance = (distance - radius) / PROXIMITY;
    double growthValue = GROWTH_VALUE - GROWTH_VALUE * normalizeDistance;
    if (growthValue < ITEM_SIZE) growthValue = 0.1;

    radius += (_radius + growthValue - radius) * EASING;
    path.addOval(Rect.fromCircle(center: position, radius: radius));
  }
}