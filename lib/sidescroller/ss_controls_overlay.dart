import 'package:flutter/material.dart';

import 'sidescroller_game.dart';

class SsControlsOverlay extends StatelessWidget {
  final SidescrollerGame game;
  final VoidCallback onBack;

  const SsControlsOverlay({
    super.key,
    required this.game,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Back button — top left
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xAA000020),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BACK',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right-side action buttons
        Align(
          alignment: Alignment.bottomRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 28, bottom: 36),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Fire button
                  _ActionButton(
                    label: '🔥',
                    color: const Color(0xBBFF6600),
                    radius: 32,
                    onDown: () => game.fireHeld = true,
                    onUp: () => game.fireHeld = false,
                  ),
                  const SizedBox(width: 20),
                  // Jump button
                  _ActionButton(
                    label: '▲',
                    color: const Color(0xBB0099FF),
                    radius: 38,
                    onDown: () => game.jumpPressed = true,
                    onUp: () => game.jumpPressed = false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final double radius;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.radius,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _pressed = true);
        widget.onDown();
      },
      onPointerUp: (_) {
        setState(() => _pressed = false);
        widget.onUp();
      },
      onPointerCancel: (_) {
        setState(() => _pressed = false);
        widget.onUp();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? widget.color
              : widget.color.withValues(alpha: widget.color.a * 0.55),
          border: Border.all(
            color: widget.color,
            width: _pressed ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.radius * 0.70,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
