import 'package:flutter/material.dart';

/// Iconos pixel art personalizados para reemplazar emojis estándar
class PixelArtIcons {
  /// Icono de fuego (pequeño elemento pixel art)
  static Widget fireIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FireIconPainter(color),
    );
  }

  /// Icono de agua (gota de agua)
  static Widget waterIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WaterIconPainter(color),
    );
  }

  /// Icono de tierra/roca
  static Widget earthIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EarthIconPainter(color),
    );
  }

  /// Icono de viento/aire
  static Widget windIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WindIconPainter(color),
    );
  }

  /// Icono de lava/volcán
  static Widget lavaIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LavaIconPainter(color),
    );
  }

  /// Icono de planta/crecimiento
  static Widget plantIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlantIconPainter(color),
    );
  }

  /// Icono de maestro/corona
  static Widget masterIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MasterIconPainter(color),
    );
  }

  /// Icono neutro/blanco
  static Widget neutralIcon({double size = 24, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _NeutralIconPainter(color),
    );
  }

  /// Icono de cofre común
  static Widget commonChestIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CommonChestPainter(),
    );
  }

  /// Icono de cofre raro
  static Widget rareChestIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RareChestPainter(),
    );
  }

  /// Icono de cofre épico
  static Widget epicChestIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EpicChestPainter(),
    );
  }

  /// Icono de cofre legendario
  static Widget legendaryChestIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LegendaryChestPainter(),
    );
  }

  /// Icono de gema/diamante
  static Widget gemIcon({double size = 24, Color color = Colors.purple}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GemIconPainter(color),
    );
  }

  /// Icono de moneda
  static Widget coinIcon({double size = 24, Color color = Colors.yellow}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoinIconPainter(color),
    );
  }

  /// Icono de saco de monedas
  static Widget coinBagIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoinBagPainter(),
    );
  }

  /// Icono de enemigos/invasión
  static Widget enemyGroupIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EnemyGroupPainter(),
    );
  }

  /// Icono de play/video
  static Widget playIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlayIconPainter(),
    );
  }

  /// Icono de tienda
  static Widget shopIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShopIconPainter(),
    );
  }

  /// Icono de chef
  static Widget chefIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChefIconPainter(),
    );
  }

  /// Icono de misiones
  static Widget questIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QuestIconPainter(),
    );
  }

  /// Icono de mapa/mundo
  static Widget worldIcon({double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WorldIconPainter(),
    );
  }

  /// Obtener icono por nombre de elemento
  static Widget getElementIcon(String elementName, {double size = 24}) {
    switch (elementName.toLowerCase()) {
      case 'fuego':
        return fireIcon(size: size);
      case 'agua':
        return waterIcon(size: size);
      case 'tierra':
        return earthIcon(size: size);
      case 'viento':
        return windIcon(size: size);
      case 'lava':
        return lavaIcon(size: size);
      case 'planta':
        return plantIcon(size: size);
      case 'maestro':
        return masterIcon(size: size);
      default:
        return neutralIcon(size: size);
    }
  }
}

// ===== PAINTERS =====

class _FireIconPainter extends CustomPainter {
  final Color color;

  _FireIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Pixel art fire: triángulo simple
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..close();

    canvas.drawPath(path, paint);

