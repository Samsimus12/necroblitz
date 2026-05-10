import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'projectile.dart';
import 'weapon.dart';

class WeaponRapidFire extends Weapon {
  WeaponRapidFire() : super(damage: 9, fireRate: 4.0);

  @override
  String get displayName => 'Machine Gun';

  @override
  String get nextUpgradeDescription => 'Fire rate +20%';

  @override
  void applyUpgrade() {
    upgradeLevel++;
    fireRate *= 1.2;
  }

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    game.world.add(TracerRound(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class TracerRound extends Projectile {
  TracerRound({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 420, damage: damage, size: 16);

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final angle = math.atan2(direction.y, direction.x);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Hot tracer glow trail
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-7, 0), width: 20, height: 4),
      Paint()..color = const Color(0x66FF4400)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Tracer core — long thin round
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 3),
        const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFFF6622));

    // Bright tip
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(6, 0), width: 5, height: 3),
      Paint()..color = const Color(0xFFFFCC44));

    canvas.restore();
  }
}
