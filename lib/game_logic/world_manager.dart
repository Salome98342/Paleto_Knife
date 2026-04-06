import '../models/world.dart';
import '../models/element_type.dart';

/// Gestor de mundos y progresion
class WorldManager {
  int _currentLevel = 1; // Nivel actual del jugador
  final List<World> _worlds;

  WorldManager() : _worlds = World.getDefaultWorlds();

  /// Obtiene el nivel actual del jugador
  int get currentLevel => _currentLevel;

  /// Obtiene el mundo actual basado en el nivel del jugador
  World get currentWorld {
    return _worlds.firstWhere(
      (w) => w.containsLevel(_currentLevel),
      orElse: () => _worlds.first,
    );
  }

  /// Obtiene el numero del mundo actual
  int get currentWorldNumber => currentWorld.worldNumber;

  /// Obtiene el elemento del mundo actual
  ElementType get currentElement => currentWorld.element;

  /// Obtiene todos los mundos disponibles
  List<World> get allWorlds => List.unmodifiable(_worlds);

  /// Avanza al siguiente nivel
  void advanceLevel() {
    _currentLevel++;
  }

  /// Establece un nivel especifico
  void setLevel(int level) {
    if (level >= 1) {
      _currentLevel = level;
    }
  }

  /// Verifica si el nivel actual es un jefe
  bool get isCurrentLevelBoss {
    int levelInWorld = (_currentLevel - 1) % 100 + 1;
    return levelInWorld == 25 || levelInWorld == 50 || levelInWorld == 100;
  }

  /// Obtiene el tipo de jefe del nivel actual
  BossType? get currentBossType {
    if (!isCurrentLevelBoss) return null;
    
    int levelInWorld = (_currentLevel - 1) % 100 + 1;
    if (levelInWorld == 25) return BossType.elite;
    if (levelInWorld == 50) return BossType.minorChef;
    if (levelInWorld == 100) return BossType.seasonChef;
    return null;
  }

  /// Obtiene el progreso dentro del mundo actual (0.0 a 1.0)
  double get worldProgress {
    return currentWorld.getProgressForLevel(_currentLevel);
  }

  /// Reinicia al nivel 1
  void reset() {
    _currentLevel = 1;
  }

  /// Obtiene el multiplicador de dificultad actual
  double get difficultyMultiplier => currentWorld.difficultyMultiplier;

  /// Obtiene el multiplicador de recompensas actual
  double get rewardMultiplier => currentWorld.rewardMultiplier;

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': _currentLevel,
    };
  }

  /// Carga desde JSON
  void fromJson(Map<String, dynamic> json) {
    _currentLevel = json['currentLevel'] ?? 1;
  }
}

/// Tipos de jefes especiales
enum BossType {
  elite, // Cada 25 niveles (x2 oro)
  minorChef, // Cada 50 niveles (x5 oro)
  seasonChef, // Cada 100 niveles (x10 oro + recompensas especiales)
}
