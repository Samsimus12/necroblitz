import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../necroblitz_game.dart';
import 'monster.dart';

class Projectile extends PositionComponent
    with HasGameReference<NecroblitzGame>, CollisionCallbacks {
  final Vector2 direction;
  final double speed;
  final double damage;
  double lifetime = 0;

  Projectile({
    required super.position,
    required this.direction,
    required this.speed,
    required this.damage,
    required double size,
  }) : super(size: Vector2.all(size), anchor: Anchor.center, priority: 2);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;
    lifetime += dt;

    final gs = game.size;
    if (lifetime > 3.0 ||
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
    super.onCollisionStart(intersectionPoints, other);
    if (other is Monster) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
