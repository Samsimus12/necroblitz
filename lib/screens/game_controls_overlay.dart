import 'package:flutter/material.dart';

import '../game/necroblitz_game.dart';
import '../game/systems/supercharge_system.dart';

class GameControlsOverlay extends StatefulWidget {
  final NecroblitzGame game;
  final VoidCallback onMenu;

  const GameControlsOverlay(
      {super.key, required this.game, required this.onMenu});

  @override
  State<GameControlsOverlay> createState() => _GameControlsOverlayState();
}

class _GameControlsOverlayState extends State<GameControlsOverlay> {
  bool _paused = false;

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      widget.game.pauseEngine();
    } else {
      widget.game.resumeEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top row: Back and Pause
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HudButton(label: 'Back', onTap: widget.onMenu),
                _HudButton(
                  label: _paused ? 'Resume' : 'Pause',
                  onTap: _togglePause,
                ),
              ],
            ),
          ),
        ),

        // Paused indicator + Nova mode selector
        if (_paused)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Color(0xFFFF1744),
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(color: Color(0xAAFF1744), blurRadius: 20),
                      Shadow(color: Color(0x55FF1744), blurRadius: 40),
                    ],
                  ),
                ),
                if (widget.game.unlockedNovaModes.length > 1) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'BLITZ MODE',
                    style: TextStyle(
                      color: Color(0xFF44FF88),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...widget.game.unlockedNovaModes.map((mode) {
                    final isActive = mode == widget.game.activeNovaMode;
                    return GestureDetector(
                      onTap: () => setState(() => widget.game.activeNovaMode = mode),
                      child: Container(
                        width: 220,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0x4444FF88)
                              : const Color(0xAA000010),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF44FF88)
                                : const Color(0x33FFFFFF),
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          mode.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF44FF88)
                                : const Color(0x99F5F5DC),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

        // NOVA button — center-bottom, above joystick area
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 205),
              child: ValueListenableBuilder<SuperchargeState>(
                valueListenable: widget.game.superchargeSystem.stateNotifier,
                builder: (context, state, child) {
                  final isReady = state == SuperchargeState.ready;
                  final isActive = state == SuperchargeState.active;
                  return _HudButton(
                    label: isActive ? '⚡ ACTIVE' : 'BLITZ',
                    onTap: isReady ? widget.game.activateSupercharge : null,
                    highlight: isReady,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HudButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  const _HudButton({required this.label, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final textColor = onTap == null ? const Color(0x55F5F5DC) : const Color(0xFFF5F5DC);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xAA000010),
          borderRadius: BorderRadius.circular(8),
          border: highlight
              ? Border.all(color: const Color(0xFF44FF88), width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
