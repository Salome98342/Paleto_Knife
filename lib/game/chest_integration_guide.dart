import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import '../widgets/reward_card.dart';
import 'components/chest_component.dart';

/// Guía de integración: ChestComponent + RewardCard
/// 
/// Este archivo demuestra cómo integrar los dos componentes
/// manteniendo la lógica de UI separada del motor de juego.

// ============================================================================
// PASO 1: CUANDO AÑADES EL ChestComponent AL GAME
// ============================================================================

class ExampleGameWithChest extends FlameGame with TapDetector {
  late ChestComponent chestComponent;
  
  // Referencia al contexto de Flutter para mostrar overlays
  late BuildContext gameContext;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Crear el componente del cofre en el centro de la pantalla
    chestComponent = ChestComponent(
      position: size / 2,
      size: const Vector2(80, 70),
      onChestOpened: _handleChestOpened, // Callback cuando se abre
    );
    
    add(chestComponent);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    
    // Detectar si el usuario tocó el cofre
    if (chestComponent.hitTest(info.localPosition)) {
      chestComponent.onTap();
    }
  }

  /// Callback disparado cuando el cofre termina su animación de apertura
  /// Aquí: mostrar el overlay con la RewardCard
  void _handleChestOpened() {
    // Crear los datos de la recompensa
    final rewardData = RewardData(
      title: 'Cuchillo Legendario',
      description: 'Un cuchillo forjado en las sombras. +50 ATK',
      icon: Icons.call_split,
      accentColor: const Color(0xFFFF6B00), // accentAlt de PixelColors
      rarityLevel: 3,
    );

    // Mostrar la carta como overlay
    _showRewardOverlay(rewardData);
  }

  /// Muestra el overlay de recompensa
  void _showRewardOverlay(RewardData rewardData) {
    // Opción 1: Usar addBase para agregar un widget Flutter como overlay
    addBase(
      RewardCardOverlay(
        rewardData: rewardData,
        onDismiss: _handleRewardDismissed,
      ),
    );
  }

  /// Callback cuando el usuario cierra/acepta la recompensa
  void _handleRewardDismissed() {
    // Aquí: lógica de juego (agregar recompensa al inventario, etc.)
    print('Recompensa aceptada');
    
    // Resetear el cofre o continuar con el siguiente
    // chestComponent.setIdleState(); // Opcional: para reutilizar el cofre
  }
}

// ============================================================================
// PASO 2: WRAPPER PARA MOSTRAR COMO OVERLAY
// ============================================================================

/// Widget que encapsula RewardCard para mostrarse como overlay
class RewardCardOverlay extends StatelessWidget {
  final RewardData rewardData;
  final VoidCallback? onDismiss;

  const RewardCardOverlay({
    super.key,
    required this.rewardData,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7), // Overlay semi-transparente
      child: Stack(
        children: [
          // Fondo oscuro (tappable para cerrar)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Carta de recompensa centrada
          RewardCard(
            rewardData: rewardData,
            onDismiss: () {
              // Remover el overlay
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            animationDuration: const Duration(milliseconds: 800),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PASO 3: INTEGRACIÓN COMPLETA EN UNA PANTALLA DE JUEGO
// ============================================================================

/// Ejemplo completo de cómo integrar en una pantalla de juego
class GameScreenWithChest extends StatefulWidget {
  const GameScreenWithChest({super.key});

  @override
  State<GameScreenWithChest> createState() => _GameScreenWithChestState();
}

class _GameScreenWithChestState extends State<GameScreenWithChest> {
  late ExampleGameWithChest gameInstance;

  @override
  void initState() {
    super.initState();
    gameInstance = ExampleGameWithChest();
    // Guardar referencia al contexto para mostrar overlays desde el game
    gameInstance.gameContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: gameInstance,
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar el juego
    gameInstance.removeFromParent();
    super.dispose();
  }
}

// ============================================================================
// PASO 4: CÓMO USAR ChestComponent DIRECTAMENTE EN UN GAME EXISTENTE
// ============================================================================

/*
  En tu archivo paleto_game.dart o combat_game.dart:

  class PaletoGame extends FlameGame with TapDetector {
    late ChestComponent chestComponent;

    @override
    Future<void> onLoad() async {
      super.onLoad();
      
      // Agregar el cofre
      chestComponent = ChestComponent(
        position: Vector2(size.x / 2, size.y * 0.7),
        size: Vector2(80, 70),
        onChestOpened: () {
          _showRewardCard();
        },
      );
      add(chestComponent);
    }

    @override
    void onTapDown(TapDownInfo info) {
      super.onTapDown(info);
      
      if (chestComponent.hitTest(info.localPosition)) {
        chestComponent.onTap();
      }
    }

    void _showRewardCard() {
      final rewardData = RewardData(
        title: 'Recompensa',
        description: 'Descripción aquí',
        icon: Icons.card_giftcard,
        accentColor: const Color(0xFFFFD700),
        rarityLevel: 2,
      );

      // Usar overlays de Flame para mostrar el widget Flutter
      overlays.add('reward_card');
      
      // Pasar datos al overlay (requiere que definas el overlay builder)
    }
  }

  // En el constructor de FlameGame, registrar el builder del overlay:
  overlayBuilderMap = {
    'reward_card': (context, game) {
      return RewardCardOverlay(
        rewardData: /* tus datos */,
        onDismiss: () {
          (game as PaletoGame).overlays.remove('reward_card');
        },
      );
    },
  };
 */

// ============================================================================
// NOTAS IMPORTANTES
// ============================================================================

/*
 1. SEPARACIÓN DE RESPONSABILIDADES:
    - ChestComponent: Maneja SOLO la lógica visual y estados del cofre
    - RewardCard: Maneja SOLO la UI de la carta de recompensa
    - El Game: Coordina la comunicación entre ambos mediante callbacks

 2. GESTIÓN DE ASSETS LOTTIE:
    - Las animaciones Lottie deben estar en assets/animations/
    - chest_idle.json, chest_shake.json, chest_open.json
    - Descomenta las líneas en ChestComponent.onLoad() y los setState()

 3. CUSTOMIZACIÓN:
    - RewardData: Estructura flexible para cualquier tipo de recompensa
    - RewardCard: Totalmente customizable (colores, iconos, textos)
    - Añade más campos a RewardData según necesites

 4. PERFORMANCE:
    - ChestComponent usa LottieComponent (ligero)
    - RewardCard usa flutter_animate (optim para Flutter)
    - Sin lag en dispositivos móviles con CPU débil

 5. AUDIO:
    - Puedes añadir SFX en ChestComponent.setShakeState() y setOpenState()
    - Usa AudioService existente: AudioService.playSound('chest_shake.wav')
 */
