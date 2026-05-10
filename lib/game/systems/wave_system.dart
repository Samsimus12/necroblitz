import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/monster_boss.dart';
import '../components/monster_boss_blood_colossus.dart';
import '../components/monster_boss_cosmic_behemoth.dart';
import '../components/monster_boss_dreadnought.dart';
import '../components/monster_boss_leviathan.dart';
import '../components/monster_boss_shadow_reaper.dart';
import '../components/monster_boss_singularity.dart';
import '../components/monster_boss_solar_titan.dart';
import '../components/monster_boss_storm_phantom.dart';
import '../components/monster_boss_void_emperor.dart';
import '../components/monster_boss_void_tyrant.dart';
import '../components/monster_caster.dart';
import '../components/monster_grunt.dart';
import '../components/monster_speeder.dart';
import '../components/monster_tank.dart';
import '../necroblitz_game.dart';

class WaveSystem extends Component with HasGameReference<NecroblitzGame> {
  double _timer = 0;
  double _tankTimer = 0;
  bool _isBossFight = false;
  int _bossKillLevel = 0;
  final _rng = math.Random();

  // Levels elapsed since the last boss kill (or game start).
  int get _waveLevel => game.xpSystem.currentLevel - _bossKillLevel;

  double get _spawnInterval {
    final wl = _waveLevel;
    if (wl < 3) return 3.0;
    if (wl < 5) return 2.0;
    if (wl < 8) return 1.5;
    if (wl < 12) return 1.0;
    return 0.7;
  }

  double get _tankSpawnInterval {
    final wl = _waveLevel;
    if (wl < 5) return double.infinity;
    if (wl < 8) return 15.0;
    if (wl < 12) return 10.0;
    return 7.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isBossFight) return;

    _timer += dt;
    if (_timer >= _spawnInterval) {
      _timer = 0;
      _spawnRegular();
    }

    final tankInterval = _tankSpawnInterval;
    if (tankInterval != double.infinity) {
      _tankTimer += dt;
      if (_tankTimer >= tankInterval) {
        _tankTimer = 0;
        _spawnAt(MonsterTank(
          position: _randomEdgePosition(),
          playerLevel: _effectiveLevel,
        ));
      }
    }
  }

  int get _effectiveLevel => game.xpSystem.currentLevel + game.bossPhase * 8;

  void _spawnRegular() {
    final wl = _waveLevel;
    final eff = _effectiveLevel;
    final pos = _randomEdgePosition();
    final roll = _rng.nextDouble();
    if (wl >= 7 && roll < 0.15) {
      _spawnAt(MonsterCaster(position: pos, playerLevel: eff));
    } else if (wl >= 3 && roll < (wl >= 7 ? 0.50 : 0.35)) {
      _spawnAt(MonsterSpeeder(position: pos, playerLevel: eff));
    } else {
      _spawnAt(MonsterGrunt(position: pos, playerLevel: eff));
    }
  }

  void _spawnAt(Component monster) {
    game.world.add(monster);
  }

  Vector2 _randomEdgePosition() {
    final sz = game.size;
    switch (_rng.nextInt(4)) {
      case 0:
        return Vector2(_rng.nextDouble() * sz.x, -50);
      case 1:
        return Vector2(sz.x + 50, _rng.nextDouble() * sz.y);
      case 2:
        return Vector2(_rng.nextDouble() * sz.x, sz.y + 50);
      default:
        return Vector2(-50, _rng.nextDouble() * sz.y);
    }
  }

  void startBossFight(int playerLevel) {
    _isBossFight = true;
    _timer = 0;
    _tankTimer = 0;
    final spawnPos = Vector2(game.size.x / 2, -80);
    // Cycle through 10 unique bosses; bossPhase is the count already defeated.
    final BossMonster boss = switch (game.bossPhase % 10) {
      0 => MonsterBossDreadnought(position: spawnPos, playerLevel: playerLevel),
      1 => MonsterBossVoidTyrant(position: spawnPos, playerLevel: playerLevel),
      2 => MonsterBossLeviathan(position: spawnPos, playerLevel: playerLevel),
      3 => MonsterBossBloodColossus(position: spawnPos, playerLevel: playerLevel),
      4 => MonsterBossStormPhantom(position: spawnPos, playerLevel: playerLevel),
      5 => MonsterBossCosmicBehemoth(position: spawnPos, playerLevel: playerLevel),
      6 => MonsterBossShadowReaper(position: spawnPos, playerLevel: playerLevel),
      7 => MonsterBossSolarTitan(position: spawnPos, playerLevel: playerLevel),
      8 => MonsterBossVoidEmperor(position: spawnPos, playerLevel: playerLevel),
      _ => MonsterBossSingularity(position: spawnPos, playerLevel: playerLevel),
    };
    game.activeBoss = boss;
    game.world.add(boss);
  }

  void onBossKilled() {
    _isBossFight = false;
    _timer = 0;
    _tankTimer = 0;
    _bossKillLevel = game.xpSystem.currentLevel;
  }

  void reset() {
    _timer = 0;
    _tankTimer = 0;
    _isBossFight = false;
    _bossKillLevel = 0;
  }
}
