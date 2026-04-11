import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/paleto_game.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/upgrade_shop_overlay.dart';
import '../widgets/wave_clear_overlay.dart';
import '../widgets/pause_menu_overlay.dart';
import '../controllers/economy_controller.dart';
import '../controllers/world_controller.dart';
import '../controllers/chef_controller.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../game_logic/game_state.dart';
import '../game_logic/revive_system.dart';
import '../game_logic/reward_system.dart';
import '../widgets/game_over_overlay.dart' as old_gameover;
import 'overlays/game_over_overlay.dart' as new_gameover;
import 'overlays/reward_overlay.dart';
import '../widgets/thank_you_ad_overlay.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final PaletoGame _game;

  // =========================
  // NUEVOS SISTEMAS
  // =========================

  late GameStateManager _gameState;
  late ReviveSystem _reviveSystem;
  late RewardSystem _rewardSystem;
  late AdService _adService;

  late Timer _updatePlayTimeTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Reproducir música de gameplay
    try {
      final locationData = context.read<WorldController>().selectedLocation;
      final locationName = locationData.name.toLowerCase();

      if (locationName == 'caribe') {
        AudioService.instance.playCarribeMusic();
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

    // =========================
    // INICIALIZAR NUEVOS SISTEMAS
    // =========================

    _adService = AdService();
    _gameState = GameStateManager();
    _reviveSystem = ReviveSystem(gameState: _gameState, adService: _adService);
    _rewardSystem = RewardSystem(gameState: _gameState, adService: _adService);

    // Configurar callbacks del ReviveSystem
    _reviveSystem.onReviveStarted = () {
      // Cerrar overlay de game over
      _game.overlays.remove('NewGameOver');
    };
    _reviveSystem.onReviveCompleted = _onReviveCompleted;
    _reviveSystem.onReviveCancelled = _onReviveCancelled;
    _reviveSystem.onShowThankYouOverlay = () {
      // Mostrar overlay de agradecimiento
      _game.overlays.add('ThankYouAd');
    };
    _reviveSystem.onClearNearbyEnemies = () {
      // Implementar lógica de limpiar enemigos cercanos
    };
    _reviveSystem.onRepositionPlayer = () {
      // Implementar lógica de reposicionar jugador
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayTimeTracking();
    });

    _game = PaletoGame(
      locationData: context.read<WorldController>().selectedLocation,
      playerIcon: context.read<ChefController>().activeChef.icon,
      onPlayerTakeDamage: (double amount) {
        if (mounted) {
          _gameState.takeDamage(amount.toInt());
          context.read<EconomyController>().takeDamage(amount);

          // Verificar si el jugador murió
          if (_gameState.playerHealth <= 0 && _gameState.status == GameStatus.playing) {
            _onPlayerDeath();
          }

          if (context.read<EconomyController>().playerHp <= 0) {
            _game.pauseEngine();
            // Usar nuevo overlay si está disponible
            if (_reviveSystem.canRevive) {
              _game.overlays.add('NewGameOver');
            } else {
              _game.overlays.add('GameOver');
            }
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
          _gameState.addEnemyDefeated();
          final eco = context.read<EconomyController>();
          eco.addRewardsFromEnemy(wave, isBoss: isBoss);

          // Agregar recompensas al sistema de recompensas
          if (isBoss) {
            _gameState.addCoins(wave * 50);
            _gameState.addGems(wave);
          } else {
            _gameState.addCoins(wave * 10);
          }

          if (isBoss) {
            context.read<ChefController>().processBossKillReward(eco, context);
          }
          try {
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

  void _startPlayTimeTracking() {
    _updatePlayTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState.status == GameStatus.playing) {
        _elapsedSeconds++;
        _gameState.updatePlayTime(_elapsedSeconds);
      }
    });
  }

  void _onPlayerDeath() {
    _game.pauseEngine();
    _gameState.setStatus(GameStatus.dead);
    _reviveSystem.offerRevive();
    _game.overlays.add('NewGameOver');
  }

  void _onReviveCompleted() {
    // El juego será reanudado por el ThankYouAdOverlay cuando se cierre
    _gameState.resumeAfterRevive();
  }

  void _onReviveCancelled() {
    _game.overlays.remove('NewGameOver');
    _gameState.showRewardScreen();
    _game.pauseEngine();
    _game.overlays.add('NewRewardOverlay');
  }

  @override
  void dispose() {
    _updatePlayTimeTimer.cancel();
    try {
      AudioService.instance.playMenuMusic();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameStateManager>.value(
      value: _gameState,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<PaletoGame>(
          game: _game,
          overlayBuilderMap: {
            'HUD': (context, game) => HudOverlay(game: game),
            'UpgradeShop': (context, game) => UpgradeShopOverlay(game: game),
            'WaveClear': (context, game) => WaveClearOverlay(game: game),
            'GameOver': (context, game) => old_gameover.GameOverOverlay(game: game),
            'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
            // Nuevos overlays del sistema de muerte/revivir
            'NewGameOver': (context, game) => new_gameover.GameOverOverlay(
              reviveSystem: _reviveSystem,
            ),
            'ThankYouAd': (context, game) => ThankYouAdOverlay(
              onComplete: () {
                _game.overlays.remove('ThankYouAd');
                _game.resumeEngine();
              },
            ),
            'NewRewardOverlay': (context, game) => RewardOverlay(
              rewardSystem: _rewardSystem,
              onClose: () {
                _game.overlays.remove('NewRewardOverlay');
                _game.resumeEngine();
                _gameState.resetGame();
              },
            ),
          },
          initialActiveOverlays: const [
            'HUD',
          ],
        ),
      ),
    );
  }
}
