import 'package:flame/components.dart';

import '../necroblitz_game.dart';

abstract class Weapon extends Component with HasGameReference<NecroblitzGame> {
  double damage;
  double fireRate;
  int upgradeLevel = 1;
  double _timer = 0;

  Weapon({required this.damage, required this.fireRate});

  double get fireInterval => 1.0 / fireRate;

  String get displayName;
  bool get isUpgradeable => true;
  String get nextUpgradeDescription => 'Damage +30%';

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= fireInterval) {
      final delta = game.aimJoystick.relativeDelta;
      if (!delta.isZero()) {
        _timer = 0;
        fire(game.player.position, delta.normalized());
      }
    }
  }

  void fire(Vector2 playerPos, Vector2 direction);

  void applyUpgrade() {
    upgradeLevel++;
    damage *= 1.3;
  }
}
