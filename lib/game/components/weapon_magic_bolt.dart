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
    game.world.add(MagicBolt(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

// ── Projectile ───────────────────────────────────────────────────────────────

class MagicBolt extends Projectile {
  final Color color;

  MagicBolt({
    required super.position,
    required super.direction,
    required double damage,
    this.color = const Color(0xFF00E5FF),
    double speed = 300,
    double boltSize = 10,
  }) : super(speed: speed, damage: damage, size: boltSize);

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2 + 5,
      Paint()
        ..color = color.withAlpha(85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2,
      Paint()..color = color,
    );
  }
}
