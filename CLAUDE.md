# NecroBlitz — Project Handoff

## What This Is
Cross-platform (iOS + Android) zombie apocalypse game — Flutter + Flame engine.

**Two modes exist in this repo:**
- **Side-scroller** (`lib/sidescroller/`) — Contra-style platformer, currently the active game (`main.dart` routes here). 10 levels planned, cutscenes between levels (user handles art/VO).
- **Top-down arena** (`lib/game/`) — original bird's-eye survival mode. Fully built but currently bypassed by `main.dart`.

**Active direction**: Side-scroller prototype is in progress. Top-down code is intact and can be restored.

**Forked from**: novabolt (same mechanics, full zombie reskin)
**GitHub**: https://github.com/Samsimus12/necroblitz

---

## ⚠️ CRITICAL PERSPECTIVE — top-down mode only

True **top-down (bird's-eye) view** — drone camera directly above. Think GTA 1/2 or Hotline Miami.
- Backgrounds are **floor/ground textures** seen from above
- All characters are **overhead sprites** — head visible from above, body foreshortened
- This does NOT apply to the side-scroller mode

---

## How to Run
```bash
flutter pub get
cd ios && pod install && cd ..   # after adding plugins
flutter run -d "Samsimus"        # physical iPhone (preferred)
# Hot reload: r  |  Hot restart: R  |  Quit: q
# After native changes: always full flutter run, not hot reload
# USB error "Connection reset by peer" → unplug/replug and retry
# Build error "expected app not found / SdkRoot" → flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run
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
└── images/
    ├── survivor/                  # Top-down 8-dir idle sprites (92×92px PNGs)
    │   └── walk/                  # Top-down walk: {direction}_{0-3}.png (32 files)
    ├── ss_survivor/               # Side-scroller survivor sprites (92×92px canvas, east-facing)
    │   ├── idle.png               # Standing idle
    │   └── walk_{0-5}.png         # 6-frame walk cycle
    └── ss_zombie/                 # Side-scroller zombie sprites (92×92px canvas, east-facing)
        ├── idle.png
        ├── walk_{0-7}.png         # 8-frame scary-walk cycle
        └── death_{0-6}.png        # 7-frame falling-back-death animation
lib/
├── main.dart                      # ATT prompt → AdMob init → menu/game
├── ads/ad_manager.dart
├── audio/audio_manager.dart       # Singleton; playMenu/playGame/playBoss; crossfades
├── coins/coin_manager.dart        # Singleton; SCRAPS, owned items, selected skins
├── stats/stats_manager.dart       # Singleton; bestLevel, bestKills
├── game/                          # Top-down arena (intact, not active)
│   ├── necroblitz_game.dart
│   ├── components/
│   │   ├── player.dart            # PixelLab sprite player (8 dir, idle + 4-frame walk)
│   │   ├── background.dart        # Phase 0 GTA1-style canvas; phases 1-9 canvas placeholders
│   │   ├── barricade.dart         # Blitz barricade (canvas, 64×18, 150HP, 20s lifetime)
│   │   ├── monster_*.dart         # Grunt/Tank/Speeder/Caster + 10 bosses
│   │   └── weapon_*.dart          # 7 weapons
│   ├── data/
│   │   ├── map_data.dart          # City grid walkability (kTileSize=32)
│   │   └── upgrade_cards.dart
│   └── systems/
│       ├── flow_field.dart        # BFS pathfinding
│       └── wave_system.dart
└── sidescroller/                  # Active game mode
    ├── sidescroller_game.dart     # FlameGame root — gravity, platforms, camera, shake/hit-stop
    ├── ss_controls_overlay.dart   # Flutter overlay — jump button (▲), aim joystick
    └── components/
        ├── ss_player.dart         # PixelLab sprite soldier + canvas fallback
        ├── ss_zombie.dart         # PixelLab sprite zombie + canvas fallback
        ├── ss_bullet.dart         # Orange glow bullet
        ├── ss_platform.dart       # Brown rect platform (placeholder)
        ├── ss_background.dart     # 2-layer parallax city ruins
        └── ss_hud.dart            # HP bar + kill count
```

---

## Side-Scroller — Current State

### PixelLab Sprites (just integrated — ⚠️ VERIFY ON DEVICE)
- **PixelLab character IDs**: Survivor `0e1c6526-536d-4b3e-be15-906bb23ca3d4`, Zombie `c31985e4-3b48-4940-b6eb-ec97cdf0c370`
- All sprites are **east-facing only** — canvas flip handles left-facing
- Sprites render at **72×72** inside the component bounds (26×46 player, 26×38 zombie); the oversize is intentional for visual quality
- `onLoad()` loads sprites with **silent try-catch** — canvas fallback activates automatically if load fails
- Damage flash: `saveLayer` + red rect with `BlendMode.srcATop` over the sprite
- Zombie death: sprite frames (`death_0–6`) play linearly over `kDyingDuration=0.55s`; alpha fade + physics launch still apply on top
- Walk animation: player animates while `jx > 0.12 && _onGround && !_crouching` (6 frames @ 0.10s each); zombie animates while `_onGround` (8 frames @ 0.12s)
- **If sprites still show as canvas**: run `flutter clean && pod install` then full rebuild. The last build hit "expected app not found / SdkRoot" error and may not have deployed.

### Controls
- **Left joystick**: move (horizontal) + crouch (push down while grounded)
- **Right joystick** (aim, cyan): steer bullets; when released, shoots horizontally in facing direction
- **▲ button**: jump
- **Auto-fire**: continuous at `kFireRate = 0.17s`

### Gameplay Rules (confirmed)
- **No backwards movement**: camera locks left boundary
- **Enemies drop health orbs** on death (not yet implemented — add `SsHealthOrb`)
- **Boss at end of each level** (not yet implemented)
- **Minimum 2 minutes per level**
- **10 levels** with cutscenes between them (user handles art/VO)

### What's Done ✅
1. **Game feel**: screen shake on damage/kill, hit-stop (3-frame freeze), knockback + exponential decay, death animation, muzzle flash, coyote time (80ms), jump buffer (100ms)
2. **Core platformer**: gravity (900), AABB collision, wall-clamp, fall-death
3. **Level 0 layout**: ground + 18 platforms across 5000px, 20 patrol zombies
4. **2-layer parallax background**: dark city ruins
5. **PixelLab sprites**: soldier (idle + 6-frame walk) + zombie (idle + 8-frame walk + 7-frame death)

### Sidescroller Roadmap — Priority Order

#### Priority 1 — Verify Sprites Deployed ⚠️ NEXT
See "If sprites still show as canvas" note above.

#### Priority 2 — Audio ⚠️
`flame_audio` already wired up. Need SFX files (user provides) + call sites:
- Gunshot on `_fire()` in `ss_player.dart`
- Zombie growl on spawn, death sound in `_die()`
- Footsteps tied to `_isMoving && _onGround`
- Hit sound on `takeDamage()`
- Background ambient loop

#### Priority 3 — Gameplay Depth ⚠️
1. **Level exit door** at x=4800 that unlocks when all zombies cleared
2. **Scrolling enemy spawns** from right edge as player advances
3. **Enemy variety**: Heavy (HP=120, speed=30) + Runner (HP=20, speed=200, charges)
4. **Health orbs** (`SsHealthOrb`) — random drop on zombie death (+20 HP)
5. **Weapon pickups** on platforms mid-level

#### Priority 4 — Visuals ⚠️
- Blood splat particles on zombie death
- Bullet impact sparks on platform hit
- Platform tiles — cracked concrete detail
- Expand parallax from 2 to 4 layers
- Cover objects (cars, dumpsters)

#### Priority 5 — Level Design ⚠️
- Zone 1 (0–800): flat ground, intro enemies
- Zone 2 (800–1800): platforms rise, first chokepoint, Heavy zombie
- Zone 3 (1800–2800): breather + weapon pickup
- Zone 4 (2800–4200): dense, height variation, Runner zombies
- Zone 5 (4200–5000): boss arena

### Key Technical Gotchas — Side-Scroller

1. **Hit-stop passes `dt=0`**: `SidescrollerGame.update()` calls `super.update(0)` during hit-stop. Hit-stop timer decrements with real dt BEFORE the call.

2. **Camera + shake always runs**: computed AFTER `super.update()`, regardless of hit-stop.

3. **Zombie anchor is `bottomCenter`**: local coords `(0,0)` = top-left of bounding box. HP bar at `y=-7` (above bounding box).

4. **`saveLayer` for death fade**: `Paint()..color = Color.fromARGB(alpha, 255, 255, 255)` applies global opacity. Sprite frames are drawn inside this layer.

5. **Sprite flip**: `canvas.translate(size.x, 0); canvas.scale(-1, 1)` — everything drawn after (sprite + muzzle flash) auto-mirrors. East-facing sprites look correct when flipped.

6. **Aim joystick fallback**: magnitude < 0.15 → shoot horizontally in `_facingRight` direction.

7. **Muzzle flash inside flip**: drawn at `bx=34, by=-4` in sprite mode (hardcoded, may need tuning after visual check).

8. **`JoystickComponent` margins**: moveJoystick `left:36, bottom:44`; aimJoystick `right:120, bottom:44`; jump button `right:28, bottom:36`.

---

## Top-Down Arena — Status
*(On hold while side-scroller is active)*

### What's Complete ✅
- 10-phase boss cycle, music crossfade, AdMob ads live
- Full SCRAPS economy + shop (6 survivor skins, 4 armour, 4 Blitz themes)
- Level-up card picker (14 cards), Blitz bar + 11 modes
- Phase 0 GTA1-style canvas background (building/sidewalk/street)
- PixelLab survivor sprite (8 dir idle + 32 walk frames)
- City grid + BFS flow field pathfinding
- Barricade system (Blitz = laser mode, places 64×18 wooden barrier)
- Shields REMOVED (didn't fit theme)

### What's Remaining ⚠️
- **Priority 1**: Canvas backgrounds for phases 1–9 (see phase descriptions in full notes below)
- **Priority 2**: All 10 boss `render()` methods need zombie redesigns (attack patterns are correct, only render needs replacing)
- **Priority 3**: Regular enemy top-down redesigns (grunt/tank/speeder/caster)
- **Priority 4**: App Store — register NecroBlitz in AdMob, new icon/splash, `flutter build ipa --release`

### Phase Background Descriptions (canvas, top-down view)
| Phase | Name | Details |
|---|---|---|
| 1 | Industrial Wasteland | Dark metal grating, rust stains, pipe shadows |
| 2 | Toxic Sewers | Wet concrete, drain channels, toxic green puddles |
| 3 | Blood Streets | Dark asphalt, blood pool splats, tyre marks |
| 4 | Radioactive Zone | Cracked irradiated earth, caution stripe bands |
| 5 | Frozen Wastes | Snow-covered ground, glossy ice patches |
| 6 | Burning City | Scorched black asphalt, ember-lit ground |
| 7 | Underground Bunker | Concrete tile floor, painted floor arrows |
| 8 | Dead Forest | Dark soil, dead leaves, tree stump circles |
| 9 | Horde Mind | Pulsing organic flesh-floor, neural vein network |

### Boss Render Designs (top-down, render() only — keep fireSpecialAttack unchanged)
| Boss | Design |
|---|---|
| Abomination (ph0) | Large oval body, 6 claw-arms radially, glowing wound on back |
| Plague Lord (ph1) | Huge round body dripping bile, pustule bumps, fly swarm halo |
| Gore Beast (ph2) | Segmented centipede body, mandible claws at front |
| Titan Zombie (ph3) | Large humanoid top-down, scrap armour plates |
| Feral Alpha (ph4) | Lean X-shaped body, claws in 4 directions |
| Necrohulk (ph5) | Huge circular body, glowing green cracks |
| Wraith (ph6) | Wispy smoke cloud, skull face inside |
| Rot Giant (ph7) | Large humanoid, exposed rib cage from above |
| Infection King (ph8) | Spider-like, tentacle limbs radiating out |
| Horde Mind (ph9) | Cluster of fused zombie shapes, one pulsing mass |

---

## Top-Down Arena — Key Technical Gotchas

1. **Camera origin**: `camera.viewfinder.anchor = Anchor.topLeft` — world == screen coords. Do NOT change.
2. **Player size is 48px**: Sprites display at 72px (overflows — fine). Hitbox is `CircleHitbox`.
3. **PixelLab image path**: `game.images.load('survivor/south.png')` → `assets/images/survivor/south.png`. New folders need pubspec entry.
4. **StarBackground class name kept**: Referenced widely — do not rename even though it renders ground.
5. **ATT before AdMob**: `main.dart _initialize()` requests ATT before `AdManager.instance.init()`. Required for iOS.
6. **`NovaMode` enum values kept unchanged**: `laser` mode places a barricade. Changing enum breaks SharedPreferences.
7. **Skin item IDs unchanged**: SharedPreferences compatibility. `shield_default` still exists — harmless.
8. **Boss death hook**: `Monster._die()` → `onDie()` → `BossMonster.onDie()` → `game.onBossKilled()`. Don't touch.
9. **City grid tile math**: Columns repeat every 16, rows every 32. Use `((x % n) + n) % n` — plain `%` returns negative for off-screen enemies.
10. **Barricade collision**: proximity-based (`distance < monster.size.x/2 + 28`), no Flame collision system.
11. **flame_audio path**: `FlameAudio.updatePrefix('assets/')` — audio files in `assets/` root.

---

## PixelLab MCP Reference
- **Tool**: `mcp__pixellab__create_character` (pro mode = 20 credits, ~3-5 min)
- **Side-scroller view**: `"side"`, pro mode, 48px size → 92×92px canvas output
- **Top-down view**: `"high top-down"`, pro mode
- **Tile type**: `create_tiles_pro`, `square_topdown`, `tile_size: 32`
- **Check status**: `get_character` with the returned ID
- **Animations**: `animate_character` with `template_animation_id`. 8 jobs run concurrently max — queue one character at a time to avoid slot exhaustion.
- **Download**: `curl --fail` from the ZIP URL in `get_character` result
- **Extract pattern**: ZIPs contain `states/{Name}/rotations/{dir}.png` and `states/{Name}/animations/{anim-hash}/{dir}/frame_00N.png`
- **Side-scroller only needs east direction** — canvas flip handles left-facing

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
