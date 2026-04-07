import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/paleto_game.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/upgrade_shop_overlay.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/wave_clear_overlay.dart';
import '../widgets/pause_menu_overlay.dart';
import '../controllers/economy_controller.dart';
import '../controllers/world_controller.dart';
import '../controllers/chef_controller.dart';
import '../services/audio_service.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final PaletoGame _game;

  @override
  void initState() {
    super.initState();
    // Reproducir música de gameplay al entrar (según la ubicación)
    try {
      final locationData = context.read<WorldController>().selectedLocation;
      final locationName = locationData.name.toLowerCase();
      
      if (locationName == 'america') {
        AudioService.instance.playAmericaMusic();
      } else if (locationName == 'asia') {
        AudioService.instance.playAsiaMusic();
      } else if (locationName == 'europa') {
        AudioService.instance.playEuropaMusic();
      } else {
        AudioService.instance.playGameplayMusic();
      }
    } catch (_) {}
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EconomyController>().setMaxHp(
        context.read<ChefController>().activeChef.currentHp,
      );
    });

    _game = PaletoGame(
      locationData: context.read<WorldController>().selectedLocation,
      playerIcon: context.read<ChefController>().activeChef.icon,
      onPlayerTakeDamage: (double amount) {
        if (mounted) {
          context.read<EconomyController>().takeDamage(amount);
          if (context.read<EconomyController>().playerHp <= 0) {
            _game.pauseEngine();
            _game.overlays.add('GameOver');
          }
        }
      },
      getPlayerFireRate: () {
        if (mounted) {
          return context.read<ChefController>().activeChef.currentFireRate;
        }
        return 0.3;
      },
      onEnemyKilled: (wave, isBoss) {
        if (mounted) {
          final eco = context.read<EconomyController>();
          eco.addRewardsFromEnemy(wave, isBoss: isBoss);
          if (isBoss) {
            context.read<ChefController>().processBossKillReward(eco, context);
          }
          try {
            // Reproducir sonido de moneda al ganar recompensa
            AudioService.instance.playCoinCollect();
          } catch (_) {}
        }
      },
      getPlayerDamage: () {
        if (mounted) {
          return context.read<ChefController>().getTotalDamage(
            context.read<WorldController>().selectedLocation.name,
          );
        }
        return 10.0;
      },
    );
  }

  @override
  void dispose() {
    // Volver a música de menú cuando sales de gameplay
    try {
      AudioService.instance.playMenuMusic();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold negro puro detras del juego
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<PaletoGame>(
        game: _game,
        // Conectar las capas de UI de Flutter por encima del Canvas
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(game: game),
          'UpgradeShop': (context, game) => UpgradeShopOverlay(game: game),
          'WaveClear': (context, game) => WaveClearOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
          'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
        },
        initialActiveOverlays: const [
          'HUD',
        ], // El HUD siempre activo al empezar
      ),
    );
  }
}
