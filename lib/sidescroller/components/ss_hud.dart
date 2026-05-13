import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle;

import '../sidescroller_game.dart';

class SsHud extends Component with HasGameReference<SidescrollerGame> {
  SsHud() : super(priority: 20);

  final _textPaint = TextPaint(
    style: TextStyle(
      color: const Color(0xFFE0E0E0),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final player = game.player;

    // HP bar — placed below the BACK button (y=46)
    const barX = 12.0, barY = 46.0, barW = 130.0, barH = 9.0;
    canvas.drawRect(
      const Rect.fromLTWH(barX, barY, barW, barH),
      Paint()..color = const Color(0xFF222222),
    );
    final hpFrac = (player.currentHp / player.maxHp).clamp(0.0, 1.0);
    final hpColor = hpFrac > 0.5
        ? const Color(0xFF4CAF50)
        : hpFrac > 0.25
            ? const Color(0xFFFFAA00)
            : const Color(0xFFFF3333);
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barW * hpFrac, barH),
      Paint()..color = hpColor,
    );
    canvas.drawRect(
      const Rect.fromLTWH(barX, barY, barW, barH),
      Paint()
        ..color = const Color(0x55FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _textPaint.render(canvas, 'HP', Vector2(barX, barY + barH + 2));

    // Kill count — top-right
    _textPaint.render(
      canvas,
      'KILLS: ${game.killCount}',
      Vector2(w - 95, 14),
    );
  }
}
