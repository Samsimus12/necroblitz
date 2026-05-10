import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../necroblitz_game.dart';
import 'weapon_magic_bolt.dart';

class PlayerNovaBurst extends Component with HasGameReference<NecroblitzGame> {
  final int shotCount;
  final Color color;
  final double damage;
  double _fireTimer;

  static const double _fireInterval = 0.5;

  PlayerNovaBurst({
    required this.shotCount,
    required this.color,
    required this.damage,
  })  : _fireTimer = _fireInterval, // fire immediately on first update
        super(priority: 4);

  @override
  void update(double dt) {
    if (game.superchargeSystem.deplete(dt)) {
      removeFromParent();
      return;
    }
    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0;
      _fireBurst();
    }
  }

  void _fireBurst() {
    final origin = game.player.position;
    final effectiveDamage = damage * game.superchargeSystem.damageMultiplier;
    for (int i = 0; i < shotCount; i++) {
      final angle = (i / shotCount) * math.pi * 2;
      game.world.add(MagicBolt(
        position: origin.clone(),
        direction: Vector2(math.cos(angle), math.sin(angle)),
        damage: effectiveDamage,
        color: color,
        speed: 400,
        boltSize: 14,
      ));
    }
  }
}
