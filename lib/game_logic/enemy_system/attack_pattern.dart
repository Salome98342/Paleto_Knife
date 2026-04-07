/// Tipos de patrones de ataque
enum AttackPatternType {
  /// Un único proyectil hacia abajo
  straight,

  /// Abanico de proyectiles
  spread,

  /// Circulo completo de proyectiles
  radial,

  /// Apunta directamente al jugador
  aimed,
}

/// Configuración del patrón de ataque de un enemigo
class AttackPattern {
  /// Tipo de patrón
  final AttackPatternType type;

  /// Tiempo entre ataques (segundos)
  final double cooldown;

  /// Velocidad de los proyectiles
  final double bulletSpeed;

  /// Daño de cada proyectil
  final double bulletDamage;

  /// Cantidad de proyectiles por ataque
  final int bulletCount;

  /// Ángulo de apertura para patrones spread/aimed
  final double spreadAngle;

  AttackPattern({
    required this.type,
    required this.cooldown,
    required this.bulletSpeed,
    this.bulletDamage = 5.0,
    this.bulletCount = 1,
    this.spreadAngle = 60.0,
  });

  /// Copia profunda
  AttackPattern copyWith({
    AttackPatternType? type,
    double? cooldown,
    double? bulletSpeed,
    double? bulletDamage,
    int? bulletCount,
    double? spreadAngle,
  }) {
    return AttackPattern(
      type: type ?? this.type,
      cooldown: cooldown ?? this.cooldown,
      bulletSpeed: bulletSpeed ?? this.bulletSpeed,
      bulletDamage: bulletDamage ?? this.bulletDamage,
      bulletCount: bulletCount ?? this.bulletCount,
      spreadAngle: spreadAngle ?? this.spreadAngle,
    );
  }
}
