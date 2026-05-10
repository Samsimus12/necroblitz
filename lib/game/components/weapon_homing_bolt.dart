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
    game.world.add(HomingBolt(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class HomingBolt extends Projectile {
  static const _turnRate = 3.0;

  late Vector2 _velocity;

  HomingBolt({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 220, damage: damage, size: 11) {
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
      if (d < minDist) {
        minDist = d;
        nearest = m;
      }
    }

    if (nearest != null) {
      final toTarget = (nearest.position - position).normalized();
      final newDir = (_velocity.normalized() + toTarget * (_turnRate * dt)).normalized();
      _velocity = newDir * speed;
    }

    position += _velocity * dt;
    lifetime += dt;

    final gs = game.size;
    if (lifetime > 5.0 ||
        position.x < -60 ||
        position.x > gs.x + 60 ||
        position.y < -60 ||
        position.y > gs.y + 60) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2 + 6,
      Paint()
        ..color = const Color(0x669B59B6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2,
      Paint()..color = const Color(0xFF9B59B6),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 4,
      Paint()..color = const Color(0xFFD7BDE2),
    );
  }
}
