import 'element_type.dart';

/// Modelo de Cuchillo Especial (Skin coleccionable)
/// Cada cuchillo equipado activa una habilidad pasiva con niveles
class Knife {
  final String id;
  final String name;
  final String description;
  final KnifeRarity rarity;
  final KnifeAbility ability;
  bool isUnlocked; // Si el jugador lo ha coleccionado
  bool isEquipped; // Si esta equipado actualmente
  int abilityLevel; // Nivel de la habilidad (mejora con fragmentos)
  int fragments; // Fragmentos acumulados

  Knife({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.ability,
    this.isUnlocked = false,
    this.isEquipped = false,
    this.abilityLevel = 1,
    this.fragments = 0,
  });

  /// Obtiene el bono de la habilidad segun nivel
  /// SEGUN DOCUMENTO:
  /// - Damage Boost: +10% por nivel
  /// - Critical Boost: +5% por nivel
  /// - Gold Boost: +15% por nivel
  /// - Attack Speed: +8% por nivel
  /// - Multi-Strike: +3% probabilidad por nivel
  double get abilityBonus {
    switch (ability) {
      case KnifeAbility.damageBoost:
        return 0.10 * abilityLevel; // +10% por nivel
      case KnifeAbility.critBoost:
        return 0.05 * abilityLevel; // +5% por nivel
      case KnifeAbility.goldBoost:
        return 0.15 * abilityLevel; // +15% por nivel
      case KnifeAbility.speedBoost:
        return 0.08 * abilityLevel; // +8% por nivel
      case KnifeAbility.accuracyBoost:
        return 0.05 * abilityLevel; // +5% por nivel
      case KnifeAbility.multiStrike:
        return 0.03 * abilityLevel; // +3% por nivel
    }
  }

  /// Fragmentos necesarios para subir nivel (segun rareza)
  int get fragmentsNeeded {
    return rarity.fragmentsForUpgrade;
  }

  /// Puede subir de nivel si tiene suficientes fragmentos
  bool get canLevelUp => fragments >= fragmentsNeeded;

  /// Sube un nivel consumiendo fragmentos
  void levelUp() {
    if (canLevelUp) {
      fragments -= fragmentsNeeded;
      abilityLevel++;
    }
  }

  /// Agrega fragmentos
  void addFragments(int amount) {
    fragments += amount;
  }

  /// Cuchillos predefinidos (segun documento: 13 skins total)
  static List<Knife> getDefaultKnives() {
    return [
      // ===== COMUNES (5 skins) =====
      Knife(
        id: 'basic_knife',
        name: 'Cuchillo Basico',
        description: 'El cuchillo estandar del Chef',
        rarity: KnifeRarity.common,
        ability: KnifeAbility.damageBoost,
        isUnlocked: true,
        isEquipped: true,
      ),
      Knife(
        id: 'paring_knife',
        name: 'Cuchillo Mondador',
        description: 'Pequeno pero preciso',
        rarity: KnifeRarity.common,
        ability: KnifeAbility.accuracyBoost,
      ),
      Knife(
        id: 'bread_knife',
        name: 'Cuchillo de Pan',
        description: 'Con filo serrado',
        rarity: KnifeRarity.common,
        ability: KnifeAbility.speedBoost,
      ),
      Knife(
        id: 'cleaver',
        name: 'Macheta',
        description: 'Pesado y contundente',
        rarity: KnifeRarity.common,
        ability: KnifeAbility.damageBoost,
      ),
      Knife(
        id: 'utility_knife',
        name: 'Cuchillo Multiusos',
        description: 'Versatil y equilibrado',
        rarity: KnifeRarity.common,
        ability: KnifeAbility.multiStrike,
      ),
      
      // ===== RARAS (3 skins) =====
      Knife(
        id: 'butcher_knife',
        name: 'Cuchillo Carnicero',
        description: 'Pesado y contundente',
        rarity: KnifeRarity.rare,
        ability: KnifeAbility.damageBoost,
      ),
      Knife(
        id: 'chef_knife',
        name: 'Cuchillo Chef',
        description: 'El preferido de los profesionales',
        rarity: KnifeRarity.rare,
        ability: KnifeAbility.speedBoost,
      ),
      Knife(
        id: 'boning_knife',
        name: 'Cuchillo Deshuesador',
        description: 'Flexible y mortifero',
        rarity: KnifeRarity.rare,
        ability: KnifeAbility.critBoost,
      ),
      
      // ===== EPICAS (2 skins) =====
      Knife(
        id: 'sushi_knife',
        name: 'Cuchillo Sushi',
        description: 'Afilado como el agua',
        rarity: KnifeRarity.epic,
        ability: KnifeAbility.critBoost,
      ),
      Knife(
        id: 'golden_knife',
        name: 'Cuchillo Dorado',
        description: 'Atrae la riqueza',
        rarity: KnifeRarity.epic,
        ability: KnifeAbility.goldBoost,
      ),
      
      // ===== LEGENDARIAS (2 skins) =====
      Knife(
        id: 'dragon_knife',
        name: 'Cuchillo del Dragon',
        description: 'Forjado en fuego legendario',
        rarity: KnifeRarity.legendary,
        ability: KnifeAbility.damageBoost,
      ),
      Knife(
        id: 'master_blade',
        name: 'Hoja del Maestro',
        description: 'Nunca falla su objetivo',
        rarity: KnifeRarity.legendary,
        ability: KnifeAbility.multiStrike,
      ),
      
      // ===== MITICA (1 skin) =====
      Knife(
        id: 'excalibur_knife',
        name: 'Excalibur Culinario',
        description: 'El arma del Chef supremo',
        rarity: KnifeRarity.mythic,
        ability: KnifeAbility.damageBoost,
      ),
    ];
  }

