import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../necroblitz_game.dart';

// ── Pre-generated deterministic scene layouts (seed=42) ───────────────────────

// Buildings: [xFrac, wFrac, hFrac, windowCols, windowRows, isDamaged(0/1)]
final _buildings = _mkList(42, 6, (r) => [
  r.nextDouble(),
  r.nextDouble() * 0.10 + 0.06,
  r.nextDouble() * 0.28 + 0.18,
  (r.nextInt(3) + 2).toDouble(),
  (r.nextInt(3) + 3).toDouble(),
  r.nextBool() ? 1.0 : 0.0,
]);

// Dead trees: [xFrac, heightFrac, trunkWFrac, a0..a4 branch angles, l0..l4 branch lens]
final _trees = _mkList(137, 7, (r) {
  final a = List.generate(5, (_) => (r.nextDouble() - 0.5) * math.pi * 1.4);
  final l = List.generate(5, (_) => r.nextDouble() * 0.055 + 0.028);
  return [r.nextDouble(), r.nextDouble() * 0.22 + 0.13, r.nextDouble() * 0.012 + 0.005, ...a, ...l];
});

// Ice spikes: [xFrac, heightFrac, baseWFrac, fromTop(0/1)]
final _iceSpikes = _mkList(73, 14, (r) => [
  r.nextDouble(), r.nextDouble() * 0.13 + 0.05,
  r.nextDouble() * 0.025 + 0.009, r.nextBool() ? 1.0 : 0.0,
]);

// Waste barrels: [xFrac, yFrac]
final _barrels = _mkList(91, 4, (r) => [
  r.nextDouble() * 0.76 + 0.12, r.nextDouble() * 0.22 + 0.56,
]);

// Blood pools: [xFrac, wFrac, hFrac, yFrac]
final _bloodPools = _mkList(55, 5, (r) => [
  r.nextDouble(), r.nextDouble() * 0.10 + 0.04,
  r.nextDouble() * 0.022 + 0.008, r.nextDouble() * 0.18 + 0.73,
]);

// Sewer drips: [xFrac, lenFrac, speed, phaseOffset]
final _sewDrips = _mkList(19, 14, (r) => [
  r.nextDouble(), r.nextDouble() * 0.08 + 0.03,
  r.nextDouble() * 18 + 8, r.nextDouble() * math.pi * 2,
]);

// Neural veins: [x1, y1, x2, y2, lineW]
final _veins = _mkList(201, 22, (r) {
  final cx = 0.20 + r.nextDouble() * 0.60;
  final cy = 0.12 + r.nextDouble() * 0.76;
  final ang = r.nextDouble() * math.pi * 2;
  final len = r.nextDouble() * 0.22 + 0.06;
  return [cx, cy, cx + math.cos(ang) * len, cy + math.sin(ang) * len,
          r.nextDouble() * 1.6 + 0.4];
});

// Chimneys: [xFrac, widthFrac, heightFrac]
final _chimneys = _mkList(63, 3, (r) => [
  r.nextDouble() * 0.65 + 0.18, r.nextDouble() * 0.028 + 0.018,
  r.nextDouble() * 0.30 + 0.28,
]);

// Bunker pillars: [xFrac] — evenly spaced
final _pillars = List.generate(5, (i) => [0.08 + i * 0.21]);

List<List<double>> _mkList(int seed, int count, List<double> Function(math.Random) fn) {
  final r = math.Random(seed);
  return List.generate(count, (_) => fn(r));
}

// ── Particle palettes ─────────────────────────────────────────────────────────
const _ashGrey     = [Color(0xFF8A8A80), Color(0xFF7A7A72), Color(0xFF9A9A90)];
const _smokeGrey   = [Color(0xFF686860), Color(0xFF585850), Color(0xFF787870)];
const _toxicGreen  = [Color(0xFF44FF44), Color(0xFF88FF00), Color(0xFF00CC44), Color(0xFFAAFF44), Color(0xFF66FF88)];
const _bloodRed    = [Color(0xFFCC1111), Color(0xFFDD3300), Color(0xFFBB2200)];
const _radioGreen  = [Color(0xFF88CC00), Color(0xFF44AA00), Color(0xFFAAFF00), Color(0xFF226600)];
const _iceWhite    = [Color(0xFFCCEEFF), Color(0xFFAADDFF), Color(0xFF88CCFF), Color(0xFFEEF8FF), Color(0xFFFFFFFF)];
const _emberOrange = [Color(0xFFFF6600), Color(0xFFFF3300), Color(0xFFFFAA00), Color(0xFFFF8800)];
const _dustMote    = [Color(0xFFBBBBAA)];
const _forestWisp  = [Color(0xFF331500), Color(0xFF221000), Color(0xFF441800), Color(0xFF110A00)];
const _neuralRed   = [Color(0xFFCC0044), Color(0xFFDD2266), Color(0xFFAA0033)];

