import 'dart:math' as math;
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
    game.world.add(StunGrenade(
      position: playerPos.clone(),
      direction: direction,
      damage: damage,
    ));
  }
}

class StunGrenade extends Projectile {
  double _spin = 0;

  StunGrenade({
    required super.position,
    required super.direction,
    required double damage,
  }) : super(speed: 260, damage: damage, size: 14);

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 3.5;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      other.takeDamage(damage);
      other.applySlow(0.4, 2.0);
      game.world.add(StunFlash(position: position.clone()));
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

    // Outer glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 10),
      Paint()..color = const Color(0x4488DDFF)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Canister body — cylindrical blue-grey shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 13, height: 9),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF4A5E6A));

    // Top / bottom caps (lighter)
    canvas.drawRect(
      Rect.fromLTWH(-6.5, -4.5, 13, 3),
      Paint()..color = const Color(0xFF607D8B));
    canvas.drawRect(
      Rect.fromLTWH(-6.5, 1.5, 13, 3),
      Paint()..color = const Color(0xFF546E7A));

    // Label band — white stripe in middle
    canvas.drawRect(
      Rect.fromLTWH(-6.5, -1.0, 13, 2),
      Paint()..color = const Color(0xCCFFFFFF));

    // Fuse hole / port on top cap
    canvas.drawCircle(const Offset(0, -4), 1.8,
      Paint()..color = const Color(0xFF263238));

    // Fuse sizzle glow
    canvas.drawCircle(const Offset(0, -5.5), 3,
      Paint()..color = const Color(0x6688EEFF)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(const Offset(0, -5.5), 1.5,
      Paint()..color = const Color(0xFFCCEEFF));

    canvas.restore();
  }
}

class StunFlash extends PositionComponent {
  static const _duration = 0.40;
  double _elapsed = 0;

  StunFlash({required super.position})
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
    final r = 90.0 * t;
    final a = ((1 - t) * 255).round();

    // White-blue concussion wave
    canvas.drawCircle(Offset.zero, r,
      Paint()..color = Color(0xFFFFFFFF).withAlpha((a * 0.7).round())
             ..style = PaintingStyle.stroke
             ..strokeWidth = (6 * (1 - t)).clamp(0.5, 6)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Icy blue inner flash
    canvas.drawCircle(Offset.zero, r * 0.45,
      Paint()..color = Color(0xFF88DDFF).withAlpha((a * 0.5).round())
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Ice crystal spikes — 6-pointed burst
    final spikePaint = Paint()..color = Color(0xFFBBEEFF).withAlpha(a)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
      final ang = i * math.pi / 3;
      canvas.drawLine(
        Offset(math.cos(ang) * r * 0.15, math.sin(ang) * r * 0.15),
        Offset(math.cos(ang) * r * 0.55, math.sin(ang) * r * 0.55),
        spikePaint);
    }
  }
}
