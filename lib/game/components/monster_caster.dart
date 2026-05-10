import 'dart:math' as math;
import 'dart:ui';

import '../data/monster_data.dart';
import 'caster_projectile.dart';
import 'monster.dart';

// Spitter zombie — ranged zombie that hurls bile from distance.
class MonsterCaster extends Monster {
  static const _preferredRange = 200.0;
  static const _retreatRange = 130.0;
  static const _fireInterval = 2.5;

  double _fireTimer = 1.5;

  MonsterCaster({required super.position, int playerLevel = 1})
      : super(stats: casterStats.scaled(playerLevel));

  static const _deathColors = [
    Color(0xFF44AA00), Color(0xFF00AACC), Color(0xFF88FF00),
    Color(0xFFCC0000), Color(0xFF66CC00), Color(0xFF00FFCC),
    Color(0xFFFFAA00), Color(0xFFAAAAAA), Color(0xFF552200), Color(0xFFFF0044),
  ];

  @override
  Color get deathColor => _deathColors[(game.bossPhase % 10).clamp(0, 9)];

  @override
  void updateMovement(double dt) {
    final dir = game.player.position - position;
    final dist = dir.length;
    if (dist < 1) return;
    if (dist > _preferredRange) {
      position += dir.normalized() * stats.speed * slowFactor * dt;
    } else if (dist < _retreatRange) {
      position -= dir.normalized() * stats.speed * slowFactor * dt;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;
    _fireTimer -= dt;
    if (_fireTimer <= 0) {
      _fireTimer = _fireInterval;
      _fire();
    }
  }

  void _fire() {
    final dir = game.player.position - position;
    if (dir.length < 1) return;
    game.world.add(CasterProjectile(
      position: position.clone(),
      direction: dir.normalized(),
    ));
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = size.x / 2;
    final dir = game.player.position - position;
    final angle = math.atan2(dir.y, dir.x);

    switch (game.bossPhase % 10) {
      case 0:
        _renderRotten(canvas, cx, cy, r, angle);
      case 1:
        _renderAcid(canvas, cx, cy, r, angle);
      case 2:
        _renderToxic(canvas, cx, cy, r, angle);
      default:
        _renderThemed(canvas, cx, cy, r, angle);
    }

    renderHpBar(canvas);
    renderFlash(canvas);
  }

  // Phase 0 — rotten spitter with bile sac
  void _renderRotten(Canvas canvas, double cx, double cy, double r, double angle) {
    // Bile glow around body
    canvas.drawCircle(Offset(cx, cy), r + 4, Paint()
      ..color = const Color(0x5544AA00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Hunched body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 1.8),
        Paint()..color = const Color(0xFF3D4A2A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 1.8),
        Paint()..color = const Color(0xFF6A7A5A)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Bile sac (bulge aimed at player)
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, -4, r - 3, 8), const Radius.circular(3)),
      Paint()..color = const Color(0xFF2A3D1A),
    );
    canvas.drawCircle(Offset(r - 2, 0), 4, Paint()
      ..color = const Color(0xAA66CC00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(r - 2, 0), 2.5, Paint()..color = const Color(0xFF88FF00));
    canvas.restore();

    // Glowing core
    canvas.drawCircle(Offset(cx, cy), 7, Paint()
      ..color = const Color(0xAA44AA00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFF66CC00));

    // Charge ring (bile building up)
    final chargeAlpha = (_fireTimer / _fireInterval * 180).toInt().clamp(0, 180);
    canvas.drawCircle(Offset(cx, cy), 11, Paint()
      ..color = Color.fromARGB(chargeAlpha, 68, 170, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  // Phase 1 — acid-sprayer (chrome canister zombie)
  void _renderAcid(Canvas canvas, double cx, double cy, double r, double angle) {
    // Outer chrome ring
    canvas.drawCircle(Offset(cx, cy), r + 5, Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);

    // Gear teeth
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final tx = cx + (r + 5) * math.cos(a);
      final ty = cy + (r + 5) * math.sin(a);
      canvas.save();
      canvas.translate(tx, ty);
      canvas.rotate(a);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 5, height: 3),
          Paint()..color = const Color(0xFF546E7A));
      canvas.restore();
    }

    // Octagonal body
    final oct = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      if (i == 0) oct.moveTo(cx + r * math.cos(a), cy + r * math.sin(a));
      else oct.lineTo(cx + r * math.cos(a), cy + r * math.sin(a));
    }
    oct.close();
    canvas.drawPath(oct, Paint()..color = const Color(0xFF455A64));
    canvas.drawPath(oct, Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Acid spray barrel
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, -3, r - 2, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawCircle(Offset(r - 1, 0), 3, Paint()..color = const Color(0xFF44CC00));
    canvas.restore();

    // Acid core
    canvas.drawCircle(Offset(cx, cy), 7, Paint()
      ..color = const Color(0xAA44CC00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFF66FF00));

    final chargeAlpha = (_fireTimer / _fireInterval * 180).toInt().clamp(0, 180);
    canvas.drawCircle(Offset(cx, cy), 11, Paint()
      ..color = Color.fromARGB(chargeAlpha, 68, 204, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  // Phase 2 — toxic void spitter with tendrils
  void _renderToxic(Canvas canvas, double cx, double cy, double r, double angle) {
    canvas.drawCircle(Offset(cx, cy), r + 6, Paint()
      ..color = const Color(0x5588FF00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF0D2000));

    // Tendrils
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
        Offset(cx + (r + 8) * math.cos(a), cy + (r + 8) * math.sin(a)),
        Paint()..color = const Color(0xFF44CC00)..strokeWidth = 1.5,
      );
    }

    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = const Color(0xFF44CC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Acid barrel
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, -3, r - 2, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF0D2000),
    );
    canvas.drawCircle(Offset(r - 1, 0), 3, Paint()..color = const Color(0xFF88FF00));
    canvas.restore();

    // Toxic eye
    canvas.drawCircle(Offset(cx, cy), 7, Paint()
      ..color = const Color(0xAA88FF00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFF88FF00));
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = const Color(0xFF000000));
    canvas.drawCircle(Offset(cx, cy), 1, Paint()..color = const Color(0xFFFFFFFF));