  /// Conversion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity.name,
      'ability': ability.name,
      'isUnlocked': isUnlocked,
      'isEquipped': isEquipped,
      'abilityLevel': abilityLevel,
      'fragments': fragments,
    };
  }

  /// Creacion desde JSON
  factory Knife.fromJson(Map<String, dynamic> json) {
    return Knife(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rarity: KnifeRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => KnifeRarity.common,
      ),
      ability: KnifeAbility.values.firstWhere(
        (e) => e.name == json['ability'],
        orElse: () => KnifeAbility.damageBoost,
      ),
      isUnlocked: json['isUnlocked'] ?? false,
      isEquipped: json['isEquipped'] ?? false,
      abilityLevel: json['abilityLevel'] ?? 1,
      fragments: json['fragments'] ?? 0,
    );
  }
}

/// Rareza de los cuchillos
/// SEGUN DOCUMENTO:
/// - Comun: 60% probabilidad, 1 fragmento para mejorar
/// - Rara: 25% probabilidad, 2 fragmentos para mejorar
/// - Epica: 10% probabilidad, 5 fragmentos para mejorar
/// - Legendaria: 4% probabilidad, 10 fragmentos para mejorar
/// - Mitica: 1% probabilidad, 25 fragmentos para mejorar
enum KnifeRarity {
  common('Comun', 1.0, 1, 60),
  rare('Rara', 1.5, 2, 25),
  epic('Epica', 2.0, 5, 10),
  legendary('Legendaria', 3.0, 10, 4),
  mythic('Mitica', 5.0, 25, 1);

  final String displayName;
  final double multiplier;
  final int fragmentsForUpgrade; // Fragmentos necesarios para subir nivel
  final int dropChance; // Probabilidad de drop (0-100)
  
  const KnifeRarity(
    this.displayName,
    this.multiplier,
    this.fragmentsForUpgrade,
    this.dropChance,
  );

  /// Color asociado a la rareza
  int getColor() {
    switch (this) {
      case KnifeRarity.common:
        return 0xFF9E9E9E; // Gris
      case KnifeRarity.rare:
        return 0xFF2196F3; // Azul
      case KnifeRarity.epic:
        return 0xFF9C27B0; // Purpura
      case KnifeRarity.legendary:
        return 0xFFFF9800; // Naranja
      case KnifeRarity.mythic:
        return 0xFFFFD700; // Dorado/Rojo brillante
    }
  }
}

/// Habilidades de los cuchillos
/// SEGUN DOCUMENTO:
/// - Damage Boost: +10% dano por nivel
/// - Critical Boost: +5% critico por nivel
/// - Gold Boost: +15% oro por nivel
/// - Attack Speed: +8% velocidad por nivel
/// - Multi-Strike: +3% probabilidad de doble golpe por nivel
enum KnifeAbility {
  damageBoost('Dano aumentado'),
  critBoost('Critico aumentado'),
  goldBoost('Oro aumentado'),
  speedBoost('Velocidad aumentada'),
  accuracyBoost('Precision aumentada'),
  multiStrike('Golpe multiple');

