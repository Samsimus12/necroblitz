import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../audio/audio_manager.dart';
import '../coins/coin_manager.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback onPlay;
  const MainMenuScreen({super.key, required this.onPlay});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<void> _showShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
    setState(() {});
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0A1A08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF44AA00), width: 1.5),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(color: Color(0xFFF5F5DC), decoration: TextDecoration.none),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Music',
                style: TextStyle(color: Color(0xFFF5F5DC), fontSize: 16, decoration: TextDecoration.none),
              ),
              Switch(
                value: AudioManager.instance.musicEnabled,
                onChanged: (val) async {
                  await AudioManager.instance.setMusicEnabled(val);
                  if (val) AudioManager.instance.playMenu();
                  setDialogState(() {});
                  setState(() {});
                },
                activeColor: const Color(0xFF44AA00),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0F05), Color(0xFF050800)],
              ),
            ),
          ),

          // Living animated background
          const Positioned.fill(child: IgnorePointer(child: _MenuBackground())),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'NECROBLITZ',
                    style: TextStyle(
                      color: Color(0xFF66FF00),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(color: Color(0xBB66FF00), blurRadius: 24),
                        Shadow(color: Color(0x66CC4400), blurRadius: 60),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'SURVIVE · UPGRADE · ELIMINATE',
                    style: TextStyle(
                      color: Color(0x99F5F5DC),
                      fontSize: 12,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _WeaponDot(color: const Color(0xFF00E5FF), label: 'Pistol'),
                      _WeaponDot(color: const Color(0xFF9B59B6), label: 'Dart'),
                      _WeaponDot(color: const Color(0xFFF4A800), label: 'Shotgun'),
                      _WeaponDot(color: const Color(0xFFFF6B35), label: 'MG'),
                      _WeaponDot(color: const Color(0xFF66FF00), label: 'Blades'),
                      _WeaponDot(color: const Color(0xFF88D8F0), label: 'Stun'),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: widget.onPlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 72, vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      shadowColor: const Color(0xFF44AA00),
                      elevation: 12,
                    ),
                    child: const Text('PLAY'),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showShop,
                    icon: const Text('🔧', style: TextStyle(fontSize: 16)),
                    label: const Text(
                      'SHOP',
                      style: TextStyle(
                        color: Color(0xFF66FF00),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF66FF00),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),

          // Scrap balance — top-left corner
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔩', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${CoinManager.instance.totalCoins}',
                      style: const TextStyle(
                        color: Color(0xCC66FF00),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings cog — top-right corner
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Color(0x99F5F5DC), size: 26),
                  onPressed: _showSettings,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Living background ─────────────────────────────────────────────────────────

class _MenuBackground extends StatefulWidget {
  const _MenuBackground();

  @override
  State<_MenuBackground> createState() => _MenuBackgroundState();
}

class _MenuBackgroundState extends State<_MenuBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (mounted) setState(() => _t = elapsed.inMilliseconds / 1000.0);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MenuBgPainter(_t),
        size: Size.infinite,
      ),
    );
  }
}

// Pre-generated background element data (fixed seed = deterministic)
final _bgData = _genBgData();

({
  List<List<double>> debris,
  List<List<double>> zombies,
}) _genBgData() {
  final rng = math.Random(42);
  final debris = List.generate(
    35,
    (_) => [rng.nextDouble(), rng.nextDouble(), rng.nextDouble() * 0.05 + 0.02,
             rng.nextDouble() * math.pi * 2, (rng.nextDouble() - 0.5) * 0.6,
             rng.nextDouble() * 6 + 3],
  );
  final zombies = List.generate(
    5,
    (_) => [
      rng.nextDouble(), // x fraction
      rng.nextDouble(), // y0 fraction
      rng.nextDouble() * 0.025 + 0.008, // drift speed
      rng.nextDouble() * math.pi * 2, // heading angle
    ],
  );
  return (debris: debris, zombies: zombies);
}

class _MenuBgPainter extends CustomPainter {
  final double t;
  const _MenuBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _paintDebris(canvas, size);
    _paintZombies(canvas, size);
  }

  void _paintDebris(Canvas canvas, Size size) {
    const rFactors = [0.90, 0.68, 0.85, 0.72, 1.00, 0.65, 0.88, 0.75];
    final paint = Paint()
      ..color = const Color(0x225A6A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final s in _bgData.debris) {
      final x = s[0] * size.width;
      final rawY = (s[1] + t * s[2]) % 1.0;
      final y = rawY * size.height;
      final rot = s[3] + t * s[4];
      final r = s[5];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      const sides = 8;
      final path = Path();
      for (var i = 0; i < sides; i++) {
        final angle = i * 2 * math.pi / sides;
        final vr = r * rFactors[i];
        final vx = math.cos(angle) * vr;
        final vy = math.sin(angle) * vr;
        if (i == 0) {
          path.moveTo(vx, vy);
        } else {
          path.lineTo(vx, vy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _paintZombies(Canvas canvas, Size size) {
    // Faint zombie silhouettes drifting across the screen
    final bodyPaint = Paint()..color = const Color(0x224A6A3A);
    final eyePaint = Paint()..color = const Color(0x44CC4400);

    for (final s in _bgData.zombies) {
      final x = s[0] * size.width;
      final rawY = (s[1] + t * s[2]) % 1.0;
      final y = rawY * size.height;
      final angle = s[3];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      const r = 8.0;
      // Body blob
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.4, height: r * 2), bodyPaint);
      // Head
      canvas.drawCircle(const Offset(0, -r * 1.4), r * 0.6, bodyPaint);
      // Outstretched arms
      canvas.drawLine(const Offset(-r * 0.5, -r * 0.2), const Offset(-r * 1.5, r * 0.2), bodyPaint..strokeWidth = 2);
      canvas.drawLine(const Offset(r * 0.5, -r * 0.2), const Offset(r * 1.5, r * 0.2), bodyPaint..strokeWidth = 2);
      // Glowing eyes
      canvas.drawCircle(Offset(-r * 0.2, -r * 1.5), r * 0.18, eyePaint);
      canvas.drawCircle(Offset(r * 0.2, -r * 1.5), r * 0.18, eyePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MenuBgPainter old) => old.t != t;
}

// ── Weapon dot ────────────────────────────────────────────────────────────────

class _WeaponDot extends StatelessWidget {
  final Color color;
  final String label;
  const _WeaponDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: color.withAlpha(160),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
