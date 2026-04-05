import 'dart:math';
import 'technique.dart';
import 'sous_chef.dart';
import 'equipment.dart';
import 'reset_bonus.dart';
import 'element_type.dart';

/// Modelo que representa el estado completo del juego
/// Contiene todos los datos del progreso del jugador
class GameState {
  // Recursos básicos
  double gold; // Oro actual
  int knifeFragments; // Fragmentos de cuchillo
  
  // Sistema de drops especiales
  int relicChests; // Cofres de Reliquia (necesitas 3 para abrir)
  double relicChestProgress; // Progreso hacia el siguiente cofre (0-1)
  int cultHearts; // Corazones de Culto (necesitas 3 para abrir)
  double cultHeartProgress; // Progreso hacia el siguiente corazón (0-1)
  
  // Progreso
  int currentLevel; // Nivel actual (1-500+)
  int currentWorld; // Mundo actual (1-12)
  int enemiesDefeated; // Total de enemigos derrotados
  int totalClicks; // Total de clicks realizados
  
  // Estadísticas del Chef
  double baseDamage;
  double attackSpeed;
  double critChance;
  double critMultiplier;
  double accuracy;
  double goldBonus;
  
  // Système de mejoras
  List<Technique> techniques; // Técnicas del Chef
  List<SousChef> sousChefs; // Sous-chefs disponibles
  
  // Equipamiento
  List<Knife> knives; // Cuchillos coleccionables
  List<Jewel> jewels; // Joyas (collares y anillos)
  List<Relic> relics; // Reliquias para sous-chefs
  List<Idol> idols; // Ídolos culinarios
  
  // Sistema de reinicio
  ResetState resetState;
  
  // Metadatos
  DateTime lastSaveTime; // Última vez que se guardó el juego

  GameState({
    this.gold = 0,
    this.knifeFragments = 0,
    this.relicChests = 0,
    this.relicChestProgress = 0.0,
    this.cultHearts = 0,
    this.cultHeartProgress = 0.0,
    this.currentLevel = 1,
    this.currentWorld = 1,
    this.enemiesDefeated = 0,
    this.totalClicks = 0,
    this.baseDamage = 10,
    this.attackSpeed = 1.0,
    this.critChance = 0.05,
    this.critMultiplier = 2.0,
    this.accuracy = 0.85,
    this.goldBonus = 0.0,
    List<Technique>? techniques,
    List<SousChef>? sousChefs,
    List<Knife>? knives,
    List<Jewel>? jewels,
    List<Relic>? relics,
    List<Idol>? idols,
    ResetState? resetState,
    DateTime? lastSaveTime,
  })  : techniques = techniques ?? Technique.getDefaultTechniques(),
        sousChefs = sousChefs ?? SousChef.getDefaultSousChefs(),
        knives = knives ?? Knife.getDefaultKnives(),
        jewels = jewels ?? Jewel.getDefaultJewels(),
        relics = relics ?? Relic.getDefaultRelics(),
        idols = idols ?? Idol.getDefaultIdols(),
        resetState = resetState ?? ResetState(),
        lastSaveTime = lastSaveTime ?? DateTime.now();

  /// Calcula el DPS total de los sous-chefs activos
  double getTotalSousChefDps() {
    double totalDps = 0;
    
    for (var chef in sousChefs.where((c) => c.isActive)) {
      // Buscar si tiene reliquia equipada
      double relicBonus = 0;
      if (chef.relicId != null) {
        var relic = relics.firstWhere(
          (r) => r.id == chef.relicId,
          orElse: () => relics.first,
        );
        relicBonus = relic.damageBonus;
      }
      
      totalDps += chef.getCurrentDps(relicBonus: relicBonus);
    }
    
    return totalDps;
  }

  /// Aplica las bonificaciones de técnicas a las estadísticas del Chef
  void applyTechniqueBoosts() {
    for (var technique in techniques) {
      if (technique.level == 0) continue;
      
      switch (technique.type) {
        case TechniqueType.damage:
          baseDamage += technique.totalEffect;
          break;
        case TechniqueType.attackSpeed:
          attackSpeed *= (1 + technique.totalEffect);
          break;
        case TechniqueType.goldBonus:
          goldBonus += technique.totalEffect;
          break;
        case TechniqueType.critChance:
          critChance += technique.totalEffect;
          break;
        case TechniqueType.critDamage:
          critMultiplier += technique.totalEffect;
          break;
        case TechniqueType.accuracy:
          accuracy += technique.totalEffect;
          break;
      }
    }
    
    // Limitar valores
    critChance = critChance.clamp(0.0, 0.75); // Máximo 75% crítico
    accuracy = accuracy.clamp(0.0, 0.99); // Máximo 99% precisión
  }

