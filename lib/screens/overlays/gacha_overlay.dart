import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/chef_controller.dart';
import '../../controllers/economy_controller.dart';
import '../../game/paleto_game.dart';
import '../../services/audio_service.dart';
import '../../ui/theme/paleto_colors.dart';
import '../../ui/theme/paleto_text.dart';
import '../../widgets/retro/rarity_border.dart';
import '../../widgets/retro/resource_chip.dart';
import '../../widgets/retro/retro_button.dart';
import '../../widgets/retro/retro_menu_box.dart';

enum GachaState { idle, animating, showResult }

class GachaOverlay extends StatefulWidget {
  final PaletoGame game;

  const GachaOverlay({super.key, required this.game});

  @override
  State<GachaOverlay> createState() => _GachaOverlayState();
}

class _GachaOverlayState extends State<GachaOverlay>
    with SingleTickerProviderStateMixin {
  GachaState _state = GachaState.idle;
  List<_GachaResultView> _results = const [];
  bool _entered = false;
  bool _isClosing = false;

  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _entered = true;
      });
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  Future<void> _performPull({required int pulls, required int cost}) async {
    if (_state == GachaState.animating) {
      return;
    }

    final economy = context.read<EconomyController>();
    final chefController = context.read<ChefController>();

    if (economy.gems < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemas insuficientes para invocar.')),
      );
      return;
    }

    setState(() {
      _state = GachaState.animating;
    });

    AudioService.instance.playClickGacha();
    economy.spendGems(cost);

    final rollResults = chefController.rollGacha(true, pulls, 'Raro', economy);
    final generated = rollResults
        .map(
          (result) => _GachaResultView(
            name: result.entity.name,
            rarity: _mapRarity(result.entity.rarity),
            icon: result.entity.icon,
            imagePath: result.entity.imagePath,
            isNew: result.isNew,
            tokens: result.tokensGranted,
          ),
        )
        .toList();

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    setState(() {
      _results = generated;
      _state = GachaState.showResult;
    });
  }

  Future<void> _closeOverlay() async {
    if (_isClosing) {
      return;
    }

    setState(() {
      _isClosing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    widget.game.overlays.remove('GachaScreen');
  }

  PaletoRarity _mapRarity(GachaRarity rarity) {
    switch (rarity) {
      case GachaRarity.Common:
        return PaletoRarity.common;
      case GachaRarity.Rare:
        return PaletoRarity.rare;
      case GachaRarity.Epic:
        return PaletoRarity.epic;
      case GachaRarity.Legendary:
        return PaletoRarity.legendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gems = context.watch<EconomyController>().gems;
    final canPullSingle = _state != GachaState.animating && gems >= 120;
    final canPullTen = _state != GachaState.animating && gems >= 1000;

    return AnimatedOpacity(
      opacity: _entered && !_isClosing ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _entered && !_isClosing ? Offset.zero : const Offset(0, 0.03),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
              RetroMenuBox(
                title: 'RECLUTAR CHEFS',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Invoca chefs y cuchillos de elite',
                        style: PaletoText.body(size: 11),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ResourceChip(
                      assetPath: 'lib/assets/images/icon.png',
                      value: gems,
                    ),
                    const SizedBox(width: 8),
                    RetroButton(
                      label: 'Cerrar',
                      onPressed: _closeOverlay,
                      baseColor: PaletoColors.btnNeutral,
                      lightBorder: PaletoColors.btnNeutralLt,
                      darkBorder: PaletoColors.btnNeutralDk,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RetroMenuBox(
                  title: _state == GachaState.showResult ? 'RESULTADOS' : null,
                  padding: const EdgeInsets.all(16),
                  hasScanlines: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCenterArea(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      label: 'x1 Pull',
                      onPressed: () => _performPull(pulls: 1, cost: 120),
                      baseColor: PaletoColors.btnPrimary,
                      lightBorder: PaletoColors.btnPrimaryLt,
                      darkBorder: PaletoColors.btnPrimaryDk,
                      icon: const Icon(Icons.casino, color: Colors.white, size: 16),
                      enabled: canPullSingle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RetroButton(
                      label: 'x10 Pull',
                      onPressed: () => _performPull(pulls: 10, cost: 1000),
                      baseColor: PaletoColors.btnGacha,
                      lightBorder: PaletoColors.btnGachaLt,
                      darkBorder: PaletoColors.btnGachaDk,
                      icon: const Icon(Icons.auto_awesome, color: Colors.black, size: 16),
                      enabled: canPullTen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Costo x1: 120',
                      textAlign: TextAlign.center,
                      style: PaletoText.body(
                        size: 9,
                        color: canPullSingle ? PaletoColors.textSecondary : PaletoColors.elemFire,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Costo x10: 1000',
                      textAlign: TextAlign.center,
                      style: PaletoText.body(
                        size: 9,
                        color: canPullTen ? PaletoColors.textSecondary : PaletoColors.elemFire,
                      ),
                    ),
                  ),
                ],
              ),
              if (_state == GachaState.showResult) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    label: 'Volver a tirar',
                    onPressed: () {
                      setState(() {
                        _state = GachaState.idle;
                      });
                    },
                    baseColor: PaletoColors.btnSecondary,
                    lightBorder: PaletoColors.btnSecondaryLt,
                    darkBorder: PaletoColors.btnSecondaryDk,
                    icon: const Icon(Icons.replay, color: Colors.white, size: 16),
                  ),
                ),
              ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterArea() {
    switch (_state) {
      case GachaState.idle:
        return Column(
          key: const ValueKey<String>('idle'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.black,
              alignment: Alignment.center,
              child: Text('CHEF', style: PaletoText.header(size: 14)),
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: Tween<double>(begin: 0.4, end: 1).animate(_blinkController),
              child: Text(
                'Toca para invocar',
                style: PaletoText.body(size: 12, color: PaletoColors.textPrimary),
              ),
            ),
          ],
        );
      case GachaState.animating:
        return Container(
          key: const ValueKey<String>('animating'),
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 3, color: PaletoColors.textAccent),
              ),
              const SizedBox(height: 12),
              Text('INVOCANDO...', style: PaletoText.header(size: 11)),
            ],
          ),
        );
      case GachaState.showResult:
        return GridView.builder(
          key: const ValueKey<String>('result'),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            return _CardResultWidget(result: _results[index]);
          },
        );
    }
  }
}

