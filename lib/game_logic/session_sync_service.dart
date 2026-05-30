import 'package:flutter/foundation.dart';
import '../controllers/game_controller.dart';
import '../game_logic/game_state.dart';

/// Servicio que sincroniza el estado de una sesión de combate
/// con el progreso persistente del jugador
///
/// Responsabilidades:
/// - Transferir recompensas de sesión a progreso permanente
/// - Sincronizar estadísticas acumuladas
/// - Manejar la lógica de revivir y recompensas finales
///
/// FLUJO:
/// 1. Durante combate: GameStateManager acumula coinsEarned, enemiesDefeated, etc
/// 2. Al terminar combate: SessionSyncService.syncSessionToProgress() transfiere datos
/// 3. GameController.saveGameState() guarda el cambio en persistencia
class SessionSyncService {
  /// Sincroniza el estado final de una sesión al progreso del jugador
  /// Debe ser llamado cuando la sesión termina (gameOver o go back)
  static Future<void> syncSessionToProgress({
    required GameStateManager sessionState,
    required GameController gameController,
  }) async {
    // Validar antes de sincronizar
    if (!validateSync(sessionState)) {
      debugPrint('[ERROR] SessionSync: Validación falló, no sincronizando');
      return;
    }

    // No sincronizar si la sesión está vacía
    if (sessionState.coinsEarned == 0 && sessionState.gemsEarned == 0) {
      debugPrint('[SessionSync] Sesión vacía, sin sincronización necesaria');
      return;
    }

    debugPrint('[SessionSync] Iniciando sincronización...');

    // Transferir recompensas acumuladas a GameState persistente
    gameController.addGold(sessionState.coinsEarned.toDouble());
    gameController.addEnemiesDefeated(sessionState.enemiesDefeated);

    debugPrint('[SessionSync] ✓ Monedas: +${sessionState.coinsEarned}');
    debugPrint('[SessionSync] ✓ Enemigos: +${sessionState.enemiesDefeated}');

    // Guardar el estado actualizado
    await gameController.saveGameState();

    debugPrint('[SessionSync] Sincronización completada');
  }

  /// Obtiene las recompensas finales de una sesión con multiplicadores aplicados
  static Map<String, dynamic> getSessionRewards(GameStateManager sessionState) {
    return {
      'coins': sessionState.coinsEarned,
      'gems': sessionState.gemsEarned,
      'enemiesDefeated': sessionState.enemiesDefeated,
      'totalDamageDealt': sessionState.totalDamageDealt,
      'timePlayedSeconds': sessionState.timePlayedSeconds,
      'rewardMultiplier': sessionState.rewardMultiplier,
      'hasRevived': sessionState.hasRevived,
    };
  }

  /// Valida que la sincronización sea segura antes de aplicarla
  static bool validateSync(GameStateManager sessionState) {
    // Validar que los valores sean razonables
    if (sessionState.coinsEarned < 0) {
      debugPrint('[ERROR] SessionSync: coinsEarned es negativo');
      return false;
    }
    if (sessionState.gemsEarned < 0) {
      debugPrint('[ERROR] SessionSync: gemsEarned es negativo');
      return false;
    }
    if (sessionState.enemiesDefeated < 0) {
      debugPrint('[ERROR] SessionSync: enemiesDefeated es negativo');
      return false;
    }

    return true;
  }
}