  /// Aplica las bonificaciones del equipamiento
  void applyEquipmentBoosts() {
    // Cuchillo equipado
    var equippedKnife = knives.firstWhere(
      (k) => k.isEquipped,
      orElse: () => knives.first,
    );
    
    switch (equippedKnife.ability) {
      case KnifeAbility.damageBoost:
        baseDamage *= (1 + equippedKnife.abilityBonus);
        break;
      case KnifeAbility.critBoost:
        critChance += equippedKnife.abilityBonus;
        break;
      case KnifeAbility.goldBoost:
        goldBonus += equippedKnife.abilityBonus;
        break;
      case KnifeAbility.speedBoost:
        attackSpeed *= (1 + equippedKnife.abilityBonus);
        break;
      case KnifeAbility.accuracyBoost:
        accuracy += equippedKnife.abilityBonus;
        break;
      case KnifeAbility.multiStrike:
        // Multi-strike is handled during damage calculation
        break;
    }
    
    // Joyas equipadas
    for (var jewel in jewels.where((j) => j.isEquipped)) {
      switch (jewel.stat) {
        case JewelStat.damage:
          baseDamage *= (1 + jewel.bonus);
          break;
        case JewelStat.critChance:
          critChance += jewel.bonus;
          break;
        case JewelStat.gold:
          goldBonus += jewel.bonus;
          break;
        case JewelStat.attackSpeed:
          attackSpeed *= (1 + jewel.bonus);
          break;
      }
    }
    
    // Ídolo activo
    var activeIdol = idols.firstWhere(
      (i) => i.isActive,
      orElse: () => idols.first..isActive = false,
    );
    
    if (activeIdol.isActive) {
      // Aplicar bonus
      switch (activeIdol.bonusType) {
        case IdolBonus.damage:
          baseDamage *= (1 + activeIdol.bonusValue);
          break;
        case IdolBonus.gold:
          goldBonus += activeIdol.bonusValue;
          break;
        case IdolBonus.speed:
          attackSpeed *= (1 + activeIdol.bonusValue);
          break;
        case IdolBonus.crit:
          critChance += activeIdol.bonusValue;
          break;
      }
      // Nota: Las penalizaciones se aplican en el sistema de combate
    }
  }

  /// Aplica las bonificaciones permanentes del reinicio
  void applyResetBonuses() {
    baseDamage *= (1 + resetState.totalDamageBonus);
    goldBonus += resetState.totalGoldBonus;
    attackSpeed *= (1 + resetState.totalSpeedBonus);
  }

  /// Procesa los drops especiales al derrotar un enemigo
  /// SEGÚN DOCUMENTO:
  /// - Cofres de Reliquia: 8% por enemigo
  /// - Corazones de Culto: 3% por enemigo
  DropResult processEnemyDrops() {
    final random = Random();
    bool gotRelicChest = false;
    bool gotCultHeart = false;
    Relic? newRelic;
    Idol? newIdol;
    
    // 8% de chance de cofre de reliquia
    if (random.nextDouble() < 0.08) {
      relicChests++;
      gotRelicChest = true;
      relicChestProgress = 0.0;
    }
    
    // Si tienes 3 cofres acumulados, obtienes una reliquia automáticamente
    if (relicChests >= 3) {
      relicChests -= 3;
      newRelic = generateRandomRelic();
      relics.add(newRelic);
    }
    
    // 3% de chance de corazón de culto
    if (random.nextDouble() < 0.03) {
      cultHearts++;
      gotCultHeart = true;
      cultHeartProgress = 0.0;
    }
    
    // Si tienes 3 corazones acumulados, obtienes un ídolo automáticamente
    if (cultHearts >= 3) {
      cultHearts -= 3;
      newIdol = generateRandomIdol();
      idols.add(newIdol);
    }
    
    return DropResult(
      gotRelicChest: gotRelicChest,
      gotCultHeart: gotCultHeart,
      newRelic: newRelic,
      newIdol: newIdol,
    );
  }

