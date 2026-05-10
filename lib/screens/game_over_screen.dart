import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../coins/coin_manager.dart';
import '../game/necroblitz_game.dart';
import '../stats/stats_manager.dart';

class GameOverScreen extends StatefulWidget {
  final NecroblitzGame game;
  final VoidCallback? onMenu;
  const GameOverScreen({super.key, required this.game, this.onMenu});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _coinsAwarded = false;

  @override
  void initState() {
    super.initState();
    AdManager.instance.rewardedAdReady.addListener(_onAdReadyChanged);
  }

  @override
  void dispose() {
    AdManager.instance.rewardedAdReady.removeListener(_onAdReadyChanged);
    super.dispose();
  }

  void _onAdReadyChanged() => setState(() {});

  int get _coinsEarned => widget.game.xpSystem.currentLevel * 10;

  void _awardCoins() {
    if (_coinsAwarded) return;
    _coinsAwarded = true;
    CoinManager.instance.addCoins(_coinsEarned);
  }

  void _watchAdAndContinue() {
    AdManager.instance.showRewardedAd(
      onRewarded: () => widget.game.continueWithHalfHp(),
    );
  }

  void _playAgain() {
    _awardCoins();
    widget.game.restart();
  }

  void _goToMenu() {
    _awardCoins();
    widget.onMenu?.call();
  }

  @override
  Widget build(BuildContext context) {
    final adReady = AdManager.instance.rewardedAdReady.value;
    final canContinue = adReady && !widget.game.hasUsedContinue;

    return Material(
      color: const Color(0xCC000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Color(0xFFCC2936),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            if (widget.game.isNewBest) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW BEST!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Run stats
            Text(
              'Level ${widget.game.xpSystem.currentLevel}  ·  ${widget.game.killCount} kills',
              style: const TextStyle(
                color: Color(0xFFF5F5DC),
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            // All-time records
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 5),
                Text(
                  'Best: Lv ${StatsManager.instance.bestLevel}  ·  ${StatsManager.instance.bestKills} kills',
                  style: const TextStyle(
                    color: Color(0xAAF5F5DC),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔩', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 5),
                Text(
                  '+$_coinsEarned SCRAPS',
                  style: const TextStyle(
                    color: Color(0xFF66FF00),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (canContinue) ...[
              ElevatedButton.icon(
                onPressed: _watchAdAndContinue,
                icon: const Icon(Icons.play_circle_outline, size: 22),
                label: const Text('Watch Ad — Continue (50% HP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _playAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 18),
                textStyle: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text('PLAY AGAIN'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _goToMenu,
              child: const Text(
                'Main Menu',
                style: TextStyle(
                  color: Color(0xAAF5F5DC),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
