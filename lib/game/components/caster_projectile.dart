import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'player.dart';
import 'projectile.dart';

class CasterProjectile extends Projectile {
  CasterProjectile({
    required super.position,
    required super.direction,
  }) : super(speed: 220, damage: 12, size: 12);

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Bile splatter trail
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, 0), width: 14, height: 7),
      Paint()..color = const Color(0x4444BB00)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Main bile blob — elongated in travel direction
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(1, 0), width: 12, height: 9),
      Paint()..color = const Color(0xFF2A7A00));

    // Bright core
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(2, 0), width: 7, height: 5),
      Paint()..color = const Color(0xFF66DD00));

    // Highlight droplet
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(3, -1.5), width: 3, height: 2),
      Paint()..color = const Color(0x88AAFFAA));

    // Drip at the back
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, 1), width: 4, height: 4),
      Paint()..color = const Color(0xFF226600));

    canvas.restore();
  }
}
