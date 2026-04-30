import 'package:flame/components.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Estados posibles del cofre
enum ChestState { idle, shake, open }

/// Callback cuando el cofre finaliza su animación de apertura
typedef OnChestOpened = void Function();

/// Componente del cofre interactivo con animaciones Lottie
/// Maneja 3 estados: idle (respiración), shake (sacudida), open (apertura)
class ChestComponent extends PositionComponent {
  late LottieComponent lottieComponent;
  
  ChestState _currentState = ChestState.idle;
  OnChestOpened? onChestOpened;
  
  // Animación de respiración (breathing/bobbing)
  double _idleTimer = 0.0;
  final double _idleAmplitude = 4.0;
  final double _idleFrequency = 2.0;
  Vector2 _basePosition = Vector2.zero();
  
  // Animación de sacudida
  double _shakeTimer = 0.0;
  final double _shakeDuration = 0.5;
  final double _shakeIntensity = 3.0;
  bool _shakeCompleted = false;
  
  // Control de clicks
  bool _clickInProgress = false;

  ChestComponent({
    required Vector2 position,
    required Vector2 size,
    this.onChestOpened,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    _basePosition = position.clone();
    
    // Crear LottieComponent para animaciones
    // NOTA: Descomentar cuando tengas los archivos JSON en assets/animations/chest/
    // try {
    //   lottieComponent = LottieComponent(
    //     width: size.x,
    //     height: size.y,
    //   );
    //   add(lottieComponent);
    // } catch (e) {
    //   print('Error loading Lottie: $e');
    // }
    
    super.onLoad();
  }

  /// Inicializa el estado idle (respiración suave)
  void setIdleState() {
    if (_currentState == ChestState.idle) return;
    
    _currentState = ChestState.idle;
    _idleTimer = 0.0;
    _clickInProgress = false;
    
    // Aquí cargarías la animación Lottie correspondiente
    // await lottieComponent.loadAnimation('assets/animations/chest_idle.json');
  }

  /// Activa el estado shake (sacudida al ser tocado)
  void setShakeState() {
    if (_currentState == ChestState.shake) return;
    
    _currentState = ChestState.shake;
    _shakeTimer = 0.0;
    _shakeCompleted = false;
    _clickInProgress = true;
    
    // Aquí cargarías la animación Lottie de sacudida
    // await lottieComponent.loadAnimation('assets/animations/chest_shake.json');
  }

  /// Activa el estado open (apertura del cofre)
  Future<void> setOpenState() async {
    if (_currentState == ChestState.open) return;
    
    print('[ChestComponent] Activando estado OPEN');
    _currentState = ChestState.open;
    _clickInProgress = true;
    
    // Aquí cargarías la animación Lottie de apertura
    // await lottieComponent.loadAnimation('assets/animations/chest_open.json');
    // Esperar a que la animación Lottie termine
    // await Future.delayed(Duration(milliseconds: 800)); // Duración de la animación
    
    // Disparar callback cuando la animación de apertura termina completamente
    print('[ChestComponent] Disparando callback onChestOpened');
    if (onChestOpened != null) {
      onChestOpened!();
    } else {
      print('[ChestComponent] ⚠️ onChestOpened es null');
    }
  }

  /// Detecta si el toque/click está dentro del área del cofre
  bool hitTest(Vector2 clickPos) {
    final dx = position.x - clickPos.x;
    final dy = position.y - clickPos.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Radio de interacción: 50% del tamaño más grande (área más grande para facilitar el tap)
    final interactionRadius = math.max(size.x, size.y) * 0.5;
    
    print('[ChestComponent.hitTest] Posición cofre: ${position}, Click: $clickPos');
    print('[ChestComponent.hitTest] Distancia: $distance, Radio: $interactionRadius');
    print('[ChestComponent.hitTest] ¿Dentro? ${distance <= interactionRadius}');
    
    return distance <= interactionRadius;
  }

  /// Maneja el evento de click/toque en el cofre
  void onTap() {
    print('[ChestComponent.onTap] ¡LLAMADO! Estado actual: $_currentState');
    
    if (_currentState == ChestState.open || _clickInProgress) {
      print('[ChestComponent.onTap] Ignorado - ya está abierto o en proceso');
      return;
    }
    
    if (_currentState == ChestState.idle) {
      print('[ChestComponent.onTap] Transición: idle -> shake');
      // Transición: idle -> shake
      setShakeState();
      // Después de la sacudida, ir a open
      Future.delayed(const Duration(milliseconds: 500), () {
        print('[ChestComponent.onTap] Después de shake, abriendo...');
        setOpenState();
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    switch (_currentState) {
      case ChestState.idle:
        _updateIdleAnimation(dt);
      case ChestState.shake:
        _updateShakeAnimation(dt);
      case ChestState.open:
        // En estado open no hacer movimiento
        break;
    }
  }

  /// Actualiza la animación de respiración (idle)
  void _updateIdleAnimation(double dt) {
    _idleTimer += dt;
    
    // Movimiento vertical suave (onda senoidal) + pequeño balanceo
    final bobOffset = math.sin(_idleTimer * _idleFrequency * math.pi) * _idleAmplitude;
    final sway = math.sin(_idleTimer * 1.5) * 2; // Balanceo horizontal leve
    
    position.y = _basePosition.y + bobOffset;
    position.x = _basePosition.x + sway;
  }

  /// Actualiza la animación de sacudida (shake)
  void _updateShakeAnimation(double dt) {
    _shakeTimer += dt;
    
    if (_shakeTimer >= _shakeDuration) {
      _shakeCompleted = true;
      // Volver a posición base al completar shake
      position.setFrom(_basePosition);
      return;
    }
    
    // Shake más intenso y frecuente
    final intensity = _shakeIntensity * (1 - (_shakeTimer / _shakeDuration)); // Se debilita con el tiempo
    final randomX = (math.Random().nextDouble() - 0.5) * intensity * 2;
    final randomY = (math.Random().nextDouble() - 0.5) * intensity * 0.5;
    
    position.x = _basePosition.x + randomX;
    position.y = _basePosition.y + randomY;
  }

  /// Getter para el estado actual
  ChestState get currentState => _currentState;

  /// Verifica si el cofre está completamente abierto
  bool get isOpened => _currentState == ChestState.open;

  /// Setter para cambiar el callback
  set onChestOpenedCallback(OnChestOpened? callback) {
    onChestOpened = callback;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dibujar el cofre según su estado
    switch (_currentState) {
      case ChestState.idle:
        _drawClosedChest(canvas);
      case ChestState.shake:
        _drawClosedChest(canvas);
      case ChestState.open:
        _drawOpenChest(canvas);
    }
  }

  /// Dibuja el cofre cerrado (NES pixel art style)
  void _drawClosedChest(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFA0826D) // Madera clara
      ..style = PaintingStyle.fill;
    
    final darkPaint = Paint()
      ..color = const Color(0xFF5C4033) // Madera oscura
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFF3D2817) // Borde oscuro
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Sombra base
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, size.y / 2 + 5),
        width: size.x * 0.9,
        height: size.y * 0.15,
      ),
      shadowPaint,
    );
    
