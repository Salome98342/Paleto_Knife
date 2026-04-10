import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../paleto_game.dart';
import '../../game_logic/enemy_system/enemy_types.dart';
import '../../game_logic/enemy_system/attack_pattern.dart';
import '../../game_logic/enemy_system/enemy_behavior.dart';
import '../../models/element_type.dart';

class EnemyComponent extends PositionComponent
    with HasGameReference<PaletoGame> {
  bool isActive = false;
  double moveSpeed = 50.0;
  Vector2 velocity = Vector2.zero();

  double hp = 10.0;
  double maxHp = 10.0;

  // Bullet hell variables
  double _shootTimer = 0.0;
  double _currentRotation = 0.0;

  // Datos del enemigo
  late EnemyTypeDefinition enemyDefinition;
  bool isBoss = false;

  late Paint _paint;
  late Paint _elementPaint;
  late TextPaint _textPaint;
  String _displayName = "";

  // Variables de comportamiento
  Vector2 _behaviorVelocity = Vector2.zero();
  double _behaviorTimer = 0.0;

  EnemyComponent() : super(size: Vector2(40, 40), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.grey;
    _elementPaint = Paint();
    _textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  void spawn(
    Vector2 startPos,
    EnemyTypeDefinition definition, {
    bool isBoss = false,
  }) {
    position.setFrom(startPos);
    enemyDefinition = definition;
    this.isBoss = isBoss;
    _displayName = definition.name;

    // Configurar HP
    if (isBoss) {
      size = Vector2(80, 80);
      hp = definition.baseHealth * (2.0 + (game.currentWave * 0.5));
      _displayName = "👑 ${definition.name}";
    } else {
      _configureSizeByRole();
      hp = definition.baseHealth + (game.currentWave * 5.0);
    }

    maxHp = hp;

    // Configurar color por elemento
    _paint.color = _getElementColor(definition.element);
    _elementPaint.color = _getElementColor(definition.element).withValues(alpha: 0.5);

    // Velocidad inicial basada en comportamiento
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    _behaviorVelocity = Vector2(cos(angle), sin(angle)) * definition.behavior.speed;
    velocity = _behaviorVelocity;

    // Aplicar modificadores por Alert
    if (game.locationData.isAlert) {
      hp *= 1.5;
      maxHp = hp;
      _behaviorVelocity *= 1.3;
      velocity = _behaviorVelocity;
    }

    isActive = true;
    _shootTimer = 0;
    _behaviorTimer = 0;
  }

  void _configureSizeByRole() {
    switch (enemyDefinition.role.toLowerCase()) {
      case 'grunt':
        size = Vector2(30, 30);
        break;
      case 'bruiser':
        size = Vector2(50, 50);
        break;
      case 'shooter':
        size = Vector2(35, 35);
        break;
      case 'tank':
        size = Vector2(60, 60);
        break;
      case 'elite':
        size = Vector2(45, 45);
        break;
      default:
        size = Vector2(40, 40);
    }
  }

  Color _getElementColor(ElementType element) {
    switch (element) {
      case ElementType.fire:
        return Colors.red;
      case ElementType.water:
        return Colors.blue;
      case ElementType.earth:
        return Colors.brown;
      case ElementType.wind:
        return Colors.cyan;
      case ElementType.lava:
        return Colors.deepOrange;
      case ElementType.plant:
        return Colors.green;
      case ElementType.neutral:
        return Colors.grey;
      case ElementType.master:
        return Colors.purple;
    }
  }

  void despawn() {
    isActive = false;
  }

  bool takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      return true;
    }
    return false;
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    super.update(dt);

    // Actualizar comportamiento de movimiento
    _updateBehavior(dt);
    position.add(velocity * dt);
    _bounceOffWalls();

    // Lógica de disparo
    _shootTimer += dt;
    if (_shootTimer >= enemyDefinition.attackPattern.cooldown) {
      _shootTimer = 0;
      _executeAttackPattern();
    }
  }

  void _updateBehavior(double dt) {
    _behaviorTimer += dt;

    switch (enemyDefinition.behavior.type) {
      case BehaviorType.chase:
        _updateChase();
        break;
      case BehaviorType.keepDistance:
        _updateKeepDistance();
        break;
      case BehaviorType.wander:
        _updateWander(dt);
        break;
      case BehaviorType.circlePlayer:
        _updateCirclePlayer();
        break;
      case BehaviorType.stationary:
        velocity = Vector2.zero();
        break;
    }
  }

  void _updateChase() {
    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();
    velocity = direction * enemyDefinition.behavior.speed;
  }

  void _updateKeepDistance() {
    final playerPos = game.player.position;
    final distance = (playerPos - position).length;
    final direction = (playerPos - position).normalized();

    if (distance < enemyDefinition.behavior.preferredDistance) {
      velocity = -direction * enemyDefinition.behavior.speed;
    } else if (distance > enemyDefinition.behavior.preferredDistance * 1.5) {
      velocity = direction * enemyDefinition.behavior.speed;
    } else {
      velocity *= 0.8;
    }
  }

  void _updateWander(double dt) {
    if (_behaviorTimer > 2.0) {
      _behaviorTimer = 0;
      final random = Random();
      final angle = random.nextDouble() * 2 * pi;
      _behaviorVelocity = Vector2(cos(angle), sin(angle)) * enemyDefinition.behavior.speed;
    }
    velocity = _behaviorVelocity;
  }

  void _updateCirclePlayer() {
    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();
    final distance = (playerPos - position).length;
    final perp = Vector2(-direction.y, direction.x);

    // Mantener distancia mientras orbita
    Vector2 movement = direction * (distance - enemyDefinition.behavior.preferredDistance) * 0.01;
    movement += perp * enemyDefinition.behavior.speed * 0.5;

    velocity = movement;
  }

  void _executeAttackPattern() {
    if (isBoss) {
      _executeBossAttackPattern();
      return;
    }

    final pattern = enemyDefinition.attackPattern;
    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();

    switch (pattern.type) {
      case AttackPatternType.straight:
        game.spawnBullet(position, direction * pattern.bulletSpeed, isPlayer: false);
        break;

      case AttackPatternType.spread:
        final spreadAngle = pattern.spreadAngle;
        final baseAngle = atan2(direction.y, direction.x);

        for (int i = 0; i < pattern.bulletCount; i++) {
          final angle = baseAngle + (i - (pattern.bulletCount - 1) / 2) * (spreadAngle / pattern.bulletCount);
          final bulletDir = Vector2(cos(angle), sin(angle));
          game.spawnBullet(position, bulletDir * pattern.bulletSpeed, isPlayer: false);
        }
        break;

      case AttackPatternType.radial:
        final step = (2 * pi) / pattern.bulletCount;
        for (int i = 0; i < pattern.bulletCount; i++) {
          final angle = i * step + _currentRotation;
          final bulletDir = Vector2(cos(angle), sin(angle));
          game.spawnBullet(position, bulletDir * pattern.bulletSpeed, isPlayer: false);
        }
        _currentRotation += 0.3;
        break;

      case AttackPatternType.aimed:
        game.spawnBullet(position, direction * pattern.bulletSpeed, isPlayer: false);
        break;
    }
  }

  void _executeBossAttackPattern() {
    double healthRatio = max(0, hp) / maxHp;

    _currentRotation += 0.4; // Rotación consistente

    /// FASE 1: Saludable (100% - 70% HP)
    if (healthRatio > 0.7) {
      // Patrón 1: Espiral densa
      for (int i = 0; i < 3; i++) {
        final angle = _currentRotation + (i * (2 * pi / 3));
        final dir = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, dir * 150.0, isPlayer: false);
      }

      // Patrón 2: Disparo dirigido lento cada 2 tiempos
      if (_shootTimer.toInt() % 2 == 0) {
        final playerPos = game.player.position;
        final direction = (playerPos - position).normalized();
        game.spawnBullet(position, direction * 120.0, isPlayer: false);
      }
    }
    /// FASE 2: Moderado (70% - 40% HP)
    else if (healthRatio > 0.4) {
      // Patrón 1: Doble espiral cruzada
      for (int i = 0; i < 4; i++) {
        final angle = _currentRotation + (i * (2 * pi / 4));
        final dir = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, dir * 160.0, isPlayer: false);

        final dir2 = Vector2(cos(angle + pi), sin(angle + pi));
        game.spawnBullet(position, dir2 * 160.0, isPlayer: false);
      }

      // Patrón 2: Radial ocasional
      if (Random().nextDouble() < 0.2) {
        for (int i = 0; i < 12; i++) {
          final angle = (i * (2 * pi / 12));
          final dir = Vector2(cos(angle), sin(angle));
          game.spawnBullet(position, dir * 140.0, isPlayer: false);
        }
      }

      // Patrón 3: Spawnear enemigos cada 5 tiempos
      if (_shootTimer.toInt() % 5 == 0 && _shootTimer.toInt() % 6 != 0) {
        _spawnBossMinions();
      }
    }
    /// FASE 3: Crítico (40% - 0% HP)
    else {
      // Patrón 1: Ataque frenético - Triple espiral
      for (int i = 0; i < 6; i++) {
        final angle = _currentRotation * 2 + (i * (2 * pi / 6));
        final dir = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, dir * 200.0, isPlayer: false);
      }

      // Patrón 2: Espiral inversa simultánea
      for (int i = 0; i < 6; i++) {
        final angle = -_currentRotation * 2 + (i * (2 * pi / 6));
        final dir = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, dir * 180.0, isPlayer: false);
      }

      // Patrón 3: Disparos apuntados rápidos
      if (_shootTimer % 0.3 < 0.15) {
        final playerPos = game.player.position;
        final direction = (playerPos - position).normalized();
        game.spawnBullet(position, direction * 200.0, isPlayer: false);
      }

      // Patrón 4: Spawnear enemigos frecuentemente
      if (_shootTimer.toInt() % 3 == 0 && _shootTimer.toInt() % 4 != 0) {
        _spawnBossMinions();
      }

      // Patrón 5: Radial masivo
      if (Random().nextDouble() < 0.3) {
        for (int i = 0; i < 16; i++) {
          final angle = (i * (2 * pi / 16)) + _currentRotation;
          final dir = Vector2(cos(angle), sin(angle));
          game.spawnBullet(position, dir * 120.0, isPlayer: false);
        }
      }
    }
  }

  void _spawnBossMinions() {
    try {
      // Spawnear 2-3 enemigos menores alrededor del jefe
      final spawnCount = Random().nextInt(2) + 2;

      for (int i = 0; i < spawnCount; i++) {
        EnemyComponent? enemy;
        try {
          enemy = game.enemyPool.firstWhere((e) => !e.isActive);
        } catch (e) {
          // No hay enemigos disponibles en el pool
          continue;
        }

        // Calcular posición alrededor del jefe
        final angle = (i * (2 * pi / spawnCount)) + Random().nextDouble();
        final spawnDistance = 120.0;
        final spawnPos = position +
            Vector2(cos(angle), sin(angle)) * spawnDistance;

        // Seleccionar un enemigo aleatorio de la región
        if (game.locationData.amalgams.isNotEmpty) {
          final randomAmalgam = game
              .locationData
              .amalgams[Random().nextInt(game.locationData.amalgams.length)];

          if (randomAmalgam.enemyDefinition != null) {
            enemy.spawn(spawnPos, randomAmalgam.enemyDefinition!, isBoss: false);
          }
        }
      }
    } catch (e) {
      // Ignorar errores de spawn
    }
  }

  void _bounceOffWalls() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    if (position.x < halfWidth || position.x > game.size.x - halfWidth) {
      velocity.x = -velocity.x;
      position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
    }

    final maxY = isBoss ? game.size.y * 0.35 : game.size.y - halfHeight;
    final minY = isBoss ? game.size.y * 0.05 : halfHeight;

    if (position.y < minY || position.y > maxY) {
      velocity.y = -velocity.y;
      position.y = position.y.clamp(minY, maxY);
    }
  }

  void _drawShape(Canvas canvas) {
    final role = enemyDefinition.role.toLowerCase();

    switch (role) {
      case 'grunt':
        // Cuadrado simple
        canvas.drawRect(size.toRect(), _paint);
        break;

      case 'bruiser':
        // Hexágono (círculo con bordes)
        _drawPolygon(canvas, 6);
        break;

      case 'shooter':
        // Triángulo
        _drawPolygon(canvas, 3);
        break;

      case 'tank':
        // Octágono
        _drawPolygon(canvas, 8);
        break;

      case 'elite':
        // Stella (estrella)
        _drawStar(canvas);
        break;

      case 'boss':
        // Corona de espinas
        _drawBossShape(canvas);
        break;

      default:
        canvas.drawRect(size.toRect(), _paint);
    }
  }

  void _drawPolygon(Canvas canvas, int sides) {
    final path = Path();
    final radius = size.x / 2;
    final step = (2 * pi) / sides;

    for (int i = 0; i < sides; i++) {
      final angle = i * step - pi / 2;
      final x = radius * cos(angle);
      final y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, _paint);
    canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawStar(Canvas canvas) {
    final path = Path();
    final radius = size.x / 2;
    final points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi) / points - pi / 2;
      final r = (i % 2 == 0) ? radius : radius * 0.4;
      final x = r * cos(angle);
      final y = r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, _paint);
    canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _drawBossShape(Canvas canvas) {
    // Círculo con púas
    canvas.drawCircle(Offset.zero, size.x / 2, _paint);

    const spikeCount = 12;
    const spikeLength = 15.0;
    final step = (2 * pi) / spikeCount;

    for (int i = 0; i < spikeCount; i++) {
      final angle = i * step;
      final start = Vector2(cos(angle), sin(angle)) * (size.x / 2);
      final end = Vector2(cos(angle), sin(angle)) * (size.x / 2 + spikeLength);

      canvas.drawLine(
        start.toOffset(),
        end.toOffset(),
        Paint()..strokeWidth = 2..color = _paint.color);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    // Dibujar forma distintiva
    _drawShape(canvas);

    // Dibujar nombre
    _textPaint.render(
      canvas,
      _displayName,
      Vector2(0, -size.y / 2 - 15),
      anchor: Anchor.bottomCenter,
    );

    // Barra de vida para jefes y élites
    if (isBoss || enemyDefinition.role.toLowerCase() == 'elite') {
      const barWidth = 80.0;
      const barHeight = 6.0;

      final barRect = Rect.fromLTWH(
        -barWidth / 2,
        -size.y / 2 - 35,
        barWidth,
        barHeight,
      );
      final hpRect = Rect.fromLTWH(
        -barWidth / 2,
        -size.y / 2 - 35,
        barWidth * (max(0, hp) / maxHp),
        barHeight,
      );

      canvas.drawRect(barRect, Paint()..color = Colors.black);
      canvas.drawRect(hpRect, Paint()..color = Colors.red);
    }
  }
}
