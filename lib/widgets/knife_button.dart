import 'package:flutter/material.dart';

/// Widget del boton principal del cuchillo
/// Muestra un cuchillo que el jugador puede presionar
class KnifeButton extends StatefulWidget {
  final VoidCallback onTap;
  final double scale;

  const KnifeButton({
    super.key,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  State<KnifeButton> createState() => _KnifeButtonState();
}

class _KnifeButtonState extends State<KnifeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    widget.onTap();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * widget.scale,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
                boxShadow: [
                  BoxShadow(
                    color: _isPressed 
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.3),
                    blurRadius: _isPressed ? 15 : 20,
                    spreadRadius: _isPressed ? 2 : 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.local_dining,
                  size: 100,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
