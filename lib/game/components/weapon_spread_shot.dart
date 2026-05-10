import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'projectile.dart';
import 'weapon.dart';

class WeaponSpreadShot extends Weapon {
  WeaponSpreadShot() : super(damage: 10, fireRate: 1.5);

  @override
  String get displayName => 'Shotgun';

  @override
  String get nextUpgradeDescription => 'Damage +30%';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    for (final angle in [-0.30, -0.10, 0.10, 0.30]) {
      game.world.add(ShotgunPellet(
        position: playerPos.clone(),
        direction: _rotate(direction, angle),
        damage: damage * 0.65,
      ));
    }
    // Centre shot at full damage
    game.world.add(ShotgunPellet(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }

  Vector2 _rotate(Vector2 v, double rad) {
    final c = math.cos(rad);
    final s = math.sin(rad);
    return Vector2(v.x * c - v.y * s, v.x * s + v.y * c);
  }
}

class ShotgunPellet extends Projectile {
  ShotgunPellet({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 360, damage: damage, size: 9);

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Short powder burn / muzzle trail
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-4, 0), width: 9, height: 3),
      Paint()..color = const Color(0x44FF8800)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Lead pellet — slightly flattened sphere
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 7, height: 6),
      Paint()..color = const Color(0xFF888880));

    // Highlight
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0.5, -1.0), width: 3, height: 2),
      Paint()..color = const Color(0x88CCCCCC));

    canvas.restore();
  }
}
