import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math' as math;
import 'dart:math';

import 'components/bullet.dart';
import 'components/explosion.dart';
import 'components/treasure_chest.dart';
import 'player/player.dart';
import 'enemies/enemy.dart';

import '../controllers/world_controller.dart';
import '../services/audio_service.dart';

class PaletoGame extends FlameGame with PanDetector, DoubleTapDetector, TapCallbacks {
  final LocationData locationData;
  final IconData? playerIcon;
  final Function(int wave, bool isBoss)? onEnemyKilled;
  final Function(double)? onPlayerTakeDamage;
  final double Function()? getPlayerDamage;
  final double Function()? getPlayerFireRate;

  PaletoGame({
    required this.locationData,
    this.playerIcon,
    this.onEnemyKilled,
    this.getPlayerDamage,
    this.onPlayerTakeDamage,
    this.getPlayerFireRate,
  });

  // Camara Parallax Offset
  double backgroundOffsetY = 0.0;

  late PlayerComponent player;

  // Object Pooling
  final List<BulletComponent> _bulletPool = List.generate(
    300,
    (_) => BulletComponent(),
  );
  final List<EnemyComponent> enemyPool = List.generate(
    50,
    (_) => EnemyComponent(),
  );

  // Sistema de Cofres
  final List<TreasureChestComponent> treasures = [];
  List<TreasureReward> waveRewards = [];

  // Sistema de Olas (Waves)
  int currentWave = 1;
  int enemiesKilledInWave = 0;
  int enemiesToKillNextWave = 15;
  int enemiesSpawnedInWave = 0;
  double _enemySpawnTimer = 0.0;
  double get _currentSpawnInterval => math.max(0.5, 3.0 - (currentWave * 0.2));

  bool _isSpawningBoss = false;
  bool _showBossAlert = false;
  double _bossAlertTimer = 0.0;
  bool _bossMusicPlaying = false; // Controlar que la música de boss no se repita
  final TextPaint _alertPaint = TextPaint(
    style: const TextStyle(
      color: Colors.redAccent,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      fontFamily: 'PressStart2P',
      shadows: [
        Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
        Shadow(color: Colors.red, blurRadius: 10, offset: Offset(0, 0)),
      ],
    ),
  );

  // Screen shake
  double _shakeIntensity = 0.0;
  double _shakeTimer = 0.0;

  // Parallax background stars
  final math.Random _bgRandom = math.Random();
  late List<Vector2> _stars;
  final Paint _starPaint = Paint()..color = Colors.white54;

  @override
  Color backgroundColor() => const Color(0xFF1B1B2F);

  @override
  Future<void> onLoad() async {
    _stars = List.generate(
      50,
      (_) => Vector2(_bgRandom.nextDouble(), _bgRandom.nextDouble()),
    );
    await super.onLoad();

    // Configurar cantidad de enemigos según alerta
    if (locationData.isAlert) {
      enemiesToKillNextWave = 25; // +67% más enemigos en alerta
    } else {
      enemiesToKillNextWave = 15;
    }

    player = PlayerComponent(
      position: Vector2(size.x / 2, size.y * 0.8),
      icon: playerIcon,
    );
    await add(player);

    for (var b in _bulletPool) {
      await add(b);
    }
    for (var e in enemyPool) {
      await add(e);
    }
  }

