import 'package:flame/game.dart';
import 'components/combat_game_screen.dart';

/// Juego Flame principal con sistema de combate integrado
class CombatGame extends FlameGame {
  /// Pantalla principal de juego
  late CombatGameScreen gameScreen;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Crear pantalla de juego
    gameScreen = CombatGameScreen()
      ..size = size
      ..position = Vector2.zero();

    add(gameScreen);
  }

  /// Pausa el juego
  void pauseGame() {
    pauseEngine();
    gameScreen.pauseCombat();
  }

  /// Reanuda el juego
  void resumeGame() {
    resumeEngine();
    gameScreen.resumeCombat();
  }

  /// Reinicia el juego
  void restartGame() {
    gameScreen.restartCombat();
  }
}
