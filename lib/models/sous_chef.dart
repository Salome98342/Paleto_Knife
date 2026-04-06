import 'element_type.dart';

/// Modelo de Sous-chef (ayudante automatico)
/// Los Sous-chefs atacan automaticamente generando DPS pasivo
class SousChef {
  final String id;
  final String name;
  final String description;
  final ElementType element;
  final double baseDps; // DPS base del sous-chef
  final double baseCost; // Costo inicial para contratar
  final double costMultiplier; // Multiplicador por cada nivel
  final int worldRequirement; // Mundo minimo para desbloquear
  int level; // Nivel actual
  bool isActive; // Si esta activo en uno de los 5 slots
  String? relicId; // ID de la reliquia equipada (opcional)

  SousChef({
    required this.id,
    required this.name,
    required this.description,
    required this.element,
    required this.baseDps,
    required this.baseCost,
    this.costMultiplier = 1.15,
    this.worldRequirement = 1,
    this.level = 0,
    this.isActive = false,
    this.relicId,
  });

  /// Calcula el costo actual para subir de nivel
  double get currentCost {
    if (level == 0) return baseCost;
    return baseCost * (costMultiplier * level);
  }

  /// Calcula el DPS actual considerando nivel y reliquia
  double getCurrentDps({double relicBonus = 0}) {
    double dps = baseDps * (level + 1);

    // Aplicar bono de reliquia si existe
    if (relicId != null && relicBonus > 0) {
      dps *= (1 + relicBonus);
    }

    return dps;
  }

  /// Calcula el DPS con ventaja elemental
  double getDpsAgainst(ElementType enemyElement, {double relicBonus = 0}) {
    double baseDps = getCurrentDps(relicBonus: relicBonus);
    double multiplier = element.getAdvantageAgainst(enemyElement);
    return baseDps * multiplier;
  }

  /// Sube un nivel al sous-chef
  void levelUp() {
    level++;
  }

  /// Activa/desactiva el sous-chef
  void toggleActive() {
    isActive = !isActive;
  }

  /// Equipa una reliquia
  void equipRelic(String? newRelicId) {
    relicId = newRelicId;
  }

  /// Sous-chefs predefinidos
  static List<SousChef> getDefaultSousChefs() {
    return [
      // Chef Aprendiz - Disponible desde el inicio
      SousChef(
        id: 'apprentice',
        name: 'Chef Aprendiz',
        description: 'Un principiante entusiasta que ayuda con lo basico',
        element: ElementType.neutral,
        baseDps: 0.5,
        baseCost: 10,
        worldRequirement: 1,
      ),

      // Chef Sushiman - Mundo 2 (Agua)
      SousChef(
        id: 'sushiman',
        name: 'Chef Sushiman',
        description: 'Experto en cocina asiatica y tecnicas acuaticas',
        element: ElementType.water,
        baseDps: 2.0,
        baseCost: 100,
        worldRequirement: 2,
      ),

      // Chef Parrillero - Mundo 3 (Fuego)
      SousChef(
        id: 'grillmaster',
        name: 'Chef Parrillero',
        description: 'Maestro del fuego y las brasas',
        element: ElementType.fire,
        baseDps: 5.0,
        baseCost: 500,
        worldRequirement: 3,
      ),

      // Chef Panadero - Mundo 4 (Tierra)
      SousChef(
        id: 'baker',
        name: 'Chef Panadero',
        description: 'Artesano de masas y reposteria',
        element: ElementType.earth,
        baseDps: 12.0,
        baseCost: 2500,
        worldRequirement: 4,
      ),

      // Chef Ejecutivo - Mundo 5 (Maestro)
      SousChef(
        id: 'executive',
        name: 'Chef Ejecutivo',
        description: 'Domina todas las tecnicas culinarias',
        element: ElementType.master,
        baseDps: 30.0,
        baseCost: 10000,
        worldRequirement: 5,
      ),
    ];
  }

  /// Conversion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'element': element.name,
      'baseDps': baseDps,
      'baseCost': baseCost,
      'costMultiplier': costMultiplier,
      'worldRequirement': worldRequirement,
      'level': level,
      'isActive': isActive,
      'relicId': relicId,
    };
  }

  /// Creacion desde JSON
  factory SousChef.fromJson(Map<String, dynamic> json) {
    return SousChef(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      element: ElementType.values.firstWhere(
        (e) => e.name == json['element'],
        orElse: () => ElementType.neutral,
      ),
      baseDps: json['baseDps'],
      baseCost: json['baseCost'],
      costMultiplier: json['costMultiplier'] ?? 1.15,
      worldRequirement: json['worldRequirement'] ?? 1,
      level: json['level'] ?? 0,
      isActive: json['isActive'] ?? false,
      relicId: json['relicId'],
    );
  }

  /// Copia con nuevos valores
  SousChef copyWith({
    String? id,
    String? name,
    String? description,
    ElementType? element,
    double? baseDps,
    double? baseCost,
    double? costMultiplier,
    int? worldRequirement,
    int? level,
    bool? isActive,
    String? relicId,
  }) {
    return SousChef(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      element: element ?? this.element,
      baseDps: baseDps ?? this.baseDps,
      baseCost: baseCost ?? this.baseCost,
      costMultiplier: costMultiplier ?? this.costMultiplier,
      worldRequirement: worldRequirement ?? this.worldRequirement,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      relicId: relicId ?? this.relicId,
    );
  }
}
