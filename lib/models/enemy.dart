import 'dart:math';
import 'package:flutter/material.dart';
import 'element_type.dart';

/// Tier del enemigo segun el documento
enum EnemyTier {
  normal, // 80% - Amalgamas comunes
  elite, // 15% - Amalgamas mejoradas (x5 HP, x3 oro)
  miniBoss, // 4% - Chef Menor (x15 HP, x7 oro)
  boss, // 1% - Chef de Temporada (x50 HP, x20 oro)
}

/// Modificadores especiales del enemigo
enum EnemyModifier {
  gigante, // +30% HP, +20% oro, +50% tamano visual
  crujiente, // +20% HP, reduccion de dano (armadura)
  desbordado, // +50% HP, +30% oro, multiples partes visuales
}

/// Modelo del enemigo (Amalgama Culinaria Mutante)
class Enemy {
  String id;
  String name;
  String description;
  AmalgamaType type;
  ElementType element;
  EnemyTier tier; // Tier del enemigo
  List<EnemyModifier> modifiers; // Modificadores activos
  Offset position; // Posicion en pantalla
  double health; // Vida actual
  double maxHealth; // Vida maxima
  double attackSpeed; // Velocidad de ataque (disparos por segundo)
  double baseDamage; // Dano base de los proyectiles
  bool isAlive; // Si el enemigo esta vivo
  int level; // Nivel del enemigo (1-500+)

  Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.element,
    required this.tier,
    required this.position,
    required this.health,
    required this.maxHealth,
    this.modifiers = const [],
    this.attackSpeed = 0.5,
    this.baseDamage = 5,
    this.isAlive = true,
    this.level = 1,
  });

  /// Recibe dano (considerando ventaja elemental)
  void takeDamage(double damage) {
    // Aplicar reduccion por modificador "crujiente" (armadura)
    if (modifiers.contains(EnemyModifier.crujiente)) {
      damage *= 0.85; // -15% dano recibido
    }

    health -= damage;
    if (health <= 0) {
      health = 0;
      isAlive = false;
    }
  }

  /// Obtiene el rectangulo de colision del enemigo
  Rect getHitbox() {
    double baseSize = _getBaseSize();
    return Rect.fromCenter(center: position, width: baseSize, height: baseSize);
  }

  /// Tamano base segun tier y modificadores
  double _getBaseSize() {
    double size = 80.0; // Tamano base

    // Ajuste por tier
    switch (tier) {
      case EnemyTier.normal:
        size *= 1.0;
        break;
      case EnemyTier.elite:
        size *= 1.2;
        break;
      case EnemyTier.miniBoss:
        size *= 1.5;
        break;
      case EnemyTier.boss:
        size *= 2.0;
        break;
    }

    // Modificador gigante
    if (modifiers.contains(EnemyModifier.gigante)) {
      size *= 1.5;
    }

    return size;
  }

  /// Obtiene la velocidad de ataque escalada por nivel
  double getScaledAttackSpeed() {
    return attackSpeed * (1 + (level - 1) * 0.02); // +2% por nivel
  }

  /// Obtiene el dano escalado por nivel
  double getScaledDamage() {
    return baseDamage * (1 + (level - 1) * 0.05); // +5% por nivel
  }

  /// Obtiene el oro que dropea al ser derrotado
  /// FORMULA SEGUN DOCUMENTO: goldBase * tierMultiplier * modifierMultipliers
  double getGoldReward() {
    // Oro base escalado por nivel (75% del HP base en oro)
    double gold = 20.0 * pow(1.23, level) * 0.75;

    // Multiplicadores por tier
    switch (tier) {
      case EnemyTier.normal:
        gold *= 1.0;
        break;
      case EnemyTier.elite:
        gold *= 3.0;
        break;
      case EnemyTier.miniBoss:
        gold *= 7.0;
        break;
      case EnemyTier.boss:
        gold *= 20.0;
        break;
    }

    // Multiplicadores por modificadores
    if (modifiers.contains(EnemyModifier.gigante)) {
      gold *= 1.2; // +20% oro
    }
    if (modifiers.contains(EnemyModifier.desbordado)) {
      gold *= 1.3; // +30% oro
    }

    return gold;
  }

  /// Reinicia el enemigo con estadisticas del nivel actual
  /// FORMULA DE HP SEGUN DOCUMENTO: 20 * (1.23 ^ nivel) * tierMultiplier * modifierMultipliers
  void reset(
    int newLevel, {
    EnemyTier? newTier,
    List<EnemyModifier>? newModifiers,
  }) {
    level = newLevel;
    tier = newTier ?? tier;
    modifiers = newModifiers ?? modifiers;

    // FORMULA BASE ACTUALIZADA: healthBase plana mas escalado suave
    double baseHealth = 10.0 + (level * 2);

    // Multiplicadores por tier
    switch (tier) {
      case EnemyTier.normal:
        baseHealth *= 1.0;
        break;
      case EnemyTier.elite:
        baseHealth *= 2.0;
        break;
      case EnemyTier.miniBoss:
        baseHealth *= 3.0;
        break;
      case EnemyTier.boss:
        baseHealth *= 5.0;
        break;
    }

    // Modificadores
    if (modifiers.contains(EnemyModifier.gigante)) {
      baseHealth *= 1.3; // +30% HP
    }
    if (modifiers.contains(EnemyModifier.crujiente)) {
      baseHealth *= 1.2; // +20% HP
    }
    if (modifiers.contains(EnemyModifier.desbordado)) {
      baseHealth *= 1.5; // +50% HP
    }

    maxHealth = baseHealth;
    health = maxHealth;
    isAlive = true;
  }

  /// Porcentaje de vida restante
  double get healthPercentage {
    if (maxHealth <= 0) return 0;
    return (health / maxHealth).clamp(0.0, 1.0);
  }

  /// Verifica si este enemigo es un boss
  bool get isBoss {
    return tier == EnemyTier.boss;
  }

  /// Crea una Amalgama aleatoria segun el nivel y elemento del mundo
  /// SISTEMA DE APARICION SEGUN DOCUMENTO:
  /// - Normal: 80%
  /// - Elite: 15%
  /// - Chef Menor (mini-boss): 4% (cada ~25 enemigos)
  /// - Chef de Temporada (boss): 1% (cada ~100 enemigos, garantizado cada nivel que termina en 0)
  static Enemy createForLevel(
    int level,
    ElementType worldElement, {
    Offset? position,
  }) {
    position ??= const Offset(200, 200);
    final random = Random();

    // Determinar tier segun reglas del documento
    EnemyTier tier;

    if (level % 10 == 0) {
      // Cada 10 niveles: Chef de Temporada (100% garantizado)
      tier = EnemyTier.boss;
    } else if (level % 5 == 0) {
      // Cada 5 niveles: 80% Chef Menor
      tier = random.nextDouble() < 0.8 ? EnemyTier.miniBoss : EnemyTier.elite;
    } else {
      // Probabilidades normales: 80% normal, 15% elite, 4% mini-boss, 1% boss
      double roll = random.nextDouble() * 100;
      if (roll < 1) {
        // 1% Boss
        tier = EnemyTier.boss;
      } else if (roll < 5) {
        // 4% Mini-Boss
        tier = EnemyTier.miniBoss;
      } else if (roll < 20) {
        // 15% Elite
        tier = EnemyTier.elite;
      } else {
        // 80% Normal
        tier = EnemyTier.normal;
      }
    }

    // Determinar modificadores
    List<EnemyModifier> modifiers = [];

    if (level >= 50) {
      // Nivel 50+: Enemigos pueden tener modificadores
      if (tier == EnemyTier.normal && random.nextDouble() < 0.1) {
        // 10% chance para normales
        modifiers.add(_getRandomModifier(random));
      } else if (tier == EnemyTier.elite) {
        // Elite: siempre 1 modificador
        modifiers.add(_getRandomModifier(random));
        if (random.nextDouble() < 0.3) {
          // 30% chance de segundo
          modifiers.add(_getRandomModifier(random));
        }
      } else if (tier == EnemyTier.miniBoss) {
        // Mini-boss: 1-2 modificadores
        modifiers.add(_getRandomModifier(random));
        if (random.nextDouble() < 0.5) {
          modifiers.add(_getRandomModifier(random));
        }
      } else if (tier == EnemyTier.boss) {
        // Boss: 2-3 modificadores
        modifiers.add(_getRandomModifier(random));
        modifiers.add(_getRandomModifier(random));
        if (random.nextDouble() < 0.5) {
          modifiers.add(_getRandomModifier(random));
        }
      }
    }

    // Eliminar duplicados
    modifiers = modifiers.toSet().toList();

    // Seleccionar tipo de Amalgama segun el elemento y tier
    AmalgamaType type;
    String name;
    String desc;

    if (tier == EnemyTier.boss) {
      name = 'Chef de Temporada';
      desc = 'El jefe supremo de esta temporada culinaria';
      type = AmalgamaType.seasonChef;
    } else if (tier == EnemyTier.miniBoss) {
      name = 'Chef Menor';
      desc = 'Un chef experimentado corrompido';
      type = AmalgamaType.minorChef;
    } else if (tier == EnemyTier.elite) {
      name = 'Amalgama Elite';
      desc = 'Una version mas poderosa de las amalgamas comunes';
      type = AmalgamaType.elite;
    } else {
      // Seleccionar segun el elemento del mundo
      switch (worldElement) {
        case ElementType.fire:
          type = AmalgamaType.lavaPizza;
          name = 'Pizza de Lava';
          desc = 'Pizza con tentaculos igneos';
          break;
        case ElementType.water:
          type = AmalgamaType.livingSushi;
          name = 'Sushi Viviente';
          desc = 'Rolls que se arrastran y atacan';
          break;
        case ElementType.earth:
          type = AmalgamaType.breadGolem;
          name = 'Golem de Pan';
          desc = 'Enorme criatura de masa horneada';
          break;
        case ElementType.master:
          type = AmalgamaType.volcanicCake;
          name = 'Pastel Volcanico';
          desc = 'Postre explosivo que lanza llamas';
          break;
        default:
          type = AmalgamaType.carnivorousSalad;
          name = 'Ensalada Carnivora';
          desc = 'Vegetales venenosos con dientes';
      }
    }

    // Anadir nombres de modificadores al nombre
    if (modifiers.contains(EnemyModifier.gigante)) {
      name = 'Gigante $name';
    }
    if (modifiers.contains(EnemyModifier.crujiente)) {
      name = 'Crujiente $name';
    }
    if (modifiers.contains(EnemyModifier.desbordado)) {
      name = 'Desbordado $name';
    }

    Enemy enemy = Enemy(
      id: 'enemy_$level',
      name: name,
      description: desc,
      type: type,
      element: worldElement,
      tier: tier,
      modifiers: modifiers,
      position: position,
      health: 100,
      maxHealth: 100,
      level: level,
    );

    enemy.reset(level);
    return enemy;
  }

  /// Selecciona un modificador aleatorio
  static EnemyModifier _getRandomModifier(Random random) {
    const modifiers = EnemyModifier.values;
    return modifiers[random.nextInt(modifiers.length)];
  }

  /// Copia del enemigo con nuevos valores
  Enemy copyWith({
    String? id,
    String? name,
    String? description,
    AmalgamaType? type,
    ElementType? element,
    EnemyTier? tier,
    List<EnemyModifier>? modifiers,
    Offset? position,
    double? health,
    double? maxHealth,
    double? attackSpeed,
    double? baseDamage,
    bool? isAlive,
    int? level,
  }) {
    return Enemy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      element: element ?? this.element,
      tier: tier ?? this.tier,
      modifiers: modifiers ?? this.modifiers,
      position: position ?? this.position,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      baseDamage: baseDamage ?? this.baseDamage,
      isAlive: isAlive ?? this.isAlive,
      level: level ?? this.level,
    );
  }
}

