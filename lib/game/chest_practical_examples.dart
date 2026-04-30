import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import '../widgets/reward_card.dart';
import 'components/chest_component.dart';

/// IMPLEMENTACIÓN PRÁCTICA: Pantalla con Cofre + Recompensas
/// 
/// Este archivo contiene ejemplos listos para copiar y pegar
/// en tus pantallas de juego existentes

// ============================================================================
// EJEMPLO 1: Integración en un Game existente (Opción Simple)
// ============================================================================

class ChestGameScreen extends FlameGame with TapDetector {
  late ChestComponent chestComponent;
  final BuildContext screenContext;
  
  // Datos de recompensas (ejemplo: 5 recompensas posibles)
  static final List<RewardData> AVAILABLE_REWARDS = [
    const RewardData(
      title: 'Cuchillo Legendario',
      description: 'Legendario arcano que desgarrante el espacio.',
      icon: Icons.call_split,
      accentColor: Color(0xFFFF6B00), // accentAlt
      rarityLevel: 3,
    ),
    const RewardData(
      title: 'Poción de Fortaleza',
      description: 'Tu ataque aumenta permanentemente +25.',
      icon: Icons.local_fire_department,
      accentColor: Color(0xFFCC3333), // danger
      rarityLevel: 2,
    ),
    const RewardData(
      title: 'Expansión de Mana',
      description: 'Tu mana máximo aumenta en 50 puntos.',
      icon: Icons.bubble_chart,
      accentColor: Color(0xFF3399FF), // mana
      rarityLevel: 2,
    ),
    const RewardData(
      title: 'Monedas de Oro',
      description: 'Obtienes 1000 monedas de oro.',
      icon: Icons.paid,
      accentColor: Color(0xFFFFD700), // accent
      rarityLevel: 1,
    ),
    const RewardData(
      title: 'Talismán Protector',
      description: 'Reduces el daño recibido en un 20%.',
      icon: Icons.shield,
      accentColor: Color(0xFF44CC44), // health
      rarityLevel: 3,
    ),
  ];

  ChestGameScreen(this.screenContext);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Crear el componente del cofre
    chestComponent = ChestComponent(
      position: size / 2,
      size: const Vector2(80, 70),
      onChestOpened: _handleChestOpened,
    );
    
    add(chestComponent);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    
    // Detectar toque en el cofre
    if (chestComponent.hitTest(info.localPosition)) {
      chestComponent.onTap();
    }
  }

  /// Callback: Cofre completamente abierto
  void _handleChestOpened() {
    // Selector aleatorio de recompensa
    final randomReward = AVAILABLE_REWARDS[
      DateTime.now().millisecondsSinceEpoch % AVAILABLE_REWARDS.length
    ];
    
    // Mostrar overlay
    _showRewardOverlay(randomReward);
  }

  /// Muestra el overlay de recompensa
  void _showRewardOverlay(RewardData rewardData) {
    // Usando showDialog para máxima compatibilidad
    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (context) => _RewardDialogWrapper(
        rewardData: rewardData,
        onDismiss: () {
          Navigator.pop(context);
          _handleRewardAccepted(rewardData);
        },
      ),
    );
  }

  /// Callback: Recompensa aceptada
  void _handleRewardAccepted(RewardData rewardData) {
    print('✓ Recompensa aceptada: ${rewardData.title}');
    
    // Aquí: Agregar la recompensa al jugador
    // ejemplo: gameController.addReward(rewardData);
    
    // Opcional: resetear el cofre para usarlo de nuevo
    // chestComponent.setIdleState();
  }
}

/// Wrapper para mostrar RewardCard en Dialog
class _RewardDialogWrapper extends StatelessWidget {
  final RewardData rewardData;
  final VoidCallback onDismiss;

