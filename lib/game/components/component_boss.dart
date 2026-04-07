import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game_logic/boss_system/boss.dart';
import '../../game_logic/boss_system/boss_manager.dart';

/// Componente visual del boss en Flame
class ComponentBoss extends PositionComponent {
  /// Referencia al boss
  final Boss boss;
  final BossManager bossManager;

  /// Paints
  late Paint fillPaint;
  late Paint borderPaint;
  late Paint phasePaint;

  /// Animación de entrada
  double entryProgress = 0.0;
  final entryDuration = 1.5; // segundos

  /// Parpadeo de cambio de fase
  double phaseFlashDuration = 0.0;
  final maxPhaseFlash = 0.3;

  /// Tamaño del boss
  final bossSize = 60.0;

  /// Ángulo de rotación (animación)
  double rotation = 0.0;

  ComponentBoss(this.boss, this.bossManager)
      : super(
          position: Vector2(boss.position.dx, boss.position.dy),
          size: Vector2(150, 150),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    fillPaint = Paint()
      ..color = const Color(0xFFFF00FF) // Magenta oscuro
      ..style = PaintingStyle.fill;

    borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    phasePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Listener para cambios de fase
    bossManager.phaseChanged.listen((event) {
      phaseFlashDuration = maxPhaseFlash;
      _showPhaseChangeEffect();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animación de entrada
    if (entryProgress < entryDuration) {
      entryProgress += dt;
    }

    // Parpadeo de fase
    if (phaseFlashDuration > 0) {
      phaseFlashDuration -= dt;
    }

    // Rotación leve (animación esperando)
    rotation += dt * 30; // 30 grados por segundo
    if (rotation >= 360) rotation -= 360;

    // Seguir modelo
    position.setValues(boss.position.dx, boss.position.dy);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final entryScale =
        (entryProgress / entryDuration).clamp(0.0, 1.0);

    // Efecto de entrada (scale + fade)
    if (entryProgress < entryDuration) {
      _drawEntryEffect(canvas, center, entryScale);
      return; // No dibujar boss hasta que termine la entrada
    }

    // Dibujar cuerpo del boss
    _drawBossBody(canvas, center);

    // Dibujar aura de fase
    _drawPhaseAura(canvas, center);

    // Barra de vida grande
    _drawBossHealthBar(canvas, center);

    // Información de fase
    _drawPhaseInfo(canvas);
  }

  /// Efecto de entrada del boss
  void _drawEntryEffect(Canvas canvas, Offset center, double progress) {
    // Círculo expandible
    final maxRadius = bossSize * 2;
    final radius = maxRadius * progress;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.purple.withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Boss escalado
    final bossScale = progress;
    _drawBossAtScale(canvas, center, bossScale);
  }

  /// Dibuja el cuerpo del boss
  void _drawBossBody(Canvas canvas, Offset center) {
    _drawBossAtScale(canvas, center, 1.0);
  }

  /// Dibuja el boss con escala específica
  void _drawBossAtScale(Canvas canvas, Offset center, double scale) {
    final size = bossSize * scale;

    // Shadow
    canvas.drawCircle(
      center,
      size * 0.6,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );

    // Body
    canvas.drawCircle(
      center,
      size,
      fillPaint,
    );

    // Borde
    canvas.drawCircle(
      center,
      size,
      borderPaint,
    );

    // Ojos (animación de rotación)
    final eyeDistance = size * 0.4;
    final eyeSize = size * 0.15;

    // Ojo izquierdo
    canvas.drawCircle(
      center.translate(-eyeDistance, -size * 0.2),
      eyeSize,
      Paint()..color = Colors.white,
    );

    // Ojo derecho
    canvas.drawCircle(
      center.translate(eyeDistance, -size * 0.2),
      eyeSize,
      Paint()..color = Colors.white,
    );

    // Pupilas (viendo al jugador)
    final pupilSize = eyeSize * 0.6;
    canvas.drawCircle(
      center.translate(-eyeDistance, -size * 0.2),
      pupilSize,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      center.translate(eyeDistance, -size * 0.2),
      pupilSize,
      Paint()..color = Colors.black,
    );
  }

  /// Dibuja aura de fase
  void _drawPhaseAura(Canvas canvas, Offset center) {
    final phaseIndex = boss.currentPhaseIndex;
    final auraColor = [
      Colors.blue,
      Colors.orange,
      Colors.red,
    ][phaseIndex.clamp(0, 2)];

    final phaseFlashOpacity = phaseFlashDuration > 0 ? 0.8 : 0.3;

    canvas.drawCircle(
      center,
      bossSize * 1.2,
      Paint()
        ..color = auraColor.withValues(alpha: phaseFlashOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Puntas de aura (según fase)
    final spikes = 8 + (phaseIndex * 4);
    for (int i = 0; i < spikes; i++) {
      final angle = (360.0 / spikes) * i + rotation;
      final radians = angle * math.pi / 180;

      final startRadius = bossSize * 1.2;
      final endRadius = bossSize * 1.5;

      final startPoint = Offset(
        center.dx + startRadius * math.cos(radians),
        center.dy + startRadius * math.sin(radians),
      );

      final endPoint = Offset(
        center.dx + endRadius * math.cos(radians),
        center.dy + endRadius * math.sin(radians),
      );

      canvas.drawLine(
        startPoint,
        endPoint,
        Paint()
          ..color = auraColor.withValues(alpha: 0.6)
          ..strokeWidth = 2,
      );
    }
  }

  /// Dibuja barra de vida del boss
  void _drawBossHealthBar(Canvas canvas, Offset center) {
    const barWidth = 140.0;
    const barHeight = 12.0;

    final barTopLeft = Offset(
      center.dx - barWidth / 2,
      center.dy - bossSize - 30,
    );

    // Fondo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barTopLeft.dx, barTopLeft.dy, barWidth, barHeight),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // HP
    final healthPercent = boss.hpPercentage.clamp(0.0, 1.0);
    final healthColor = healthPercent > 0.5
        ? Colors.green
        : healthPercent > 0.25
            ? Colors.orange
            : Colors.red;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barTopLeft.dx,
          barTopLeft.dy,
          barWidth * healthPercent,
          barHeight,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = healthColor,
    );

    // Borde
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barTopLeft.dx, barTopLeft.dy, barWidth, barHeight),
        const Radius.circular(6),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Texto de HP
    _drawBossHPText(
      canvas,
      Offset(center.dx, barTopLeft.dy - 5),
      healthPercent,
    );
  }

  /// Dibuja texto de HP del boss
  void _drawBossHPText(Canvas canvas, Offset position, double healthPercent) {
    final text = 'HP: ${boss.currentHp.toInt()}/${boss.maxHp.toInt()} '
        '(${(healthPercent * 100).toInt()}%)';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  /// Dibuja información de la fase
  void _drawPhaseInfo(Canvas canvas) {
    final phase = boss.currentPhase;
    final phaseText =
        'FASE ${boss.currentPhaseIndex + 1} - ${phase.description}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: phaseText,
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2, size.y + 10),
    );
  }

  /// Efecto visual de cambio de fase
  void _showPhaseChangeEffect() {
    // Este efecto se puede expandir con partículas más adelante
  }
}
