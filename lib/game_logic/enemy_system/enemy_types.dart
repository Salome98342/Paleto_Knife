import '../../models/element_type.dart';
import 'enemy_behavior.dart';
import 'attack_pattern.dart';

/// Región del enemigo
enum Region {
  asia,
  caribbean,
  europe,
}

/// Definición de un tipo de enemigo reutilizable
class EnemyTypeDefinition {
  /// ID único del tipo (ej: 'dumpling_coloso')
  final String id;

  /// Nombre del enemigo
  final String name;

  /// Descripción del enemigo
  final String description;

  /// Lore del enemigo
  final String lore;

  /// Región del enemigo
  final Region region;

  /// Elemento del enemigo
  final ElementType element;

  /// Tipo de enemigo (grunt, bruiser, shooter, tank, elite, boss)
  final String role;

  /// Vida base
  final double baseHealth;

  /// Comportamiento de movimiento
  final Behavior behavior;

  /// Patrón de ataque
  final AttackPattern attackPattern;

  /// Color para debug (ARGB)
  final int debugColor;

  /// Emojis de counters efectivos
  final List<String> counters;

  /// Visual description (para sprite/animación)
  final String visualDescription;

  EnemyTypeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.lore,
    required this.region,
    required this.element,
    required this.role,
    required this.baseHealth,
    required this.behavior,
    required this.attackPattern,
    required this.debugColor,
    required this.counters,
    required this.visualDescription,
  });

  /// Copia profunda
  EnemyTypeDefinition copyWith({
    String? id,
    String? name,
    String? description,
    String? lore,
    Region? region,
    ElementType? element,
    String? role,
    double? baseHealth,
    Behavior? behavior,
    AttackPattern? attackPattern,
    int? debugColor,
    List<String>? counters,
    String? visualDescription,
  }) {
    return EnemyTypeDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      lore: lore ?? this.lore,
      region: region ?? this.region,
      element: element ?? this.element,
      role: role ?? this.role,
      baseHealth: baseHealth ?? this.baseHealth,
      behavior: behavior ?? this.behavior,
      attackPattern: attackPattern ?? this.attackPattern,
      debugColor: debugColor ?? this.debugColor,
      counters: counters ?? this.counters,
      visualDescription: visualDescription ?? this.visualDescription,
    );
  }
}

/// Catálogo de tipos de enemigos predefinidos
class EnemyTypesCatalog {
  static final Map<String, EnemyTypeDefinition> _catalog = {};

  /// Registra un tipo de enemigo
  static void register(EnemyTypeDefinition definition) {
    _catalog[definition.id] = definition;
  }

  /// Obtiene un tipo de enemigo por ID
  static EnemyTypeDefinition? get(String id) => _catalog[id];

  /// Obtiene todos los tipos registrados
  static List<EnemyTypeDefinition> getAll() => _catalog.values.toList();

  /// Obtiene enemigos por región
  static List<EnemyTypeDefinition> getByRegion(Region region) {
    return _catalog.values.where((e) => e.region == region).toList();
  }

  /// Obtiene enemigos por rol
  static List<EnemyTypeDefinition> getByRole(String role) {
    return _catalog.values.where((e) => e.role == role).toList();
  }

  /// Verifica si existe un tipo
  static bool exists(String id) => _catalog.containsKey(id);

  /// Limpia el catálogo
  static void clear() => _catalog.clear();

  /// Inicializa los tipos de enemigos estándar
  static void initializeDefaults() {
    clear();

    // ============================================================
    // 🌏 ASIA (TIERRA)
    // ============================================================

    // 🟤 Dumpling Coloso (Tank)
    register(EnemyTypeDefinition(
      id: 'dumpling_coloso',
      name: 'Dumpling Coloso',
      description: 'Masa ancestral endurecida por siglos',
      lore: 'Un dumpling que se convirtió en una colación gigante y mineral tras siglos en la tierra',
      region: Region.asia,
      element: ElementType.earth,
      role: 'tank',
      baseHealth: 150.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 80.0,
        preferredDistance: 150.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 2.0,
        bulletSpeed: 150.0,
        bulletDamage: 12.0,
        bulletCount: 2,
      ),
      debugColor: 0xFF8D6E63,
      counters: ['🔥', '🌋', '🌱'],
      visualDescription: 'Gigante, agrietado, vapor interno',
    ));