  const _RewardDialogWrapper({
    required this.rewardData,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: RewardCard(
        rewardData: rewardData,
        onDismiss: onDismiss,
        animationDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 2: Widget Wrapper para usarlo en StatefulWidget
// ============================================================================

class ChestGameWidget extends StatefulWidget {
  const ChestGameWidget({super.key});

  @override
  State<ChestGameWidget> createState() => _ChestGameWidgetState();
}

class _ChestGameWidgetState extends State<ChestGameWidget> {
  late ChestGameScreen gameInstance;

  @override
  void initState() {
    super.initState();
    gameInstance = ChestGameScreen(context);
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
    gameInstance.removeFromParent();
    super.dispose();
  }
}

// ============================================================================
// EJEMPLO 3: Sistema avanzado con múltiples cofres
// ============================================================================

class AdvancedChestGameScreen extends FlameGame with TapDetector {
  final List<ChestComponent> chests = [];
  final BuildContext screenContext;
  int chestsOpened = 0;
  static const int TOTAL_CHESTS = 3;

  AdvancedChestGameScreen(this.screenContext);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Crear múltiples cofres en diferentes posiciones
    final positions = [
      Vector2(size.width * 0.2, size.height * 0.5),
      Vector2(size.width * 0.5, size.height * 0.5),
      Vector2(size.width * 0.8, size.height * 0.5),
    ];

    for (int i = 0; i < positions.length; i++) {
      final chest = ChestComponent(
        position: positions[i],
        size: const Vector2(80, 70),
        onChestOpened: () => _handleChestOpened(i),
      );
      
      chests.add(chest);
      add(chest);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    
    // Detección de múltiples cofres
    for (int i = 0; i < chests.length; i++) {
      if (chests[i].hitTest(info.localPosition) && !chests[i].isOpened) {
        chests[i].onTap();
        break;
      }
    }
  }

  void _handleChestOpened(int chestIndex) {
    chestsOpened++;
    print('Cofre $chestIndex abierto ($chestsOpened/$TOTAL_CHESTS)');
    
    // Mostrar recompensa
    final rewardData = ChestGameScreen.AVAILABLE_REWARDS[chestIndex];
    _showRewardOverlay(rewardData, chestIndex);
    
    // Si todos están abiertos, mostrar pantalla de victoria
    if (chestsOpened == TOTAL_CHESTS) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _showVictoryScreen();
      });
    }
  }

  void _showRewardOverlay(RewardData rewardData, int chestIndex) {
    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: RewardCard(
          rewardData: rewardData,
          onDismiss: () => Navigator.pop(context),
          animationDuration: const Duration(milliseconds: 800),
        ),
      ),
    );
  }

  void _showVictoryScreen() {
    print('¡Todos los cofres abiertos!');
    // Mostrar pantalla de victoria
  }
}

// ============================================================================
// EJEMPLO 4: Integración con un Game Controller existente
// ============================================================================

/*
// En tu archivo existente (ej: game/paleto_game.dart)

class PaletoGame extends FlameGame with TapDetector {
  late ChestComponent currentChest;
  late BuildContext gameContext;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Otros componentes del juego...
    
    // Agregar el cofre
    currentChest = ChestComponent(
      position: Vector2(size.x / 2, size.y * 0.6),
      size: const Vector2(80, 70),
      onChestOpened: _onChestOpened,
    );
    add(currentChest);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    
    // Tus otros controles...
    
    // Detectar cofre
    if (currentChest.hitTest(info.localPosition)) {
      currentChest.onTap();
    }
  }

  void _onChestOpened() {
    // Lógica del juego
    print('Cofre abierto en el juego principal');
    
    // Mostrar recompensa
    final reward = _selectReward();
    _displayRewardCard(reward);
  }

  void _displayRewardCard(RewardData reward) {
    showDialog(
      context: gameContext,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: RewardCard(
          rewardData: reward,
          onDismiss: () {
            Navigator.pop(ctx);
            // Continuar lógica del juego
          },
        ),
      ),
    );
  }

  RewardData _selectReward() {
    // Tu lógica de selección de recompensas
    return ChestGameScreen.AVAILABLE_REWARDS[0];
  }
}
*/

// ============================================================================
// HELPER: Generador de RewardData dinámico
// ============================================================================

class RewardGenerator {
  /// Genera una recompensa aleatoria basada en rareza
  static RewardData generateRandomReward({
    double rarityMultiplier = 1.0,
  }) {
    final roll = DateTime.now().millisecondsSinceEpoch % 100;
    
    // 60% común, 30% raro, 10% épico
    final rarityLevel = roll < 60
        ? 1
        : roll < 90
            ? 2
            : 3;

    return ChestGameScreen.AVAILABLE_REWARDS[
      DateTime.now().microsecondsSinceEpoch % ChestGameScreen.AVAILABLE_REWARDS.length
    ];
  }

  /// Genera recompensas personalizadas
  static RewardData createCustomReward({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    int rarityLevel = 2,
  }) {
    return RewardData(
      title: title,
      description: description,
      icon: icon,
      accentColor: accentColor,
      rarityLevel: rarityLevel,
    );
  }
}

// ============================================================================
// NOTAS Y CONSEJOS
// ============================================================================

/*
1. MOSTRAR REWARD CARD:
   ✓ showDialog() - Dialog nativo de Flutter
   ✓ CompositedTransformFollower - Para seguir al cofre
   ✓ Overlay (GlobalKey) - Para control total

2. SONIDOS:
   - Agregar en _handleChestOpened():
     AudioService.playSound('chest_open.wav');
   - Agregar en RewardCard construction:
     AudioService.playSound('card_appear.wav');

3. ANIMACIONES AUDIO:
   - Sincronizar la duración de la animación con la del audio
   - Usar Duration(milliseconds: 800) para ambas

4. MANEJO MEMORIA:
   - Los cofres son PositionComponent: Flame maneja memoria
   - Los Dialogs con RewardCard: Navegate.pop() cuando cierres
   - LottieComponent: Se desasigna automáticamente

5. TESTEO:
   - Simular toques en diferentes posiciones
   - Verificar que _clickInProgress impida clicks dobles
   - Probar en múltiples dispositivos (tamaños diferentes)

6. PERSONALIZACIÓN FUTURA:
   - Añadir animación de caída del cofre
   - Efectos de partículas (confetti) al abrirse
   - Sonido de dinero al aparecer la carta
   - Vibración móvil (haptics) al abrir
*/
