import 'package:flutter/material.dart';

/// Modelo del jugador (Chef Maestro)
class Player {
  static const double spriteWidth = 50.0;
  static const double spriteHeight = 60.0;
  static const double hitboxWidth = 34.0;
  static const double hitboxHeight = 46.0;

  Offset position; // Posición en pantalla
  double health; // Vida actual
  double maxHealth; // Vida máxima
  
  // Estadísticas de combate base
  double baseDamage; // Daño base por cuchillo
  double attackSpeed; // Velocidad de ataque (ataques por segundo)
  double critChance; // Probabilidad de crítico (0.0 a 1.0)
  double critMultiplier; // Multiplicador de daño crítico (ej: 2.0 = x2)
  double accuracy; // Precisión (0.0 a 1.0, reduce misses)
  double goldBonus; // Bonus de oro ganado (0.0 = sin bonus, 0.5 = +50%)
  
  // Movimiento
  double movementSpeed; // Velocidad de movimiento horizontal
  bool isAlive; // Si el jugador está vivo
  
  // Poder especial
  bool powerActive; // Si el poder está activo
  double powerDuration; // Duración del poder en segundos
  double powerCooldown; // Tiempo de cooldown en segundos
  double powerRemainingTime; // Tiempo restante del poder activo
  double powerCooldownRemaining; // Tiempo restante de cooldown
  
  // Recursos
  double gold; // Oro actual
  int knifeFragments; // Fragmentos de cuchillo

  Player({
    required this.position,
    this.health = 100,
    this.maxHealth = 100,
    this.baseDamage = 10,
    this.attackSpeed = 1.0,
    this.critChance = 0.05, // 5% base
    this.critMultiplier = 2.0, // x2 daño crítico
    this.accuracy = 0.85, // 85% precisión base
    this.goldBonus = 0.0, // Sin bonus inicial
    this.movementSpeed = 300,
    this.isAlive = true,
    this.powerActive = false,
    this.powerDuration = 5.0,
    this.powerCooldown = 15.0,
    this.powerRemainingTime = 0,
    this.powerCooldownRemaining = 0,
    this.gold = 0,
    this.knifeFragments = 0,
  });

  /// Mueve el jugador horizontalmente
  void moveHorizontal(double dx, double screenWidth) {
    double newX = position.dx + dx;
    
    // Limitar movimiento al ancho de la pantalla (con margen)
    const playerWidth = spriteWidth;
    newX = newX.clamp(playerWidth / 2, screenWidth - playerWidth / 2);
    
    position = Offset(newX, position.dy);
  }

  /// Mueve al jugador a una posición objetivo dentro de límites
  void moveTo(
    Offset target,
    Size screenSize, {
    double minY = 0,
    double maxYPadding = 70,
  }) {
    final clampedX = target.dx.clamp(spriteWidth / 2, screenSize.width - spriteWidth / 2);
    final clampedY = target.dy.clamp(minY, screenSize.height - maxYPadding);
    position = Offset(clampedX, clampedY);
  }

  /// Recibe daño
  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      health = 0;
      isAlive = false;
    }
  }

  /// Cura al jugador
  void heal(double amount) {
    health += amount;
    if (health > maxHealth) {
      health = maxHealth;
    }
  }

  /// Verifica si el ataque es un crítico
  bool rollCritical() {
    return (DateTime.now().millisecond % 100) / 100.0 < critChance;
  }

  /// Verifica si el ataque acierta (precisión)
  bool rollAccuracy() {
    return (DateTime.now().microsecond % 100) / 100.0 < accuracy;
  }

  /// Calcula el daño de un ataque considerando críticos
  double calculateDamage({bool forceCrit = false}) {
    double damage = baseDamage;
    
    // Aplicar multiplicador de poder si está activo
    if (powerActive) {
      damage *= 2.0;
    }
    
    // Aplicar crítico
    if (forceCrit || rollCritical()) {
      damage *= critMultiplier;
    }
    
    return damage;
  }

  /// Agrega oro con bonus aplicado
  void addGold(double baseGold) {
    gold += baseGold * (1 + goldBonus);
  }

  /// Gasta oro si es posible
  bool spendGold(double amount) {
    if (gold >= amount) {
      gold -= amount;
      return true;
    }
    return false;
  }

  /// Agrega fragmentos de cuchillo
  void addKnifeFragments(int amount) {
    knifeFragments += amount;
  }

  /// Gasta fragmentos si es posible
  bool spendFragments(int amount) {
    if (knifeFragments >= amount) {
      knifeFragments -= amount;
      return true;
    }
    return false;
  }

  /// Activa el poder especial
  bool activatePower() {
    if (powerCooldownRemaining <= 0 && !powerActive) {
      powerActive = true;
      powerRemainingTime = powerDuration;
      powerCooldownRemaining = powerCooldown;
      return true;
    }
    return false;
  }

  /// Actualiza el estado del poder especial
  void updatePower(double deltaTime) {
    if (powerActive) {
      powerRemainingTime -= deltaTime;
      if (powerRemainingTime <= 0) {
        powerActive = false;
        powerRemainingTime = 0;
      }
    }
    
    if (powerCooldownRemaining > 0) {
      powerCooldownRemaining -= deltaTime;
      if (powerCooldownRemaining < 0) {
        powerCooldownRemaining = 0;
      }
    }
  }

  /// Obtiene el DPS (Daño Por Segundo) manual del Chef
  double get dps {
    return baseDamage * attackSpeed * (1 + critChance * (critMultiplier - 1));
  }

  /// Porcentaje de vida restante
  double get healthPercentage {
    if (maxHealth <= 0) return 0;
    return (health / maxHealth).clamp(0.0, 1.0);
  }

  /// Obtiene el rectángulo de colisión del jugador
  Rect getHitbox() {
    return Rect.fromCenter(
      center: position,
      width: hitboxWidth,
      height: hitboxHeight,
    );
  }

  /// Reinicia el jugador
  void reset() {
    health = maxHealth;
    isAlive = true;
    powerActive = false;
    powerRemainingTime = 0;
    powerCooldownRemaining = 0;
  }

  /// Copia con nuevos valores
  Player copyWith({
    Offset? position,
    double? health,
    double? maxHealth,
    double? baseDamage,
    double? attackSpeed,
    double? critChance,
    double? critMultiplier,
    double? accuracy,
    double? goldBonus,
    double? movementSpeed,
    bool? isAlive,
    bool? powerActive,
    double? powerDuration,
    double? powerCooldown,
    double? powerRemainingTime,
    double? powerCooldownRemaining,
    double? gold,
    int? knifeFragments,
  }) {
    return Player(
      position: position ?? this.position,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      baseDamage: baseDamage ?? this.baseDamage,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      critChance: critChance ?? this.critChance,
      critMultiplier: critMultiplier ?? this.critMultiplier,
      accuracy: accuracy ?? this.accuracy,
      goldBonus: goldBonus ?? this.goldBonus,
      movementSpeed: movementSpeed ?? this.movementSpeed,
      isAlive: isAlive ?? this.isAlive,
      powerActive: powerActive ?? this.powerActive,
      powerDuration: powerDuration ?? this.powerDuration,
      powerCooldown: powerCooldown ?? this.powerCooldown,
      powerRemainingTime: powerRemainingTime ?? this.powerRemainingTime,
      powerCooldownRemaining: powerCooldownRemaining ?? this.powerCooldownRemaining,
      gold: gold ?? this.gold,
      knifeFragments: knifeFragments ?? this.knifeFragments,
    );
  }
}
