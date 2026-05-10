import 'dart:math' as math;

import '../components/player.dart';
import '../components/weapon.dart';
import '../components/weapon_explosive_bolt.dart';
import '../components/weapon_frost_shard.dart';
import '../components/weapon_homing_bolt.dart';
import '../components/weapon_rapid_fire.dart';
import '../components/weapon_spread_shot.dart';
import '../components/weapon_sword_aura.dart';
import '../necroblitz_game.dart';

enum UpgradeCategory { weapon, nova, mobility }

abstract class UpgradeCard {
  String get title;
  String get description;
  String get iconLabel;
  UpgradeCategory get category;
  void apply(NecroblitzGame game);
}

class WeaponUpgradeCard extends UpgradeCard {
  final Weapon weapon;
  WeaponUpgradeCard(this.weapon);

  @override
  String get title => '${weapon.displayName} Lv${weapon.upgradeLevel + 1}';
  @override
  String get description => weapon.nextUpgradeDescription;
  @override
  String get iconLabel => '⬆';
  @override
  UpgradeCategory get category => UpgradeCategory.weapon;
  @override
  void apply(NecroblitzGame game) => weapon.applyUpgrade();
}

class NewWeaponCard extends UpgradeCard {
  final String _title;
  final String _description;
  final Weapon Function() factory;

  NewWeaponCard({
    required String title,
    required String description,
    required this.factory,
  })  : _title = title,
        _description = description;

  @override
  String get title => _title;
  @override
  String get description => _description;
  @override
  String get iconLabel => '✦';
  @override
  UpgradeCategory get category => UpgradeCategory.weapon;
  @override
  void apply(NecroblitzGame game) => game.player.add(factory());
}

class StatBuffCard extends UpgradeCard {
  final String _title;
  final String _description;
  final String _icon;
  final UpgradeCategory _category;
  final void Function(NecroblitzGame) _apply;

  StatBuffCard({
    required String title,
    required String description,
    required UpgradeCategory category,
    required void Function(NecroblitzGame) apply,
    String icon = '★',
  })  : _title = title,
        _description = description,
        _category = category,
        _icon = icon,
        _apply = apply;

  @override
  String get title => _title;
  @override
  String get description => _description;
  @override
  String get iconLabel => _icon;
  @override
  UpgradeCategory get category => _category;
  @override
  void apply(NecroblitzGame game) => _apply(game);
}

