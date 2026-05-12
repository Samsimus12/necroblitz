import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../necroblitz_game.dart';

// ── Pre-generated scene layouts ───────────────────────────────────────────────

// Building rooftop footprints: [xFrac, yFrac, wFrac, hFrac]
final _rooftops = _mkList(42, 8, (r) => [
  r.nextDouble() * 0.80 + 0.10, r.nextDouble() * 0.80 + 0.10,
  r.nextDouble() * 0.20 + 0.10, r.nextDouble() * 0.16 + 0.08,
]);

// Ground detail / rubble: [xFrac, yFrac, rFrac, angle]
final _rubble = _mkList(137, 16, (r) => [
  r.nextDouble(), r.nextDouble(),
  r.nextDouble() * 0.025 + 0.008, r.nextDouble() * math.pi * 2,
]);

// Tree stumps (top-down circles): [xFrac, yFrac, rFrac]
final _stumps = _mkList(73, 10, (r) => [
  r.nextDouble() * 0.85 + 0.07, r.nextDouble() * 0.85 + 0.07,
  r.nextDouble() * 0.020 + 0.012,
]);

// Barrel tops: [xFrac, yFrac]
final _barrels = _mkList(91, 6, (r) => [
  r.nextDouble() * 0.76 + 0.12, r.nextDouble() * 0.76 + 0.12,
]);

// Liquid pools: [xFrac, yFrac, wFrac, hFrac]
final _pools = _mkList(55, 7, (r) => [
  r.nextDouble(), r.nextDouble(),
  r.nextDouble() * 0.12 + 0.05, r.nextDouble() * 0.05 + 0.02,
]);

// Ice patches: [xFrac, yFrac, wFrac, hFrac]
final _icePatches = _mkList(19, 9, (r) => [
  r.nextDouble(), r.nextDouble(),
  r.nextDouble() * 0.10 + 0.04, r.nextDouble() * 0.04 + 0.015,
]);

// Neural veins: [x1Frac, y1Frac, x2Frac, y2Frac, lineW]
final _veins = _mkList(201, 22, (r) {
  final cx = 0.20 + r.nextDouble() * 0.60;
  final cy = 0.12 + r.nextDouble() * 0.76;
  final ang = r.nextDouble() * math.pi * 2;
  final len = r.nextDouble() * 0.22 + 0.06;
  return [cx, cy, cx + math.cos(ang) * len, cy + math.sin(ang) * len,
          r.nextDouble() * 1.6 + 0.4];
});

// Crate tops: [xFrac, yFrac, sizeFrac, angleFrac]
final _crates = _mkList(63, 6, (r) => [
  r.nextDouble() * 0.80 + 0.10, r.nextDouble() * 0.80 + 0.10,
  r.nextDouble() * 0.030 + 0.018, r.nextDouble(),
]);

// Fire patches: [xFrac, yFrac, sizeFrac]
final _firePatches = _mkList(29, 8, (r) => [
  r.nextDouble(), r.nextDouble(), r.nextDouble() * 0.040 + 0.020,
]);

// Dead leaves: [xFrac, yFrac, wFrac, angle]
final _leaves = _mkList(77, 40, (r) => [
  r.nextDouble(), r.nextDouble(),
  r.nextDouble() * 0.015 + 0.008, r.nextDouble() * math.pi,
]);

// Bone fragments: [xFrac, yFrac, lenFrac, angle]
final _bones = _mkList(99, 16, (r) => [
  r.nextDouble(), r.nextDouble(),
  r.nextDouble() * 0.020 + 0.010, r.nextDouble() * math.pi,
]);

List<List<double>> _mkList(int seed, int count, List<double> Function(math.Random) fn) {
  final r = math.Random(seed);
  return List.generate(count, (_) => fn(r));
}

// ── Particle palettes ─────────────────────────────────────────────────────────
const _ashGrey    = [Color(0xFF8A8A80), Color(0xFF7A7A72), Color(0xFF9A9A90)];
const _smokeGrey  = [Color(0xFF686860), Color(0xFF585850), Color(0xFF787870)];
const _toxicGreen = [Color(0xFF44FF44), Color(0xFF88FF00), Color(0xFF00CC44), Color(0xFFAAFF44), Color(0xFF66FF88)];
const _bloodRed   = [Color(0xFFCC1111), Color(0xFFDD3300), Color(0xFFBB2200)];
const _radioGreen = [Color(0xFF88CC00), Color(0xFF44AA00), Color(0xFFAAFF00), Color(0xFF226600)];
const _iceWhite   = [Color(0xFFCCEEFF), Color(0xFFAADDFF), Color(0xFF88CCFF), Color(0xFFEEF8FF), Color(0xFFFFFFFF)];
const _ember      = [Color(0xFFFF6600), Color(0xFFFF3300), Color(0xFFFFAA00), Color(0xFFFF8800)];
const _dustMote   = [Color(0xFFBBBBAA)];
const _forestWisp = [Color(0xFF331500), Color(0xFF221000), Color(0xFF441800), Color(0xFF110A00)];
const _neuralRed  = [Color(0xFFCC0044), Color(0xFFDD2266), Color(0xFFAA0033)];