    // 🟤 Gyoza Errante (Grunt)
    register(EnemyTypeDefinition(
      id: 'gyoza_errante',
      name: 'Gyoza Errante',
      description: 'Comida olvidada que cobró vida',
      lore: 'Un gyoza abandonado en las calles de un templo antiguo',
      region: Region.asia,
      element: ElementType.earth,
      role: 'grunt',
      baseHealth: 25.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 180.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 0.7,
        bulletSpeed: 250.0,
        bulletDamage: 4.0,
        bulletCount: 1,
      ),
      debugColor: 0xFFBDBDBD,
      counters: ['🔥'],
      visualDescription: 'Pequeño, saltarín, con expresión de sorpresa',
    ));

    // 🟤 Bola de Harina Maldita (Swarm)
    register(EnemyTypeDefinition(
      id: 'bola_harina_maldita',
      name: 'Bola de Harina Maldita',
      description: 'Fragmentos de masa corrupta',
      lore: 'Formaciones de masa que se mueven de forma sincronizada',
      region: Region.asia,
      element: ElementType.earth,
      role: 'swarm',
      baseHealth: 8.0,
      behavior: Behavior(
        type: BehaviorType.wander,
        speed: 120.0,
        acceleration: 40.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.radial,
        cooldown: 1.2,
        bulletSpeed: 200.0,
        bulletDamage: 2.0,
        bulletCount: 4,
      ),
      debugColor: 0xFFC2185B,
      counters: ['💨'],
      visualDescription: 'Múltiples esferas pequeñas girando',
    ));

    // 🟤 Tótem de Vapor (Shooter)
    register(EnemyTypeDefinition(
      id: 'totem_vapor',
      name: 'Tótem de Vapor',
      description: 'Utensilios poseídos',
      lore: 'Un bambú y herramientas de cocina poseídas por espíritus',
      region: Region.asia,
      element: ElementType.earth,
      role: 'shooter',
      baseHealth: 40.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 100.0,
        preferredDistance: 250.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 1.5,
        bulletSpeed: 280.0,
        bulletDamage: 6.0,
        bulletCount: 5,
        spreadAngle: 45.0,
      ),
      debugColor: 0xFF9CCC65,
      counters: ['🔥'],
      visualDescription: 'Columna de bambú con vapor saliendo',
    ));

    // ⚫ Raíz Hereje (Elite)
    register(EnemyTypeDefinition(
      id: 'raiz_hereje',
      name: 'Raíz Hereje',
      description: 'Raíces que cazan',
      lore: 'Raíces antiguas que adquirieron inteligencia maligna',
      region: Region.asia,
      element: ElementType.earth,
      role: 'elite',
      baseHealth: 120.0,
      behavior: Behavior(
        type: BehaviorType.circlePlayer,
        speed: 140.0,
        preferredDistance: 120.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 0.6,
        bulletSpeed: 320.0,
        bulletDamage: 9.0,
        bulletCount: 2,
      ),
      debugColor: 0xFF558B2F,
      counters: ['🔥', '🌋'],
      visualDescription: 'Raíces retorcidas y biomórficas',
    ));

    // ============================================================
    // 🌊 CARIBE (FUEGO)
    // ============================================================

    // 🔥 Jerk Infernal (Bruiser)
    register(EnemyTypeDefinition(
      id: 'jerk_infernal',
      name: 'Jerk Infernal',
      description: 'Bestia volcánica',
      lore: 'Un pollo cocinado a fuego obsceno que cobró vida',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'bruiser',
      baseHealth: 90.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 170.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 0.9,
        bulletSpeed: 280.0,
        bulletDamage: 8.0,
        bulletCount: 1,
      ),
      debugColor: 0xFFF44336,
      counters: ['💧'],
      visualDescription: 'Pollo en llamas, humeante, agresivo',
    ));

    // 🔥 Brasa Viva (Swarm)
    register(EnemyTypeDefinition(
      id: 'brasa_viva',
      name: 'Brasa Viva',
      description: 'Chispas vivientes',
      lore: 'Chispas de fuego que adquirieron consciencia',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'swarm',
      baseHealth: 12.0,
      behavior: Behavior(
        type: BehaviorType.wander,
        speed: 150.0,
        acceleration: 60.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.radial,
        cooldown: 1.0,
        bulletSpeed: 220.0,
        bulletDamage: 3.0,
        bulletCount: 6,
      ),
      debugColor: 0xFFFF6F00,
      counters: ['💨', '💧'],
      visualDescription: 'Pequeñas esferas de fuego flotando',
    ));

    // 🔥 Parrillero Maldito (Shooter)
    register(EnemyTypeDefinition(
      id: 'parrillero_maldito',
      name: 'Parrillero Maldito',
      description: 'Cocinero poseído',
      lore: 'Un cocinero de carne poseído por fuegos infernales',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'shooter',
      baseHealth: 60.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 110.0,
        preferredDistance: 200.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 1.3,
        bulletSpeed: 300.0,
        bulletDamage: 7.0,
        bulletCount: 4,
        spreadAngle: 50.0,
      ),
      debugColor: 0xFFBF360C,
      counters: ['💧'],
      visualDescription: 'Figura negra con brasas en el cuerpo',
    ));

    // 🔥 Bestia Ahumada (Tank)
    register(EnemyTypeDefinition(
      id: 'bestia_ahumada',
      name: 'Bestia Ahumada',
      description: 'Carne endurecida',
      lore: 'Carne asada que se endureció y cobró vida',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'tank',
      baseHealth: 140.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 90.0,
        preferredDistance: 180.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 1.8,
        bulletSpeed: 200.0,
        bulletDamage: 11.0,
        bulletCount: 2,
      ),
      debugColor: 0xFF5D4037,
      counters: ['💧', '🌱'],
      visualDescription: 'Masa oscura y ondulante de carne',
    ));

    // ⚫ Espíritu Picante (Elite)
    register(EnemyTypeDefinition(
      id: 'espiritu_picante',
      name: 'Espíritu Picante',
      description: 'Esencia ardiente',
      lore: 'La personificación del calor y el picante',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'elite',
      baseHealth: 110.0,
      behavior: Behavior(
        type: BehaviorType.circlePlayer,
        speed: 160.0,
        preferredDistance: 140.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.radial,
        cooldown: 0.8,
        bulletSpeed: 300.0,
        bulletDamage: 8.0,
        bulletCount: 8,
      ),
      debugColor: 0xFFE60000,
      counters: ['💧', '💨'],
      visualDescription: 'Silueta de fuego puro, incandescente',
    ));

    // ============================================================
    // 🌿 EUROPA (AGUA)
    // ============================================================

    // 💧 Sopa Abisal (Swarm)
    register(EnemyTypeDefinition(
      id: 'sopa_abisal',
      name: 'Sopa Abisal',
      description: 'Océano corrupto',
      lore: 'Gota de océano profundo que dejó de ser singular',
      region: Region.europe,
      element: ElementType.water,
      role: 'swarm',
      baseHealth: 15.0,
      behavior: Behavior(
        type: BehaviorType.wander,
        speed: 140.0,
        acceleration: 50.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 1.1,
        bulletSpeed: 240.0,
        bulletDamage: 3.5,
        bulletCount: 1,
      ),
      debugColor: 0xFF1565C0,
      counters: ['🌱', '💨'],
      visualDescription: 'Gotas azules brillantes moviéndose juntas',
    ));

    // 💧 Lancero de Caldo (Shooter)
    register(EnemyTypeDefinition(
      id: 'lancero_caldo',
      name: 'Lancero de Caldo',
      description: 'Guerrero de agua',
      lore: 'Un caldo que aprendió a arrojar proyectiles como lanzas',
      region: Region.europe,
      element: ElementType.water,
      role: 'shooter',
      baseHealth: 45.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 120.0,
        preferredDistance: 220.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 1.4,
        bulletSpeed: 290.0,
        bulletDamage: 6.5,
        bulletCount: 2,
      ),
      debugColor: 0xFF0D47A1,
      counters: ['🌳'],
      visualDescription: 'Columna de agua con forma humanoid',
    ));

    // 💧 Masa Fluvial (Grunt)
    register(EnemyTypeDefinition(
      id: 'masa_fluvial',
      name: 'Masa Fluvial',
      description: 'Agua corriente corrupta',
      lore: 'Agua de río que desarrolló su propia voluntad',
      region: Region.europe,
      element: ElementType.water,
      role: 'grunt',
      baseHealth: 30.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 160.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 0.8,
        bulletSpeed: 260.0,
        bulletDamage: 5.0,
        bulletCount: 1,
      ),
      debugColor: 0xFF42A5F5,
      counters: ['🌳'],
      visualDescription: 'Onda de agua fluyendo',
    ));

    // 💧 Gólem de Salmuera (Tank)
    register(EnemyTypeDefinition(
      id: 'golem_salmuera',
      name: 'Gólem de Salmuera',
      description: 'Agua cristalizada',
      lore: 'Agua salada que se solidificó en forma de guardian',
      region: Region.europe,
      element: ElementType.water,
      role: 'tank',
      baseHealth: 160.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 70.0,
        preferredDistance: 200.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.radial,
        cooldown: 2.2,
        bulletSpeed: 180.0,
        bulletDamage: 10.0,
        bulletCount: 3,
      ),
      debugColor: 0xFF00695C,
      counters: ['🌱', '🌋'],
      visualDescription: 'Cubo translúcido de agua congelada',
    ));

    // ⚫ Druida Corrupto (Elite)
    register(EnemyTypeDefinition(
      id: 'druida_corrupto',
      name: 'Druida Corrupto',
      description: 'Guardián del agua oscura',
      lore: 'Un protector del río que fue corrompido por fuerzas obscuras',
      region: Region.europe,
      element: ElementType.water,
      role: 'elite',
      baseHealth: 130.0,
      behavior: Behavior(
        type: BehaviorType.circlePlayer,
        speed: 150.0,
        preferredDistance: 160.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 1.0,
        bulletSpeed: 310.0,
        bulletDamage: 8.5,
        bulletCount: 5,
        spreadAngle: 60.0,
      ),
      debugColor: 0xFF1A447D,
      counters: ['🔥'],
      visualDescription: 'Figura de ramas y agua moviéndose en sincronía',
    ));

    // Fallback para grunt genérico
    register(EnemyTypeDefinition(
      id: 'grunt',
      name: 'Grunt',
      description: 'Enemigo básico agresivo',
      lore: 'Enemigo común sin historia especial',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'grunt',
      baseHealth: 20.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 150.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 0.8,
        bulletSpeed: 300.0,
        bulletDamage: 5.0,
        bulletCount: 1,
      ),
      debugColor: 0xFF00CC00,
      counters: [],
      visualDescription: 'Forma simple y genérica',
    ));

    // 🔵 SHOOTER - Mantiene distancia y dispara
    register(EnemyTypeDefinition(
      id: 'shooter',
      name: 'Shooter',
      description: 'Mantiene distancia y dispara con precisión',
      lore: 'Enemigo genérico tipo disparador',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'shooter',
      baseHealth: 15.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 100.0,
        preferredDistance: 250.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 1.2,
        bulletSpeed: 350.0,
        bulletDamage: 8.0,
        bulletCount: 1,
      ),
      debugColor: 0xFF0099FF,
      counters: [],
      visualDescription: 'Forma disparadora genérica',
    ));

    // 🟣 SWARM - Enjambre rápido
    register(EnemyTypeDefinition(
      id: 'swarm',
      name: 'Swarm',
      description: 'Pequeños enemigos rápidos que aparecen en grupos',
      lore: 'Enemigo genérico tipo enjambre',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'swarm',
      baseHealth: 5.0,
      behavior: Behavior(
        type: BehaviorType.wander,
        speed: 200.0,
        acceleration: 80.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.straight,
        cooldown: 2.0,
        bulletSpeed: 200.0,
        bulletDamage: 2.0,
        bulletCount: 1,
      ),
      debugColor: 0xFFCC00FF,
      counters: [],
      visualDescription: 'Múltiples esferas pequeñas',
    ));

    // 🔴 TANK - Resistente y lento
    register(EnemyTypeDefinition(
      id: 'tank',
      name: 'Tank',
      description: 'Tanque lento pero resistente',
      lore: 'Enemigo genérico tipo tanque',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'tank',
      baseHealth: 60.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 80.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 1.5,
        bulletSpeed: 250.0,
        bulletDamage: 6.0,
        bulletCount: 3,
        spreadAngle: 90.0,
      ),
      debugColor: 0xFFCC0000,
      counters: [],
      visualDescription: 'Forma grande y sólida',
    ));

    // 🟡 SNIPER - Poco movimiento, ataques dirigidos
    register(EnemyTypeDefinition(
      id: 'sniper',
      name: 'Sniper',
      description: 'Dispara con precisión desde lejos',
      lore: 'Enemigo genérico tipo francotirador',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'shooter',
      baseHealth: 25.0,
      behavior: Behavior(
        type: BehaviorType.circlePlayer,
        speed: 50.0,
        preferredDistance: 300.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 2.0,
        bulletSpeed: 400.0,
        bulletDamage: 12.0,
        bulletCount: 1,
      ),
      debugColor: 0xFFFFCC00,
      counters: [],
      visualDescription: 'Forma esbelta y vigilante',
    ));

    // ============================================================
    // 👑 JEFES (BOSSES)
    // ============================================================

    // 👑 Emperador Dumpling (Boss - Asia)
    register(EnemyTypeDefinition(
      id: 'emperador_dumpling',
      name: 'Emperador Dumpling',
      description: 'El soberano ancestral de la tierra',
      lore: 'Legenda cuenta que el primer dumpling que cobró vida ascendió a emperador tras siglos de dominio',
      region: Region.asia,
      element: ElementType.earth,
      role: 'boss',
      baseHealth: 500.0,
      behavior: Behavior(
        type: BehaviorType.keepDistance,
        speed: 100.0,
        preferredDistance: 200.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.radial,
        cooldown: 1.2,
        bulletSpeed: 200.0,
        bulletDamage: 15.0,
        bulletCount: 12,
      ),
      debugColor: 0xFF6D4C41,
      counters: ['🔥', '🌋'],
      visualDescription: 'Enorme, coronado, con aura de tierra',
    ));

    // 👑 Soberana del Fuego (Boss - Caribe)
    register(EnemyTypeDefinition(
      id: 'soberana_fuego',
      name: 'Soberana del Fuego',
      description: 'Recina infernal de los volcanes caribeños',
      lore: 'Emerger del corazón del volcán con furia primigenia acumulada',
      region: Region.caribbean,
      element: ElementType.fire,
      role: 'boss',
      baseHealth: 480.0,
      behavior: Behavior(
        type: BehaviorType.circlePlayer,
        speed: 130.0,
        preferredDistance: 180.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 1.0,
        bulletSpeed: 250.0,
        bulletDamage: 16.0,
        bulletCount: 8,
        spreadAngle: 90.0,
      ),
      debugColor: 0xFFD84315,
      counters: ['💧', '🌱'],
      visualDescription: 'Humanoides de fuego, corona de llamas',
    ));

    // 👑 Guardián de Hielo (Boss - Europa)
    register(EnemyTypeDefinition(
      id: 'guardian_hielo',
      name: 'Guardián de Hielo',
      description: 'Centinela eterno de los picos nevados',
      lore: 'Manifestación del frío absoluto que protege los secretos de la montaña',
      region: Region.europe,
      element: ElementType.water,
      role: 'boss',
      baseHealth: 520.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 120.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.aimed,
        cooldown: 0.8,
        bulletSpeed: 280.0,
        bulletDamage: 14.0,
        bulletCount: 3,
      ),
      debugColor: 0xFF00BCD4,
      counters: ['🔥', '🌋'],
      visualDescription: 'Cristales de hielo, forma angular y amenazante',
    ));

    // ⚫ ELITE - Versión mejorada de Grunt
    register(EnemyTypeDefinition(
      id: 'elite',
      name: 'Elite',
      description: 'Grunt mejorado con patrón de ataque complejo',
      lore: 'Enemigo genérico élite',
      region: Region.asia,
      element: ElementType.neutral,
      role: 'elite',
      baseHealth: 40.0,
      behavior: Behavior(
        type: BehaviorType.chase,
        speed: 180.0,
      ),
      attackPattern: AttackPattern(
        type: AttackPatternType.spread,
        cooldown: 0.6,
        bulletSpeed: 320.0,
        bulletDamage: 7.0,
        bulletCount: 5,
        spreadAngle: 120.0,
      ),
      debugColor: 0xFFFFFFFF,
      counters: [],
      visualDescription: 'Forma mejorada y resplandeciente',
    ));
  }
}
