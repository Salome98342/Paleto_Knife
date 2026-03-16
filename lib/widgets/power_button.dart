import 'package:flutter/material.dart';

/// Widget del botón de poder especial
class PowerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final bool isOnCooldown;
  final double cooldownProgress; // 0.0 a 1.0
  final double activeDuration; // Duración restante del poder activo
  final double? powerDuration; // Duración total del poder

  const PowerButton({
    super.key,
    required this.onPressed,
    required this.isActive,
    required this.isOnCooldown,
    required this.cooldownProgress,
    this.activeDuration = 0,
    this.powerDuration,
  });

  @override
  Widget build(BuildContext context) {
    final bool canUse = !isOnCooldown && !isActive;
    
    return GestureDetector(
      onTap: canUse ? onPressed : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Indicador de progreso circular
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: isActive && powerDuration != null
                  ? activeDuration / powerDuration!
                  : (isOnCooldown ? 1 - cooldownProgress : 1.0),
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive
                    ? Colors.green
                    : (isOnCooldown ? Colors.orange : Colors.purple),
              ),
            ),
          ),
          
          // Botón principal
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isActive
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : (canUse
                        ? [Colors.purple.shade400, Colors.purple.shade600]
                        : [Colors.grey.shade400, Colors.grey.shade600]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? Colors.green : Colors.purple)
                      .withOpacity(canUse ? 0.4 : 0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              isActive ? Icons.flash_on : Icons.bolt,
              color: Colors.white,
              size: 36,
            ),
          ),
          
          // Texto de estado
          if (isOnCooldown && !isActive)
            Positioned(
              bottom: -25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${((1 - cooldownProgress) * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          if (isActive)
            Positioned(
              bottom: -25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
