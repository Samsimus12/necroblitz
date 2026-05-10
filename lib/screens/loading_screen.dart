import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F05), Color(0xFF050800)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _glow,
                builder: (_, __) => Text(
                  'NECROBLITZ',
                  style: TextStyle(
                    color: const Color(0xFF66FF00),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(
                            102, 255, 0, 0.35 + _glow.value * 0.45),
                        blurRadius: 22 + _glow.value * 22,
                      ),
                      Shadow(
                        color: Color.fromRGBO(
                            204, 68, 0, 0.15 + _glow.value * 0.2),
                        blurRadius: 60,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'SURVIVE · UPGRADE · ELIMINATE',
                style: TextStyle(
                  color: Color(0x99F5F5DC),
                  fontSize: 12,
                  letterSpacing: 3.5,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 64),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF44AA00)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LOADING',
                style: TextStyle(
                  color: Color(0x55F5F5DC),
                  fontSize: 11,
                  letterSpacing: 4,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
