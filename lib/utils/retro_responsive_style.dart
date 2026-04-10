import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_utils.dart';

/// Estilos responsivos para diseño retro
class RetroResponsiveStyle {
  /// Tamaños de fuente por categoría de pantalla
  static const Map<String, double> fontSizes = {
    // Encabezados principal
    'h1_small': 12,
    'h1_medium': 14,
    'h1_large': 16,
    'h1_xlarge': 20,

    // Encabezados secundarios
    'h2_small': 10,
    'h2_medium': 12,
    'h2_large': 14,
    'h2_xlarge': 16,

    // Texto normal
    'body_small': 8,
    'body_medium': 10,
    'body_large': 12,
    'body_xlarge': 14,

    // Etiquetas pequeñas
    'label_small': 6,
    'label_medium': 8,
    'label_large': 10,
    'label_xlarge': 12,
  };

  /// Tamaños de borde por categoría
  static const Map<String, double> borderSizes = {
    'small': 2,
    'medium': 3,
    'large': 4,
    'xlarge': 5,
  };

  /// Obtener tamaño de fuente H1 según pantalla
  static double h1Size(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return fontSizes['h1_small']!;
      case DeviceCategory.medium:
        return fontSizes['h1_medium']!;
      case DeviceCategory.large:
        return fontSizes['h1_large']!;
      case DeviceCategory.xlarge:
        return fontSizes['h1_xlarge']!;
    }
  }

  /// Obtener tamaño de fuente H2 según pantalla
  static double h2Size(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return fontSizes['h2_small']!;
      case DeviceCategory.medium:
        return fontSizes['h2_medium']!;
      case DeviceCategory.large:
        return fontSizes['h2_large']!;
      case DeviceCategory.xlarge:
        return fontSizes['h2_xlarge']!;
    }
  }

  /// Obtener tamaño de fuente normal según pantalla
  static double bodySize(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return fontSizes['body_small']!;
      case DeviceCategory.medium:
        return fontSizes['body_medium']!;
      case DeviceCategory.large:
        return fontSizes['body_large']!;
      case DeviceCategory.xlarge:
        return fontSizes['body_xlarge']!;
    }
  }

  /// Obtener tamaño de etiqueta según pantalla
  static double labelSize(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return fontSizes['label_small']!;
      case DeviceCategory.medium:
        return fontSizes['label_medium']!;
      case DeviceCategory.large:
        return fontSizes['label_large']!;
      case DeviceCategory.xlarge:
        return fontSizes['label_xlarge']!;
    }
  }

  /// Obtener tamaño de borde según pantalla
  static double borderSize(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return borderSizes['small']!;
      case DeviceCategory.medium:
        return borderSizes['medium']!;
      case DeviceCategory.large:
        return borderSizes['large']!;
      case DeviceCategory.xlarge:
        return borderSizes['xlarge']!;
    }
  }

  /// Obtener fuente pixel art responsiva (H1)
  static TextStyle h1(
    BuildContext context, {
    Color color = const Color(0xFF1E1E1E),
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: h1Size(context),
      color: color,
      height: 1.4,
    ).copyWith(fontFamilyFallback: ['Roboto', 'sans-serif']);
  }

  /// Obtener fuente pixel art responsiva (H2)
  static TextStyle h2(
    BuildContext context, {
    Color color = const Color(0xFF1E1E1E),
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: h2Size(context),
      color: color,
      height: 1.4,
    ).copyWith(fontFamilyFallback: ['Roboto', 'sans-serif']);
  }

  /// Obtener fuente pixel art responsiva (body)
  static TextStyle body(
    BuildContext context, {
    Color color = const Color(0xFF1E1E1E),
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: bodySize(context),
      color: color,
      height: 1.4,
    ).copyWith(fontFamilyFallback: ['Roboto', 'sans-serif']);
  }

  /// Obtener fuente pixel art responsiva (label)
  static TextStyle label(
    BuildContext context, {
    Color color = const Color(0xFF1E1E1E),
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: labelSize(context),
      color: color,
      height: 1.4,
    ).copyWith(fontFamilyFallback: ['Roboto', 'sans-serif']);
  }

  /// Decoración de caja responsiva
  static BoxDecoration responsiveBox({
    Color color = const Color(0xFFC4CFA1),
    bool isPressed = false,
    required BuildContext context,
  }) {
    final borderWidth = borderSize(context);
    final shadowOffset = borderWidth;

    return BoxDecoration(
      color: color,
      border: Border.all(color: Colors.black, width: borderWidth),
      boxShadow: isPressed
          ? []
          : [
              BoxShadow(
                color: Colors.black,
                offset: Offset(shadowOffset, shadowOffset),
                blurRadius: 0,
              ),
            ],
    );
  }

  /// Padding responsivo
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double horizontalMultiplier = 1.0,
    double verticalMultiplier = 1.0,
  }) {
    final baseScale = ResponsiveUtils.getScaleFactor(context);
    return EdgeInsets.symmetric(
      horizontal: 16 * baseScale * horizontalMultiplier,
      vertical: 16 * baseScale * verticalMultiplier,
    );
  }

  /// Spacing responsivo
  static double spacing(BuildContext context, double baseSize) {
    return baseSize * ResponsiveUtils.getScaleFactor(context);
  }

  /// Tamaño de icono responsivo
  static double iconSize(BuildContext context, double baseSize) {
    return baseSize * ResponsiveUtils.getUIScaleFactor(context);
  }

  /// Tamaño de botón responsivo
  static double buttonSize(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return 32;
      case DeviceCategory.medium:
        return 40;
      case DeviceCategory.large:
        return 48;
      case DeviceCategory.xlarge:
        return 56;
    }
  }

  /// Altura de botón responsiva
  static double buttonHeight(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return 36;
      case DeviceCategory.medium:
        return 44;
      case DeviceCategory.large:
        return 52;
      case DeviceCategory.xlarge:
        return 60;
    }
  }

  /// Ancho mínimo de botón responsivo
  static double buttonMinWidth(BuildContext context) {
    switch (ResponsiveUtils.getDeviceCategory(context)) {
      case DeviceCategory.small:
        return 64;
      case DeviceCategory.medium:
        return 80;
      case DeviceCategory.large:
        return 96;
      case DeviceCategory.xlarge:
        return 120;
    }
  }
}
