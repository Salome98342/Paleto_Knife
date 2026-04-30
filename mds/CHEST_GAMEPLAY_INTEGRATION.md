/// EJEMPLO PRÁCTICO: Integración de ChestRewardScreen en GameplayScreen
/// 
/// Este archivo muestra EXACTAMENTE qué código agregar a tu GameplayScreen
/// para mostrar el cofre cuando el jugador obtiene recompensas

/*

═══════════════════════════════════════════════════════════════════════════════
PASO 1: AGREGAR IMPORT A TU GameplayScreen
═══════════════════════════════════════════════════════════════════════════════

En lib/screens/gameplay_screen.dart, en la sección de imports, agregar:

  import 'chest_reward_screen.dart'; // ← AGREGAR ESTA LÍNEA

═══════════════════════════════════════════════════════════════════════════════
PASO 2: MODIFICAR _onReviveCancelled()
═══════════════════════════════════════════════════════════════════════════════

ANTES (código actual):
─────────────────────────────────────────────────────────────────────────────

  void _onReviveCancelled() {
    _game.overlays.remove('NewGameOver');
    _gameState.showRewardScreen();
    _game.pauseEngine();
    _game.overlays.add('NewRewardOverlay');
  }

DESPUÉS (código modificado con cofre):
─────────────────────────────────────────────────────────────────────────────

  void _onReviveCancelled() {
    _game.overlays.remove('NewGameOver');
    _gameState.showRewardScreen();
    _game.pauseEngine();
    
    // MOSTRAR COFRE EN LUGAR DE OVERLAY SIMPLE
    _showChestReward();
  }

═══════════════════════════════════════════════════════════════════════════════
PASO 3: AGREGAR NUEVO MÉTODO _showChestReward()
═══════════════════════════════════════════════════════════════════════════════

En la clase _GameplayScreenState, DESPUÉS de _onReviveCancelled(), agregar:

  /// Mostrar pantalla de recompensa con cofre interactivo
  void _showChestReward() {
    // Obtener recompensas del sistema
    final coins = _gameState.coinsEarned; // o el nombre que uses
    final gems = _gameState.gemsEarned;
    final enemiesDefeated = _gameState.enemiesDefeated;
    
    // Navegar a la pantalla del cofre
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChestRewardScreen(
          coinsReward: coins,
          gemsReward: gems,
          itemsReward: enemiesDefeated ~/ 10, // Ej: 1 item cada 10 enemigos
          onRewardAccepted: _acceptRewardAndContinue,
        ),
      ),
    );
  }

  /// Callback cuando el usuario acepta la recompensa
  void _acceptRewardAndContinue() {
    // Aquí: aplicar las recompensas al jugador
    _game.resumeEngine();
    
    // Guardar progreso
    if (mounted) {
      context.read<EconomyController>().saveProgress();
      context.read<ChefController>().saveProgress();
    }
    
    // Volver a menú/mundo
    Navigator.of(context).pop();
  }

═══════════════════════════════════════════════════════════════════════════════
ALTERNATIVA: Usar el cofre como un overlay SIN navegar
═══════════════════════════════════════════════════════════════════════════════

Si prefieres mantener el overlay actual pero mostrar un cofre ANTES de las
recompensas finales, puedes hacer:

  void _showChestReward() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ChestRewardScreen(
          coinsReward: _gameState.coinsEarned,
          gemsReward: _gameState.gemsEarned,
          itemsReward: 0,
          onRewardAccepted: () {
            Navigator.pop(ctx); // Cerrar diálogo
            _game.overlays.add('NewRewardOverlay'); // Mostrar overlay anterior
          },
        ),
      ),
    );
  }

═══════════════════════════════════════════════════════════════════════════════
OPCIÓN RECOMENDADA: Mostrar cofre SEGUIDO de detalles
═══════════════════════════════════════════════════════════════════════════════

Crear un flujo natural:
1. Cofre interactivo (visual bonito)
2. RewardCard (detalles de recompensa)
3. Overlay de recompensas (resumen final)

Implementación:

  void _showChestReward() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChestRewardScreen(
          coinsReward: _gameState.coinsEarned,
          gemsReward: _gameState.gemsEarned,
          itemsReward: 0,
          onRewardAccepted: () {
            // Después que el usuario acepta la carta
            _acceptAndShowFinalRewards();
          },
        ),
      ),
    );
  }

  void _acceptAndShowFinalRewards() {
    // Mostrar el overlay final de recompensas
    _game.overlays.add('NewRewardOverlay');
    
    // El juego se reanuda cuando el usuario cierra este overlay
  }

═══════════════════════════════════════════════════════════════════════════════
PASOS DETALLADOS DE IMPLEMENTACIÓN
═══════════════════════════════════════════════════════════════════════════════

1. Abre: lib/screens/gameplay_screen.dart

2. En la línea 1-20 (imports), agrega:
   import 'chest_reward_screen.dart';

3. Busca el método: _onReviveCancelled()

4. Reemplaza su contenido con:
   
   void _onReviveCancelled() {
     _game.overlays.remove('NewGameOver');
     _gameState.showRewardScreen();
     _game.pauseEngine();
     _showChestReward();  // ← ESTA LÍNEA
   }

5. Agrega estos dos métodos al final de _GameplayScreenState:

   void _showChestReward() {
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (ctx) => ChestRewardScreen(
           coinsReward: _gameState.coinsEarned,
           gemsReward: _gameState.gemsEarned,
           itemsReward: 0,
           onRewardAccepted: _acceptRewardAndContinue,
         ),
       ),
     );
   }

   void _acceptRewardAndContinue() {
     _game.resumeEngine();
     if (mounted) {
       context.read<EconomyController>().saveProgress();
     }
     Navigator.of(context).pop();
   }

6. ¡Listo! El cofre debería apareces cuando el jugador pierda.

═══════════════════════════════════════════════════════════════════════════════
VERIFICACIÓN
═══════════════════════════════════════════════════════════════════════════════

Después de hacer los cambios, verifica que:

✓ El archivo compila sin errores
✓ Cuando pierdes una partida y rechazas revivir, aparece el cofre
✓ El cofre se ve bien en el centro de la pantalla
✓ Al tocar el cofre, se abre con animación
✓ Aparece la RewardCard con los detalles
✓ Al aceptar, vuelves al menú principal

═══════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════════════════

P: El cofre no aparece
A: Verifica:
   - Import está agregado
   - _showChestReward() es llamado
   - ChestComponent está en lib/game/components/

P: Error "ChestRewardScreen not found"
A: Asegúrate que el archivo existe:
   lib/screens/chest_reward_screen.dart

P: El cofre aparece pero muy pequeño/grande
A: En chest_reward_screen.dart, línea ~70, cambia:
   size: const Vector2(100, 85),  // Ancho x Alto

P: La RewardCard no se ve bonita
A: Verifica reward_card.dart en lib/widgets/

═══════════════════════════════════════════════════════════════════════════════
INFORMACIÓN DE GAMESTATEMANAGER
═══════════════════════════════════════════════════════════════════════════════

Variables que puedes usar en _showChestReward():

  _gameState.coinsEarned    // Monedas ganadas
  _gameState.gemsEarned     // Gemas ganadas
  _gameState.enemiesDefeated // Enemigos derrotados
  _gameState.totalDamageDealt // Daño total
  _gameState.timePlayedSeconds // Tiempo jugado

═══════════════════════════════════════════════════════════════════════════════
NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

1. Implementa los cambios arriba ↑
2. Prueba en el emulador/dispositivo
3. Ajusta tamaños/colores según necesites
4. Agregar sonidos (opcional):
   AudioService.instance.playSound('chest_open.wav')
5. Agregar más variantes de RewardData

═══════════════════════════════════════════════════════════════════════════════
*/
