import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import '../data/nova_mode.dart';
import 'monster_boss.dart';

class MonsterBossDreadnought extends BossMonster {
  MonsterBossDreadnought({required super.position, int playerLevel = 1})
      : super(stats: bossStats.scaled(playerLevel), playerLevel: playerLevel);

  @override
  String get displayName => 'ABOMINATION';

  @override
  double get fireInterval => hpFraction > 0.5 ? 2.0 : 1.2;

  @override
  double get projectileDamage => 14.0;

  // 3 shots at level 10, +2 per 20 levels (level 30 → 5, level 50 → 7, etc.)
  @override
  int get shotCount => (playerLevel ~/ 10 + 2).clamp(3, 9);

  @override
  double get specialAttackInterval => 18.0;

  @override
  int get maxSpecialAttacks => 2;

  @override
  int get specialBurstCount => 12;

  @override
  Color get specialColor => const Color(0xFFFFDD00);

  @override
  void onDie() {
    game.pendingInheritMode = NovaMode.dreadnought;
    super.onDie();
  }

  @override
  Color get deathColor => const Color(0xFF5A7A3A);

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

    // Decay glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 100, height: 95),
      Paint()..color = const Color(0x3344AA00)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));

    // Six claw-arms radiating outward (top-down mutant limbs)
    final clawPaint = Paint()..color = const Color(0xFF3A4A2A);
    final clawEdge  = Paint()..color = const Color(0xFF6A8A4A)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + math.pi / 6;
      final armPath = Path()
        ..moveTo(cx + math.cos(a - 0.25) * 16, cy + math.sin(a - 0.25) * 16)
        ..lineTo(cx + math.cos(a) * 44, cy + math.sin(a) * 44)
        ..lineTo(cx + math.cos(a + 0.25) * 16, cy + math.sin(a + 0.25) * 16)
        ..close();
      canvas.drawPath(armPath, clawPaint);
      canvas.drawPath(armPath, clawEdge);
      // Claw tip
      canvas.drawCircle(Offset(cx + math.cos(a) * 46, cy + math.sin(a) * 46), 4,
        Paint()..color = const Color(0xFF4A5A3A));
      canvas.drawLine(
        Offset(cx + math.cos(a - 0.18) * 43, cy + math.sin(a - 0.18) * 43),
        Offset(cx + math.cos(a - 0.4) * 50, cy + math.sin(a - 0.4) * 50),
        Paint()..color = const Color(0xFF88AA66)..strokeWidth = 1.5..strokeCap = StrokeCap.round);
      canvas.drawLine(
        Offset(cx + math.cos(a + 0.18) * 43, cy + math.sin(a + 0.18) * 43),
        Offset(cx + math.cos(a + 0.4) * 50, cy + math.sin(a + 0.4) * 50),
        Paint()..color = const Color(0xFF88AA66)..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }

    // Main bloated body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 60, height: 56),
      Paint()..color = const Color(0xFF4A5A3A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 60, height: 56),
      Paint()..color = const Color(0xFF7A8A5A)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Boils / pustules on back
    for (int i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5;
      canvas.drawCircle(
        Offset(cx + math.cos(a) * 20, cy + math.sin(a) * 18), 5,
        Paint()..color = const Color(0xFF5A6A4A));
    }

    // Glowing wound — open gash on top
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 8), width: 24, height: 12),
      Paint()..color = const Color(0xFF880000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 8), width: 16, height: 8),
      Paint()..color = const Color(0xFFAA44CC00)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 8), width: 10, height: 5),
      Paint()..color = const Color(0xFF66CC00));

    // Sunken head — skull visible at top
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 18), width: 20, height: 16),
      Paint()..color = const Color(0xFF3A4A2A));
    // Eye sockets
    canvas.drawCircle(Offset(cx - 5, cy - 19), 3.5,
      Paint()..color = const Color(0xFFFF4400)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(cx + 5, cy - 19), 3.5,
      Paint()..color = const Color(0xFFFF4400)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(cx - 5, cy - 19), 2, Paint()..color = const Color(0xFF1A0000));
    canvas.drawCircle(Offset(cx + 5, cy - 19), 2, Paint()..color = const Color(0xFF1A0000));

    canvas.restore();

    renderChargeEffect(canvas, cx, cy);
    renderFlash(canvas);
  }
}
