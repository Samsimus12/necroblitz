import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../coins/coin_manager.dart';
import '../necroblitz_game.dart';
import 'monster.dart';
import 'monster_boss.dart';
import 'weapon.dart';
import 'weapon_magic_bolt.dart';

// Tint overlay color per skin, applied over the sprite.
Color _skinTint(String skin) => switch (skin) {
      'ice'    => const Color(0x554DD0E1),
      'flame'  => const Color(0x55FF5722),
      'shadow' => const Color(0x55424242),
      'solar'  => const Color(0x55FFD600),
      'void'   => const Color(0x556A1B9A),
      _        => const Color(0x00000000), // default: no tint
    };

// Glow colour per skin, used for the helmet glow ring.
Color _skinGlow(String skin) => switch (skin) {
      'ice'    => const Color(0xAA00B8D4),
      'flame'  => const Color(0xAADD2C00),
      'shadow' => const Color(0xAA616161),
      'solar'  => const Color(0xAAFF8F00),
      'void'   => const Color(0xAA7B1FA2),
      _        => const Color(0xAA388E3C),
    };

const _kSpriteDisplay = 72.0; // render size for the 92×92 sprite canvas

class Player extends PositionComponent
    with HasGameReference<NecroblitzGame>, CollisionCallbacks {
  double maxHp = 100;
  double currentHp = 100;
  double moveSpeed = 180;
  int afterburnerStacks = 0;
  static const int maxAfterburnerStacks = 2;
  double _facingAngle = 0;

  double shieldHp = 0;
  static const double maxShieldHp = 50.0;
  double _shieldFlashTimer = 0;
  double _damageTime = 0;

  final Map<String, Image> _sprites = {};

  Player({required super.position})
      : super(size: Vector2.all(48), anchor: Anchor.center, priority: 3);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.active);
    add(WeaponMagicBolt());
    for (final dir in ['south', 'south-east', 'east', 'north-east',
                        'north', 'north-west', 'west', 'south-west']) {
      _sprites[dir] = await game.images.load('survivor/$dir.png');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final delta = game.joystick.relativeDelta;
    if (delta.length > 0.05) {
      position += delta * moveSpeed * dt;
      final r = size.x / 2;
      position.x = position.x.clamp(r, game.size.x - r);
      position.y = position.y.clamp(r, game.size.y - r);
    }

    final aim = game.aimJoystick.relativeDelta;
    if (aim.length > 0.05) {
      _facingAngle = math.atan2(aim.y, aim.x) + math.pi / 2;
    }

    if (_shieldFlashTimer > 0) _shieldFlashTimer -= dt;
    _damageTime += dt;
  }

  Vector2 get aimDirection {
    final aim = game.aimJoystick.relativeDelta;
    if (aim.length > 0.05) return aim.normalized();
    return Vector2(math.sin(_facingAngle), -math.cos(_facingAngle));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Monster && !other.isDead) {
      takeDamage(other.stats.contactDamagePerSecond);
      if (other is! BossMonster) other.takeDamage(other.currentHp);
    }
  }

  void addShield(double amount) =>
      shieldHp = (shieldHp + amount).clamp(0, maxShieldHp);

  void addHp(double amount) =>
      currentHp = (currentHp + amount).clamp(0, maxHp);

  void takeDamage(double damage) {
    if (game.isGameOver) return;
    if (shieldHp > 0) {
      _shieldFlashTimer = 0.12;
      final absorbed = damage.clamp(0.0, shieldHp);
      shieldHp -= absorbed;
      damage -= absorbed;
      if (damage <= 0) return;
    }
    currentHp = (currentHp - damage).clamp(0, maxHp);
    if (currentHp <= 0) game.onPlayerDeath();
  }

  Iterable<Weapon> get activeWeapons => children.whereType<Weapon>();
  bool hasWeapon<T extends Weapon>() => children.whereType<T>().isNotEmpty;

  void reset() {
    maxHp = 100;
    currentHp = 100;
    moveSpeed = 180;
    afterburnerStacks = 0;
    _facingAngle = 0;
    shieldHp = 0;
    _shieldFlashTimer = 0;
    _damageTime = 0;
    children.whereType<Weapon>().toList().forEach((w) => w.removeFromParent());
    add(WeaponMagicBolt());
  }

  /// Maps _facingAngle (0=north, clockwise) to one of 8 sprite direction names.
  String get _spriteDirection {
    // Normalise to [0, 2π)
    var a = _facingAngle % (2 * math.pi);
    if (a < 0) a += 2 * math.pi;
    // 8 sectors of π/4 each, offset by π/8 so boundaries fall between directions
    final index = ((a + math.pi / 8) / (math.pi / 4)).floor() % 8;
    const dirs = ['north', 'north-east', 'east', 'south-east',
                  'south', 'south-west', 'west', 'north-west'];
    return dirs[index];
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Laser sight — drawn in component-local space, follows aim joystick directly
    final aimDelta = game.aimJoystick.relativeDelta;
    if (aimDelta.length > 0.05) {
      final dir = aimDelta.normalized();
      const len = 240.0;
      final ex = cx + dir.x * len;
      final ey = cy + dir.y * len;
      canvas.drawLine(Offset(cx, cy), Offset(ex, ey),
        Paint()
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round
          ..shader = Gradient.linear(Offset(cx, cy), Offset(ex, ey), [
            const Color(0xBB00FF55), const Color(0x0000FF55),
          ]));
      canvas.drawCircle(Offset(ex, ey), 2.5,
        Paint()..color = const Color(0x88FF2200));
    }

    // Directional sprite
    final img = _sprites[_spriteDirection];
    final dst = Rect.fromCenter(
      center: Offset(cx, cy),
      width: _kSpriteDisplay,
      height: _kSpriteDisplay,
    );
    if (img != null) {
      final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      canvas.drawImageRect(img, src, dst, Paint());

      // Non-default skin: overlay a semi-transparent colour tint
      final tint = _skinTint(CoinManager.instance.selectedSkin);
      if (tint.a > 0) {
        canvas.drawRect(dst, Paint()
          ..color = tint
          ..blendMode = BlendMode.srcATop);
      }

      // Skin glow ring around helmet area (upper-centre of sprite)
      final glowCenter = Offset(cx, cy - _kSpriteDisplay * 0.18);
      canvas.drawCircle(glowCenter, 9,
        Paint()
          ..color = _skinGlow(CoinManager.instance.selectedSkin)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    } else {
      // Fallback while sprites load
      canvas.drawCircle(Offset(cx, cy), 20,
        Paint()..color = const Color(0xFF4CAF50));
    }

    // Damage overlays (drawn after sprite, no rotation needed)
    final hpFraction = (currentHp / maxHp).clamp(0.0, 1.0);
    if (hpFraction < 0.75) _renderDamage(canvas, cx, cy, hpFraction);

    _renderShield(canvas);
  }

  void _renderDamage(Canvas canvas, double cx, double cy, double hpFraction) {
    final stain = Paint()..color = const Color(0xCC880000);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3, cy - 3), width: 7, height: 5), stain);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy + 3), width: 5, height: 4), stain);

    if (hpFraction >= 0.50) return;

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy + 5), width: 6, height: 5), stain);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy - 6), width: 5, height: 4), stain);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 14), width: 14, height: 10),
      Paint()..color = const Color(0x66333333)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    if (hpFraction >= 0.25) return;

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy), width: 14, height: 9),
      Paint()..color = const Color(0x66440000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy + 10), width: 12, height: 11),
      Paint()..color = const Color(0xCCFF5500)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    if (hpFraction >= 0.10) return;

    final pulse = math.sin(_damageTime * 10) * 0.5 + 0.5;
    final a = (60 + pulse * 130).toInt();
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 48),
      Paint()..color = Color.fromARGB(a ~/ 2, 255, 0, 0)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy + 11), width: 13, height: 12),
      Paint()..color = Color.fromARGB(a, 255, 110, 0)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 5, cy + 11), width: 13, height: 12),
      Paint()..color = Color.fromARGB(a, 255, 80, 0)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
  }

  Color get _shieldColor => switch (CoinManager.instance.selectedShieldSkin) {
        'shield_plasma' => const Color(0xFFFF6B35),
        'shield_void'   => const Color(0xFFCC00FF),
        'shield_gold'   => const Color(0xFFFFD700),
        _               => const Color(0xFF44FF88),
      };

  void _renderShield(Canvas canvas) {
    if (shieldHp <= 0) return;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final fraction = (shieldHp / maxShieldHp).clamp(0.0, 1.0);
    final alpha = (fraction * 200 + 30).toInt();
    final strokeW = fraction * 3.0 + 1.0;
    const ringRadius = 30.0;
    final sc = _shieldColor;

    canvas.drawCircle(Offset(cx, cy), ringRadius,
      Paint()
        ..color = Color.fromARGB(alpha ~/ 3, sc.red, sc.green, sc.blue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    final ringColor = _shieldFlashTimer > 0
        ? const Color(0xC8FFFFFF)
        : Color.fromARGB(alpha, sc.red, sc.green, sc.blue);
    canvas.drawCircle(Offset(cx, cy), ringRadius,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW);
  }
}
