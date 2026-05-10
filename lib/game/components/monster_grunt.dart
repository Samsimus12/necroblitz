import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import 'monster.dart';

// Basic zombie — shambling walker viewed from above.
class MonsterGrunt extends Monster {
  MonsterGrunt({required super.position, int playerLevel = 1})
      : super(stats: gruntStats.scaled(playerLevel));

  double _rotAngle = 0;

  static const _rFactors = [0.90, 0.65, 0.85, 0.72, 1.00, 0.68, 0.88, 0.62, 0.92, 0.78, 0.70, 0.95];
  static const _baseR = 11.0;

  @override
  void update(double dt) {
    super.update(dt);
    _rotAngle += 0.4 * dt;
  }

  Path _buildZombieBody(double cx, double cy) {
    final path = Path();
    const n = 12;
    for (int i = 0; i < n; i++) {
      final a = _rotAngle * 0.2 + (i / n) * 2 * math.pi;
      final r = _baseR * _rFactors[i];
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    return path..close();
  }

  static const _deathColors = [
    Color(0xFF6B7355), Color(0xFF78606C), Color(0xFF44CC00),
    Color(0xFFBB2200), Color(0xFF44CC22), Color(0xFF00BBDD),
    Color(0xFFFF6600), Color(0xFFCCCCCC), Color(0xFF442200), Color(0xFFCC0033),
  ];

  @override
  Color get deathColor => _deathColors[(game.bossPhase % 10).clamp(0, 9)];

  @override
  void render(Canvas canvas) {
    switch (game.bossPhase % 10) {
      case 0:
        _renderRotten(canvas);
      case 1:
        _renderIndustrial(canvas);
      case 2:
        _renderToxic(canvas);
      default:
        _renderThemed(canvas);
    }
    renderHpBar(canvas);
    renderFlash(canvas);
  }

  static const _themeBody = [
    Color(0xFF4A5A3A), Color(0xFF4A3A4A), Color(0xFF0D2000), // 0-2 (2 unused here)
    Color(0xFF3D0000), Color(0xFF1A3300), Color(0xFF001A1A), // 3-5
    Color(0xFF2A1500), Color(0xFF1A1A1A), Color(0xFF1A0A00), Color(0xFF220011), // 6-9
  ];
  static const _themeOutline = [
    Color(0xFF7A8A5A), Color(0xFF7A5A6A), Color(0xFF44CC00),
    Color(0xFF880000), Color(0xFF33AA00), Color(0xFF00AACC),
    Color(0xFFCC6600), Color(0xFF888888), Color(0xFF552200), Color(0xFFCC0033),
  ];
  static const _themeGlow = [
    Color(0x004A5A3A), Color(0x004A3A4A), Color(0x5544CC00),
    Color(0x88FF2200), Color(0x8844AA00), Color(0x8800CCDD),
    Color(0x88FF6600), Color(0x88888888), Color(0x88441100), Color(0xAACC0033),
  ];

  void _renderThemed(Canvas canvas) {
    final p = (game.bossPhase % 10).clamp(0, 9);
    final cx = size.x / 2;
    final cy = size.y / 2;
    final path = _buildZombieBody(cx, cy);

    final glow = _themeGlow[p];
    if (glow.a > 0) {
      canvas.drawPath(path, Paint()
        ..color = glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    canvas.drawPath(path, Paint()..color = _themeBody[p]);
    canvas.drawPath(path, Paint()
      ..color = _themeOutline[p]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Pulsing eyes for phases with glow
    if (glow.a > 0) {
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = _themeOutline[p].withAlpha(180));
    }
  }

  // Phase 0 — rotten grey-green zombie
  void _renderRotten(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final path = _buildZombieBody(cx, cy);

    canvas.drawPath(path, Paint()..color = const Color(0xFF4A5A3A));
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF7A8A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Arms reaching outward
    final armAngle = _rotAngle * 0.6;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(armAngle);
    final armPaint = Paint()
      ..color = const Color(0xFF5A6A4A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-4, 0), const Offset(-13, 3), armPaint);
    canvas.drawLine(const Offset(4, 0), const Offset(13, -3), armPaint);
    // Head
    canvas.drawCircle(const Offset(0, -_baseR - 2), 3.5, Paint()..color = const Color(0xFF5A6A4A));
    canvas.drawCircle(const Offset(-1.0, -_baseR - 3), 1.2, Paint()..color = const Color(0xFFCC4400));
    canvas.drawCircle(const Offset(1.2, -_baseR - 3), 1.2, Paint()..color = const Color(0xFFCC4400));
    canvas.restore();
  }

  // Phase 1 — industrial / armoured zombie with rebar
  void _renderIndustrial(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    const radii8 = [0.88, 0.72, 0.94, 0.78, 0.90, 0.68, 0.92, 0.74];
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = _rotAngle * 0.2 + (i / 8) * 2 * math.pi;
      final r = _baseR * radii8[i];
      if (i == 0) path.moveTo(cx + r * math.cos(a), cy + r * math.sin(a));
      else path.lineTo(cx + r * math.cos(a), cy + r * math.sin(a));
    }
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Bolted armour plates
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_rotAngle * 0.2);
    final boltPaint = Paint()..color = const Color(0xFF222222);
    final boltRimPaint = Paint()
      ..color = const Color(0xFF999999)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final pos in const [Offset(-5, -4), Offset(5, 3), Offset(-2, 6), Offset(6, -5)]) {
      canvas.drawCircle(pos, 2.2, boltPaint);
      canvas.drawCircle(pos, 2.2, boltRimPaint);
    }
    canvas.restore();
  }

  // Phase 2 — toxic glowing zombie
  void _renderToxic(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final path = _buildZombieBody(cx, cy);

    canvas.drawPath(path, Paint()
      ..color = const Color(0x5544CC00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawPath(path, Paint()..color = const Color(0xFF0D2000));
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF44CC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    canvas.drawCircle(Offset(cx, cy), 5, Paint()
      ..color = const Color(0xAA44CC00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = const Color(0xFF88FF00));
  }
}
