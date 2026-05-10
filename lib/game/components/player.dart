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
          jacket: Color(0xFF4DD0E1), pants: Color(0xFF0097A7),
          highlight: Color(0xFFE0F7FA), glow: Color(0xAA00B8D4)),
      'flame' => const _OutfitPalette(
          jacket: Color(0xFFFF5722), pants: Color(0xFFBF360C),
          highlight: Color(0xFFFFAB91), glow: Color(0xAADD2C00)),
      'shadow' => const _OutfitPalette(
          jacket: Color(0xFF424242), pants: Color(0xFF212121),
          highlight: Color(0xFF757575), glow: Color(0xAA616161)),
      'solar' => const _OutfitPalette(
          jacket: Color(0xFFFFD600), pants: Color(0xFFF57F17),
          highlight: Color(0xFFFFFFFF), glow: Color(0xAAFF8F00)),
      'void' => const _OutfitPalette(
          jacket: Color(0xFF6A1B9A), pants: Color(0xFF4A148C),
          highlight: Color(0xFFCE93D8), glow: Color(0xAA7B1FA2)),
      _ => const _OutfitPalette(
          jacket: Color(0xFF4CAF50), pants: Color(0xFF2E7D32),
          highlight: Color(0xFFA5D6A7), glow: Color(0xAA388E3C)),
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
      : super(size: Vector2.all(48), anchor: Anchor.center, priority: 3);

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

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Aim direction laser sight
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
      // Red dot
      canvas.drawCircle(Offset(ex, ey), 2.5,
        Paint()..color = const Color(0x88FF2200));
    }

    final pal = _paletteForSkin(CoinManager.instance.selectedSkin);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_facingAngle);
    canvas.translate(-cx, -cy);

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3), width: 28, height: 10),
      Paint()..color = const Color(0x55000000));

    // ── Legs ──────────────────────────────────────────────────────────────
    // Back leg (right in local space)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy + 10), width: 8, height: 14),
        const Radius.circular(3)),
      Paint()..color = pal.pants);
    // Front leg (left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 6, cy + 9), width: 8, height: 14),
        const Radius.circular(3)),
      Paint()..color = pal.pants);
    // Knee pad suggestion
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 6, cy + 8), width: 8, height: 3),
      Paint()..color = pal.highlight.withAlpha(100));

    // Boots
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy + 18), width: 10, height: 6),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF2C1A0E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 6, cy + 17), width: 10, height: 6),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF2C1A0E));
    // Boot sole
    canvas.drawRect(Rect.fromLTWH(cx - 12, cy + 20, 10, 1),
      Paint()..color = const Color(0xFF1A0A04));

    // ── Torso / tactical vest ─────────────────────────────────────────────
    final torso = Path()
      ..moveTo(cx, cy - 12)
      ..lineTo(cx + 10, cy - 4)
      ..lineTo(cx + 9, cy + 7)
      ..lineTo(cx, cy + 6)
      ..lineTo(cx - 9, cy + 7)
      ..lineTo(cx - 10, cy - 4)
      ..close();
    canvas.drawPath(torso, Paint()..color = pal.jacket);

    // Vest highlight — chest plate line
    canvas.drawPath(torso,
      Paint()..color = pal.highlight.withAlpha(55)
             ..style = PaintingStyle.stroke
             ..strokeWidth = 1.2);

    // Chest strap — horizontal across torso
    canvas.drawLine(Offset(cx - 8, cy - 1), Offset(cx + 8, cy - 1),
      Paint()..color = pal.highlight.withAlpha(80)..strokeWidth = 1.5);
    // Buckle dot
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 1), width: 4, height: 3),
      Paint()..color = const Color(0xFFAAAAAA));

    // Side pouches
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 10, cy + 2), width: 5, height: 6),
        const Radius.circular(1)),
      Paint()..color = pal.jacket.withAlpha(220));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 10, cy + 2), width: 5, height: 6),
        const Radius.circular(1)),
      Paint()..color = pal.jacket.withAlpha(220));

    // ── Weapon (gun) — left side, pointing forward (up) ──────────────────
    // Grip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 10, cy - 3), width: 5, height: 7),
        const Radius.circular(1)),
      Paint()..color = const Color(0xFF1A1A1A));
    // Frame / slide
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 10, cy - 11), width: 5, height: 14),
        const Radius.circular(1)),
      Paint()..color = const Color(0xFF2A2E30));
    // Barrel
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 10, cy - 19), width: 3, height: 6),
      Paint()..color = const Color(0xFF3A3E40));
    // Muzzle
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 10, cy - 23), width: 4, height: 3),
      Paint()..color = const Color(0xFF455A64));
    // Trigger guard
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 9.5, cy - 5), width: 6, height: 5),
      0, math.pi, false,
      Paint()..color = const Color(0xFF2A2E30)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // ── Arms ─────────────────────────────────────────────────────────────
    // Left arm (gun arm) — extended forward, holding gun
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 13, cy - 7), width: 7, height: 15),
        const Radius.circular(3)),
      Paint()..color = pal.jacket);
    // Left hand
    canvas.drawCircle(Offset(cx - 12, cy - 15), 3.5,
      Paint()..color = const Color(0xFFBC8A6A));

    // Right arm — bent slightly, supporting stance
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 13, cy - 1), width: 7, height: 11),
        const Radius.circular(3)),
      Paint()..color = pal.jacket);
    // Right hand
    canvas.drawCircle(Offset(cx + 13, cy - 7), 3.5,
      Paint()..color = const Color(0xFFBC8A6A));

    // ── Head / helmet ─────────────────────────────────────────────────────
    // Helmet glow
    canvas.drawCircle(Offset(cx, cy - 15), 11,
      Paint()..color = pal.glow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Helmet base (hard shell)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 15), width: 20, height: 18),
      Paint()..color = const Color(0xFF9E9E9E));

    // Helmet top brim
    canvas.drawRect(
      Rect.fromLTWH(cx - 10, cy - 24, 20, 4),
      Paint()..color = const Color(0xFF757575));

    // Visor — dark tinted
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 15), width: 14, height: 8),
      Paint()..color = pal.highlight.withAlpha(140));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 15), width: 14, height: 8),
      Paint()..color = const Color(0xFF000000).withAlpha(80));
    // Visor highlight glint
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy - 17), width: 5, height: 3),
      Paint()..color = const Color(0x66FFFFFF));

    // Chin guard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 9), width: 12, height: 5),
        const Radius.circular(2)),
      Paint()..color = const Color(0xFF616161));

    // Ear protection / ear cup
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 10, cy - 15), width: 5, height: 7),
      Paint()..color = const Color(0xFF616161));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 10, cy - 15), width: 5, height: 7),
      Paint()..color = const Color(0xFF616161));

    // Damage overlays
    final hpFraction = (currentHp / maxHp).clamp(0.0, 1.0);
    if (hpFraction < 0.75) _renderDamage(canvas, cx, cy, hpFraction);

    canvas.restore();

    _renderShield(canvas);
  }

  void _renderDamage(Canvas canvas, double cx, double cy, double hpFraction) {
    // Blood stains on torso
    final stain = Paint()..color = const Color(0xCC880000);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3, cy - 3), width: 7, height: 5), stain);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 4, cy + 3), width: 5, height: 4), stain);

    if (hpFraction >= 0.50) return;

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy + 5), width: 6, height: 5), stain);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy - 6), width: 5, height: 4), stain);
    // Smoke puff
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 7, cy + 14), width: 14, height: 10),
      Paint()..color = const Color(0x66333333)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    if (hpFraction >= 0.25) return;

    // Burning arm
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 6, cy), width: 14, height: 9),
      Paint()..color = const Color(0x66440000));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 4, cy + 10), width: 12, height: 11),
      Paint()..color = const Color(0xCCFF5500)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    if (hpFraction >= 0.10) return;

    // Critical pulse
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
