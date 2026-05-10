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

class _OutfitPalette {
  final Color jacket;
  final Color pants;
  final Color highlight;
  final Color glow;
  const _OutfitPalette({
    required this.jacket,
    required this.pants,
    required this.highlight,
    required this.glow,
  });
}

_OutfitPalette _paletteForSkin(String skin) => switch (skin) {
      'ice' => const _OutfitPalette(
          jacket: Color(0xFF4DD0E1),
          pants: Color(0xFF0097A7),
          highlight: Color(0xFFE0F7FA),
          glow: Color(0xAA00B8D4),
        ),
      'flame' => const _OutfitPalette(
          jacket: Color(0xFFFF5722),
          pants: Color(0xFFBF360C),
          highlight: Color(0xFFFFAB91),
          glow: Color(0xAADD2C00),
        ),
      'shadow' => const _OutfitPalette(
          jacket: Color(0xFF424242),
          pants: Color(0xFF212121),
          highlight: Color(0xFF757575),
          glow: Color(0xAA616161),
        ),
      'solar' => const _OutfitPalette(
          jacket: Color(0xFFFFD600),
          pants: Color(0xFFF57F17),
          highlight: Color(0xFFFFFFFF),
          glow: Color(0xAAFF8F00),
        ),
      'void' => const _OutfitPalette(
          jacket: Color(0xFF6A1B9A),
          pants: Color(0xFF4A148C),
          highlight: Color(0xFFCE93D8),
          glow: Color(0xAA7B1FA2),
        ),
      _ => const _OutfitPalette(
          jacket: Color(0xFF4CAF50),
          pants: Color(0xFF2E7D32),
          highlight: Color(0xFFA5D6A7),
          glow: Color(0xAA388E3C),
        ),
    };

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

  Player({required super.position})
      : super(size: Vector2.all(44), anchor: Anchor.center, priority: 3);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.active);
    add(WeaponMagicBolt());
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

  void addShield(double amount) {
    shieldHp = (shieldHp + amount).clamp(0, maxShieldHp);
  }

  void addHp(double amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

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

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Aim direction line
    final aimDelta = game.aimJoystick.relativeDelta;
    if (aimDelta.length > 0.05) {
      final dir = aimDelta.normalized();
      const len = 220.0;
      final endX = cx + dir.x * len;
      final endY = cy + dir.y * len;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(endX, endY),
        Paint()
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..shader = Gradient.linear(
            Offset(cx, cy),
            Offset(endX, endY),
            [const Color(0x9900FF44), const Color(0x0000FF44)],
          ),
      );
    }

    final pal = _paletteForSkin(CoinManager.instance.selectedSkin);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_facingAngle);
    canvas.translate(-cx, -cy);

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 24, height: 10),
      Paint()..color = const Color(0x44000000),
    );

    // Legs
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy + 10), width: 7, height: 12),
      Paint()..color = pal.pants,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 5, cy + 10), width: 7, height: 12),
      Paint()..color = pal.pants,
    );

    // Boots
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy + 16), width: 8, height: 5),
      Paint()..color = const Color(0xFF3E2723),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 5, cy + 16), width: 8, height: 5),
      Paint()..color = const Color(0xFF3E2723),
    );

    // Torso / jacket
    final torso = Path()
      ..moveTo(cx, cy - 10)
      ..lineTo(cx + 9, cy - 3)
      ..lineTo(cx + 8, cy + 7)
      ..lineTo(cx, cy + 5)
      ..lineTo(cx - 8, cy + 7)
      ..lineTo(cx - 9, cy - 3)
      ..close();
    canvas.drawPath(torso, Paint()..color = pal.jacket);
    canvas.drawPath(
      torso,
      Paint()
        ..color = pal.highlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Arms
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 12, cy - 4), width: 7, height: 14),
      Paint()..color = pal.jacket,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 12, cy + 1), width: 7, height: 10),
      Paint()..color = pal.jacket,
    );

    // Head / helmet
    final headGlow = Paint()
      ..color = pal.glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(cx, cy - 12), 9, headGlow);
    canvas.drawCircle(Offset(cx, cy - 12), 8, Paint()..color = const Color(0xFFBCAAA4));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 9, height: 7),
      Paint()..color = pal.highlight.withAlpha(180),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 1.5, cy - 14), width: 3, height: 3),
      Paint()..color = const Color(0xAAFFFFFF),
    );

    // Gun barrel (pointing forward = up)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 9, cy - 11), width: 4, height: 10),
      Paint()..color = const Color(0xFF263238),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 9, cy - 17), width: 3, height: 4),
      Paint()..color = const Color(0xFF455A64),
    );

    final hpFraction = (currentHp / maxHp).clamp(0.0, 1.0);
    if (hpFraction < 0.75) _renderDamage(canvas, cx, cy, hpFraction);

    canvas.restore();

    _renderShield(canvas);
  }

  void _renderDamage(Canvas canvas, double cx, double cy, double hpFraction) {
    final stainPaint = Paint()..color = const Color(0xBB880000);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3, cy - 5), width: 5, height: 4), stainPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy + 2), width: 4, height: 3), stainPaint);

    if (hpFraction >= 0.50) return;

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy + 3), width: 5, height: 4), stainPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy - 7), width: 4, height: 4), stainPaint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 6, cy + 12), width: 10, height: 8),
      Paint()
        ..color = const Color(0x77333333)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    if (hpFraction >= 0.25) return;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 6, cy - 2), width: 12, height: 8),
      Paint()..color = const Color(0x66440000),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy + 8), width: 10, height: 9),
      Paint()
        ..color = const Color(0xCCFF4400)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    if (hpFraction >= 0.10) return;

    final pulse = math.sin(_damageTime * 10) * 0.5 + 0.5;
    final pulseAlpha = (80 + pulse * 120).toInt();
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 42),
      Paint()
        ..color = Color.fromARGB(pulseAlpha ~/ 2, 255, 0, 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 5, cy + 10), width: 11, height: 10),
      Paint()
        ..color = Color.fromARGB(pulseAlpha, 255, 100, 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 5, cy + 10), width: 11, height: 10),
      Paint()
        ..color = Color.fromARGB(pulseAlpha, 255, 100, 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
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
    const ringRadius = 28.0;
    final sc = _shieldColor;

    canvas.drawCircle(
      Offset(cx, cy),
      ringRadius,
      Paint()
        ..color = Color.fromARGB(alpha ~/ 3, sc.red, sc.green, sc.blue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final ringColor = _shieldFlashTimer > 0
        ? const Color(0xC8FFFFFF)
        : Color.fromARGB(alpha, sc.red, sc.green, sc.blue);
    canvas.drawCircle(
      Offset(cx, cy),
      ringRadius,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
  }
}
