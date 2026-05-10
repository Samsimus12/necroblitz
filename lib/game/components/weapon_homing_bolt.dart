import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'monster.dart';
import 'projectile.dart';
import 'weapon.dart';

class WeaponHomingBolt extends Weapon {
  WeaponHomingBolt() : super(damage: 12, fireRate: 1.5);

  @override
  String get displayName => 'Tracking Dart';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    game.world.add(TrackingDart(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class TrackingDart extends Projectile {
  static const _turnRate = 3.0;
  late Vector2 _velocity;

  TrackingDart({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 220, damage: damage, size: 16) {
    _velocity = direction * 220;
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    Monster? nearest;
    double minDist = double.infinity;
    for (final m in game.world.children.whereType<Monster>()) {
      final d = m.position.distanceTo(position);
      if (d < minDist) { minDist = d; nearest = m; }
    }
    if (nearest != null) {
      final toTarget = (nearest.position - position).normalized();
      _velocity = (_velocity.normalized() + toTarget * (_turnRate * dt)).normalized() * speed;
    }

    position += _velocity * dt;
    lifetime += dt;

    final gs = game.size;
    if (lifetime > 5.0 || position.x < -60 || position.x > gs.x + 60 ||
        position.y < -60 || position.y > gs.y + 60) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) { other.takeDamage(damage); removeFromParent(); }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(_velocity.y, _velocity.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Exhaust / steering trail
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-7, 0), width: 14, height: 5),
      Paint()..color = const Color(0x559B59B6)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Dart body — elongated, dark purple with lighter shaft
    final bodyPath = Path()
      ..moveTo(8, 0)          // sharp tip
      ..lineTo(2, -2.5)
      ..lineTo(-5, -2)
      ..lineTo(-5, 2)
      ..lineTo(2, 2.5)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFF6A1B9A));

    // Syringe-style needle tip
    canvas.drawLine(
      const Offset(5, 0), const Offset(10, 0),
      Paint()..color = const Color(0xFFCCCCCC)..strokeWidth = 1.5..strokeCap = StrokeCap.round);

    // Shaft highlight
    canvas.drawLine(
      const Offset(-4, -1.0), const Offset(4, -1.0),
      Paint()..color = const Color(0x88CE93D8)..strokeWidth = 1.0);

    // Stabiliser fins at back
    final finPaint = Paint()..color = const Color(0xFF4A148C);
    // Top fin
    canvas.drawPath(Path()
      ..moveTo(-5, -2)
      ..lineTo(-9, -6)
      ..lineTo(-5, -1)
      ..close(), finPaint);
    // Bottom fin
    canvas.drawPath(Path()
      ..moveTo(-5, 2)
      ..lineTo(-9, 6)
      ..lineTo(-5, 1)
      ..close(), finPaint);

    // Purple glow core
    canvas.drawCircle(const Offset(0, 0), 3.5,
      Paint()..color = const Color(0x889B59B6)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    canvas.restore();
  }
}
