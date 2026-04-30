/// GUÍA DE INTEGRACIÓN: ChestRewardScreen en tu flujo de juego
/// 
/// Este archivo explica cómo integrar la nueva pantalla de cofre
/// en tu sistema existente de recompensas

/*

═══════════════════════════════════════════════════════════════════════════════
PASO 1: IMPORTAR LOS NUEVOS COMPONENTES
═══════════════════════════════════════════════════════════════════════════════

En tu archivo principal de navegación o donde manejás el flujo de pantallas,
agrega estos imports:

import '../screens/chest_reward_screen.dart';
import '../game/components/chest_component.dart';
import '../widgets/reward_card.dart';

═══════════════════════════════════════════════════════════════════════════════
PASO 2: CREAR UN MÉTODO PARA MOSTRAR LA PANTALLA DEL COFRE
═══════════════════════════════════════════════════════════════════════════════

En tu GameController o donde manejás la lógica de recompensas:

  /// Mostrar pantalla de cofre después de ganar
  void showChestRewardScreen({
    required int coins,
    required int gems,
    required int items,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChestRewardScreen(
          coinsReward: coins,
          gemsReward: gems,
          itemsReward: items,
          onRewardAccepted: () {
            // Aquí: aplicar las recompensas al jugador
            addCoins(coins);
            addGems(gems);
            addItems(items);
            
            // Volver a la pantalla anterior
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

═══════════════════════════════════════════════════════════════════════════════
PASO 3: INTEGRACIÓN CON TU REWARD SYSTEM EXISTENTE
═══════════════════════════════════════════════════════════════════════════════

En tu struct que maneja fin de juego (ej: después de CombatGame):

  void _onCombatFinished() {
    // Obtener recompensas del sistema existente
    final coins = rewardSystem.getCoins();
    final gems = rewardSystem.getGems();
    
    // OPCIÓN A: Mostrar el cofre en lugar del overlay actual
    showChestRewardScreen(
      coins: coins,
      gems: gems,
      items: 0,
    );
    
    // OPCIÓN B: Mantener ambos (cofre primero, luego detalles)
    // navigator.push(ChestRewardScreen(...));
  }

═══════════════════════════════════════════════════════════════════════════════
PASO 4: CONECTAR CON COMBAT_GAME.DART
═══════════════════════════════════════════════════════════════════════════════

En tu CombatGame, cuando el jugador gane, disparar:

  void _onGameWon() {
    pauseEngine();
    
    // Llamar a callback de victoria
    onGameWon?.call();
    
    // El callback exterior (en tu main widget) mostraría:
    // showChestRewardScreen(...)
  }

═══════════════════════════════════════════════════════════════════════════════
PASO 5: INFORMACIÓN DE LOS COMPONENTES DISPONIBLES
═══════════════════════════════════════════════════════════════════════════════

ARCHIVO: lib/screens/chest_reward_screen.dart
CLASE: ChestRewardScreen (StatefulWidget)

Constructor:
  ChestRewardScreen({
    required int coinsReward,
    required int gemsReward,
    required int itemsReward,
    required VoidCallback onRewardAccepted,
  })

PARÁMETROS:
- coinsReward: Monedas ganadas
- gemsReward: Gemas ganadas  
- itemsReward: Items ganados
- onRewardAccepted: Callback cuando el usuario acepta la recompensa

EJEMPLO DE USO:
─────────────────────────────────────────────────────────────────────────────

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => ChestRewardScreen(
        coinsReward: 500,
        gemsReward: 50,
        itemsReward: 2,
        onRewardAccepted: () {
          // Aplicar recompensas
          gameController.addCoins(500);
          gameController.addGems(50);
          gameController.addItems(2);
          
          // Volver a la pantalla anterior
          Navigator.pop(context);
        },
      ),
    ),
  );

═══════════════════════════════════════════════════════════════════════════════
PASO 6: PERSONALIZACIÓN DE COLORES Y TAMAÑOS
═══════════════════════════════════════════════════════════════════════════════

En _ChestGameInstance.onLoad():

  // Cambiar tamaño del cofre (ajusta si se ve muy pequeño/grande)
  size: const Vector2(100, 85),  // Ancho x Alto

  // Cambiar posición (ej: lado izquierdo)
  position: Vector2(size.x * 0.3, size.y / 2),

═══════════════════════════════════════════════════════════════════════════════
PASO 7: INTEGRACIÓN CON OVERLAYS (ALTERNATIVA)
═══════════════════════════════════════════════════════════════════════════════

Si prefieres mostrar el cofre como overlay sobre el juego existente:

En CombatGame:
  
  @override
  void onLoad() async {
    super.onLoad();
    
    // Registrar el overlay builder
    overlayBuilderMap = {
      'chest_reward': (context, game) {
        return ChestOverlayWidget(
          game: this as CombatGame,
          coinsReward: 500,
          gemsReward: 50,
          itemsReward: 0,
        );
      },
    };
  }

  // Cuando el combate termina:
  void _onCombatFinished() {
    overlays.add('chest_reward');
  }

═══════════════════════════════════════════════════════════════════════════════
PASO 8: CAMBIOS MÍNIMOS NECESARIOS
═══════════════════════════════════════════════════════════════════════════════

OPCIÓN SIMPLE (Recomendado):
1. Copia el contenido de chest_reward_screen.dart
2. Donde muestres recompensas actualmente, reemplaza con:
   Navigator.push(context, MaterialPageRoute(
     builder: (ctx) => ChestRewardScreen(...)
   ))

OPCIÓN INTERMEDIA:
1. Mantén tu sistema actual
2. Muestra el cofre como alternativa opcional
3. Usuarios pueden elegir si ver el cofre o no

OPCIÓN COMPLETA:
1. Integra el cofre en cada punto de recompensa
2. Crea variantes del RewardData según el tipo de recompensa
3. Personaliza el flujo de animación

═══════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
═══════════════════════════════════════════════════════════════════════════════

P: El cofre no aparece
R: Verifica que ChestComponent esté correctamente importado:
   import '../game/components/chest_component.dart';

P: El cofre aparece pero no responde a toques
R: Asegúrate de que TapDetector está incluido:
   class _ChestGameInstance extends FlameGame with TapDetector

P: La RewardCard no aparece
R: Verifica que reward_card.dart está en lib/widgets/
   import '../widgets/reward_card.dart';

P: El tamaño del cofre está mal
R: Ajusta en _ChestGameInstance.onLoad():
   size: const Vector2(100, 85),  // Ancho, Alto

═══════════════════════════════════════════════════════════════════════════════
CONFIGURACIÓN RECOMENDADA PARA TU JUEGO
═══════════════════════════════════════════════════════════════════════════════

ARQUITECTURA SUGERIDA:

1. Después que CombatGame termina
2. Mostrar ChestRewardScreen
3. Usuario abre cofre
4. Aparece RewardCard con detalles
5. Usuario acepta
6. Aplicar recompensas y volver al menú

FLUJO:
  CombatGame (jugando)
       ↓ (combate ganado)
  ChestRewardScreen (cofre interactivo)
       ↓ (usuario toca cofre)
  RewardCard (detalles de recompensa)
       ↓ (usuario acepta)
  Menú principal / Siguiente combate

═══════════════════════════════════════════════════════════════════════════════
ARCHIVOS NECESARIOS (YA CREADOS)
═══════════════════════════════════════════════════════════════════════════════

✅ lib/game/components/chest_component.dart
   └─ El componente Flame del cofre

✅ lib/widgets/reward_card.dart
   └─ La carta de recompensa con animaciones

✅ lib/screens/chest_reward_screen.dart
   └─ La pantalla que integra ambos (NUEVO)

═══════════════════════════════════════════════════════════════════════════════

¡LISTO PARA INTEGRAR! Comienza por el PASO 2 y PASO 3.
*/