  void shakeScreen(double intensity, double duration) {
    _shakeIntensity = intensity;
    _shakeTimer = duration;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (_shakeTimer > 0) {
      final dx = (_bgRandom.nextDouble() - 0.5) * 2 * _shakeIntensity;
      final dy = (_bgRandom.nextDouble() - 0.5) * 2 * _shakeIntensity;
      canvas.translate(dx, dy);
    }

    // Dibujar estrellas (Parallax 8-bit)
    for (int i = 0; i < _stars.length; i++) {
      final x = _stars[i].x * size.x;
      final y = _stars[i].y * size.y;
      final starSize = (i % 3 + 1).toDouble();
      canvas.drawRect(Rect.fromLTWH(x, y, starSize, starSize), _starPaint);
    }

    if (_showBossAlert) {
      final scale = 1.0 + 0.1 * math.sin(_bossAlertTimer * 10);
      final opacity = 0.5 + 0.5 * math.sin(_bossAlertTimer * 15).abs();

      canvas.save();
      canvas.translate(size.x / 2, size.y / 2.5);
      canvas.scale(scale);

      final style = _alertPaint.style;
      final pulsatingPaint = TextPaint(
        style: style.copyWith(color: style.color!.withValues(alpha: opacity)),
      );

      pulsatingPaint.render(
        canvas,
        "!PELIGRO EXTREMO!\nEL JEFE HA LLEGADO",
        Vector2.zero(),
        anchor: Anchor.center,
      );
      canvas.restore();
    }

    super.render(canvas);

    // Renderizar cofres
    for (var treasure in treasures) {
      if (treasure.isActive) {
        canvas.save();
        canvas.translate(treasure.position.x, treasure.position.y);
        treasure.render(canvas);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  @override
  void update(double dt) {
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0) {
        _shakeIntensity = 0.0;
      }
    }
    if (_showBossAlert) {
      _bossAlertTimer += dt;
    } else {
      _bossAlertTimer = 0.0;
    }

    super.update(dt);

    // Parallax update
    for (int i = 0; i < _stars.length; i++) {
      _stars[i].y += dt * 0.1 * (i % 3 + 1); // Diferentes velocidades
      if (_stars[i].y > 1.0) {
        _stars[i].y = 0.0;
        _stars[i].x = _bgRandom.nextDouble();
      }
    }

    _enemySpawnTimer += dt;
    if (_enemySpawnTimer >= _currentSpawnInterval) {
      _enemySpawnTimer = 0;
      _spawnEnemy();
    }

    // Actualizar cofres
    for (var treasure in treasures) {
      treasure.update(dt);
    }

    _checkCollisions();
  }

  void _spawnEnemy() {
    if (enemiesSpawnedInWave > enemiesToKillNextWave)
      return; // Esperar a que muera el jefe
    final isBoss = enemiesSpawnedInWave == enemiesToKillNextWave;

    if (isBoss && !_isSpawningBoss) {
      _isSpawningBoss = true;
      _showBossAlert = true;
      
      // Reproducir alerta de boss
      try {
        AudioService.instance.playBossAlert();
      } catch (_) {}
      
      // Reproducir música de boss según la ubicación
      if (!_bossMusicPlaying) {
        _bossMusicPlaying = true;
        try {
          final locationName = locationData.name.toLowerCase();
          if (locationName == 'america') {
            AudioService.instance.playAmericaBossMusic();
          } else if (locationName == 'asia') {
            AudioService.instance.playAsiaBossMusic();
          } else if (locationName == 'europa') {
            AudioService.instance.playEuropaBossMusic();
          }
        } catch (_) {}
      }

      Future.delayed(const Duration(seconds: 3), () {
        _showBossAlert = false;
        try {
          final enemy = enemyPool.firstWhere((e) => !e.isActive);
          final randomX = (math.Random().nextDouble() * (size.x - 80)) + 40;
          final randomAmalgam = locationData
              .amalgams[math.Random().nextInt(locationData.amalgams.length)];

          if (randomAmalgam.enemyDefinition != null) {
            enemy.spawn(
              Vector2(randomX, 50),
              randomAmalgam.enemyDefinition!,
              isBoss: true,
            );
            enemiesSpawnedInWave++;
          }
        } catch (e) {}
      });
      return;
    } else if (isBoss && _isSpawningBoss) {
      return;
    }

    try {
      final enemy = enemyPool.firstWhere((e) => !e.isActive);
      final randomX = (math.Random().nextDouble() * (size.x - 80)) + 40;

      final randomAmalgam = locationData
          .amalgams[math.Random().nextInt(locationData.amalgams.length)];

      if (randomAmalgam.enemyDefinition != null) {
        enemy.spawn(Vector2(randomX, 50), randomAmalgam.enemyDefinition!, isBoss: isBoss);
        enemiesSpawnedInWave++;
      }
    } catch (e) {}
  }

  void spawnBullet(Vector2 pos, Vector2 vel, {bool isPlayer = true}) {
    try {
      final bullet = _bulletPool.firstWhere((b) => !b.isActive);
      bullet.shoot(pos, vel, isPlayer: isPlayer);
    } catch (e) {
      // Ignorar si el pool de balas esta lleno
    }
  }

  void _checkCollisions() {
    final activeBullets = _bulletPool.where((b) => b.isActive).toList();
    final activeEnemies = enemyPool.where((e) => e.isActive).toList();

    for (var bullet in activeBullets) {
      if (!bullet.isActive) continue;

      if (bullet.isPlayerBullet) {
        for (var enemy in activeEnemies) {
          if (!enemy.isActive) continue;
          if (_checkCircleCollision(bullet, enemy)) {
            bullet.isActive = false;

            // Efecto de hit
            ExplosionHelper.spawn(this, bullet.position, color: Colors.yellow);

            // Reproducir sonido de hit
            try {
              AudioService.instance.playHitSound();
            } catch (_) {}
            
            final damage = getPlayerDamage != null ? getPlayerDamage!() : 10.0;
            final isDead = enemy.takeDamage(damage);

            if (isDead) {
              // Reproducir sonido de muerte según el tipo
              try {
                if (enemy.isBoss) {
                  AudioService.instance.playBossDeath();
                } else {
                  AudioService.instance.playEnemyDeath();
                }
              } catch (_) {}
              
              // Efecto visual de muerte
              shakeScreen(
                enemy.isBoss ? 15.0 : 8.0,
                0.15,
              ); // Mas shake si es jefe

              if (onEnemyKilled != null) {
                // Mandar el nivel y si es jefe a Flutter para la economia
                onEnemyKilled!(currentWave, enemy.isBoss);
              }

              // Si es un jefe, 30% de chance de soltar cofre
              if (enemy.isBoss && math.Random().nextDouble() < 0.3) {
                spawnTreasure(enemy.position);
              }

              enemy.despawn();

              // Progresion de Olas
              enemiesKilledInWave++;
              // +1 por el jefe
              if (enemiesKilledInWave >= enemiesToKillNextWave + 1) {
                _isSpawningBoss = false;
                _showBossAlert = false;
                _bossMusicPlaying = false; // Reset para la próxima onda de boss
                currentWave++;
                enemiesKilledInWave = 0;
                enemiesSpawnedInWave = 0;
                // Incremento más agresivo en sitios en alerta
                if (locationData.isAlert) {
                  enemiesToKillNextWave += (currentWave * 8); // +60% más que normal
                } else {
                  enemiesToKillNextWave += (currentWave * 5);
                }
                // Volver a música de gameplay después de matar boss
                Future.delayed(const Duration(milliseconds: 500), () {
                  try {
                    final locationName = locationData.name.toLowerCase();
                    if (locationName == 'america') {
                      AudioService.instance.playAmericaMusic();
                    } else if (locationName == 'asia') {
                      AudioService.instance.playAsiaMusic();
                    } else if (locationName == 'europa') {
                      AudioService.instance.playEuropaMusic();
                    }
                  } catch (_) {}
                });
                Future.delayed(const Duration(seconds: 3), () {
                  pauseEngine();
                  overlays.add('WaveClear');
                });
              }
            }
            break;
          }
        }
      } else {
        if (!player.isInvulnerable && _checkCircleCollision(bullet, player)) {
          bullet.isActive = false;
          shakeScreen(15.0, 0.3);
          ExplosionHelper.spawn(
            this,
            player.position,
            color: Colors.blueAccent,
          );
          if (onPlayerTakeDamage != null) {
            onPlayerTakeDamage!(15.0 + (currentWave * 5.0));
          }
        }
      }
    }
  }

  bool _checkCircleCollision(PositionComponent a, PositionComponent b) {
    final dx = a.position.x - b.position.x;
    final dy = a.position.y - b.position.y;
    final distanceSquared = (dx * dx) + (dy * dy);

    final r1 = a.size.x / 2;
    final r2 = b.size.x / 2;
    final radiusSumSquared = (r1 + r2) * (r1 + r2);

    return distanceSquared <= radiusSumSquared;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.position.add(info.delta.global);
  }

  @override
  void onDoubleTap() {
    player.dash();
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Intentar abrir un cofre en esta posición
    final treasure = getTreasureAt(event.localPosition);
    if (treasure != null) {
      final index = treasures.indexOf(treasure);
      openTreasure(index);
    }
  }

  void resetGame() {
    currentWave = 1;
    enemiesKilledInWave = 0;
    enemiesSpawnedInWave = 0;
    enemiesToKillNextWave = 15;
    waveRewards.clear();
    for (var t in treasures) {
      t.despawn();
    }
    treasures.clear();

    for (var b in _bulletPool) {
      b.isActive = false;
    }
    for (var e in enemyPool) {
      e.despawn();
    }

    player.position = Vector2(size.x / 2, size.y * 0.8);
  }

  void spawnTreasure(Vector2 position) {
    final treasure = TreasureChestComponent();
    treasure.spawn(position);
    treasures.add(treasure);
  }

  void openTreasure(int index) {
    if (index >= 0 && index < treasures.length) {
      final treasure = treasures[index];
      if (!treasure.isOpened) {
        treasure.open();
        
        // Agregar recompensa a la lista de rewards
        final reward = TreasureReward(
          'Cofre Abierto',
          'Has obtenido recursos del jefe',
          Random().nextInt(50) + 50, // Gemas aleatorias
        );
        waveRewards.add(reward);
      }
    }
  }

  TreasureChestComponent? getTreasureAt(Vector2 clickPos) {
    for (int i = treasures.length - 1; i >= 0; i--) {
      if (treasures[i].checkClick(clickPos)) {
        return treasures[i];
      }
    }
    return null;
  }

  double getWaveRecoveryPercentage() {
    if (locationData.amalgams.isEmpty) return 0.0;
    return (enemiesKilledInWave / (enemiesToKillNextWave + 1)) * 100;
  }
}

class TreasureReward {
  final String title;
  final String description;
  final int gemAmount;

  TreasureReward(this.title, this.description, this.gemAmount);
}

