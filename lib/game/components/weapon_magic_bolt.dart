import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'projectile.dart';
import 'weapon.dart';

// ── Weapon ──────────────────────────────────────────────────────────────────

class WeaponMagicBolt extends Weapon {
  WeaponMagicBolt() : super(damage: 15, fireRate: 2.0);

  @override
  String get displayName => 'Pistol';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    game.world.add(PistolBullet(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

// ── Projectile ───────────────────────────────────────────────────────────────

class PistolBullet extends Projectile {
  PistolBullet({
    required super.position,
    required super.direction,
    required double damage,
    double speed = 320,
    double boltSize = 14,
  }) : super(speed: speed, damage: damage, size: boltSize);

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Motion blur trail
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, 0), width: 14, height: 4),
      Paint()..color = const Color(0x33FFCC44)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Brass casing — main bullet body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 13, height: 5),
      Paint()..color = const Color(0xFFB8962E));

    // Bullet tip (ogive) — slightly lighter, pointed right
    final tipPath = Path()
      ..moveTo(2, -2.2)
      ..lineTo(7, 0)
      ..lineTo(2, 2.2)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFFD4AF50));

    // Highlight streak on top of casing
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-1, -1.0), width: 8, height: 1.5),
      Paint()..color = const Color(0x88FFE580));

    canvas.restore();
  }
}

// Used by nova burst — renders as a glowing energy bolt in the given color.
class MagicBolt extends PistolBullet {
  final Color color;

  MagicBolt({
    required super.position,
    required super.direction,
    required double damage,
    this.color = const Color(0xFF00E5FF),
    double speed = 320,
    double boltSize = 14,
  }) : super(damage: damage, speed: speed, boltSize: boltSize);

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Outer glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 18, height: 8),
      Paint()..color = color.withAlpha(80)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Energy bolt body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 5),
      Paint()..color = color);

    // Bright core
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 8, height: 3),
      Paint()..color = const Color(0xFFFFFFFF).withAlpha(180));

    canvas.restore();
  }
}
