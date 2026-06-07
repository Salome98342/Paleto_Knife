import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../paleto_game.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<PaletoGame> {
  double shootCooldown = 0.0;
  double _invulnerableTimer = 0.0; // Dash invulnerability
  double _dashCooldown = 0.0;
  late Paint _paint;
  
  // Campo necesario para el constructor
  final IconData? icon;
  final String? chefId; 
  
  // Imagen animada del chef
  final List<_AnimatedFrame> _chefFrames = [];
  int _chefFrameIndex = 0;
  double _chefFrameElapsed = 0.0;
  
  // === AJUSTES FINOS DE LA CAJA ROJA ===
  static const double _hitboxOffsetXRatio = 0.0;
  static const double _hitboxWidthRatio = 0.42;
  static const double _hitboxHeightRatio = 0.56;
  static const double _hitboxOffsetYRatio = 0.0;
  
  // Flag para mostrar/ocultar hitbox debug (Definición única)
  final bool _showHitbox = true; 

  PlayerComponent({
    required Vector2 position,
    this.icon,
    this.chefId,
  }) : super(position: position, size: Vector2(72, 84), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.blue;
  }

  Future<ui.Codec> _decodeCodec(ByteData bytes) async {
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    return codec;
  }

  Future<void> _loadChefFramesWithFallback() async {
    const candidates = [
      'lib/assets/images/cocinero_linea/linea_spin.gif',
      'lib/assets/images/cocinero_linea/linea.png',
    ];

    for (final key in candidates) {
      try {
        final bytes = await rootBundle.load(key);
        final codec = await _decodeCodec(bytes);

        _chefFrames.clear();
        _chefFrameIndex = 0;
        _chefFrameElapsed = 0.0;

        final frameCount = codec.frameCount;
        for (var frameIndex = 0; frameIndex < frameCount; frameIndex++) {
          final frame = await codec.getNextFrame();
          _chefFrames.add(
            _AnimatedFrame(
              image: frame.image,
              duration: frame.duration > Duration.zero
                  ? frame.duration
                  : const Duration(milliseconds: 83),
            ),
          );
        }
        return;
      } catch (e) {
        debugPrint('[PlayerComponent] ❌ Failed key $key: $e');
      }
    }
    _chefFrames.clear();
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      if (chefId == 'r_fire_1') {
        await _loadChefFramesWithFallback();
      }
    } catch (e) {
      debugPrint('[PlayerComponent] ❌ ERROR in onLoad: $e');
      _chefFrames.clear();
    }
  }
  
  Rect getHitbox() {
    final hitboxRect = _getLocalHitboxRect();
    final topLeft = Offset(position.x - size.x / 2, position.y - size.y / 2);
    return hitboxRect.shift(topLeft);
  }

  Vector2 _getWorldVisibleCenter() {
    final spriteRect = _getLocalSpriteRect();
    final topLeft = Vector2(position.x - size.x / 2, position.y - size.y / 2);

    return Vector2(
      topLeft.x + spriteRect.center.dx,
      topLeft.y + spriteRect.center.dy,
    );
  }

  void dash() {
    if (_dashCooldown > 0) return;
    _invulnerableTimer = 1.0; 
    _dashCooldown = 3.0; 
    game.shakeScreen(10.0, 0.2);

    final origin = _getWorldVisibleCenter();
    int bullets = 16;
    double step = (2 * math.pi) / bullets;
    for (int i = 0; i < bullets; i++) {
      final angle = i * step;
      final direction = Vector2(math.cos(angle), math.sin(angle));
      game.spawnBullet(origin.clone(), direction * 300.0, isPlayer: true);
    }
  }

  bool get isInvulnerable => _invulnerableTimer > 0;

  void moveBy(Vector2 delta) {
    position.add(delta);
    _keepInBounds();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (shootCooldown > 0) shootCooldown -= dt;
    if (_invulnerableTimer > 0) _invulnerableTimer -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;

    if (isInvulnerable) {
      _paint.color = Colors.cyanAccent.withValues(alpha: 0.5);
    } else {
      _paint.color = Colors.blue;
    }

    _keepInBounds();

    if (_chefFrames.length > 1) {
      _chefFrameElapsed += dt;
      final duration = _chefFrames[_chefFrameIndex].duration.inMicroseconds / Duration.microsecondsPerSecond;
      while (_chefFrameElapsed >= duration) {
        _chefFrameElapsed -= duration;
        _chefFrameIndex = (_chefFrameIndex + 1) % _chefFrames.length;
      }
    }

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
    position.x = position.x.clamp(halfWidth, game.size.x - halfWidth);
    position.y = position.y.clamp(halfHeight, game.size.y - halfHeight);
  }

  void _shoot() {
    game.spawnBullet(_getWorldVisibleCenter(), Vector2(0, -500), isPlayer: true);
  }

  @override
  void render(Canvas canvas) {
    final spriteRect = _getLocalSpriteRect();

    if (_chefFrames.isNotEmpty) {
      final frame = _chefFrames[_chefFrameIndex].image;
      canvas.drawImageRect(
        frame,
        Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()),
        spriteRect,
        _paint,
      );
    } else if (icon != null) {
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
          spriteRect.center.dx - textPainter.width / 2,
          spriteRect.center.dy - textPainter.height / 2,
        ),
      );
    } else {
      canvas.drawRect(spriteRect, _paint);
    }
    
    if (_showHitbox) {
      final hitboxPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(_getLocalHitboxRect(), hitboxPaint);
    }
  }

  Rect _getLocalSpriteRect() {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    if (_chefFrames.isEmpty) {
      return Rect.fromCenter(center: Offset(centerX, centerY), width: size.x, height: size.y);
    }

    final frame = _chefFrames[_chefFrameIndex].image;
    final fittedSize = _fitContain(
      Size(frame.width.toDouble(), frame.height.toDouble()),
      Size(size.x, size.y),
    );

    return Rect.fromCenter(center: Offset(centerX, centerY), width: fittedSize.width, height: fittedSize.height);
  }

  Rect _getLocalHitboxRect() {
    final spriteRect = _getLocalSpriteRect();
    return Rect.fromCenter(
      center: Offset(
        spriteRect.center.dx + (spriteRect.width * _hitboxOffsetXRatio),
        spriteRect.center.dy + (spriteRect.height * _hitboxOffsetYRatio),
      ),
      width: spriteRect.width * _hitboxWidthRatio,
      height: spriteRect.height * _hitboxHeightRatio,
    );
  }

  Size _fitContain(Size source, Size destination) {
    if (source.width <= 0 || source.height <= 0) return destination;
    final scale = math.min(destination.width / source.width, destination.height / source.height);
    return Size(source.width * scale, source.height * scale);
  }
}

class _AnimatedFrame {
  const _AnimatedFrame({required this.image, required this.duration});
  final ui.Image image;
  final Duration duration;
}