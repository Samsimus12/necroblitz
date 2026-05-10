import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../necroblitz_game.dart';
import 'player.dart';

class ShieldPickup extends PositionComponent
    with HasGameReference<NecroblitzGame>, CollisionCallbacks {
  static const double shieldAmount = 50.0;
  static const double _lifetime = 8.0;

  double _timer = 0;
  double _pulse = 0;

  ShieldPickup({required Vector2 position})
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
      other.addShield(shieldAmount);
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
        ..color = Color.fromARGB(alpha ~/ 3, 0, 229, 255)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Outer ring
    canvas.drawCircle(
      center,
      r * 0.88,
      Paint()
        ..color = Color.fromARGB(alpha, 0, 229, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Inner ring
    canvas.drawCircle(
      center,
      r * 0.55,
      Paint()
        ..color = Color.fromARGB((alpha * 0.7).toInt(), 100, 240, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Center dot
    canvas.drawCircle(
      center,
      r * 0.2,
      Paint()..color = Color.fromARGB(alpha, 180, 248, 255),
    );
  }
}
