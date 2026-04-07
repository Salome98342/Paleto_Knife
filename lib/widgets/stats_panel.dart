import 'package:flutter/material.dart';

/// Widget que muestra las estadisticas principales del jugador
class StatsPanel extends StatelessWidget {
  final double points;
  final double pointsPerClick;
  final double pointsPerSecond;
  final double globalMultiplier;
  final int totalClicks;

  const StatsPanel({
    super.key,
    required this.points,
    required this.pointsPerClick,
    required this.pointsPerSecond,
    required this.globalMultiplier,
    required this.totalClicks,
  });

  /// Formatea numeros grandes de manera legible
  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Puntos principales
            Text(
              'Puntos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatNumber(points),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estadisticas secundarias
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.touch_app,
                  label: 'Por click',
                  value: _formatNumber(pointsPerClick),
                ),
                _StatItem(
                  icon: Icons.timer,
                  label: 'Por segundo',
                  value: _formatNumber(pointsPerSecond),
                ),
                _StatItem(
                  icon: Icons.trending_up,
                  label: 'Multiplicador',
                  value: 'x${globalMultiplier.toStringAsFixed(1)}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total de clicks
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total de clicks: ${_formatNumber(totalClicks.toDouble())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget auxiliar para mostrar una estadistica individual
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 2),
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
