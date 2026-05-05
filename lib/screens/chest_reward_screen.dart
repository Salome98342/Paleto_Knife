import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../game/components/chest_component.dart';
import '../widgets/reward_card.dart';
import '../main.dart';
import '../controllers/chef_controller.dart';
import 'dart:math';

/// Pantalla de recompensa con cofre interactivo (usando Flame)
/// Se muestra después de ganar un combate o comprar un cofre en la tienda
class ChestRewardScreen extends StatefulWidget {
  // Recompensas de combate
  final int? coinsReward;
  final int? gemsReward;
  final int? itemsReward;
  
  // Recompensas de gacha (tienda) - puede ser uno o varios
  final RollResult? gachaResult;
  final List<RollResult>? gachaResults;
  final bool isGachaReward;
  
  final VoidCallback onRewardAccepted;

  const ChestRewardScreen({
    super.key,
    this.coinsReward,
    this.gemsReward,
    this.itemsReward,
    this.gachaResult,
    this.gachaResults,
    this.isGachaReward = false,
    required this.onRewardAccepted,
  });

  @override
  State<ChestRewardScreen> createState() => _ChestRewardScreenState();
}

class _ChestRewardScreenState extends State<ChestRewardScreen> {
  late _ChestGameInstance gameInstance;
  int _currentGachaIndex = 0;

  @override
  void initState() {
    super.initState();
    gameInstance = _ChestGameInstance(
      coinsReward: widget.coinsReward ?? 0,
      gemsReward: widget.gemsReward ?? 0,
      itemsReward: widget.itemsReward ?? 0,
      onChestOpened: _showRewardCard,
    );
  }

  void _showRewardCard() {
    // Usar Future.microtask para evitar build durante construcción
    Future.microtask(() {
      if (!mounted) return;
      
      if (widget.isGachaReward && (widget.gachaResults != null && widget.gachaResults!.isNotEmpty)) {
        _showGachaReward();
      } else {
        _showCombatReward();
      }
    });
  }

