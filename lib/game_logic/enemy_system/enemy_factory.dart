import 'dart:math';
import 'package:flutter/material.dart';
import '../projectile_system.dart';
import '../../models/enemy.dart';
import '../../models/element_type.dart';
import 'enemy_types.dart';

/// Factory para crear enemigos de diferentes tipos
class EnemyFactory {
  final ProjectileSystem projectileSystem;
  int _enemyCounter = 0;

  EnemyFactory({required this.projectileSystem});

  /// Crea un enemigo de un tipo específico
  Enemy createEnemy({
    required String typeId,
    required Offset position,
    required int level,
    double difficultyMultiplier = 1.0,
  }) {
    final typeDef = EnemyTypesCatalog.get(typeId);
    if (typeDef == null) {
      throw Exception('Enemy type not found: $typeId');
    }

    // Calcular HP escalado por nivel y dificultad
    final scaledHealth = typeDef.baseHealth *
        (1.0 + (level - 1) * 0.15) * // +15% por nivel
        difficultyMultiplier;

    // Calcular daño escalado
    final scaledDamage = typeDef.attackPattern.bulletDamage *
        (1.0 + (level - 1) * 0.1) * // +10% por nivel
        difficultyMultiplier;

    // Crear enemy base
    final enemy = Enemy(
      id: 'enemy_${typeId}_${_enemyCounter++}',
      name: typeDef.name,
      description: typeDef.description,
      type: AmalgamaType.lavaPizza, // Tipo base pone por defecto
      element: ElementType.neutral, // Elemento neutral por default
      tier: EnemyTier.normal, // Tier normal, escalable
      position: position,
      health: scaledHealth,
      maxHealth: scaledHealth,
      attackSpeed: 1.0 / typeDef.attackPattern.cooldown,
      baseDamage: scaledDamage,
      level: level,
    );

    return enemy;
  }

  /// Crea múltiples enemigos del mismo tipo
  List<Enemy> createEnemies({
    required String typeId,
    required List<Offset> positions,
    required int level,
    double difficultyMultiplier = 1.0,
  }) {
    return positions.map((pos) {
      return createEnemy(
        typeId: typeId,
        position: pos,
        level: level,
        difficultyMultiplier: difficultyMultiplier,
      );
    }).toList();
  }

  /// Genera posiciones de spawn para un patrón específico
  List<Offset> generateSpawnPositions({
    required String pattern,
    required int quantity,
    required Size screenSize,
    double positionVariability = 0.5,
  }) {
    final positions = <Offset>[];
    final topMargin = 100.0;
    final centerX = screenSize.width / 2;

    switch (pattern) {
      case 'burst':
        // Todos aproximadamente en la misma línea con variabilidad
        for (int i = 0; i < quantity; i++) {
          final x = centerX +
              (i - quantity / 2) * 100 +
              (Random().nextDouble() - 0.5) * 100 * positionVariability;
          final y = topMargin + Random().nextDouble() * 50;
          positions.add(Offset(
            x.clamp(20.0, screenSize.width - 20),
            y,
          ));
        }
        break;

      case 'stream':
        // Flujo continuo desde un punto
        for (int i = 0; i < quantity; i++) {
          final xVar =
              (Random().nextDouble() - 0.5) * 150 * positionVariability;
          final x = centerX + xVar;
          final y = topMargin;
          positions.add(Offset(
            x.clamp(20.0, screenSize.width - 20),
            y,
          ));
        }
        break;

      case 'random':
        // Posiciones completamente aleatorias
        for (int i = 0; i < quantity; i++) {
          final x = (Random().nextDouble() * screenSize.width)
              .clamp(20.0, screenSize.width - 20);
          final y = (Random().nextDouble() * screenSize.height * 0.3) +
              topMargin;
          positions.add(Offset(x, y));
        }
        break;

      case 'circle':
        // Círculo alrededor del centro
        for (int i = 0; i < quantity; i++) {
          final angle = (360 / quantity) * i;
          final radius = 150.0 + Random().nextDouble() * 50;
          final x = centerX + radius * _cosine(angle);
          final y = topMargin + radius * _sine(angle);
          positions.add(Offset(
            x.clamp(20.0, screenSize.width - 20),
            y.clamp(20.0, screenSize.height - 20),
          ));
        }
        break;

      default:
        // Fallback a burst
        for (int i = 0; i < quantity; i++) {
          final x = centerX + (i - quantity / 2) * 80;
          positions.add(Offset(
            x.clamp(20.0, screenSize.width - 20),
            topMargin,
          ));
        }
    }

    return positions;
  }

  // Helpers trigonométricos
  double _cosine(double degrees) {
    return cos(degrees * pi / 180);
  }

  double _sine(double degrees) {
    return sin(degrees * pi / 180);
  }
}
