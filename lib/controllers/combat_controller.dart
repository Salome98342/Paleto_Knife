import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/projectile.dart';
import '../models/element_type.dart';
import '../game_logic/projectile_system.dart';
import '../game_logic/player_controller.dart';
import '../game_logic/enemy_controller.dart';
import '../game_logic/world_manager.dart';
import 'game_controller.dart';
import 'chef_controller.dart';
import '../services/audio_service.dart';

/// Controlador principal del sistema de combate
/// Integra jugador, enemigos, proyectiles y mundos
class CombatController extends ChangeNotifier {
  late ProjectileSystem _projectileSystem;
  late PlayerController _playerController;
  late EnemyController _enemyController;
  late WorldManager _worldManager;

  GameController? _gameController;
  ChefController?
  _chefController; // Referencia al GameController para procesar drops y recompensas

  Timer? _gameLoopTimer;

  bool _isInitialized = false;
  bool _isPaused = false;
  int _enemiesDefeatedThisLevel = 0;

  Size _screenSize = const Size(400, 800);

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPaused => _isPaused;
  Player get player => _playerController.player;
  Enemy get enemy => _enemyController.enemy;
  List<Projectile> get projectiles => _projectileSystem.projectiles;
  int get currentLevel => _worldManager.currentLevel;
  int get currentWorldNumber => _worldManager.currentWorldNumber;
  WorldManager get worldManager => _worldManager;
  double get currentGold => _gameController?.gold ?? 0;

  /// Inicializa el sistema de combate
  void initialize(
    Size screenSize, {
    GameController? gameController,
    ChefController? chefController,
  }) {
    if (_isInitialized) return;

    _screenSize = screenSize;
    _gameController = gameController;
    _chefController = chefController;

    // Inicializar sistemas
    _projectileSystem = ProjectileSystem();
    _worldManager = WorldManager();

    // Crear jugador
    final player = Player(
      position: Offset(screenSize.width / 2, screenSize.height - 100),
    );
    _playerController = PlayerController(
      player: player,
      projectileSystem: _projectileSystem,
    );

    // Crear enemigo inicial
    final enemy = Enemy.createForLevel(
      1,
      _worldManager.currentElement,
      position: Offset(screenSize.width / 2, 150),
    );
    _enemyController = EnemyController(
      enemy: enemy,
      projectileSystem: _projectileSystem,
    );

    // Iniciar ataques automaticos
    _playerController.startAutoAttack();
    _enemyController.startAutoAttack();

    // Iniciar game loop
    _startGameLoop();

    _isInitialized = true;
    notifyListeners();
  }

  /// Actualiza el tamano de la pantalla
  void updateScreenSize(Size newSize) {
    _screenSize = newSize;
  }

  /// Inicia el bucle principal del juego
  void _startGameLoop() {
    _gameLoopTimer?.cancel();

    const frameRate = 60;
    const frameDuration = Duration(microseconds: 1000000 ~/ frameRate);

    _gameLoopTimer = Timer.periodic(frameDuration, (timer) {
      if (_isPaused) return;

      final deltaTime = frameDuration.inMicroseconds / 1000000.0;
      _update(deltaTime);
    });
  }

  /// Actualizacion principal del juego
  void _update(double deltaTime) {
    // Sincronizar stats desde GameController si existe
    if (_gameController != null) {
      _playerController.player.baseDamage = _gameController!.baseDamage;
      _playerController.player.attackSpeed = _gameController!.attackSpeed;
      _playerController.player.critChance = _gameController!.critChance;
      _playerController.player.critMultiplier = _gameController!.critMultiplier;
    }

    // Actualizar jugador
    _playerController.update(deltaTime);

    // Actualizar enemigo
    _enemyController.update(deltaTime);

    // Actualizar posicion del jugador al enemigo (para ataques dirigidos)
    _enemyController.updatePlayerPosition(_playerController.player.position);

    // Actualizar proyectiles
    _projectileSystem.update(deltaTime, _screenSize);

    // Verificar colisiones
    _checkCollisions();

    // Verificar si el enemigo fue derrotado
    if (!_enemyController.isAlive) {
      _onEnemyDefeated();
    }

    // Verificar si el jugador fue derrotado
    if (!_playerController.isAlive) {
      _onPlayerDefeated();
    }

    notifyListeners();
  }

  /// Verifica las colisiones entre proyectiles y enemigos/jugador
  void _checkCollisions() {
    // Proyectiles del jugador vs enemigo
    if (_enemyController.isAlive) {
      final hits = _projectileSystem.checkPlayerProjectileCollisions(
        _enemyController.enemy.getHitbox(),
      );

      for (var projectile in hits) {
        _enemyController.takeDamage(projectile.damage);
      }
    }

    // Proyectiles del enemigo vs jugador
    if (_playerController.isAlive) {
      final hits = _projectileSystem.checkEnemyProjectileCollisions(
        _playerController.player.getHitbox(),
      );

      for (var projectile in hits) {
        _playerController.takeDamage(projectile.damage);
      }
    }
  }

