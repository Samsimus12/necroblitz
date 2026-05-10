import 'package:flutter/material.dart';

import '../game/data/upgrade_cards.dart';
import '../game/necroblitz_game.dart';

class LevelUpScreen extends StatelessWidget {
  final NecroblitzGame game;
  const LevelUpScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final cards = game.currentCards;

    return Material(
      color: const Color(0xBB000A00),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              game.isBossReward ? 'BOSS REWARD!' : 'LEVEL UP!',
              style: TextStyle(
                color: game.isBossReward ? const Color(0xFFFF4444) : const Color(0xFFFFD700),
                fontSize: 44,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                      color: game.isBossReward ? const Color(0xAAFF0000) : const Color(0xAAF4A800),
                      blurRadius: 20,
                      offset: Offset(0, 0))
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Level ${game.xpSystem.currentLevel}',
              style: const TextStyle(color: Color(0xCCF5F5DC), fontSize: 20),
            ),
            if (game.picksTotal > 1) ...[
              const SizedBox(height: 6),
              Text(
                game.isBossReward
                    ? 'Pick ${game.currentPickIndex} of ${game.picksTotal} — Boss Reward'
                    : 'Pick ${game.currentPickIndex} of ${game.picksTotal} — Lucky Draw!',
                style: TextStyle(
                  color: game.isBossReward ? const Color(0xFFFF6666) : const Color(0xFF00E5FF),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
            if (game.bonusCards.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'BONUS',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              for (final bonus in game.bonusCards) _BonusWidget(card: bonus),
              const SizedBox(height: 16),
              const Divider(color: Color(0x334CAF50), indent: 24, endIndent: 24),
            ],
            if (game.pendingInheritMode != null) ...[
              const SizedBox(height: 16),
              _InheritedNovaWidget(modeName: game.pendingInheritMode!.displayName),
            ],
            const SizedBox(height: 16),
            for (final card in cards) _CardWidget(card: card, game: game),
          ],
        ),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final UpgradeCard card;
  final NecroblitzGame game;

  const _CardWidget({required this.card, required this.game});

  Color get _accent {
    if (card is WeaponUpgradeCard) return const Color(0xFF44AA00);
    if (card is NewWeaponCard) return const Color(0xFFF4A800);
    return const Color(0xFF44FF88);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        card.apply(game);
        game.resumeFromLevelUp();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF08160A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent, width: 2),
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _accent.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  card.iconLabel,
                  style: TextStyle(fontSize: 22, color: _accent),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Color(0xFFF5F5DC),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    card.description,
                    style: const TextStyle(
                      color: Color(0xAAF5F5DC),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _accent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BonusWidget extends StatelessWidget {
  final StatBuffCard card;
  const _BonusWidget({required this.card});

  static const _green = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF081A0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withAlpha(120), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _green.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('♥', style: TextStyle(fontSize: 20, color: _green)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.description,
                  style: const TextStyle(
                    color: Color(0xAA4CAF50),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'AUTO',
            style: TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InheritedNovaWidget extends StatelessWidget {
  final String modeName;
  const _InheritedNovaWidget({required this.modeName});

  static const _green = Color(0xFF44FF88);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF001A0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withAlpha(120), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _green.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 20, color: _green)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blitz Inherited',
                  style: TextStyle(
                    color: _green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  modeName,
                  style: const TextStyle(
                    color: Color(0xAA44FF88),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'AUTO',
            style: TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