class _CardResultWidget extends StatelessWidget {
  final _GachaResultView result;

  const _CardResultWidget({required this.result});

  @override
  Widget build(BuildContext context) {
    final rarityColor = switch (result.rarity) {
      PaletoRarity.common => PaletoColors.rarityCommon,
      PaletoRarity.rare => PaletoColors.rarityRare,
      PaletoRarity.epic => PaletoColors.rarityEpic,
      PaletoRarity.legendary => PaletoColors.rarityLegendary,
    };

    final stars = switch (result.rarity) {
      PaletoRarity.common => '★',
      PaletoRarity.rare => '★★',
      PaletoRarity.epic => '★★★',
      PaletoRarity.legendary => '★★★★',
    };

    return RarityBorder(
      rarity: result.rarity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: rarityColor.withValues(alpha: 0.20)),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AudioService.instance.playClickGacha();
            },
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.black,
                  child: result.imagePath == null
                      ? Icon(result.icon, color: Colors.white, size: 42)
                      : Image.asset(
                          'lib/assets/images/${result.imagePath!}',
                          filterQuality: FilterQuality.none,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(result.icon, color: Colors.white, size: 42),
                        ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    result.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PaletoText.header(size: 8),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    children: [
                      Text(
                        stars,
                        style: PaletoText.header(size: 9, color: rarityColor),
                      ),
                      Text(
                        result.isNew ? 'NUEVO' : '+${result.tokens} TOKENS',
                        style: PaletoText.body(
                          size: 8,
                          color: result.isNew ? PaletoColors.textPrimary : PaletoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GachaResultView {
  final String name;
  final PaletoRarity rarity;
  final IconData icon;
  final String? imagePath;
  final bool isNew;
  final int tokens;

  const _GachaResultView({
    required this.name,
    required this.rarity,
    required this.icon,
    required this.imagePath,
    required this.isNew,
    required this.tokens,
  });
}
