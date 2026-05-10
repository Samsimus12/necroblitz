import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import 'monster_boss.dart';
import '../necroblitz_game.dart';
import '../systems/supercharge_system.dart';

class Hud extends PositionComponent with HasGameReference<NecroblitzGame> {
  Hud() : super(priority: 10);

  static final _labelStyle = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF5F5DC),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  );

  static final _bossLabelStyle = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF88FF),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void render(Canvas canvas) {
    final screenW = game.size.x;
    final screenH = game.size.y;

    _drawHpBar(canvas, screenW);
    _drawSuperchargeBar(canvas, screenW, screenH);
    _drawXpBar(canvas, screenW, screenH);
    _drawLevelBadge(canvas, screenW);

    final boss = game.activeBoss;
    if (boss != null) {
      _drawBossBar(canvas, screenW, boss);
    }
  }

  void _drawHpBar(Canvas canvas, double screenW) {
    const x = 16.0;
    const y = 114.0;
    final w = screenW - 32;
    const h = 20.0;
    final fraction =
        (game.player.currentHp / game.player.maxHp).clamp(0.0, 1.0);
    _drawBar(canvas,
        x: x,
        y: y,
        w: w,
        h: h,
        fraction: fraction,
        fg: const Color(0xFFE74C3C),
        bg: const Color(0xFF3A1010));

    _labelStyle.render(canvas, 'HP', Vector2(x + 4, y + 3));
  }

  void _drawSuperchargeBar(Canvas canvas, double screenW, double screenH) {
    const x = 16.0;
    const hpBarBottom = 114.0 + 20.0;
    const y = hpBarBottom + 6.0;
    const h = 18.0;
    final w = screenW - 32;
    final fraction = game.superchargeSystem.fraction;
    final state = game.superchargeSystem.stateNotifier.value;
    final isLit = state == SuperchargeState.ready || state == SuperchargeState.active;
    final fg = isLit ? const Color(0xFF44FF88) : const Color(0xFF1A5C30);
    _drawBar(canvas, x: x, y: y, w: w, h: h, fraction: fraction, fg: fg, bg: const Color(0xFF061A0E));
    _labelStyle.render(canvas, 'BLITZ', Vector2(x + 4, y + 2));
  }

  void _drawXpBar(Canvas canvas, double screenW, double screenH) {
    const x = 16.0;
    const h = 10.0;
    final y = screenH - h - 14;
    final w = screenW - 32;
    final fraction = game.xpSystem.xpFraction;
    _drawBar(canvas,
        x: x,
        y: y,
        w: w,
        h: h,
        fraction: fraction,
        fg: const Color(0xFF9B59B6),
        bg: const Color(0xFF1A0A2E));
  }

  void _drawLevelBadge(Canvas canvas, double screenW) {
    const cy = 68.0;
    const r = 22.0;
    final cx = screenW / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF9B59B6),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFF4A800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final label = 'Lvl ${game.xpSystem.currentLevel}';
    _labelStyle.render(
        canvas, label, Vector2(cx - 15, cy - 7));
  }

  void _drawBossBar(Canvas canvas, double screenW, BossMonster boss) {
    const x = 16.0;
    const novaBarBottom = 114.0 + 20.0 + 6.0 + 18.0;
    const y = novaBarBottom + 10.0;
    const h = 16.0;
    final w = screenW - 32;

    // Background track with glow border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 1, y - 1, w + 2, h + 2), const Radius.circular(9)),
      Paint()..color = const Color(0xFFAA00FF),
    );
    _drawBar(canvas,
        x: x,
        y: y,
        w: w,
        h: h,
        fraction: boss.hpFraction,
        fg: const Color(0xFF9900FF),
        bg: const Color(0xFF220044));

    _bossLabelStyle.render(canvas, boss.displayName, Vector2(x + 4, y));
  }

  void _drawBar(
    Canvas canvas, {
    required double x,
    required double y,
    required double w,
    required double h,
    required double fraction,
    required Color fg,
    required Color bg,
  }) {
    final rr = Radius.circular(h / 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), rr),
        Paint()..color = bg);
    if (fraction > 0) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w * fraction, h), rr),
          Paint()..color = fg);
    }
  }
}
