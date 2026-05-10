import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'weapon.dart';
import 'weapon_magic_bolt.dart';

class WeaponSpreadShot extends Weapon {
  WeaponSpreadShot() : super(damage: 10, fireRate: 1.5);

  @override
  String get displayName => 'Shotgun';

  @override
  String get nextUpgradeDescription => 'Damage +30%';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    for (final angle in [-0.35, 0.0, 0.35]) {
      game.world.add(MagicBolt(
        position: playerPos.clone(),
        direction: _rotate(direction, angle),
        damage: damage,
        color: const Color(0xFFF4A800),
        boltSize: 8,
      ));
    }
  }

  Vector2 _rotate(Vector2 v, double rad) {
    final c = math.cos(rad);
    final s = math.sin(rad);
    return Vector2(v.x * c - v.y * s, v.x * s + v.y * c);
  }
}
