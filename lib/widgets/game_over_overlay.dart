import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/paleto_game.dart';
import '../controllers/economy_controller.dart';
import 'retro_style.dart';

class GameOverOverlay extends StatelessWidget {
  final PaletoGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final eco = context.watch<EconomyController>();

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
                'GAME OVER',
                style: RetroStyle.font(color: RetroStyle.primary, size: 24),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.1, duration: 600.ms),
              const SizedBox(height: 20),
              
              Text(
                'Wave alcanzada: ${eco.currentWave}',
                style: RetroStyle.font(color: Colors.white, size: 10),
              ),
              const SizedBox(height: 30),
              
              GestureDetector(
                onTap: () {
                  eco.resetRun();
                  game.resetGame();
                  game.overlays.remove('GameOver');
                  game.resumeEngine();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: RetroStyle.box(color: RetroStyle.accent),
                  child: Center(
                    child: Text(
                      'REINTENTAR',
                      style: RetroStyle.font(color: RetroStyle.textDark, size: 14),
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1.seconds),
            ],
          ),
        ).animate().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutBack, duration: 600.ms),
      ),
    );
  }
}
