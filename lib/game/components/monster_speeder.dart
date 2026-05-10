import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import 'monster.dart';

// Runner zombie — lean and fast, hunched forward.
class MonsterSpeeder extends Monster {
  MonsterSpeeder({required super.position, int playerLevel = 1})
      : super(stats: speederStats.scaled(playerLevel));

  static const _deathColors = [
    Color(0xFF6B7355), Color(0xFF607060), Color(0xFF44CC00),
    Color(0xFFCC2200), Color(0xFF44AA00), Color(0xFF00AABB),
    Color(0xFFFF6600), Color(0xFFAAAAAA), Color(0xFF552200), Color(0xFFCC0033),
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
        _renderScrapmetal(canvas, cx, cy);
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
    Color(0xFF3D4A2A), Color(0xFF404848), Color(0xFF0D2000),
    Color(0xFF550000), Color(0xFF1A3300), Color(0xFF001A1A),
    Color(0xFF441100), Color(0xFF1A1A1A), Color(0xFF1A0A00), Color(0xFF220011),
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
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 4), width: 6, height: 8),
          Paint()..color = glow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    // Lean elongated body
    final body = Path()
      ..moveTo(cx, cy - 8)
      ..lineTo(cx + 3, cy - 1)
      ..lineTo(cx + 3, cy + 5)
      ..lineTo(cx, cy + 4)
      ..lineTo(cx - 3, cy + 5)
      ..lineTo(cx - 3, cy - 1)
      ..close();
    canvas.drawPath(body, Paint()..color = _bodyColor[p]);
    canvas.drawPath(body, Paint()
      ..color = _eyeColor[p].withAlpha(100)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Outstretched arms (running pose)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 7, cy - 3), width: 6, height: 10), Paint()..color = _bodyColor[p]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 2), width: 6, height: 8), Paint()..color = _bodyColor[p]);

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 9), width: 7, height: 6), Paint()..color = _bodyColor[p]);
    canvas.drawCircle(Offset(cx, cy - 9), 3.5, Paint()..color = _eyeColor[p]);
  }

  // Phase 0 — lean rotten runner
  void _renderRotten(Canvas canvas, double cx, double cy) {
    // Speed trail
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 5), width: 5, height: 7),
        Paint()..color = const Color(0x4466AA00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Body — lean and hunched
    final body = Path()
      ..moveTo(cx, cy - 8)
      ..lineTo(cx + 3, cy - 1)
      ..lineTo(cx + 3, cy + 5)
      ..lineTo(cx, cy + 4)
      ..lineTo(cx - 3, cy + 5)
      ..lineTo(cx - 3, cy - 1)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF3D4A2A));
    canvas.drawPath(body, Paint()
      ..color = const Color(0xFF6A7A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);

    // Outstretched arms in running pose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 7, cy - 3), width: 5, height: 10), Paint()..color = const Color(0xFF3D4A2A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 2), width: 5, height: 8), Paint()..color = const Color(0xFF3D4A2A));

    // Head (forward leaning)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 9), width: 8, height: 6), Paint()..color = const Color(0xFF4A5A3A));
    // Glowing eyes
    canvas.drawCircle(Offset(cx - 1.5, cy - 10), 1.5, Paint()..color = const Color(0xFFFF6600));
    canvas.drawCircle(Offset(cx + 1.5, cy - 10), 1.5, Paint()..color = const Color(0xFFFF6600));
    // Snarling mouth
    canvas.drawLine(Offset(cx - 2, cy - 7), Offset(cx + 2, cy - 7),
        Paint()..color = const Color(0xFF1A0000)..strokeWidth = 1.2);
  }

  // Phase 1 — scrap metal zombie: patched together
  void _renderScrapmetal(Canvas canvas, double cx, double cy) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 5), width: 7, height: 9),
        Paint()..color = const Color(0x4400AACC)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Wider angled body
    final body = Path()
      ..moveTo(cx, cy - 8)
      ..lineTo(cx + 4, cy)
      ..lineTo(cx + 3, cy + 5)
      ..lineTo(cx, cy + 4)
      ..lineTo(cx - 3, cy + 5)
      ..lineTo(cx - 4, cy)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF404848));
    canvas.drawPath(body, Paint()
      ..color = const Color(0xFF787878)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);

    // Scrap arm (rod)
    canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy - 11),
        Paint()..color = const Color(0xFF787878)..strokeWidth = 1.0);
    canvas.drawCircle(Offset(cx, cy - 11), 1.5, Paint()..color = const Color(0xFF00AACC));

    // Arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 7, cy - 2), width: 5, height: 9), Paint()..color = const Color(0xFF3A4448));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 1), width: 5, height: 7), Paint()..color = const Color(0xFF3A4448));

    // Head with visor
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 8), width: 8, height: 7), Paint()..color = const Color(0xFF3A4448));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 9), width: 5, height: 3), Paint()..color = const Color(0xFF00AACC));

    // Fuel fire
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 6), width: 3, height: 4), Paint()..color = const Color(0xFF00AACC));
  }

  // Phase 2 — toxic runner dripping bile
  void _renderToxic(Canvas canvas, double cx, double cy) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 6), width: 6, height: 10),
        Paint()..color = const Color(0xAA44CC00)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    final body = Path()
      ..moveTo(cx, cy - 9)
      ..lineTo(cx + 2.5, cy + 1)
      ..lineTo(cx + 2.5, cy + 6)
      ..lineTo(cx, cy + 5)
      ..lineTo(cx - 2.5, cy + 6)
      ..lineTo(cx - 2.5, cy + 1)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF0D2000));
    canvas.drawPath(body, Paint()
      ..color = const Color(0xFF44CC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);

    // Arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 7, cy - 2), width: 5, height: 9), Paint()..color = const Color(0xFF0D2000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 1), width: 5, height: 7), Paint()..color = const Color(0xFF0D2000));

    // Glowing eye
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 7), width: 6, height: 5),
        Paint()..color = const Color(0xFF88FF00));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 7), width: 3, height: 2.5),
        Paint()..color = const Color(0xFF000000));

    // Toxic flame trail
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 7), width: 3, height: 4),
        Paint()..color = const Color(0xFF44CC00));
  }
}