List<UpgradeCard> generateUpgradeCards(NecroblitzGame game) {
  final rng = math.Random();
  final pool = <UpgradeCard>[];
  final player = game.player;
  final phase = game.bossPhase;

  final fireRatePct   = 15 + phase * 5;
  final weaponDmgPct  = 20 + phase * 5;
  final chargePct     = 20 + phase * 5;
  final beamPct       = 20 + phase * 5;
  final novaDmgPct    = 30 + phase * 5;

  final fireRateMult  = 1.0 + fireRatePct / 100.0;
  final weaponDmgMult = 1.0 + weaponDmgPct / 100.0;
  final chargeBonus   = chargePct / 100.0;
  final beamBonus     = beamPct / 100.0;
  final novaDmgBonus  = novaDmgPct / 100.0;

  for (final w in player.activeWeapons) {
    if (w.isUpgradeable && w.upgradeLevel < 10) pool.add(WeaponUpgradeCard(w));
  }

  if (!player.hasWeapon<WeaponSpreadShot>()) {
    pool.add(NewWeaponCard(
      title: 'Shotgun Blast',
      description: 'Fires 3 pellets in a wide spread',
      factory: WeaponSpreadShot.new,
    ));
  }
  if (!player.hasWeapon<WeaponRapidFire>()) {
    pool.add(NewWeaponCard(
      title: 'Machine Gun',
      description: '4 shots/sec at 60% power each',
      factory: WeaponRapidFire.new,
    ));
  }
  if (!player.hasWeapon<WeaponHomingBolt>()) {
    pool.add(NewWeaponCard(
      title: 'Tracking Dart',
      description: 'Self-guided dart seeks the nearest zombie',
      factory: WeaponHomingBolt.new,
    ));
  }
  if (!player.hasWeapon<WeaponSwordAura>()) {
    pool.add(NewWeaponCard(
      title: 'Blade Ring',
      description: 'Spinning blades shred nearby zombies',
      factory: WeaponSwordAura.new,
    ));
  }
  if (!player.hasWeapon<WeaponExplosiveBolt>()) {
    pool.add(NewWeaponCard(
      title: 'Frag Grenade',
      description: 'Detonates on impact, blasting all nearby zombies',
      factory: WeaponExplosiveBolt.new,
    ));
  }
  if (!player.hasWeapon<WeaponFrostShard>()) {
    pool.add(NewWeaponCard(
      title: 'Stun Grenade',
      description: 'Flash-bang slows zombies to 40% speed for 2s',
      factory: WeaponFrostShard.new,
    ));
  }

  if (rng.nextDouble() < 0.10) {
    pool.add(StatBuffCard(
      title: 'Military Cache',
      description: 'All weapons deal +$weaponDmgPct% damage',
      category: UpgradeCategory.weapon,
      apply: (g) {
        for (final w in g.player.activeWeapons) {
          w.damage *= weaponDmgMult;
        }
      },
    ));
  }

  pool.add(StatBuffCard(
    title: 'Ammo Drop',
    description: 'Fire rate +$fireRatePct% for all weapons',
    category: UpgradeCategory.weapon,
    apply: (g) {
      for (final w in g.player.activeWeapons) {
        w.fireRate *= fireRateMult;
      }
    },
  ));

  pool.addAll([
    StatBuffCard(
      title: 'Rage Builder',
      description: 'Blitz charge rate +$chargePct% faster',
      category: UpgradeCategory.nova,
      apply: (g) => g.superchargeSystem.chargeMultiplier += chargeBonus,
    ),
    StatBuffCard(
      title: 'Extended Rampage',
      description: 'Blitz lasts $beamPct% longer',
      category: UpgradeCategory.nova,
      apply: (g) => g.superchargeSystem.depleteMultiplier =
          (g.superchargeSystem.depleteMultiplier - beamBonus).clamp(0.2, 1.0),
    ),
    StatBuffCard(
      title: 'Blitz Overload',
      description: 'Blitz damage +$novaDmgPct%',
      category: UpgradeCategory.nova,
      icon: '⚡',
      apply: (g) => g.superchargeSystem.damageMultiplier += novaDmgBonus,
    ),
  ]);

  if (player.afterburnerStacks < Player.maxAfterburnerStacks) {
    pool.add(StatBuffCard(
      title: 'Adrenaline Rush',
      description: 'Survivor moves +25% faster',
      category: UpgradeCategory.mobility,
      apply: (g) {
        g.player.moveSpeed *= 1.25;
        g.player.afterburnerStacks++;
      },
    ));
  }

  final byCategory = <UpgradeCategory, List<UpgradeCard>>{};
  for (final card in pool) {
    byCategory.putIfAbsent(card.category, () => []).add(card);
  }

  final picks = <UpgradeCard>[];
  for (final cards in byCategory.values) {
    cards.shuffle(rng);
    picks.add(cards.first);
  }
  picks.shuffle(rng);

  if (picks.length < 3) {
    final chosen = picks.toSet();
    final leftovers = pool.where((c) => !chosen.contains(c)).toList()..shuffle(rng);
    picks.addAll(leftovers.take(3 - picks.length));
  }

  return picks.take(3).toList();
}

List<StatBuffCard> rollBonusCards(NecroblitzGame game) {
  final result = <StatBuffCard>[];
  final rng = math.Random();
  if (rng.nextDouble() < 0.20) {
    result.add(StatBuffCard(
      title: '+25 Body Armour',
      description: 'Scavenged armour plates for +25 max HP',
      category: UpgradeCategory.mobility,
      icon: '♥',
      apply: (g) {
        g.player.maxHp += 25;
        g.player.currentHp = (g.player.currentHp + 25).clamp(0, g.player.maxHp);
      },
    ));
  }
  if (rng.nextDouble() < 0.20) {
    result.add(StatBuffCard(
      title: 'Med Kit',
      description: 'Emergency bandages restore 40 HP',
      category: UpgradeCategory.mobility,
      icon: '♥',
      apply: (g) {
        g.player.currentHp = (g.player.currentHp + 40).clamp(0, g.player.maxHp);
      },
    ));
  }
  return result;
}
