# NecroBlitz — Project Handoff

## What This Is
Cross-platform (iOS + Android) zombie apocalypse arena survival game — Flutter + Flame engine.
Top-down (bird's-eye) view. Left joystick moves, right joystick aims and fires. Kill zombies → XP → level up → card pick. Blitz bar fills on kills → activate for screen-wide attack. Boss every 10 levels — 10 unique mutant bosses cycling with increasing difficulty. AdMob live. SCRAPS (🔩) coin economy for survivor skins, armour, and Blitz colours.

**Forked from**: novabolt (same mechanics, full zombie reskin)
**GitHub**: https://github.com/Samsimus12/necroblitz

---

## ⚠️ CRITICAL PERSPECTIVE — affects all visual work

True **top-down (bird's-eye) view** — drone camera directly above. Think GTA 1/2 or Hotline Miami.
- Backgrounds are **floor/ground textures** seen from above
- All characters are **overhead sprites** — head visible from above, body foreshortened

---

## How to Run
```bash
flutter pub get
cd ios && pod install && cd ..   # after adding plugins
flutter run -d "Samsimus"        # physical iPhone (preferred)
# Hot reload: r  |  Hot restart: R  |  Quit: q
# After native changes: always full flutter run, not hot reload
# USB error "Connection reset by peer" → unplug/replug and retry
```

## Tech Stack
- **Flutter** (Dart SDK `^3.11.5`) + **Flame 1.37.0** (2D game engine)
- **flame_audio 2.12.1** — BGM files in `assets/` (prefix set to `assets/`)
- **google_mobile_ads 5.3.1** — rewarded + interstitial ads
- **app_tracking_transparency 2.0.6** — must fire before AdMob init on iOS
- **shared_preferences** — persists scraps, owned items, selected skins, best stats
- **PixelLab MCP** — AI pixel art generation (characters + tiles); credentials configured
- All gameplay visuals are **code-drawn** (Canvas) OR **PixelLab sprites** — no manual image assets

---

## File Structure
```
assets/
├── *.wav                          # BGM tracks (Fighting, Boss Battle, Menu, etc.)
├── images/
│   ├── survivor/                  # 8-direction player sprites (92×92px PNGs)
│   │   └── south/east/north/west/south-east/north-east/north-west/south-west.png
│   └── background/
│       └── phase0/                # 16 city ruins tiles (32×32px, tile_0..tile_15.png)
lib/
├── main.dart                      # ATT prompt → AdMob init → menu/game
├── ads/ad_manager.dart            # Singleton; rewarded + interstitial
├── audio/audio_manager.dart       # Singleton; playMenu/playGame/playBoss; crossfades
├── coins/coin_manager.dart        # Singleton; SCRAPS, owned items, selected skins
├── stats/stats_manager.dart       # Singleton; bestLevel, bestKills
├── game/
│   ├── necroblitz_game.dart       # FlameGame root — bossPhase, killCount, onBossKilled()
│   ├── components/
│   │   ├── player.dart            # PixelLab sprite player (8 directions, 72px display)
│   │   ├── background.dart        # StarBackground — phase 0 tiled sprites, phases 1-9 canvas
│   │   ├── monster_grunt/tank/speeder/caster.dart  # ⚠️ Need top-down redesign
│   │   ├── monster_boss_dreadnought.dart   # ⚠️ Needs zombie render (Abomination, phase 0)
│   │   ├── monster_boss_void_tyrant.dart   # ⚠️ Needs zombie render (Plague Lord, phase 1)
│   │   ├── monster_boss_leviathan.dart     # ⚠️ Needs zombie render (Gore Beast, phase 2)
│   │   ├── monster_boss_blood_colossus.dart# ⚠️ Needs zombie render (Titan Zombie, phase 3)
│   │   ├── monster_boss_storm_phantom.dart # ⚠️ Needs zombie render (Feral Alpha, phase 4)
│   │   ├── monster_boss_cosmic_behemoth.dart # ⚠️ Needs zombie render (Necrohulk, phase 5)
│   │   ├── monster_boss_shadow_reaper.dart # ⚠️ Needs zombie render (Wraith, phase 6)
│   │   ├── monster_boss_solar_titan.dart   # ⚠️ Needs zombie render (Rot Giant, phase 7)
│   │   ├── monster_boss_void_emperor.dart  # ⚠️ Needs zombie render (Infection King, phase 8)
│   │   ├── monster_boss_singularity.dart   # ⚠️ Needs zombie render (Horde Mind, phase 9)
│   │   ├── weapon_*.dart          # 7 weapons (Pistol, Shotgun, Machine Gun, Tracking Dart,
│   │   │                          #            Blade Ring, Frag Grenade, Stun Grenade)
│   │   ├── hud.dart               # HP/BLITZ/XP bars, boss bar
│   │   └── [other components]     # projectile, shield_pickup, health_pickup, death_particles
│   ├── systems/wave_system.dart   # effectiveLevel = currentLevel + bossPhase*8
│   └── data/upgrade_cards.dart    # 14 upgrade cards
└── screens/                       # main_menu, shop, level_up, game_over, game_controls
```

---

## What Is Done ✅

### PixelLab Sprite Integration
- **Player**: fully replaced canvas-drawn survivor with PixelLab pro sprites
  - PixelLab character ID: `b5924bc1-e5cf-498c-aa4e-f13a6f17e143` (Civilian Survivor)
  - 8 directional PNGs in `assets/images/survivor/` (92×92px canvas, displayed at 72×72px)
  - `_facingAngle` (0=north, clockwise) maps to direction string via `_spriteDirection` getter
  - Skin variants: semi-transparent colour overlay (`srcATop` blend) + helmet glow ring
  - Laser sight, damage overlays, and shield ring still canvas-drawn on top

- **Phase 0 Background**: replaced canvas city ruins with PixelLab tiles
  - PixelLab tile ID: `ea0834fb-a435-479c-8e9a-8d1e4b2df1ab` (City Ruins, 16 tiles)
  - 16 tiles (tile_0..tile_15) in `assets/images/background/phase0/`, each 32×32px
  - Deterministic tile selection: `(col*17 + row*31 + col*row*3) % 16`
  - Manhole covers + building rooftop footprints still canvas-drawn on top of tiles
  - Animated ash particles still drawn last (on top of everything)
  - **Phases 1–9 still canvas-drawn** — need PixelLab tile sets generated

### Game Systems (all complete)
- 10-phase boss cycle with increasing difficulty
- Music crossfade between menu/fighting/boss tracks
- AdMob rewarded + interstitial ads live
- Full SCRAPS economy + shop (6 survivor skins, 4 armour skins, 4 Blitz themes)
- Level-up card picker (14 cards), Blitz bar + 11 Blitz modes
- Boss death → new StarBackground (re-added with new phase)

### All UI Screens ✅
Main menu, shop, HUD, level-up, game-over, loading — all fully zombie-themed.

---

## What's Remaining ⚠️

### Priority 1 — PixelLab backgrounds for phases 1–9
For each phase, generate tiles with `create_tiles_pro` (square_topdown, 32px, segmentation mode),
download to `assets/images/background/phase{N}/`, add to pubspec.yaml, implement `_loadTilesForPhase`
branch, and replace the canvas `_render*` method with a tile grid + canvas overlays.

Phase descriptions for tile prompts:
| Phase | Name | Tile description |
|---|---|---|
| 1 | Industrial Wasteland | Dark metal grating, rust stains, pipe shadows |
| 2 | Toxic Sewers | Wet concrete with drain channels, toxic green puddles |
| 3 | Blood Streets | Dark asphalt with blood pool splats, tyre marks |
| 4 | Radioactive Zone | Cracked irradiated earth, caution stripe bands |
| 5 | Frozen Wastes | Snow-covered ground, glossy ice patches |
| 6 | Burning City | Scorched black asphalt, ember-lit ground, fire patches |
| 7 | Underground Bunker | Concrete tile floor grid, painted floor arrows |
| 8 | Dead Forest | Dark soil, dead leaves, tree stump circles |
| 9 | Horde Mind | Pulsing organic flesh-floor, neural vein network |

### Priority 2 — All 10 boss renders (top-down zombie mutants)
All 10 boss files still have Novabolt space-warship `render()`. Only `render()` needs replacing —
attack patterns (`fireSpecialAttack`) are correct and must stay unchanged.

| Boss | Design |
|---|---|
| Abomination (phase 0) | Large oval body, 6 claw-arms radially, glowing wound on back |
| Plague Lord (phase 1) | Huge round body dripping bile, pustule bumps, fly swarm halo |
| Gore Beast (phase 2) | Segmented centipede/slug body, mandible claws at front |
| Titan Zombie (phase 3) | Large humanoid top-down, scrap armour plates |
| Feral Alpha (phase 4) | Lean X-shaped body, claws in 4 directions |
| Necrohulk (phase 5) | Huge circular body, glowing green cracks |
| Wraith (phase 6) | Wispy smoke cloud, skull face inside |
| Rot Giant (phase 7) | Large humanoid, exposed rib cage from above |
| Infection King (phase 8) | Spider-like, tentacle limbs radiating out, pulsing core |
| Horde Mind (phase 9) | Cluster of fused zombie shapes, one pulsing mass |

### Priority 3 — Regular enemy top-down redesigns
monster_grunt, monster_tank, monster_speeder, monster_caster all need overhead zombie renders.
Consider generating with PixelLab (character type, high top-down, pro mode).

### Priority 4 — App Store
- Register NecroBlitz in AdMob; replace Novabolt ad unit IDs in `ad_manager.dart`
- New zombie app icon (`assets/icon/icon.png`) and splash (`assets/splash/splash.png`)
- `flutter build ipa --release` → Transporter → App Store Connect

---

## Key Technical Decisions & Gotchas

1. **Camera origin**: `camera.viewfinder.anchor = Anchor.topLeft` — world == screen coords. Do NOT change.

2. **Player size is 48px**: `super(size: Vector2.all(48), anchor: Anchor.center)`. Sprites display at 72px (overflows component bounds visually — fine). Hitbox is `CircleHitbox` inside the 48px component.

3. **Sprite direction mapping**: `_facingAngle` = 0 means facing north (up screen), increases clockwise. `_spriteDirection` getter maps to one of 8 strings using `((angle + π/8) / (π/4)).floor() % 8`.

4. **PixelLab image path**: Flame loads from `assets/images/` prefix. `game.images.load('survivor/south.png')` → `assets/images/survivor/south.png`. Each new sprite folder needs a `- assets/images/<folder>/` entry in pubspec.yaml.

5. **StarBackground re-init**: `onBossKilled()` and `restart()` both remove and re-add `StarBackground`, so `onLoad` runs fresh each phase change. `_loadTilesForPhase` must check `game.bossPhase % 10`.

6. **`StarBackground` class name kept**: Referenced widely — do not rename even though it renders ground, not stars.

7. **ATT before AdMob**: `main.dart _initialize()` requests ATT before `AdManager.instance.init()`. Required for iOS.

8. **Weapons as Player children**: Weapon `render()` is in Player local space — draw at `(size.x/2, size.y/2)` for center.

9. **`NovaMode` enum values kept unchanged**: (laser, dreadnought, voidTyrant…) Only display strings are zombie-themed.

10. **Skin item IDs unchanged**: (skin_default, shield_default, nova_default…) SharedPreferences compatibility.

11. **Boss death hook**: `Monster._die()` → `onDie()` → `BossMonster.onDie()` → `game.onBossKilled()`. Don't touch.

12. **`fireSpecialAttack()` is public on BossMonster**: Subclasses override it. Don't make private.

13. **`Projectile.lifetime` is public**: `HomingBolt` increments it manually (skips `super.update()`).

14. **flame_audio path**: `FlameAudio.updatePrefix('assets/')` — audio files are in `assets/` root.

---

## PixelLab MCP Reference
- **Tool**: `mcp__pixellab__create_character` (pro mode = 20 credits, ~3-5 min)
- **Tool**: `mcp__pixellab__create_tiles_pro` (standard, ~15-90 sec)
- **Character view for this game**: `"high top-down"`
- **Tile type for backgrounds**: `square_topdown`, `tile_size: 32`, `outline_mode: "segmentation"`
- **Check status**: `get_character` / `get_tiles_pro` with the returned ID
- **Download**: `curl --fail` from the B2 storage URLs in the result

## Enemy Stats Reference
| Monster | HP | Speed | Contact Dmg | XP |
|---|---|---|---|---|
| Grunt | 30 | 80 | 10 | 10 |
| Speeder | 18 | 210 | 7 | 5 |
| Tank | 160 | 45 | 18 | 30 |
| Caster | 40 | 55 | 6 | 20 |
| Abomination (ph0) | 800 | 30 | 28 | 0 |
| Plague Lord (ph1) | 1600 | 45 | 40 | 0 |
| Gore Beast (ph2) | 2400 | 35 | 45 | 0 |
| Titan Zombie (ph3) | 3200 | 25 | 52 | 0 |
| Feral Alpha (ph4) | 2000 | 65 | 38 | 0 |
| Necrohulk (ph5) | 4000 | 20 | 58 | 0 |
| Wraith (ph6) | 2800 | 55 | 48 | 0 |
| Rot Giant (ph7) | 3600 | 30 | 55 | 0 |
| Infection King (ph8) | 4800 | 40 | 62 | 0 |
| Horde Mind (ph9) | 6000 | 35 | 70 | 0 |
