import 'package:flutter/material.dart';
import 'enemy_system/enemy_factory.dart';
import 'enemy_system/enemy_types.dart';
import 'wave_system/wave.dart';
import 'wave_system/wave_manager.dart';
import 'wave_system/enemy_spawn_config.dart';
import 'boss_system/boss_manager.dart';
import 'projectile_system.dart';

/// Factory para crear ciclos completos de oleadas + boss
class CombatCycleFactory {
  /// Crea un ciclo de combate simple (2-3 waves + 1 boss)
  static CombatCycle createSimpleCycle() {
    // Inicializar tipos de enemigos
    EnemyTypesCatalog.initializeDefaults();

    final waves = [
      // Wave 1: Introducción - Grunts
      Wave(
        id: 'wave_1',
        waveNumber: 1,
        description: 'Introducción: Enemigos básicos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 4,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.3,
          ),
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 3,
            spawnPattern: 'stream',
            delayBetweenSpawns: 1.0,
          ),
        ],
        difficultyMultiplier: 1.0,
      ),

      // Wave 2: Variedad - Mezcla de tipos
      Wave(
        id: 'wave_2',
        waveNumber: 2,
        description: 'Variedad: Diferentes tipos de enemigos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 3,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.4,
          ),
          EnemySpawnConfig(
            enemyType: 'shooter',
            quantity: 2,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.3,
          ),
          EnemySpawnConfig(
            enemyType: 'swarm',
            quantity: 8,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.2,
          ),
        ],
        difficultyMultiplier: 1.2,
      ),

      // Wave 3: Dificultad - Enemigos más fuertes
      Wave(
        id: 'wave_3',
        waveNumber: 3,
        description: 'Dificultad: Preparación para el boss',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'tank',
            quantity: 2,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.5,
          ),
          EnemySpawnConfig(
            enemyType: 'sniper',
            quantity: 2,
            spawnPattern: 'random',
            delayBetweenSpawns: 1.5,
          ),
          EnemySpawnConfig(
            enemyType: 'elite',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.3,
          ),
          EnemySpawnConfig(
            enemyType: 'swarm',
            quantity: 5,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.3,
          ),
        ],
        difficultyMultiplier: 1.5,
      ),
    ];

    return CombatCycle(waves: waves);
  }

  /// Crea un ciclo progresivo (más oleadas, más difícil)
  static CombatCycle createProgressiveCycle() {
    EnemyTypesCatalog.initializeDefaults();

    final waves = [
      // Wave 1
      Wave(
        id: 'wave_1',
        waveNumber: 1,
        description: 'Inicio: Pocos enemigos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 3,
            spawnPattern: 'burst',
          ),
        ],
        difficultyMultiplier: 1.0,
      ),

      // Wave 2
      Wave(
        id: 'wave_2',
        waveNumber: 2,
        description: 'Aumento: Más enemigos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 4,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.8,
          ),
          EnemySpawnConfig(
            enemyType: 'shooter',
            quantity: 2,
            spawnPattern: 'burst',
          ),
        ],
        difficultyMultiplier: 1.1,
      ),

      // Wave 3
      Wave(
        id: 'wave_3',
        waveNumber: 3,
        description: 'Presión: Enemigos rápidos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'swarm',
            quantity: 10,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.3,
          ),
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 2,
            spawnPattern: 'burst',
          ),
        ],
        difficultyMultiplier: 1.2,
      ),

      // Wave 4
      Wave(
        id: 'wave_4',
        waveNumber: 4,
        description: 'Caos: Todos los tipos',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'grunt',
            quantity: 3,
            spawnPattern: 'circle',
          ),
          EnemySpawnConfig(
            enemyType: 'shooter',
            quantity: 3,
            spawnPattern: 'burst',
          ),
          EnemySpawnConfig(
            enemyType: 'tank',
            quantity: 1,
            spawnPattern: 'burst',
          ),
          EnemySpawnConfig(
            enemyType: 'swarm',
            quantity: 6,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.25,
          ),
        ],
        difficultyMultiplier: 1.4,
      ),

      // Wave 5
      Wave(
        id: 'wave_5',
        waveNumber: 5,
        description: 'Final: Elite y tanques',
        spawns: [
          EnemySpawnConfig(
            enemyType: 'elite',
            quantity: 2,
            spawnPattern: 'burst',
          ),
          EnemySpawnConfig(
            enemyType: 'tank',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 1.0,
          ),
          EnemySpawnConfig(
            enemyType: 'sniper',
            quantity: 1,
            spawnPattern: 'burst',
          ),
        ],
        difficultyMultiplier: 1.6,
      ),
    ];

    return CombatCycle(waves: waves);
  }
}

