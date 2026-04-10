import 'package:flutter/material.dart';

/// Utilidades para responsive design
/// Escala automáticamente según el tamaño de pantalla
class ResponsiveUtils {
  /// Obtener la altura de la pantalla
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Obtener el ancho de la pantalla
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtener el padding seguro (notches, etc)
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Factor de escala basado en altura de pantalla
  /// Pantalla pequeña (< 600) = 0.7x
  /// Pantalla normal (600-800) = 1.0x
  /// Pantalla grande (> 800) = 1.2x
  static double getScaleFactor(BuildContext context) {
    final height = screenHeight(context);
    if (height < 600) return 0.7;
    if (height < 800) return 1.0;
    return 1.2;
  }

  /// Factor de escala para texto
  /// Más conservador que getScaleFactor
  static double getTextScaleFactor(BuildContext context) {
    final height = screenHeight(context);
    if (height < 600) return 0.8;
    if (height < 800) return 0.95;
    if (height < 1000) return 1.0;
    return 1.1;
  }

  /// Factor de escala para UI (botones, cards, etc)
  static double getUIScaleFactor(BuildContext context) {
    final height = screenHeight(context);
    if (height < 600) return 0.75;
    if (height < 800) return 0.9;
    if (height < 1000) return 1.0;
    return 1.15;
  }

  /// Categoría de dispositivo
  static DeviceCategory getDeviceCategory(BuildContext context) {
    final height = screenHeight(context);
    final width = screenWidth(context);

    // Teléfono pequeño (< 600px height)
    if (height < 600) {
      return DeviceCategory.small;
    }

    // Teléfono normal (600-800px)
    if (height < 800) {
      return DeviceCategory.medium;
    }

    // Teléfono grande o tablet (800-1200px)
    if (height < 1200) {
      return DeviceCategory.large;
    }

    // Tablet o pantalla muy grande
    return DeviceCategory.xlarge;
  }

  /// Espaciado dinámico
  static double spacing(BuildContext context, double baseSize) {
    return baseSize * getScaleFactor(context);
  }

  /// Tamaño de fuente dinámico
  static double fontSize(BuildContext context, double baseSize) {
    return baseSize * getTextScaleFactor(context);
  }

  /// Tamaño de widget dinámico
  static double widgetSize(BuildContext context, double baseSize) {
    return baseSize * getUIScaleFactor(context);
  }

  /// Padding responsivo
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) {
    final scale = getScaleFactor(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal * scale,
      vertical: vertical * scale,
    );
  }

  /// Padding simétrico
  static EdgeInsets symmetricPadding(
    BuildContext context, {
    double h = 16,
    double v = 16,
  }) {
    return responsivePadding(context, horizontal: h, vertical: v);
  }

  /// Padding específico
  static EdgeInsets customPadding(
    BuildContext context, {
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    final scale = getScaleFactor(context);
    return EdgeInsets.only(
      left: left * scale,
      right: right * scale,
      top: top * scale,
      bottom: bottom * scale,
    );
  }

  /// Validar si es pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return screenHeight(context) < 600;
  }

  /// Validar si es pantalla mediana
  static bool isMediumScreen(BuildContext context) {
    return screenHeight(context) >= 600 && screenHeight(context) < 900;
  }

  /// Validar si es pantalla grande
  static bool isLargeScreen(BuildContext context) {
    return screenHeight(context) >= 900;
  }

  /// Ancho máximo para contenido (evita que sea demasiado ancho)
  static double maxContentWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width > 600) {
      return 600;
    }
    return width - 32;
  }
}

/// Categorías de dispositivos
enum DeviceCategory {
  small,    // < 600px (teléfono pequeño)
  medium,   // 600-800px (teléfono normal)
  large,    // 800-1200px (teléfono grande)
  xlarge,   // > 1200px (tablet)
}

/// Extensión para obtener nombre legible de categoría
extension DeviceCategoryExtension on DeviceCategory {
  String get name {
    switch (this) {
      case DeviceCategory.small:
        return 'Small Phone';
      case DeviceCategory.medium:
        return 'Medium Phone';
      case DeviceCategory.large:
        return 'Large Phone';
      case DeviceCategory.xlarge:
        return 'Tablet';
    }
  }
}
