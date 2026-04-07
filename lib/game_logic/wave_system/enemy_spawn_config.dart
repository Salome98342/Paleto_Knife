/// Configuración de cómo spawnear enemigos en una oleada
class EnemySpawnConfig {
  /// Tipo de enemigo a spawnear
  final String enemyType;

  /// Cantidad de enemigos a spawnear
  final int quantity;

  /// Patrón de spawn: 'burst' (todos juntos), 'stream' (constante), 'random' (aleatorio), 'circle' (círculo)
  final String spawnPattern;

  /// Retraso entre spawns consecutivos (en segundos)
  final double delayBetweenSpawns;

  /// Variabilidad en la posición de spawn (0-1, siendo 1 aleatoriedad máxima)
  final double positionVariability;

  EnemySpawnConfig({
    required this.enemyType,
    required this.quantity,
    this.spawnPattern = 'burst',
    this.delayBetweenSpawns = 0.3,
    this.positionVariability = 0.5,
  });

  /// Copia profunda de la configuración
  EnemySpawnConfig copyWith({
    String? enemyType,
    int? quantity,
    String? spawnPattern,
    double? delayBetweenSpawns,
    double? positionVariability,
  }) {
    return EnemySpawnConfig(
      enemyType: enemyType ?? this.enemyType,
      quantity: quantity ?? this.quantity,
      spawnPattern: spawnPattern ?? this.spawnPattern,
      delayBetweenSpawns: delayBetweenSpawns ?? this.delayBetweenSpawns,
      positionVariability: positionVariability ?? this.positionVariability,
    );
  }
}
