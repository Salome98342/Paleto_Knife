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
      color: Colors.black54, // Fondo oscurecido
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration.copyWith(
            color: AppTheme.surface.withValues(alpha: 0.95), // Casi solido
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MEJORAS',
                    style: AppTheme.titleStyle.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMain),
                    onPressed: () {
                      try {
                        // Volver a música de juego cuando se cierra
                        import_audio.AudioService.instance.playLastGameplayMusic();
                      } catch (_) {}
                      game.resumeEngine();
                      game.resumeEngine();
                      game.overlays.remove('UpgradeShop');
                    },
                  ),
                ],
              ),
              const Divider(color: AppTheme.magic),
              const SizedBox(height: 16),

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
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
                    color: canAfford ? AppTheme.magic : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
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
                    color: canAfford ? AppTheme.magic : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
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
