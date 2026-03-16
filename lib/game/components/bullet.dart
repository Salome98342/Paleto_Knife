import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../paleto_game.dart';

/// Bullet/Projectile component
/// 
/// Features:
/// - Moves in a specific direction
/// - Auto-destroys when off-screen
/// - Collision detection ready
class BulletComponent extends SpriteComponent
    with HasGameReference<PaletoGame> {
  
  final Vector2 direction;
  final double speed;

  BulletComponent({
    required Vector2 position,
    required this.direction,
    this.speed = 500.0,
  }) : super(
          position: position,
          size: Vector2(20, 40),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create placeholder sprite
    _createPlaceholder();

    // Configurar prioridad de renderizado
    priority = 5;
  }

  /// Crea un placeholder visual cuando no hay sprites disponibles
  void _createPlaceholder() {
    final paint = Paint()..color = Colors.yellowAccent;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Dibujar un rectángulo amarillo como proyectil
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 20, 40),
      paint,
    );
    
    final picture = recorder.endRecording();
    final image = picture.toImageSync(20, 40);
    
    sprite = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Mover el proyectil en la dirección especificada
    position.add(direction.normalized() * speed * dt);

    // Destruir el proyectil si sale de la pantalla
    if (_isOutOfBounds()) {
      removeFromParent();
    }
  }

  /// Verifica si el proyectil está fuera de los límites de la pantalla
  bool _isOutOfBounds() {
    return position.x < -size.x ||
        position.x > game.size.x + size.x ||
        position.y < -size.y ||
        position.y > game.size.y + size.y;
  }
}
