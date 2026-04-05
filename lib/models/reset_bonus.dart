/// Modelo de bonificación de reinicio
/// Almacena los bonos permanentes obtenidos al reiniciar
class ResetBonus {
  final String id;
  final String name;
  final String description;
  final ResetBonusType type;
  int level; // Cantidad de veces que se ha obtenido este bono

  ResetBonus({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.level = 0,
  });

  /// Obtiene el valor del bono actual
  double get currentBonus {
    switch (type) {
      case ResetBonusType.damage:
        return 0.05 * level; // +5% por nivel
      case ResetBonusType.gold:
        return 0.03 * level; // +3% por nivel
      case ResetBonusType.speed:
        return 0.02 * level; // +2% por nivel
    }
  }

  /// Aumenta el nivel del bono
  void addLevel() {
    level++;
  }

  /// Bonos predefinidos
  static List<ResetBonus> getDefaultBonuses() {
    return [
      ResetBonus(
        id: 'damage_bonus',
        name: 'Bonus de Daño',
        description: '+5% de daño permanente por reinicio',
        type: ResetBonusType.damage,
      ),
      ResetBonus(
        id: 'gold_bonus',
        name: 'Bonus de Oro',
        description: '+3% de oro permanente por reinicio',
        type: ResetBonusType.gold,
      ),
      ResetBonus(
        id: 'speed_bonus',
        name: 'Bonus de Velocidad',
        description: '+2% de velocidad permanente por reinicio',
        type: ResetBonusType.speed,
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
      'level': level,
    };
  }

  /// Creación desde JSON
  factory ResetBonus.fromJson(Map<String, dynamic> json) {
    return ResetBonus(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ResetBonusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResetBonusType.damage,
      ),
      level: json['level'] ?? 0,
    );
  }

  /// Copia con nuevos valores
  ResetBonus copyWith({
    String? id,
    String? name,
    String? description,
    ResetBonusType? type,
    int? level,
  }) {
    return ResetBonus(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      level: level ?? this.level,
    );
  }
}

/// Tipos de bonos de reinicio
enum ResetBonusType {
  damage,
  gold,
  speed,
}

/// Modelo de estado de reinicio y tokens
/// SEGÚN DOCUMENTO:
/// - Disponible desde nivel 150+
/// - Tokens = floor(nivel / 150)
/// - Bonificaciones automáticas por cada reinicio:
///   +5% daño, +3% oro, +2% velocidad
class ResetState {
  int totalResets; // Cantidad total de reinicios realizados
  int resetTokens; // Tokens de reinicio disponibles
  int highestLevelReached; // Nivel más alto alcanzado (registro histórico)

  ResetState({
    this.totalResets = 0,
    this.resetTokens = 0,
    this.highestLevelReached = 1,
  });

  /// Calcula los tokens que se obtendrían al reiniciar ahora
  /// FÓRMULA DOCUMENTO: floor(nivel / 150)
  int calculateTokensForReset(int currentLevel) {
    if (currentLevel < 150) return 0;
    return currentLevel ~/ 150; // División entera (floor)
  }

  /// Verifica si se puede reiniciar
  bool canReset(int currentLevel) {
    return currentLevel >= 150;
  }

  /// Realiza un reinicio
  /// Retorna los tokens obtenidos
  int performReset(int currentLevel) {
    if (!canReset(currentLevel)) return 0;
    
    // Calcular y agregar tokens
    int tokensEarned = calculateTokensForReset(currentLevel);
    resetTokens += tokensEarned;
    
    // Actualizar estadísticas
    totalResets++;
    if (currentLevel > highestLevelReached) {
      highestLevelReached = currentLevel;
    }
    
    return tokensEarned;
  }

  /// Bonificaciones totales actuales
  /// SEGÚN DOCUMENTO: +5% daño, +3% oro, +2% velocidad por reinicio
  double get totalDamageBonus => 0.05 * totalResets;
  double get totalGoldBonus => 0.03 * totalResets;
  double get totalSpeedBonus => 0.02 * totalResets;

  /// Conversión a JSON
  Map<String, dynamic> toJson() {
    return {
      'totalResets': totalResets,
      'resetTokens': resetTokens,
      'highestLevelReached': highestLevelReached,
    };
  }

  /// Creación desde JSON
  factory ResetState.fromJson(Map<String, dynamic> json) {
    return ResetState(
      totalResets: json['totalResets'] ?? 0,
      resetTokens: json['resetTokens'] ?? 0,
      highestLevelReached: json['highestLevelReached'] ?? 1,
    );
  }

  /// Copia con nuevos valores
  ResetState copyWith({
    int? totalResets,
    int? resetTokens,
    int? highestLevelReached,
  }) {
    return ResetState(
      totalResets: totalResets ?? this.totalResets,
      resetTokens: resetTokens ?? this.resetTokens,
      highestLevelReached: highestLevelReached ?? this.highestLevelReached,
    );
  }
}
