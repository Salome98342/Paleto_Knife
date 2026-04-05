import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/paleto_game.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/upgrade_shop_overlay.dart';
import '../widgets/game_over_overlay.dart';
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
    _game = PaletoGame(
      locationData: context.read<WorldController>().selectedLocation,
      onPlayerTakeDamage: (amount) {
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
      onEnemyKilled: (level) {
        if (mounted) {
          context.read<EconomyController>().addCoinsFromEnemy(level);
          try { AudioService.instance.playCoinCollect(); } catch (_) {}
        }
      },
      getPlayerDamage: () {
        if (mounted) {
          return context.read<ChefController>().activeChef.currentDamage;
        }
        return 10.0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold negro puro detrÃ¡s del juego
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<PaletoGame>(
        game: _game,
        // Conectar las capas de UI de Flutter por encima del Canvas
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(game: game),
          'UpgradeShop': (context, game) => UpgradeShopOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
          'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
        },
        initialActiveOverlays: const ['HUD'], // El HUD siempre activo al empezar
      ),
    );
  }
}



