import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game_logic/game_state.dart';
import '../../game_logic/reward_system.dart';

/// Overlay de Recompensas Post-Partida
///
/// Mostrado cuando:
/// - Termina la partida (sin revive o después de declinar revive)
///
/// UI:
/// - Monedas obtenidas
/// - Gemas obtenidas
/// - Estadísticas (enemigos, daño, tiempo)
/// - Botón "x2 Recompensa (ver anuncio)"
/// - Botón "Continuar / Volver al menú"
class RewardOverlay extends StatefulWidget {
  final RewardSystem rewardSystem;
  final VoidCallback onClose;

  const RewardOverlay({
    Key? key,
    required this.rewardSystem,
    required this.onClose,
  }) : super(key: key);

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isDoubleRewardAnimating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Animar duplicación de recompensas
  void _animateDoubleReward() {
    setState(() => _isDoubleRewardAnimating = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isDoubleRewardAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateManager>(
      builder: (context, gameState, _) {
        final stats = widget.rewardSystem.getRunStats();
        final canDouble = widget.rewardSystem.canDoubleRewards();

        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.97),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.90,
                  maxHeight: MediaQuery.of(context).size.height * 0.80,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🎉 TÍTULO
                      const Text(
                        '¡RECOMPENSAS!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                          shadows: [
                            Shadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // 💰 MONEDAS
                      _buildRewardCard(
                        icon: Icons.attach_money,
                        label: 'Monedas',
                        amount: stats['coins'].toString(),
                        color: const Color(0xFFFFD700),
                        isAnimating: _isDoubleRewardAnimating,
                      ),

                      const SizedBox(height: 8),

                      // 💎 GEMAS
                      _buildRewardCard(
                        icon: Icons.diamond,
                        label: 'Gemas',
                        amount: stats['gems'].toString(),
                        color: const Color(0xFF00D4FF),
                        isAnimating: _isDoubleRewardAnimating,
                      ),

                      const SizedBox(height: 12),

                      // 📊 ESTADÍSTICAS
                      _buildStatsSection(stats),

                      const SizedBox(height: 16),

                      // 🎁 BOTÓN DUPLICAR (si está disponible)
                      if (canDouble) ...[
                        ScaleTransition(
                          scale: _isDoubleRewardAnimating
                              ? Tween<double>(begin: 1.0, end: 1.15)
                                  .animate(_animationController)
                              : AlwaysStoppedAnimation(1.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _animateDoubleReward();
                              widget.rewardSystem.attemptDoubleReward();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFFFF6B00),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.tv, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'x2 Recompensa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),
                      ] else if (gameState.rewardMultiplier > 1) ...[
                        // Mostrar que las recompensas ya fueron duplicadas
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A4E2A),
                            border: Border.all(
                              color: const Color(0xFF00FF00),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF00FF00),
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Recompensas duplicadas ✓',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00FF00),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),
                      ],

                      // 👉 BOTÓN CONTINUAR
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _animationController.reverse().then((_) {
                              widget.onClose();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AA00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 6,
                            shadowColor: const Color(0xFF00AA00),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  /// Widget para mostrar cada recompensa
  Widget _buildRewardCard({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
    required bool isAnimating,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isAnimating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B00)),
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }

  /// Widget para mostrar estadísticas
  Widget _buildStatsSection(Map<String, dynamic> stats) {
    final timeMinutes = (stats['timePlayedSeconds'] as int) ~/ 60;
    final timeSeconds = (stats['timePlayedSeconds'] as int) % 60;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          _buildStatRow(
            '⚔️ Enemigos derrotados',
            '${stats['enemiesDefeated']}',
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            '💢 Daño total',
            '${stats['totalDamage']}',
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            '⏱️ Tiempo jugado',
            '$timeMinutes:${timeSeconds.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    );
  }

  /// Fila individual de estadística
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
