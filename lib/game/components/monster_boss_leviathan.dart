import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../data/monster_data.dart';
import '../data/nova_mode.dart';
import 'boss_projectile.dart';
import 'monster_boss.dart';

class MonsterBossLeviathan extends BossMonster {
  MonsterBossLeviathan({required super.position, int playerLevel = 1})
      : super(stats: leviathanStats.scaled(playerLevel), playerLevel: playerLevel);

  @override
  String get displayName => 'GORE BEAST';

  @override
  double get fireInterval => hpFraction > 0.5 ? 2.5 : 1.4;

  @override
  double get projectileDamage => 16.0;

  @override
  int get shotCount => (playerLevel ~/ 10 + 2).clamp(4, 10);

  @override
  double get specialAttackInterval => 20.0;

  @override
  int get maxSpecialAttacks => 2;

  @override
  int get specialBurstCount => 24;

  @override
  Color get specialColor => const Color(0xFF00CCFF);

  @override
  Color get deathColor => const Color(0xFF0088FF);

  @override
  void fireSpecialAttack() {
    for (int i = 0; i < specialBurstCount; i++) {
      final angle = (i / specialBurstCount) * math.pi * 2;
      game.world.add(BossProjectile(
        position: position.clone(),
        direction: Vector2(math.cos(angle), math.sin(angle)),
        damage: projectileDamage * 1.5,
        speed: 200,
        size: 22,
        color: specialColor,
      ));
    }
  }

  @override
  void onDie() {
    game.pendingInheritMode = NovaMode.leviathan;
    super.onDie();
  }

  @override
  void render(Canvas canvas) {
    if (isDead) return;
    final cx = size.x / 2;
    final cy = size.y / 2;

    final dir = game.player.position - position;
    final angle = math.atan2(dir.y, dir.x) + math.pi / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);

    // Engine exhaust glow at bottom
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 44), width: 38, height: 22),
      Paint()
        ..color = const Color(0xAA0066FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Swept energy fins — left
    final leftFin = Path()
      ..moveTo(cx - 6, cy - 10)
      ..lineTo(cx - 38, cy - 26)
      ..lineTo(cx - 48, cy + 4)
      ..lineTo(cx - 30, cy + 14)
      ..lineTo(cx - 10, cy + 6)
      ..close();
    // Swept energy fins — right
    final rightFin = Path()
      ..moveTo(cx + 6, cy - 10)
      ..lineTo(cx + 38, cy - 26)
      ..lineTo(cx + 48, cy + 4)
      ..lineTo(cx + 30, cy + 14)
      ..lineTo(cx + 10, cy + 6)
      ..close();
    final finPaint = Paint()..color = const Color(0xFF220055);
    canvas.drawPath(leftFin, finPaint);
    canvas.drawPath(rightFin, finPaint);

    // Fin outlines
    canvas.drawPath(
      leftFin,
      Paint()
        ..color = const Color(0xFF4422AA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawPath(
      rightFin,
      Paint()
        ..color = const Color(0xFF4422AA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Main elongated oval hull (taller than wide)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 80),
      Paint()..color = const Color(0xFF1A0066),
    );

    // Hull outline glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 80),
      Paint()
        ..color = const Color(0xFF6644FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Bridge dome at top
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 28), width: 28, height: 24),
      Paint()..color = const Color(0xFF220088),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 28), width: 22, height: 18),
      Paint()
        ..color = const Color(0xFF220088)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Large cyan eye in bridge dome
    canvas.drawCircle(
      Offset(cx, cy - 28),
      9,
      Paint()
        ..color = const Color(0xFF0088CC)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(cx, cy - 28), 7, Paint()..color = const Color(0xFF00CCFF));
    canvas.drawCircle(Offset(cx, cy - 28), 3, Paint()..color = const Color(0xFFFFFFFF));

    // Mid-hull panel lines
    canvas.drawLine(
      Offset(cx - 14, cy - 6),
      Offset(cx - 14, cy + 18),
      Paint()
        ..color = const Color(0xFF3322AA)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx + 14, cy - 6),
      Offset(cx + 14, cy + 18),
      Paint()
        ..color = const Color(0xFF3322AA)
        ..strokeWidth = 1.5,
    );

    // Multiple engine ports at bottom
    final enginePortPaint = Paint()..color = const Color(0xFF110033);
    final engineFirePaint = Paint()
      ..color = const Color(0xFF0088FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (int i = -2; i <= 2; i++) {
      final ex = cx + i * 7.0;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(ex, cy + 36), width: 8, height: 6), enginePortPaint);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(ex, cy + 38), width: 5, height: 4), engineFirePaint);
    }

    canvas.restore();

    renderChargeEffect(canvas, cx, cy);
    renderFlash(canvas);
  }
}
