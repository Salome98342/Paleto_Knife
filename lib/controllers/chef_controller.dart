import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

enum GachaRarity { Common, Rare, Epic, Legendary }

class GachaEntity {
  final String id;
  final String name;
  final GachaRarity rarity;
  final IconData icon;
  final String lore;
  final bool isChef;
  
  final String favoredLocation; 
  final String strongAgainst;
  final String weakAgainst;

  final double baseDamage;
  final double baseFireRate; 

  int level;
  bool isUnlocked;
  int tokens;

  GachaEntity({
    required this.id,
    required this.name,
    required this.rarity,
    required this.icon,
    required this.lore,
    required this.isChef,
    required this.favoredLocation,
    required this.strongAgainst,
    required this.weakAgainst,
    required this.baseDamage,
    required this.baseFireRate,
    this.level = 1,
    this.isUnlocked = false,
    this.tokens = 0,
  });

  int get maxLevel {
    switch (rarity) {
      case GachaRarity.Common: return 1;
      case GachaRarity.Rare: return 5;
      case GachaRarity.Epic: return 8;
      case GachaRarity.Legendary: return 10;
    }
  }

  int get tokensNeededToUpgrade {
    if (level >= maxLevel) return -1;
    int multiplier = rarity == GachaRarity.Legendary ? 3 : rarity == GachaRarity.Epic ? 2 : 1;
    return level * 10 * multiplier;
  }

  double get currentDamage => baseDamage + (level * (isChef ? 2 : 5));
  double get currentFireRate => math.max(0.05, baseFireRate * (1 - (level * 0.02))); 

  String get rarityName => rarity.toString().split('.').last;
  
  Color get rarityColor {
    switch (rarity) {
      case GachaRarity.Common: return Colors.grey;
      case GachaRarity.Rare: return Colors.blue;
      case GachaRarity.Epic: return Colors.purple;
      case GachaRarity.Legendary: return Colors.orange;
    }
  }
}

class RollResult {
  final GachaEntity entity;
  final bool isNew;
  final int tokensGranted;

  RollResult({required this.entity, required this.isNew, required this.tokensGranted});
}

class ChefController extends ChangeNotifier {
  late List<GachaEntity> allEntities;
  
  int _activeChefIndex = 0;
  int _activeKnifeIndex = -1; // -1 means no specific knife equiped, but let's default to first knife

  ChefController() {
    _initializeData();
    _loadData();
  }

  GachaEntity get activeChef => allEntities[_activeChefIndex];
  GachaEntity get activeKnife => allEntities[_activeKnifeIndex == -1 ? allEntities.indexWhere((e) => !e.isChef) : _activeKnifeIndex];

  List<GachaEntity> get chefs => allEntities.where((e) => e.isChef).toList();
  List<GachaEntity> get knives => allEntities.where((e) => !e.isChef).toList();

