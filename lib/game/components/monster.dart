import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../data/monster_data.dart';
import '../necroblitz_game.dart';
import 'death_particles.dart';
import 'health_pickup.dart';
import 'shield_pickup.dart';

abstract class Monster extends PositionComponent
    with HasGameReference<NecroblitzGame> {
  final MonsterStats stats;
  late double currentHp;
  bool isDead = false;
  double slowFactor = 1.0;
  double _slowTimer = 0;
  double _flashTimer = 0;

  Monster({
    required super.position,
    required this.stats,
  }) : super(
          size: Vector2.all(stats.size),
          anchor: Anchor.center,
          priority: 1,
        ) {
    currentHp = stats.maxHp;
  }

  Color get deathColor;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;
    if (_flashTimer > 0) _flashTimer -= dt;
    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) slowFactor = 1.0;
    }
    updateMovement(dt);
  }

  void updateMovement(double dt) {
    final dir = game.player.position - position;
    if (dir.length > 1) {
      position += dir.normalized() * stats.speed * slowFactor * dt;
    }
  }

  void applySlow(double factor, double duration) {
    slowFactor = factor;
    _slowTimer = duration;
  }

  void takeDamage(double damage) {
    if (isDead) return;
    currentHp -= damage;
    _flashTimer = 0.12;
    if (currentHp <= 0) _die();
  }

  void _die() {
    isDead = true;
    game.world.add(DeathParticles(position: position.clone(), color: deathColor));
    final rng = math.Random();
    if (rng.nextDouble() < stats.shieldDropChance) {
      game.world.add(ShieldPickup(position: position.clone()));
    }
    if (rng.nextDouble() < stats.healthDropChance) {
      game.world.add(HealthPickup(position: position.clone()));
    }
    game.onMonsterKilled(stats.xpValue, stats.chargeValue);
    onDie();
    removeFromParent();
  }

  void onDie() {}

  double get hpFraction => (currentHp / stats.maxHp).clamp(0.0, 1.0);

  void renderHpBar(Canvas canvas) {
    const barH = 4.0;
    final barY = -10.0;
    final bgRect = Rect.fromLTWH(0, barY, size.x, barH);
    final fgRect = Rect.fromLTWH(0, barY, size.x * hpFraction, barH);
    canvas.drawRect(bgRect, Paint()..color = const Color(0xFF444444));
    canvas.drawRect(fgRect, Paint()..color = const Color(0xFFE74C3C));
  }

  void renderFlash(Canvas canvas) {
    if (_flashTimer <= 0) return;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = const Color(0x99FFFFFF),
    );
  }
}
