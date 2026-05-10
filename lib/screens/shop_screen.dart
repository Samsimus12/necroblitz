import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../audio/audio_manager.dart';
import '../coins/coin_manager.dart';

// ── Item definitions ──────────────────────────────────────────────────────────

class _SkinItem {
  final String id;
  final String name;
  final int price;
  final Color primary;
  final Color pants;
  final Color highlight;
  const _SkinItem({
    required this.id,
    required this.name,
    required this.price,
    required this.primary,
    required this.pants,
    required this.highlight,
  });
}

class _ShieldItem {
  final String id;
  final String name;
  final int price;
  final Color color;
  const _ShieldItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
  });
}

class _NovaItem {
  final String id;
  final String name;
  final int price;
  final Color color;
  const _NovaItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
  });
}

const _skins = [
  _SkinItem(
    id: 'default',
    name: 'Standard Gear',
    price: 0,
    primary: Color(0xFF4CAF50),
    pants: Color(0xFF2E7D32),
    highlight: Color(0xFFA5D6A7),
  ),
  _SkinItem(
    id: 'ice',
    name: 'Arctic Vest',
    price: 300,
    primary: Color(0xFF4DD0E1),
    pants: Color(0xFF0097A7),
    highlight: Color(0xFFE0F7FA),
  ),
  _SkinItem(
    id: 'flame',
    name: 'Hazmat Suit',
    price: 500,
    primary: Color(0xFFFF5722),
    pants: Color(0xFFBF360C),
    highlight: Color(0xFFFFAB91),
  ),
  _SkinItem(
    id: 'shadow',
    name: 'Tactical Camo',
    price: 700,
    primary: Color(0xFF424242),
    pants: Color(0xFF212121),
    highlight: Color(0xFF757575),
  ),
  _SkinItem(
    id: 'solar',
    name: 'Riot Gear',
    price: 900,
    primary: Color(0xFFFFD600),
    pants: Color(0xFFF57F17),
    highlight: Color(0xFFFFFFFF),
  ),
  _SkinItem(
    id: 'void',
    name: 'Specter Suit',
    price: 1200,
    primary: Color(0xFF6A1B9A),
    pants: Color(0xFF4A148C),
    highlight: Color(0xFFCE93D8),
  ),
];

const _shields = [
  _ShieldItem(
    id: 'shield_default',
    name: 'Riot Shield',
    price: 0,
    color: Color(0xFF44FF88),
  ),
  _ShieldItem(
    id: 'shield_plasma',
    name: 'Kevlar',
    price: 250,
    color: Color(0xFFFF6B35),
  ),
  _ShieldItem(
    id: 'shield_void',
    name: 'Undead Ward',
    price: 500,
    color: Color(0xFFCC00FF),
  ),
  _ShieldItem(
    id: 'shield_gold',
    name: 'Heavy Plate',
    price: 750,
    color: Color(0xFFFFD700),
  ),
];

const _novaThemes = [
  _NovaItem(
    id: 'nova_default',
    name: 'Pulse Burst',
    price: 0,
    color: Color(0xFF44FF88),
  ),
  _NovaItem(
    id: 'nova_inferno',
    name: 'Hellfire',
    price: 350,
    color: Color(0xFFFF3D00),
  ),
  _NovaItem(
    id: 'nova_void',
    name: 'Toxic Wave',
    price: 650,
    color: Color(0xFF66FF00),
  ),
  _NovaItem(
    id: 'nova_eclipse',
    name: 'Gold Rush',
    price: 950,
    color: Color(0xFFFFD700),
  ),
];

const _adCoinsReward = 75;
const _cardWidth = 120.0;
const _cardListHeight = 195.0;

