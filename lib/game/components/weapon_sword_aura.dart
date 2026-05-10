import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'monster.dart';
import 'weapon.dart';

class WeaponSwordAura extends Weapon {
  static const _radius = 70.0;

  double _angle = 0;

  WeaponSwordAura() : super(damage: 8, fireRate: 1.0);

  @override
  String get displayName => 'Blade Ring';

  @override
  String get nextUpgradeDescription => 'Blade damage +30%';

  @override
  void update(double dt) {
    _angle += dt * 2.0;

    for (final m in game.world.children.whereType<Monster>()) {
      final dist = m.position.distanceTo(game.player.position);
      if (dist < _radius + m.size.x / 2) {
        m.takeDamage(damage * dt);
      }
    }
  }

  @override
  void fire(Vector2 playerPos, Vector2 direction) {}

  @override
  void render(Canvas canvas) {
    final cx = game.player.size.x / 2;
    final cy = game.player.size.y / 2;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      _radius,
      Paint()
        ..color = const Color(0x44FFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Ring
    canvas.drawCircle(
      Offset(cx, cy),
      _radius,
      Paint()
        ..color = const Color(0xCCFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3 spinning rune dots
    final dotPaint = Paint()..color = const Color(0xFFFFD700);
    for (int i = 0; i < 3; i++) {
      final a = _angle + (i * math.pi * 2 / 3);
      canvas.drawCircle(
        Offset(cx + math.cos(a) * _radius, cy + math.sin(a) * _radius),
        4.5,
        dotPaint,
      );
    }

    // Upgrade balls — one per level beyond 1, counter-orbiting on inner ring
    final extraBalls = upgradeLevel - 1;
    if (extraBalls > 0) {
      const innerR = _radius * 0.65;
      final glowPaint = Paint()
        ..color = const Color(0x88FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      final ballPaint = Paint()..color = const Color(0xFFFFFFAA);
      for (int i = 0; i < extraBalls; i++) {
        final a = -_angle * 1.5 + (i * math.pi * 2 / extraBalls);
        final bx = cx + math.cos(a) * innerR;
        final by = cy + math.sin(a) * innerR;
        canvas.drawCircle(Offset(bx, by), 5.0, glowPaint);
        canvas.drawCircle(Offset(bx, by), 3.0, ballPaint);
      }
    }
  }
}
