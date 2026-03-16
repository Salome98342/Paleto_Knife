import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'paleto_game.dart';

/// Pantalla del juego que renderiza el FlameGame
/// 
/// Esta pantalla envuelve el GameWidget de Flame y maneja
/// la integración con Flutter
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PaletoGame _game;

  @override
  void initState() {
    super.initState();
    _game = PaletoGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // GameWidget renderiza el juego Flame
            GameWidget(
              game: _game,
              loadingBuilder: (context) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar el juego',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botón de pausa/volver en la esquina superior izquierda
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
