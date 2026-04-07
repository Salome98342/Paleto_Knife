import 'dart:async';
import 'package:flutter/material.dart';
import 'wave.dart';
import 'enemy_spawn_config.dart';
import '../enemy_system/enemy_factory.dart';
import '../../models/enemy.dart';

/// Estados del WaveManager
enum WaveState {
  idle, // Esperando comenzar
  preparing, // Preparando oleada (mostrando "Wave X")
  spawning, // Spowneando enemigos
  inProgress, // Oleada en progreso
  completed, // Oleada completada
  transitioning, // Transición a siguiente oleada
}

/// Callback para eventos del WaveManager
typedef void OnWaveEventCallback(Wave wave);
typedef void OnEnemySpawnedCallback(Enemy enemy);
typedef void OnWaveStateChangedCallback(WaveState state);

/// Gestiona las oleadas del juego
class WaveManager {
  /// Oleadas configuradas
  final List<Wave> waves;

  /// Factory de enemigos
  final EnemyFactory enemyFactory;

  /// Índice de la oleada actual
  int _currentWaveIndex = 0;

  /// Estado actual
  WaveState _state = WaveState.idle;

  /// Enemigos activos de la oleada actual
  final List<Enemy> _activeEnemies = [];

  /// Timer para controlar los spawns
  Timer? _spawnTimer;

  /// Tiempo acumulado para spawning progresivo
  double _spawnTime = 0;

  /// Configuración actual de spawning
  EnemySpawnConfig? _currentSpawnConfig;

  /// Índice del spawn actual
  int _currentSpawnIndex = 0;

  /// Cantidad de enemigos ya spawneados en el spawn actual
  int _spawnedCount = 0;

  /// Timer para la pausa entre oleadas
  Timer? _transitionTimer;

  /// Tiempo de pausa antes de comenzar una oleada
  final double prepareWaveDuration = 0.5;

  /// Tiempo de pausa entre oleadas
  final double transitionDuration = 1.5;

  /// Callbacks
  final _onWaveStart = StreamController<Wave>.broadcast();
  final _onWaveEnd = StreamController<Wave>.broadcast();
  final _onEnemySpawned = StreamController<Enemy>.broadcast();
  final _onStateChanged = StreamController<WaveState>.broadcast();

  WaveManager({
    required this.waves,
    required this.enemyFactory,
  });

  /// Obtiene el estado actual
  WaveState get state => _state;

  /// Obtiene la onda actual
  Wave? get currentWave =>
      _currentWaveIndex < waves.length ? waves[_currentWaveIndex] : null;

  /// Obtiene el número de la oleada actual
  int get currentWaveNumber => _currentWaveIndex + 1;

  /// Obtiene los enemigos activos
  List<Enemy> get activeEnemies => List.unmodifiable(_activeEnemies);

  /// Cantidad total de enemigos en la oleada actual
  int get totalEnemiesInWave =>
      currentWave?.getTotalEnemyCount() ?? 0;

  /// Cantidad de enemigos restantes
  int get remainingEnemies {
    return _activeEnemies.where((e) => e.isAlive).length;
  }

  /// Stream de eventos
  Stream<Wave> get waveStarted => _onWaveStart.stream;
  Stream<Wave> get waveEnded => _onWaveEnd.stream;
  Stream<Enemy> get enemySpawned => _onEnemySpawned.stream;
  Stream<WaveState> get stateChanged => _onStateChanged.stream;

  /// Inicia la primera oleada
  void startFirstWave() {
    if (_currentWaveIndex >= waves.length) {
      _state = WaveState.idle;
      return;
    }
    _beginWave();
  }

  /// Comienza la oleada actual
  void _beginWave() {
    if (currentWave == null) return;

    _state = WaveState.preparing;
    _onStateChanged.add(_state);

    // Pequeña pausa antes de mostrar la oleada
    Future.delayed(Duration(milliseconds: (prepareWaveDuration * 1000).toInt()),
        () {
      _state = WaveState.spawning;
      _onStateChanged.add(_state);
      _onWaveStart.add(currentWave!);

      // Resetear variables de spawn
      _currentSpawnIndex = 0;
      _spawnedCount = 0;
      _spawnTime = 0;

      // Comenzar a spawnear enemigos
      _startSpawning();
    });
  }

