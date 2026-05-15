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
  static const double kCoyoteTime = 0.08;
  static const double kJumpBuffer = 0.10;
  static const double _kWalkFrameDuration = 0.10;

  double maxHp = 100;
  double currentHp = 100;

  double _vy = 0;
  bool _onGround = false;
  bool _facingRight = true;
  bool _crouching = false;
  bool _isMoving = false;

  double _damageFlash = 0;
  double _invincibleTimer = 0;
  double _fireTimer = 0;
  bool _jumpConsumed = false;
  double _coyoteTimer = 0;
  double _jumpBufferTimer = 0;
  double _muzzleFlashTimer = 0;

  Sprite? _idleSprite;
  final List<Sprite> _walkSprites = [];
  int _walkFrameIndex = 0;
  double _walkFrameTimer = 0;

  SsPlayer({required super.position})
      : super(size: Vector2(26, 46), anchor: Anchor.bottomCenter, priority: 5);

  @override
  Future<void> onLoad() async {
    try {
      _idleSprite = Sprite(await game.images.load('ss_survivor/idle.png'));
      for (int i = 0; i < 6; i++) {
        _walkSprites.add(Sprite(await game.images.load('ss_survivor/walk_$i.png')));
      }
    } catch (_) {}
  }

  @override
  void update(double dt) {
    if (game.isGameOver) return;

    final jx = game.moveJoystick.relativeDelta.x;
    final jy = game.moveJoystick.relativeDelta.y;

    if (jx.abs() > 0.12) {
      position.x += jx * kMoveSpeed * dt;
      _facingRight = jx > 0;
    }

    _crouching = _onGround && jy > 0.5;

    if (game.jumpPressed && !_jumpConsumed) _jumpBufferTimer = kJumpBuffer;
    if (!game.jumpPressed) _jumpConsumed = false;
    _jumpBufferTimer -= dt;

    _vy = (_vy + SidescrollerGame.kGravity * dt)
        .clamp(double.negativeInfinity, kMaxFallSpeed);
    position.y += _vy * dt;

    _resolvePlatforms();

    _isMoving = jx.abs() > 0.12 && _onGround && !_crouching;
    if (_isMoving && _walkSprites.isNotEmpty) {
      _walkFrameTimer += dt;
      if (_walkFrameTimer >= _kWalkFrameDuration) {
        _walkFrameTimer -= _kWalkFrameDuration;
        _walkFrameIndex = (_walkFrameIndex + 1) % _walkSprites.length;
      }
    } else {
      _walkFrameIndex = 0;
      _walkFrameTimer = 0;
    }

    if (_onGround) {
      _coyoteTimer = kCoyoteTime;
    } else {
      _coyoteTimer -= dt;
    }

    if (_jumpBufferTimer > 0 && _coyoteTimer > 0 && !_crouching) {
      _vy = kJumpVelocity;
      _onGround = false;
      _jumpConsumed = true;
      _coyoteTimer = 0;
      _jumpBufferTimer = 0;
    }

    position.x =
        position.x.clamp(size.x / 2, SidescrollerGame.kWorldWidth - size.x / 2);

    if (position.y > game.size.y + 200) takeDamage(maxHp);

    _fireTimer -= dt;
    if (!_crouching && _fireTimer <= 0) {
      final ax = game.aimJoystick.relativeDelta.x;
      final ay = game.aimJoystick.relativeDelta.y;
      _fire(ax, ay);
      _fireTimer = kFireRate;
    }

    if (_damageFlash > 0) _damageFlash -= dt;
    if (_invincibleTimer > 0) _invincibleTimer -= dt;
    if (_muzzleFlashTimer > 0) _muzzleFlashTimer -= dt;

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

      if (_vy >= 0 && pBottom >= plTop && pBottom <= plBottom) {
        position.y = plTop;
        _vy = 0;
        _onGround = true;
      } else if (_vy < 0 && pTop <= plBottom && pTop >= plTop) {
        position.y = plBottom + size.y;
        _vy = 0;
      }
    }
  }

  void _fire(double ax, double ay) {
    double dx, dy;

    if (ax.abs() > 0.15 || ay.abs() > 0.15) {
      final len = math.sqrt(ax * ax + ay * ay);
      dx = ax / len;
      dy = ay / len;
      if (ax.abs() > 0.15) _facingRight = ax > 0;
    } else {
      dx = _facingRight ? 1.0 : -1.0;
      dy = 0;
    }

    final muzzleOffset = Vector2(
      (_facingRight ? 1 : -1) * (size.x * 0.6 + 8),
      -size.y * 0.55,
    );
    game.spawnBullet(position + muzzleOffset, Vector2(dx, dy));
    _muzzleFlashTimer = 0.07;
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
    game.triggerShake(4.0, 0.15);
    if (currentHp <= 0) game.triggerGameOver();
  }

  @override
  void render(Canvas canvas) {
    final flash = _damageFlash > 0;
    final w = size.x;
    final h = _crouching ? size.y * 0.60 : size.y;
    final yOff = _crouching ? size.y * 0.40 : 0.0;

    canvas.save();
    if (!_facingRight) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    final currentSprite = (_isMoving && _walkSprites.isNotEmpty)
        ? _walkSprites[_walkFrameIndex]
        : _idleSprite;

    if (currentSprite != null && !_crouching) {
      const spriteW = 72.0;
      const spriteH = 72.0;
      final sx = (size.x - spriteW) / 2;
      final sy = size.y - spriteH;

      if (flash) {
        canvas.saveLayer(Rect.fromLTWH(sx, sy, spriteW, spriteH), Paint());
      }
      currentSprite.render(canvas,
          position: Vector2(sx, sy), size: Vector2(spriteW, spriteH));
      if (flash) {
        canvas.drawRect(
          Rect.fromLTWH(sx, sy, spriteW, spriteH),
          Paint()
            ..color = const Color(0x55FF0000)
            ..blendMode = BlendMode.srcATop,
        );
        canvas.restore();
      }

      if (_muzzleFlashTimer > 0) {
        const bx = 34.0;
        const by = -4.0;
        canvas.drawCircle(
            const Offset(bx, by),
            8,
            Paint()
              ..color = const Color(0xBBFF8800)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(
            const Offset(bx, by), 3.5, Paint()..color = const Color(0xFFFFFFCC));
      }
    } else {
      // Canvas fallback (also used when crouching)
      final bodyGreen = flash ? const Color(0xFFFF3333) : const Color(0xFF4CAF50);
      final darkGreen = flash ? const Color(0xFFBB0000) : const Color(0xFF2E7D32);
      const skinColor = Color(0xFFFFCC80);

      if (_crouching) {
        canvas.drawRect(Rect.fromLTWH(3, yOff + h * 0.15, w - 6, h * 0.60),
            Paint()..color = bodyGreen);
        canvas.drawOval(Rect.fromLTWH(w * 0.30, yOff, w * 0.65, h * 0.50),
            Paint()..color = skinColor);
        canvas.drawRect(Rect.fromLTWH(w * 0.25, yOff, w * 0.70, h * 0.28),
            Paint()..color = darkGreen);
        canvas.drawCircle(Offset(w * 0.80, yOff + h * 0.35), 2,
            Paint()..color = const Color(0xFF1A1A1A));
        canvas.drawRect(
            Rect.fromLTWH(w * 0.55, yOff + h * 0.38, 16, 5),
            Paint()..color = const Color(0xFF616161));
      } else {
        canvas.drawOval(Rect.fromLTWH(w * 0.05, 0, w * 0.70, h * 0.32),
            Paint()..color = skinColor);
        canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.76, h * 0.20),
            Paint()..color = darkGreen);
        canvas.drawCircle(Offset(w * 0.65, h * 0.22), 2.5,
            Paint()..color = const Color(0xFF1A1A1A));
        canvas.drawRect(Rect.fromLTWH(4, h * 0.30, w - 8, h * 0.42),
            Paint()..color = bodyGreen);
        canvas.drawRect(
            Rect.fromLTWH(4, h * 0.72, (w - 10) * 0.46, h * 0.28),
            Paint()..color = darkGreen);
        canvas.drawRect(
            Rect.fromLTWH(w - 4 - (w - 10) * 0.46, h * 0.72, (w - 10) * 0.46, h * 0.28),
            Paint()..color = darkGreen);
        canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.38, w * 0.30, 7),
            Paint()..color = darkGreen);
        canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.36, 16, 5),
            Paint()..color = const Color(0xFF616161));

        if (_muzzleFlashTimer > 0) {
          final bx = w * 0.70 + 18.0;
          final by = h * 0.36 + 2.5;
          canvas.drawCircle(
              Offset(bx, by),
              8,
              Paint()
                ..color = const Color(0xBBFF8800)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
          canvas.drawCircle(
              Offset(bx, by), 3.5, Paint()..color = const Color(0xFFFFFFCC));
        }
      }
    }

    canvas.restore();

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
