import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/combat_controller.dart';
import '../controllers/game_controller.dart';
import '../main.dart';
import '../models/element_type.dart';
import '../widgets/combat_arena.dart';
import '../widgets/power_button.dart';
import '../services/audio_service.dart';

import 'settings_dialog.dart';

/// Pantalla principal del modo combate
class CombatScreen extends StatefulWidget {
  final GameController gameController;

  const CombatScreen({
    super.key,
    required this.gameController,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  late CombatController _combatController;

  @override
  void initState() {
    super.initState();
    _combatController = CombatController();
    
    // Inicializar despues del primer frame para tener el tamano correcto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _combatController.initialize(size, gameController: widget.gameController);
      _combatController.addListener(_onCombatStateChanged);
    });
  }

  void _onCombatStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _combatController.removeListener(_onCombatStateChanged);
    _combatController.dispose();
    super.dispose();
  }

  void _showWorldInfo() {
    final world = _combatController.worldManager.currentWorld;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(world.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Niveles: ${world.startLevel}-${world.endLevel}'),
            const SizedBox(height: 8),
            Text(world.description),
            const SizedBox(height: 16),
            Text('Dificultad: x${world.difficultyMultiplier.toStringAsFixed(1)}'),
            Text('Recompensas: x${world.rewardMultiplier.toStringAsFixed(1)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  String _getElementName(ElementType element) {
    switch (element) {
      case ElementType.fire:
        return 'FUEGO';
      case ElementType.water:
        return 'AGUA';
      case ElementType.earth:
        return 'TIERRA';
      case ElementType.master:
        return 'MAESTRO';
      case ElementType.neutral:
        return '';
    }
  }
  
  bool _hasElementalAdvantage(ElementType enemyElement) {
    // Por ahora retorna false. En el futuro aqui se podria calcular
    // la ventaja elemental basandose en el elemento del jugador vs enemigo
    // Por ejemplo: Fuego > Tierra > Agua > Fuego
    return false; // TODO: implementar sistema de ventaja elemental del jugador
  }

  @override
  Widget build(BuildContext context) {
    if (!_combatController.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final player = _combatController.player;
    final enemy = _combatController.enemy;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Movimiento libre en la arena
        onPanStart: _combatController.isPaused ? null : (details) {
          _combatController.movePlayerToPosition(details.localPosition);
        },
        onPanUpdate: _combatController.isPaused ? null : (details) {
          _combatController.handlePlayerDrag(details);
        },
        // Tap para disparar poder (alternativa al boton)
        onDoubleTap: _combatController.isPaused ? null : () {
          _combatController.activatePower();
        },
        child: Stack(
          children: [
          // Arena de combate (fondo)
          Positioned.fill(
            child: CombatArena(
              player: player,
              enemy: enemy,
              projectiles: _combatController.projectiles,
              isPaused: _combatController.isPaused,
            ),
          ),
          
          // HUD Superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(), // Quitamos el marco gris opaco
                child: Column(
                  children: [
                  // Informacion del mundo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Info del mundo
                      GestureDetector(
                        onTap: _showWorldInfo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: PixelColors.accent, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.public,
                                color: PixelColors.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'LVL ${_combatController.worldManager.currentLevel}',
                                style: GoogleFonts.pressStart2p(
                                  color: PixelColors.accent,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: PixelColors.accent, width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: PixelColors.accent,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _combatController.currentGold.toStringAsFixed(0),
                                  style: GoogleFonts.pressStart2p(
                                    color: PixelColors.accent,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Boton de ajustes (Musica)
                          GestureDetector(
                            onTap: () {
                              _combatController.pause();
                              AudioService.instance.playSettingsMusic();
                              showDialog(
                                context: context,
                                builder: (_) => const SettingsDialog(),
                              ).then((_) {
                                _combatController.resume();
                                AudioService.instance.playGameplayMusic();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: PixelColors.border, width: 2),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: PixelColors.text,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Boton de pausa
                          GestureDetector(
                            onTap: () {
                              if (_combatController.isPaused) {
                                _combatController.resume();
                              } else {
                                _combatController.pause();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: PixelColors.border, width: 2),
                              ),
                              child: Icon(
                                _combatController.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: PixelColors.text,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                                    const SizedBox(height: 12),
                  
                  // Informacion del elemento del enemigo
                  if (enemy.isAlive)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Color(enemy.element.getColor()).withOpacity(0.75),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji del elemento
                          Text(
                            enemy.element.getEmoji(),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          
                          // Nombre del elemento
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getElementName(enemy.element),
                                style: GoogleFonts.pressStart2p(
                                  color: Color(enemy.element.getColor()),
                                  fontSize: 6.5,
                                ),
                              ),
                              if (enemy.isBoss)
                                Row(
                                  children: const [
                                    Icon(Icons.shield, color: Colors.amber, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'x3 Vida',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Indicador de ventaja elemental (si aplica)
                          if (_hasElementalAdvantage(enemy.element))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green, width: 1),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.trending_up, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '+25%',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                                    const Spacer(),
                  
                  // Boton de poder especial e instrucciones
                  Column(
                    children: [
                      // Boton de poder especial
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PowerButton(
                            onPressed: () => _combatController.activatePower(),
                            isActive: player.powerActive,
                            isOnCooldown: player.powerCooldownRemaining > 0,
                            cooldownProgress: player.powerCooldownRemaining /
                                player.powerCooldown,
                            activeDuration: player.powerRemainingTime,
                            powerDuration: player.powerDuration,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Overlay de pausa
          if (_combatController.isPaused)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PAUSA',
                        style: GoogleFonts.pressStart2p(
                          color: PixelColors.accent,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => _combatController.resume(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Continuar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _combatController.reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home),
                        label: const Text('Menu Principal'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Game Over overlay
          if (!player.isAlive)
            Positioned.fill(
              child: Container(
                color: Colors.red.shade900.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GAME OVER',
                        style: GoogleFonts.pressStart2p(
                          color: PixelColors.text,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => _combatController.reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Victoria overlay (se muestra al derrotar un boss)
          if (!enemy.isAlive && _combatController.worldManager.isCurrentLevelBoss)
            Positioned.fill(
              child: Container(
                color: Colors.green.shade900.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VICTORIA',
                        style: GoogleFonts.pressStart2p(
                          color: PixelColors.accent,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ENEMIGO DERROTADO',
                        style: GoogleFonts.pressStart2p(
                          color: PixelColors.text,
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'SIGUIENTE MUNDO...',
                        style: GoogleFonts.pressStart2p(
                          color: PixelColors.textDim,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
        ],
      ),
      ),
    );
  }
}