  /// Comienza el proceso de spawning
  void _startSpawning() {
    if (currentWave == null || _currentSpawnIndex >= currentWave!.spawns.length) {
      _state = WaveState.inProgress;
      _onStateChanged.add(_state);
      return;
    }

    _currentSpawnConfig = currentWave!.spawns[_currentSpawnIndex];
    _spawnedCount = 0;
    _spawnTime = 0;

    // Timer para spawning progresivo
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      _updateSpawning();
    });
  }

  /// Actualiza el proceso de spawning (llamado cada frame)
  void _updateSpawning() {
    if (_currentSpawnConfig == null) return;

    _spawnTime += 0.05; // 50ms

    final config = _currentSpawnConfig!;
    final delay = config.delayBetweenSpawns;

    switch (config.spawnPattern) {
      case 'burst':
        // Todos juntos
        if (_spawnedCount == 0) {
          _spawnEnemies(config);
          _spawnedCount = config.quantity;
        }
        break;

      case 'stream':
        // Uno cada delay
        while (_spawnTime >= delay && _spawnedCount < config.quantity) {
          _spawnSingleEnemy(config);
          _spawnedCount++;
          _spawnTime -= delay;
        }
        break;

      case 'random':
        // Aleatorio con distribución uniforme
        final avgDelay = delay;
        while (_spawnTime >= avgDelay && _spawnedCount < config.quantity) {
          _spawnSingleEnemy(config);
          _spawnedCount++;
          _spawnTime -= avgDelay;
        }
        break;

      case 'circle':
        // Todos juntos en círculo
        if (_spawnedCount == 0) {
          _spawnEnemies(config);
          _spawnedCount = config.quantity;
        }
        break;
    }

    // Si termino este spawn, pasar al siguiente
    if (_spawnedCount >= config.quantity) {
      _currentSpawnIndex++;
      _spawnTimer?.cancel();
      _spawnTimer =
          Timer(Duration(milliseconds: 100), () => _startSpawning());
    }
  }

  /// Detiene el spawning
  void _stopSpawning() {
    _spawnTimer?.cancel();
    _spawnTimer = null;
  }

  /// Spawnea un único enemigo
  void _spawnSingleEnemy(EnemySpawnConfig config) {
    final size = Size(400, 800); // Tamaño de pantalla ficticio
    final positions = enemyFactory.generateSpawnPositions(
      pattern: config.spawnPattern,
      quantity: 1,
      screenSize: size,
      positionVariability: config.positionVariability,
    );

    if (positions.isNotEmpty) {
      final enemy = enemyFactory.createEnemy(
        typeId: config.enemyType,
        position: positions[0],
        level: currentWaveNumber,
        difficultyMultiplier: currentWave?.difficultyMultiplier ?? 1.0,
      );

      _activeEnemies.add(enemy);
      _onEnemySpawned.add(enemy);
    }
  }

  /// Spawnea todos los enemigos de una configuración
  void _spawnEnemies(EnemySpawnConfig config) {
    final size = Size(400, 800);
    final positions = enemyFactory.generateSpawnPositions(
      pattern: config.spawnPattern,
      quantity: config.quantity,
      screenSize: size,
      positionVariability: config.positionVariability,
    );

    for (final pos in positions) {
      final enemy = enemyFactory.createEnemy(
        typeId: config.enemyType,
        position: pos,
        level: currentWaveNumber,
        difficultyMultiplier: currentWave?.difficultyMultiplier ?? 1.0,
      );

      _activeEnemies.add(enemy);
      _onEnemySpawned.add(enemy);
    }
  }

  /// Actualiza el estado de la oleada (llamar cada frame)
  void update(double deltaTime) {
    if (_state == WaveState.idle ||
        _state == WaveState.preparing ||
        _state == WaveState.transitioning) {
      return;
    }

    // Verificar si quedan enemigos vivos
    _activeEnemies.removeWhere((e) => !e.isAlive);

    if (_activeEnemies.isEmpty && _state != WaveState.completed) {
      _onWaveEnd.add(currentWave!);
      _state = WaveState.completed;
      _onStateChanged.add(_state);
      _stopSpawning();

      // Transición a siguiente oleada
      _transitionTimer?.cancel();
      _transitionTimer =
          Timer(Duration(milliseconds: (transitionDuration * 1000).toInt()),
              () {
        _currentWaveIndex++;
        if (_currentWaveIndex < waves.length) {
          _state = WaveState.transitioning;
          _onStateChanged.add(_state);
          _beginWave();
        } else {
          _state = WaveState.completed;
          _onStateChanged.add(_state);
        }
      });
    }
  }

  /// Verifica si hay más oleadas
  bool hasNextWave() => _currentWaveIndex + 1 < waves.length;

  /// Obtiene la próxima oleada
  Wave? getNextWave() {
    final nextIndex = _currentWaveIndex + 1;
    return nextIndex < waves.length ? waves[nextIndex] : null;
  }

  /// Reinicia el sistema de oleadas
  void reset() {
    _stopSpawning();
    _transitionTimer?.cancel();
    _currentWaveIndex = 0;
    _state = WaveState.idle;
    _activeEnemies.clear();
    _spawnTime = 0;
  }

  /// Limpia recursos
  void dispose() {
    _stopSpawning();
    _transitionTimer?.cancel();
    _onWaveStart.close();
    _onWaveEnd.close();
    _onEnemySpawned.close();
    _onStateChanged.close();
  }
}
