import 'dart:ui';

import 'package:flame/components.dart';

import 'monster.dart';
import 'projectile.dart';
import 'weapon.dart';

class WeaponFrostShard extends Weapon {
  WeaponFrostShard() : super(damage: 10, fireRate: 1.2);

  @override
  String get displayName => 'Stun Grenade';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    game.world.add(FrostShard(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class FrostShard extends Projectile {
  FrostShard({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 280, damage: damage, size: 9);

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      other.takeDamage(damage);
      other.applySlow(0.4, 2.0);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2 + 5,
      Paint()
        ..color = const Color(0x5588D8F0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2,
      Paint()..color = const Color(0xFF88D8F0),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 3,
      Paint()..color = const Color(0xFFFFFFFF),
    );
  }
}
