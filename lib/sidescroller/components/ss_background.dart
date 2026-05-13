import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../sidescroller_game.dart';

class SsBackground extends Component with HasGameReference<SidescrollerGame> {
  // Precomputed building rects for the full world (stored as relative heights)
  final List<_Building> _far = [];
  final List<_Building> _mid = [];

  SsBackground() : super(priority: -100);

  @override
  void onMount() {
    super.onMount();
    _precompute();
  }

  void _precompute() {
    final h = game.size.y;
    final groundY = h - 64;

    // Far layer
    final rng1 = math.Random(42);
    double x = 0;
    while (x < SidescrollerGame.kWorldWidth + 60) {
      final bw = rng1.nextDouble() * 45 + 18;
      final bh = rng1.nextDouble() * h * 0.22 + h * 0.10;
      _far.add(_Building(x, groundY - bh - 20, bw, bh));
      x += bw + rng1.nextDouble() * 12 + 2;
    }

    // Mid layer
    final rng2 = math.Random(77);
    x = 0;
    while (x < SidescrollerGame.kWorldWidth + 60) {
      final bw = rng2.nextDouble() * 32 + 12;
      final bh = rng2.nextDouble() * h * 0.12 + h * 0.05;
      _mid.add(_Building(x, groundY - bh - 5, bw, bh));
      x += bw + rng2.nextDouble() * 8 + 1;
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = game.camera.viewfinder.position.x;
    final w = game.size.x;
    final h = game.size.y;
    final groundY = h - 64;

    // Sky
    canvas.drawRect(Rect.fromLTWH(cx, 0, w, groundY + 4),
        Paint()..color = const Color(0xFF070711));

    // Moon
    canvas.drawCircle(Offset(cx + w * 0.82, h * 0.11), 20,
        Paint()..color = const Color(0xFFE8E0C0));
    canvas.drawCircle(Offset(cx + w * 0.82, h * 0.11), 28,
        Paint()
          ..color = const Color(0x22E8E0C0)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Clouds / haze
    _drawHaze(canvas, cx, w, h);

    // Far silhouette (parallax 0.12)
    final farPaint = Paint()..color = const Color(0xFF0A0D14);
    _drawLayer(canvas, _far, cx, cx * 0.12, farPaint);

    // Mid ruins (parallax 0.30)
    final midPaint = Paint()..color = const Color(0xFF0F1318);
    _drawLayer(canvas, _mid, cx, cx * 0.30, midPaint);

    // Ground fill (below platforms)
    canvas.drawRect(Rect.fromLTWH(cx, groundY, w, h - groundY),
        Paint()..color = const Color(0xFF100E0A));
  }

  void _drawLayer(Canvas canvas, List<_Building> layer, double cx,
      double parallaxScroll, Paint paint) {
    // parallaxScroll is how far the layer has moved relative to the world
    // Building world x adjusted for parallax: bx - (bx * factor) = bx * (1 - factor)
    // We need: screen_x = bx * (1 - factor) - cx * (1 - factor) + cx = bx * (1-f) + cx * f
    // Simpler: shift each building by -(parallaxScroll - cx) relative to real world position
    //   actual canvas x = bx - parallaxScroll (parallax offset applied)
    //   then it will appear at screen x = (bx - parallaxScroll) - cx + cx = bx - parallaxScroll
    // Wait — canvas coords in world space: drawing at canvas x X appears at screen x = X - cx
    // So to appear at screen x = s, draw at canvas x = s + cx
    // For parallax layer: screen x of building = (bx) - parallaxScroll
    // So draw at canvas x = (bx - parallaxScroll) + cx = bx + cx - parallaxScroll

    final offset = cx - parallaxScroll; // shift to apply to each building's x
    final visLeft = cx - 60;
    final visRight = cx + game.size.x + 60;

    for (final b in layer) {
      final drawX = b.x + offset;
      if (drawX + b.w < visLeft) continue;
      if (drawX > visRight) break;
      canvas.drawRect(Rect.fromLTWH(drawX, b.y, b.w, b.h), paint);
    }
  }

  void _drawHaze(Canvas canvas, double cx, double w, double h) {
    final rng = math.Random(99);
    final hazePaint = Paint()..color = const Color(0x06A0B0FF);
    for (int i = 0; i < 6; i++) {
      final hx = cx + rng.nextDouble() * w;
      final hy = rng.nextDouble() * h * 0.6;
      final hw = rng.nextDouble() * 80 + 40;
      final hh = rng.nextDouble() * 16 + 8;
      canvas.drawOval(Rect.fromLTWH(hx, hy, hw, hh), hazePaint);
    }
  }
}

class _Building {
  final double x, y, w, h;
  const _Building(this.x, this.y, this.w, this.h);
}
