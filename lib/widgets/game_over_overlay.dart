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
              const SizedBox(height: 20),

              // Ganancias de la partida
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  children: [
                    Text("RECOMPENSAS DE LA RUN", style: RetroStyle.font(color: Colors.white, size: 8)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         Row(
                           children: [
                             const Icon(Icons.monetization_on, color: Colors.yellow, size: 16)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(end: 1.2, duration: 400.ms),
                             const SizedBox(width: 4),
                             TweenAnimationBuilder<int>(
                               tween: IntTween(begin: 0, end: eco.sessionCoins),
                               duration: const Duration(seconds: 2),
                               curve: Curves.easeOutQuart,
                               builder: (context, value, child) {
                                  return Text("+$value", style: RetroStyle.font(color: Colors.yellow, size: 12));
                               }
                             ),
                           ],
                         ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.5),
                         if (eco.sessionGems > 0)
                           Row(
                             children: [
                               const Icon(Icons.diamond, color: Colors.purpleAccent, size: 16)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(end: 1.2, duration: 400.ms),
                               const SizedBox(width: 4),
                               TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: eco.sessionGems),
                                duration: const Duration(seconds: 2),
                                curve: Curves.easeOutQuart,
                                builder: (context, value, child) {
                                   return Text("+$value", style: RetroStyle.font(color: Colors.purpleAccent, size: 12));
                                }
                               ),
                             ],
                           ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideX(begin: 0.5),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              GestureDetector(
                onTap: () {
                  eco.resetRun();
                  game.resetGame();
                  game.overlays.remove('GameOver');
                  game.resumeEngine();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: RetroStyle.box(color: RetroStyle.accent),
                  child: Center(
                    child: Text(
                      'REINTENTAR',
                      style: RetroStyle.font(color: RetroStyle.textDark, size: 14),
                    ),
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1.5.seconds),
              
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  eco.resetRun(); // Para que asegure reiniciarla
                  game.overlays.remove('GameOver');
                  game.resumeEngine();
                  // Navegar de vuelta al menú, se asume pop si están empujando la ruta o Navigator.of(context).pushReplacement
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: RetroStyle.box(color: Colors.grey.shade400),
                  child: Center(
                    child: Text(
                      'SALIR AL MENÚ',
                      style: RetroStyle.font(color: RetroStyle.textDark, size: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 1.0, end: 0.0, curve: Curves.easeOutBack, duration: 600.ms),
      ),
    );
  }
}
