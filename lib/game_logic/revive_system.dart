import '../services/ad_service.dart';
import 'game_state.dart';

/// Sistema de revivir completamente desacoplado
///
/// Responsabilidades:
/// - Ofrecer revive cuando el jugador muere
/// - Integrar con AdService de forma desacoplada
/// - Controlar la lógica de revive (1 vez por partida)
/// - Callback para limpiar enemigos después de revivir
class ReviveSystem {
  final GameStateManager gameState;
  final AdService adService;

  // Callback para acciones relacionadas al revive
  Function()? onReviveStarted;
  Function()? onReviveCompleted;
  Function()? onReviveCancelled;
  Function()? onShowThankYouOverlay;

  // Para limpiar enemigos cercanos después de revivir
  Function()? onClearNearbyEnemies;

  // Para reposicionar al jugador
  Function()? onRepositionPlayer;

  ReviveSystem({
    required this.gameState,
    required this.adService,
  });

  /// Ofrecer revive cuando el jugador muere
  void offerRevive() {
    if (!gameState.canRevive) return;

    gameState.setStatus(GameStatus.reviveOffered);
    onReviveStarted?.call();
  }

  /// El jugador presiona "Revivir" (con anuncio)
  void attemptRevive() {
    if (!gameState.canRevive) return;

    // Notificar que el revive comenzó (cierra overlays)
    onReviveStarted?.call();

    // Verificar si el anuncio está listo
    if (!adService.isRewardedRevivirReady) {
      // Si no hay anuncio, ejecutar revive sin anuncio (opcional)
      _executeRevive();
      return;
    }

    // Mostrar anuncio recompensado
    adService.showRewardedRevivir(() {
      _executeRevive();
    });
  }

  /// Lógica INTERNA de revive
  void _executeRevive() {
    // 1. Mostrar overlay de agradecimiento
    onShowThankYouOverlay?.call();

    // 2. Restaurar vida (50% o valor fijo)
    gameState.revivePlayer(healthAmount: 50);

    // 3. Reposicionar jugador en zona segura
    onRepositionPlayer?.call();

    // 4. Limpiar enemigos cercanos (anti spawn kill)
    onClearNearbyEnemies?.call();

    // 5. Cambiar estado a revived
    gameState.setStatus(GameStatus.revived);

    // 6. Notificar
    onReviveCompleted?.call();
  }

  /// El jugador presiona "No, gracias"
  void declineRevive() {
    gameState.finishGame();
    onReviveCancelled?.call();
  }

  /// Obtener estado actual de revive
  bool get canRevive => gameState.canRevive;
  bool get hasRevived => gameState.hasRevived;
  GameStatus get currentStatus => gameState.status;
}
