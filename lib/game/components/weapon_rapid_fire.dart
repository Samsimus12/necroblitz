import 'dart:ui';

import 'package:flame/components.dart';

import 'weapon.dart';
import 'weapon_magic_bolt.dart';

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
    game.world.add(MagicBolt(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
      color: const Color(0xFFFF6B35),
      speed: 350,
      boltSize: 7,
    ));
  }
}