/// Orquestador del ciclo completo de combate
class CombatCycle {
  final List<Wave> waves;
  final ProjectileSystem projectileSystem = ProjectileSystem();
  late final EnemyFactory enemyFactory;
  late final WaveManager waveManager;
  final BossManager bossManager = BossManager();

  CombatCycle({required this.waves}) {
    enemyFactory = EnemyFactory(projectileSystem: projectileSystem);
    waveManager = WaveManager(
      waves: waves,
      enemyFactory: enemyFactory,
    );

    _setupEventListeners();
  }

  /// Configura los listeners de eventos
  void _setupEventListeners() {
    // Cuando termina una oleada
    waveManager.waveEnded.listen((wave) {
      print('✅ Onda $wave completada');
      print('📍 Enemigos restantes: ${waveManager.remainingEnemies}');

      // Si no hay más oleadas, preparar el boss
      if (!waveManager.hasNextWave()) {
        print('🎯 ¡BOSS INCOMING!');
        Future.delayed(Duration(milliseconds: 800), () {
          bossManager.prepareBoss(
            'final_boss',
            Offset(200, 150), // Posición inicial del boss
          );
        });
      }
    });

    // Cuando comienza una oleada
    waveManager.waveStarted.listen((wave) {
      print('🌊 ¡COMENZAR ONDA ${wave.waveNumber}!');
      print('📊 Dificultad: ${wave.difficultyMultiplier}x');
      print('👾 Total enemigos: ${wave.getTotalEnemyCount()}');
    });

    // Cuando se spawne un enemigo
    waveManager.enemySpawned.listen((enemy) {
      print('✨ Spawneado: ${enemy.name} en ${enemy.position}');
    });

    // Cambios de estado de oleada
    waveManager.stateChanged.listen((state) {
      print('📍 Wave State: ${state.name}');
    });

    // Boss events
    bossManager.bossStarted.listen((boss) {
      print('👑 ¡${boss.name} ha llegado!');
      print('❤️ Boss HP: ${boss.currentHp}/${boss.maxHp}');
    });

    bossManager.phaseChanged.listen((event) {
      print('⚡ CAMBIO DE FASE: ${event.newPhase.description}');
      print('🔥 Multiplicador de dificultad: ${event.boss.getDifficultyMultiplier()}');
    });

    bossManager.bossDefeated.listen((boss) {
      print('🎉 ¡${boss.name} DERROTADO!');
      print('🏆 ¡COMBATE COMPLETADO!');
    });
  }

  /// Inicia el ciclo de combate
  void start() {
    print('═══════════════════════════════════════');
    print('🎮 INICIANDO CICLO DE COMBATE');
    print('═══════════════════════════════════════');
    print('📋 Total de oleadas: ${waves.length}');
    print('═══════════════════════════════════════\n');

    waveManager.startFirstWave();
  }

  /// Actualiza el ciclo (llamar cada frame)
  void update(double deltaTime) {
    waveManager.update(deltaTime);
    bossManager.update(deltaTime);

    // Simular daño a enemigos para pruebas
    // (En el juego real, esto vendría del jugador)
  }

  /// Obtiene los enemigos activos
  List<dynamic> getActiveEnemies() {
    return waveManager.activeEnemies;
  }

  /// Obtiene el boss actual
  dynamic get activeBoss => bossManager.currentBoss;

  /// Información de actualización
  String getStatusInfo() {
    String info = 'Onda ${waveManager.currentWaveNumber}/${waves.length}';
    info += ' | Estado: ${waveManager.state.name}';
    info += ' | Enemigos: ${waveManager.remainingEnemies}/${waveManager.totalEnemiesInWave}';

    if (bossManager.currentBoss != null) {
      info += ' | Boss HP: ${bossManager.currentBoss!.currentHp.toInt()}';
      info += ' | Fase: ${bossManager.currentBoss!.currentPhaseIndex + 1}';
    }

    return info;
  }

  /// Limpia recursos
  void dispose() {
    waveManager.dispose();
    bossManager.dispose();
  }
}
