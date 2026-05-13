import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ads/ad_manager.dart';
import 'audio/audio_manager.dart';
import 'coins/coin_manager.dart';
import 'sidescroller/sidescroller_game.dart';
import 'sidescroller/ss_controls_overlay.dart';
import 'stats/stats_manager.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const NecroblitzApp());
}

class NecroblitzApp extends StatefulWidget {
  const NecroblitzApp({super.key});

  @override
  State<NecroblitzApp> createState() => _NecroblitzAppState();
}

class _NecroblitzAppState extends State<NecroblitzApp> {
  bool _loaded = false;
  bool _inGame = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    await AdManager.instance.init();
    await CoinManager.instance.init();
    await AudioManager.instance.init();
    await StatsManager.instance.init();
    if (mounted) setState(() => _loaded = true);
  }

  void _startGame() => setState(() => _inGame = true);

  void _returnToMenu() => setState(() => _inGame = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _loaded
            ? (_inGame ? _buildGame() : _buildMenu())
            : const LoadingScreen(key: ValueKey('loading')),
      ),
    );
  }

  Widget _buildMenu() {
    return Scaffold(
      key: const ValueKey('ss-menu'),
      backgroundColor: const Color(0xFF070711),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NECROBLITZ',
              style: TextStyle(
                color: Color(0xFFFF1744),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                shadows: [
                  Shadow(color: Color(0xAAFF1744), blurRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SIDE-SCROLLER PROTOTYPE',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _startGame,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xAAFF1744),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFF1744), width: 2),
                ),
                child: const Text(
                  'PLAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return GameWidget<SidescrollerGame>.controlled(
      key: const ValueKey('ss-game'),
      gameFactory: SidescrollerGame.new,
      initialActiveOverlays: const ['Controls'],
      overlayBuilderMap: {
        'Controls': (context, game) =>
            SsControlsOverlay(game: game, onBack: _returnToMenu),
        'GameOver': (context, game) => _GameOverOverlay(
              kills: game.killCount,
              onRestart: () {
                setState(() {
                  _inGame = false;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _inGame = true);
                });
              },
              onMenu: _returnToMenu,
            ),
      },
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int kills;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const _GameOverOverlay({
    required this.kills,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xCC000000),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'YOU DIED',
              style: TextStyle(
                color: Color(0xFFFF1744),
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: 10,
                shadows: [Shadow(color: Color(0xAAFF1744), blurRadius: 24)],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'KILLS: $kills',
              style: const TextStyle(
                color: Color(0xFFCCCCCC),
                fontSize: 20,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Btn(label: 'RETRY', onTap: onRestart),
                const SizedBox(width: 24),
                _Btn(label: 'MENU', onTap: onMenu),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xAA000020),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF666666)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
