import 'package:flutter/material.dart';

/// Widget para mostrar sprites animados (sprite sheets)
class AnimatedSprite extends StatefulWidget {
  final String assetPath;
  final int frameCount; // Numero de frames en el sprite sheet
  final double frameWidth; // Ancho de cada frame en pixeles
  final double frameHeight; // Alto de cada frame en pixeles
  final double fps; // Frames por segundo
  final bool loop; // Si la animacion debe repetirse
  final double displayWidth; // Ancho de visualizacion
  final double displayHeight; // Alto de visualizacion

  const AnimatedSprite({
    super.key,
    required this.assetPath,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
    this.fps = 12,
    this.loop = true,
    this.displayWidth = 50,
    this.displayHeight = 60,
  });

  @override
  State<AnimatedSprite> createState() => _AnimatedSpriteState();
}

class _AnimatedSpriteState extends State<AnimatedSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();

    // Configurar el controller para la animacion
    final duration = Duration(
      milliseconds: (1000 / widget.fps * widget.frameCount).round(),
    );

    _controller = AnimationController(vsync: this, duration: duration);

    _controller.addListener(() {
      final newFrame =
          (_controller.value * widget.frameCount).floor() % widget.frameCount;
      if (newFrame != _currentFrame) {
        setState(() {
          _currentFrame = newFrame;
        });
      }
    });

    // Iniciar animacion
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Imagen total: frameCount * frameWidth de ancho
    // Queremos mostrar solo frameWidth de ancho, empezando en _currentFrame * frameWidth

    return ClipRect(
      child: SizedBox(
        width: widget.displayWidth,
        height: widget.displayHeight,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: widget.frameWidth.toDouble(),
            height: widget.frameHeight.toDouble(),
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(-_currentFrame * widget.frameWidth, 0),
                child: Image.asset(
                  widget.assetPath,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