// ── Shop screen ───────────────────────────────────────────────────────────────

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _mgr = CoinManager.instance;
  final _ads = AdManager.instance;

  Future<void> _buySkin(String id, int price) async {
    final ok = await _mgr.purchase('skin_$id', price);
    if (ok) {
      await _mgr.selectSkin(id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _equipSkin(String id) async {
    await _mgr.selectSkin(id);
    if (mounted) setState(() {});
  }

  Future<void> _buyShield(String id, int price) async {
    final ok = await _mgr.purchase(id, price);
    if (ok) {
      await _mgr.selectShieldSkin(id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _equipShield(String id) async {
    await _mgr.selectShieldSkin(id);
    if (mounted) setState(() {});
  }

  Future<void> _buyNova(String id, int price) async {
    final ok = await _mgr.purchase(id, price);
    if (ok) {
      await _mgr.selectNovaTheme(id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _equipNova(String id) async {
    await _mgr.selectNovaTheme(id);
    if (mounted) setState(() {});
  }

  void _watchAdForCoins() {
    _ads.showRewardedAd(
      onRewarded: () async {
        await _mgr.addCoins(_adCoinsReward);
        if (mounted) setState(() {});
      },
      onDismissed: () => AudioManager.instance.playMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F05), Color(0xFF050800)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEarnScrapsSection(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _sectionHeader('SURVIVOR SKINS'),
                      ),
                      const SizedBox(height: 10),
                      _buildHorizontalList(
                        itemCount: _skins.length,
                        builder: (i) {
                          final s = _skins[i];
                          return _SkinCard(
                            item: s,
                            owned: _mgr.owns('skin_${s.id}'),
                            equipped: _mgr.selectedSkin == s.id,
                            canAfford: _mgr.totalCoins >= s.price,
                            onBuy: () => _buySkin(s.id, s.price),
                            onEquip: () => _equipSkin(s.id),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _sectionHeader('ARMOUR SKINS'),
                      ),
                      const SizedBox(height: 10),
                      _buildHorizontalList(
                        itemCount: _shields.length,
                        builder: (i) {
                          final sh = _shields[i];
                          return _ShieldCard(
                            item: sh,
                            owned: _mgr.owns(sh.id),
                            equipped: _mgr.selectedShieldSkin == sh.id,
                            canAfford: _mgr.totalCoins >= sh.price,
                            onBuy: () => _buyShield(sh.id, sh.price),
                            onEquip: () => _equipShield(sh.id),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _sectionHeader('BLITZ BURST'),
                      ),
                      const SizedBox(height: 10),
                      _buildHorizontalList(
                        itemCount: _novaThemes.length,
                        builder: (i) {
                          final n = _novaThemes[i];
                          return _NovaCard(
                            item: n,
                            owned: _mgr.owns(n.id),
                            equipped: _mgr.selectedNovaTheme == n.id,
                            canAfford: _mgr.totalCoins >= n.price,
                            onBuy: () => _buyNova(n.id, n.price),
                            onEquip: () => _equipNova(n.id),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList({
    required int itemCount,
    required Widget Function(int) builder,
  }) {
    return SizedBox(
      height: _cardListHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => SizedBox(width: _cardWidth, child: builder(i)),
      ),
    );
  }

  Widget _buildEarnScrapsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('EARN SCRAPS'),
          const SizedBox(height: 10),
          ValueListenableBuilder<bool>(
            valueListenable: _ads.rewardedAdReady,
            builder: (_, ready, __) => _AdBanner(
              ready: ready,
              onWatch: _watchAdForCoins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xAAF5F5DC)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'SHOP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF66FF00),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x2266FF00),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x5566FF00)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔩', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${_mgr.totalCoins}',
                  style: const TextStyle(
                    color: Color(0xFF66FF00),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withAlpha(30))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0x99F5F5DC),
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withAlpha(30))),
      ],
    );
  }
}

// ── Ad banner ─────────────────────────────────────────────────────────────────

class _AdBanner extends StatelessWidget {
  final bool ready;
  final VoidCallback onWatch;
  const _AdBanner({required this.ready, required this.onWatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ready ? const Color(0x8866FF00) : const Color(0x33FFFFFF),
        ),
      ),
      child: Row(
        children: [
          const Text('📺', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Watch an ad',
                  style: TextStyle(
                    color: Color(0xEEF5F5DC),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Earn $_adCoinsReward 🔩 SCRAPS instantly',
                  style: const TextStyle(color: Color(0x99F5F5DC), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: ready ? onWatch : null,
            style: TextButton.styleFrom(
              backgroundColor:
                  ready ? const Color(0x3366FF00) : const Color(0x11FFFFFF),
              foregroundColor:
                  ready ? const Color(0xFF66FF00) : const Color(0x55FFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: ready
                      ? const Color(0x8866FF00)
                      : const Color(0x22FFFFFF),
                ),
              ),
            ),
            child: Text(
              ready ? 'WATCH' : 'LOADING',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skin card ─────────────────────────────────────────────────────────────────

class _SkinCard extends StatelessWidget {
  final _SkinItem item;
  final bool owned, equipped, canAfford;
  final VoidCallback onBuy, onEquip;

  const _SkinCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      preview: SizedBox(
        width: 56,
        height: 64,
        child: CustomPaint(
          painter: _SurvivorPainter(
            jacket: item.primary,
            pants: item.pants,
            highlight: item.highlight,
          ),
        ),
      ),
      name: item.name,
      price: item.price,
      owned: owned,
      equipped: equipped,
      canAfford: canAfford,
      accentColor: item.primary,
      onBuy: onBuy,
      onEquip: onEquip,
    );
  }
}

// ── Shield card ───────────────────────────────────────────────────────────────

class _ShieldCard extends StatelessWidget {
  final _ShieldItem item;
  final bool owned, equipped, canAfford;
  final VoidCallback onBuy, onEquip;

  const _ShieldCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      preview: SizedBox(
        width: 56,
        height: 64,
        child: CustomPaint(
          painter: _ShieldPainter(color: item.color),
        ),
      ),
      name: item.name,
      price: item.price,
      owned: owned,
      equipped: equipped,
      canAfford: canAfford,
      accentColor: item.color,
      onBuy: onBuy,
      onEquip: onEquip,
    );
  }
}

// ── Nova card ─────────────────────────────────────────────────────────────────

class _NovaCard extends StatelessWidget {
  final _NovaItem item;
  final bool owned, equipped, canAfford;
  final VoidCallback onBuy, onEquip;

  const _NovaCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      preview: SizedBox(
        width: 56,
        height: 64,
        child: CustomPaint(
          painter: _BlitzPainter(color: item.color),
        ),
      ),
      name: item.name,
      price: item.price,
      owned: owned,
      equipped: equipped,
      canAfford: canAfford,
      accentColor: item.color,
      onBuy: onBuy,
      onEquip: onEquip,
    );
  }
}

// ── Shared item card ──────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final Widget preview;
  final String name;
  final int price;
  final bool owned, equipped, canAfford;
  final Color accentColor;
  final VoidCallback onBuy, onEquip;

  const _ItemCard({
    required this.preview,
    required this.name,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.accentColor,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: equipped ? accentColor.withAlpha(25) : const Color(0xFF0A1A08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: equipped
              ? accentColor.withAlpha(140)
              : const Color(0x3344AA00),
          width: equipped ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          preview,
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xEEF5F5DC),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (equipped) return _badge('EQUIPPED', const Color(0xFF44FF88));
    if (owned) return _actionButton('EQUIP', const Color(0xFF44AA00), onEquip);
    if (price == 0) return _actionButton('GET', const Color(0xFF27AE60), onBuy);
    return _actionButton(
      '🔩 $price',
      canAfford ? const Color(0xFF27AE60) : const Color(0xFF555555),
      canAfford ? onBuy : () {},
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color.withAlpha(40),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: color.withAlpha(100)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _SurvivorPainter extends CustomPainter {
  final Color jacket, pants, highlight;
  const _SurvivorPainter({required this.jacket, required this.pants, required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.48,
      Paint()
        ..color = jacket.withAlpha(35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Legs
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy + 10), width: 7, height: 12), Paint()..color = pants);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 5, cy + 10), width: 7, height: 12), Paint()..color = pants);

    // Torso
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 8)
        ..lineTo(cx + 8, cy - 2)
        ..lineTo(cx + 7, cy + 6)
        ..lineTo(cx, cy + 4)
        ..lineTo(cx - 7, cy + 6)
        ..lineTo(cx - 8, cy - 2)
        ..close(),
      Paint()..color = jacket,
    );

    // Arms
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 11, cy - 2), width: 6, height: 12), Paint()..color = jacket);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 11, cy + 1), width: 6, height: 9), Paint()..color = jacket);

    // Head
    canvas.drawCircle(Offset(cx, cy - 12), 7, Paint()..color = const Color(0xFFBCAAA4));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 7, height: 5),
      Paint()..color = highlight.withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(_SurvivorPainter old) =>
      old.jacket != jacket || old.pants != pants || old.highlight != highlight;
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  const _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Survivor silhouette (dark)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 22),
        Paint()..color = const Color(0x88AAAACC));

    // Shield glow
    canvas.drawCircle(
      Offset(cx, cy),
      22,
      Paint()
        ..color = color.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Shield ring
    canvas.drawCircle(
      Offset(cx, cy),
      22,
      Paint()
        ..color = color.withAlpha(200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.color != color;
}

class _BlitzPainter extends CustomPainter {
  final Color color;
  const _BlitzPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF050A02),
    );

    final beamRect = Rect.fromLTWH(cx - 14, 0, 28, size.height);
    canvas.drawRect(
      beamRect,
      Paint()
        ..color = color.withAlpha(30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawRect(
      Rect.fromLTWH(cx - 9, 0, 18, size.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, size.height),
          Offset(cx, 0),
          [color.withAlpha(160), color.withAlpha(0)],
        ),
    );

    canvas.drawLine(
      Offset(cx, size.height),
      Offset(cx, 0),
      Paint()
        ..color = const Color(0xCCFFFFFF)
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      Offset(cx, size.height - 6),
      8,
      Paint()
        ..color = color.withAlpha(180)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_BlitzPainter old) => old.color != color;
}
