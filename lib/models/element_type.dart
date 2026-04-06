/// Tipos de elementos en el juego
enum ElementType {
  neutral('Neutral'),
  water('Agua'),
  fire('Fuego'),
  earth('Tierra'),
  master('Maestro'); // Domina todos los elementos

  final String displayName;
  const ElementType(this.displayName);

  /// Obtiene la ventaja elemental contra otro elemento
  /// Retorna un multiplicador de dano
  double getAdvantageAgainst(ElementType other) {
    if (this == ElementType.master || other == ElementType.neutral) {
      return 1.0; // Sin ventaja especial
    }

    if (this == ElementType.neutral) {
      return 1.0; // Neutral no tiene ventajas
    }

    // Sistema de ventajas: Agua > Fuego > Tierra > Agua
    if (this == ElementType.water && other == ElementType.fire) {
      return 1.25; // +25% de dano
    }
    if (this == ElementType.fire && other == ElementType.earth) {
      return 1.25;
    }
    if (this == ElementType.earth && other == ElementType.water) {
      return 1.25;
    }

    // Desventajas (inverso)
    if (this == ElementType.water && other == ElementType.earth) {
      return 0.75; // -25% de dano
    }
    if (this == ElementType.fire && other == ElementType.water) {
      return 0.75;
    }
    if (this == ElementType.earth && other == ElementType.fire) {
      return 0.75;
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
        return 0xFF8D6E63; // Marron
      case ElementType.master:
        return 0xFF9C27B0; // Purpura
      case ElementType.neutral:
        return 0xFF9E9E9E; // Gris
    }
  }

  /// Obtiene el emoji asociado al elemento
  String getEmoji() {
    switch (this) {
      case ElementType.water:
        return '';
      case ElementType.fire:
        return '';
      case ElementType.earth:
        return '';
      case ElementType.master:
        return '';
      case ElementType.neutral:
        return '';
    }
  }
}
