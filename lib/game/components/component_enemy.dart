import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../game_logic/enemy_system/enemy_types.dart';

/// Componente visual de un enemigo en Flame
class ComponentEnemy extends PositionComponent {
  /// Referencia al modelo de enemigo
  final Enemy enemy;

  /// Definición del tipo de enemigo
  late EnemyTypeDefinition enemyType;

  /// Paint para dibujar el enemigo
  late Paint fillPaint;
  late Paint borderPaint;

  /// Tamaño del enemigo
  late double enemySize;

  /// Animación de spawn (scale)
  double spawnProgress = 0.0;
  final spawnDuration = 0.3; // segundos

  /// Indicador de daño tomado (parpadeo)
  double damageFlashDuration = 0.0;
  final maxDamageFlash = 0.1;

  ComponentEnemy(this.enemy)
      : super(
          position: Vector2(enemy.position.dx, enemy.position.dy),
          size: Vector2(80, 80), // Tamaño base
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Obtener definición del tipo (intentar varias estrategias)
    // Primero por nombre del enemigo en minúsculas
    var typeDefinition = EnemyTypesCatalog.get(enemy.name.toLowerCase());
    
    // Si no encuentra, usar 'grunt' como default
    if (typeDefinition == null) {
      typeDefinition = EnemyTypesCatalog.get('grunt')!;
    }
    
    enemyType = typeDefinition;

    // Configurar paints
    fillPaint = Paint()
      ..color = Color(enemyType.debugColor)
      ..style = PaintingStyle.fill;

    borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Tamaño base
    enemySize = 40.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animación de spawn (primeros 0.3s)
    if (spawnProgress < spawnDuration) {
      spawnProgress += dt;
    }

    // Actualizar parpadeo de daño
    if (damageFlashDuration > 0) {
      damageFlashDuration -= dt;
    }

    // Seguir modelo (posición)
    position.setValues(enemy.position.dx, enemy.position.dy);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Cálculo de escala de spawn
    final spawnScale = (spawnProgress / spawnDuration).clamp(0.0, 1.0);

    // Centro del componente
    final center = Offset(size.x / 2, size.y / 2);

    // Dibujar shadow
    canvas.drawCircle(
      center,
      enemySize * spawnScale * 0.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    // Aplicar color de daño si corresponde
    if (damageFlashDuration > 0) {
      fillPaint.color = Color(enemyType.debugColor).withValues(alpha: 
        0.5 + 0.5 * (damageFlashDuration / maxDamageFlash),
      );
    } else {
      fillPaint.color = Color(enemyType.debugColor);
    }

    // Dibujar cuerpo del enemigo
    canvas.drawCircle(
      center,
      enemySize * spawnScale,
      fillPaint,
    );

    // Borde
    canvas.drawCircle(
      center,
      enemySize * spawnScale,
      borderPaint,
    );

    // Dibujar número de tipo en el centro (para debugging)
    _drawEnemyLabel(canvas, center, spawnScale);

    // Barra de vida
    _drawHealthBar(canvas, center, spawnScale);
  }

  /// Dibuja etiqueta del enemigo
  void _drawEnemyLabel(Canvas canvas, Offset center, double scale) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: enemy.name.characters.first.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center.translate(
        -textPainter.width / 2,
        -textPainter.height / 2,
      ),
    );
  }

  /// Dibuja barra de vida encima del enemigo
  void _drawHealthBar(Canvas canvas, Offset center, double scale) {
    final barWidth = enemySize * scale * 2;
    const barHeight = 4.0;
    final barTopLeft = Offset(
      center.dx - barWidth / 2,
      center.dy - enemySize * scale - 12,
    );

    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(barTopLeft.dx, barTopLeft.dy, barWidth, barHeight),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // Vida
    final healthPercent = enemy.healthPercentage.clamp(0.0, 1.0);
    final healthColor =
        healthPercent > 0.5 ? Colors.green : Colors.red;

    canvas.drawRect(
      Rect.fromLTWH(
        barTopLeft.dx,
        barTopLeft.dy,
        barWidth * healthPercent,
        barHeight,
      ),
      Paint()..color = healthColor,
    );
  }

  /// El enemigo toma daño (visual feedback)
  void onDamageReceived() {
    damageFlashDuration = maxDamageFlash;
  }
}
