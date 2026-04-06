import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmalgamData {
  final String name;
  final String description;
  final IconData icon;
  final String element;
  final String weakness;
  final bool isBoss;

  AmalgamData(
    this.name,
    this.description,
    this.icon, {
    this.element = "Normal",
    this.weakness = "Ninguna",
    this.isBoss = false,
  });
}

class LocationData {
  final String name;
  final String description;
  final bool isAlert;
  final String recommendedElement;
  final Color elementColor;
  final List<AmalgamData> amalgams;

  LocationData(
    this.name,
    this.description,
    this.isAlert,
    this.recommendedElement,
    this.elementColor,
    this.amalgams,
  );
}

class WorldController extends ChangeNotifier {
  final List<LocationData> locations = [
    LocationData(
      "Asia",
      "Invasion de amalgamas de comida asiatica picante.",
      true,
      "Fuego",
      Colors.redAccent,
      [
        AmalgamData(
          "Sushi-Maki Letal",
          "Un rollo relleno de arroz explosivo.",
          Icons.set_meal,
          element: "Fuego",
          weakness: "Agua",
        ),
        AmalgamData(
          "Ramen-Golem",
          "Lanza fideos ultra calientes. Ten cuidado.",
          Icons.ramen_dining,
          element: "Fuego",
          weakness: "Agua",
        ),
        AmalgamData(
          "Dios Dragón Sriracha",
          "Señor de la Capsaicina. Quema todo a su paso.",
          Icons.local_fire_department,
          element: "Fuego",
          weakness: "Agua",
          isBoss: true,
        ),
      ],
    ),
    LocationData(
      "America",
      "Comida chatarra radiactiva suelta en las calles.",
      false,
      "Agua",
      Colors.lightBlue,
      [
        AmalgamData(
          "Hamburguesaurio",
          "Salpicara grasa por todas partes.",
          Icons.fastfood,
          element: "Agua",
          weakness: "Tierra",
        ),
        AmalgamData(
          "Pizza-Mutante",
          "Discurre sus rebanadas buscando presa.",
          Icons.local_pizza,
          element: "Agua",
          weakness: "Tierra",
        ),
        AmalgamData(
          "Kaiser Rey Burger",
          "Emperador de la comida rápida marina y grasienta.",
          Icons.anchor,
          element: "Agua",
          weakness: "Tierra",
          isBoss: true,
        ),
      ],
    ),
    LocationData(
      "Europa",
      "La panaderia fina se ha rebelado en masa.",
      true,
      "Tierra",
      Colors.green,
      [
        AmalgamData(
          "Baguette-Blade",
          "Pan anejo que golpea como roca.",
          Icons.bakery_dining,
          element: "Tierra",
          weakness: "Fuego",
        ),
        AmalgamData(
          "Croissant-Bat",
          "Vuela silenciosamente en picada.",
          Icons.breakfast_dining,
          element: "Tierra",
          weakness: "Fuego",
        ),
        AmalgamData(
          "Señor de la Masa Madre",
          "Monstruo de harina inmenso. Controla terremotos.",
          Icons.landscape,
          element: "Tierra",
          weakness: "Fuego",
          isBoss: true,
        ),
      ],
    ),
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
}
