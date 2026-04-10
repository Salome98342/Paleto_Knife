import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/paleto_game.dart';
import '../controllers/economy_controller.dart';
import '../controllers/world_controller.dart';
import 'retro_style.dart';

class WaveClearOverlay extends StatelessWidget {
  final PaletoGame game;

  const WaveClearOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final eco = context.read<EconomyController>();
    final world = context.read<WorldController>();
    final recoveryPercentage = game.getWaveRecoveryPercentage();
    final treasures = game.waveRewards;

    // Actualizar progreso de liberación cuando se muestra este overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      world.addLiberation(world.selectedLocation.name, recoveryPercentage);
    });

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: RetroStyle.box(color: RetroStyle.background),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'OLEADA ${game.currentWave - 1} SUPERADA!',
                  style: RetroStyle.font(
                    color: Colors.yellowAccent,
                    size: 20,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.05, duration: 800.ms),
                const SizedBox(height: 20),

                // Progreso de recuperación
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: RetroStyle.box(color: Colors.grey.shade800),
                  child: Column(
                    children: [
                      Text(
                        'PROGRESO DE RECUPERACIÓN',
                        style: RetroStyle.font(
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              color: Colors.grey.shade900,
                            ),
                            child: LinearProgressIndicator(
                              value: recoveryPercentage / 100,
                              backgroundColor: Colors.grey.shade900,
                              valueColor: AlwaysStoppedAnimation(
                                recoveryPercentage > 80
                                    ? Colors.greenAccent
                                    : recoveryPercentage > 50
                                        ? Colors.yellowAccent
                                        : Colors.orangeAccent,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                '${recoveryPercentage.toStringAsFixed(1)}%',
                                style: RetroStyle.font(
                                  color: Colors.white,
                                  size: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recompensas de cofres
                if (treasures.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: RetroStyle.box(color: Colors.amber.shade900),
                    child: Column(
                      children: [
                        Text(
                          '💎 COFRES ABIERTOS',
                          style: RetroStyle.font(
                            color: Colors.yellowAccent,
                            size: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...treasures.map((reward) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                reward.title,
                                style: RetroStyle.font(
                                  color: Colors.white,
                                  size: 9,
                                ),
                              ),
                              Text(
                                '+${reward.gemAmount} 💎',
                                style: RetroStyle.font(
                                  color: Colors.amber,
                                  size: 9,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                if (treasures.isNotEmpty) const SizedBox(height: 16),

                Text(
                  '!Buen trabajo! ¿Qué deseas hacer?',
                  style: RetroStyle.font(color: Colors.white, size: 10),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Botón continuar
                GestureDetector(
                  onTap: () {
                    // Guardar progreso y continuar
                    eco.saveProgress();
                    // Actualizar progreso de recuperación en el mapa
                    final world = context.read<WorldController>();
                    world.updateRecoveryProgress(game.locationData.name, recoveryPercentage);
                    game.overlays.remove('WaveClear');
                    game.resumeEngine();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: RetroStyle.box(color: RetroStyle.accent),
                    child: Center(
                      child: Text(
                        'GUARDAR Y CONTINUAR',
                        style: RetroStyle.font(
                          color: RetroStyle.textDark,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 1.5.seconds),

                const SizedBox(height: 16),

                // Botón salir
                GestureDetector(
                  onTap: () {
                    // Guardar, remover overlay y salir
                    eco.saveProgress();
                    eco.resetRun();
                    game.overlays.remove('WaveClear');
                    game.resumeEngine();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: RetroStyle.box(color: Colors.grey.shade400),
                    child: Center(
                      child: Text(
                        'SALIR AL MAPA',
                        style: RetroStyle.font(
                          color: RetroStyle.textDark,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .slideY(
              begin: -1.0,
              end: 0.0,
              curve: Curves.easeOutBack,
              duration: 600.ms,
            ),
      ),
    );
  }
}