/// Tipos de Amalgamas Culinarias Mutantes
enum AmalgamaType {
  // Amalgamas comunes
  lavaPizza('Pizza de Lava', ''),
  livingSushi('Sushi Viviente', ''),
  carnivorousSalad('Ensalada Carnivora', ''),
  breadGolem('Golem de Pan', ''),
  volcanicCake('Pastel Volcanico', ''),

  // Jefes
  elite('Amalgama Elite', ''),
  minorChef('Chef Menor', ''),
  seasonChef('Chef de Temporada', '');

  final String displayName;
  final String emoji;
  const AmalgamaType(this.displayName, this.emoji);

  /// Obtiene el color principal del tipo de Amalgama
  Color getColor() {
    switch (this) {
      case AmalgamaType.lavaPizza:
        return Colors.red.shade700;
      case AmalgamaType.livingSushi:
        return Colors.blue.shade400;
      case AmalgamaType.carnivorousSalad:
        return Colors.green.shade600;
      case AmalgamaType.breadGolem:
        return Colors.brown.shade500;
      case AmalgamaType.volcanicCake:
        return Colors.orange.shade700;
      case AmalgamaType.elite:
        return Colors.purple.shade600;
      case AmalgamaType.minorChef:
        return Colors.indigo.shade700;
      case AmalgamaType.seasonChef:
        return Colors.amber.shade600;
    }
  }
}