  void _showCombatReward() {
    if (!mounted) return;
    
    final rewardData = _selectReward(
      coins: widget.coinsReward ?? 0,
      gems: widget.gemsReward ?? 0,
      items: widget.itemsReward ?? 0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        elevation: 0,
        child: RewardCard(
          rewardData: rewardData,
          onDismiss: () {
            if (mounted) {
              Navigator.pop(ctx);
              // Usar Future para evitar llamadas durante frame
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) widget.onRewardAccepted();
              });
            }
          },
          animationDuration: const Duration(milliseconds: 800),
        ),
      ),
    );
  }

  void _showGachaReward() {
    if (!mounted) return;
    
    final results = widget.gachaResults!;
    final result = results[_currentGachaIndex];
    final entity = result.entity;
    final remainingCount = results.length - _currentGachaIndex - 1;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        elevation: 0,
        child: Stack(
          children: [
            RewardCard.fromGacha(
              gachaEntity: entity,
              isNew: result.isNew,
              tokensGranted: result.tokensGranted,
              onDismiss: () {
                if (mounted) {
                  Navigator.pop(ctx);
                  
                  // Si hay más resultados, mostrar el siguiente
                  if (remainingCount > 0) {
                    _currentGachaIndex++;
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) _showGachaReward();
                    });
                  } else {
                    // Todos los resultados mostrados
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) widget.onRewardAccepted();
                    });
                  }
                }
              },
              animationDuration: const Duration(milliseconds: 800),
            ),
            
            // Indicador de progreso
            if (results.length > 1)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    '${_currentGachaIndex + 1}/${results.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  RewardData _selectReward({
    required int coins,
    required int gems,
    required int items,
  }) {
    // Determinar cuál es la recompensa principal
    final rewards = [
      ('Monedas', coins, Icons.monetization_on, const Color(0xFFFFD700)),
      ('Gemas', gems, Icons.diamond, const Color(0xFF3399FF)),
      ('Items', items, Icons.card_giftcard, const Color(0xFFFF6B00)),
    ];

    rewards.sort((a, b) => b.$2.compareTo(a.$2));
    final mainReward = rewards.first;

    return RewardData(
      title: '${mainReward.$1}: +${mainReward.$2}',
      description: _buildDescriptionFromRewards(coins, gems, items),
      icon: mainReward.$3,
      accentColor: mainReward.$4,
      rarityLevel: _calculateRarity(coins, gems, items),
    );
  }

  String _buildDescriptionFromRewards(int coins, int gems, int items) {
    final parts = <String>[];
    if (coins > 0) parts.add('+$coins monedas');
    if (gems > 0) parts.add('+$gems gemas');
    if (items > 0) parts.add('+$items items');
    return parts.join('\n');
  }

  int _calculateRarity(int coins, int gems, int items) {
    final total = coins + gems + (items * 50);
    if (total > 1000) return 3; // Épico
    if (total > 500) return 2; // Raro
    return 1; // Común
  }

  @override
  void dispose() {
    gameInstance.removeFromParent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO CON PATRÓN RETRO
          Container(
            color: const Color(0xFF0D0D1A), // Fondo base oscuro
            child: Stack(
              children: [
                // Patrón de píxeles
                CustomPaint(
                  painter: _PixelPatternPainter(),
                  size: Size.infinite,
                ),
                
                // Efecto de gradiente sutil
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1a1a2e).withOpacity(0.5),
                        const Color(0xFF0D0D1A).withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // JUEGO CON EL COFRE
          GestureDetector(
            onTap: () {
              print('[ChestRewardScreen.GestureDetector] TAP DETECTADO EN EL JUEGO');
              gameInstance.chestComponent.onTap();
            },
            child: GameWidget(
              game: gameInstance,
            ),
          ),
          
          // INTERFAZ SUPERIOR
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // TÍTULO CON EFECTOS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    '⚔️ COFRE DE RECOMPENSAS ⚔️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF6B00).withOpacity(0.8),
                          blurRadius: 8,
                        ),
                        const Shadow(
                          color: Color(0xFF000000),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 1500.ms, color: const Color(0xFFFFD700)),
                ),
              ],
            ),
          ),
          
          // CONTROLES INFERIORES
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // INSTRUCCIÓN CON ANIMACIÓN
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                      color: Colors.black45,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '✨ TOCA EL COFRE PARA ABRIR ✨',
                          style: TextStyle(
                            color: const Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 800.ms),
                        const SizedBox(height: 8),
                        Text(
                          'O PRESIONA EL BOTÓN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // BOTÓN CON ESTILO RETRO
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFFD700), width: 3),
                      color: const Color(0xFFFF6B00),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('[ChestRewardScreen.Button] Botón presionado');
                          gameInstance.chestComponent.onTap();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          child: Text(
                            '▶ ABRIR COFRE ◀',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(end: 1.08, duration: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pintor para patrón de píxeles en fondo
class _PixelPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;
    
    const pixelSize = 16.0;
    
    for (double x = 0; x < size.width; x += pixelSize) {
      for (double y = 0; y < size.height; y += pixelSize) {
        if ((x.toInt() + y.toInt()) % 32 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, pixelSize - 1, pixelSize - 1),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPatternPainter oldDelegate) => false;
}

/// Instancia del juego Flame que contiene el cofre
class _ChestGameInstance extends FlameGame {
  late ChestComponent chestComponent;
  final int coinsReward;
  final int gemsReward;
  final int itemsReward;
  final VoidCallback onChestOpened;

  _ChestGameInstance({
    required this.coinsReward,
    required this.gemsReward,
    required this.itemsReward,
    required this.onChestOpened,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    print('[ChestGame.onLoad] Iniciando juego. Tamaño: $size');

    // Crear el cofre en el centro de la pantalla
    chestComponent = ChestComponent(
      position: size / 2,
      size: Vector2(100, 85),
      onChestOpened: onChestOpened,
    );

    add(chestComponent);
    print('[ChestGame.onLoad] Cofre creado en: ${chestComponent.position}');
  }

  @override
  void onTapDown(TapDownEvent info) {
    print('[ChestGame.onTapDown] Tap recibido en: ${info.localPosition}');
    print('[ChestGame.onTapDown] Posición cofre: ${chestComponent.position}, Tamaño: ${chestComponent.size}');
    
    // Permitir tap en cualquier lado para este debug
    print('[ChestGame.onTapDown] ¡Llamando onTap al cofre!');
    chestComponent.onTap();
  }

  @override
  void onTapCancel(TapCancelEvent info) {
    print('[ChestGame.onTapCancel] Tap cancelado');
  }

  @override
  void onTapUp(TapUpEvent info) {
    print('[ChestGame.onTapUp] Tap liberado en: ${info.localPosition}');
  }
}
