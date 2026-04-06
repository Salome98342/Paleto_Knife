import 'element_type.dart';

/// Modelo que representa un mundo/nivel en el juego
/// Cada mundo tiene 100 niveles y un elemento tematico
class World {
  final int worldNumber; // Numero de mundo (1, 2, 3...)
  final String name;
  final String description;
  final ElementType element;
  final String theme; // Tematica culinaria del mundo
  final double difficultyMultiplier; // Multiplicador de dificultad
  final double rewardMultiplier; // Multiplicador de recompensas
  final int startLevel; // Nivel inicial (1, 101, 201, etc.)
  final int endLevel; // Nivel final (100, 200, 300, etc.)

  World({
    required this.worldNumber,
    required this.name,
    required this.description,
    required this.element,
    required this.theme,
    required this.difficultyMultiplier,
    required this.rewardMultiplier,
  }) : startLevel = (worldNumber - 1) * 100 + 1,
       endLevel = worldNumber * 100;

  /// Verifica si un nivel pertenece a este mundo
  bool containsLevel(int level) {
    return level >= startLevel && level <= endLevel;
  }

  /// Obtiene el progreso dentro del mundo (0.0 a 1.0)
  double getProgressForLevel(int level) {
    if (!containsLevel(level)) return 0.0;
    return (level - startLevel) / 100.0;
  }

  /// Crea mundos predefinidos segun el documento
  static List<World> getDefaultWorlds() {
    return [
      // Mundo 1: Neutral - Cocina Basica
      World(
        worldNumber: 1,
        name: 'Cocina Basica',
        description: 'Fundamentos culinarios y primeros ingredientes',
        element: ElementType.neutral,
        theme: 'Temporada de Iniciacion',
        difficultyMultiplier: 1.0,
        rewardMultiplier: 1.0,
      ),

      // Mundo 2: Agua - Reino Acuatico
      World(
        worldNumber: 2,
        name: 'Reino Acuatico',
        description: 'Mariscos y sushi cobran vida en aguas profundas',
        element: ElementType.water,
        theme: 'Temporada del Mar',
        difficultyMultiplier: 1.5,
        rewardMultiplier: 1.5,
      ),

      // Mundo 3: Fuego - Volcan de Lava
      World(
        worldNumber: 3,
        name: 'Volcan de Lava',
        description: 'Pizzas igneas y parrillas ardientes',
        element: ElementType.fire,
        theme: 'Temporada del Fuego',
        difficultyMultiplier: 2.0,
        rewardMultiplier: 2.0,
      ),

      // Mundo 4: Tierra - Bosque de Pan
      World(
        worldNumber: 4,
        name: 'Bosque de Pan',
        description: 'Golems de masa y vegetales carnivoros',
        element: ElementType.earth,
        theme: 'Temporada de la Tierra',
        difficultyMultiplier: 2.5,
        rewardMultiplier: 2.5,
      ),

      // Mundo 5: Maestro - Olimpo Culinario
      World(
        worldNumber: 5,
        name: 'Olimpo Culinario',
        description: 'El reino de los Chefs Maestros',
        element: ElementType.master,
        theme: 'Temporada Suprema',
        difficultyMultiplier: 3.0,
        rewardMultiplier: 3.0,
      ),
    ];
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'worldNumber': worldNumber,
      'name': name,
      'description': description,
      'element': element.name,
      'theme': theme,
      'difficultyMultiplier': difficultyMultiplier,
      'rewardMultiplier': rewardMultiplier,
    };
  }

  /// Crea desde JSON
  factory World.fromJson(Map<String, dynamic> json) {
    return World(
      worldNumber: json['worldNumber'],
      name: json['name'],
      description: json['description'],
      element: ElementType.values.firstWhere(
        (e) => e.name == json['element'],
        orElse: () => ElementType.neutral,
      ),
      theme: json['theme'],
      difficultyMultiplier: json['difficultyMultiplier'],
      rewardMultiplier: json['rewardMultiplier'],
    );
  }
}