  final String displayName;
  const KnifeAbility(this.displayName);
}

/// Modelo de Joya (Collar o Anillo)
class Jewel {
  final String id;
  final String name;
  final String description;
  final JewelType type;
  final JewelStat stat;
  final double bonus;
  bool isUnlocked;
  bool isEquipped;

  Jewel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.stat,
    required this.bonus,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  /// Joyas predefinidas
  static List<Jewel> getDefaultJewels() {
    return [
      // Collares
      Jewel(
        id: 'power_necklace',
        name: 'Collar del Poder',
        description: 'Aumenta tu dano',
        type: JewelType.necklace,
        stat: JewelStat.damage,
        bonus: 0.20,
      ),
      Jewel(
        id: 'crit_necklace',
        name: 'Collar Critico',
        description: 'Aumenta tu probabilidad de critico',
        type: JewelType.necklace,
        stat: JewelStat.critChance,
        bonus: 0.15,
      ),
      
      // Anillos
      Jewel(
        id: 'fortune_ring',
        name: 'Anillo de la Fortuna',
        description: 'Aumenta el oro ganado',
        type: JewelType.ring,
        stat: JewelStat.gold,
        bonus: 0.25,
      ),
      Jewel(
        id: 'speed_ring',
        name: 'Anillo de Velocidad',
        description: 'Aumenta tu velocidad de ataque',
        type: JewelType.ring,
        stat: JewelStat.attackSpeed,
        bonus: 0.18,
      ),
    ];
  }

  /// Conversion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'stat': stat.name,
      'bonus': bonus,
      'isUnlocked': isUnlocked,
      'isEquipped': isEquipped,
    };
  }

  /// Creacion desde JSON
  factory Jewel.fromJson(Map<String, dynamic> json) {
    return Jewel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: JewelType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => JewelType.necklace,
      ),
      stat: JewelStat.values.firstWhere(
        (e) => e.name == json['stat'],
        orElse: () => JewelStat.damage,
      ),
      bonus: json['bonus'],
      isUnlocked: json['isUnlocked'] ?? false,
      isEquipped: json['isEquipped'] ?? false,
    );
  }
}

/// Tipo de joya
enum JewelType {
  necklace('Collar'),
  ring('Anillo');

  final String displayName;
  const JewelType(this.displayName);
}

/// Estadistica que mejora la joya
enum JewelStat {
  damage('Dano'),
  critChance('Critico'),
  gold('Oro'),
  attackSpeed('Velocidad');

  final String displayName;
  const JewelStat(this.displayName);
}

/// Modelo de Reliquia (potencia Sous-chefs)
/// Segun documento: puede ser especifica para un sous-chef o elemental
class Relic {
  final String id;
  final String name;
  final String description;
  final int tier; // 1-5 (mayor tier = mayor bonificacion)
  final double damageBonus; // Bono de dano
  final String? targetSousChefId; // ID del sous-chef que potencia (si es especifica)
  final ElementType? targetElement; // Elemento que potencia (si es elemental)
  bool isEquipped;

  Relic({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.damageBonus,
    this.targetSousChefId,
    this.targetElement,
    this.isEquipped = false,
  });

  /// Verifica si es una reliquia especifica (para un sous-chef concreto)
  bool get isSpecific => targetSousChefId != null;

  /// Verifica si es una reliquia elemental (para elementos)
  bool get isElemental => targetElement != null;

