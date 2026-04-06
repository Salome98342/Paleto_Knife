import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/projectile.dart';

/// Sistema que gestiona todos los proyectiles del juego
class ProjectileSystem {
  final List<Projectile> _projectiles = [];
  int _projectileIdCounter = 0;

  /// Obtiene todos los proyectiles activos
  List<Projectile> get projectiles => List.unmodifiable(_projectiles);

  /// Obtiene solo los proyectiles del jugador
  List<Projectile> get playerProjectiles =>
      _projectiles.where((p) => p.isPlayerProjectile && p.isActive).toList();

  /// Obtiene solo los proyectiles enemigos
  List<Projectile> get enemyProjectiles =>
      _projectiles.where((p) => !p.isPlayerProjectile && p.isActive).toList();

  /// Crea un proyectil del jugador
  void spawnPlayerProjectile({
    required Offset position,
    required double damage,
  }) {
    final projectile = Projectile(
      id: 'projectile_${_projectileIdCounter++}',
      position: position,
      velocity: -500, // Hacia arriba
      damage: damage,
      isPlayerProjectile: true,
    );
    _projectiles.add(projectile);
  }

  /// Crea un proyectil enemigo simple
  void spawnEnemyProjectile({
    required Offset position,
    required double damage,
  }) {
    final projectile = Projectile(
      id: 'projectile_${_projectileIdCounter++}',
      position: position,
      velocity: 300, // Hacia abajo
      damage: damage,
      isPlayerProjectile: false,
    );
    _projectiles.add(projectile);
  }

  /// Crea un patron radial de proyectiles (360 grados)
  void spawnRadialPattern({
    required Offset position,
    required double damage,
    required int bulletCount,
    required double speed,
    double startAngle = 0,
  }) {
    final angleStep = 360.0 / bulletCount;

    for (int i = 0; i < bulletCount; i++) {
      final angle = startAngle + (i * angleStep);
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: angle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  /// Crea un patron de abanico (fan spread)
  void spawnFanPattern({
    required Offset position,
    required double damage,
    required int bulletCount,
    required double speed,
    double centerAngle = 90, // Apunta hacia abajo por defecto
    double spreadAngle = 60, // Angulo total del abanico
  }) {
    if (bulletCount == 1) {
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: centerAngle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
      return;
    }

    final angleStep = spreadAngle / (bulletCount - 1);
    final startAngle = centerAngle - (spreadAngle / 2);

    for (int i = 0; i < bulletCount; i++) {
      final angle = startAngle + (i * angleStep);
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: angle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  /// Crea un patron de espiral
  void spawnSpiralPattern({
    required Offset position,
    required double damage,
    required int bulletCount,
    required double speed,
    required double spiralRotation, // Angulo de rotacion de la espiral
  }) {
    final angleStep = 360.0 / bulletCount;

    for (int i = 0; i < bulletCount; i++) {
      final angle = spiralRotation + (i * angleStep);
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: angle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  /// Crea un patron dirigido hacia el jugador
  void spawnAimedPattern({
    required Offset position,
    required Offset targetPosition,
    required double damage,
    required int bulletCount,
    required double speed,
    double spreadAngle = 0, // Dispersion alrededor del objetivo
  }) {
    // Calcular angulo hacia el jugador
    final dx = targetPosition.dx - position.dx;
    final dy = targetPosition.dy - position.dy;
    final baseAngle = math.atan2(dy, dx) * 180 / math.pi;

    if (bulletCount == 1 || spreadAngle == 0) {
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: baseAngle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
      return;
    }

    // Crear spreaddebido alrededor del angulo base
    final angleStep = spreadAngle / (bulletCount - 1);
    final startAngle = baseAngle - (spreadAngle / 2);

    for (int i = 0; i < bulletCount; i++) {
      final angle = startAngle + (i * angleStep);
      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: angle,
        speed: speed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  /// Actualiza todos los proyectiles
  /// Crea un patron de Danza Floral (Radial + Senoidal)
  void spawnFloralDance({
    required Offset position,
    required double damage,
    required int bulletCount,
    required double baseSpeed,
    required double time,
  }) {
    final angleStep = 360.0 / bulletCount;
    final rotationOffset = time * 30.0;

    for (int i = 0; i < bulletCount; i++) {
      final angle = rotationOffset + (i * angleStep);
      final speedMod = math.sin((angle * 5) * math.pi / 180.0);
      final finalSpeed = baseSpeed + (speedMod * 100).abs();

      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: angle,
        speed: finalSpeed,
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  /// Crea un patron "Lluvia de Estrellas Caoticas" con Safe Zone
  void spawnChaoticStars({
    required Offset position,
    required double damage,
    required int bulletCount,
    required double speed,
    required double time,
  }) {
    final angleStep = 180.0 / bulletCount;

    for (int i = 0; i <= bulletCount; i++) {
      final angle = i * angleStep;

      // SAFE ZONE: No dispares en un area conica justo debajo
      if (angle > 75 && angle < 105) continue;

      final chaoticWobble = math.sin(time * 10 + i) * 15;
      final finalAngle = angle + chaoticWobble;

      final projectile = Projectile.withAngle(
        id: 'bullet_${_projectileIdCounter++}',
        position: position,
        angleInDegrees: finalAngle,
        speed: speed + (math.cos(time + i) * 50),
        damage: damage,
        isPlayerProjectile: false,
      );
      _projectiles.add(projectile);
    }
  }

  void update(double deltaTime, Size screenSize) {
    // Actualizar posiciones
    for (var projectile in _projectiles) {
      if (projectile.isActive) {
        projectile.update(deltaTime);

        // Desactivar proyectiles fuera de los limites
        if (projectile.isOutOfBounds(screenSize)) {
          projectile.isActive = false;
        }
      }
    }

    // Eliminar proyectiles inactivos
    _projectiles.removeWhere((p) => !p.isActive);
  }

  /// Verifica colisiones de proyectiles del jugador con un rectangulo
  List<Projectile> checkPlayerProjectileCollisions(Rect targetRect) {
    final hits = <Projectile>[];

    for (var projectile in playerProjectiles) {
      if (projectile.collidesWith(targetRect)) {
        projectile.isActive = false;
        hits.add(projectile);
      }
    }

    return hits;
  }

  /// Verifica colisiones de proyectiles enemigos con un rectangulo
  List<Projectile> checkEnemyProjectileCollisions(Rect targetRect) {
    final hits = <Projectile>[];

    for (var projectile in enemyProjectiles) {
      if (projectile.collidesWith(targetRect)) {
        projectile.isActive = false;
        hits.add(projectile);
      }
    }

    return hits;
  }

  /// Limpia todos los proyectiles
  void clear() {
    _projectiles.clear();
  }

  /// Obtiene el numero total de proyectiles activos
  int get activeCount => _projectiles.where((p) => p.isActive).length;
}
