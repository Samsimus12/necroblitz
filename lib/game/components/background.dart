import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../necroblitz_game.dart';

// ── Phase 0: City Ruins ───────────────────────────────────────────────────────
const _debrisColor = Color(0xFF6B6B6B);

// ── Phase 1: Industrial Wasteland ────────────────────────────────────────────
const _ashColors = [
  Color(0xFFBBBBAA), Color(0xFFCCBBAA), Color(0xFFAA9988),
  Color(0xFFDDCCBB), Color(0xFFAAAAAA),
];
const _smokeColors = [
  Color(0xFF888880), Color(0xFF777770), Color(0xFF999990),
];

// ── Phase 2: Toxic Sewers ─────────────────────────────────────────────────────
const _toxicColors = [
  Color(0xFF44FF44), Color(0xFF88FF00), Color(0xFF00CC44),
  Color(0xFFAAFF44), Color(0xFF66FF88),
];

// ── Phase 3: Blood Streets ────────────────────────────────────────────────────
const _bloodColors = [
  Color(0xFFCC1111), Color(0xFFDD3300), Color(0xFFBB2200),
];

// ── Phase 4: Radioactive Zone ─────────────────────────────────────────────────
const _radioColors = [
  Color(0xFF88CC00), Color(0xFF44AA00), Color(0xFFAAFF00), Color(0xFF226600),
];

// ── Phase 5: Frozen Wastes ────────────────────────────────────────────────────
const _frozenColors = [
  Color(0xFF88CCFF), Color(0xFFAAEEFF), Color(0xFF66BBFF),
  Color(0xFF44AAEE), Color(0xFFCCEEFF),
];

// ── Phase 6: Burning City ─────────────────────────────────────────────────────
const _emberColors = [
  Color(0xFFFF6600), Color(0xFFFF3300), Color(0xFFFFAA00), Color(0xFFDD2200),
];

// ── Phase 7: Underground Bunker ───────────────────────────────────────────────
const _bunkerColors = [
  Color(0xFFFFFFCC), Color(0xFFFFEEAA), Color(0xFFCCDDFF),
  Color(0xFFFFCCAA), Color(0xFFAAFFCC),
];

// ── Phase 8: Dead Forest ──────────────────────────────────────────────────────
const _deadForestColors = [
  Color(0xFF221100), Color(0xFF110800), Color(0xFF332200), Color(0xFF440011),
];

// ── Phase 9: Horde Mind ───────────────────────────────────────────────────────
const _hordeMindColors = [
  Color(0xFFCC0044), Color(0xFFDD2266), Color(0xFFAA0033),
];

class StarBackground extends Component with HasGameReference<NecroblitzGame> {
  final _particles = <_Particle>[];
  final _clouds = <_Cloud>[];
  final _rng = math.Random();

  @override
  Future<void> onLoad() async {
    _particles.clear();
    _clouds.clear();
    final sz = game.size;
    final phase = game.bossPhase % 10;

    switch (phase) {
      case 1: // Industrial Wasteland — ash clouds + smoke
        for (int i = 0; i < 5; i++) {
          _clouds.add(_Cloud(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            w: _rng.nextDouble() * 180 + 120, h: _rng.nextDouble() * 45 + 25,
            speed: _rng.nextDouble() * 4 + 2,
            alpha: _rng.nextDouble() * 0.10 + 0.08,
            colorIndex: _rng.nextInt(_smokeColors.length), isLarge: true,
          ));
        }
        for (int i = 0; i < 12; i++) {
          _clouds.add(_Cloud(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            w: _rng.nextDouble() * 100 + 60, h: _rng.nextDouble() * 25 + 14,
            speed: _rng.nextDouble() * 12 + 6,
            alpha: _rng.nextDouble() * 0.14 + 0.10,
            colorIndex: _rng.nextInt(_smokeColors.length), isLarge: false,
          ));
        }
        for (int i = 0; i < 25; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 1.0 + 0.3,
            speed: _rng.nextDouble() * 5 + 2,
            alpha: _rng.nextDouble() * 0.25 + 0.10,
            colorIndex: _rng.nextInt(_ashColors.length),
          ));
        }

