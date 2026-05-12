import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import '../data/nova_mode.dart';
import 'monster_boss.dart';

class MonsterBossVoidTyrant extends BossMonster {
  MonsterBossVoidTyrant({required super.position, int playerLevel = 1})
      : super(stats: tyrantStats.scaled(playerLevel), playerLevel: playerLevel);

  @override
  String get displayName => 'PLAGUE LORD';

  @override
  double get fireInterval => hpFraction > 0.4 ? 1.8 : 0.9;

  @override
  double get projectileDamage => 18.0;

  // 5 shots at level 20, +2 per 20 levels (level 40 → 7, level 60 → 9, etc.)
  @override
  int get shotCount => (playerLevel ~/ 10 + 3).clamp(5, 11);

  @override
  double get specialAttackInterval => 15.0;

  @override
  int get maxSpecialAttacks => 2;

  @override
  int get specialBurstCount => 16;

  @override
  Color get specialColor => const Color(0xFFFF00CC);

  @override
  Color get deathColor => const Color(0xFF88AA22);

  @override
  void onDie() {
    game.pendingInheritMode = NovaMode.voidTyrant;
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

    // Bile aura
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 118, height: 112),
      Paint()..color = const Color(0x2288AA00)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));

    // Fly swarm orbiting the body
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi * 2 / 12;
      canvas.drawCircle(Offset(cx + math.cos(a) * 52, cy + math.sin(a) * 50), 2.5,
        Paint()..color = const Color(0xFF333300));
    }

    // Massive bloated round body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 78, height: 74),
      Paint()..color = const Color(0xFF5A6A1A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 78, height: 74),
      Paint()..color = const Color(0xFF88AA22)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Pustule bumps around the edge
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + math.pi / 8;
      canvas.drawCircle(Offset(cx + math.cos(a) * 30, cy + math.sin(a) * 28), 7,
        Paint()..color = const Color(0xFF6A7A22));
      canvas.drawCircle(Offset(cx + math.cos(a) * 30, cy + math.sin(a) * 28), 3.5,
        Paint()..color = const Color(0xFF88CC00));
    }

    // Stubby arm stubs at sides
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 42, cy + 4), width: 18, height: 10),
      Paint()..color = const Color(0xFF4A5A18));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 42, cy + 4), width: 18, height: 10),
      Paint()..color = const Color(0xFF4A5A18));

    // Sunken bloated head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 18), width: 30, height: 26),
      Paint()..color = const Color(0xFF4A5A18));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 18), width: 30, height: 26),
      Paint()..color = const Color(0xFF88AA22)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Glowing bile eyes
    canvas.drawCircle(Offset(cx - 7, cy - 20), 5,
      Paint()..color = const Color(0xFFAAFF00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(cx + 7, cy - 20), 5,
      Paint()..color = const Color(0xFFAAFF00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(cx - 7, cy - 20), 3, Paint()..color = const Color(0xFF000000));
    canvas.drawCircle(Offset(cx + 7, cy - 20), 3, Paint()..color = const Color(0xFF000000));
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - 12), width: 20, height: 10),
      0.1, math.pi - 0.2, false,
      Paint()..color = const Color(0xFF88AA00)..strokeWidth = 2.0..style = PaintingStyle.stroke);

    // Bile drips from belly
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 12, cy + 39), width: 6, height: 10),
      Paint()..color = const Color(0xFF66AA00));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 8, cy + 40), width: 5, height: 8),
      Paint()..color = const Color(0xFF66AA00));


    canvas.restore();

    renderChargeEffect(canvas, cx, cy);
    renderFlash(canvas);
  }
}
