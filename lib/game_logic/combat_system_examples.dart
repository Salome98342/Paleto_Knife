// ignore_for_file: unused_import

import 'dart:math';
import 'package:flutter/material.dart';
import 'enemy_system/enemy_factory.dart';
import 'enemy_system/enemy_types.dart';
import 'wave_system/wave.dart';
import 'wave_system/wave_manager.dart';
import 'wave_system/enemy_spawn_config.dart';
import 'boss_system/boss_manager.dart';
import 'projectile_system.dart';
import 'combat_cycle.dart';
export 'combat_cycle.dart';
export 'wave_system/wave_manager.dart';
export 'enemy_system/enemy_factory.dart';
export 'boss_system/boss_manager.dart';

/// GUÍA: Cómo usar el sistema de combate refactorizado
/// 
/// Este archivo contiene ejemplos de uso de:
/// 1. Sistema de oleadas (WaveManager)
/// 2. Sistema de enemigos (EnemyFactory)
/// 3. Sistema de bosses (BossManager)

void main() {
  // Ejemplo 1: Crear un ciclo simple
  exampleSimpleCycle();
}

/// Ejemplo 1: Ciclo simple (3 waves + 1 boss)
void exampleSimpleCycle() {
  print('=== EJEMPLO 1: CICLO SIMPLE ===\n');

  final cycle = CombatCycleFactory.createSimpleCycle();
  cycle.start();

  // Simulación de actualización (en el juego real, esto sería en el game loop)
  // Aquí simulamos 30 segundos de juego
  var elapsed = 0.0;
  Future.delayed(Duration(milliseconds: 0), () async {
    while (elapsed < 30.0) {
      cycle.update(0.016); // 60 FPS
      elapsed += 0.016;
      await Future.delayed(Duration(milliseconds: 16));
      
      // Simular daño aleatorio a enemigos cada frame
      for (final enemy in cycle.getActiveEnemies()) {
        if (enemy.isAlive && Random().nextDouble() > 0.98) {
          enemy.takeDamage(Random().nextDouble() * 10 + 5);
        }
      }

      // Simular daño al boss
      if (cycle.activeBoss != null && Random().nextDouble() > 0.95) {
        cycle.bossManager.damageBoss(Random().nextDouble() * 20 + 10);
      }
    }

    print('\n=== FIN DE LA SIMULACIÓN ===\n');
    cycle.dispose();
  });
}

/// Ejemplo 2: Ciclo progresivo (5 waves + 1 boss)
void exampleProgressiveCycle() {
  print('=== EJEMPLO 2: CICLO PROGRESIVO ===\n');

  final cycle = CombatCycleFactory.createProgressiveCycle();
  cycle.start();

  // Similar al ejemplo 1 pero con duración mayor
}

/// Ejemplo 3: Crear un ciclo personalizado
void exampleCustomCycle() {
  print('=== EJEMPLO 3: CICLO PERSONALIZADO ===\n');

  // Inicializar tipos de enemigos
  EnemyTypesCatalog.initializeDefaults();

  // Crear oleadas personalizadas
  final waves = [
    Wave(
      id: 'custom_1',
      waveNumber: 1,
      description: 'Oleada custom 1',
      spawns: [
        EnemySpawnConfig(
          enemyType: 'grunt',
          quantity: 5,
          spawnPattern: 'burst',
        ),
      ],
      difficultyMultiplier: 1.0,
    ),
    Wave(
      id: 'custom_2',
      waveNumber: 2,
      description: 'Oleada custom 2',
      spawns: [
        EnemySpawnConfig(
          enemyType: 'elite',
          quantity: 3,
          spawnPattern: 'circle',
          delayBetweenSpawns: 0.5,
        ),
        EnemySpawnConfig(
          enemyType: 'swarm',
          quantity: 15,
          spawnPattern: 'stream',
          delayBetweenSpawns: 0.2,
        ),
      ],
      difficultyMultiplier: 1.3,
    ),
  ];

  // Crear ciclo con oleadas personalizadas
  final cycle = CombatCycle(waves: waves);
  cycle.start();
}

/// Ejemplo 4: Uso avanzado - Integración con Flame
/// 
/// En un componente de Flame:
/// 
/// class GameScreen extends PositionComponent {
///   late CombatCycle combatCycle;
///   final TextComponent waveInfo = TextComponent();
///   final List<ComponentEnemy> componentEnemies = [];
///   ComponentBoss? componentBoss;
///
///   @override
///   Future<void> onLoad() async {
///     // Crear ciclo
///     combatCycle = CombatCycleFactory.createSimpleCycle();
///
///     // Listeners
///     combatCycle.waveManager.enemySpawned.listen((enemy) {
///       // Crear ComponentEnemy basado en Enemy
///       final componentEnemy = ComponentEnemy(enemy);
///       componentEnemies.add(componentEnemy);
///       add(componentEnemy);
///     });
///
///     combatCycle.bossManager.bossStarted.listen((boss) {
///       // Crear ComponentBoss
///       componentBoss = ComponentBoss(boss);
///       add(componentBoss!);
///     });
///
///     // Iniciar
///     combatCycle.start();
///   }
///
///   @override
///   void update(double dt) {
///     super.update(dt);
///     
///     // Actualizar ciclo
///     combatCycle.update(dt);
///
///     // Actualizar info de UI
///     waveInfo.text = combatCycle.getStatusInfo();
///
///     // Limpiar enemigos muertos
///     componentEnemies.removeWhere((e) {
///       if (!e.enemy.isAlive) {
///         e.removeFromParent();
///         return true;
///       }
///       return false;
///     });
///   }
/// }

/// Ejemplo 5: Cómo agregar nuevos tipos de enemigos
// NOTE: This example requires additional enemy behavior and attack pattern types
// that may not be fully defined in your system. Uncomment to use with proper classes.
/*
void exampleAddNewEnemyType() {
  print('=== EJEMPLO 5: AGREGAR NUEVO TIPO DE ENEMIGO ===\n');

  // Registrar un nuevo tipo
  EnemyTypesCatalog.register(
    EnemyTypeDefinition(
      id: 'healer',
      name: 'Healer',
      description: 'Enemigo que cura a otros',
      baseHealth: 20.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 120.0,
        preferredDistance: 250.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 3.0,
        bulletSpeed: 200.0,
        bulletDamage: 3.0, // Bajo daño, se enfoca en curar
        bulletCount: 1,
      ),
      debugColor: 0xFF00FF00, // Verde lima
    ),
  );

  // Ahora se puede usar en oleadas
  print('✅ Nuevo tipo "healer" registrado');
  print('📚 Tipos disponibles: ${EnemyTypesCatalog.getAll().map((e) => e.id).toList()}');
}
*/

/// Ejemplo 6: Cómo crear un boss personalizado
void exampleCustomBoss() {
  print('=== EJEMPLO 6: BOSS PERSONALIZADO ===\n');

  // Esto se hace en BossFactory::createBoss
  // Agregar un nuevo case en el switch:
  // case 'my_custom_boss':
  //   return _createMyCustomBoss(position);

  print('📖 Ver boss_manager.dart para agregar bosses personalizados');
}
// import 'game_logic/combat_system_examples.dart';
// 
// void main() {
//   exampleSimpleCycle();
// }
