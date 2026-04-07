import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game_logic/combat_cycle.dart';
import 'component_enemy.dart';
import 'component_boss.dart';
import 'ui_displays.dart';

/// Estado de la pantalla de juego
enum GameScreenState {
  initializing,
  waitingStart,
  waveActive,
  bossIncoming,
  bossFighting,
  completed,
  paused,
}

/// Pantalla principal del juego con integración del sistema de combate
class CombatGameScreen extends PositionComponent {
  /// Ciclo de combate
  late CombatCycle combatCycle;

  /// Estado actual
  GameScreenState gameState = GameScreenState.initializing;

  /// Componentes enemigos activos
  final Map<String, ComponentEnemy> componentEnemies = {};

  /// Componente del boss
  ComponentBoss? componentBoss;

  /// Displays de UI
  late WaveInfoDisplay waveInfo;
  late BossInfoDisplay bossInfo;

  /// Control de pausa
  bool isPaused = false;

  CombatGameScreen() : super();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Crear ciclo de combate simple
    combatCycle = CombatCycleFactory.createSimpleCycle();

    // Configurar listeners
    _setupEventListeners();

    // Crear displays de UI
    waveInfo = WaveInfoDisplay();
    add(waveInfo);

    bossInfo = BossInfoDisplay();
    add(bossInfo);

    // Notar: El texto de estado se mostrará en la consola (print)
    // y en los displays de UI. Para pantalla completa, se renderiza en ui_displays

    // Cambiar estado
    gameState = GameScreenState.waitingStart;

    // Iniciar combate
    Future.delayed(Duration(milliseconds: 500), () {
      _startCombat();
    });
  }

  /// Configura los listeners del ciclo de combate
  void _setupEventListeners() {
    // Evento: Comienza oleada
    combatCycle.waveManager.waveStarted.listen((wave) {
      print('🌊 ¡ONDA ${wave.waveNumber}!');
      gameState = GameScreenState.waveActive;

      waveInfo.showWaveStart();
      waveInfo.updateState(
        newWaveNumber: wave.waveNumber,
        newTotalEnemies: wave.getTotalEnemyCount(),
        newRemainingEnemies: wave.getTotalEnemyCount(),
        newState: 'starting',
      );
    });

    // Evento: Se spawneó enemigo
    combatCycle.waveManager.enemySpawned.listen((enemy) {
      // Crear componente visual
      final componentEnemy = ComponentEnemy(enemy);
      componentEnemies[enemy.id] = componentEnemy;
      add(componentEnemy);
    });

    // Evento: Oleada completada
    combatCycle.waveManager.waveEnded.listen((wave) {
      print('✅ Onda ${wave.waveNumber} completada');
      waveInfo.updateState(
        newWaveNumber: wave.waveNumber,
        newTotalEnemies: 0,
        newRemainingEnemies: 0,
        newState: 'ending',
      );

      // Si hay próxima onda, esperar
      if (combatCycle.waveManager.hasNextWave()) {
        gameState = GameScreenState.waitingStart;
      } else {
        // Si no, preparar boss
        gameState = GameScreenState.bossIncoming;
      }
    });

    // Evento: Boss comienza a entrar
    combatCycle.bossManager.bossStarted.listen((boss) {
      print('👑 ¡${boss.name} ha llegado!');
      gameState = GameScreenState.bossFighting;

      // Crear componente visual del boss
      componentBoss = ComponentBoss(boss, combatCycle.bossManager);
      add(componentBoss!);

      // Actualizar UI
      bossInfo.updateState(
        newBossName: boss.name,
        newCurrentPhase: boss.currentPhaseIndex + 1,
        newTotalPhases: boss.phases.length,
      );
    });

    // Evento: Cambio de fase del boss
    combatCycle.bossManager.phaseChanged.listen((event) {
      print(
          '⚡ CAMBIO DE FASE: ${event.newPhase.description}');

      bossInfo.updateState(
        newBossName: event.boss.name,
        newCurrentPhase: event.boss.currentPhaseIndex + 1,
        newTotalPhases: event.boss.phases.length,
      );

      // Aquí se podría agregar efecto visual de shake, etc.
    });

    // Evento: Boss derrotado
    combatCycle.bossManager.bossDefeated.listen((boss) {
      print('🏆 ¡${boss.name} DERROTADO!');
      print('🎉 ¡COMBATE COMPLETADO!');

      gameState = GameScreenState.completed;
      bossInfo.hide();

      // Mostrar mensaje de victoria
      _showVictoryMessage();
    });

    // Evento: Cambio de estado de oleada
    combatCycle.waveManager.stateChanged.listen((state) {
      // Debugging - actualizar UI de estado
    });
  }

  /// Inicia el combate
  void _startCombat() {
    print('═══════════════════════════════════════');
    print('🎮 INICIANDO COMBATE');
    print('═══════════════════════════════════════');
    combatCycle.start();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isPaused) return;

    // Actualizar ciclo de combate
    combatCycle.update(dt);

    // Limpiar enemigos muertos de la lista
    final deadEnemies = combatCycle.getActiveEnemies()
        .where((e) => !e.isAlive)
        .toList();

    for (final deadEnemy in deadEnemies) {
      if (componentEnemies.containsKey(deadEnemy.id)) {
        componentEnemies[deadEnemy.id]?.removeFromParent();
        componentEnemies.remove(deadEnemy.id);
      }
    }

    // Actualizar UI de enemigos restantes
    final remainingEnemies = combatCycle.waveManager.remainingEnemies;
    final totalEnemies = combatCycle.waveManager.totalEnemiesInWave;

    if (gameState == GameScreenState.waveActive && totalEnemies > 0) {
      waveInfo.updateState(
        newWaveNumber: combatCycle.waveManager.currentWaveNumber,
        newTotalEnemies: totalEnemies,
        newRemainingEnemies: remainingEnemies,
        newState: 'active',
      );
    }
  }

  /// Muestra mensajes de victoria
  void _showVictoryMessage() {
    final victoryText = TextComponent(
      text: '🏆 ¡VICTORIA! 🏆',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2 - 100, size.y / 2 - 50),
    );
    add(victoryText);
  }

  /// Pausa el combate
  void pauseCombat() {
    isPaused = true;
    gameState = GameScreenState.paused;
  }

  /// Reanuda el combate
  void resumeCombat() {
    isPaused = false;
    gameState = GameScreenState.waveActive;
  }

  /// Reinicia el combate
  void restartCombat() {
    combatCycle.dispose();
    componentEnemies.clear();
    if (componentBoss != null) {
      componentBoss!.removeFromParent();
      componentBoss = null;
    }
    gameState = GameScreenState.waitingStart;

    // Recrear ciclo
    Future.delayed(Duration(milliseconds: 100), () {
      onLoad();
    });
  }

  @override
  void onRemove() {
    super.onRemove();
    combatCycle.dispose();
  }
}
