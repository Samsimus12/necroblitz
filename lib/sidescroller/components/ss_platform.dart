import 'dart:ui';

import 'package:flame/components.dart';

class SsPlatform extends PositionComponent {
  SsPlatform({required super.position, required super.size})
      : super(priority: 1);

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Base concrete fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF3A2E22),
    );
    // Top edge highlight
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 3),
      Paint()..color = const Color(0xFF6A5A44),
    );
    // Seam lines
    final seam = Paint()
      ..color = const Color(0xFF2A2018)
      ..strokeWidth = 1;
    for (double x = 40; x < w; x += 40) {
      canvas.drawLine(Offset(x, 3), Offset(x, h), seam);
    }
  }
}
