import 'dart:math' as math;
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
    game.world.add(FragGrenade(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class FragGrenade extends Projectile {
  static const _aoeRadius = 80.0;
  // Spin angle accumulates each frame
  double _spin = 0;

  FragGrenade({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 210, damage: damage, size: 16);

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 4.0;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      for (final m in game.world.children.whereType<Monster>()) {
        if (m.position.distanceTo(position) <= _aoeRadius) {
          m.takeDamage(damage);
        }
      }
      game.world.add(FragBlast(position: position.clone()));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_spin);

    // Grenade body — dark olive, slightly oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 13, height: 11),
      Paint()..color = const Color(0xFF3D4A28));

    // Segmented pineapple texture — 4 horizontal bands
    for (int i = -1; i <= 1; i++) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(0, i * 3.5), width: 12, height: 0.8),
        Paint()..color = const Color(0xFF2E3820));
    }
    // 2 vertical segment lines
    for (final dx in [-2.5, 2.5]) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(dx, 0), width: 0.8, height: 9),
        Paint()..color = const Color(0xFF2E3820));
    }

    // Body highlight
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-1.5, -2.0), width: 5, height: 3),
      Paint()..color = const Color(0x334A5A30));

    // Spoon / safety lever — flat metal tab sticking off side
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(7, -1), width: 5, height: 2),
      Paint()..color = const Color(0xFF8A8A7A));

    // Pull pin ring at top
    canvas.drawCircle(const Offset(0, -6), 3.5,
      Paint()..color = const Color(0x00000000));
    canvas.drawCircle(const Offset(0, -6), 3.5,
      Paint()..color = const Color(0xFFAA9944)
             ..style = PaintingStyle.stroke
             ..strokeWidth = 1.5);
    // Ring cross-bar
    canvas.drawLine(
      const Offset(-2, -6), const Offset(2, -6),
      Paint()..color = const Color(0xFFAA9944)..strokeWidth = 1.5);

    canvas.restore();
  }
}

class FragBlast extends PositionComponent {
  static const _duration = 0.45;
  double _elapsed = 0;

  FragBlast({required super.position})
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
    final r = FragGrenade._aoeRadius * t;
    final baseAlpha = ((1 - t) * 255).round();

    // Inner fireball
    canvas.drawCircle(Offset.zero, r * 0.35,
      Paint()..color = Color(0xFFFFDD00).withAlpha((baseAlpha * 0.6).round())
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));

    // Shockwave ring
    canvas.drawCircle(Offset.zero, r,
      Paint()..color = Color(0xFFFF6600).withAlpha(baseAlpha)
             ..style = PaintingStyle.stroke
             ..strokeWidth = (5 * (1 - t)).clamp(0.5, 5));

    // Secondary ring
    canvas.drawCircle(Offset.zero, r * 0.65,
      Paint()..color = Color(0xFFCC2200).withAlpha((baseAlpha * 0.5).round())
             ..style = PaintingStyle.stroke
             ..strokeWidth = (3 * (1 - t)).clamp(0.5, 3));

    // Smoke puff at centre
    canvas.drawCircle(Offset.zero, r * 0.25,
      Paint()..color = Color(0xFF666655).withAlpha((baseAlpha * 0.4).round())
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Debris sparks — fixed positions around ring
    final sparkPaint = Paint()..color = Color(0xFFFFAA00).withAlpha(baseAlpha);
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawCircle(Offset(math.cos(a) * r * 0.85, math.sin(a) * r * 0.85),
        2.5 * (1 - t), sparkPaint);
    }
  }
}