    final chargeAlpha = (_fireTimer / _fireInterval * 180).toInt().clamp(0, 180);
    canvas.drawCircle(Offset(cx, cy), 11, Paint()
      ..color = Color.fromARGB(chargeAlpha, 136, 255, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  static const _bodyColor = [
    Color(0xFF2D3D1A), Color(0xFF455A64), Color(0xFF0D2000),
    Color(0xFF3D0000), Color(0xFF1A3300), Color(0xFF001A1A),
    Color(0xFF2A1500), Color(0xFF1A1A1A), Color(0xFF1A0A00), Color(0xFF220011),
  ];
  static const _outlineColor = [
    Color(0xFF44AA00), Color(0xFF78909C), Color(0xFF88FF00),
    Color(0xFF880000), Color(0xFF66CC00), Color(0xFF00AACC),
    Color(0xFFCC7700), Color(0xFF888888), Color(0xFF552200), Color(0xFFCC0033),
  ];
  static const _coreColor = [
    Color(0xFF66CC00), Color(0xFF44CC00), Color(0xFF88FF00),
    Color(0xFFFF2200), Color(0xFF66FF00), Color(0xFF00FFCC),
    Color(0xFFFFAA00), Color(0xFFCCCCCC), Color(0xFFFF6600), Color(0xFFFF0044),
  ];

  void _renderThemed(Canvas canvas, double cx, double cy, double r, double angle) {
    final p = (game.bossPhase % 10).clamp(0, 9);
    final outlineColor = _outlineColor[p];
    final coreColor = _coreColor[p];

    canvas.drawCircle(Offset(cx, cy), r + 4, Paint()
      ..color = outlineColor.withAlpha(80)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Hexagon body
    final hex = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 6 + i * math.pi / 3;
      if (i == 0) hex.moveTo(cx + r * math.cos(a), cy + r * math.sin(a));
      else hex.lineTo(cx + r * math.cos(a), cy + r * math.sin(a));
    }
    hex.close();
    canvas.drawPath(hex, Paint()..color = _bodyColor[p]);
    canvas.drawPath(hex, Paint()
      ..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Barrel
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, -3, r - 2, 6), const Radius.circular(2)),
      Paint()..color = _bodyColor[p].withAlpha(220),
    );
    canvas.drawCircle(Offset(r - 1, 0), 3, Paint()..color = coreColor);
    canvas.restore();

    canvas.drawCircle(Offset(cx, cy), 7, Paint()
      ..color = coreColor.withAlpha(160)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = coreColor);

    final chargeAlpha = (_fireTimer / _fireInterval * 180).toInt().clamp(0, 180);
    canvas.drawCircle(Offset(cx, cy), 11, Paint()
      ..color = coreColor.withAlpha(chargeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }
}
