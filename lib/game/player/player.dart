import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../paleto_game.dart';
import '../components/bullet.dart';

/// Player component - handles the player character behavior in the game
/// 
/// Features:
/// - Touch-to-move controls
/// - Automatic projectile shooting
/// - Screen boundary detection
/// - Simple sprite rendering
class PlayerComponent extends SpriteComponent
    with HasGameReference<PaletoGame>, TapCallbacks {
  
  PlayerComponent({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(100, 100),
          anchor: Anchor.center,
        );

  // Movement configuration
  final double moveSpeed = 300.0;
  Vector2? targetPosition;

  // Shooting configuration
  double shootCooldown = 0.0;
  final double shootInterval = 0.3; // Shoots every 0.3 seconds

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _createPlaceholder();

    priority = 10;
  }

  /// Creates a temporary visual placeholder (blue rectangle)
  void _createPlaceholder() {
    final paint = Paint()..color = Colors.blue;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 100, 100),
      paint,
    );
    
    final picture = recorder.endRecording();
    final image = picture.toImageSync(100, 100);
    
    sprite = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update shooting cooldown
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }

    // Move towards target position (touch controls)
    if (targetPosition != null) {
      final direction = targetPosition! - position;
      final distance = direction.length;

      if (distance < 5) {
        // Reached target
        targetPosition = null;
      } else {
        // Move towards target
        final velocity = direction.normalized() * moveSpeed * dt;
        position.add(velocity);
      }
    }

    // Keep player within screen bounds
    _keepInBounds();

    // Auto-shoot projectiles
    if (shootCooldown <= 0) {
      _shoot();
      shootCooldown = shootInterval;
    }
  }

  /// Keeps the player within screen boundaries
  void _keepInBounds() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    if (position.x < halfWidth) {
      position.x = halfWidth;
    } else if (position.x > game.size.x - halfWidth) {
      position.x = game.size.x - halfWidth;
    }

    if (position.y < halfHeight) {
      position.y = halfHeight;
    } else if (position.y > game.size.y - halfHeight) {
      position.y = game.size.y - halfHeight;
    }
  }

  /// Shoots a projectile upwards
  void _shoot() {
    final bullet = BulletComponent(
      position: position.clone(),
      direction: Vector2(0, -1), // Shoot upwards
    );
    
    game.add(bullet);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Set target position when screen is tapped
    targetPosition = event.localPosition;
  }
}
