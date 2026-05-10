import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../coins/coin_manager.dart';
import '../necroblitz_game.dart';
import 'monster.dart';

class SuperchargeLaser extends Component with HasGameReference<NecroblitzGame> {
  static const double dps = 120.0;
  static const double halfWidth = 18.0;

  SuperchargeLaser() : super(priority: 4);

  Color get _beamColor => switch (CoinManager.instance.selectedNovaTheme) {
        'nova_inferno' => const Color(0xFFFF3D00),
        'nova_void'    => const Color(0xFFFF00FF),
        'nova_eclipse' => const Color(0xFFFFD700),
        _              => const Color(0xFF00E5FF),
      };

  @override
  void update(double dt) {
    if (game.superchargeSystem.deplete(dt)) {
      removeFromParent();
      return;
    }

    final origin = game.player.position;
    final dir = game.player.aimDirection;
    final effectiveDps = dps * game.superchargeSystem.damageMultiplier;

    for (final monster in game.world.children.whereType<Monster>().toList()) {
      if (monster.isDead) continue;
      final delta = monster.position - origin;
      final along = delta.dot(dir);
      if (along < 0) continue;
      final perp = (delta - dir * along).length;
      if (perp < halfWidth + monster.size.x / 2) {
        monster.takeDamage(effectiveDps * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final origin = game.player.position;
    final dir = game.player.aimDirection;
    final color = _beamColor;

    final screenW = game.size.x;
    final screenH = game.size.y;
    final maxLen = math.sqrt(screenW * screenW + screenH * screenH);

    final endX = origin.x + dir.x * maxLen;
    final endY = origin.y + dir.y * maxLen;

    final perpX = -dir.y * halfWidth;
    final perpY = dir.x * halfWidth;

    // Outer glow
    canvas.drawPath(
      Path()
        ..moveTo(origin.x + perpX * 2, origin.y + perpY * 2)
        ..lineTo(endX + perpX * 2, endY + perpY * 2)
        ..lineTo(endX - perpX * 2, endY - perpY * 2)
        ..lineTo(origin.x - perpX * 2, origin.y - perpY * 2)
        ..close(),
      Paint()
        ..color = color.withAlpha(68)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Beam fill with gradient fade
    canvas.drawPath(
      Path()
        ..moveTo(origin.x + perpX, origin.y + perpY)
        ..lineTo(endX + perpX, endY + perpY)
        ..lineTo(endX - perpX, endY - perpY)
        ..lineTo(origin.x - perpX, origin.y - perpY)
        ..close(),
      Paint()
        ..shader = Gradient.linear(
          Offset(origin.x, origin.y),
          Offset(endX, endY),
          [color.withAlpha(187), color.withAlpha(0)],
        ),
    );

    // White core line
    canvas.drawLine(
      Offset(origin.x, origin.y),
      Offset(endX, endY),
      Paint()
        ..color = const Color(0xAAFFFFFF)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }
}
