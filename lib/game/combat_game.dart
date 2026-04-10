import 'package:flame/game.dart';
import 'components/combat_game_screen.dart';
import '../game_logic/game_state.dart';
import '../game_logic/revive_system.dart';
import '../game_logic/reward_system.dart';
import '../services/ad_service.dart';
import 'dart:async';

/// Juego Flame principal con sistema de combate integrado
///
/// Tiene integrado:
/// - Sistema de estado del juego (GameStateManager)
/// - Sistema de revivir (ReviveSystem)
/// - Sistema de recompensas (RewardSystem)
class CombatGame extends FlameGame {
  /// Pantalla principal de juego
  late CombatGameScreen gameScreen;

  // =========================
  // SISTEMAS INTEGRADOS
  // =========================

  late GameStateManager gameState;
  late ReviveSystem reviveSystem;
  late RewardSystem rewardSystem;
  late AdService adService;

  // Timing
  int _elapsedSeconds = 0;
  late Timer _updatePlayTimeTimer;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Inicializar servicios
    adService = AdService();
    gameState = GameStateManager();
    reviveSystem = ReviveSystem(gameState: gameState, adService: adService);
    rewardSystem = RewardSystem(gameState: gameState, adService: adService);

    // Listeners del ReviveSystem
    reviveSystem.onReviveCompleted = _onReviveCompleted;
    reviveSystem.onReviveCancelled = _onReviveCancelled;
    reviveSystem.onClearNearbyEnemies = _clearNearbyEnemies;
    reviveSystem.onRepositionPlayer = _repositionPlayer;

    // Listeners del RewardSystem
    rewardSystem.onDoubleRewardCompleted = _onDoubleRewardCompleted;

    // Crear pantalla de juego
    gameScreen = CombatGameScreen()
      ..size = size
      ..position = Vector2.zero();

    add(gameScreen);

    // Iniciar timer de playtime
    _startPlayTimeTracking();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Verificar si el jugador murió
    if (gameState.status == GameStatus.playing && gameState.playerHealth <= 0) {
      _onPlayerDeath();
    }
  }

  // =========================
  // MUERTE Y REVIVIR
  // =========================

  /// Callback cuando el jugador muere
  void _onPlayerDeath() {
    pauseEngine();
    gameState.setStatus(GameStatus.dead);
    reviveSystem.offerRevive();

    // Mostrar overlay de game over
    overlays.add('GameOverOverlay');
  }

  /// Callback cuando revive es completado
  void _onReviveCompleted() {
    overlays.remove('GameOverOverlay');
    gameState.resumeAfterRevive();
    resumeEngine();
  }

  /// Callback cuando revive es rechazado
  void _onReviveCancelled() {
    overlays.remove('GameOverOverlay');
    gameState.showRewardScreen();
    pauseEngine();

    // Mostrar overlay de recompensas
    overlays.add('RewardOverlay');
  }

  /// Limpiar enemigos cercanos después de revivir
  void _clearNearbyEnemies() {
  }

  /// Reposicionar al jugador en zona segura
  void _repositionPlayer() {
  }

  // =========================
  // RECOMPENSAS
  // =========================

  /// Callback cuando se duplican recompensas
  void _onDoubleRewardCompleted() {
    // Actualizar UI del overlay de recompensas
    // Ya está manejado por ChangeNotifier de GameStateManager
  }

  // =========================
  // TRACKING DE PLAYTIME
  // =========================

  void _startPlayTimeTracking() {
    _updatePlayTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (gameState.status == GameStatus.playing) {
        _elapsedSeconds++;
        gameState.updatePlayTime(_elapsedSeconds);
      }
    });
  }

  // =========================
  // CONTROL DEL JUEGO
  // =========================

  /// Pausa el juego
  void pauseGame() {
    pauseEngine();
    gameScreen.pauseCombat();
  }

  /// Reanuda el juego
  void resumeGame() {
    resumeEngine();
    gameScreen.resumeCombat();
  }

  /// Reinicia el juego
  void restartGame() {
    _elapsedSeconds = 0;
    gameState.resetGame();
    overlays.remove('GameOverOverlay');
    overlays.remove('RewardOverlay');
    gameScreen.restartCombat();
    resumeEngine();
  }

  /// Terminar juego completamente
  void endGame() {
    pauseEngine();
    gameState.finishGame();
    overlays.add('RewardOverlay');
  }

  @override
  void onRemove() {
    _updatePlayTimeTimer.cancel();
    super.onRemove();
  }
}
