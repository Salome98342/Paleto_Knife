import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class AlertWarningBorder extends PositionComponent
    with HasGameReference<FlameGame> {
  static const double borderHeight = 40;
  static const double stripesSpeed = 200;
  static const double alertDuration = 6.0;

  final bool isTopBorder;
  late Timer _alertTimer;
  late Sprite _stripesSprite;
  double _scrollOffset = 0;

  AlertWarningBorder({
    required this.isTopBorder,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _stripesSprite = Sprite(await game.images.load('stripes_pattern.png'));
    size = Vector2(game.size.x, borderHeight);
    position = Vector2(0, isTopBorder ? 0 : game.size.y - borderHeight);

    _alertTimer = Timer(alertDuration, onTick: removeFromParent)..start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _alertTimer.update(dt);
    _scrollOffset += stripesSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final spriteWidth = _stripesSprite.src.width;
    var currentX = -(_scrollOffset % spriteWidth);

    while (currentX < size.x) {
      _stripesSprite.render(
        canvas,
        position: Vector2(currentX, 0),
        size: Vector2(spriteWidth, borderHeight),
      );
      currentX += spriteWidth;
    }
  }
}
