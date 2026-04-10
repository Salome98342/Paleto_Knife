import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../game_logic/enemy_system/enemy_types.dart';
import '../models/element_type.dart';

class AmalgamData {
  final String name;
  final String description;
  final IconData icon;
  final String element;
  final String weakness;
  final bool isBoss;
  final EnemyTypeDefinition? enemyDefinition; // Referencia al enemigo completo

  AmalgamData(
    this.name,
    this.description,
    this.icon, {
    this.element = "Normal",
    this.weakness = "Ninguna",
    this.isBoss = false,
    this.enemyDefinition,
  });
}

class LocationData {
  final String name;
  final String description;
  final bool isAlert;
  final String recommendedElement;
  final Color elementColor;
  final List<AmalgamData> amalgams;
  final List<AmalgamData> neutralEnemies; // Enemigos neutrales en sección separada
  final List<AmalgamData> bosses; // Jefes en sección separada

  LocationData(
    this.name,
    this.description,
    this.isAlert,
    this.recommendedElement,
    this.elementColor,
    this.amalgams, {
    this.neutralEnemies = const [],
    this.bosses = const [],
  });
}

class WorldController extends ChangeNotifier {
  final List<LocationData> locations = [];

  late LocationData selectedLocation;

  Map<String, double> liberationProgress = {};

  WorldController() {
    _initializeLocations();
    selectedLocation = locations.isNotEmpty ? locations.first : _createEmptyLocation();
    _loadData();
  }

  void _initializeLocations() {
    // Inicializar catálogo de tipos de enemigos
    EnemyTypesCatalog.initializeDefaults();

    // Cargar enemigos por región
    final allRegions = [Region.asia, Region.caribbean, Region.europe];
    final allNeutralEnemies = <AmalgamData>[];
    final allBosses = <AmalgamData>[];
    
    for (final region in allRegions) {
      final regionName = _getRegionName(region);
      final regionEnemies = EnemyTypesCatalog.getByRegion(region);
      
      if (regionEnemies.isNotEmpty) {
        // Separar jefes de enemigos normales
        final bosses = regionEnemies.where((e) => e.role == 'boss').toList();
        final normalEnemies = regionEnemies.where((e) => e.role != 'boss').toList();
        
        // Separar enemigos neutrales de enemigos con elemento
        final nonNeutralEnemies = normalEnemies.where((e) => e.element != ElementType.neutral).toList();
        final neutralEnemies = normalEnemies.where((e) => e.element == ElementType.neutral).toList();
        
        final amalgams = nonNeutralEnemies.map((enemy) {
          return AmalgamData(
            enemy.name,
            enemy.description,
            _getIconForElement(enemy.element),
            element: enemy.element.name,
            weakness: _getWeakness(enemy.element),
            isBoss: false,
            enemyDefinition: enemy,
          );
        }).toList();

        final neutralAmalgams = neutralEnemies.map((enemy) {
          return AmalgamData(
            enemy.name,
            enemy.description,
            _getIconForElement(enemy.element),
            element: enemy.element.name,
            weakness: _getWeakness(enemy.element),
            isBoss: false,
            enemyDefinition: enemy,
          );
        }).toList();

        final bossAmalgams = bosses.map((enemy) {
          return AmalgamData(
            enemy.name,
            enemy.description,
            Icons.shield,
            element: enemy.element.name,
            weakness: _getWeakness(enemy.element),
            isBoss: true,
            enemyDefinition: enemy,
          );
        }).toList();

        // Agregar neutrales y jefes a las listas globales
        allNeutralEnemies.addAll(neutralAmalgams);
        allBosses.addAll(bossAmalgams);

        final isAlert = region == Region.asia; // Asia está en peligro
        final recommendedElement = nonNeutralEnemies.isNotEmpty 
            ? _getWeakness(nonNeutralEnemies.first.element) 
            : "Ninguno";

        locations.add(
          LocationData(
            regionName,
            "Invasión de amalgamas de $regionName",
            isAlert,
            recommendedElement,
            _getRegionColor(region),
            amalgams,
            neutralEnemies: region == Region.asia ? [] : neutralAmalgams,
            bosses: bossAmalgams,
          ),
        );
      }
    }

    // Agregar sección de enemigos neutrales de todas las regiones
    if (allNeutralEnemies.isNotEmpty || allBosses.isNotEmpty) {
      locations.add(
        LocationData(
          'Neutro',
          'Amalgamas sin afinidad de elemento + Soberanos',
          false,
          'Ninguno',
          Color(0xFF808080),
          allNeutralEnemies,
          neutralEnemies: [],
          bosses: allBosses,
        ),
      );
    }
  }

  String _getRegionName(Region region) {
    switch (region) {
      case Region.asia:
        return 'Asia';
      case Region.caribbean:
        return 'Caribe';
      case Region.europe:
        return 'Europa';
    }
  }

  IconData _getIconForElement(ElementType element) {
    switch (element) {
      case ElementType.fire:
        return Icons.local_fire_department;
      case ElementType.water:
        return Icons.water;
      case ElementType.earth:
        return Icons.landscape;
      case ElementType.wind:
        return Icons.cloud;
      case ElementType.lava:
        return Icons.volcano;
      case ElementType.plant:
        return Icons.nature;
      default:
        return Icons.help;
    }
  }

  String _getWeakness(ElementType element) {
    switch (element) {
      case ElementType.fire:
        return "Agua";
      case ElementType.water:
        return "Tierra";
      case ElementType.earth:
        return "Fuego";
      case ElementType.wind:
        return "Tierra";
      case ElementType.lava:
        return "Agua";
      case ElementType.plant:
        return "Fuego";
      default:
        return "Ninguna";
    }
  }

  Color _getRegionColor(Region region) {
    switch (region) {
      case Region.asia:
        return Colors.redAccent;
      case Region.caribbean:
        return Colors.lightBlue;
      case Region.europe:
        return Colors.green;
    }
  }

  LocationData _createEmptyLocation() {
    return LocationData(
      "Sin región",
      "No hay región seleccionada",
      false,
      "Ninguno",
      Colors.grey,
      [],
    );
  }

  void selectLocation(LocationData loc) {
    selectedLocation = loc;
    notifyListeners();
  }

  void addLiberation(String locationName, double amount) {
    liberationProgress[locationName] =
        ((liberationProgress[locationName] ?? 0.0) + amount).clamp(0.0, 100.0);
    _saveData();
    notifyListeners();
  }

  double getLiberation(String locationName) {
    return liberationProgress[locationName] ?? 0.0;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in liberationProgress.keys) {
      prefs.setDouble('liberation_$key', liberationProgress[key]!);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var loc in locations) {
      liberationProgress[loc.name] =
          prefs.getDouble('liberation_${loc.name}') ?? 0.0;
    }
    notifyListeners();
  }

  Future<void> updateRecoveryProgress(String locationName, double recoveryPercentage) async {
    if (liberationProgress.containsKey(locationName)) {
      // Tomar el máximo entre el progreso anterior y el nuevo
      liberationProgress[locationName] = 
          math.max(liberationProgress[locationName]!, recoveryPercentage);
      await _saveData();
      notifyListeners();
    }
  }
}
