import '../services/ad_service.dart';
import 'game_state.dart';

/// Sistema de recompensas post-partida
///
/// Responsabilidades:
/// - Mostrar recompensas ganadas
/// - Ofrecer duplicar recompensas con anuncio
/// - Controlar el estado del botón x2
/// - Actualizar UI en tiempo real
class RewardSystem {
  final GameStateManager gameState;
  final AdService adService;

  // Callbacks para evento de recompensas
  Function()? onDoubleRewardStarted;
  Function()? onDoubleRewardCompleted;

  RewardSystem({
    required this.gameState,
    required this.adService,
  });

  // =========================
  // INFORMACIÓN DE RECOMPENSAS
  // =========================

  /// Obtener monedas actuales (con multiplicador aplicado)
  int getCoins() => gameState.coinsEarned;

  /// Obtener gemas actuales (con multiplicador aplicado)
  int getGems() => gameState.gemsEarned;

  /// Estatísticas de la run
  Map<String, dynamic> getRunStats() {
    return {
      'coins': gameState.coinsEarned,
      'gems': gameState.gemsEarned,
      'enemiesDefeated': gameState.enemiesDefeated,
      'totalDamage': gameState.totalDamageDealt,
      'timePlayedSeconds': gameState.timePlayedSeconds,
      'multiplier': gameState.rewardMultiplier,
    };
  }

  // =========================
  // DUPLICADOR DE RECOMPENSAS
  // =========================

  /// Verificar si el botón x2 está disponible
  bool canDoubleRewards() {
    return !gameState.doubleRewardUsed && gameState.rewardMultiplier == 1;
  }

  /// Intentar duplicar recompensas (con anuncio)
  void attemptDoubleReward() {
    if (!canDoubleRewards()) return;

    // Verificar si el anuncio está listo
    if (!adService.isRewardedMonedasReady) {
      // Si no hay anuncio, duplicar sin anuncio (opcional)
      _executeDoubleReward();
      return;
    }

    // Mostrar anuncio recompensado
    onDoubleRewardStarted?.call();
    adService.showRewardedMonedas(() {
      _executeDoubleReward();
    });
  }

  /// Lógica INTERNA de duplicar
  void _executeDoubleReward() {
    gameState.doubleRewards();
    onDoubleRewardCompleted?.call();
  }

  // =========================
  // FINALIZACIÓN DE RECOMPENSAS
  // =========================

  /// Obtener recompensas finales para guardar
  Map<String, int> getFinalRewards() {
    return gameState.getFinalRewards();
  }

  /// Debug: mostrar resumen de recompensas
  String getDebugSummary() {
    final stats = getRunStats();
    return '''
RewardSummary:
- Coins: ${stats['coins']}
- Gems: ${stats['gems']}
- Enemies: ${stats['enemiesDefeated']}
- Damage: ${stats['totalDamage']}
- Time: ${stats['timePlayedSeconds']}s
- Multiplier: ${stats['multiplier']}x
- Can Double: ${canDoubleRewards()}
''';
  }
}
