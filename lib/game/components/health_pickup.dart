import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../necroblitz_game.dart';
import 'player.dart';

class HealthPickup extends PositionComponent
    with HasGameReference<NecroblitzGame>, CollisionCallbacks {
  static const double healAmount = 30.0;
  static const double _lifetime = 8.0;

  double _timer = 0;
  double _pulse = 0;

  HealthPickup({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(28),
          anchor: Anchor.center,
          priority: 2,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    _pulse += dt * 4.0;
    if (_timer >= _lifetime) removeFromParent();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      other.addHp(healAmount);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final remaining = (1.0 - _timer / _lifetime).clamp(0.0, 1.0);
    final pulse = math.sin(_pulse) * 0.15 + 0.85;
    final alpha = (remaining * pulse * 220).toInt().clamp(0, 255);
    final r = size.x / 2;
    final center = Offset(r, r);

    // Outer glow
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Color.fromARGB(alpha ~/ 3, 0, 230, 100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Outer ring
    canvas.drawCircle(
      center,
      r * 0.88,
      Paint()
        ..color = Color.fromARGB(alpha, 0, 230, 100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      r * 0.55,
      Paint()
        ..color = Color.fromARGB((alpha * 0.7).toInt(), 100, 255, 160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Cross (health symbol)
    final crossPaint = Paint()
      ..color = Color.fromARGB(alpha, 180, 255, 210)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final cr = r * 0.28;
    canvas.drawLine(Offset(r, r - cr), Offset(r, r + cr), crossPaint);
    canvas.drawLine(Offset(r - cr, r), Offset(r + cr, r), crossPaint);
  }
}
