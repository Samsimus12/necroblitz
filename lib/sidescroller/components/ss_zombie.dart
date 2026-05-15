import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../sidescroller_game.dart';

class SsZombie extends PositionComponent
    with HasGameReference<SidescrollerGame> {
  static const double kPatrolSpeed = 55.0;
  static const double kPatrolRange = 110.0;
  static const double kMaxFallSpeed = 900.0;
  static const double kDyingDuration = 0.55;
  static const double _kWalkFrameDuration = 0.12;

  double maxHp = 50.0;
  double hp = 50.0;
  bool isDead = false;

  bool _movingRight = true;
  double _damageFlash = 0;
  double _vy = 0;
  bool _onGround = false;
  final double _originX;

  double _knockbackVx = 0;

  bool _dying = false;
  double _dyingTimer = 0;
  double _dyingAlpha = 1.0;
  double _dyingVy = 0.0;
  double _dyingVx = 0.0;

  Sprite? _idleSprite;
  final List<Sprite> _walkSprites = [];
  final List<Sprite> _deathSprites = [];
  int _walkFrameIndex = 0;
  double _walkFrameTimer = 0;
  int _deathFrameIndex = 0;

  SsZombie({required Vector2 position})
      : _originX = position.x,
        super(
          position: position,
          size: Vector2(26, 38),
          anchor: Anchor.bottomCenter,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    try {
      _idleSprite = Sprite(await game.images.load('ss_zombie/idle.png'));
      for (int i = 0; i < 8; i++) {
        _walkSprites.add(Sprite(await game.images.load('ss_zombie/walk_$i.png')));
      }
      for (int i = 0; i < 7; i++) {
        _deathSprites.add(Sprite(await game.images.load('ss_zombie/death_$i.png')));
      }
    } catch (_) {}
  }

  void applyKnockback(double vx) {
    _knockbackVx = vx;
  }

  @override
  void update(double dt) {
    if (isDead && !_dying) return;

    if (_dying) {
      _dyingTimer -= dt;
      _dyingAlpha = (_dyingTimer / kDyingDuration).clamp(0.0, 1.0);
      if (_deathSprites.isNotEmpty) {
        final elapsed = kDyingDuration - _dyingTimer;
        _deathFrameIndex = (elapsed / kDyingDuration * _deathSprites.length)
            .floor()
            .clamp(0, _deathSprites.length - 1);
      }
      _dyingVy = (_dyingVy + SidescrollerGame.kGravity * 0.6 * dt)
          .clamp(-800.0, 600.0);
      position.x += _dyingVx * dt;
      position.y += _dyingVy * dt;
      if (_dyingTimer <= 0) removeFromParent();
      return;
    }

    _vy = (_vy + SidescrollerGame.kGravity * dt)
        .clamp(double.negativeInfinity, kMaxFallSpeed);
    position.y += _vy * dt;

    if (_knockbackVx.abs() > 1) {
      position.x += _knockbackVx * dt;
      _knockbackVx *= math.pow(0.001, dt) as double;
    } else {
      _knockbackVx = 0;
    }

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

    if (_onGround && _knockbackVx.abs() < 10) {
      position.x += (_movingRight ? kPatrolSpeed : -kPatrolSpeed) * dt;
      if (position.x > _originX + kPatrolRange) _movingRight = false;
      if (position.x < _originX - kPatrolRange) _movingRight = true;
    }

    if (_onGround && _walkSprites.isNotEmpty) {
      _walkFrameTimer += dt;
      if (_walkFrameTimer >= _kWalkFrameDuration) {
        _walkFrameTimer -= _kWalkFrameDuration;
        _walkFrameIndex = (_walkFrameIndex + 1) % _walkSprites.length;
      }
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
    _dying = true;
    _dyingTimer = kDyingDuration;
    _dyingAlpha = 1.0;
    _dyingVy = -160.0;
    _dyingVx = _knockbackVx.abs() < 10
        ? (_movingRight ? -80 : 80)
        : _knockbackVx * 1.4;
    game.onZombieKilled();
    game.triggerHitStop(0.05);
    game.triggerShake(6.0, 0.18);
  }

  @override
  void render(Canvas canvas) {
    final flash = _damageFlash > 0;
    final w = size.x;
    final h = size.y;

    if (_dying) {
      canvas.saveLayer(
        null,
        Paint()
          ..color = Color.fromARGB((_dyingAlpha * 255).round(), 255, 255, 255),
      );
    }

    canvas.save();
    if (!_movingRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    Sprite? sprite;
    if (_dying && _deathSprites.isNotEmpty) {
      sprite = _deathSprites[_deathFrameIndex];
    } else if (_walkSprites.isNotEmpty) {
      sprite = _walkSprites[_walkFrameIndex];
    } else {
      sprite = _idleSprite;
    }

    if (sprite != null) {
      const spriteW = 72.0;
      const spriteH = 72.0;
      final sx = (w - spriteW) / 2;
      final sy = h - spriteH;

      if (flash) {
        canvas.saveLayer(Rect.fromLTWH(sx, sy, spriteW, spriteH), Paint());
      }
      sprite.render(canvas,
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
    } else {
      // Canvas fallback
      final bodyColor = flash ? const Color(0xFFFF3333) : const Color(0xFF5A7035);
      final darkColor = flash ? const Color(0xFFAA0000) : const Color(0xFF2E4A18);
      const skinColor = Color(0xFF7A8A4A);

      canvas.drawRect(Rect.fromLTWH(3, h * 0.30, w - 6, h * 0.48),
          Paint()..color = bodyColor);
      canvas.drawOval(Rect.fromLTWH(w * 0.22, 0, w * 0.70, h * 0.38),
          Paint()..color = skinColor);
      canvas.drawCircle(Offset(w * 0.76, h * 0.16), 2.8,
          Paint()..color = const Color(0xFFFF1744));
      canvas.drawCircle(Offset(w * 0.76, h * 0.16), 1.2,
          Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.32, w * 0.55, 7),
          Paint()..color = darkColor);
      canvas.drawRect(
          Rect.fromLTWH(3, h * 0.76, (w - 8) * 0.46, h * 0.24),
          Paint()..color = darkColor);
      canvas.drawRect(
          Rect.fromLTWH(w - 3 - (w - 8) * 0.46, h * 0.76, (w - 8) * 0.46, h * 0.24),
          Paint()..color = darkColor);
    }

    canvas.restore();

    if (!_dying && hp < maxHp) {
      canvas.drawRect(Rect.fromLTWH(0, -7, w, 4),
          Paint()..color = const Color(0xFF2A2A2A));
      canvas.drawRect(Rect.fromLTWH(0, -7, w * (hp / maxHp), 4),
          Paint()..color = const Color(0xFF76C442));
    }

    if (_dying) canvas.restore();
  }
}
