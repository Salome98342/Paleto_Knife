import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../paleto_game.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<PaletoGame> {
  double shootCooldown = 0.0;
  double _invulnerableTimer = 0.0; // Dash invulnerability
  double _dashCooldown = 0.0;
  late Paint _paint;
  final IconData? icon;

  PlayerComponent({required Vector2 position, this.icon})
    : super(position: position, size: Vector2(30, 30), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.blue;
  }

  void dash() {
    if (_dashCooldown > 0) return;
    _invulnerableTimer = 1.0; // 1 segundo de invulnerabilidad
    _dashCooldown = 3.0; // 3 segundos de recarga
    game.shakeScreen(10.0, 0.2); // Pequeno efecto visual

    // Disparo circular (Nova)
    int bullets = 16;
    double step = (2 * math.pi) / bullets;
    for (int i = 0; i < bullets; i++) {
      final angle = i * step;
      final direction = Vector2(math.cos(angle), math.sin(angle));
      game.spawnBullet(position.clone(), direction * 300.0, isPlayer: true);
    }
  }

  bool get isInvulnerable => _invulnerableTimer > 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (shootCooldown > 0) shootCooldown -= dt;
    if (_invulnerableTimer > 0) _invulnerableTimer -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;

    if (isInvulnerable) {
      // Efecto parpadeo
      _paint.color = Colors.cyanAccent.withOpacity(0.5);
    } else {
      _paint.color = Colors.blue;
    }

    _keepInBounds();

    if (shootCooldown <= 0) {
      _shoot();
      shootCooldown = game.getPlayerFireRate != null
          ? game.getPlayerFireRate!()
          : 0.3;
    }
  }

  void _keepInBounds() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    if (position.x < halfWidth) position.x = halfWidth;
    if (position.x > game.size.x - halfWidth)
      position.x = game.size.x - halfWidth;
    if (position.y < halfHeight) position.y = halfHeight;
    if (position.y > game.size.y - halfHeight)
      position.y = game.size.y - halfHeight;
  }

  void _shoot() {
    game.spawnBullet(position.clone(), Vector2(0, -500), isPlayer: true);
  }

  @override
  void render(Canvas canvas) {
    if (icon != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            fontSize: size.x,
            fontFamily: icon!.fontFamily,
            package: icon!.fontPackage,
            color: _paint.color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2,
        ),
      );
    } else {
      canvas.drawRect(size.toRect(), _paint);
    }
  }
}
