import 'package:flutter/material.dart';
import '../models/upgrade.dart';

/// Widget que muestra una tarjeta de mejora
/// Incluye nombre, descripcion, nivel y costo
class UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final double playerPoints;
  final VoidCallback onBuy;

  const UpgradeCard({
    super.key,
    required this.upgrade,
    required this.playerPoints,
    required this.onBuy,
  });

  /// Determina si el jugador puede comprar esta mejora
  bool get canAfford => playerPoints >= upgrade.currentCost;

  /// Obtiene el color del borde segun el tipo de upgrade
  Color _getBorderColor() {
    switch (upgrade.type) {
      case UpgradeType.clickPower:
        return Colors.blue;
      case UpgradeType.autoClicker:
        return Colors.green;
      case UpgradeType.multiplier:
        return Colors.purple;
    }
  }

  /// Obtiene el icono segun el tipo de upgrade
  IconData _getIcon() {
    switch (upgrade.type) {
      case UpgradeType.clickPower:
        return Icons.touch_app;
      case UpgradeType.autoClicker:
        return Icons.autorenew;
      case UpgradeType.multiplier:
        return Icons.trending_up;
    }
  }

  /// Formatea numeros grandes de manera legible
  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: canAfford ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford ? _getBorderColor() : Colors.grey.shade300,
          width: canAfford ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: canAfford ? onBuy : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getBorderColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getIcon(), color: _getBorderColor(), size: 30),
              ),
              const SizedBox(width: 16),

              // Informacion
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      upgrade.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: canAfford
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nivel: ${upgrade.level}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getBorderColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Costo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatNumber(upgrade.currentCost),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    canAfford ? 'COMPRAR' : 'No disponible',
                    style: TextStyle(
                      fontSize: 10,
                      color: canAfford ? Colors.green.shade700 : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
