import 'dart:ui';

import 'package:flame/components.dart';

import 'monster.dart';
import 'projectile.dart';
import 'weapon.dart';

class WeaponExplosiveBolt extends Weapon {
  WeaponExplosiveBolt() : super(damage: 25, fireRate: 0.8);

  @override
  String get displayName => 'Frag Grenade';

  @override
  bool get isUpgradeable => false;

  @override
  String get nextUpgradeDescription => 'Blast damage +30%';

  @override
  void fire(Vector2 playerPos, Vector2 direction) {
    game.world.add(ExplosiveBolt(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class ExplosiveBolt extends Projectile {
  static const _aoeRadius = 80.0;

  ExplosiveBolt({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 250, damage: damage, size: 13);

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      for (final m in game.world.children.whereType<Monster>()) {
        if (m.position.distanceTo(position) <= _aoeRadius) {
          m.takeDamage(damage);
        }
      }
      game.world.add(AoeBlast(position: position.clone(), radius: _aoeRadius));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2 + 7,
      Paint()
        ..color = const Color(0x66FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 2,
      Paint()..color = const Color(0xFFFF8C00),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.x / 3.5,
      Paint()..color = const Color(0xFFFFD700),
    );
  }
}

class AoeBlast extends PositionComponent {
  static const _duration = 0.35;

  final double radius;
  double _elapsed = 0;

  AoeBlast({required super.position, required this.radius})
      : super(size: Vector2.zero(), anchor: Anchor.center, priority: 2);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / _duration).clamp(0.0, 1.0);
    final r = radius * t;
    final alpha = ((1 - t) * 220).round();

    canvas.drawCircle(
      Offset.zero,
      r * 0.55,
      Paint()..color = Color(0xFFFFD700).withAlpha((alpha * 0.25).round()),
    );
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Color(0xFFFFD700).withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4 * (1 - t)).clamp(0.5, 4),
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.7,
      Paint()
        ..color = Color(0xFFFF8C00).withAlpha((alpha * 0.4).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2 * (1 - t)).clamp(0.5, 2),
    );
  }
}