// ── StarBackground (class name kept for codebase compatibility) ───────────────

class StarBackground extends Component with HasGameReference<NecroblitzGame> {
  final _particles = <_Particle>[];
  final _rng = math.Random();
  double _t = 0;

  // Pixel art tiles for sprite-rendered phases.
  final List<Image> _bgTiles = [];

  @override
  Future<void> onLoad() async {
    _spawnParticles();
    await _loadTilesForPhase(game.bossPhase % 10);
  }

  Future<void> _loadTilesForPhase(int phase) async {
    _bgTiles.clear();
    if (phase == 0) {
      for (int i = 0; i < 16; i++) {
        _bgTiles.add(await game.images.load('background/phase0/tile_$i.png'));
      }
    }
  }

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
      case 0: add(40, minR: 0.4, maxR: 1.5, minSpd: 6,  maxSpd: 14, minA: 0.10, maxA: 0.35, palette: _ashGrey.length);
      case 1: add(20, minR: 0.4, maxR: 1.2, minSpd: 3,  maxSpd: 9,  minA: 0.06, maxA: 0.20, palette: _smokeGrey.length);
      case 2:
        add(40, minR: 0.5, maxR: 2.0, minSpd: 8,  maxSpd: 20, minA: 0.25, maxA: 0.60, palette: _toxicGreen.length);
        add(12, minR: 1.0, maxR: 3.0, minSpd: 6,  maxSpd: 14, minA: 0.20, maxA: 0.45, palette: _toxicGreen.length, rising: true);
      case 3: add(40, minR: 0.8, maxR: 2.5, minSpd: 8,  maxSpd: 18, minA: 0.25, maxA: 0.60, palette: _bloodRed.length);
      case 4:
        add(6,  minR: 2.0, maxR: 4.5, minSpd: 4,  maxSpd: 10, minA: 0.30, maxA: 0.60, palette: _radioGreen.length);
        add(50, minR: 0.4, maxR: 1.5, minSpd: 5,  maxSpd: 14, minA: 0.18, maxA: 0.45, palette: _radioGreen.length);
      case 5:
        add(10, minR: 1.2, maxR: 2.5, minSpd: 14, maxSpd: 28, minA: 0.40, maxA: 0.80, palette: _iceWhite.length);
        add(80, minR: 0.3, maxR: 0.9, minSpd: 10, maxSpd: 22, minA: 0.20, maxA: 0.55, palette: _iceWhite.length);
      case 6:
        add(10, minR: 1.5, maxR: 3.5, minSpd: 12, maxSpd: 28, minA: 0.40, maxA: 0.75, palette: _ember.length, rising: true);
        add(40, minR: 0.4, maxR: 1.5, minSpd: 10, maxSpd: 24, minA: 0.25, maxA: 0.60, palette: _ember.length, rising: true);
      case 7: add(30, minR: 0.2, maxR: 0.8, minSpd: 1,  maxSpd: 4,  minA: 0.05, maxA: 0.18, palette: _dustMote.length);
      case 8: add(18, minR: 0.6, maxR: 2.0, minSpd: 2,  maxSpd: 5,  minA: 0.05, maxA: 0.15, palette: _forestWisp.length);
      default: add(40, minR: 0.4, maxR: 1.5, minSpd: 10, maxSpd: 24, minA: 0.25, maxA: 0.65, palette: _neuralRed.length);
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

  // ── Phase 0: City Ruins ────────────────────────────────────────────────────

