import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/paleto_game.dart';
import '../controllers/economy_controller.dart';
import 'retro_style.dart';

class WaveClearOverlay extends StatelessWidget {
  final PaletoGame game;

  const WaveClearOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final eco = context.read<EconomyController>();

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: RetroStyle.box(color: RetroStyle.background),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'OLEADA ${game.currentWave - 1} SUPERADA!',
                style: RetroStyle.font(color: Colors.yellowAccent, size: 20),
                textAlign: TextAlign.center,
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 800.ms),
              const SizedBox(height: 20),
              
              Text(
                '!Buen trabajo! ?Que deseas hacer?',
                style: RetroStyle.font(color: Colors.white, size: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              GestureDetector(
                onTap: () {
                  // Guardar progreso y continuar
                  eco.saveProgress(); 
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
                      style: RetroStyle.font(color: RetroStyle.textDark, size: 12),
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1.5.seconds),
              
              const SizedBox(height: 16),

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
                      style: RetroStyle.font(color: RetroStyle.textDark, size: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: -1.0, end: 0.0, curve: Curves.easeOutBack, duration: 600.ms),
      ),
    );
  }
}