  /// Genera una reliquia aleatoria según el nivel actual
  Relic generateRandomRelic() {
    final random = Random();
    
    // Tier basado en mundo actual (1-5)
    int tier = (currentWorld / 2).ceil().clamp(1, 5);
    
    // Tipo: específica o elemental (50/50)
    bool isElemental = random.nextBool();
    
    String id = 'relic_${DateTime.now().millisecondsSinceEpoch}';
    String name;
    double bonus = 0.5 + (tier * 0.3); // 50% + 30% por tier
    
    if (isElemental) {
      // Reliquia elemental
      final elements = [ElementType.fire, ElementType.water, ElementType.earth];
      ElementType element = elements[random.nextInt(elements.length)];
      name = 'Tomo de ${element.name}';
      
      return Relic(
        id: id,
        name: name,
        description: '+${(bonus * 100).toStringAsFixed(0)}% DPS a sous-chefs de ${element.name}',
        tier: tier,
        damageBonus: bonus,
        targetElement: element,
        isEquipped: false,
      );
    } else {
      // Reliquia específica (para un sous-chef aleatorio)
      final availableChefs = sousChefs.where((c) => c.level > 0).toList();
      if (availableChefs.isEmpty) {
        // Si no hay sous-chefs, crear una elemental por defecto
        return generateRandomRelic();
      }
      
      SousChef targetChef = availableChefs[random.nextInt(availableChefs.length)];
      name = 'Emblema de ${targetChef.name}';
      
      return Relic(
        id: id,
        name: name,
        description: '+${(bonus * 100).toStringAsFixed(0)}% DPS a ${targetChef.name}',
        tier: tier,
        damageBonus: bonus,
        targetSousChefId: targetChef.id,
        isEquipped: false,
      );
    }
  }

  /// Genera un ídolo aleatorio
  Idol generateRandomIdol() {
    final random = Random();
    
    // Tipos de ídolos según documento
    final idolTypes = [
      {'name': 'Cuchillo Carnicero', 'bonus': IdolBonus.damage, 'value': 1.0, 'penalty': IdolPenalty.crit, 'penaltyValue': 0.5},
      {'name': 'Cuchara de Oro', 'bonus': IdolBonus.gold, 'value': 2.0, 'penalty': IdolPenalty.damage, 'penaltyValue': 0.5},
      {'name': 'Batidor Relámpago', 'bonus': IdolBonus.speed, 'value': 1.0, 'penalty': IdolPenalty.damage, 'penaltyValue': 0.25},
    ];
    
    var selectedType = idolTypes[random.nextInt(idolTypes.length)];
    
    String id = 'idol_${DateTime.now().millisecondsSinceEpoch}';
    
    return Idol(
      id: id,
      name: selectedType['name'] as String,
      description: 'Gran poder con sacrificio',
      bonusType: selectedType['bonus'] as IdolBonus,
      bonusValue: selectedType['value'] as double,
      penaltyType: selectedType['penalty'] as IdolPenalty,
      penaltyValue: selectedType['penaltyValue'] as double,
      isActive: false,
    );
  }