// ── StarBackground ────────────────────────────────────────────────────────────

class StarBackground extends Component with HasGameReference<NecroblitzGame> {
  final _particles = <_Particle>[];
  final _rng = math.Random();
  double _t = 0;

  @override
  Future<void> onLoad() async => _spawnParticles();

  void _spawnParticles() {
    _particles.clear();
    final sz = game.size;
    final phase = game.bossPhase % 10;

    void add(int n, {required double minR, required double maxR,
        required double minSpd, required double maxSpd,
        required double minA, required double maxA,
        required int palette, bool rising = false}) {
      for (int i = 0; i < n; i++) {
        final spd = minSpd + _rng.nextDouble() * (maxSpd - minSpd);
        _particles.add(_Particle(
          x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
          radius: minR + _rng.nextDouble() * (maxR - minR),
          speed: rising ? -spd : spd,
          alpha: minA + _rng.nextDouble() * (maxA - minA),
          colorIndex: _rng.nextInt(palette),
        ));
      }
    }

    switch (phase) {
      case 0:
        add(60, minR: 0.4, maxR: 1.8, minSpd: 8, maxSpd: 18, minA: 0.10, maxA: 0.40, palette: _ashGrey.length);
      case 1:
        add(30, minR: 0.4, maxR: 1.5, minSpd: 4, maxSpd: 12, minA: 0.08, maxA: 0.24, palette: _smokeGrey.length);
      case 2:
        add(55, minR: 0.5, maxR: 2.5, minSpd: 12, maxSpd: 28, minA: 0.30, maxA: 0.75, palette: _toxicGreen.length);
        add(18, minR: 1.0, maxR: 3.5, minSpd: 8, maxSpd: 20, minA: 0.20, maxA: 0.55, palette: _toxicGreen.length, rising: true);
      case 3:
        add(50, minR: 0.8, maxR: 3.0, minSpd: 10, maxSpd: 22, minA: 0.25, maxA: 0.70, palette: _bloodRed.length);
      case 4:
        add(8,  minR: 2.5, maxR: 5.0, minSpd: 5, maxSpd: 14, minA: 0.35, maxA: 0.70, palette: _radioGreen.length);
        add(70, minR: 0.4, maxR: 1.8, minSpd: 6, maxSpd: 18, minA: 0.20, maxA: 0.55, palette: _radioGreen.length);
      case 5:
        add(12, minR: 1.2, maxR: 3.0, minSpd: 10, maxSpd: 22, minA: 0.40, maxA: 0.80, palette: _iceWhite.length);
        add(110, minR: 0.3, maxR: 1.0, minSpd: 8, maxSpd: 20, minA: 0.20, maxA: 0.60, palette: _iceWhite.length);
      case 6:
        add(12, minR: 1.5, maxR: 4.0, minSpd: 15, maxSpd: 35, minA: 0.40, maxA: 0.80, palette: _emberOrange.length, rising: true);
        add(55, minR: 0.4, maxR: 1.8, minSpd: 12, maxSpd: 28, minA: 0.25, maxA: 0.70, palette: _emberOrange.length, rising: true);
      case 7:
        add(40, minR: 0.2, maxR: 0.9, minSpd: 2, maxSpd: 6, minA: 0.05, maxA: 0.22, palette: _dustMote.length);
      case 8:
        add(22, minR: 0.6, maxR: 2.5, minSpd: 2, maxSpd: 7, minA: 0.05, maxA: 0.18, palette: _forestWisp.length);
      default:
        add(50, minR: 0.4, maxR: 1.8, minSpd: 12, maxSpd: 30, minA: 0.25, maxA: 0.75, palette: _neuralRed.length);
    }
  }

  @override
  void update(double dt) {
    _t += dt;
    final h = game.size.y;
    for (final p in _particles) {
      p.y += p.speed * dt;
      if (p.speed > 0 && p.y > h + 4) p.y = -4;
      if (p.speed < 0 && p.y < -4) p.y = h + 4;
    }
  }

  @override
  void render(Canvas canvas) {
    switch (game.bossPhase % 10) {
      case 0: _renderCityRuins(canvas);
      case 1: _renderIndustrial(canvas);
      case 2: _renderToxicSewers(canvas);
      case 3: _renderBloodStreets(canvas);
      case 4: _renderRadioactive(canvas);
      case 5: _renderFrozenWastes(canvas);
      case 6: _renderBurningCity(canvas);
      case 7: _renderBunker(canvas);
      case 8: _renderDeadForest(canvas);
      default: _renderHordeMind(canvas);
    }
  }

  // ── Phase 0: City Ruins ───────────────────────────────────────────────────

