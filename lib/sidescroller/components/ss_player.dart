import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../sidescroller_game.dart';
import 'ss_zombie.dart';

class SsPlayer extends PositionComponent
    with HasGameReference<SidescrollerGame> {
  static const double kMoveSpeed = 220.0;
  static const double kJumpVelocity = -510.0;
  static const double kMaxFallSpeed = 900.0;
  static const double kFireRate = 0.17;
  static const double kContactDmgPerSec = 12.0;
  static const double kInvincibleTime = 0.55;

  double maxHp = 100;
  double currentHp = 100;

  double _vy = 0;
  bool _onGround = false;
  bool _facingRight = true;
  bool _crouching = false;

  double _damageFlash = 0;
  double _invincibleTimer = 0;
  double _fireTimer = 0;
  bool _jumpConsumed = false;

  SsPlayer({required super.position})
      : super(size: Vector2(26, 46), anchor: Anchor.bottomCenter, priority: 5);

  @override
  void update(double dt) {
    if (game.isGameOver) return;

    final jx = game.moveJoystick.relativeDelta.x;
    final jy = game.moveJoystick.relativeDelta.y;

    // Horizontal movement
    if (jx.abs() > 0.12) {
      position.x += jx * kMoveSpeed * dt;
      _facingRight = jx > 0;
    }

    // Crouch: joystick pushed down while on ground
    _crouching = _onGround && jy > 0.5;

    // Jump
    if (game.jumpPressed && !_jumpConsumed) {
      if (_onGround && !_crouching) {
        _vy = kJumpVelocity;
        _onGround = false;
        _jumpConsumed = true;
      }
    }
    if (!game.jumpPressed) _jumpConsumed = false;

    // Gravity
    _vy = (_vy + SidescrollerGame.kGravity * dt)
        .clamp(double.negativeInfinity, kMaxFallSpeed);
    position.y += _vy * dt;

    _resolvePlatforms();

    position.x =
        position.x.clamp(size.x / 2, SidescrollerGame.kWorldWidth - size.x / 2);

    // Fell off bottom
    if (position.y > game.size.y + 200) takeDamage(maxHp);

    // Shooting
    _fireTimer -= dt;
    if (game.fireHeld && !_crouching && _fireTimer <= 0) {
      _fire(jx, jy);
      _fireTimer = kFireRate;
    }

    // Timers
    if (_damageFlash > 0) _damageFlash -= dt;
    if (_invincibleTimer > 0) _invincibleTimer -= dt;

    // Contact damage from zombies
    if (_invincibleTimer <= 0) {
      for (final z in game.world.children.whereType<SsZombie>()) {
        if (!z.isDead && _overlaps(z)) {
          takeDamage(kContactDmgPerSec * dt);
          break;
        }
      }
    }
  }

  void _resolvePlatforms() {
    _onGround = false;
    final pLeft = position.x - size.x / 2;
    final pRight = position.x + size.x / 2;
    final pBottom = position.y;
    final pTop = position.y - size.y;

    for (final plat in game.platforms) {
      final plLeft = plat.position.x;
      final plRight = plat.position.x + plat.size.x;
      final plTop = plat.position.y;
      final plBottom = plat.position.y + plat.size.y;

      if (pRight <= plLeft || pLeft >= plRight) continue;

      // Land on top
      if (_vy >= 0 && pBottom >= plTop && pBottom <= plBottom) {
        position.y = plTop;
        _vy = 0;
        _onGround = true;
      }
      // Hit underside
      else if (_vy < 0 && pTop <= plBottom && pTop >= plTop) {
        position.y = plBottom + size.y;
        _vy = 0;
      }
    }
  }

  void _fire(double jx, double jy) {
    // 8-directional Contra-style aiming
    double dx, dy;
    final aimUp = jy < -0.45;
    final aimDiag = jy < -0.25 && jx.abs() > 0.25;

    if (aimUp && jx.abs() < 0.3) {
      dx = 0; dy = -1;
    } else if (aimDiag || aimUp) {
      dx = _facingRight ? 1 : -1;
      dy = -1;
      final len = math.sqrt(2.0);
      dx /= len; dy /= len;
    } else {
      dx = _facingRight ? 1.0 : -1.0;
      dy = 0;
    }

    final muzzleOffset = Vector2(
      (_facingRight ? 1 : -1) * (size.x * 0.6 + 8),
      -size.y * 0.55,
    );
    game.spawnBullet(position + muzzleOffset, Vector2(dx, dy));
  }

  bool _overlaps(SsZombie z) {
    final dx = (position.x - z.position.x).abs();
    final dy = ((position.y - size.y / 2) - (z.position.y - z.size.y / 2)).abs();
    return dx < (size.x / 2 + z.size.x / 2) - 4 &&
        dy < (size.y / 2 + z.size.y / 2) - 4;
  }

  void takeDamage(double amt) {
    if (_invincibleTimer > 0) return;
    currentHp = (currentHp - amt).clamp(0, maxHp);
    _damageFlash = 0.18;
    _invincibleTimer = kInvincibleTime;
    if (currentHp <= 0) game.triggerGameOver();
  }

  @override
  void render(Canvas canvas) {
    final flash = _damageFlash > 0;
    final bodyGreen = flash ? const Color(0xFFFF3333) : const Color(0xFF4CAF50);
    final darkGreen = flash ? const Color(0xFFBB0000) : const Color(0xFF2E7D32);
    final skinColor = const Color(0xFFFFCC80);
    final w = size.x;
    final h = _crouching ? size.y * 0.60 : size.y;
    final yOff = _crouching ? size.y * 0.40 : 0.0;

    canvas.save();
    if (!_facingRight) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    if (_crouching) {
      // Crouched torso
      canvas.drawRect(Rect.fromLTWH(3, yOff + h * 0.15, w - 6, h * 0.60),
          Paint()..color = bodyGreen);
      // Head forward
      canvas.drawOval(Rect.fromLTWH(w * 0.30, yOff, w * 0.65, h * 0.50),
          Paint()..color = skinColor);
      // Helmet
      canvas.drawRect(Rect.fromLTWH(w * 0.25, yOff, w * 0.70, h * 0.28),
          Paint()..color = darkGreen);
      // Eye
      canvas.drawCircle(Offset(w * 0.80, yOff + h * 0.35), 2,
          Paint()..color = const Color(0xFF1A1A1A));
      // Gun
      canvas.drawRect(
          Rect.fromLTWH(w * 0.55, yOff + h * 0.38, 16, 5),
          Paint()..color = const Color(0xFF616161));
    } else {
      // Head
      canvas.drawOval(Rect.fromLTWH(w * 0.05, 0, w * 0.70, h * 0.32),
          Paint()..color = skinColor);
      // Helmet
      canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.76, h * 0.20),
          Paint()..color = darkGreen);
      // Eye
      canvas.drawCircle(Offset(w * 0.65, h * 0.22), 2.5,
          Paint()..color = const Color(0xFF1A1A1A));
      // Torso
      canvas.drawRect(Rect.fromLTWH(4, h * 0.30, w - 8, h * 0.42),
          Paint()..color = bodyGreen);
      // Legs
      canvas.drawRect(Rect.fromLTWH(4, h * 0.72, (w - 10) * 0.46, h * 0.28),
          Paint()..color = darkGreen);
      canvas.drawRect(
          Rect.fromLTWH(w - 4 - (w - 10) * 0.46, h * 0.72, (w - 10) * 0.46, h * 0.28),
          Paint()..color = darkGreen);
      // Gun arm + barrel
      canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.38, w * 0.30, 7),
          Paint()..color = darkGreen);
      canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.36, 16, 5),
          Paint()..color = const Color(0xFF616161));
    }

    canvas.restore();

    // HP bar (small, above head)
    if (currentHp < maxHp) {
      final barW = size.x + 4.0;
      canvas.drawRect(Rect.fromLTWH(-2, -10, barW, 4),
          Paint()..color = const Color(0xFF333333));
      canvas.drawRect(
          Rect.fromLTWH(-2, -10, barW * (currentHp / maxHp), 4),
          Paint()..color = const Color(0xFF4CAF50));
    }
  }
}