  /// Se llama cuando el enemigo es derrotado
  void _onEnemyDefeated() {
    final defeatedEnemy = _enemyController.enemy;
    final defeatedLevel = _worldManager.currentLevel;

    debugPrint(
      'Enemigo derrotado! (${defeatedEnemy.tier.name}, Lvl $defeatedLevel)',
    );

    AudioService.instance.playHitSound();

    // Detener ataques
    _enemyController.stopAutoAttack();

    // Procesar recompensas si hay un GameController disponible
    if (_gameController != null) {
      // Otorgar oro
      final goldReward = defeatedEnemy.getGoldReward();
      _gameController!.addGold(goldReward);
      AudioService.instance.playCoinCollect();

      // Procesar drops (cofres/corazones)
      _gameController!.processEnemyDefeat(defeatedLevel);

      // Fragmentos de cuchillo en jefes
      if (defeatedEnemy.tier == EnemyTier.boss) {
        _gameController!.addKnifeFragments(5); // 5 fragmentos por jefe
        _chefController?.grantBossTokens();
      } else if (defeatedEnemy.tier == EnemyTier.miniBoss) {
        _gameController!.addKnifeFragments(2); // 2 fragmentos por mini-jefe
      }

      // Solo avanza de nivel cada 5 enemigos (para que la progresion no sea tan acelerada)
      _enemiesDefeatedThisLevel++;
      if (_enemiesDefeatedThisLevel >= 5 || defeatedEnemy.isBoss) {
        _enemiesDefeatedThisLevel = 0;

        final nextLevel = defeatedLevel + 1;
        _gameController!.setCurrentLevel(nextLevel);
        // Avanzar nivel en el WorldManager
        _worldManager.advanceLevel();
      }
    }

    // Esperar un momento antes de crear nuevo enemigo
    Future.delayed(const Duration(milliseconds: 500), () {
      _spawnNextEnemy();
    });
  }

  /// Se llama cuando el jugador es derrotado
  void _onPlayerDefeated() {
    debugPrint('Jugador derrotado!');
    pause();

    // Aqui podrias mostrar un dialogo de Game Over
  }

  /// Spawns el siguiente enemigo
  void _spawnNextEnemy() {
    final currentLevel = _worldManager.currentLevel;
    final currentElement = _worldManager.currentElement;
    final isBoss = _worldManager.isCurrentLevelBoss;

    // Crear nuevo enemigo
    _enemyController.spawnNewEnemy(
      currentLevel,
      currentElement,
      Offset(_screenSize.width / 2, 150),
      isBoss: isBoss,
    );
    _enemyController.startAutoAttack();

    // Limpiar proyectiles
    _projectileSystem.clear();

    // Cambiar música según si es boss o not
    if (isBoss) {
      _playBossMusic(currentElement);
    } else {
      _playGameplayMusicForElement(currentElement);
    }

    debugPrint('Nivel $currentLevel - ${isBoss ? "JEFE" : "Amalgama normal"}');
    notifyListeners();
  }

  /// Helper para reproducir música de boss según el elemento de la región
  void _playBossMusic(ElementType element) {
    try {
      switch (element) {
        case ElementType.water:
          AudioService.instance.playAmericaBossMusic();
          break;
        case ElementType.fire:
          AudioService.instance.playAsiaBossMusic();
          break;
        case ElementType.earth:
          AudioService.instance.playEuropaBossMusic();
          break;
        default:
          // Para neutral y master, usar gameplay music
          break;
      }
    } catch (e) {
      debugPrint('Error playing boss music: $e');
    }
  }

  /// Helper para reproducir música de gameplay según el elemento
  void _playGameplayMusicForElement(ElementType element) {
    try {
      switch (element) {
        case ElementType.water:
          AudioService.instance.playAmericaMusic();
          break;
        case ElementType.fire:
          AudioService.instance.playAsiaMusic();
          break;
        case ElementType.earth:
          AudioService.instance.playEuropaMusic();
          break;
        default:
          // Para neutral y master, usar gameplay music normal
          AudioService.instance.playGameplayMusic();
          break;
      }
    } catch (e) {
      debugPrint('Error playing gameplay music: $e');
    }
  }

  /// Mueve el jugador a una posicion horizontal especifica (movimiento tactil)
  void movePlayerToX(double x) {
    if (_isPaused) return;
    _playerController.moveToX(x, _screenSize.width);
    notifyListeners();
  }

  /// Mueve el jugador a una posicion libre dentro de la arena
  void movePlayerToPosition(Offset localPosition) {
    if (_isPaused) return;
    _playerController.moveTo(localPosition, _screenSize);
    notifyListeners();
  }

  /// Maneja el drag del jugador
  void handlePlayerDrag(DragUpdateDetails details) {
    if (_isPaused) return;
    movePlayerToPosition(details.localPosition);
  }

  /// Activa el poder especial del jugador
  bool activatePower() {
    final activated = _playerController.activatePower();
    if (activated) {
      AudioService.instance.playPowerupSound();
      notifyListeners();
    }
    return activated;
  }

  /// Pausa el juego
  void pause() {
    _isPaused = true;
    _playerController.stopAutoAttack();
    _enemyController.stopAutoAttack();
    notifyListeners();
  }

  /// Reanuda el juego
  void resume() {
    _isPaused = false;
    _playerController.startAutoAttack();
    _enemyController.startAutoAttack();
    notifyListeners();
  }

  /// Reinicia el combate
  void reset() {
    _projectileSystem.clear();
    _worldManager.reset();

    // Reiniciar al nivel 1
    _enemiesDefeatedThisLevel = 0;
    _enemyController.resetForLevel(1, _worldManager.currentElement);
    _playerController.reset();

    _playerController.startAutoAttack();
    _enemyController.startAutoAttack();

    _isPaused = false;
    notifyListeners();
  }

  /// Obtiene el rectangulo de colision del jugador (para evitar el error isAlive)
  bool get isPlayerAlive => player.isAlive;

  /// Limpia recursos
  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _playerController.dispose();
    _enemyController.dispose();
    super.dispose();
  }
}
