import 'enemy_spawn_config.dart';

/// Configuración de una oleada completa
class Wave {
  /// Identificador único de la oleada
  final String id;

  /// Número de la oleada para UI
  final int waveNumber;

  /// Configuraciones de spawn para esta oleada
  final List<EnemySpawnConfig> spawns;

  /// Si es una oleada de boss
  final bool isBossWave;

  /// Dificultad relativa (used for scaling HP/damage)
  final double difficultyMultiplier;

  /// Descripción de la oleada (para UI/debug)
  final String description;

  Wave({
    required this.id,
    required this.waveNumber,
    required this.spawns,
    this.isBossWave = false,
    this.difficultyMultiplier = 1.0,
    this.description = '',
  });

  /// Obtiene la cantidad total de enemigos en esta oleada
  int getTotalEnemyCount() {
    return spawns.fold<int>(0, (sum, config) => sum + config.quantity);
  }

  /// Copia profunda
  Wave copyWith({
    String? id,
    int? waveNumber,
    List<EnemySpawnConfig>? spawns,
    bool? isBossWave,
    double? difficultyMultiplier,
    String? description,
  }) {
    return Wave(
      id: id ?? this.id,
      waveNumber: waveNumber ?? this.waveNumber,
      spawns: spawns ?? this.spawns,
      isBossWave: isBossWave ?? this.isBossWave,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
      description: description ?? this.description,
    );
  }
}
