import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'retro_style.dart';

class PauseMenuOverlay extends StatelessWidget {
  final dynamic game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: RetroStyle.box(color: RetroStyle.panel),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSA',
                style: RetroStyle.font(color: RetroStyle.textDark, size: 24),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: -0.1, end: 0.1, duration: 1.seconds),
              const SizedBox(height: 32),
              
              GestureDetector(
                onTap: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseMenu');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: RetroStyle.box(color: RetroStyle.panel),
                  child: Center(
                    child: Text(
                      'CONTINUAR',
                      style: RetroStyle.font(size: 16, color: RetroStyle.textDark),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () {
                  game.resumeEngine();
                  game.overlays.remove('PauseMenu');
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: RetroStyle.box(color: RetroStyle.primary),
                  child: Center(
                    child: Text(
                      'SALIR',
                      style: RetroStyle.font(size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
