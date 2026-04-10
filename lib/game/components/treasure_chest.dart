import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Cofre de tesoro que se cae cuando un jefe muere
class TreasureChestComponent extends PositionComponent {
  bool isActive = false;
  
  // Animación
  double _bobTimer = 0.0;
  double _bobHeight = 5.0;
  Vector2 _basePosition = Vector2.zero();
  double _bobSpeed = 2.0;
  
  // Física
  Vector2 velocity = Vector2.zero();
  Vector2 acceleration = Vector2(0, 300); // Gravedad
  
  // Visual
  final Paint _chestPaint = Paint()..color = Colors.amber.shade700;
  final Paint _lightPaint = Paint()..color = Colors.amber.shade300;
  final Paint _lockPaint = Paint()..color = Colors.black;
  
  // Estado
  bool isOpened = false;
  double _glowIntensity = 0.0;
  double _glowDirection = 1.0;

  TreasureChestComponent()
      : super(
          size: Vector2(40, 35),
          anchor: Anchor.center,
        );

  void spawn(Vector2 startPos) {
    position.setFrom(startPos);
    _basePosition.setFrom(startPos);
    velocity = Vector2.zero();
    isActive = true;
    isOpened = false;
    _bobTimer = 0.0;
    _glowIntensity = 0.5;
    _glowDirection = 1.0;
  }

  void despawn() {
    isActive = false;
  }

  // Retorna si el cofre fue clicado
  bool checkClick(Vector2 clickPos) {
    if (!isActive || isOpened) return false;
    
    final dx = position.x - clickPos.x;
    final dy = position.y - clickPos.y;
    final distance = sqrt(dx * dx + dy * dy);
    
    return distance <= size.x / 1.5; // Radio de interacción
  }

  void open() {
    isOpened = true;
  }

  @override
  void update(double dt) {
    if (!isActive || isOpened) return;

    // Aplicar gravedad y caída
    velocity.y += acceleration.y * dt;
    position.add(velocity * dt);

    // Limitar velocidad de caída
    if (velocity.y > 400) {
      velocity.y = 400;
    }

    // Parar cuando toque el suelo (y > 700)
    if (position.y > 700) {
      position.y = 700;
      velocity.y = 0;
    }

    // Bobbing animation cuando está en el suelo
    if (velocity.y == 0) {
      _bobTimer += dt * _bobSpeed;
      final bobOffset = sin(_bobTimer * pi) * _bobHeight;
      position.y = _basePosition.y + 700 - _basePosition.y + bobOffset;
      
      // Glow effect
      _glowIntensity += dt * _glowDirection;
      if (_glowIntensity >= 1.0) {
        _glowIntensity = 1.0;
        _glowDirection = -1.0;
      } else if (_glowIntensity <= 0.3) {
        _glowIntensity = 0.3;
        _glowDirection = 1.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    // Glow de fondo (aura)
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: _glowIntensity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 1.2,
      glowPaint,
    );

    // Cuerpo del cofre (rectángulo redondeado)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.x * 0.1,
        size.y * 0.3,
        size.x * 0.8,
        size.y * 0.6,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, _chestPaint);

    // Tapa del cofre (semicírculo)
    final lidPath = Path()
      ..moveTo(size.x * 0.1, size.y * 0.3)
      ..arcToPoint(
        Offset(size.x * 0.9, size.y * 0.3),
        radius: const Radius.circular(20),
        largeArc: true,
      )
      ..close();
    canvas.drawPath(lidPath, _lightPaint);

    // Cerradura (pequeño cuadrado oscuro)
    canvas.drawRect(
      Rect.fromLTWH(
        size.x * 0.4,
        size.y * 0.35,
        size.x * 0.2,
        size.y * 0.15,
      ),
      _lockPaint,
    );

    // Línea divisoria del cofre
    canvas.drawLine(
      Offset(size.x * 0.1, size.y * 0.5),
      Offset(size.x * 0.9, size.y * 0.5),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    // Gema de luz si está brillando mucho
    if (_glowIntensity > 0.6) {
      canvas.drawCircle(
        Offset(size.x * 0.7, size.y * 0.2),
        2,
        Paint()..color = Colors.yellowAccent,
      );
    }
  }
}
