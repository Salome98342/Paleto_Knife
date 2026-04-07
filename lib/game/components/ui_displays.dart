import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Componente UI para mostrar información de la oleada
class WaveInfoDisplay extends Component {
  /// Número de oleada actual
  int waveNumber = 1;

  /// Cantidad de enemigos totales en la oleada
  int totalEnemies = 0;

  /// Cantidad de enemigos restantes
  int remainingEnemies = 0;

  /// Estado de la oleada (idle, starting, active, ending)
  String waveState = 'idle';

  /// Duración del flash de inicio (cuando se muestra "WAVE X")
  double waveStartFlash = 0.0;
  final maxWaveStartFlash = 1.0;

  /// Posición de renderizado
  final displayPosition = Offset(20, 20);

  WaveInfoDisplay() : super();

  @override
  void update(double dt) {
    super.update(dt);

    // Reducir flash de inicio
    if (waveStartFlash > 0) {
      waveStartFlash -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar header de oleada
    _drawWaveNumber(canvas);

    // Dibujar contador de enemigos
    _drawEnemyCounter(canvas);

    // Dibujar estado
    _drawWaveState(canvas);
  }

  /// Dibuja el número de oleada grande
  void _drawWaveNumber(Canvas canvas) {
    final flashOpacity = waveStartFlash > 0
        ? 1.0 - (waveStartFlash / maxWaveStartFlash)
        : 0.3;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ONDA $waveNumber',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3 + 0.7 * flashOpacity),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, displayPosition);
  }

  /// Dibuja contador de enemigos
  void _drawEnemyCounter(Canvas canvas) {
    final percentage = totalEnemies > 0 ? remainingEnemies / totalEnemies : 0.0;
    final barWidth = 150.0;
    const barHeight = 8.0;

    final counterY = displayPosition + const Offset(0, 50);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(counterY.dx, counterY.dy, barWidth, barHeight),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // Progress bar
    final color = percentage > 0.5
        ? Colors.green
        : percentage > 0.25
            ? Colors.orange
            : Colors.red;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          counterY.dx,
          counterY.dy,
          barWidth * percentage,
          barHeight,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = color,
    );

    // Texto
    final text = 'Enemigos: $remainingEnemies/$totalEnemies';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      counterY.translate(0, barHeight + 5),
    );
  }

  /// Dibuja estado de la oleada
  void _drawWaveState(Canvas canvas) {
    String stateText = '';
    Color stateColor = Colors.white;

    switch (waveState) {
      case 'starting':
        stateText = '▶ INICIANDO...';
        stateColor = Colors.yellow;
        break;
      case 'active':
        stateText = '● EN COMBATE';
        stateColor = Colors.red;
        break;
      case 'ending':
        stateText = '✓ COMPLETADA';
        stateColor = Colors.green;
        break;
      default:
        return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: stateText,
        style: TextStyle(
          color: stateColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      displayPosition.translate(0, 80),
    );
  }

  /// Muestra animación de nueva oleada
  void showWaveStart() {
    waveStartFlash = maxWaveStartFlash;
    waveState = 'active';
  }

  /// Actualiza el estado
  void updateState({
    required int newWaveNumber,
    required int newTotalEnemies,
    required int newRemainingEnemies,
    String? newState,
  }) {
    waveNumber = newWaveNumber;
    totalEnemies = newTotalEnemies;
    remainingEnemies = newRemainingEnemies;
    if (newState != null) {
      waveState = newState;
    }
  }
}

/// Componente UI para información del boss
class BossInfoDisplay extends Component {
  /// Nombre del boss
  String bossName = '';

  /// Numero de fase actual
  int currentPhase = 1;

  /// Total de fases
  int totalPhases = 3;

  /// Mostrar solo cuando el boss está activo
  bool isVisible = false;

  /// Posición (esquina superior derecha)
  final displayPosition = Offset(20, 150);

  BossInfoDisplay() : super();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!isVisible) return;

    _drawBossName(canvas);
    _drawPhaseIndicator(canvas);
  }

  /// Dibuja nombre del boss
  void _drawBossName(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '👑 $bossName',
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, displayPosition);
  }

  /// Dibuja indicador de fases
  void _drawPhaseIndicator(Canvas canvas) {
    const dotSize = 10.0;
    const dotSpacing = 20.0;

    for (int i = 0; i < totalPhases; i++) {
      final isCurrentPhase = i == currentPhase - 1;
      final dotX = displayPosition.dx + (i * dotSpacing);
      final dotY = displayPosition.dy + 40;

      canvas.drawCircle(
        Offset(dotX + dotSize / 2, dotY),
        dotSize / 2,
        Paint()
          ..color = isCurrentPhase ? Colors.red : Colors.grey
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        Offset(dotX + dotSize / 2, dotY),
        dotSize / 2,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Número de fase
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          dotX + dotSize / 2 - textPainter.width / 2,
          dotY - textPainter.height / 2,
        ),
      );
    }
  }

  /// Actualiza la información del boss
  void updateState({
    required String newBossName,
    required int newCurrentPhase,
    required int newTotalPhases,
  }) {
    bossName = newBossName;
    currentPhase = newCurrentPhase;
    totalPhases = newTotalPhases;
    isVisible = true;
  }

  /// Oculta el display del boss
  void hide() {
    isVisible = false;
  }
}