  void _renderCityRuins(Canvas canvas) {
    final sz = game.size;

    if (_bgTiles.isNotEmpty) {
      // Pixel art tile grid — deterministic tile selection per cell
      const tSize = 32.0;
      final cols = (sz.x / tSize).ceil() + 1;
      final rows = (sz.y / tSize).ceil() + 1;
      final paint = Paint();
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
          final idx = (col * 17 + row * 31 + col * row * 3) % _bgTiles.length;
          final img = _bgTiles[idx];
          final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
          final dst = Rect.fromLTWH(col * tSize, row * tSize, tSize, tSize);
          canvas.drawImageRect(img, src, dst, paint);
        }
      }
    } else {
      // Fallback while tiles load
      canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
        Paint()..color = const Color(0xFF252523));
    }

    // Manhole covers drawn on top of tile layer
    _drawManhole(canvas, Offset(sz.x * 0.30, sz.y * 0.44), 9);
    _drawManhole(canvas, Offset(sz.x * 0.70, sz.y * 0.72), 8);
    _drawManhole(canvas, Offset(sz.x * 0.50, sz.y * 0.20), 7);

    // Building rooftop footprints seen from above
    final roofPaint = Paint()..color = const Color(0xFF1C1C1A);
    final roofEdge = Paint()
      ..color = const Color(0xFF303030)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final r in _rooftops) {
      final rw = sz.x * r[2], rh = sz.y * r[3];
      final rx = sz.x * r[0] - rw / 2, ry = sz.y * r[1] - rh / 2;
      canvas.drawRect(Rect.fromLTWH(rx, ry, rw, rh), roofPaint);
      canvas.drawRect(Rect.fromLTWH(rx, ry, rw, rh), roofEdge);
      canvas.drawRect(Rect.fromLTWH(rx + 4, ry + 4, 8, 6),
        Paint()..color = const Color(0xFF222220));
    }

    // Animated ash particles
    final p = Paint();
    for (final s in _particles) {
      p.color = _ashGrey[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, p);
    }
  }

  void _drawManhole(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF1A1A18));
    canvas.drawCircle(center, r,
      Paint()..color = const Color(0xFF353533)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawLine(center + Offset(-r * 0.6, 0), center + Offset(r * 0.6, 0),
      Paint()..color = const Color(0xFF2A2A28)..strokeWidth = 1.0);
    canvas.drawLine(center + Offset(0, -r * 0.6), center + Offset(0, r * 0.6),
      Paint()..color = const Color(0xFF2A2A28)..strokeWidth = 1.0);
  }

  // ── Phase 1: Industrial Wasteland (top-down) ───────────────────────────────

  void _renderIndustrial(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF1E1C18));

    // Metal grate grid
    const gridSize = 28.0;
    final gridPaint = Paint()..color = const Color(0xFF2A2820)..strokeWidth = 1.2;
    final crossPaint = Paint()..color = const Color(0xFF252318)..strokeWidth = 0.5;
    for (double gx = 0; gx < sz.x; gx += gridSize) {
      canvas.drawLine(Offset(gx, 0), Offset(gx, sz.y), gridPaint);
    }
    for (double gy = 0; gy < sz.y; gy += gridSize) {
      canvas.drawLine(Offset(0, gy), Offset(sz.x, gy), gridPaint);
    }
    for (double gx = 0; gx < sz.x; gx += gridSize * 2) {
      for (double gy = 0; gy < sz.y; gy += gridSize * 2) {
        canvas.drawLine(Offset(gx, gy), Offset(gx + gridSize, gy + gridSize), crossPaint);
        canvas.drawLine(Offset(gx + gridSize, gy), Offset(gx, gy + gridSize), crossPaint);
      }
    }

    // Rust stain blobs
    for (final rb in _rubble.take(8)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]),
                        width: sz.x * rb[2] * 5, height: sz.x * rb[2] * 2.5),
        Paint()..color = const Color(0x44552200)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }

    // Pipe runs on floor (thick horizontal strips)
    final pipePaint = Paint()..color = const Color(0xFF2A2820);
    final pipeHighlight = Paint()..color = const Color(0xFF383630)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (final yFrac in [0.20, 0.48, 0.76]) {
      final py = sz.y * yFrac;
      canvas.drawRect(Rect.fromLTWH(0, py - 5, sz.x, 10), pipePaint);
      canvas.drawRect(Rect.fromLTWH(0, py - 5, sz.x, 10), pipeHighlight);
      // Flange joints along pipe
      for (double fx = sz.x * 0.12; fx < sz.x; fx += sz.x * 0.22) {
        canvas.drawCircle(Offset(fx, py), 6, Paint()..color = const Color(0xFF1E1C18));
        canvas.drawCircle(Offset(fx, py), 6,
          Paint()..color = const Color(0xFF3A3830)..style = PaintingStyle.stroke..strokeWidth = 1.0);
      }
    }

    // Oil/fluid spill patches
    for (final pool in _pools.take(3)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * pool[0], sz.y * pool[1]),
                        width: sz.x * pool[2] * 1.5, height: sz.y * pool[3] * 2),
        Paint()..color = const Color(0xFF141208));
    }

    // Barrel tops
    _drawBarrelTops(canvas, const Color(0xFF2A2820), const Color(0xFF444038), 8.0, glow: null);

    final p = Paint();
    for (final s in _particles) {
      p.color = _smokeGrey[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, p);
    }
  }

  void _drawBarrelTops(Canvas canvas, Color body, Color rim, double r, {required Color? glow}) {
    final sz = game.size;
    for (final b in _barrels) {
      final bx = sz.x * b[0], by = sz.y * b[1];
      if (glow != null) {
        canvas.drawCircle(Offset(bx, by), r * 1.8,
          Paint()..color = glow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
      canvas.drawCircle(Offset(bx, by), r, Paint()..color = body);
      canvas.drawCircle(Offset(bx, by), r,
        Paint()..color = rim..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawCircle(Offset(bx, by), r * 0.28, Paint()..color = rim);
    }
  }

  // ── Phase 2: Toxic Sewers (top-down) ──────────────────────────────────────

  void _renderToxicSewers(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF0E1A0C));

    // Concrete block seams
    const blockW = 50.0, blockH = 40.0;
    final seamPaint = Paint()..color = const Color(0xFF081208)..strokeWidth = 0.8;
    for (double gx = 0; gx < sz.x; gx += blockW) {
      canvas.drawLine(Offset(gx, 0), Offset(gx, sz.y), seamPaint);
    }
    for (double gy = 0; gy < sz.y; gy += blockH) {
      canvas.drawLine(Offset(0, gy), Offset(sz.x, gy), seamPaint);
    }

    // Drain channels cutting across the floor
    final drainPaint = Paint()..color = const Color(0xFF050D04);
    final drainGlow = Paint()
      ..color = const Color(0x2244CC00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (final rect in [
      Rect.fromLTWH(0, sz.y * 0.32 - 4, sz.x, 8),
      Rect.fromLTWH(0, sz.y * 0.68 - 4, sz.x, 8),
      Rect.fromLTWH(sz.x * 0.22 - 4, 0, 8, sz.y),
      Rect.fromLTWH(sz.x * 0.75 - 4, 0, 8, sz.y),
    ]) {
      canvas.drawRect(rect, drainPaint);
      canvas.drawRect(rect, drainGlow);
    }

    // Toxic pools (glowing green ovals on concrete floor)
    for (final pool in _pools) {
      final px = sz.x * pool[0], py = sz.y * pool[1];
      final pw = sz.x * pool[2], ph = sz.y * pool[3];
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 2, height: ph * 3),
        Paint()..color = const Color(0xAA44CC00)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 1.5, height: ph * 2.2),
        Paint()..color = const Color(0xFF1A4A0A));
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 0.7, height: ph),
        Paint()..color = const Color(0xFF44CC00));
    }

    // Slime smears on floor
    final slimePaint = Paint()..color = const Color(0x6644AA00);
    for (final rb in _rubble.take(6)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]), width: 22, height: 9),
        slimePaint);
    }

    // Manhole covers
    _drawManhole(canvas, Offset(sz.x * 0.50, sz.y * 0.50), 12);
    _drawManhole(canvas, Offset(sz.x * 0.20, sz.y * 0.80), 10);

    // Animated bubble pulses on pool surfaces
    for (int i = 0; i < 5; i++) {
      final bx = sz.x * (0.20 + i * 0.16);
      final by = sz.y * (0.30 + (i % 3) * 0.22);
      final pulse = math.sin(_t * 2.5 + i * 1.3) * 0.5 + 0.5;
      canvas.drawCircle(Offset(bx, by), 2.5 + pulse * 2,
        Paint()..color = Color(0xFF44CC22).withAlpha((pulse * 150).round()));
    }

    final pp = Paint();
    for (final s in _particles) {
      final c = _toxicGreen[s.colorIndex];
      if (s.speed < 0) {
        pp..color = c.withAlpha((s.alpha * 120).round())
          ..style = PaintingStyle.stroke..strokeWidth = 0.8;
      } else {
        pp..color = c.withAlpha((s.alpha * 255).round())
          ..style = PaintingStyle.fill..strokeWidth = 0;
      }
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.style = PaintingStyle.fill;
  }

  // ── Phase 3: Blood Streets (top-down) ─────────────────────────────────────

  void _renderBloodStreets(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF180002));

    // Asphalt surface seams
    final seamPaint = Paint()..color = const Color(0xFF100001)..strokeWidth = 0.6;
    for (double gy = 0; gy < sz.y; gy += 55) {
      canvas.drawLine(Offset(0, gy), Offset(sz.x, gy), seamPaint);
    }

    // Tyre marks burned into road
    final tyrePaint = Paint()
      ..color = const Color(0xFF0E0001)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(sz.x * 0.60, sz.y * 0.80),
                      width: sz.x * 0.60, height: sz.y * 0.60),
      -0.8, 1.2, false, tyrePaint);
    canvas.drawLine(Offset(sz.x * 0.10, sz.y * 0.20), Offset(sz.x * 0.45, sz.y * 0.35),
      tyrePaint..strokeWidth = 5);

    // Car rooftop silhouettes (top of abandoned cars seen from above)
    final carPaint = Paint()..color = const Color(0xFF110001);
    final carEdge = Paint()..color = const Color(0xFF200002)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.save();
    canvas.translate(sz.x * 0.22, sz.y * 0.30);
    canvas.rotate(0.18);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 28, height: 52),
        const Radius.circular(4)), carPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 28, height: 52),
        const Radius.circular(4)), carEdge);
    canvas.drawRect(Rect.fromCenter(center: const Offset(0, -8), width: 22, height: 14),
      Paint()..color = const Color(0xFF0A0001));
    canvas.restore();
    canvas.save();
    canvas.translate(sz.x * 0.75, sz.y * 0.62);
    canvas.rotate(-0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 26, height: 48),
        const Radius.circular(4)), carPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 26, height: 48),
        const Radius.circular(4)), carEdge);
    canvas.drawRect(Rect.fromCenter(center: const Offset(0, -7), width: 20, height: 13),
      Paint()..color = const Color(0xFF0A0001));
    canvas.restore();

    // Blood pool splats (irregular shapes on road)
    final bloodGlow = Paint()
      ..color = const Color(0x44AA0000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (final pool in _pools) {
      final px = sz.x * pool[0], py = sz.y * pool[1];
      final pw = sz.x * pool[2] * 2.0, ph = sz.y * pool[3] * 3.5;
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 1.4, height: ph), bloodGlow);
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw, height: ph * 0.8),
        Paint()..color = const Color(0xFF5A0000));
      for (int i = 0; i < 4; i++) {
        final a = pool[0] * 6 + i * math.pi / 2;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(px + math.cos(a) * pw * 0.7, py + math.sin(a) * ph * 0.6),
                          width: pw * 0.2, height: ph * 0.18),
          Paint()..color = const Color(0xFF3A0000));
      }
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _bloodRed[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s.x, s.y), width: s.radius * 1.2, height: s.radius * 2.2), pp);
    }
  }

  // ── Phase 4: Radioactive Zone (top-down) ──────────────────────────────────

  void _renderRadioactive(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF0A1200));

    // Crack network with glowing seams
    final crackPaint = Paint()..color = const Color(0xFF18260A)..strokeWidth = 1.0;
    final crackGlow = Paint()
      ..color = const Color(0x2244AA00)
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final cracks = [
      [0.0, 0.25, 0.40, 0.30], [0.40, 0.30, 0.65, 0.15],
      [0.40, 0.30, 0.35, 0.60], [0.35, 0.60, 0.10, 0.80],
      [0.35, 0.60, 0.70, 0.75], [0.70, 0.75, 1.0,  0.70],
    ];
    for (final c in cracks) {
      canvas.drawLine(Offset(sz.x * c[0], sz.y * c[1]), Offset(sz.x * c[2], sz.y * c[3]), crackPaint);
      canvas.drawLine(Offset(sz.x * c[0], sz.y * c[1]), Offset(sz.x * c[2], sz.y * c[3]), crackGlow);
    }

    // Caution stripes on floor
    final stripe1 = Paint()..color = const Color(0x11AAAA00);
    const stripeW = 18.0;
    for (double x = -sz.y; x < sz.x + sz.y; x += stripeW * 2) {
      final path = Path()
        ..moveTo(x, 0)..lineTo(x + stripeW, 0)
        ..lineTo(x + stripeW + sz.y, sz.y)..lineTo(x + sz.y, sz.y)..close();
      canvas.drawPath(path, stripe1);
    }

    // Radioactive liquid pools
    for (final pool in _pools.take(4)) {
      final px = sz.x * pool[0], py = sz.y * pool[1];
      final pw = sz.x * pool[2], ph = sz.y * pool[3];
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 2.2, height: ph * 3.2),
        Paint()..color = const Color(0x5544AA00)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: pw * 1.5, height: ph * 2.2),
        Paint()..color = const Color(0xFF112200));
    }

    // Barrel tops with radioactive glow
    _drawBarrelTops(canvas, const Color(0xFF0E1E06), const Color(0xFF44CC00), 9.0,
      glow: const Color(0x3044AA00));

    // Faint radiation symbol painted on ground
    final symCx = sz.x * 0.78, symCy = sz.y * 0.22;
    const symR = 22.0;
    final symPaint = Paint()..color = const Color(0x0DAACC00);
    for (int i = 0; i < 3; i++) {
      final a = i * math.pi * 2 / 3 - math.pi / 2;
      final wedge = Path()
        ..moveTo(symCx, symCy)
        ..lineTo(symCx + math.cos(a - 0.38) * symR, symCy + math.sin(a - 0.38) * symR)
        ..arcTo(Rect.fromCenter(center: Offset(symCx, symCy), width: symR * 2, height: symR * 2),
                a - 0.38, 0.76, false)
        ..close();
      canvas.drawPath(wedge, symPaint);
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _radioGreen[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = s.radius > 2.0 ? const MaskFilter.blur(BlurStyle.normal, 4) : null;
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 5: Frozen Wastes (top-down) ─────────────────────────────────────

  void _renderFrozenWastes(Canvas canvas) {
    final sz = game.size;

    // Snow-covered ground (bright!)
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFFCCD8E0));

    // Snow drift patches (subtle darker areas)
    for (final rb in _rubble.take(12)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]),
                        width: sz.x * rb[2] * 6, height: sz.x * rb[2] * 3),
        Paint()..color = const Color(0xFFBBCDD6));
    }

    // Ice patches — glossy brighter ovals on snow
    for (final ip in _icePatches) {
      final ix = sz.x * ip[0], iy = sz.y * ip[1];
      final iw = sz.x * ip[2], ih = sz.y * ip[3];
      canvas.drawOval(Rect.fromCenter(center: Offset(ix, iy), width: iw * 2.2, height: ih * 2.2),
        Paint()..color = const Color(0xFFD8EEF8));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ix - iw * 0.1, iy - ih * 0.2),
                        width: iw * 0.5, height: ih * 0.4),
        Paint()..color = const Color(0xBBFFFFFF));
    }

    // Frozen crack lines on ice
    final iceCrackPaint = Paint()..color = const Color(0xAAB0CCDD)..strokeWidth = 0.8;
    canvas.drawLine(Offset(sz.x * 0.20, sz.y * 0.15), Offset(sz.x * 0.35, sz.y * 0.45), iceCrackPaint);
    canvas.drawLine(Offset(sz.x * 0.35, sz.y * 0.45), Offset(sz.x * 0.55, sz.y * 0.40), iceCrackPaint);
    canvas.drawLine(Offset(sz.x * 0.35, sz.y * 0.45), Offset(sz.x * 0.28, sz.y * 0.70),
      iceCrackPaint..strokeWidth = 0.6);
    canvas.drawLine(Offset(sz.x * 0.70, sz.y * 0.30), Offset(sz.x * 0.80, sz.y * 0.65), iceCrackPaint);

    // Footprint trails pressed into snow
    final footPaint = Paint()..color = const Color(0xFFB8CCD4);
    for (int i = 0; i < 12; i++) {
      final fx = sz.x * (0.38 + (i % 2 == 0 ? 0.03 : -0.03));
      final fy = sz.y * (0.10 + i * 0.07);
      if (fy < sz.y * 0.98) {
        canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy), width: 7, height: 4), footPaint);
      }
    }

    // Blizzard wind streaks sweeping horizontally
    final windPaint = Paint()..color = const Color(0x44AACCEE)..strokeWidth = 0.7;
    for (int i = 0; i < 16; i++) {
      final wy = sz.y * (i / 16.0 + (_t * 0.04) % 0.07);
      final startX = ((_t * 90 + i * sz.x / 8) % (sz.x + 80)) - 80;
      canvas.drawLine(Offset(startX, wy), Offset(startX + 55, wy + 4), windPaint);
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _iceWhite[s.colorIndex].withAlpha((s.alpha * 255).round());
      if (s.radius > 1.0) {
        final r = s.radius;
        pp..strokeWidth = r * 0.5..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(s.x - r, s.y), Offset(s.x + r, s.y), pp);
        canvas.drawLine(Offset(s.x, s.y - r), Offset(s.x, s.y + r), pp);
        pp..style = PaintingStyle.fill..strokeWidth = 0;
      } else {
        canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
      }
    }
  }

  // ── Phase 6: Burning City (top-down) ──────────────────────────────────────

  void _renderBurningCity(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF180800));

    // Char / scorch marks on asphalt
    for (final rb in _rubble.take(10)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]),
                        width: sz.x * rb[2] * 6, height: sz.x * rb[2] * 3.5),
        Paint()..color = const Color(0xFF100500));
    }

    // Burnt car rooftop silhouettes
    final carPaint = Paint()..color = const Color(0xFF0E0400);
    final carEdge = Paint()..color = const Color(0xFF1A0800)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.save();
    canvas.translate(sz.x * 0.18, sz.y * 0.35);
    canvas.rotate(0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 26, height: 50),
        const Radius.circular(4)), carPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 26, height: 50),
        const Radius.circular(4)), carEdge);
    canvas.restore();
    canvas.save();
    canvas.translate(sz.x * 0.72, sz.y * 0.60);
    canvas.rotate(-0.15);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 24, height: 46),
        const Radius.circular(4)), carPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 24, height: 46),
        const Radius.circular(4)), carEdge);
    canvas.restore();

    // Fire patches on ground seen from directly above
    for (final fp in _firePatches) {
      final fx = sz.x * fp[0], fy = sz.y * fp[1];
      final fs = sz.x * fp[2];
      final flicker = math.sin(_t * (3.5 + fp[2] * 20) + fp[0] * 8) * 0.3 + 0.7;
      canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy), width: fs * 3.5, height: fs * 2),
        Paint()..color = Color(0xFF221000).withAlpha((flicker * 130).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy), width: fs * 2.0, height: fs * 1.2),
        Paint()..color = Color(0xFFFF3300).withAlpha((flicker * 170).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawOval(Rect.fromCenter(center: Offset(fx, fy), width: fs * 0.9, height: fs * 0.55),
        Paint()..color = Color(0xFFFFAA00).withAlpha((flicker * 210).round()));
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _ember[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = s.radius > 1.5 ? const MaskFilter.blur(BlurStyle.normal, 3) : null;
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 7: Underground Bunker (top-down) ─────────────────────────────────

  void _renderBunker(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF1C1C1E));

    // Checkerboard tile floor
    const tileSize = 40.0;
    final tileLightPaint = Paint()..color = const Color(0xFF222226);
    final tileDarkPaint  = Paint()..color = const Color(0xFF181818);
    bool altRow = false;
    for (double gy = 0; gy < sz.y; gy += tileSize) {
      bool altCol = altRow;
      for (double gx = 0; gx < sz.x; gx += tileSize) {
        canvas.drawRect(Rect.fromLTWH(gx + 0.5, gy + 0.5, tileSize - 1, tileSize - 1),
          altCol ? tileLightPaint : tileDarkPaint);
        altCol = !altCol;
      }
      altRow = !altRow;
    }
    final groutPaint = Paint()..color = const Color(0xFF0E0E10)..strokeWidth = 1.0;
    for (double gx = 0; gx < sz.x; gx += tileSize) {
      canvas.drawLine(Offset(gx, 0), Offset(gx, sz.y), groutPaint);
    }
    for (double gy = 0; gy < sz.y; gy += tileSize) {
      canvas.drawLine(Offset(0, gy), Offset(sz.x, gy), groutPaint);
    }

    // Painted floor arrows
    final arrowPaint = Paint()
      ..color = const Color(0x22888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    _drawFloorArrow(canvas, sz.x * 0.25, sz.y * 0.30, arrowPaint);
    _drawFloorArrow(canvas, sz.x * 0.65, sz.y * 0.55, arrowPaint);
    _drawFloorArrow(canvas, sz.x * 0.45, sz.y * 0.72, arrowPaint);

    // Grate opening on floor
    canvas.drawRect(Rect.fromCenter(center: Offset(sz.x * 0.80, sz.y * 0.20), width: 20, height: 12),
      Paint()..color = const Color(0xFF0C0C0E));
    canvas.drawRect(Rect.fromCenter(center: Offset(sz.x * 0.80, sz.y * 0.20), width: 20, height: 12),
      Paint()..color = const Color(0xFF282828)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(sz.x * 0.80 - 8, sz.y * 0.20 - 4 + i * 3.0),
        Offset(sz.x * 0.80 + 8, sz.y * 0.20 - 4 + i * 3.0),
        Paint()..color = const Color(0xFF1E1E20)..strokeWidth = 0.8);
    }

    // Crate tops (wood crates seen from above)
    for (final c in _crates) {
      final cx = sz.x * c[0], cy = sz.y * c[1];
      final cs = sz.x * c[2];
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(c[3] * math.pi / 4);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: cs * 2, height: cs * 2),
        Paint()..color = const Color(0xFF2A2218));
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: cs * 2, height: cs * 2),
        Paint()..color = const Color(0xFF3A3228)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawLine(Offset(-cs, 0), Offset(cs, 0),
        Paint()..color = const Color(0xFF241E14)..strokeWidth = 1.0);
      canvas.drawLine(Offset(0, -cs), Offset(0, cs),
        Paint()..color = const Color(0xFF241E14)..strokeWidth = 1.0);
      canvas.restore();
    }

    // Light reflections from ceiling fixtures
    for (int i = 0; i < 3; i++) {
      final lx = sz.x * (0.20 + i * 0.30);
      final flicker = math.sin(_t * 7 + i * 2.1) > 0.97 ? 0.05 : 1.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(lx, sz.y * 0.08), width: sz.x * 0.20, height: sz.y * 0.10),
        Paint()..color = Color(0xFFEEEECC).withAlpha((flicker * 15).round())
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _dustMote[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
  }

  void _drawFloorArrow(Canvas canvas, double cx, double cy, Paint paint) {
    const len = 16.0, head = 5.0;
    canvas.drawLine(Offset(cx - len, cy), Offset(cx + len, cy), paint);
    canvas.drawLine(Offset(cx + len - head, cy - head), Offset(cx + len, cy), paint);
    canvas.drawLine(Offset(cx + len - head, cy + head), Offset(cx + len, cy), paint);
  }

  // ── Phase 8: Dead Forest (top-down) ───────────────────────────────────────

  void _renderDeadForest(Canvas canvas) {
    final sz = game.size;

    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = const Color(0xFF0D0900));

    // Soil texture variation patches
    for (final rb in _rubble.take(14)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]),
                        width: sz.x * rb[2] * 4.5, height: sz.x * rb[2] * 2.5),
        Paint()..color = const Color(0xFF120C00));
    }

    // Dead leaves scattered on ground (flat ovals at various angles)
    const leafColors = [Color(0xFF3A2A00), Color(0xFF2A1800), Color(0xFF1E1200), Color(0xFF301E00)];
    for (int i = 0; i < _leaves.length; i++) {
      final leaf = _leaves[i];
      canvas.save();
      canvas.translate(sz.x * leaf[0], sz.y * leaf[1]);
      canvas.rotate(leaf[3]);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero,
                        width: sz.x * leaf[2] * 2, height: sz.x * leaf[2] * 0.8),
        Paint()..color = leafColors[i % leafColors.length]);
      canvas.restore();
    }

    // Tree stumps (top-down cross-section circles with growth rings)
    for (final stump in _stumps) {
      final sx = sz.x * stump[0], sy = sz.y * stump[1];
      final sr = sz.x * stump[2];
      canvas.drawCircle(Offset(sx, sy), sr,
        Paint()..color = const Color(0xFF1A0D00));
      canvas.drawCircle(Offset(sx, sy), sr,
        Paint()..color = const Color(0xFF2A1800)..style = PaintingStyle.stroke..strokeWidth = 2.0);
      canvas.drawCircle(Offset(sx, sy), sr * 0.7,
        Paint()..color = const Color(0xFF220F00)..style = PaintingStyle.stroke..strokeWidth = 0.8);
      canvas.drawCircle(Offset(sx, sy), sr * 0.4,
        Paint()..color = const Color(0xFF1E0C00)..style = PaintingStyle.stroke..strokeWidth = 0.6);
      canvas.drawCircle(Offset(sx, sy), sr * 0.15,
        Paint()..color = const Color(0xFF180A00));
    }

    // Root lines spreading from stumps across ground
    final rootPaint = Paint()..color = const Color(0xFF180C00)..strokeWidth = 1.0;
    final subRootPaint = Paint()..color = const Color(0xFF180C00)..strokeWidth = 0.5;
    for (final stump in _stumps) {
      final sx = sz.x * stump[0], sy = sz.y * stump[1];
      final sr = sz.x * stump[2];
      for (int i = 0; i < 6; i++) {
        final a = (i / 6.0) * math.pi * 2 + stump[0] * 2;
        final endX = sx + math.cos(a) * sr * 3.5;
        final endY = sy + math.sin(a) * sr * 3.5;
        canvas.drawLine(Offset(sx, sy), Offset(endX, endY), rootPaint);
        final a2 = a + 0.4;
        canvas.drawLine(
          Offset(sx + math.cos(a) * sr * 1.8, sy + math.sin(a) * sr * 1.8),
          Offset(sx + math.cos(a2) * sr * 3.0, sy + math.sin(a2) * sr * 3.0),
          subRootPaint);
      }
    }

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _forestWisp[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }

  // ── Phase 9: Horde Mind (top-down) ────────────────────────────────────────

  void _renderHordeMind(Canvas canvas) {
    final sz = game.size;
    final pulse = math.sin(_t * 1.2) * 0.5 + 0.5;

    // Pulsing organic flesh floor
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = Color.lerp(const Color(0xFF1A0005), const Color(0xFF220008), pulse)!);

    // Organic texture patches
    for (final rb in _rubble.take(12)) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sz.x * rb[0], sz.y * rb[1]),
                        width: sz.x * rb[2] * 5, height: sz.x * rb[2] * 3),
        Paint()..color = const Color(0xFF1E0007));
    }

    // Bone fragments scattered on the flesh floor
    final bonePaint = Paint()..color = const Color(0xFF2A2010);
    for (final bone in _bones) {
      canvas.save();
      canvas.translate(sz.x * bone[0], sz.y * bone[1]);
      canvas.rotate(bone[3]);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero,
                        width: sz.x * bone[2] * 2, height: sz.x * bone[2] * 0.4),
        bonePaint);
      canvas.restore();
    }

    // Neural vein network spreading across the floor
    final veinPaint = Paint()..style = PaintingStyle.stroke;
    for (final v in _veins) {
      final x1 = sz.x * v[0], y1 = sz.y * v[1];
      final x2 = sz.x * v[2], y2 = sz.y * v[3];
      final pulseA = (math.sin(_t * 1.5 + v[0] * 8) * 0.35 + 0.55).clamp(0.0, 1.0);
      veinPaint
        ..color = Color(0xFFCC0033).withAlpha((pulseA * 170).round())
        ..strokeWidth = v[4];
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), veinPaint);
      canvas.drawCircle(Offset(x1, y1), v[4] * 2.0,
        Paint()..color = Color(0xFFDD0044).withAlpha((pulseA * 220).round()));
    }

    // Heartbeat pulse rings expanding from centre
    final beat = (_t * 0.85) % 1.0;
    canvas.drawCircle(Offset(sz.x / 2, sz.y / 2), sz.x * 0.08 + beat * sz.x * 0.50,
      Paint()..color = Color(0xFFCC0033).withAlpha(((1 - beat) * 80).round())
             ..style = PaintingStyle.stroke..strokeWidth = 2.0);
    final beat2 = ((_t * 0.85) + 0.5) % 1.0;
    canvas.drawCircle(Offset(sz.x / 2, sz.y / 2), sz.x * 0.08 + beat2 * sz.x * 0.50,
      Paint()..color = Color(0xFFAA0022).withAlpha(((1 - beat2) * 50).round())
             ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    final pp = Paint();
    for (final s in _particles) {
      pp.color = _neuralRed[s.colorIndex].withAlpha((s.alpha * 255).round());
      pp.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, pp);
    }
    pp.maskFilter = null;
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _Particle {
  double x, y, radius, speed, alpha;
  int colorIndex;
  _Particle({
    required this.x, required this.y, required this.radius,
    required this.speed, required this.alpha, required this.colorIndex,
  });
}
