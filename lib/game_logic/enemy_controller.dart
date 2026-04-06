import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/enemy.dart';
import '../models/element_type.dart';
import 'projectile_system.dart';

/// Patron de ataque enemigo
enum AttackPattern {
  simple, // Un solo proyectil hacia abajo
  fan, // Abanico de proyectiles
  radial, // Circulo completo de proyectiles
  spiral, // Espiral rotante
  aimed, // Apunta al jugador
  floralDance, // FASE 2: Danza Floral (Radial + Senoidal)
  chaoticStars, // FASE 3: Lluvia Caotica con zona central segura
}

/// Controlador que maneja la logica del enemigo
class EnemyController {
  Enemy _enemy;
  final ProjectileSystem _projectileSystem;

  Timer? _attackTimer;
  double _attackCooldown = 0;
  double _spiralRotation = 0; // Para patrones de espiral
  double _time = 0; // Tiempo local para mover al jefe y animaciones senoidales
  Offset?
  _spawnPosition; // Posicion inicial para calcular movimientos oscilatorios

  AttackPattern _currentPattern = AttackPattern.simple;
  int _attackCount = 0; // Contador de ataques para variar patrones

  // Referencia a la posicion del jugador (para ataques dirigidos)
  Offset? _playerPosition;

  EnemyController({
    required Enemy enemy,
    required ProjectileSystem projectileSystem,
  }) : _enemy = enemy,
       _projectileSystem = projectileSystem;

  /// Obtiene el enemigo actual
  Enemy get enemy => _enemy;

  /// Actualiza la posicion del jugador (para ataques dirigidos)
  void updatePlayerPosition(Offset position) {
    _playerPosition = position;
  }

  /// Actualiza el estado del enemigo
  void update(double deltaTime) {
    if (!_enemy.isAlive) return;

    // Sumar tiempo acumulado para calculos matematicos puristas
    _time += deltaTime;

    // Actualizar cooldown de ataque
    if (_attackCooldown > 0) {
      _attackCooldown -= deltaTime;
    }

    // Actualizar rotacion de espiral
    _spiralRotation += deltaTime * 90; // Rotar 90 grados por segundo
    if (_spiralRotation >= 360) {
      _spiralRotation -= 360;
    }

    // Movimiento del Jefe
    if (_enemy.isBoss) {
      if (_spawnPosition == null) {
        _spawnPosition = _enemy.position;
      }

      // REGLA 1: Movimiento oscilatorio de Boss en la parte superior
      // Ecuacion de Seno con amplitud de 100 pixeles.
      final newX = _spawnPosition!.dx + math.sin(_time * 1.5) * 100;
      _enemy.position = Offset(newX, _enemy.position.dy);
    }
  }

  /// Selecciona el patron de ataque basado en el nivel del enemigo
  AttackPattern _selectPattern(int level) {
    if (_enemy.isBoss) {
      // Regla 2: Fases del Jefe basadas en HP
      double hpRatio = _enemy.health / _enemy.maxHealth;

      if (hpRatio > 0.6) {
        // Fase 1: Espiral y Abanico
        return _attackCount % 2 == 0 ? AttackPattern.spiral : AttackPattern.fan;
      } else if (hpRatio > 0.3) {
        // Fase 2: Danza Floral
        return AttackPattern.floralDance;
      } else {
        // Fase 3 (Desesperacion): Lluvia de Estrellas Caoticas
        return AttackPattern.chaoticStars;
      }
    }

    // Aumentar complejidad segun el nivel para enemigos normales
    if (level < 5) {
      return _attackCount % 3 == 0 ? AttackPattern.fan : AttackPattern.simple;
    } else if (level < 15) {
      final patterns = [
        AttackPattern.simple,
        AttackPattern.fan,
        AttackPattern.aimed,
      ];
      return patterns[_attackCount % patterns.length];
    } else if (level < 30) {
      final patterns = [
        AttackPattern.fan,
        AttackPattern.radial,
        AttackPattern.aimed,
      ];
      return patterns[_attackCount % patterns.length];
    } else {
      // Normal enemies don't use boss phases
      final patterns = [
        AttackPattern.simple,
        AttackPattern.fan,
        AttackPattern.radial,
        AttackPattern.spiral,
        AttackPattern.aimed,
      ];
      return patterns[_attackCount % patterns.length];
    }
  }

  /// Obtiene parametros de bullet hell basados en el nivel
  Map<String, dynamic> _getBulletHellParams(int level) {
    // Escalar dificultad con el nivel
    final worldMultiplier = 1 + (level ~/ 10) * 0.2; // +20% cada 10 niveles

    return {
      'bulletCount': math.min(
        3 + (level ~/ 5),
        16,
      ), // 3-16 balas, aumenta cada 5 niveles
      'speed': 200 + (level * 5) * worldMultiplier, // Aumenta con nivel
      'spreadAngle': 60 + (level ~/ 10) * 10.0, // Abanicos mas anchos
    };
  }

