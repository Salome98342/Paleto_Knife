/// Modelo que representa una mejora o upgrade en el juego
/// Cada upgrade tiene un costo, un efecto y puede ser comprado múltiples veces
class Upgrade {
  final String id;
  final String name;
  final String description;
  final double baseCost; // Costo inicial
  final double costMultiplier; // Multiplicador de costo por cada nivel
  final UpgradeType type; // Tipo de mejora
  final double effect; // Efecto base de la mejora
  int level; // Nivel actual de la mejora

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.costMultiplier,
    required this.type,
    required this.effect,
    this.level = 0,
  });

  /// Calcula el costo actual basado en el nivel
  double get currentCost {
    if (level == 0) return baseCost;
    return baseCost * (costMultiplier * level);
  }

  /// Calcula el efecto actual basado en el nivel
  double get currentEffect {
    return effect * (level + 1);
  }

  /// Compra un nivel de esta mejora
  void buyLevel() {
    level++;
  }

  /// Convierte el upgrade a un Map para guardar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'baseCost': baseCost,
      'costMultiplier': costMultiplier,
      'type': type.toString(),
      'effect': effect,
      'level': level,
    };
  }

  /// Crea un upgrade desde un Map
  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      baseCost: json['baseCost'],
      costMultiplier: json['costMultiplier'],
      type: UpgradeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => UpgradeType.clickPower,
      ),
      effect: json['effect'],
      level: json['level'] ?? 0,
    );
  }

  /// Copia el upgrade con nuevos valores
  Upgrade copyWith({
    String? id,
    String? name,
    String? description,
    double? baseCost,
    double? costMultiplier,
    UpgradeType? type,
    double? effect,
    int? level,
  }) {
    return Upgrade(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseCost: baseCost ?? this.baseCost,
      costMultiplier: costMultiplier ?? this.costMultiplier,
      type: type ?? this.type,
      effect: effect ?? this.effect,
      level: level ?? this.level,
    );
  }
}

/// Tipos de mejoras disponibles en el juego
enum UpgradeType {
  clickPower, // Aumenta puntos por click
  autoClicker, // Genera puntos automáticamente por segundo
  multiplier, // Multiplica el total de puntos obtenidos
}