    // Detalle de llama
    final detailPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), size.width * 0.15, detailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaterIconPainter extends CustomPainter {
  final Color color;

  _WaterIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Gota de agua
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.2,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.95,
      )
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.7,
        size.width * 0.7,
        size.height * 0.4,
        size.width * 0.5,
        size.height * 0.1,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EarthIconPainter extends CustomPainter {
  final Color color;

  _EarthIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Roca cuadrada estilo pixel art
    final rect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.6,
    );

    canvas.drawRect(rect, paint);

    // Detalles de roca
    final detailPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), size.width * 0.08, detailPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.6), size.width * 0.09, detailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindIconPainter extends CustomPainter {
  final Color color;

  _WindIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Líneas de viento
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.3), Offset(size.width * 0.8, size.height * 0.3), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.5), Offset(size.width * 0.85, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.7), Offset(size.width * 0.8, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LavaIconPainter extends CustomPainter {
  final Color color;

  _LavaIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Volcán: triángulo + flujo de lava
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Triángulo volcán
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.65)
      ..lineTo(size.width * 0.15, size.height * 0.65)
      ..close();

    canvas.drawPath(path, paint);

    // Base/lava
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.65, size.width * 0.7, size.height * 0.25),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlantIconPainter extends CustomPainter {
  final Color color;

  _PlantIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Tallo
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.4, size.width * 0.1, size.height * 0.6),
      paint,
    );

    // Hojas
    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.25, size.height * 0.25),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.1, size.width * 0.25, size.height * 0.25),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.25, size.height * 0.25),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.35, size.width * 0.25, size.height * 0.25),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MasterIconPainter extends CustomPainter {
  final Color color;

  _MasterIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Corona
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.5, size.width * 0.6, size.height * 0.3),
      paint,
    );

    // Picos
    for (int i = 0; i < 3; i++) {
      final xOffset = size.width * (0.3 + (i * 0.2));
      final path = Path()
        ..moveTo(xOffset, size.height * 0.5)
        ..lineTo(xOffset + size.width * 0.08, size.height * 0.15)
        ..lineTo(xOffset + size.width * 0.16, size.height * 0.5)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeutralIconPainter extends CustomPainter {
  final Color color;

  _NeutralIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Círculo simple
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CommonChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    // Cuerpo del cofre
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.5),
      paint,
    );

    // Tapa
    final topPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.4)
        ..lineTo(size.width * 0.4, size.height * 0.15)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.85, size.height * 0.4)
        ..close(),
      topPaint,
    );

    // Candado frontal
    final lockPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), size.width * 0.08, lockPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RareChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[600]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.5),
      paint,
    );

    final topPaint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.4)
        ..lineTo(size.width * 0.4, size.height * 0.15)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.85, size.height * 0.4)
        ..close(),
      topPaint,
    );

    // Borde brillante
    final shinePaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.43, size.width * 0.64, size.height * 0.44),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EpicChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple[600]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.5),
      paint,
    );

    final topPaint = Paint()
      ..color = Colors.purple[400]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.4)
        ..lineTo(size.width * 0.4, size.height * 0.15)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.85, size.height * 0.4)
        ..close(),
      topPaint,
    );

    // Gemas decorativas
    final gemPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.55), size.width * 0.05, gemPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.55), size.width * 0.05, gemPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendaryChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber[600]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.4, size.width * 0.7, size.height * 0.5),
      paint,
    );

    final topPaint = Paint()
      ..color = Colors.amber[400]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.4)
        ..lineTo(size.width * 0.4, size.height * 0.15)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.85, size.height * 0.4)
        ..close(),
      topPaint,
    );

    // Brillo dorado múltiple
    final shinePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.45), size.width * 0.06, shinePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.07, shinePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.45), size.width * 0.06, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GemIconPainter extends CustomPainter {
  final Color color;

  _GemIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Diamante
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.9)
      ..lineTo(size.width * 0.2, size.height * 0.4)
      ..close();

    canvas.drawPath(path, paint);

    // Brillo
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.1)
        ..lineTo(size.width * 0.65, size.height * 0.35)
        ..lineTo(size.width * 0.5, size.height * 0.45)
        ..close(),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinIconPainter extends CustomPainter {
  final Color color;

  _CoinIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Moneda circular
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, paint);

    // Borde
    final borderPaint = Paint()
      ..color = Colors.orange[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, borderPaint);

    // Valor central
    final valuePaint = Paint()
      ..color = Colors.orange[900]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.15, valuePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bagPaint = Paint()
      ..color = Colors.brown[400]!
      ..style = PaintingStyle.fill;

    // Saco
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.6),
      bagPaint,
    );

    // Cuello del saco
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.15, size.width * 0.3, size.height * 0.25),
      bagPaint,
    );

    // Monedas dentro
    final coinPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.5), size.width * 0.08, coinPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.55), size.width * 0.08, coinPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), size.width * 0.08, coinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnemyGroupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final enemyPaint = Paint()
      ..color = Colors.red[700]!
      ..style = PaintingStyle.fill;

    // Tres siluetas de enemigos
    // Enemigo 1 (izquierda)
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.4), size.width * 0.12, enemyPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.55, size.width * 0.2, size.height * 0.35),
      enemyPaint,
    );

    // Enemigo 2 (centro, más grande)
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), size.width * 0.14, enemyPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.38, size.height * 0.5, size.width * 0.24, size.height * 0.4),
      enemyPaint,
    );

    // Enemigo 3 (derecha)
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), size.width * 0.12, enemyPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.65, size.height * 0.55, size.width * 0.2, size.height * 0.35),
      enemyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Triángulo de play
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.2)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShopIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[600]!
      ..style = PaintingStyle.fill;

    // Puerta de tienda
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.6),
      paint,
    );

    // Ventanas
    final windowPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.35, size.width * 0.2, size.height * 0.2),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.35, size.width * 0.2, size.height * 0.2),
      windowPaint,
    );

    // Letrero arriba
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.08, size.width * 0.7, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChefIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skinPaint = Paint()
      ..color = Colors.orange[200]!
      ..style = PaintingStyle.fill;

    // Cabeza
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.25), size.width * 0.15, skinPaint);

    // Cuerpo (delantal)
    final apronPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.5),
      apronPaint,
    );

    // Gorro de chef
    final hatPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.05, size.width * 0.3, size.height * 0.15),
      hatPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuestIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()
      ..color = Colors.yellow[100]!
      ..style = PaintingStyle.fill;

    // Pergamino/papel
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.8),
      paperPaint,
    );

    // Líneas de texto
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.25), Offset(size.width * 0.7, size.height * 0.25), linePaint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.4), Offset(size.width * 0.7, size.height * 0.4), linePaint);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.55), Offset(size.width * 0.7, size.height * 0.55), linePaint);

    // Exclamación decorativa
    final excPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), size.width * 0.06, excPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorldIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final globePaint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;

    // Globo terraqueo
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, globePaint);

    // Continentes (círculos verdes)
    final continentPaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), size.width * 0.08, continentPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.45), size.width * 0.09, continentPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.65), size.width * 0.07, continentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
