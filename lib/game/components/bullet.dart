import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../paleto_game.dart';

class BulletComponent extends PositionComponent
    with HasGameReference<PaletoGame> {
  bool isActive = false;
  Vector2 velocity = Vector2.zero();
  bool isPlayerBullet =
      true; // True if it hurts enemies, false if it hurts player
  late Paint _paint;

  BulletComponent() : super(size: Vector2(10, 10), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.yellow;
  }

  void shoot(Vector2 startPos, Vector2 vel, {bool isPlayer = true}) {
    position.setFrom(startPos);
    velocity.setFrom(vel);
    isPlayerBullet = isPlayer;
    isActive = true;
    _paint.color = isPlayer ? Colors.yellow : Colors.redAccent;
  }

  @override
  void update(double dt) {
    if (!isActive) return;

    position.add(velocity * dt);

    // Destruir el proyectil si sale de la pantalla extendida (pooling)
    if (position.x < -50 ||
        position.x > game.size.x + 50 ||
        position.y < -50 ||
        position.y > game.size.y + 50) {
      isActive = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
  }
}
