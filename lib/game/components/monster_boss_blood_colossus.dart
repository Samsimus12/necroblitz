import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../data/monster_data.dart';
import '../data/nova_mode.dart';
import 'boss_projectile.dart';
import 'monster_boss.dart';

class MonsterBossBloodColossus extends BossMonster {
  MonsterBossBloodColossus({required super.position, int playerLevel = 1})
      : super(stats: colossusStats.scaled(playerLevel), playerLevel: playerLevel);

  @override
  String get displayName => 'TITAN ZOMBIE';

  @override
  double get fireInterval => hpFraction > 0.5 ? 2.2 : 1.1;

  @override
  double get projectileDamage => 20.0;

  @override
  int get shotCount => (playerLevel ~/ 10 + 3).clamp(6, 12);

  @override
  double get specialAttackInterval => 18.0;

  @override
  int get maxSpecialAttacks => 2;

  @override
  int get specialBurstCount => 24;

  @override
  Color get specialColor => const Color(0xFFCC1100);

  @override
  Color get deathColor => const Color(0xFFBB0000);

  @override
  void fireSpecialAttack() {
    for (int i = 0; i < specialBurstCount; i++) {
      final angle = (i / specialBurstCount) * math.pi * 2;
      game.world.add(BossProjectile(
        position: position.clone(),
        direction: Vector2(math.cos(angle), math.sin(angle)),
        damage: projectileDamage * 1.5,
        speed: 260,
        size: 24,
        color: const Color(0xFFCC1100),
      ));
    }
  }

  @override
  void onDie() {
    game.pendingInheritMode = NovaMode.bloodColossus;
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

    // Left shoulder spike pod
    final leftShoulderPod = Path()
      ..moveTo(cx - 28, cy - 14)
      ..lineTo(cx - 56, cy - 10)
      ..lineTo(cx - 60, cy + 18)
      ..lineTo(cx - 44, cy + 22)
      ..lineTo(cx - 28, cy + 8)
      ..close();
    // Right shoulder spike pod
    final rightShoulderPod = Path()
      ..moveTo(cx + 28, cy - 14)
      ..lineTo(cx + 56, cy - 10)
      ..lineTo(cx + 60, cy + 18)
      ..lineTo(cx + 44, cy + 22)
      ..lineTo(cx + 28, cy + 8)
      ..close();
    final shoulderPaint = Paint()..color = const Color(0xFF660000);
    canvas.drawPath(leftShoulderPod, shoulderPaint);
    canvas.drawPath(rightShoulderPod, shoulderPaint);

    // Shoulder spike tips — left
    final leftSpike1 = Path()
      ..moveTo(cx - 46, cy - 10)
      ..lineTo(cx - 62, cy - 22)
      ..lineTo(cx - 52, cy - 4)
      ..close();
    final leftSpike2 = Path()
      ..moveTo(cx - 54, cy + 2)
      ..lineTo(cx - 70, cy - 2)
      ..lineTo(cx - 58, cy + 14)
      ..close();
    // Shoulder spike tips — right
    final rightSpike1 = Path()
      ..moveTo(cx + 46, cy - 10)
      ..lineTo(cx + 62, cy - 22)
      ..lineTo(cx + 52, cy - 4)
      ..close();
    final rightSpike2 = Path()
      ..moveTo(cx + 54, cy + 2)
      ..lineTo(cx + 70, cy - 2)
      ..lineTo(cx + 58, cy + 14)
      ..close();
    final spikePaint = Paint()..color = const Color(0xFF880000);
    canvas.drawPath(leftSpike1, spikePaint);
    canvas.drawPath(leftSpike2, spikePaint);
    canvas.drawPath(rightSpike1, spikePaint);
    canvas.drawPath(rightSpike2, spikePaint);

    // Main blocky hull
    final hull = Path()
      ..moveTo(cx - 28, cy - 44)
      ..lineTo(cx + 28, cy - 44)
      ..lineTo(cx + 36, cy - 28)
      ..lineTo(cx + 36, cy + 36)
      ..lineTo(cx + 22, cy + 44)
      ..lineTo(cx - 22, cy + 44)
      ..lineTo(cx - 36, cy + 36)
      ..lineTo(cx - 36, cy - 28)
      ..close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF550000));

    // Forward thick armor plate
    final armorPlate = Path()
      ..moveTo(cx - 26, cy - 44)
      ..lineTo(cx + 26, cy - 44)
      ..lineTo(cx + 30, cy - 26)
      ..lineTo(cx + 26, cy - 14)
      ..lineTo(cx - 26, cy - 14)
      ..lineTo(cx - 30, cy - 26)
      ..close();
    canvas.drawPath(armorPlate, Paint()..color = const Color(0xFF660000));

    // Hull outline
    canvas.drawPath(
      hull,
      Paint()
        ..color = const Color(0xFFAA0000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Armor plate outline
    canvas.drawPath(
      armorPlate,
      Paint()
        ..color = const Color(0xFFCC2200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Glowing red cannon ports across front (5 ports)
    final cannonPortPaint = Paint()..color = const Color(0xFF220000);
    final cannonGlowPaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (int i = -2; i <= 2; i++) {
      final px = cx + i * 11.0;
      canvas.drawRect(
          Rect.fromCenter(center: Offset(px, cy - 44), width: 7, height: 10), cannonPortPaint);
      canvas.drawCircle(Offset(px, cy - 50), 3.5, cannonGlowPaint);
    }

    // Red-glowing viewport slit across bridge
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 26), width: 40, height: 7),
      Paint()
        ..color = const Color(0xFFCC0000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 26), width: 38, height: 5),
      Paint()..color = const Color(0xFFFF2200),
    );

    // Side armor ribs
    for (int i = 0; i < 3; i++) {
      final ry = cy - 4 + i * 14.0;
      canvas.drawLine(
        Offset(cx - 36, ry),
        Offset(cx - 24, ry),
        Paint()
          ..color = const Color(0xFF880000)
          ..strokeWidth = 2.0,
      );
      canvas.drawLine(
        Offset(cx + 36, ry),
        Offset(cx + 24, ry),
        Paint()
          ..color = const Color(0xFF880000)
          ..strokeWidth = 2.0,
      );
    }

    canvas.restore();

    renderChargeEffect(canvas, cx, cy);
    renderFlash(canvas);
  }
}
