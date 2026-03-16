import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/enemy.dart';
import '../models/element_type.dart';
import 'projectile_system.dart';

/// Patrón de ataque enemigo
enum AttackPattern {
  simple, // Un solo proyectil hacia abajo
  fan, // Abanico de proyectiles
  radial, // Círculo completo de proyectiles
  spiral, // Espiral rotante
  aimed, // Apunta al jugador
}

/// Controlador que maneja la lógica del enemigo
class EnemyController {
  Enemy _enemy;
  final ProjectileSystem _projectileSystem;
  
  Timer? _attackTimer;
  double _attackCooldown = 0;
  double _spiralRotation = 0; // Para patrones de espiral
  AttackPattern _currentPattern = AttackPattern.simple;
  int _attackCount = 0; // Contador de ataques para variar patrones
  
  // Referencia a la posición del jugador (para ataques dirigidos)
  Offset? _playerPosition;

  EnemyController({
    required Enemy enemy,
    required ProjectileSystem projectileSystem,
  })  : _enemy = enemy,
        _projectileSystem = projectileSystem;

  /// Obtiene el enemigo actual
  Enemy get enemy => _enemy;
  
  /// Actualiza la posición del jugador (para ataques dirigidos)
  void updatePlayerPosition(Offset position) {
    _playerPosition = position;
  }

  /// Actualiza el estado del enemigo
  void update(double deltaTime) {
    if (!_enemy.isAlive) return;
    
    // Actualizar cooldown de ataque
    if (_attackCooldown > 0) {
      _attackCooldown -= deltaTime;
    }
    
    // Actualizar rotación de espiral
    _spiralRotation += deltaTime * 90; // Rotar 90 grados por segundo
    if (_spiralRotation >= 360) {
      _spiralRotation -= 360;
    }
  }
  
  /// Selecciona el patrón de ataque basado en el nivel del enemigo
  AttackPattern _selectPattern(int level) {
    // Aumentar complejidad según el nivel
    if (level < 5) {
      // Niveles 1-4: Solo simple y fan básico
      return _attackCount % 3 == 0 ? AttackPattern.fan : AttackPattern.simple;
    } else if (level < 15) {
      // Niveles 5-14: Simple, fan y aimed
      final patterns = [AttackPattern.simple, AttackPattern.fan, AttackPattern.aimed];
      return patterns[_attackCount % patterns.length];
    } else if (level < 30) {
      // Niveles 15-29: Todo excepto espiral
      final patterns = [AttackPattern.fan, AttackPattern.radial, AttackPattern.aimed];
      return patterns[_attackCount % patterns.length];
    } else {
      // Nivel 30+: Todos los patrones incluyendo espiral
      final patterns = AttackPattern.values;
      return patterns[_attackCount % patterns.length];
    }
  }
  
  /// Obtiene parámetros de bullet hell basados en el nivel
  Map<String, dynamic> _getBulletHellParams(int level) {
    // Escalar dificultad con el nivel
    final worldMultiplier = 1 + (level ~/ 10) * 0.2; // +20% cada 10 niveles
    
    return {
      'bulletCount': math.min(3 + (level ~/ 5), 16), // 3-16 balas, aumenta cada 5 niveles
      'speed': 200 + (level * 5) * worldMultiplier, // Aumenta con nivel
      'spreadAngle': 60 + (level ~/ 10) * 10.0, // Abanicos más anchos
    };
  }

  /// Intenta atacar con patrón bullet hell
  bool tryAttack() {
    if (!_enemy.isAlive) return false;
    
    if (_attackCooldown <= 0) {
      // Calcular cooldown basado en velocidad de ataque escalada
      final scaledAttackSpeed = _enemy.getScaledAttackSpeed();
      _attackCooldown = 1.0 / scaledAttackSpeed;
      
      // Seleccionar patrón para este ataque
      _currentPattern = _selectPattern(_enemy.level);
      _attackCount++;
      
      // Obtener parámetros escalados
      final params = _getBulletHellParams(_enemy.level);
      final damage = _enemy.getScaledDamage();
      final position = Offset(
        _enemy.position.dx,
        _enemy.position.dy + 40,
      );
      
      // Ejecutar patrón de ataque
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
          // Círculo completo (bullet hell clásico)
          final bulletCount = _enemy.isBoss 
              ? params['bulletCount'] * 2 // Bosses disparan el doble
              : params['bulletCount'];
          _projectileSystem.spawnRadialPattern(
            position: position,
            damage: damage,
            bulletCount: bulletCount,
            speed: params['speed'],
            startAngle: _spiralRotation, // Rotar el patrón
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
              spreadAngle: 30, // Ligera dispersión
            );
          } else {
            // Fallback a simple si no hay posición del jugador
            _projectileSystem.spawnEnemyProjectile(
              position: position,
              damage: damage,
            );
          }
          break;
      }
      
      return true;
    }
    return false;
  }

  /// Inicia el ataque automático
  void startAutoAttack() {
    _attackTimer?.cancel();
    
    _attackTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (_enemy.isAlive) {
          tryAttack();
        }
      },
    );
  }

  /// Detiene el ataque automático
  void stopAutoAttack() {
    _attackTimer?.cancel();
    _attackTimer = null;
  }

  /// Recibe daño
  void takeDamage(double damage) {
    _enemy.takeDamage(damage);
  }

  /// Verifica si el enemigo está vivo
  bool get isAlive => _enemy.isAlive;

  /// Reinicia el enemigo para un nuevo nivel
  void resetForLevel(int level, ElementType worldElement, {bool isBoss = false}) {
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
    _enemy = Enemy.createForLevel(
      level,
      worldElement,
      position: position,
    );
    _attackCooldown = 0;
  }

  /// Limpia recursos
  void dispose() {
    _attackTimer?.cancel();
  }
}
