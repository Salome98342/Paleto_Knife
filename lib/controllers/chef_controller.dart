import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChefData {
  final String id;
  final String name;
  final String rarity; // Common, Rare, Epic, Legendary
  final IconData icon;
  final String lore;
  
  // Element/Location Data
  final String favoredLocation; 
  final String strongAgainst;
  final String weakAgainst;

  // Base Stats
  final double baseDamage;
  final double baseFireRate; // Lower is faster

  // dynamic stats
  int level;
  bool isUnlocked;

  ChefData({
    required this.id,
    required this.name,
    required this.rarity,
    required this.icon,
    required this.lore,
    required this.favoredLocation,
    required this.strongAgainst,
    required this.weakAgainst,
    required this.baseDamage,
    required this.baseFireRate,
    this.level = 1,
    this.isUnlocked = false,
  });

  double get currentDamage => baseDamage + (level * 2);
  double get currentFireRate => baseFireRate * (1 - (level * 0.02)); // gets slightly faster
  
  int get upgradeCost {
    int multiplier = rarity == 'Legendary' ? 4 : rarity == 'Epic' ? 3 : rarity == 'Rare' ? 2 : 1;
    return level * 150 * multiplier;
  }
}

class ChefController extends ChangeNotifier {
  late List<ChefData> chefs;
  
  // Guardamos el índice del chef que actualmente está usando el jugador (para sacar stats)
  int _activeChefIndex = 0;

  ChefController() {
    _initializeChefs();
    _loadData();
  }

  ChefData get activeChef => chefs[_activeChefIndex];

  void _initializeChefs() {
    chefs = [
      ChefData(
        id: 'c1',
        name: 'Chef Maestro',
        rarity: 'Common',
        icon: Icons.person,
        lore: 'Un veterano de la cocina tradicional. Fiable y equilibrado en la mayoría de batallas.',
        favoredLocation: 'Ninguna (Equilibrado)',
        strongAgainst: 'Comida Genérica',
        weakAgainst: 'Picante Extremo',
        baseDamage: 10.0,
        baseFireRate: 0.3,
        isUnlocked: true,
      ),
      ChefData(
        id: 'c2',
        name: 'Sushi Ninja',
        rarity: 'Rare',
        icon: Icons.cut,
        lore: 'Sus cuchillos cortan el aire. Especialista en evadir los letales ataques de las amalgamas de Asia.',
        favoredLocation: 'Asia',
        strongAgainst: 'Arroz Explosivo',
        weakAgainst: 'Grasa (América)',
        baseDamage: 15.0,
        baseFireRate: 0.25,
      ),
      ChefData(
        id: 'c3',
        name: 'Vegan-Borg',
        rarity: 'Epic',
        icon: Icons.smart_toy,
        lore: 'Cyber-organismo desarrollado para purgar comida chatarra con rayos de clorofila pura.',
        favoredLocation: 'América',
        strongAgainst: 'Grasa y Frituras',
        weakAgainst: 'Masas Francesas (Europa)',
        baseDamage: 25.0,
        baseFireRate: 0.4,
      ),
      ChefData(
        id: 'c4',
        name: 'Croissant Hunter',
        rarity: 'Legendary',
        icon: Icons.kebab_dining,
        lore: 'Una leyenda desterrada de Francia tras cazar a las levaduras primigenias. Sus ataques perforan al enemigo.',
        favoredLocation: 'Europa',
        strongAgainst: 'Carbohidratos duros',
        weakAgainst: 'Magia Asiática',
        baseDamage: 40.0,
        baseFireRate: 0.20,
      ),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < chefs.length; i++) {
      chefs[i].level = prefs.getInt('chef_level_${chefs[i].id}') ?? 1;
      // El primero siempre desbloqueado, el resto dependen de variables guardadas
      if (i != 0) {
        chefs[i].isUnlocked = prefs.getBool('chef_unlocked_${chefs[i].id}') ?? false;
      }
    }
    _activeChefIndex = prefs.getInt('active_chef_index') ?? 0;
    notifyListeners();
  }

  Future<void> _saveData(ChefData chef) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chef_level_${chef.id}', chef.level);
    await prefs.setBool('chef_unlocked_${chef.id}', chef.isUnlocked);
    await prefs.setInt('active_chef_index', _activeChefIndex);
  }

  void setActiveChef(int index) {
    if (chefs[index].isUnlocked) {
      _activeChefIndex = index;
      _saveData(chefs[index]);
      notifyListeners();
    }
  }
  void upgradeChef(ChefData chef) {
    chef.level += 1;
    _saveData(chef);
    notifyListeners();
  }
  
  void unlockChef(ChefData chef) {
    chef.isUnlocked = true;
    _saveData(chef);
    notifyListeners();
  }
}

