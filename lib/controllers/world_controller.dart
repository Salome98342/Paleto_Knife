import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmalgamData {
  final String name;
  final String description;
  final IconData icon;

  AmalgamData(this.name, this.description, this.icon);
}

class LocationData {
  final String name;
  final String description;
  final bool isAlert;
  final List<AmalgamData> amalgams;

  LocationData(this.name, this.description, this.isAlert, this.amalgams);
}

class WorldController extends ChangeNotifier {
  final List<LocationData> locations = [
    LocationData("Asia", "Invasión de amalgamas de comida asiática picante.", true, [
      AmalgamData("Sushi-Maki Letal", "Un rollo relleno de arroz explosivo.", Icons.set_meal),
      AmalgamData("Ramen-Golem", "Lanza fideos ultra calientes. Ten cuidado.", Icons.ramen_dining),
    ]),
    LocationData("América", "Comida chatarra radiactiva suelta en las calles.", false, [
      AmalgamData("Hamburguesaurio", "Salpicará grasa por todas partes.", Icons.fastfood),
      AmalgamData("Pizza-Mutante", "Discurre sus rebanadas buscando presa.", Icons.local_pizza),
    ]),
    LocationData("Europa", "La panadería fina se ha rebelado en masa.", true, [
      AmalgamData("Baguette-Blade", "Pan añejo que golpea como roca.", Icons.bakery_dining),
      AmalgamData("Croissant-Bat", "Vuela silenciosamente en picada.", Icons.breakfast_dining),
    ]),
  ];

  late LocationData selectedLocation;
  
  Map<String, double> liberationProgress = {};

  WorldController() {
    selectedLocation = locations.first;
    _loadData();
  }

  void selectLocation(LocationData loc) {
    selectedLocation = loc;
    notifyListeners();
  }

  void addLiberation(String locationName, double amount) {
    liberationProgress[locationName] = ((liberationProgress[locationName] ?? 0.0) + amount).clamp(0.0, 100.0);
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
      liberationProgress[loc.name] = prefs.getDouble('liberation_${loc.name}') ?? 0.0;
    }
    notifyListeners();
  }
}
