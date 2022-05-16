import 'package:flutter/material.dart';

import 'package:dayplan_it/constants.dart';

class DrawTriangleShape extends CustomPainter {
  late Paint painter;
  final Color fillColor;

  DrawTriangleShape({this.fillColor = primaryColor}) {
    painter = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