  void _renderCityRuins(Canvas canvas) {
    final sz = game.size;

    // Sky gradient — overcast ruins dark
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF0C0E0A), const Color(0xFF181A14), const Color(0xFF1E2018),
      ], [0.0, 0.55, 1.0]));

    // Distant haze band
    canvas.drawRect(Rect.fromLTWH(0, sz.y * 0.40, sz.x, sz.y * 0.18),
      Paint()..color = const Color(0x0A6A7060)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Building silhouettes
    final wallPaint = Paint()..color = const Color(0xFF1A1E18);
    final darkWall = Paint()..color = const Color(0xFF141612);
    final winOffPaint = Paint()..color = const Color(0xFF0C0E0A);
    final winOnPaint = Paint()..color = const Color(0x33FFCC66);

    for (final b in _buildings) {
      final bx = sz.x * b[0];
      final bw = sz.x * b[1];
      final bh = sz.y * b[2];
      final by = sz.y - bh;
      final isDamaged = b[5] > 0.5;

      // Shadow
      canvas.drawRect(Rect.fromLTWH(bx - bw / 2 + 3, by, bw, bh),
        Paint()..color = const Color(0x22000000));

      // Main face
      canvas.drawRect(Rect.fromLTWH(bx - bw / 2, by, bw, bh), wallPaint);

      // Damaged top edge — jagged cutout
      if (isDamaged) {
        final notchW = bw * 0.28;
        final notchH = sz.y * 0.04;
        canvas.drawRect(Rect.fromLTWH(bx - bw * 0.1, by - 2, notchW, notchH), darkWall);
        canvas.drawRect(Rect.fromLTWH(bx + bw * 0.20, by - 1, notchW * 0.6, notchH * 0.6), darkWall);
      }

      // Windows
      final cols = b[3].toInt();
      final rows = b[4].toInt();
      final winW = bw / (cols * 1.8 + 1);
      final winH = bh / (rows * 2.0 + 1);
      for (int c = 0; c < cols; c++) {
        for (int row = 0; row < rows; row++) {
          final wx = bx - bw / 2 + winW * 0.9 + c * (winW * 1.8);
          final wy = by + winH * 0.8 + row * (winH * 2.0);
          final lit = (c + row * 3 + b[3].toInt()) % 7 == 0;
          canvas.drawRect(Rect.fromLTWH(wx, wy, winW, winH), lit ? winOnPaint : winOffPaint);
        }
      }

      // Side shadow
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 3, by, 3, bh), darkWall);
    }

    // Rubble piles at bottom
    final rubblePaint = Paint()..color = const Color(0xFF222420);
    canvas.drawOval(Rect.fromCenter(center: Offset(sz.x * 0.15, sz.y - 6), width: sz.x * 0.18, height: 14), rubblePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(sz.x * 0.55, sz.y - 5), width: sz.x * 0.22, height: 11), rubblePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(sz.x * 0.85, sz.y - 7), width: sz.x * 0.16, height: 13), rubblePaint);

    // Ash particles
    final p = Paint();
    for (final s in _particles) {
      p.color = _ashGrey[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, p);
    }
  }

  // ── Phase 1: Industrial Wasteland ─────────────────────────────────────────

  void _renderIndustrial(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF1A1208), const Color(0xFF2A1C10), const Color(0xFF362410),
      ], [0.0, 0.50, 1.0]));

    // Horizontal pipe runs
    final pipePaint = Paint()..color = const Color(0xFF2A2018);
    final pipeHighlight = Paint()..color = const Color(0xFF3A3020)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final py = sz.y * (0.30 + i * 0.18);
      canvas.drawRect(Rect.fromLTWH(0, py - 4, sz.x, 8), pipePaint);
      canvas.drawRect(Rect.fromLTWH(0, py - 4, sz.x, 8), pipeHighlight);
      // Flange rings
      for (double fx = sz.x * 0.15; fx < sz.x; fx += sz.x * 0.22) {
        canvas.drawRect(Rect.fromCenter(center: Offset(fx, py), width: 10, height: 14),
          Paint()..color = const Color(0xFF1E1810));
        canvas.drawRect(Rect.fromCenter(center: Offset(fx, py), width: 10, height: 14),
          Paint()..color = const Color(0xFF2E2818)..style = PaintingStyle.stroke..strokeWidth = 0.8);
      }
    }

    // Chimneys
    final chimPaint = Paint()..color = const Color(0xFF181210);
    for (final c in _chimneys) {
      final cx = sz.x * c[0];
      final cw = sz.x * c[1];
      final ch = sz.y * c[2];
      canvas.drawRect(Rect.fromLTWH(cx - cw / 2, sz.y - ch, cw, ch), chimPaint);
      // Band rings on chimney
      for (double ry = sz.y - ch * 0.4; ry < sz.y; ry += ch * 0.15) {
        canvas.drawRect(Rect.fromLTWH(cx - cw / 2 - 1, ry, cw + 2, 3),
          Paint()..color = const Color(0xFF222018));
      }
      // Smoke plume
      final smokeAlpha = (math.sin(_t * 0.4 + c[0] * 5) * 0.12 + 0.20).clamp(0.0, 0.5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, sz.y - ch - sz.y * 0.06), width: cw * 4, height: sz.y * 0.10),
        Paint()..color = Color(0xFF888880).withAlpha((smokeAlpha * 255).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + sz.x * 0.02, sz.y - ch - sz.y * 0.11), width: cw * 3, height: sz.y * 0.07),
        Paint()..color = Color(0xFF777770).withAlpha((smokeAlpha * 200).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // Ash particles
    final p = Paint();
    for (final s in _particles) {
      p.color = _smokeGrey[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, p);
    }

    // Ground fog
    canvas.drawRect(Rect.fromLTWH(0, sz.y * 0.72, sz.x, sz.y * 0.28),
      Paint()..shader = Gradient.linear(Offset(0, sz.y * 0.72), Offset(0, sz.y), [
        const Color(0x00362410), const Color(0x1A2A1A08),
      ]));
  }

  // ── Phase 2: Toxic Sewers ─────────────────────────────────────────────────

  void _renderToxicSewers(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF001500));

    // Sewer tunnel arch walls (left and right)
    final wallPaint = Paint()..color = const Color(0xFF0A1A08);
    final wallEdge = Paint()..color = const Color(0xFF1A3A10)..style = PaintingStyle.stroke..strokeWidth = 2;

    // Left arch wall
    final leftArch = Path()
      ..moveTo(0, 0)
      ..lineTo(sz.x * 0.18, 0)
      ..quadraticBezierTo(sz.x * 0.05, sz.y * 0.40, sz.x * 0.14, sz.y)
      ..lineTo(0, sz.y)
      ..close();
    canvas.drawPath(leftArch, wallPaint);
    canvas.drawPath(leftArch, wallEdge);

    // Right arch wall
    final rightArch = Path()
      ..moveTo(sz.x, 0)
      ..lineTo(sz.x * 0.82, 0)
      ..quadraticBezierTo(sz.x * 0.95, sz.y * 0.40, sz.x * 0.86, sz.y)
      ..lineTo(sz.x, sz.y)
      ..close();
    canvas.drawPath(rightArch, wallPaint);
    canvas.drawPath(rightArch, wallEdge);

    // Ceiling with crack lines
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y * 0.06), Paint()..color = const Color(0xFF0A1A08));
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(sz.x * (0.15 + i * 0.17), 0),
        Offset(sz.x * (0.12 + i * 0.17), sz.y * 0.05),
        Paint()..color = const Color(0xFF1A3A12)..strokeWidth = 0.8,
      );
    }

    // Dripping stalactites from ceiling
    final dripGlow = Paint()..color = const Color(0x4444FF44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final dripPaint = Paint()..color = const Color(0xFF226614);

    for (final d in _sewDrips) {
      final dx = sz.x * d[0];
      final dlen = sz.y * d[1];
      // Stalactite body
      final stalPath = Path()
        ..moveTo(dx - 3, 0)
        ..lineTo(dx + 3, 0)
        ..lineTo(dx, dlen)
        ..close();
      canvas.drawPath(stalPath, dripPaint);
      canvas.drawPath(stalPath, dripGlow);

      // Animated drip drop
      final dropPos = ((_t * d[2] + d[3]) % (sz.y + dlen));
      if (dropPos < sz.y * 0.85) {
        final drop = dlen + dropPos * 0.5;
        canvas.drawCircle(Offset(dx, drop.clamp(dlen, sz.y * 0.85)),
          3.0, Paint()..color = const Color(0xFF44AA22));
      }
    }

    // Toxic pools at bottom with glow
    final poolGlow = Paint()..color = const Color(0x5544FF44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final poolPaint = Paint()..color = const Color(0xFF1A4A0A);

    canvas.drawRect(Rect.fromLTWH(0, sz.y - sz.y * 0.08, sz.x, sz.y * 0.08), poolPaint);
    canvas.drawRect(Rect.fromLTWH(0, sz.y - sz.y * 0.08, sz.x, sz.y * 0.08), poolGlow);

    // Bubbles rising from pool surface (pulsing)
    for (int i = 0; i < 6; i++) {
      final bx = sz.x * (0.12 + i * 0.16);
      final pulse = math.sin(_t * 2.5 + i * 1.3) * 0.5 + 0.5;
      canvas.drawCircle(Offset(bx, sz.y * 0.92 - pulse * 8),
        2.5 + pulse * 1.5,
        Paint()..color = Color(0xFF44CC22).withAlpha((pulse * 180).round()));
    }

    // Particles (drips + rising bubbles)
    final pp = Paint();
    for (final s in _particles) {
      final c = _toxicGreen[s.colorIndex];
      if (s.speed < 0) {
        // Rising bubble — draw as ring
        pp.color = c.withAlpha((s.alpha * 140).round());
        pp.style = PaintingStyle.stroke;
        pp.strokeWidth = 0.8;
      } else {
        pp.color = c.withAlpha((s.alpha * 255).round());
        pp.style = PaintingStyle.fill;
        pp.strokeWidth = 0;
      }
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.style = PaintingStyle.fill;
  }

  // ── Phase 3: Blood Streets ────────────────────────────────────────────────

  void _renderBloodStreets(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF160003), const Color(0xFF0E0001), const Color(0xFF0A0000),
      ], [0.0, 0.45, 1.0]));

    // Blood moon
    final moonAlpha = (math.sin(_t * 0.18) * 20 + 55).round();
    canvas.drawCircle(Offset(sz.x * 0.72, sz.y * 0.12),
      sz.x * 0.10,
      Paint()..color = Color(0xFFCC2200).withAlpha(moonAlpha)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.drawCircle(Offset(sz.x * 0.72, sz.y * 0.12),
      sz.x * 0.07,
      Paint()..color = Color(0xFFDD3300).withAlpha(moonAlpha + 40));

    // Road center dashes
    final dashPaint = Paint()..color = const Color(0x22888880)..strokeWidth = 3;
    for (double dy = 0; dy < sz.y; dy += sz.y * 0.10) {
      canvas.drawLine(Offset(sz.x / 2, dy), Offset(sz.x / 2, dy + sz.y * 0.05), dashPaint);
    }

    // Cracked asphalt lines
    final crackPaint = Paint()..color = const Color(0x18444440)..strokeWidth = 0.8;
    canvas.drawLine(Offset(sz.x * 0.22, 0), Offset(sz.x * 0.28, sz.y), crackPaint);
    canvas.drawLine(Offset(sz.x * 0.65, 0), Offset(sz.x * 0.60, sz.y), crackPaint);

    // Abandoned car wreck silhouette
    final carPaint = Paint()..color = const Color(0xFF181210);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(sz.x * 0.20, sz.y * 0.70), width: sz.x * 0.22, height: sz.y * 0.07),
        const Radius.circular(4)),
      carPaint);
    // Car cabin
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sz.x * 0.10, sz.y * 0.66, sz.x * 0.12, sz.y * 0.055),
        const Radius.circular(3)),
      Paint()..color = const Color(0xFF141010));
    // Wheels
    canvas.drawCircle(Offset(sz.x * 0.12, sz.y * 0.74), sz.x * 0.025, carPaint);
    canvas.drawCircle(Offset(sz.x * 0.28, sz.y * 0.74), sz.x * 0.025, carPaint);

    // Blood pools
    final poolGlow = Paint()..color = const Color(0x44AA0000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (final pool in _bloodPools) {
      final px = sz.x * pool[0];
      final pw = sz.x * pool[1];
      final ph = sz.y * pool[2];
      final py = sz.y * pool[3];
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 2.5, height: ph * 2), poolGlow);
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 2, height: ph * 1.5),
        Paint()..color = const Color(0xFF6A0000));
    }

    // Blood drop particles
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _bloodRed[s.colorIndex].withAlpha((s.alpha * 255).round());
      // Elongated teardrop shape (tall oval)
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s.x, s.y), width: s.radius * 1.4, height: s.radius * 2.5),
        pp);
    }
  }

  // ── Phase 4: Radioactive Zone ─────────────────────────────────────────────

  void _renderRadioactive(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF060D00), const Color(0xFF0A1400), const Color(0xFF0C1800),
      ], [0.0, 0.50, 1.0]));

    // Faint radiation warning symbol
    final symCx = sz.x * 0.82;
    final symCy = sz.y * 0.18;
    final symR = sz.x * 0.055;
    final symPaint = Paint()..color = const Color(0x12AACC00);
    for (int i = 0; i < 3; i++) {
      final a = i * math.pi * 2 / 3 - math.pi / 2;
      final wedge = Path()
        ..moveTo(symCx, symCy)
        ..lineTo(symCx + math.cos(a - 0.38) * symR * 1.8, symCy + math.sin(a - 0.38) * symR * 1.8)
        ..arcTo(Rect.fromCenter(center: Offset(symCx, symCy), width: symR * 3.6, height: symR * 3.6), a - 0.38, 0.76, false)
        ..close();
      canvas.drawPath(wedge, symPaint);
    }
    canvas.drawCircle(Offset(symCx, symCy), symR * 0.42, Paint()..color = const Color(0x15060D00));

    // Warning fence — diagonal hazard bands along left edge
    final fencePaint = Paint()..color = const Color(0x18888800);
    for (int i = 0; i < 8; i++) {
      final fy = sz.y * (i / 8.0);
      canvas.drawRect(Rect.fromLTWH(0, fy, sz.x * 0.025, sz.y / 16), fencePaint);
    }

    // Waste barrels
    for (final b in _barrels) {
      final bx = sz.x * b[0];
      final by = sz.y * b[1];
      const bw = 14.0, bh = 20.0;

      // Barrel body
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh), const Radius.circular(2)),
        Paint()..color = const Color(0xFF0A1A04));
      // Bands
      for (int ring = 0; ring < 3; ring++) {
        canvas.drawRect(Rect.fromCenter(center: Offset(bx, by - 7 + ring * 7), width: bw + 2, height: 2),
          Paint()..color = const Color(0xFF1A3008));
      }
      // Glowing lid with pulse
      final glow = (math.sin(_t * 1.8 + b[0] * 6) * 0.3 + 0.7);
      canvas.drawCircle(Offset(bx, by - bh / 2),
        bw * 0.55,
        Paint()..color = Color(0xFF88FF00).withAlpha((glow * 180).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(Offset(bx, by - bh / 2), bw * 0.38,
        Paint()..color = Color(0xFF44CC00).withAlpha((glow * 200).round()));
    }

    // Particles
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _radioGreen[s.colorIndex].withAlpha((s.alpha * 255).round());
      if (s.radius > 2.0) {
        pp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      } else {
        pp.maskFilter = null;
      }
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 5: Frozen Wastes ────────────────────────────────────────────────

  void _renderFrozenWastes(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF070E18), const Color(0xFF0A1520), const Color(0xFF0D1C28),
      ], [0.0, 0.50, 1.0]));

    // Blizzard wind streaks
    final windPaint = Paint()..color = const Color(0x12AACCFF)..strokeWidth = 0.6;
    for (int i = 0; i < 14; i++) {
      final wy = sz.y * (i / 14.0 + (_t * 0.08) % 0.10);
      final startX = (-50 + (_t * 80 + i * sz.x / 7) % (sz.x + 50));
      canvas.drawLine(Offset(startX, wy), Offset(startX - 60, wy + 8), windPaint);
    }

    // Ice formation ground
    canvas.drawRect(Rect.fromLTWH(0, sz.y - sz.y * 0.07, sz.x, sz.y * 0.07),
      Paint()..color = const Color(0xFF0E2035));

    // Ice spikes — from bottom and top
    for (final spike in _iceSpikes) {
      final sx = sz.x * spike[0];
      final slen = sz.y * spike[1];
      final sbw = sz.x * spike[2];
      final fromTop = spike[3] > 0.5;

      final sy = fromTop ? 0.0 : sz.y;
      final tip = fromTop ? slen : sz.y - slen;

      final spikePath = Path()
        ..moveTo(sx - sbw, sy)
        ..lineTo(sx + sbw, sy)
        ..lineTo(sx, tip)
        ..close();

      // Ice glow
      canvas.drawPath(spikePath,
        Paint()..color = const Color(0x3366AAFF)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      // Ice body — gradient from base to tip
      canvas.drawPath(spikePath, Paint()..color = const Color(0xFF1A4466));
      canvas.drawPath(spikePath,
        Paint()..color = const Color(0xAA88CCEE)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      // Highlight streak down center
      canvas.drawLine(Offset(sx, sy),
        Offset(sx, sy + (fromTop ? slen * 0.7 : -slen * 0.7)),
        Paint()..color = const Color(0x55CCEEFF)..strokeWidth = 0.8);
    }

    // Snowflake particles
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _iceWhite[s.colorIndex].withAlpha((s.alpha * 255).round());
      if (s.radius > 1.0) {
        // Larger flakes — draw as simple cross
        final r = s.radius;
        canvas.drawLine(Offset(s.x - r, s.y), Offset(s.x + r, s.y), pp..strokeWidth = r * 0.6);
        canvas.drawLine(Offset(s.x, s.y - r), Offset(s.x, s.y + r), pp..strokeWidth = r * 0.6);
        pp.strokeWidth = 0;
      } else {
        canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
      }
    }
  }

  // ── Phase 6: Burning City ─────────────────────────────────────────────────

  void _renderBurningCity(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF1A0400), const Color(0xFF2A0800), const Color(0xFF3A0C00),
      ], [0.0, 0.50, 1.0]));

    // Fire glow on the horizon
    canvas.drawRect(Rect.fromLTWH(0, sz.y * 0.55, sz.x, sz.y * 0.45),
      Paint()..shader = Gradient.linear(Offset(0, sz.y * 0.55), Offset(0, sz.y), [
        const Color(0x00FF3300), const Color(0x1AFF4400),
      ])..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));

    // Building silhouettes — dark with burning windows
    final burntPaint = Paint()..color = const Color(0xFF120600);
    for (final b in _buildings) {
      final bx = sz.x * b[0];
      final bw = sz.x * b[1];
      final bh = sz.y * b[2] * 1.1;
      final by = sz.y - bh;

      canvas.drawRect(Rect.fromLTWH(bx - bw / 2, by, bw, bh), burntPaint);

      // Burning windows — orange flicker
      final cols = b[3].toInt();
      final rows = b[4].toInt();
      final winW = bw / (cols * 1.8 + 1);
      final winH = bh / (rows * 2.0 + 1);
      for (int c = 0; c < cols; c++) {
        for (int row = 0; row < rows; row++) {
          final wx = bx - bw / 2 + winW * 0.9 + c * winW * 1.8;
          final wy = by + winH * 0.8 + row * winH * 2.0;
          final flicker = math.sin(_t * (3 + c + row) + b[3]) * 0.4 + 0.6;
          final lit = (c + row + b[3].toInt()) % 3 != 0;
          if (lit) {
            canvas.drawRect(Rect.fromLTWH(wx, wy, winW, winH),
              Paint()..color = Color(0xFFFF6600).withAlpha((flicker * 200).round()));
          }
        }
      }
    }

    // Ground fire at base — animated wave
    for (int i = 0; i < 5; i++) {
      final fx = sz.x * (0.05 + i * 0.22);
      final fh = sz.y * (0.06 + math.sin(_t * 3 + i) * 0.02);
      for (int j = 0; j < 3; j++) {
        final jitter = math.sin(_t * (4 + j) + i * 2) * 6;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(fx + jitter, sz.y - fh * j * 0.4), width: sz.x * 0.08, height: fh),
          Paint()..color = [
            const Color(0x88FF2200), const Color(0x66FF6600), const Color(0x44FFAA00),
          ][j]..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
    }

    // Ember particles (rising)
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _emberOrange[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = s.radius > 1.5 ? const MaskFilter.blur(BlurStyle.normal, 3) : null;
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 7: Underground Bunker ───────────────────────────────────────────

  void _renderBunker(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF060608));

    // Ceiling slab
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y * 0.06),
      Paint()..color = const Color(0xFF0E0E12));

    // Floor slab
    canvas.drawRect(Rect.fromLTWH(0, sz.y - sz.y * 0.05, sz.x, sz.y * 0.05),
      Paint()..color = const Color(0xFF0A0A0E));

    // Fluorescent light strips at ceiling — with flicker
    for (int i = 0; i < 4; i++) {
      final lx = sz.x * (0.12 + i * 0.25);
      final flicker = math.sin(_t * 8 + i * 2.3) > 0.96 ? 0.1 : 1.0;
      canvas.drawRect(Rect.fromCenter(center: Offset(lx, sz.y * 0.05), width: sz.x * 0.16, height: 4),
        Paint()..color = Color(0xFFEEEECC).withAlpha((flicker * 100).round()));
      // Light cone from strip
      canvas.drawRect(Rect.fromLTWH(lx - sz.x * 0.08, sz.y * 0.05, sz.x * 0.16, sz.y * 0.15),
        Paint()..shader = Gradient.linear(
          Offset(lx, sz.y * 0.05), Offset(lx, sz.y * 0.20),
          [Color(0xFFDDDDAA).withAlpha((flicker * 18).round()), const Color(0x00DDDDAA)],
        ));
    }

    // Concrete pillars
    for (final pl in _pillars) {
      final px = sz.x * pl[0];
      const pw = 18.0;
      // Pillar body
      canvas.drawRect(Rect.fromLTWH(px - pw / 2, 0, pw, sz.y),
        Paint()..color = const Color(0xFF0D0D11));
      // Pillar edge highlights
      canvas.drawRect(Rect.fromLTWH(px - pw / 2, 0, 2, sz.y),
        Paint()..color = const Color(0xFF161618));
      canvas.drawRect(Rect.fromLTWH(px + pw / 2 - 2, 0, 2, sz.y),
        Paint()..color = const Color(0xFF0A0A0C));
      // Horizontal brace lines
      for (double bry = sz.y * 0.20; bry < sz.y; bry += sz.y * 0.22) {
        canvas.drawRect(Rect.fromLTWH(px - pw / 2 - 4, bry - 2, pw + 8, 4),
          Paint()..color = const Color(0xFF111115));
      }
    }

    // Grid lines on floor
    final gridPaint = Paint()..color = const Color(0x0A888888)..strokeWidth = 0.5;
    for (double gx = 0; gx < sz.x; gx += sz.x / 8) {
      canvas.drawLine(Offset(gx, sz.y - sz.y * 0.05), Offset(gx, sz.y), gridPaint);
    }

    // Dust motes
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _dustMote[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
  }

  // ── Phase 8: Dead Forest ──────────────────────────────────────────────────

  void _renderDeadForest(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(Offset.zero, Offset(0, sz.y), [
        const Color(0xFF030100), const Color(0xFF060200), const Color(0xFF080300),
      ], [0.0, 0.45, 1.0]));

    // Fog patches at different heights
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, sz.y * (0.30 + i * 0.20), sz.x, sz.y * 0.12),
        Paint()..color = const Color(0x08111008)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));
    }

    // Dead trees
    final trunkPaint = Paint()..color = const Color(0xFF1A0D00);
    final branchPaint = Paint()..color = const Color(0xFF140A00)..style = PaintingStyle.stroke;

    for (final t in _trees) {
      final tx = sz.x * t[0];
      final th = sz.y * t[1];
      final tw = sz.x * t[2];

      // Tapered trunk
      final trunkPath = Path()
        ..moveTo(tx - tw, sz.y)
        ..lineTo(tx + tw, sz.y)
        ..lineTo(tx + tw * 0.35, sz.y - th)
        ..lineTo(tx - tw * 0.35, sz.y - th)
        ..close();
      canvas.drawPath(trunkPath, trunkPaint);

      // Branches (5 per tree, pre-baked angles at index 3..7, lens at 8..12)
      for (int b = 0; b < 5; b++) {
        final angle = t[3 + b];
        final len = t[8 + b] * sz.x;
        final branchY = sz.y - th * (0.28 + b * 0.14);
        final endX = tx + math.sin(angle) * len;
        final endY = branchY - math.cos(angle).abs() * len * 0.55;
        branchPaint.strokeWidth = (2.2 - b * 0.32).clamp(0.5, 2.0);
        canvas.drawLine(Offset(tx, branchY), Offset(endX, endY), branchPaint);
        // Sub-branch
        if (b < 3) {
          canvas.drawLine(
            Offset(tx + math.sin(angle) * len * 0.55, branchY - math.cos(angle).abs() * len * 0.30),
            Offset(endX + math.sin(angle + 0.6) * len * 0.35, endY - 8),
            branchPaint..strokeWidth = 0.8);
        }
      }
    }

    // Wisp particles
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _forestWisp[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 9: Horde Mind ───────────────────────────────────────────────────

  void _renderHordeMind(Canvas canvas) {
    final sz = game.size;

    // Pulsing crimson sky
    final pulse = math.sin(_t * 1.2) * 0.5 + 0.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.radial(
        Offset(sz.x / 2, sz.y * 0.40), sz.x * 0.80,
        [
          Color.lerp(const Color(0xFF1A0005), const Color(0xFF2A0008), pulse)!,
          const Color(0xFF0A0002),
        ],
      ));

    // Heartbeat rings — expand on beat
    final beat = (_t * 0.85) % 1.0;
    final ringR = sz.x * 0.15 + beat * sz.x * 0.55;
    final ringAlpha = ((1 - beat) * 100).round();
    canvas.drawCircle(Offset(sz.x / 2, sz.y * 0.38), ringR,
      Paint()..color = Color(0xFFCC0033).withAlpha(ringAlpha)
             ..style = PaintingStyle.stroke
             ..strokeWidth = 2.5);

    final beat2 = ((_t * 0.85) + 0.5) % 1.0;
    final r2 = sz.x * 0.15 + beat2 * sz.x * 0.55;
    canvas.drawCircle(Offset(sz.x / 2, sz.y * 0.38), r2,
      Paint()..color = Color(0xFFAA0022).withAlpha(((1 - beat2) * 60).round())
             ..style = PaintingStyle.stroke
             ..strokeWidth = 1.5);

    // Neural vein network
    final veinPaint = Paint()..style = PaintingStyle.stroke;
    for (final v in _veins) {
      final x1 = sz.x * v[0]; final y1 = sz.y * v[1];
      final x2 = sz.x * v[2]; final y2 = sz.y * v[3];
      final w = v[4];
      final pulseA = (math.sin(_t * 1.5 + v[0] * 8) * 0.35 + 0.55).clamp(0.0, 1.0);
      veinPaint
        ..color = Color(0xFFCC0033).withAlpha((pulseA * 160).round())
        ..strokeWidth = w;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), veinPaint);

      // Node at junction
      canvas.drawCircle(Offset(x1, y1), w * 1.8,
        Paint()..color = Color(0xFFDD0044).withAlpha((pulseA * 200).round()));
    }

    // Neural spark particles
    final pp = Paint();
    for (final s in _particles) {
      pp.color = _neuralRed[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _Particle {
  double x, y, radius, speed, alpha;
  int colorIndex;
  _Particle({
    required this.x, required this.y, required this.radius,
    required this.speed, required this.alpha, required this.colorIndex,
  });
}
