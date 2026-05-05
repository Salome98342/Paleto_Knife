import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DebugCircleMarkerComponent extends PositionComponent {
  final Color baseColor;
  final double radius;
  final double duration;
  double _elapsed = 0.0;

  DebugCircleMarkerComponent({
    required Vector2 position,
    required this.baseColor,
    this.radius = 16.0,
    this.duration = 0.45,
  }) : super(
          position: position,
          anchor: Anchor.center,
          size: Vector2.all(radius * 2),
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final currentRadius = radius * (1.0 + (progress * 0.2));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = baseColor.withValues(alpha: 1.0 - progress);

    canvas.drawCircle(Offset.zero, currentRadius, paint);
  }
}