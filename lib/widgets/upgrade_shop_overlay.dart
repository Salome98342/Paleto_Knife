import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/economy_controller.dart';
import '../game_logic/app_theme.dart';
import '../services/audio_service.dart' as import_audio;
import 'bouncy_game_button.dart';
import 'retro_style.dart';

class UpgradeShopOverlay extends StatelessWidget {
  final dynamic game;
  const UpgradeShopOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration.copyWith(
            color: const Color(0xFF0F131E),
            border: Border.all(color: AppTheme.magic, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.magic.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MEJORAS',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 22,
                          color: AppTheme.magic,
                          shadows: [
                            Shadow(
                              color: AppTheme.magic.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ajusta tu build antes de continuar',
                        style: AppTheme.numberStyleSmall.copyWith(
                          color: AppTheme.textDim,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMain),
                    onPressed: () {
                      try {
                        // Volver a música de juego cuando se cierra
                        import_audio.AudioService.instance.playLastGameplayMusic();
                      } catch (_) {}
                      game.resumeEngine();
                      game.overlays.remove('UpgradeShop');
                    },
                  ),
                ],
              ),
              const Divider(color: AppTheme.magic, thickness: 2),
              const SizedBox(height: 10),

              Consumer<EconomyController>(
                builder: (context, economy, child) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.background.withValues(alpha: 0.7),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'MONEDAS: ${economy.coins}',
                          style: AppTheme.numberStyleSmall.copyWith(
                            color: Colors.amber,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Upgrades List
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildDamageUpgrade(context),
                    _buildFireRateUpgrade(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFireRateUpgrade(BuildContext context) {
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        final canAfford = economy.coins >= economy.fireRateUpgradeCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.hudPanelDecoration.copyWith(
            color: canAfford ? AppTheme.surface : Colors.black45,
            border: Border.all(
              color: canAfford ? AppTheme.magic : Colors.grey,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: AppTheme.danger.withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.speed,
                  color: AppTheme.danger,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CADENCIA',
                      style: AppTheme.numberStyleSmall.copyWith(
                        color: AppTheme.textMain,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nivel ${economy.fireRateStat}',
                      style: AppTheme.numberStyleSmall.copyWith(
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: (economy.fireRateStat / 20).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: AppTheme.background.withValues(alpha: 0.8),
                        valueColor: AlwaysStoppedAnimation(AppTheme.magic),
                      ),
                    ),
                  ],
                ),
              ),

              // Boton de Compra
              BouncyGameButton(
                onPressed: () {
                  if (canAfford) {
                    final success = economy.tryUpgradeFireRate();
                    if (success) {
                      import_audio.AudioService.instance.playPowerupSound();
                    }
                  } else {
                    RetroStyle.showInsufficient(
                      context,
                      "MONEDAS INSUFICIENTES",
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: canAfford
                        ? LinearGradient(
                            colors: [AppTheme.magic, AppTheme.magic.withValues(alpha: 0.7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: canAfford ? null : Colors.grey.shade800,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      color: canAfford ? Colors.white.withValues(alpha: 0.45) : Colors.grey.shade700,
                      width: 1.2,
                    ),
                    boxShadow: canAfford ? AppTheme.neonShadowMagic : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${economy.fireRateUpgradeCost}',
                        style: AppTheme.numberStyleSmall.copyWith(
                          color: canAfford
                              ? AppTheme.background
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.monetization_on,
                        color: canAfford
                            ? AppTheme.background
                            : Colors.grey.shade400,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDamageUpgrade(BuildContext context) {
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        final canAfford = economy.coins >= economy.upgradeCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.hudPanelDecoration.copyWith(
            color: canAfford ? AppTheme.surface : Colors.black45,
            border: Border.all(
              color: canAfford ? AppTheme.magic : Colors.grey,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: AppTheme.danger.withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: AppTheme.danger,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DANO',
                      style: AppTheme.numberStyleSmall.copyWith(
                        color: AppTheme.textMain,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nivel ${economy.damageStat}',
                      style: AppTheme.numberStyleSmall.copyWith(
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: (economy.damageStat / 20).clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: AppTheme.background.withValues(alpha: 0.8),
                        valueColor: AlwaysStoppedAnimation(AppTheme.magic),
                      ),
                    ),
                  ],
                ),
              ),

              // Boton de Compra
              BouncyGameButton(
                onPressed: () {
                  if (canAfford) {
                    final success = economy.tryUpgradeDamage();
                    if (success) {
                      import_audio.AudioService.instance.playPowerupSound();
                    }
                  } else {
                    RetroStyle.showInsufficient(
                      context,
                      "MONEDAS INSUFICIENTES",
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: canAfford
                        ? LinearGradient(
                            colors: [AppTheme.magic, AppTheme.magic.withValues(alpha: 0.7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: canAfford ? null : Colors.grey.shade800,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      color: canAfford ? Colors.white.withValues(alpha: 0.45) : Colors.grey.shade700,
                      width: 1.2,
                    ),
                    boxShadow: canAfford ? AppTheme.neonShadowMagic : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${economy.upgradeCost}',
                        style: AppTheme.numberStyleSmall.copyWith(
                          color: canAfford
                              ? AppTheme.background
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.monetization_on,
                        color: canAfford
                            ? AppTheme.background
                            : Colors.grey.shade400,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
