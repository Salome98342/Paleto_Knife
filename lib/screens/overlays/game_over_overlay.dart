import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game_logic/game_state.dart';
import '../../game_logic/revive_system.dart';
import '../../ui/theme/paleto_colors.dart';
import '../../widgets/retro/retro_button.dart';

/// Overlay de Game Over
///
/// Mostrado cuando:
/// - El jugador muere
/// - Se ofrece revivir con anuncio
///
/// UI:
/// - Texto "¡GAME OVER!"
/// - Icono de corazón con vidas
/// - Botón "Revivir" (con icono de anuncio)
/// - Botón "No, gracias"
class GameOverOverlay extends StatefulWidget {
  final ReviveSystem reviveSystem;

  const GameOverOverlay({
    Key? key,
    required this.reviveSystem,
  }) : super(key: key);

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Countdown para revivir
  int _countdownSeconds = 5;
  late Future<void> _countdownFuture;

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Countdown BONUS (opcional)
    _startCountdown();
  }

  /// Iniciar countdown de 5 segundos
  void _startCountdown() {
    _countdownFuture = Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdownSeconds > 1) {
        setState(() => _countdownSeconds--);
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateManager>(
      builder: (context, gameState, _) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.95),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(
                    color: const Color(0xFFFF4444),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4444).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔥 TÍTULO
                      const Text(
                        '¡GAME OVER!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4444),
                          shadows: [
                            Shadow(
                              color: Color(0xFFFF4444),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // ❤️ ICONO + SALUD
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A4E),
                          border: Border.all(
                            color: const Color(0xFFFF4444),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Color(0xFFFF4444),
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'x${gameState.playerHealth}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🎬 BOTÓN REVIVIR
                      if (gameState.canRevive) ...[
                        SizedBox(
                          width: double.infinity,
                          child: RetroButton(
                            label: 'Revivir',
                            onPressed: () {
                              _animationController.reverse().then((_) {
                                widget.reviveSystem.attemptRevive();
                              });
                            },
                            baseColor: const Color(0xFF00D4FF),
                            lightBorder: const Color(0xFF69E8FF),
                            darkBorder: const Color(0xFF005A70),
                            icon: const Icon(Icons.play_circle, size: 18, color: Colors.black),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Countdown
                        Text(
                          'Revivir en: $_countdownSeconds s',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00D4FF),
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 12),
                    ],

                      // ❌ BOTÓN NO GRACIAS
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          label: 'No, gracias',
                          onPressed: () {
                            _animationController.reverse().then((_) {
                              Navigator.of(context).pop();
                              widget.reviveSystem.declineRevive();
                            });
                          },
                          baseColor: PaletoColors.btnNeutral,
                          lightBorder: PaletoColors.btnNeutralLt,
                          darkBorder: PaletoColors.btnNeutralDk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