    // Cuerpo principal del cofre (base)
    final bodyRect = Rect.fromLTWH(
      -size.x / 2,
      size.y * 0.05,
      size.x,
      size.y * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      borderPaint,
    );
    
    // Tapa del cofre (arriba, redondeada)
    final topPaint = Path();
    topPaint.moveTo(-size.x / 2 + 2, size.y * 0.05);
    topPaint.quadraticBezierTo(0, -size.y * 0.25, size.x / 2 - 2, size.y * 0.05);
    topPaint.lineTo(size.x / 2 - 2, size.y * 0.25);
    topPaint.quadraticBezierTo(0, size.y * 0.15, -size.x / 2 + 2, size.y * 0.25);
    topPaint.close();
    
    canvas.drawPath(topPaint, paint);
    canvas.drawPath(topPaint, borderPaint);
    
    // Degradado en la tapa para efecto 3D
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(-size.x / 2, -size.y * 0.25, size.x, size.y * 0.3),
      );
    canvas.drawPath(topPaint, gradientPaint);
    
    // Cerradura dorada circular
    final lockPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(0, size.y * 0.15), size.x * 0.12, lockPaint);
    
    // Detalle de cerradura (agujero)
    final lockHolePaint = Paint()
      ..color = const Color(0xFF5C4033)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, size.y * 0.15), size.x * 0.05, lockHolePaint);
    
    // Brillo de metal en la cerradura
    final metallicPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-size.x * 0.06, size.y * 0.10),
      size.x * 0.04,
      metallicPaint,
    );
    
    // Bandas metálicas (refuerzos)
    final bandPaint = Paint()
      ..color = const Color(0xFFB8860B) // Latón
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Banda horizontal
    canvas.drawLine(
      Offset(-size.x * 0.45, size.y * 0.35),
      Offset(size.x * 0.45, size.y * 0.35),
      bandPaint,
    );
    
    // Brillo en reposo (idle)
    if (_currentState == ChestState.idle) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            -size.x * 0.35,
            -size.y * 0.2,
            size.x * 0.35,
            size.y * 0.2,
          ),
          const Radius.circular(2),
        ),
        highlightPaint,
      );
    }
  }

  /// Dibuja el cofre abierto
  void _drawOpenChest(Canvas canvas) {
    final woodPaint = Paint()
      ..color = const Color(0xFFA0826D)
      ..style = PaintingStyle.fill;
    
    final darkPaint = Paint()
      ..color = const Color(0xFF5C4033)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFF3D2817)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, size.y / 2 + 5),
        width: size.x * 0.9,
        height: size.y * 0.15,
      ),
      shadowPaint,
    );
    
    // Cuerpo base
    final baseRect = Rect.fromLTWH(
      -size.x / 2,
      size.y * 0.15,
      size.x,
      size.y * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(3)),
      darkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(3)),
      borderPaint,
    );
    
    // Interior del cofre (más oscuro)
    final interiorPaint = Paint()
      ..color = const Color(0xFF3D2817)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.x * 0.4,
          size.y * 0.20,
          size.x * 0.8,
          size.y * 0.3,
        ),
        const Radius.circular(2),
      ),
      interiorPaint,
    );
    
    // Tapa abierta (rotada hacia atrás)
    final openLid = Path();
    openLid.moveTo(-size.x / 2 + 2, size.y * 0.15);
    openLid.lineTo(-size.x / 2 + 8, -size.y * 0.15);
    openLid.lineTo(size.x / 2 - 8, -size.y * 0.15);
    openLid.lineTo(size.x / 2 - 2, size.y * 0.15);
    openLid.close();
    
    canvas.drawPath(openLid, woodPaint);
    canvas.drawPath(openLid, borderPaint);
    
    // Monedas/Gemas dentro (estrellas brillantes)
    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    final jewelPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..style = PaintingStyle.fill;
    
    // Monedas distribuidas
    final positions = [
      (Offset(-size.x * 0.20, size.y * 0.15), goldPaint),
      (Offset(0, size.y * 0.25), goldPaint),
      (Offset(size.x * 0.20, size.y * 0.15), goldPaint),
      (Offset(-size.x * 0.10, size.y * 0.28), jewelPaint),
      (Offset(size.x * 0.10, size.y * 0.27), jewelPaint),
    ];
    
    for (final (pos, paintColor) in positions) {
      // Moneda/gema
      canvas.drawCircle(pos, size.x * 0.08, paintColor);
      
      // Brillo
      canvas.drawCircle(
        pos + Offset(-size.x * 0.04, -size.x * 0.04),
        size.x * 0.04,
        Paint()..color = Colors.white.withOpacity(0.7),
      );
      
      // Destello adicional
      canvas.drawCircle(
        pos + Offset(size.x * 0.02, size.x * 0.02),
        size.x * 0.02,
        Paint()..color = Colors.white.withOpacity(0.4),
      );
    }
    
    // Efecto de brillo del cofre abierto
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.x * 0.42,
          size.y * 0.18,
          size.x * 0.84,
          size.y * 0.34,
        ),
        const Radius.circular(3),
      ),
      glowPaint,
    );
  }
}
