import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player/player.dart';

/// Main game class that manages the game lifecycle, components, and updates
/// 
/// Current features:
/// - Player initialization
/// - Background color configuration
/// - Game component management
/// 
/// Future enhancements:
/// - Enemy spawning system
/// - Collision detection
/// - Score tracking
/// - Power-up system
class PaletoGame extends FlameGame {
  PaletoGame() : super();

  late PlayerComponent player;

  @override
  Color backgroundColor() => const Color(0xFF222034);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize player at bottom-center of screen
    player = PlayerComponent(
      position: Vector2(
        size.x / 2,
        size.y * 0.8,
      ),
    );

    // Add player to the game world
    await add(player);
    
    // TODO: Set up enemy spawning system
    // TODO: Initialize collision detection
  }
}
