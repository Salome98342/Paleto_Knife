import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../paleto_game.dart';
import '../../controllers/world_controller.dart' show AmalgamData;

class EnemyComponent extends PositionComponent with HasGameReference<PaletoGame> {
  bool isActive = false;
  double moveSpeed = 50.0;
  Vector2 velocity = Vector2.zero();
  
  double hp = 10.0; // Puntos de vida
  
  // Bullet hell variables
  double _shootTimer = 0.0;
  double _shootInterval = 2.0; // Cambiaro segon el tipo
  double _currentRotation = 0.0;
  
  // Tipo de patron
  int _patternType = 0; // 0 = aimed, 1 = spiral, 2 = radial
  
  late Paint _paint;
  late TextPaint _textPaint;
  String _amalgamName = "";

  EnemyComponent() : super(size: Vector2(40, 40), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.red;
    _textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  bool isBoss = false;
  double maxHp = 10.0;

  void spawn(Vector2 startPos, int type, AmalgamData amalgamData, {bool isBoss = false}) {
    position.setFrom(startPos);
    _patternType = type;
    this.isBoss = isBoss;
    _amalgamName = amalgamData.name;
    
    // Assign random color based on name hash
    final hash = amalgamData.name.hashCode;
    final r = Random(hash + 1);
    final color = Color.fromARGB(
      255, 
      r.nextInt(256), 
      r.nextInt(256), 
      r.nextInt(256)
    );
    _paint.color = color;
    isActive = true;
    _shootTimer = 0;
    
    if (isBoss) {
      size = Vector2(80, 80);
      hp = 200.0 + (game.currentWave * 80.0);
      _amalgamName = "JEFE: $_amalgamName";
    } else {
      size = Vector2(40, 40);
      hp = 10.0 + (game.currentWave * 12.0); 
    }
    
    // Configurar velocidad inicial
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    velocity = Vector2(cos(angle), sin(angle)) * moveSpeed;
    
    // Balancear dificultad del patron segon tipo
    if (_patternType == 1) { // Spiral
      _shootInterval = 0.2; 
    } else if (_patternType == 2) { // Radial
      _shootInterval = 1.5;
    } else {
      _shootInterval = 1.0;
    }
    
    // Intervalo especifico para jefe
    if (isBoss) {
      _shootInterval = 0.4;
      velocity.y = velocity.y.abs(); // Asegurar de que baja rapido la primera vez hacia la zona top
      velocity.x = velocity.x.abs() * 1.5; // Movimiento horizontal mas rapido arriba
    }

    if (game.locationData.isAlert) {
      hp *= 1.5;
      velocity *= 1.5;
      _shootInterval *= 0.6;
    }

    maxHp = hp;
  }

  void despawn() {
    isActive = false;
  }

  bool takeDamage(double amount) {
    hp -= amount;
    if (hp <= 0) {
      return true; // Muerto
    }
    return false; // Sigue vivo
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    super.update(dt);

    position.add(velocity * dt);
    _bounceOffWalls();

    // Logica de disparo Bullet Hell
    _shootTimer += dt;
    if (_shootTimer >= _shootInterval) {
      _shootTimer = 0;
      _executeAttackPattern();
    }
  }

  void _executeAttackPattern() {
    if (isBoss) {
      _executeBossAdvancedPattern();
      return;
    }
    
    if (_patternType == 0) {
      // Aimed
      final playerPos = game.player.position;
      final direction = (playerPos - position).normalized();
      game.spawnBullet(position, direction * 150.0, isPlayer: false);
    } 
    else if (_patternType == 1) {
      // Spiral
      _currentRotation += 0.5; // Avanzar rotacion
      final direction = Vector2(cos(_currentRotation), sin(_currentRotation));
      game.spawnBullet(position, direction * 120.0, isPlayer: false);
    }
    else if (_patternType == 2) {
      // Radial (Nova)
      int bullets = 12;
      double step = (2 * pi) / bullets;
      for (int i = 0; i < bullets; i++) {
        final angle = i * step;
        final direction = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, direction * 100.0, isPlayer: false);
      }
    }
  }

  void _executeBossAdvancedPattern() {
    _currentRotation += 0.3; // Avanzar rotacion

    // Mezcla de patrones basada en la vida del jefe
    double healthRatio = max(0, hp) / maxHp;

    if (healthRatio > 0.6) {
      // Fase 1: Espiral denso + Disparo dirigido lento
      final direction = Vector2(cos(_currentRotation), sin(_currentRotation));
      game.spawnBullet(position, direction * 150.0, isPlayer: false);
      game.spawnBullet(position, -direction * 150.0, isPlayer: false);
      
      final playerPos = game.player.position;
      final aimDir = (playerPos - position).normalized();
      game.spawnBullet(position, aimDir * 100.0, isPlayer: false);
      
    } else if (healthRatio > 0.3) {
      // Fase 2: Radial cruzado rapido
      int bullets = 8;
      double step = (2 * pi) / bullets;
      for (int i = 0; i < bullets; i++) {
        final angle = i * step + _currentRotation;
        final direction = Vector2(cos(angle), sin(angle));
        game.spawnBullet(position, direction * 180.0, isPlayer: false);
        game.spawnBullet(position, direction * 90.0, isPlayer: false); // Capa mas lenta
      }
    } else {
      // Fase 3: Desesperacion - Doble Espiral Inversa + Disparos Radiales
      final dir1 = Vector2(cos(_currentRotation * 2), sin(_currentRotation * 2));
      final dir2 = Vector2(cos(-_currentRotation * 2), sin(-_currentRotation * 2));
      
      game.spawnBullet(position, dir1 * 200.0, isPlayer: false);
      game.spawnBullet(position, dir2 * 200.0, isPlayer: false);
      
      // Radial ocasional
      if (Random().nextDouble() < 0.3) {
        int bullets = 16;
        double step = (2 * pi) / bullets;
        for (int i = 0; i < bullets; i++) {
          final angle = i * step + _currentRotation;
          final direction = Vector2(cos(angle), sin(angle));
          game.spawnBullet(position, direction * 120.0, isPlayer: false);
        }
      }
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

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    canvas.drawRect(size.toRect(), _paint);
    _textPaint.render(
      canvas, 
      _amalgamName, 
      Vector2(size.x / 2, -15),
      anchor: Anchor.bottomCenter,
    );

    if (isBoss) {
      final barWidth = 100.0;
      final barHeight = 8.0;
      final barRect = Rect.fromLTWH(size.x / 2 - barWidth / 2, -30, barWidth, barHeight);
      final hpRect = Rect.fromLTWH(size.x / 2 - barWidth / 2, -30, barWidth * (max(0, hp) / maxHp), barHeight);
      canvas.drawRect(barRect, Paint()..color = Colors.black);
      canvas.drawRect(hpRect, Paint()..color = Colors.red);
    }
  }
}


