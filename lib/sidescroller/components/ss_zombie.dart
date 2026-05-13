import 'dart:ui';

import 'package:flame/components.dart';

import '../sidescroller_game.dart';

class SsZombie extends PositionComponent
    with HasGameReference<SidescrollerGame> {
  static const double kPatrolSpeed = 55.0;
  static const double kPatrolRange = 110.0;
  static const double kMaxFallSpeed = 900.0;

  double maxHp = 50.0;
  double hp = 50.0;
  bool isDead = false;

  bool _movingRight = true;
  double _damageFlash = 0;
  double _vy = 0;
  bool _onGround = false;
  final double _originX;

  SsZombie({required Vector2 position})
      : _originX = position.x,
        super(
          position: position,
          size: Vector2(26, 38),
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  void update(double dt) {
    if (isDead) return;

    _vy = (_vy + SidescrollerGame.kGravity * dt)
        .clamp(double.negativeInfinity, kMaxFallSpeed);
    position.y += _vy * dt;

    _onGround = false;
    final pLeft = position.x - size.x / 2;
    final pRight = position.x + size.x / 2;

    for (final plat in game.platforms) {
      final plLeft = plat.position.x;
      final plRight = plat.position.x + plat.size.x;
      final plTop = plat.position.y;
      final plBottom = plat.position.y + plat.size.y;

      if (pRight <= plLeft || pLeft >= plRight) continue;
      if (_vy >= 0 && position.y >= plTop && position.y <= plBottom) {
        position.y = plTop;
        _vy = 0;
        _onGround = true;
      }
    }

    // Patrol
    if (_onGround) {
      position.x += (_movingRight ? kPatrolSpeed : -kPatrolSpeed) * dt;
      if (position.x > _originX + kPatrolRange) _movingRight = false;
      if (position.x < _originX - kPatrolRange) _movingRight = true;
    }

    if (_damageFlash > 0) _damageFlash -= dt;
  }

  void takeDamage(double amt) {
    if (isDead) return;
    hp -= amt;
    _damageFlash = 0.14;
    if (hp <= 0) _die();
  }

  void _die() {
    isDead = true;
    game.onZombieKilled();
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final flash = _damageFlash > 0;
    final bodyColor = flash ? const Color(0xFFFF3333) : const Color(0xFF5A7035);
    final darkColor = flash ? const Color(0xFFAA0000) : const Color(0xFF2E4A18);
    final skinColor = const Color(0xFF7A8A4A);
    final w = size.x;
    final h = size.y;

    canvas.save();
    if (!_movingRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    // Hunched torso
    canvas.drawRect(Rect.fromLTWH(3, h * 0.30, w - 6, h * 0.48),
        Paint()..color = bodyColor);
    // Head (pushed forward)
    canvas.drawOval(Rect.fromLTWH(w * 0.22, 0, w * 0.70, h * 0.38),
        Paint()..color = skinColor);
    // Red eyes
    canvas.drawCircle(Offset(w * 0.76, h * 0.16), 2.8,
        Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(Offset(w * 0.76, h * 0.16), 1.2,
        Paint()..color = const Color(0xFFFFFFFF));
    // Outstretched arms
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.32, w * 0.55, 7),
        Paint()..color = darkColor);
    // Legs (shuffling)
    canvas.drawRect(Rect.fromLTWH(3, h * 0.76, (w - 8) * 0.46, h * 0.24),
        Paint()..color = darkColor);
    canvas.drawRect(
        Rect.fromLTWH(w - 3 - (w - 8) * 0.46, h * 0.76, (w - 8) * 0.46, h * 0.24),
        Paint()..color = darkColor);

    canvas.restore();

    // HP bar
    final barW = w.toDouble();
    canvas.drawRect(Rect.fromLTWH(0, -7, barW, 4),
        Paint()..color = const Color(0xFF2A2A2A));
    canvas.drawRect(Rect.fromLTWH(0, -7, barW * (hp / maxHp), 4),
        Paint()..color = const Color(0xFF76C442));
  }
}
