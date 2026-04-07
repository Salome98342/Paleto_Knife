/// Tipos de elementos en el juego
enum ElementType {
  neutral('Neutral', '⚪'),
  // Base elements
  water('Agua', '💧'),
  fire('Fuego', '🔥'),
  earth('Tierra', '🌿'),
  // Composite elements
  wind('Viento', '💨'),      // Agua + Fuego
  lava('Lava', '🌋'),        // Fuego + Tierra
  plant('Planta', '🌱'),     // Agua + Tierra
  master('Maestro', '⭐');   // Domina todos los elementos

  final String displayName;
  final String emoji;
  const ElementType(this.displayName, this.emoji);

  /// Obtiene la ventaja elemental contra otro elemento
  /// Retorna un multiplicador de daño
  /// Base: Agua > Fuego > Tierra > Agua (+25%)
  /// Composites tienen efectos especiales
  double getAdvantageAgainst(ElementType other) {
    // Sin ventaja para maestro o cuando el objetivo es neutral
    if (this == ElementType.master || other == ElementType.neutral) {
      return 1.0;
    }

    if (this == ElementType.neutral) {
      return 1.0; // Neutral no tiene ventajas
    }

    // Sistema base: Agua > Fuego > Tierra > Agua (+25%)
    if (this == ElementType.water && other == ElementType.fire) {
      return 1.25;
    }
    if (this == ElementType.fire && other == ElementType.earth) {
      return 1.25;
    }
    if (this == ElementType.earth && other == ElementType.water) {
      return 1.25;
    }

    // Desventajas (inverso)
    if (this == ElementType.water && other == ElementType.earth) {
      return 0.75;
    }
    if (this == ElementType.fire && other == ElementType.water) {
      return 0.75;
    }
    if (this == ElementType.earth && other == ElementType.fire) {
      return 0.75;
    }

    // Ventajas especiales de elementos compuestos
    // Viento (Agua + Fuego) - AOE + Knockback
    if (this == ElementType.wind) {
      if (other == ElementType.earth) return 1.3; // Efectivo contra tierra
      if (other == ElementType.fire) return 1.2;
      if (other == ElementType.water) return 1.2;
    }

    // Lava (Fuego + Tierra) - Rompe armadura
    if (this == ElementType.lava) {
      if (other == ElementType.water) return 1.3; // Efectivo contra agua
      if (other == ElementType.earth) return 1.15; // Pequeño bonus contra tierra
    }

    // Planta (Agua + Tierra) - Veneno % vida
    if (this == ElementType.plant) {
      if (other == ElementType.fire) return 1.35; // Muy efectivo contra fuego
      if (other == ElementType.earth) return 1.2;
    }

    return 1.0; // Sin ventaja/desventaja
  }

  /// Obtiene el color asociado al elemento
  int getColor() {
    switch (this) {
      case ElementType.water:
        return 0xFF2196F3; // Azul
      case ElementType.fire:
        return 0xFFF44336; // Rojo
      case ElementType.earth:
        return 0xFF8D6E63; // Marrón
      case ElementType.wind:
        return 0xFF64B5F6; // Azul claro [AOE + Knockback]
      case ElementType.lava:
        return 0xFFFF6F00; // Naranja [Rompe armadura]
      case ElementType.plant:
        return 0xFF4CAF50; // Verde [Veneno % vida]
      case ElementType.master:
        return 0xFF9C27B0; // Púrpura
      case ElementType.neutral:
        return 0xFF9E9E9E; // Gris
    }
  }

  /// Obtiene el emoji asociado al elemento
  String getEmoji() => emoji;

  /// Verifica si es un elemento compuesto
  bool get isComposite {
    return this == ElementType.wind || 
           this == ElementType.lava || 
           this == ElementType.plant;
  }

  /// Obtiene los elementos base que componen este elemento
  /// Retorna null si no es compuesto
  (ElementType, ElementType)? getComponents() {
    switch (this) {
      case ElementType.wind:
        return (ElementType.water, ElementType.fire);
      case ElementType.lava:
        return (ElementType.fire, ElementType.earth);
      case ElementType.plant:
        return (ElementType.water, ElementType.earth);
      default:
        return null;
    }
  }
}
