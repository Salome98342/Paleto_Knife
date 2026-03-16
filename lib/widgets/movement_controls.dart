import 'package:flutter/material.dart';

/// Widget de controles de movimiento horizontal
class MovementControls extends StatelessWidget {
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onStopMovement;

  const MovementControls({
    super.key,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onStopMovement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón izquierda
        GestureDetector(
          onTapDown: (_) => onMoveLeft(),
          onTapUp: (_) => onStopMovement(),
          onTapCancel: onStopMovement,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        
        // Espacio en el medio
        const SizedBox(width: 80),
        
        // Botón derecha
        GestureDetector(
          onTapDown: (_) => onMoveRight(),
          onTapUp: (_) => onStopMovement(),
          onTapCancel: onStopMovement,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}
