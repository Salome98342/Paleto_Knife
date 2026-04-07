import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/combat_game.dart';

/// Pantalla de prueba del sistema de combate completo
class CombatTestScreen extends StatefulWidget {
  const CombatTestScreen({Key? key}) : super(key: key);

  @override
  State<CombatTestScreen> createState() => _CombatTestScreenState();
}

class _CombatTestScreenState extends State<CombatTestScreen> {
  late CombatGame game;

  @override
  void initState() {
    super.initState();
    game = CombatGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('🎮 Sistema de Combate - Demo'),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: Stack(
        children: [
          // Juego Flame
          GameWidget(game: game),

          // Botones de control (esquina inferior derecha)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.extended(
                  onPressed: () => game.pauseGame(),
                  label: const Text('⏸ Pausar'),
                  backgroundColor: Colors.orange,
                  heroTag: 'pause',
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () => game.resumeGame(),
                  label: const Text('▶ Reanudar'),
                  backgroundColor: Colors.green,
                  heroTag: 'resume',
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () => game.restartGame(),
                  label: const Text('🔄 Reiniciar'),
                  backgroundColor: Colors.red,
                  heroTag: 'restart',
                ),
              ],
            ),
          ),

          // Info panel (esquina inferior izquierda)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 CONTROLES',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Click en enemigos = Daño\n'
                    '• Click en boss = Daño\n'
                    '• Botones = Control juego',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🎯 OBJETIVO',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Derrota 3 oleadas y\n'
                    'luego al boss en 3 fases',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    game.onDetach();
    super.dispose();
  }
}
