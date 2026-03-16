import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Modelo de proyectil (tanto del jugador como del enemigo)
class Projectile {
  String id;
  Offset position;
  double velocityX; // Velocidad horizontal
  double velocityY; // Velocidad vertical
  double damage;
  bool isPlayerProjectile; // true = del jugador, false = del enemigo
  bool isActive; // Si el proyectil está activo en pantalla
  double? angle; // Ángulo de rotación visual (para bullet hell)

  Projectile({
    required this.id,
    required this.position,
    double? velocity, // Velocidad simple (compatibilidad)
    this.velocityX = 0,
    this.velocityY = 0,
    required this.damage,
    required this.isPlayerProjectile,
    this.isActive = true,
    this.angle,
  }) {
    // Si se proporciona velocity simple, convertir a velocityY
    if (velocity != null && velocityY == 0) {
      velocityY = velocity;
    }
  }
  
  /// Constructor para proyectiles con dirección angular (bullet hell)
  factory Projectile.withAngle({
    required String id,
    required Offset position,
    required double angleInDegrees,
    required double speed,
    required double damage,
    required bool isPlayerProjectile,
  }) {
    final angleInRadians = angleInDegrees * math.pi / 180;
    return Projectile(
      id: id,
      position: position,
      velocityX: math.cos(angleInRadians) * speed,
      velocityY: math.sin(angleInRadians) * speed,
      damage: damage,
      isPlayerProjectile: isPlayerProjectile,
      angle: angleInRadians,
    );
  }

  /// Actualiza la posición del proyectil
  void update(double deltaTime) {
    position = Offset(
      position.dx + (velocityX * deltaTime),
      position.dy + (velocityY * deltaTime),
    );
  }

  /// Verifica si el proyectil está fuera de los límites de la pantalla
  bool isOutOfBounds(Size screenSize) {
    return position.dy < -50 || 
           position.dy > screenSize.height + 50 ||
           position.dx < -50 || 
           position.dx > screenSize.width + 50;
  }

  /// Verifica colisión con un rectángulo
  bool collidesWith(Rect targetRect) {
    final projectileRect = Rect.fromCenter(
      center: position,
      width: 10,
      height: 20,
    );
    return projectileRect.overlaps(targetRect);
  }

  /// Crea una copia del proyectil
  Projectile copyWith({
    String? id,
    Offset? position,
    double? velocityX,
    double? velocityY,
    double? damage,
    bool? isPlayerProjectile,
    bool? isActive,
    double? angle,
  }) {
    return Projectile(
      id: id ?? this.id,
      position: position ?? this.position,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
      damage: damage ?? this.damage,
      isPlayerProjectile: isPlayerProjectile ?? this.isPlayerProjectile,
      isActive: isActive ?? this.isActive,
      angle: angle ?? this.angle,
    );
  }
}
