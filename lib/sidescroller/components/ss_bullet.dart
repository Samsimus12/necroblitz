import 'dart:ui';

import 'package:flame/components.dart';

import '../sidescroller_game.dart';
import 'ss_zombie.dart';

class SsBullet extends PositionComponent
    with HasGameReference<SidescrollerGame> {
  static const double kSpeed = 720.0;
  static const double kDamage = 26.0;
  static const double kLifetime = 2.2;

  final Vector2 direction;
  double _life = kLifetime;

  SsBullet({required super.position, required this.direction})
      : super(size: Vector2(10, 5), anchor: Anchor.center, priority: 6);

  @override
  void update(double dt) {
    position += direction * kSpeed * dt;
    _life -= dt;

    if (_life <= 0 ||
        position.x < -50 ||
        position.x > SidescrollerGame.kWorldWidth + 50) {
      removeFromParent();
      return;
    }

    // Hit platform
    for (final plat in game.platforms) {
      if (position.x >= plat.position.x &&
          position.x <= plat.position.x + plat.size.x &&
          position.y >= plat.position.y &&
          position.y <= plat.position.y + plat.size.y) {
        removeFromParent();
        return;
      }
    }

    // Hit zombie
    for (final z in game.world.children.whereType<SsZombie>().toList()) {
      if (z.isDead) continue;
      final dx = (position.x - z.position.x).abs();
      final dy = (position.y - (z.position.y - z.size.y / 2)).abs();
      if (dx < z.size.x / 2 + 6 && dy < z.size.y / 2 + 6) {
        z.takeDamage(kDamage);
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Bullet core
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      Paint()..color = const Color(0xFFFFAA00),
    );
    // Glow halo
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: size.x + 6, height: size.y + 4),
      Paint()
        ..color = const Color(0x44FF6600)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}
