import 'package:flame/components.dart';

class AlertWarningBorder extends PositionComponent {
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
    // Cargar la imagen
    _stripesSprite = Sprite(await gameRef.images.load('stripes_pattern.png'));

    // Configurar tamaño y posición
    size = Vector2(gameRef.size.x, borderHeight);
    position = Vector2(
      0,
      isTopBorder ? 0 : gameRef.size.y - borderHeight,
    );

    // Iniciar timer de duración
    _alertTimer = Timer(alertDuration, onTick: _removeAlert);
    _alertTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _alertTimer.update(dt);
    
    // Actualizar scroll offset para movimiento continuo
    _scrollOffset += stripesSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Obtener dimensiones de la imagen
    final spriteWidth = _stripesSprite.src.width;
    final spriteHeight = _stripesSprite.src.height;

    // Dibujar patrón repetido con offset
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

  void _removeAlert() {
    removeFromParent();
  }
}
