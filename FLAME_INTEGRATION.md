# Flame Game Engine Integration - Paleto Knife

## Overview

This document describes the integration of the **Flame game engine** into the Paleto Knife Flutter project. The integration provides a real-time action game mode while preserving the existing RPG mode.

## What Has Been Implemented

### 1. Dependencies

Added Flame 1.35.1 to `pubspec.yaml`:
```yaml
dependencies:
  flame: ^1.18.0
```

### 2. Project Structure

The game code is organized in a clean, modular structure:

```
lib/
├── main.dart                       # Main entry point (unchanged)
├── game/                           # NEW: Flame game directory
│   ├── paleto_game.dart           # Main game class (extends FlameGame)
│   ├── game_screen.dart           # Flutter wrapper for GameWidget
│   ├── player/
│   │   └── player.dart            # Player component with touch controls
│   ├── enemies/
│   │   └── enemy.dart             # Enemy component with AI
│   └── components/
│       └── bullet.dart            # Projectile component
├── screens/
│   └── game_screen.dart           # Updated to use Flame GameWidget
└── ... (existing Flutter structure)
```

### 3. Core Components

#### PaletoGame (paleto_game.dart)
- Extends `FlameGame` from Flame engine
- Manages game initialization and lifecycle
- Sets background color (#222034 - dark theme)
- Handles game-wide updates and state

#### PlayerComponent (game/player/player.dart)
- Uses `SpriteAnimationComponent` for sprite-based rendering
- Implements `TapCallbacks` for mobile touch input
- Features:
  - Touch-to-move controls
  - Automatic projectile shooting
  - Boundary detection (stays within screen)
  - Sprite animation support with fallback placeholder
  - Configurable move speed and shoot cooldown

#### EnemyComponent (game/enemies/enemy.dart)
- Sprite-animated enemy with autonomous behavior
- Features:
  - Random movement with wall bouncing
  - Configurable enemy types
  - Collision-ready structure
  - Damage and destruction methods (prepared for future expansion)

#### BulletComponent (game/components/bullet.dart)
- Fast-moving projectile component
- Features:
  - Directional movement
  - Auto-removal when off-screen
  - Sprite animation support
  - Collision-ready (prepared for hit detection)

### 4. Integration with Existing App

The Flame game is seamlessly integrated with the existing Flutter app:

- **Menu Screen**: The "MODO CLICKER" button now launches the Flame game
- **Game Screen**: Wraps the Flame game in a Flutter Scaffold with navigation
- **RPG Mode**: The existing "JUGAR" button continues to work with the RPG system
- **No Breaking Changes**: All existing Flutter code remains functional

## Sprite System

### Current State
All components use **placeholder graphics** (colored rectangles/circles) until sprite assets are added.

### How to Add Sprites

1. **Place sprite sheets** in `assets/images/`
2. **File naming convention**:
   - Player: `player_idle.png` (1600x100, 16 frames of 100x100)
   - Bullet: `bullet.png` (configurable frame size)
   - Enemy: `enemy_basic.png` (configurable, currently expects 8 frames)

3. **Sprite sheet format**:
   - Frames arranged horizontally
   - Each frame is the same size
   - Example: 16 frames of 100x100 = 1600x100 total image

4. **The code automatically loads sprites** using `SpriteAnimationData.sequenced`

### Example Sprite Configuration

```dart
SpriteAnimation.fromFrameData(
  spriteSheet,
  SpriteAnimationData.sequenced(
    amount: 16,              // Number of frames
    stepTime: 0.1,           // Seconds per frame
    textureSize: Vector2(100, 100),  // Size of each frame
  ),
);
```

## Touch Controls

### Player Control
- **Tap anywhere on screen**: Player moves to that position
- **Automatic shooting**: Player fires projectiles upward every 0.3 seconds
- **Boundary detection**: Player cannot move off-screen

### Future Enhancements
- Joystick control option
- Swipe gestures for special moves
- Multi-touch support for advanced actions

## Collision Detection (Prepared)

The components are structured to support Flame's collision detection system:

1. Add `CollisionCallbacks` mixin to components
2. Add collision shapes (e.g., `CircleHitbox`, `RectangleHitbox`)
3. Implement `onCollision` methods
4. Add `HasCollisionDetection` to PaletoGame

Example:
```dart
class BulletComponent extends SpriteAnimationComponent
    with HasGameReference<PaletoGame>, CollisionCallbacks {
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());  // Add collision box
  }
  
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is EnemyComponent) {
      other.takeDamage(10);
      removeFromParent();  // Destroy bullet on hit
    }
  }
}
```

## Performance Considerations

- **Component Pooling**: Consider object pooling for bullets/enemies if performance issues arise
- **Off-screen Culling**: Bullets automatically remove themselves when off-screen
- **Mobile Optimization**: Game runs at 60 FPS on most modern devices

## Testing

### Manual Testing
1. Run the app: `flutter run`
2. Tap "MODO CLICKER" on menu
3. Verify:
   - Blue square (player) appears at bottom
   - Tap screen to move player
   - Yellow bullets shoot upward automatically
   - Back button returns to menu

### Automated Testing
Add widget tests for game components:
```dart
testWidgets('Game loads without errors', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: GameScreen()),
  );
  expect(find.byType(GameWidget), findsOneWidget);
});
```

## Next Steps

### Recommended Enhancements
1. **Add sprite assets** for player, enemies, and bullets
2. **Implement collision detection** between bullets and enemies
3. **Add enemy spawning system** with waves/difficulty progression
4. **Implement scoring and HUD** overlay
5. **Add sound effects and music** using Flame Audio
6. **Create particle effects** for explosions and hits
7. **Add power-ups and special abilities**
8. **Implement game states** (menu, playing, paused, game over)

### Code Quality
- All components use `HasGameReference` (non-deprecated)
- Proper error handling with try-catch for asset loading
- Fallback placeholders ensure game runs without assets
- Clean separation of concerns (player, enemies, bullets)

## Troubleshooting

### Common Issues

**Issue**: Sprites don't load
- **Solution**: Check file paths in `assets/images/`
- **Fallback**: Colored placeholders will display instead

**Issue**: Touch not working
- **Solution**: Ensure `TapCallbacks` mixin is present on PlayerComponent
- **Check**: SafeArea in GameScreen might be affecting touch detection

**Issue**: Game runs slowly
- **Solution**: Profile with Flutter DevTools
- **Consider**: Reduce number of active components or sprite animation frame rate

## Resources

- [Flame Documentation](https://docs.flame-engine.org/)
- [Flame Examples](https://examples.flame-engine.org/)
- [Flutter Game Development](https://flutter.dev/games)

## Conclusion

The Flame game engine has been successfully integrated into the Paleto Knife project. The system is ready for sprite assets and game logic expansion while maintaining compatibility with the existing Flutter structure.