  /// Reliquias predefinidas
  static List<Relic> getDefaultRelics() {
    return [
      // Reliquias especificas tier 1
      Relic(
        id: 'apprentice_relic',
        name: 'Emblema del Aprendiz',
        description: '+50% DPS al Chef Aprendiz',
        tier: 1,
        damageBonus: 0.50,
        targetSousChefId: 'apprentice',
      ),
      
      // Reliquias elementales tier 2
      Relic(
        id: 'fire_tome',
        name: 'Tomo del Fuego',
        description: '+80% DPS a sous-chefs de Fuego',
        tier: 2,
        damageBonus: 0.80,
        targetElement: ElementType.fire,
      ),
      Relic(
        id: 'water_tome',
        name: 'Tomo del Agua',
        description: '+80% DPS a sous-chefs de Agua',
        tier: 2,
        damageBonus: 0.80,
        targetElement: ElementType.water,
      ),
      Relic(
        id: 'earth_tome',
        name: 'Tomo de la Tierra',
        description: '+80% DPS a sous-chefs de Tierra',
        tier: 2,
        damageBonus: 0.80,
        targetElement: ElementType.earth,
      ),
    ];
  }

  /// Conversion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tier': tier,
      'damageBonus': damageBonus,
      'targetSousChefId': targetSousChefId,
      'targetElement': targetElement?.name,
      'isEquipped': isEquipped,
    };
  }

  /// Creacion desde JSON
  factory Relic.fromJson(Map<String, dynamic> json) {
    ElementType? element;
    if (json['targetElement'] != null) {
      try {
        element = ElementType.values.firstWhere(
          (e) => e.name == json['targetElement'],
        );
      } catch (e) {
        element = null;
      }
    }
    
    return Relic(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tier: json['tier'] ?? 1,
      damageBonus: json['damageBonus'] ?? 0.5,
      targetSousChefId: json['targetSousChefId'],
      targetElement: element,
      isEquipped: json['isEquipped'] ?? false,
    );
  }
}

/// Modelo de Idolo Culinario (bonus alto con penalizacion)
class Idol {
  final String id;
  final String name;
  final String description;
  final IdolBonus bonusType;
  final double bonusValue;
  final IdolPenalty penaltyType;
  final double penaltyValue;
  bool isActive;

  Idol({
    required this.id,
    required this.name,
    required this.description,
    required this.bonusType,
    required this.bonusValue,
    required this.penaltyType,
    required this.penaltyValue,
    this.isActive = false,
  });

  /// Idolos predefinidos
  static List<Idol> getDefaultIdols() {
    return [
      Idol(
        id: 'butcher_idol',
        name: 'Cuchillo Carnicero',
        description: '+50% dano, -20% defensa',
        bonusType: IdolBonus.damage,
        bonusValue: 0.50,
        penaltyType: IdolPenalty.defense,
        penaltyValue: 0.20,
      ),
      Idol(
        id: 'golden_spoon',
        name: 'Cuchara de Oro',
        description: '+40% oro, -15% dano',
        bonusType: IdolBonus.gold,
        bonusValue: 0.40,
        penaltyType: IdolPenalty.damage,
        penaltyValue: 0.15,
      ),
      Idol(
        id: 'lightning_whisk',
        name: 'Batidor Relampago',
        description: '+35% velocidad, -10% critico',
        bonusType: IdolBonus.speed,
        bonusValue: 0.35,
        penaltyType: IdolPenalty.crit,
        penaltyValue: 0.10,
      ),
      Idol(
        id: 'michelin_star',
        name: 'Estrella Michelin',
        description: '+40% dano, -20% velocidad',
        bonusType: IdolBonus.damage,
        bonusValue: 0.40,
        penaltyType: IdolPenalty.speed,
        penaltyValue: 0.20,
      ),
    ];
  }

  /// Conversion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bonusType': bonusType.name,
      'bonusValue': bonusValue,
      'penaltyType': penaltyType.name,
      'penaltyValue': penaltyValue,
      'isActive': isActive,
    };
  }

  /// Creacion desde JSON
  factory Idol.fromJson(Map<String, dynamic> json) {
    return Idol(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      bonusType: IdolBonus.values.firstWhere(
        (e) => e.name == json['bonusType'],
        orElse: () => IdolBonus.damage,
      ),
      bonusValue: json['bonusValue'],
      penaltyType: IdolPenalty.values.firstWhere(
        (e) => e.name == json['penaltyType'],
        orElse: () => IdolPenalty.damage,
      ),
      penaltyValue: json['penaltyValue'],
      isActive: json['isActive'] ?? false,
    );
  }
}

/// Bonos de idolos
enum IdolBonus {
  damage,
  gold,
  speed,
  crit,
}

/// Penalizaciones de idolos
enum IdolPenalty {
  damage,
  defense,
  speed,
  crit,
}
