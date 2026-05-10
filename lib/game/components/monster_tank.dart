import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import 'monster.dart';

// Bloater zombie — huge bloated mass, slow and heavy.
class MonsterTank extends Monster {
  MonsterTank({required super.position, int playerLevel = 1})
      : super(stats: tankStats.scaled(playerLevel));

  static const _deathColors = [
    Color(0xFF556B2F), Color(0xFF607060), Color(0xFF44CC00),
    Color(0xFFBB0000), Color(0xFF44AA00), Color(0xFF00AACC),
    Color(0xFFFF6600), Color(0xFF888888), Color(0xFF442200), Color(0xFFCC0033),
  ];

  @override
  Color get deathColor => _deathColors[(game.bossPhase % 10).clamp(0, 9)];

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    final dir = game.player.position - position;
    final angle = math.atan2(dir.y, dir.x) + math.pi / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);

    switch (game.bossPhase % 10) {
      case 0:
        _renderRotten(canvas, cx, cy);
      case 1:
        _renderArmoured(canvas, cx, cy);
      case 2:
        _renderToxic(canvas, cx, cy);
      default:
        _renderThemed(canvas, cx, cy);
    }

    canvas.restore();
    renderHpBar(canvas);
    renderFlash(canvas);
  }

  static const _bodyColor = [
    Color(0xFF3D4A2A), Color(0xFF455060), Color(0xFF0D2000),
    Color(0xFF550000), Color(0xFF1A3300), Color(0xFF001A1A),
    Color(0xFF331100), Color(0xFF1A1A1A), Color(0xFF1A0A00), Color(0xFF220011),
  ];
  static const _outlineColor = [
    Color(0xFF6A7A4A), Color(0xFF687080), Color(0xFF44CC00),
    Color(0xFFAA0000), Color(0xFF33AA00), Color(0xFF00AACC),
    Color(0xFFCC6600), Color(0xFF888888), Color(0xFF552200), Color(0xFFCC0033),
  ];
  static const _eyeColor = [
    Color(0xFFFF6600), Color(0xFF00AACC), Color(0xFF88FF00),
    Color(0xFFFF2200), Color(0xFF88FF00), Color(0xFF00FFCC),
    Color(0xFFFFAA00), Color(0xFFCCCCCC), Color(0xFFFF4400), Color(0xFFFF0044),
  ];
  static const _glowColor = [
    Color(0x00000000), Color(0x00000000), Color(0xAA44CC00),
    Color(0xAACC0000), Color(0xAA44AA00), Color(0xAA00AACC),
    Color(0xAAAA6600), Color(0x00000000), Color(0xAA441100), Color(0xAACC0033),
  ];

  void _renderThemed(Canvas canvas, double cx, double cy) {
    final p = (game.bossPhase % 10).clamp(0, 9);

    final glow = _glowColor[p];
    if (glow.a > 0) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 52, height: 52),
        Paint()..color = glow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // Bloated round body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 46, height: 40),
      Paint()..color = _bodyColor[p],
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 46, height: 40),
      Paint()..color = _outlineColor[p]..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // Stubby arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 26, cy + 5), width: 10, height: 6), Paint()..color = _bodyColor[p]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 26, cy + 5), width: 10, height: 6), Paint()..color = _bodyColor[p]);

    // Head (top)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 18), width: 20, height: 16), Paint()..color = _bodyColor[p]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 18), width: 20, height: 16),
        Paint()..color = _outlineColor[p]..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Eyes
    canvas.drawCircle(Offset(cx - 4, cy - 19), 3.0, Paint()..color = _eyeColor[p]);
    canvas.drawCircle(Offset(cx + 4, cy - 19), 3.0, Paint()..color = _eyeColor[p]);
  }

  // Phase 0 — rotten bloated zombie corpse
  void _renderRotten(Canvas canvas, double cx, double cy) {
    // Glow of decay
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 50, height: 44),
      Paint()..color = const Color(0x2244AA00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Belly mass
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF3D4A2A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF6A7A4A)..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // Boils
    canvas.drawCircle(Offset(cx - 10, cy + 2), 5, Paint()..color = const Color(0xFF556B2F));
    canvas.drawCircle(Offset(cx + 8, cy + 8), 4, Paint()..color = const Color(0xFF556B2F));

    // Stubby arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy + 6), width: 10, height: 6), Paint()..color = const Color(0xFF3D4A2A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy + 6), width: 10, height: 6), Paint()..color = const Color(0xFF3D4A2A));
    // Clawed fingers
    for (int i = -1; i <= 1; i++) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 30 + i * 1.5, cy + 5), width: 3, height: 5), Paint()..color = const Color(0xFF4A5A3A));
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 30 + i * 1.5, cy + 5), width: 3, height: 5), Paint()..color = const Color(0xFF4A5A3A));
    }

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 22, height: 18), Paint()..color = const Color(0xFF4A5A3A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 22, height: 18),
        Paint()..color = const Color(0xFF6A7A4A)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Sunken eyes
    canvas.drawCircle(Offset(cx - 4, cy - 17), 3.5, Paint()..color = const Color(0xFFFF6600));
    canvas.drawCircle(Offset(cx + 4, cy - 17), 3.5, Paint()..color = const Color(0xFFFF6600));
    canvas.drawCircle(Offset(cx - 4, cy - 17), 1.8, Paint()..color = const Color(0xFF1A0000));
    canvas.drawCircle(Offset(cx + 4, cy - 17), 1.8, Paint()..color = const Color(0xFF1A0000));
    // Mouth gash
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - 12), width: 14, height: 6), 0.2, math.pi - 0.4, false,
        Paint()..color = const Color(0xFF1A0000)..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  // Phase 1 — armoured zombie with scrap metal plating
  void _renderArmoured(Canvas canvas, double cx, double cy) {
    // Bulk shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 50, height: 44),
      Paint()..color = const Color(0xFF2A3030)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Body mass with armour plating
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF404A50),
    );

    // Armour plates
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 4), width: 34, height: 28), const Radius.circular(4)),
      Paint()..color = const Color(0xFF546E7A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 4), width: 34, height: 28), const Radius.circular(4)),
      Paint()..color = const Color(0xFF90A4AE)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    // Bolt rivets
    for (final pos in const [Offset(-12.0, -4.0), Offset(12.0, -4.0), Offset(-12.0, 8.0), Offset(12.0, 8.0)]) {
      canvas.drawCircle(Offset(cx + pos.dx, cy + pos.dy + 4), 2.5, Paint()..color = const Color(0xFF263238));
      canvas.drawCircle(Offset(cx + pos.dx, cy + pos.dy + 4), 2.5,
          Paint()..color = const Color(0xFF78909C)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF90A4AE)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Arms with armour
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 26, cy + 6), width: 12, height: 7), Paint()..color = const Color(0xFF546E7A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 26, cy + 6), width: 12, height: 7), Paint()..color = const Color(0xFF546E7A));

    // Armoured head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 24, height: 20), Paint()..color = const Color(0xFF546E7A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 24, height: 20),
        Paint()..color = const Color(0xFF90A4AE)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Visor slits
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy - 17), width: 6, height: 3), Paint()..color = const Color(0xFF00AACC));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy - 17), width: 6, height: 3), Paint()..color = const Color(0xFF00AACC));
  }

  // Phase 2 — toxic bloater dripping bile
  void _renderToxic(Canvas canvas, double cx, double cy) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 54, height: 48),
      Paint()..color = const Color(0xAA44CC00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF0D2000),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: 46, height: 40),
      Paint()..color = const Color(0xFF44CC00)..style = PaintingStyle.stroke..strokeWidth = 2.0,
    );

    // Bile drips
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 8, cy + 22), width: 5, height: 8), Paint()..color = const Color(0xFF44CC00));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 10, cy + 22), width: 4, height: 6), Paint()..color = const Color(0xFF44CC00));

    // Arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 26, cy + 6), width: 12, height: 7), Paint()..color = const Color(0xFF0D2000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 26, cy + 6), width: 12, height: 7), Paint()..color = const Color(0xFF0D2000));

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 24, height: 20), Paint()..color = const Color(0xFF0D2000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 16), width: 24, height: 20),
        Paint()..color = const Color(0xFF44CC00)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Glowing toxic eyes
    canvas.drawCircle(Offset(cx - 4, cy - 17), 3.5, Paint()..color = const Color(0xFF88FF00));
    canvas.drawCircle(Offset(cx + 4, cy - 17), 3.5, Paint()..color = const Color(0xFF88FF00));
    canvas.drawCircle(Offset(cx, cy - 17), 5, Paint()
      ..color = const Color(0x4488FF00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }
}
