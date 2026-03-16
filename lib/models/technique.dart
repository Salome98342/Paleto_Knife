/// Modelo de Técnica (mejora del Chef)
/// Las técnicas son mejoras permanentes que se compran con oro
class Technique {
  final String id;
  final String name;
  final String description;
  final TechniqueType type;
  final double baseEffect; // Efecto base por nivel
  final double baseCost; // Costo inicial
  final double costMultiplier; // Multiplicador de costo por nivel
  int level; // Nivel actual

  Technique({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.baseEffect,
    required this.baseCost,
    this.costMultiplier = 1.2,
    this.level = 0,
  });

  /// Calcula el costo actual para subir de nivel
  double get currentCost {
    if (level == 0) return baseCost;
    return baseCost * (costMultiplier * level);
  }

  /// Calcula el efecto total acumulado
  double get totalEffect {
    return baseEffect * level;
  }

  /// Sube un nivel a la técnica
  void levelUp() {
    level++;
  }

  /// Técnicas predefinidas según el documento
  static List<Technique> getDefaultTechniques() {
    return [
      Technique(
        id: 'sharpen_knives',
        name: 'Afilado de Cuchillos',
        description: '+1 daño base por nivel',
        type: TechniqueType.damage,
        baseEffect: 1.0,
        baseCost: 10,
        costMultiplier: 1.15,
      ),
      Technique(
        id: 'manual_dexterity',
        name: 'Destreza Manual',
        description: '+5% velocidad de ataque por nivel',
        type: TechniqueType.attackSpeed,
        baseEffect: 0.05,
        baseCost: 25,
        costMultiplier: 1.2,
      ),
      Technique(
        id: 'golden_bacon',
        name: 'Golden Bacon',
        description: '+10% oro ganado por nivel',
        type: TechniqueType.goldBonus,
        baseEffect: 0.10,
        baseCost: 50,
        costMultiplier: 1.25,
      ),
      Technique(
        id: 'precision_cut',
        name: 'Corte de Precisión',
        description: '+2% probabilidad de crítico por nivel',
        type: TechniqueType.critChance,
        baseEffect: 0.02,
        baseCost: 75,
        costMultiplier: 1.3,
      ),
      Technique(
        id: 'lethal_technique',
        name: 'Técnica Letal',
        description: '+25% daño crítico por nivel',
        type: TechniqueType.critDamage,
        baseEffect: 0.25,
        baseCost: 100,
        costMultiplier: 1.35,
      ),
      Technique(
        id: 'culinary_precision',
        name: 'Precisión Culinaria',
        description: '+5% precisión (menos misses) por nivel',
        type: TechniqueType.accuracy,
        baseEffect: 0.05,
        baseCost: 150,
        costMultiplier: 1.4,
      ),
    ];
  }

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'baseEffect': baseEffect,
      'baseCost': baseCost,
      'costMultiplier': costMultiplier,
      'level': level,
    };
  }

  /// Creación desde JSON
  factory Technique.fromJson(Map<String, dynamic> json) {
    return Technique(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TechniqueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TechniqueType.damage,
      ),
      baseEffect: json['baseEffect'],
      baseCost: json['baseCost'],
      costMultiplier: json['costMultiplier'] ?? 1.2,
      level: json['level'] ?? 0,
    );
  }

  /// Copia con nuevos valores
  Technique copyWith({
    String? id,
    String? name,
    String? description,
    TechniqueType? type,
    double? baseEffect,
    double? baseCost,
    double? costMultiplier,
    int? level,
  }) {
    return Technique(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      baseEffect: baseEffect ?? this.baseEffect,
      baseCost: baseCost ?? this.baseCost,
      costMultiplier: costMultiplier ?? this.costMultiplier,
      level: level ?? this.level,
    );
  }
}

/// Tipos de técnicas disponibles
enum TechniqueType {
  damage, // Aumenta el daño base
  attackSpeed, // Aumenta la velocidad de ataque
  goldBonus, // Aumenta el oro ganado
  critChance, // Aumenta la probabilidad de crítico
  critDamage, // Aumenta el daño crítico
  accuracy, // Aumenta la precisión (reduce misses)
}