  void _initializeData() {
    allEntities = [
      // CHEFS
      GachaEntity(id: 'c1', name: 'Aprendiz', rarity: GachaRarity.Common, icon: Icons.person, isChef: true, lore: 'Chef básico.', favoredLocation: 'Ninguna', strongAgainst: 'Nada', weakAgainst: 'Todo', baseDamage: 10.0, baseFireRate: 0.3, isUnlocked: true),
      GachaEntity(id: 'c2', name: 'Cocinero de Comida Rápida', rarity: GachaRarity.Common, icon: Icons.fastfood, isChef: true, lore: 'Rápido pero descuidado.', favoredLocation: 'América', strongAgainst: 'Grasa', weakAgainst: 'Verduras', baseDamage: 12.0, baseFireRate: 0.35),
      GachaEntity(id: 'c3', name: 'Sushi Ninja', rarity: GachaRarity.Rare, icon: Icons.cut, isChef: true, lore: 'Cortes precisos.', favoredLocation: 'Asia', strongAgainst: 'Arroz', weakAgainst: 'Grasa', baseDamage: 15.0, baseFireRate: 0.25),
      GachaEntity(id: 'c4', name: 'Maestro Parrillero', rarity: GachaRarity.Rare, icon: Icons.outdoor_grill, isChef: true, lore: 'Fuego y carne.', favoredLocation: 'América', strongAgainst: 'Carne', weakAgainst: 'Dulces', baseDamage: 18.0, baseFireRate: 0.28),
      GachaEntity(id: 'c5', name: 'Vegan-Borg', rarity: GachaRarity.Epic, icon: Icons.smart_toy, isChef: true, lore: 'Rayos de clorofila.', favoredLocation: 'América', strongAgainst: 'Grasa', weakAgainst: 'Magia', baseDamage: 25.0, baseFireRate: 0.4),
      GachaEntity(id: 'c6', name: 'Croissant Hunter', rarity: GachaRarity.Legendary, icon: Icons.kebab_dining, isChef: true, lore: 'Leyenda de Francia.', favoredLocation: 'Europa', strongAgainst: 'Carbohidratos', weakAgainst: 'Asiático', baseDamage: 40.0, baseFireRate: 0.20),
      
      // KNIVES
      GachaEntity(id: 'k1', name: 'Cuchillo de Mesa', rarity: GachaRarity.Common, icon: Icons.kitchen, isChef: false, lore: 'Sin filo.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 5.0, baseFireRate: 0.0, isUnlocked: true), // unlocked default
      GachaEntity(id: 'k2', name: 'Cuchillo de Pan', rarity: GachaRarity.Common, icon: Icons.kitchen, isChef: false, lore: 'Con serrucho.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 8.0, baseFireRate: 0.0),
      GachaEntity(id: 'k3', name: 'Cuchilla de Carnicero', rarity: GachaRarity.Rare, icon: Icons.kitchen, isChef: false, lore: 'Pesada.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 15.0, baseFireRate: 0.0),
      GachaEntity(id: 'k4', name: 'Daga Curva', rarity: GachaRarity.Rare, icon: Icons.kitchen, isChef: false, lore: 'Cortes rápidos.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 12.0, baseFireRate: 0.0),
      GachaEntity(id: 'k5', name: 'Espada del Chef', rarity: GachaRarity.Epic, icon: Icons.whatshot, isChef: false, lore: 'Hoja perfecta.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 25.0, baseFireRate: 0.0),
      GachaEntity(id: 'k6', name: 'Excalibur de Acero', rarity: GachaRarity.Legendary, icon: Icons.whatshot, isChef: false, lore: 'Corta incluso el tejido del espacio-tiempo.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 50.0, baseFireRate: 0.0),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < allEntities.length; i++) {
      final e = allEntities[i];
      e.level = prefs.getInt('entity_level_${e.id}') ?? 1;
      e.tokens = prefs.getInt('entity_tokens_${e.id}') ?? 0;
      if (e.id != 'c1' && e.id != 'k1') {
        e.isUnlocked = prefs.getBool('entity_unlocked_${e.id}') ?? false;
      }
    }
    _activeChefIndex = prefs.getInt('active_chef_index') ?? 0;
    _activeKnifeIndex = prefs.getInt('active_knife_index') ?? allEntities.indexWhere((e) => !e.isChef);
    notifyListeners();
  }

  Future<void> _saveData(GachaEntity e) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('entity_level_${e.id}', e.level);
    await prefs.setInt('entity_tokens_${e.id}', e.tokens);
    await prefs.setBool('entity_unlocked_${e.id}', e.isUnlocked);
  }

  Future<void> _saveActiveIndices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_chef_index', _activeChefIndex);
    await prefs.setInt('active_knife_index', _activeKnifeIndex);
  }

  void setActive(GachaEntity entity) {
    if (!entity.isUnlocked) return;
    int idx = allEntities.indexWhere((e) => e.id == entity.id);
    if (entity.isChef) {
      _activeChefIndex = idx;
    } else {
      _activeKnifeIndex = idx;
    }
    _saveActiveIndices();
    notifyListeners();
  }

  bool tryUpgrade(GachaEntity e) {
    int cost = e.tokensNeededToUpgrade;
    if (cost > 0 && e.tokens >= cost && e.level < e.maxLevel) {
      e.tokens -= cost;
      e.level += 1;
      _saveData(e);
      notifyListeners();
      return true;
    }
    return false;
  }

  // GACHA SYSTEM LOGIC
  List<RollResult> rollGacha(bool isChefRoll, int amount) {
    final rand = math.Random();
    List<RollResult> results = [];

    // Filter relevant pool
    List<GachaEntity> pool = allEntities.where((e) => e.isChef == isChefRoll).toList();
    
    for (int i = 0; i < amount; i++) {
        GachaEntity rolled = _performSingleRoll(pool, rand);
        
        bool wasUnlocked = rolled.isUnlocked;
        int tokensGranted = 0;

        if (!wasUnlocked) {
            rolled.isUnlocked = true;
        } else {
            // Is Duplicate
            if (rolled.rarity == GachaRarity.Rare) tokensGranted = 5;
            else if (rolled.rarity == GachaRarity.Epic) tokensGranted = 15;
            else if (rolled.rarity == GachaRarity.Legendary) tokensGranted = 50;
            
            rolled.tokens += tokensGranted;
        }

        _saveData(rolled);
        results.add(RollResult(entity: rolled, isNew: !wasUnlocked, tokensGranted: tokensGranted));
    }
    
    notifyListeners();
    return results;
  }

  GachaEntity _performSingleRoll(List<GachaEntity> pool, math.Random rand) {
      // Common → 65%, Rare → 24%, Epic → 9%, Legendary → 2%
      while(true) {
        double roll = rand.nextDouble() * 100;
        GachaRarity targetRarity;
        
        if (roll < 65) targetRarity = GachaRarity.Common;
        else if (roll < 89) targetRarity = GachaRarity.Rare;
        else if (roll < 98) targetRarity = GachaRarity.Epic;
        else targetRarity = GachaRarity.Legendary;

        var matchingPool = pool.where((e) => e.rarity == targetRarity).toList();
        if (matchingPool.isEmpty) continue; // Si no hay en este pool (ej extremo), reintenta.
        
        // Regla: No hay duplicados en Comunes
        if (targetRarity == GachaRarity.Common) {
            var lockedCommons = matchingPool.where((e) => !e.isUnlocked).toList();
            if (lockedCommons.isEmpty) {
                // Si ya tiene todos los comunes, le mejoramos forzadamente a Raro o superior mediante otro reroll sin comunes
                continue; 
            } else {
                return lockedCommons[rand.nextInt(lockedCommons.length)];
            }
        } else {
            return matchingPool[rand.nextInt(matchingPool.length)];
        }
      }
  }

  double getTotalDamage() {
      return activeChef.currentDamage + activeKnife.currentDamage;
  }
}
