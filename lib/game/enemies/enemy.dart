import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../paleto_game.dart';

/// Enemy component with simple sprite rendering
/// 
/// Features:
/// - Autonomous movement
/// - Collision detection ready
/// - Different behavior patterns
class EnemyComponent extends SpriteComponent
    with HasGameReference<PaletoGame> {
  
  final double moveSpeed;
  final String enemyType;
  
  // Dirección de movimiento
  Vector2 velocity;

  EnemyComponent({
    required Vector2 position,
    this.moveSpeed = 100.0,
    this.enemyType = 'basic',
  })  : velocity = Vector2.zero(),
        super(
          position: position,
          size: Vector2(80, 80),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create placeholder sprite
    _createPlaceholder();

    // Inicializar movimiento aleatorio
    _initializeMovement();

    // Configurar prioridad de renderizado
    priority = 8;
  }

  /// Crea un placeholder visual cuando no hay sprites disponibles
  void _createPlaceholder() {
    final paint = Paint()..color = Colors.red;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Dibujar un círculo rojo como enemigo
    canvas.drawCircle(
      const Offset(40, 40),
      40,
      paint,
    );
    
    final picture = recorder.endRecording();
    final image = picture.toImageSync(80, 80);
    
    sprite = Sprite(image);
  }

  /// Inicializa el movimiento del enemigo con dirección aleatoria
  void _initializeMovement() {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    velocity = Vector2(cos(angle), sin(angle)) * moveSpeed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Mover el enemigo
    position.add(velocity * dt);

    // Rebotar en los bordes de la pantalla
    _bounceOffWalls();
  }

  /// Hace que el enemigo rebote en los bordes de la pantalla
  void _bounceOffWalls() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    // Rebotar en los bordes horizontales
    if (position.x < halfWidth || position.x > game.size.x - halfWidth) {
      velocity.x = -velocity.x;
      // Ajustar posición para evitar que se quede atascado
      position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
    }

    // Rebotar en los bordes verticales
    if (position.y < halfHeight || position.y > game.size.y - halfHeight) {
      velocity.y = -velocity.y;
      // Ajustar posición para evitar que se quede atascado
      position.y = position.y.clamp(halfHeight, game.size.y - halfHeight);
    }
  }

  /// Método para recibir daño (preparado para futura implementación)
  void takeDamage(int damage) {
    // TODO: Implementar sistema de vida y muerte
    debugPrint('Enemy took $damage damage');
  }

  /// Método para destruir el enemigo
  void destroy() {
    removeFromParent();
    // TODO: Agregar efectos de muerte/explosión
  }
}
