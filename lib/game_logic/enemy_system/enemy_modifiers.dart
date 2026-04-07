/// Tipos de modificadores especiales que pueden aplicarse a enemigos
enum ModifierType {
  giant,      // +100% HP, escala visual 1.5x
  armor,      // Reducción de daño recibido (-25%)
  multiple,   // Genera clones al morir o cuando alcanza 50% HP
}

/// Configuración de un modificador de enemigo
class EnemyModifier {
  /// Tipo de modificador
  final ModifierType type;

  /// Multiplicador de HP (si aplica)
  final double healthMultiplier;

  /// Reducción de daño (0.0-1.0, donde 1.0 = sin reducción)
  final double damageReduction;

  /// Cantidad de clones generados (para multiple)
  final int cloneCount;

  /// Escala visual del enemigo
  final double visualScale;

  /// Nombre para UI/logging
  final String name;

  /// Descripción para UI
  final String description;

  /// Color para identificar visualmente
  final int color;

  EnemyModifier({
    required this.type,
    this.healthMultiplier = 1.0,
    this.damageReduction = 1.0,
    this.cloneCount = 1,
    this.visualScale = 1.0,
    required this.name,
    required this.description,
    required this.color,
  });

  /// Crea un modificador GIGANTE
  factory EnemyModifier.giant() {
    return EnemyModifier(
      type: ModifierType.giant,
      healthMultiplier: 2.0,      // +100% HP
      visualScale: 1.5,            // 50% más grande
      name: 'Gigante',
      description: '+100% HP, 50% más grande',
      color: 0xFFFFD700,  // Oro
    );
  }

  /// Crea un modificador ARMOR
  factory EnemyModifier.armor() {
    return EnemyModifier(
      type: ModifierType.armor,
      damageReduction: 0.75,       // -25% daño recibido
      visualScale: 1.1,             // Ligeramente más grande
      name: 'Armadura',
      description: '-25% daño recibido, defensa mejorada',
      color: 0xFF808080,  // Plata
    );
  }

  /// Crea un modificador MULTIPLE
  factory EnemyModifier.multiple({int cloneCount = 2}) {
    return EnemyModifier(
      type: ModifierType.multiple,
      cloneCount: cloneCount,
      name: 'Múltiple',
      description: 'Genera $cloneCount clones al dividirse',
      color: 0xFF9C27B0,  // Púrpura
    );
  }

  /// Aplica el daño considerando la reducción de armadura
  double applyDamageReduction(double damage) {
    return damage * damageReduction;
  }

  /// Obtiene el multiplicador de HP efectivo
  double getHealthMultiplier() {
    return healthMultiplier;
  }
}

/// Base de datos de combinaciones de modificadores
class ModifierCombination {
  /// Modificadores aplicados simultáneamente
  final List<EnemyModifier> modifiers;

  /// Nombre de la combinación
  final String name;

  /// Color representativo (mezcla de colores)
  final int color;

  ModifierCombination({
    required this.modifiers,
    required this.name,
    required this.color,
  });

  /// Obtiene el multiplicador total de HP
  double getTotalHealthMultiplier() {
    return modifiers.fold(1.0, (acc, mod) => acc * mod.healthMultiplier);
  }

  /// Obtiene la reducción de daño final
  double getFinalDamageReduction() {
    // Si hay armadura, aplicar la reducción
    for (var mod in modifiers) {
      if (mod.type == ModifierType.armor) {
        return mod.damageReduction;
      }
    }
    return 1.0; // Sin reducción
  }

  /// Obtiene la escala visual combinada
  double getCombinedVisualScale() {
    return modifiers.fold(1.0, (acc, mod) => acc * mod.visualScale);
  }

  /// Verifica si tiene el modificador MULTIPLE
  bool hasMultiple() {
    return modifiers.any((m) => m.type == ModifierType.multiple);
  }

  /// Obtiene el total de clones
  int getTotalClones() {
    int total = 1;
    for (var mod in modifiers) {
      if (mod.type == ModifierType.multiple) {
        total = mod.cloneCount;
      }
    }
    return total;
  }
}

/// Catálogo de combinaciones de modificadores predefinidas
class ModifierCatalog {
  static final Map<String, ModifierCombination> _combinations = {};

  /// Registra una combinación
  static void register(ModifierCombination combination) {
    _combinations[combination.name] = combination;
  }

  /// Obtiene una combinación por nombre
  static ModifierCombination? get(String name) => _combinations[name];

  /// Obtiene todas las combinaciones
  static List<ModifierCombination> getAll() => _combinations.values.toList();

  /// Limpia el catálogo
  static void clear() => _combinations.clear();

  /// Inicializa las combinaciones estándar
  static void initializeDefaults() {
    clear();

    // Combinaciones individuales
    register(ModifierCombination(
      modifiers: [EnemyModifier.giant()],
      name: 'giant',
      color: 0xFFFFD700,
    ));

    register(ModifierCombination(
      modifiers: [EnemyModifier.armor()],
      name: 'armor',
      color: 0xFF808080,
    ));

    register(ModifierCombination(
      modifiers: [EnemyModifier.multiple(cloneCount: 2)],
      name: 'multiple',
      color: 0xFF9C27B0,
    ));

    // Combinaciones especiales
    register(ModifierCombination(
      modifiers: [
        EnemyModifier.giant(),
        EnemyModifier.armor(),
      ],
      name: 'giant_armor',
      color: 0xFFFFC700,  // Oro oscuro
    ));

    register(ModifierCombination(
      modifiers: [
        EnemyModifier.armor(),
        EnemyModifier.multiple(cloneCount: 2),
      ],
      name: 'armor_multiple',
      color: 0xFF7B1FA2,  // Púrpura oscuro
    ));

    register(ModifierCombination(
      modifiers: [
        EnemyModifier.giant(),
        EnemyModifier.multiple(cloneCount: 3),
      ],
      name: 'giant_multiple',
      color: 0xFFD4AF37,  // Oro
    ));
  }
}