  /// Intenta atacar con patron bullet hell
  bool tryAttack() {
    if (!_enemy.isAlive) return false;

    if (_attackCooldown <= 0) {
      // Calcular cooldown basado en velocidad de ataque escalada
      final scaledAttackSpeed = _enemy.getScaledAttackSpeed();
      _attackCooldown = 1.0 / scaledAttackSpeed;

      // Seleccionar patron para este ataque
      _currentPattern = _selectPattern(_enemy.level);
      _attackCount++;

      // Obtener parametros escalados
      final params = _getBulletHellParams(_enemy.level);
      final damage = _enemy.getScaledDamage();
      final position = Offset(_enemy.position.dx, _enemy.position.dy + 40);

      // Ejecutar patron de ataque
      switch (_currentPattern) {
        case AttackPattern.simple:
          // Un solo proyectil hacia abajo
          _projectileSystem.spawnEnemyProjectile(
            position: position,
            damage: damage,
          );
          break;

        case AttackPattern.fan:
          // Abanico hacia el jugador o hacia abajo
          _projectileSystem.spawnFanPattern(
            position: position,
            damage: damage,
            bulletCount: params['bulletCount'] ~/ 2, // Menos balas en abanico
            speed: params['speed'],
            centerAngle: 90, // Hacia abajo
            spreadAngle: params['spreadAngle'],
          );
          break;

        case AttackPattern.radial:
          // Circulo completo (bullet hell clasico)
          final bulletCount = _enemy.isBoss
              ? params['bulletCount'] *
                    2 // Bosses disparan el doble
              : params['bulletCount'];
          _projectileSystem.spawnRadialPattern(
            position: position,
            damage: damage,
            bulletCount: bulletCount,
            speed: params['speed'],
            startAngle: _spiralRotation, // Rotar el patron
          );
          break;

        case AttackPattern.spiral:
          // Espiral rotante
          _projectileSystem.spawnSpiralPattern(
            position: position,
            damage: damage,
            bulletCount: 8, // Espiral con 8 brazos
            speed: params['speed'],
            spiralRotation: _spiralRotation,
          );
          break;

        case AttackPattern.aimed:
          // Dirigido al jugador
          if (_playerPosition != null) {
            final bulletCount = _enemy.isBoss ? 5 : 3;
            _projectileSystem.spawnAimedPattern(
              position: position,
              targetPosition: _playerPosition!,
              damage: damage,
              bulletCount: bulletCount,
              speed: params['speed'],
              spreadAngle: 30, // Ligera dispersion
            );
          } else {
            // Fallback a simple si no hay posicion del jugador
            _projectileSystem.spawnEnemyProjectile(
              position: position,
              damage: damage,
            );
          }
          break;

        case AttackPattern.floralDance:
          // FASE 2: Patron Danza Floral (Radial con velocidad senoidal)
          _projectileSystem.spawnFloralDance(
            position: position,
            damage: damage,
            bulletCount: _enemy.isBoss ? 16 : 8,
            baseSpeed: params['speed'] * 0.5, // Velocidad base mas manejable
            time: _time,
          );
          break;

        case AttackPattern.chaoticStars:
          // FASE 3: Desesperacion. Disparos caoticos, pero respetando la Safe Zone.
          // Se disparan muy rapido.
          _projectileSystem.spawnChaoticStars(
            position: position,
            damage: damage,
            bulletCount: 12,
            speed: params['speed'] * 1.5, // Mucho mas rapido
            time: _time,
          );
          break;
      }

      return true;
    }
    return false;
  }

  /// Inicia el ataque automatico
  void startAutoAttack() {
    _attackTimer?.cancel();

    _attackTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_enemy.isAlive) {
        tryAttack();
      }
    });
  }

  /// Detiene el ataque automatico
  void stopAutoAttack() {
    _attackTimer?.cancel();
    _attackTimer = null;
  }

  /// Recibe dano
  void takeDamage(double damage) {
    _enemy.takeDamage(damage);
  }

  /// Verifica si el enemigo esta vivo
  bool get isAlive => _enemy.isAlive;

  /// Reinicia el enemigo para un nuevo nivel
  void resetForLevel(
    int level,
    ElementType worldElement, {
    bool isBoss = false,
  }) {
    EnemyTier newTier = isBoss ? EnemyTier.boss : _enemy.tier;
    _enemy.reset(level, newTier: newTier);
    _attackCooldown = 0;
  }

  /// Crea un nuevo enemigo para el nivel actual
  void spawnNewEnemy(
    int level,
    ElementType worldElement,
    Offset position, {
    bool isBoss = false,
  }) {
    _enemy = Enemy.createForLevel(level, worldElement, position: position);
    _attackCooldown = 0;
  }

  /// Limpia recursos
  void dispose() {
    _attackTimer?.cancel();
  }
}