      case 2: // Toxic Sewers — dripping green particles
        for (int i = 0; i < 120; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 1.8 + 0.3,
            speed: _rng.nextDouble() * 20 + 5,
            alpha: _rng.nextDouble() * 0.65 + 0.20,
            colorIndex: _rng.nextInt(_toxicColors.length),
          ));
        }

      case 3: // Blood Streets — red droplets falling
        for (int i = 0; i < 70; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 2.2 + 0.5,
            speed: _rng.nextDouble() * 12 + 3,
            alpha: _rng.nextDouble() * 0.7 + 0.2,
            colorIndex: _rng.nextInt(_bloodColors.length),
          ));
        }

      case 4: // Radioactive Zone — green/yellow particles with large glowing nodes
        for (int i = 0; i < 90; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: i < 8
                ? _rng.nextDouble() * 3.5 + 2.0
                : _rng.nextDouble() * 1.2 + 0.3,
            speed: _rng.nextDouble() * 10 + 3,
            alpha: i < 8 ? _rng.nextDouble() * 0.5 + 0.3 : _rng.nextDouble() * 0.5 + 0.2,
            colorIndex: _rng.nextInt(_radioColors.length),
          ));
        }

      case 5: // Frozen Wastes — icy blue snowflakes + crystal nodes
        for (int i = 0; i < 130; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: i < 12
                ? _rng.nextDouble() * 2.8 + 1.5
                : _rng.nextDouble() * 1.0 + 0.3,
            speed: _rng.nextDouble() * 14 + 4,
            alpha: i < 12 ? _rng.nextDouble() * 0.6 + 0.3 : _rng.nextDouble() * 0.5 + 0.2,
            colorIndex: _rng.nextInt(_frozenColors.length),
          ));
        }

      case 6: // Burning City — embers drifting
        for (int i = 0; i < 80; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: i < 10
                ? _rng.nextDouble() * 4.0 + 2.5
                : _rng.nextDouble() * 1.5 + 0.4,
            speed: _rng.nextDouble() * 8 + 2,
            alpha: i < 10 ? _rng.nextDouble() * 0.4 + 0.2 : _rng.nextDouble() * 0.6 + 0.25,
            colorIndex: _rng.nextInt(_emberColors.length),
          ));
        }

      case 7: // Underground Bunker — sparse flickering light motes
        for (int i = 0; i < 100; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 1.2 + 0.2,
            speed: _rng.nextDouble() * 6 + 1,
            alpha: _rng.nextDouble() * 0.4 + 0.1,
            colorIndex: _rng.nextInt(_bunkerColors.length),
          ));
        }

      case 8: // Dead Forest — barely visible decay wisps
        for (int i = 0; i < 40; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 2.5 + 0.8,
            speed: _rng.nextDouble() * 5 + 1,
            alpha: _rng.nextDouble() * 0.22 + 0.06,
            colorIndex: _rng.nextInt(_deadForestColors.length),
          ));
        }

      case 9: // Horde Mind — pulsing crimson neural particles
        for (int i = 0; i < 50; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 1.6 + 0.4,
            speed: _rng.nextDouble() * 18 + 5,
            alpha: _rng.nextDouble() * 0.75 + 0.2,
            colorIndex: _rng.nextInt(_hordeMindColors.length),
          ));
        }

      default: // Phase 0 — City Ruins, grey debris chunks drifting down
        for (int i = 0; i < 100; i++) {
          _particles.add(_Particle(
            x: _rng.nextDouble() * sz.x, y: _rng.nextDouble() * sz.y,
            radius: _rng.nextDouble() * 1.8 + 0.4,
            speed: _rng.nextDouble() * 12 + 3,
            alpha: _rng.nextDouble() * 0.45 + 0.12,
            colorIndex: 0,
          ));
        }
    }
  }

  @override
  void update(double dt) {
    final height = game.size.y;
    for (final s in _particles) {
      s.y += s.speed * dt;
      if (s.y > height + 2) s.y = -2;
    }
    for (final c in _clouds) {
      c.y += c.speed * dt;
      if (c.y - c.h / 2 > height) c.y = -c.h / 2;
    }
  }

  @override
  void render(Canvas canvas) {
    final phase = game.bossPhase % 10;

    if (phase == 1) {
      _renderWasteland(canvas);
      return;
    }
    if (phase == 9) {
      _renderHordeMind(canvas);
      return;
    }

    final paint = Paint();
    for (final s in _particles) {
      final Color c = switch (phase) {
        2 => _toxicColors[s.colorIndex],
        3 => _bloodColors[s.colorIndex],
        4 => _radioColors[s.colorIndex],
        5 => _frozenColors[s.colorIndex],
        6 => _emberColors[s.colorIndex],
        7 => _bunkerColors[s.colorIndex],
        8 => _deadForestColors[s.colorIndex],
        _ => _debrisColor,
      };
      paint.color = c.withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, paint);
    }
  }

  void _renderWasteland(Canvas canvas) {
    final sz = game.size;
    final paint = Paint();

    // Sky gradient: dark smog haze at top → murky brown ground fog at base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..shader = Gradient.linear(
        Offset.zero, Offset(0, sz.y),
        [
          const Color(0xFF1A1208),
          const Color(0xFF2A1E10),
          const Color(0xFF3A2A18),
        ],
        [0.0, 0.55, 1.0],
      ),
    );

    for (final s in _particles) {
      paint.color = _ashColors[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, paint);
    }

    for (final c in _clouds) {
      final color = _smokeColors[c.colorIndex];
      final a = (c.alpha * 255).round();
      if (c.isLarge) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(c.x, c.y), width: c.w * 1.5, height: c.h * 1.4),
          Paint()
            ..color = color.withAlpha(a ~/ 4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
        paint.color = color.withAlpha(a);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x, c.y - c.h * 0.10), width: c.w * 0.70, height: c.h * 1.0), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x - c.w * 0.25, c.y + c.h * 0.08), width: c.w * 0.58, height: c.h * 0.82), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x + c.w * 0.23, c.y + c.h * 0.08), width: c.w * 0.54, height: c.h * 0.78), paint);
      } else {
        paint.color = color.withAlpha(a);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x, c.y - c.h * 0.08), width: c.w * 0.78, height: c.h * 1.0), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x - c.w * 0.20, c.y + c.h * 0.10), width: c.w * 0.56, height: c.h * 0.75), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(c.x + c.w * 0.18, c.y + c.h * 0.10), width: c.w * 0.50, height: c.h * 0.70), paint);
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(0, sz.y * 0.70, sz.x, sz.y * 0.30),
      Paint()..shader = Gradient.linear(
        Offset(0, sz.y * 0.70), Offset(0, sz.y),
        [const Color(0x003A2A18), const Color(0x2A1A0E06)],
      ),
    );
  }

  void _renderHordeMind(Canvas canvas) {
    final sz = game.size;
    final paint = Paint();

    for (final s in _particles) {
      paint.color = _hordeMindColors[s.colorIndex].withAlpha((s.alpha * 255).round());
      canvas.drawCircle(Offset(s.x, s.y), s.radius, paint);
    }

    final cx = sz.x / 2;
    final cy = sz.y * 0.35;
    final ringPaint = Paint()
      ..color = const Color(0x22CC0044)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), sz.x * 0.55, ringPaint);
    ringPaint.color = const Color(0x11AA0033);
    canvas.drawCircle(Offset(cx, cy), sz.x * 0.75, ringPaint);
  }
}

class _Particle {
  double x, y, radius, speed, alpha;
  int colorIndex;
  _Particle({
    required this.x, required this.y, required this.radius,
    required this.speed, required this.alpha, required this.colorIndex,
  });
}

class _Cloud {
  double x, y, w, h, speed, alpha;
  int colorIndex;
  bool isLarge;
  _Cloud({
    required this.x, required this.y, required this.w, required this.h,
    required this.speed, required this.alpha,
    required this.colorIndex, required this.isLarge,
  });
}