  /// Convierte el estado del juego a un Map para persistencia
  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'knifeFragments': knifeFragments,
      'relicChests': relicChests,
      'relicChestProgress': relicChestProgress,
      'cultHearts': cultHearts,
      'cultHeartProgress': cultHeartProgress,
      'currentLevel': currentLevel,
      'currentWorld': currentWorld,
      'enemiesDefeated': enemiesDefeated,
      'totalClicks': totalClicks,
      'baseDamage': baseDamage,
      'attackSpeed': attackSpeed,
      'critChance': critChance,
      'critMultiplier': critMultiplier,
      'accuracy': accuracy,
      'goldBonus': goldBonus,
      'techniques': techniques.map((t) => t.toJson()).toList(),
      'sousChefs': sousChefs.map((s) => s.toJson()).toList(),
      'knives': knives.map((k) => k.toJson()).toList(),
      'jewels': jewels.map((j) => j.toJson()).toList(),
      'relics': relics.map((r) => r.toJson()).toList(),
      'idols': idols.map((i) => i.toJson()).toList(),
      'resetState': resetState.toJson(),
      'lastSaveTime': lastSaveTime.toIso8601String(),
    };
  }

  /// Crea un estado del juego desde un Map
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      gold: (json['gold'] ?? 0).toDouble(),
      knifeFragments: json['knifeFragments'] ?? 0,
      relicChests: json['relicChests'] ?? 0,
      relicChestProgress: (json['relicChestProgress'] ?? 0.0).toDouble(),
      cultHearts: json['cultHearts'] ?? 0,
      cultHeartProgress: (json['cultHeartProgress'] ?? 0.0).toDouble(),
      currentLevel: json['currentLevel'] ?? 1,
      currentWorld: json['currentWorld'] ?? 1,
      enemiesDefeated: json['enemiesDefeated'] ?? 0,
      totalClicks: json['totalClicks'] ?? 0,
      baseDamage: (json['baseDamage'] ?? 10).toDouble(),
      attackSpeed: (json['attackSpeed'] ?? 1.0).toDouble(),
      critChance: (json['critChance'] ?? 0.05).toDouble(),
      critMultiplier: (json['critMultiplier'] ?? 2.0).toDouble(),
      accuracy: (json['accuracy'] ?? 0.85).toDouble(),
      goldBonus: (json['goldBonus'] ?? 0.0).toDouble(),
      techniques: (json['techniques'] as List<dynamic>?)
          ?.map((t) => Technique.fromJson(t))
          .toList(),
      sousChefs: (json['sousChefs'] as List<dynamic>?)
          ?.map((s) => SousChef.fromJson(s))
          .toList(),
      knives: (json['knives'] as List<dynamic>?)
          ?.map((k) => Knife.fromJson(k))
          .toList(),
      jewels: (json['jewels'] as List<dynamic>?)
          ?.map((j) => Jewel.fromJson(j))
          .toList(),
      relics: (json['relics'] as List<dynamic>?)
          ?.map((r) => Relic.fromJson(r))
          .toList(),
      idols: (json['idols'] as List<dynamic>?)
          ?.map((i) => Idol.fromJson(i))
          .toList(),
      resetState: json['resetState'] != null
          ? ResetState.fromJson(json['resetState'])
          : null,
      lastSaveTime: json['lastSaveTime'] != null
          ? DateTime.parse(json['lastSaveTime'])
          : null,
    );
  }

  /// Copia el estado con nuevos valores
  GameState copyWith({
    double? gold,
    int? knifeFragments,
    int? relicChests,
    double? relicChestProgress,
    int? cultHearts,
    double? cultHeartProgress,
    int? currentLevel,
    int? currentWorld,
    int? enemiesDefeated,
    int? totalClicks,
    double? baseDamage,
    double? attackSpeed,
    double? critChance,
    double? critMultiplier,
    double? accuracy,
    double? goldBonus,
    List<Technique>? techniques,
    List<SousChef>? sousChefs,
    List<Knife>? knives,
    List<Jewel>? jewels,
    List<Relic>? relics,
    List<Idol>? idols,
    ResetState? resetState,
    DateTime? lastSaveTime,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      knifeFragments: knifeFragments ?? this.knifeFragments,
      relicChests: relicChests ?? this.relicChests,
      relicChestProgress: relicChestProgress ?? this.relicChestProgress,
      cultHearts: cultHearts ?? this.cultHearts,
      cultHeartProgress: cultHeartProgress ?? this.cultHeartProgress,
      currentLevel: currentLevel ?? this.currentLevel,
      currentWorld: currentWorld ?? this.currentWorld,
      enemiesDefeated: enemiesDefeated ?? this.enemiesDefeated,
      totalClicks: totalClicks ?? this.totalClicks,
      baseDamage: baseDamage ?? this.baseDamage,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      critChance: critChance ?? this.critChance,
      critMultiplier: critMultiplier ?? this.critMultiplier,
      accuracy: accuracy ?? this.accuracy,
      goldBonus: goldBonus ?? this.goldBonus,
      techniques: techniques ?? this.techniques,
      sousChefs: sousChefs ?? this.sousChefs,
      knives: knives ?? this.knives,
      jewels: jewels ?? this.jewels,
      relics: relics ?? this.relics,
      idols: idols ?? this.idols,
      resetState: resetState ?? this.resetState,
      lastSaveTime: lastSaveTime ?? this.lastSaveTime,
    );
  }
}

/// Resultado del procesamiento de drops al derrotar un enemigo
class DropResult {
  final bool gotRelicChest;
  final bool gotCultHeart;
  final Relic? newRelic;
  final Idol? newIdol;

  DropResult({
    this.gotRelicChest = false,
    this.gotCultHeart = false,
    this.newRelic,
    this.newIdol,
  });
}
