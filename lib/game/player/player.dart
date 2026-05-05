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
  final IconData? icon;
  final String? chefId; // ID del chef para cargar su imagen específica
  
  // Imagen animada del chef (GIF/PNG)
  final List<_AnimatedFrame> _chefFrames = [];
  int _chefFrameIndex = 0;
  double _chefFrameElapsed = 0.0;
  Rect? _chefVisibleSourceBounds;
  Size? _chefSourceSize;
  static const double _hitboxOffsetXRatio = -0.08;
  static const double _hitboxWidthRatio = 0.42;
  static const double _hitboxHeightRatio = 0.56;
  static const double _hitboxOffsetYRatio = 0.22;
  bool _showHitbox = true; // Flag para mostrar/ocultar hitbox debug

  static const double _defaultFrameDuration = 1 / 12;

  double get _cheftoDisplayWidth => size.x;
  double get _cheftoDisplayHeight => size.y;

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
        debugPrint('[PlayerComponent] Trying asset key: $key');
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

        if (_chefFrames.isEmpty) {
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

        _chefSourceSize = Size(
          _chefFrames.first.image.width.toDouble(),
          _chefFrames.first.image.height.toDouble(),
        );
        _chefVisibleSourceBounds = await _calculateVisibleSourceBounds(
          _chefFrames.map((frame) => frame.image).toList(),
        );

        debugPrint('[PlayerComponent] ✅ Loaded ${_chefFrames.length} frame(s) with key: $key');
        return;
      } catch (e) {
        debugPrint('[PlayerComponent] ❌ Failed key $key: $e');
      }
    }

    _chefFrames.clear();
  }

  PlayerComponent({
    required Vector2 position,
    this.icon,
    this.chefId,
  }) : super(position: position, size: Vector2(72, 84), anchor: Anchor.center) {
    _paint = Paint()..color = Colors.blue;
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Cargar la imagen PNG del chef según su ID
    debugPrint('[PlayerComponent] onLoad: chefId = $chefId');
    
    try {
      if (chefId == 'r_fire_1') {
        // Chef de Línea - carga robusta compatible con assets/ y lib/assets/
        debugPrint('[PlayerComponent] Attempting to load r_fire_1 image');
        
        // Esperar a que el game esté completamente listo
        await game.ready;
        debugPrint('[PlayerComponent] Game ready confirmed');
        
        await _loadChefFramesWithFallback();
        if (_chefFrames.isNotEmpty) {
          debugPrint('[PlayerComponent] Frame dimensions: ${_chefFrames.first.image.width} x ${_chefFrames.first.image.height}');
        } else {
          debugPrint('[PlayerComponent] ❌ Could not load chef image from any key');
        }
      } else {
        // Otros chefs - no cargar imagen por ahora (usar icono)
        debugPrint('[PlayerComponent] No custom image for $chefId, will use icon');
      }
    } catch (e) {
      debugPrint('[PlayerComponent] ❌ ERROR in onLoad: $e');
      debugPrint('[PlayerComponent] Stack trace: ${StackTrace.current}');
      _chefFrames.clear();
    }
  }
  
  /// Obtiene el hitbox del jugador
  Rect getHitbox() {
    final hitboxRect = _getLocalHitboxRect();

    return Rect.fromCenter(
      center: Offset(
        position.x + hitboxRect.center.dx,
        position.y + hitboxRect.center.dy,
      ),
      width: hitboxRect.width,
      height: hitboxRect.height,
    );
  }

  Vector2 _getWorldVisibleCenter() {
    final spriteRect = _getLocalSpriteRect();
    final visibleRect = _getLocalVisibleContentRect(spriteRect);

    return Vector2(
      position.x + visibleRect.center.dx,
      position.y + visibleRect.center.dy,
    );
  }

  void dash() {
    if (_dashCooldown > 0) return;
    _invulnerableTimer = 1.0; // 1 segundo de invulnerabilidad
    _dashCooldown = 3.0; // 3 segundos de recarga
    game.shakeScreen(10.0, 0.2); // Pequeno efecto visual

    // Disparo circular (Nova)
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

  @override
  void update(double dt) {
    super.update(dt);
    if (shootCooldown > 0) shootCooldown -= dt;
    if (_invulnerableTimer > 0) _invulnerableTimer -= dt;
    if (_dashCooldown > 0) _dashCooldown -= dt;

    if (isInvulnerable) {
      // Efecto parpadeo
      _paint.color = Colors.cyanAccent.withValues(alpha: 0.5);
    } else {
      _paint.color = Colors.blue;
    }

    _keepInBounds();

    if (_chefFrames.length > 1) {
      _chefFrameElapsed += dt;
      while (_chefFrameElapsed >= _chefFrames[_chefFrameIndex].duration.inMicroseconds / Duration.microsecondsPerSecond) {
        _chefFrameElapsed -= _chefFrames[_chefFrameIndex].duration.inMicroseconds / Duration.microsecondsPerSecond;
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
    if (position.x < halfWidth) position.x = halfWidth;
    if (position.x > game.size.x - halfWidth)
      position.x = game.size.x - halfWidth;
    if (position.y < halfHeight) position.y = halfHeight;
    if (position.y > game.size.y - halfHeight)
      position.y = game.size.y - halfHeight;
  }

  void _shoot() {
    game.spawnBullet(_getWorldVisibleCenter(), Vector2(0, -500), isPlayer: true);
  }

  @override
  void render(Canvas canvas) {
    final spriteRect = _getLocalSpriteRect();

    // Renderizar la imagen del chef
    if (_chefFrames.isNotEmpty) {
      final frame = _chefFrames[_chefFrameIndex].image;
      final sourceRect = Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble());

      canvas.drawImageRect(
        frame,
        sourceRect,
        spriteRect,
        _paint,
      );
    } else if (icon != null) {
      // Fallback al icono si no se cargó la imagen
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
      // Fallback a rectángulo si nada funciona
      canvas.drawRect(spriteRect, _paint);
    }
    
    // Mostrar hitbox en rojo (debug)
    if (_showHitbox) {
      final hitboxPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(_getLocalHitboxRect(), hitboxPaint);
    }
  }

  Rect _getLocalSpriteRect() {
    if (_chefFrames.isEmpty) {
      return Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);
    }

    final frame = _chefFrames[_chefFrameIndex].image;
    final fittedSize = _fitContain(
      Size(frame.width.toDouble(), frame.height.toDouble()),
      Size(size.x, size.y),
    );

    return Rect.fromCenter(
      center: Offset.zero,
      width: fittedSize.width,
      height: fittedSize.height,
    );
  }

  Rect _getLocalHitboxRect() {
    final spriteRect = _getLocalSpriteRect();
    final visibleRect = _getLocalVisibleContentRect(spriteRect);
    final hitboxWidth = visibleRect.width * _hitboxWidthRatio;
    final hitboxHeight = visibleRect.height * _hitboxHeightRatio;
    final hitboxOffsetY = visibleRect.height * _hitboxOffsetYRatio;

    return Rect.fromCenter(
      center: Offset(
        visibleRect.center.dx + (visibleRect.width * _hitboxOffsetXRatio),
        visibleRect.center.dy + hitboxOffsetY,
      ),
      width: hitboxWidth,
      height: hitboxHeight,
    );
  }

  Rect _getLocalVisibleContentRect([Rect? spriteRect]) {
    final baseSpriteRect = spriteRect ?? _getLocalSpriteRect();
    final sourceBounds = _chefVisibleSourceBounds;
    final sourceSize = _chefSourceSize;

    if (sourceBounds == null || sourceSize == null) {
      return baseSpriteRect;
    }

    final scaleX = baseSpriteRect.width / sourceSize.width;
    final scaleY = baseSpriteRect.height / sourceSize.height;

    return Rect.fromLTWH(
      baseSpriteRect.left + (sourceBounds.left * scaleX),
      baseSpriteRect.top + (sourceBounds.top * scaleY),
      sourceBounds.width * scaleX,
      sourceBounds.height * scaleY,
    );
  }

  Future<Rect?> _calculateVisibleSourceBounds(List<ui.Image> frames) async {
    Rect? bounds;

    for (final frame in frames) {
      final frameBounds = await _calculateVisibleBoundsForImage(frame);
      if (frameBounds == null) continue;

      bounds = bounds == null ? frameBounds : bounds.expandToInclude(frameBounds);
    }

    return bounds;
  }

  Future<Rect?> _calculateVisibleBoundsForImage(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    var minX = width;
    var minY = height;
    var maxX = -1;
    var maxY = -1;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixelIndex = ((y * width) + x) * 4;
        final alpha = bytes[pixelIndex + 3];

        if (alpha > 12) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < minX || maxY < minY) {
      return null;
    }

    return Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      (maxX + 1).toDouble(),
      (maxY + 1).toDouble(),
    );
  }

  Size _fitContain(Size source, Size destination) {
    if (source.width <= 0 || source.height <= 0 || destination.width <= 0 || destination.height <= 0) {
      return destination;
    }

    final scale = math.min(destination.width / source.width, destination.height / source.height);
    return Size(source.width * scale, source.height * scale);
  }
}

class _AnimatedFrame {
  const _AnimatedFrame({required this.image, required this.duration});

  final ui.Image image;
  final Duration duration;
}
