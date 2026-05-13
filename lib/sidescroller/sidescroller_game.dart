import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show EdgeInsets;

import 'components/ss_background.dart';
import 'components/ss_hud.dart';
import 'components/ss_platform.dart';
import 'components/ss_player.dart';
import 'components/ss_zombie.dart';
import 'components/ss_bullet.dart';

class SidescrollerGame extends FlameGame {
  static const double kGravity = 900.0;
  static const double kWorldWidth = 5000.0;

  late SsPlayer player;
  late JoystickComponent moveJoystick;
  final List<SsPlatform> platforms = [];
  int killCount = 0;
  bool isGameOver = false;

  // Set by the Flutter controls overlay
  bool jumpPressed = false;
  bool fireHeld = false;

  @override
  Color backgroundColor() => const Color(0xFF070711);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(SsBackground());
    _buildLevel();
    _buildJoystick();
    camera.viewport.add(SsHud());
  }

  void _buildLevel() {
    final h = size.y;
    final groundY = h - 64;

    _plat(0, groundY, kWorldWidth, 64);

    // Platforms — gradually ascending and varied
    _plat(280,  groundY - 100, 160, 14);
    _plat(510,  groundY - 150, 140, 14);
    _plat(730,  groundY - 110, 190, 14);
    _plat(990,  groundY - 170, 170, 14);
    _plat(1240, groundY - 130, 200, 14);
    _plat(1510, groundY - 190, 200, 14);
    _plat(1780, groundY - 145, 170, 14);
    _plat(2020, groundY - 175, 190, 14);
    _plat(2280, groundY - 125, 175, 14);
    _plat(2530, groundY - 165, 210, 14);
    _plat(2810, groundY - 200, 175, 14);
    _plat(3060, groundY - 145, 195, 14);
    _plat(3330, groundY - 175, 180, 14);
    _plat(3600, groundY - 135, 195, 14);
    _plat(3870, groundY - 190, 215, 14);
    _plat(4180, groundY - 155, 190, 14);
    _plat(4460, groundY - 130, 185, 14);
    _plat(4750, groundY - 100, 180, 14);

    player = SsPlayer(position: Vector2(80, groundY - 10));
    world.add(player);

    final g = groundY - 10.0;
    final enemyDefs = [
      (380.0, g),      (640.0, g),
      (530.0, groundY - 155.0),   // on platform
      (860.0, g),      (1050.0, groundY - 220.0),
      (1380.0, g),     (1580.0, groundY - 245.0),
      (1950.0, g),     (2090.0, groundY - 225.0),
      (2380.0, g),     (2600.0, groundY - 215.0),
      (2900.0, g),     (3130.0, groundY - 195.0),
      (3420.0, g),     (3660.0, groundY - 185.0),
      (3960.0, g),     (4240.0, groundY - 205.0),
      (4540.0, g),     (4820.0, g),
    ];
    for (final (x, y) in enemyDefs) {
      world.add(SsZombie(position: Vector2(x, y)));
    }
  }

  void _plat(double x, double y, double w, double h) {
    final p = SsPlatform(position: Vector2(x, y), size: Vector2(w, h));
    platforms.add(p);
    world.add(p);
  }

  void _buildJoystick() {
    moveJoystick = JoystickComponent(
      knob: CircleComponent(
        radius: 18,
        paint: Paint()..color = const Color(0x99FFD700),
      ),
      background: CircleComponent(
        radius: 36,
        paint: Paint()..color = const Color(0x44FFD700),
      ),
      margin: const EdgeInsets.only(left: 36, bottom: 44),
    );
    camera.viewport.add(moveJoystick);
  }

  void spawnBullet(Vector2 position, Vector2 direction) {
    world.add(SsBullet(position: position.clone(), direction: direction));
  }

  void onZombieKilled() => killCount++;

  void triggerGameOver() {
    if (isGameOver) return;
    isGameOver = true;
    pauseEngine();
    overlays.add('GameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;
    final targetX = (player.x - size.x * 0.30).clamp(0.0, kWorldWidth - size.x);
    camera.viewfinder.position = Vector2(targetX, 0);
  }
}
