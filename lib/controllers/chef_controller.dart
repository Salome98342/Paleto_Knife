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
  final double baseHp;

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
    this.baseHp = 100.0,
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
    // Multiplicador único por Rareza (x1, x2, x4, x10)
    int multiplier = rarity == GachaRarity.Legendary ? 10 : rarity == GachaRarity.Epic ? 4 : rarity == GachaRarity.Rare ? 2 : 1;
    // Por ejemplo: Nivel 1 Raro = 1 * 5 * 2 = 10 Tokens. Nivel 1 Legendario = 1 * 5 * 10 = 50 tokens.
    return level * 5 * multiplier;
  }

  int get coinsNeededToUpgrade {
    if (level >= maxLevel) return -1;
    // El coste de monedas será estricamente proporcional a la rareza y el nivel usando una base de oro (e.g. x100)
    int multiplier = rarity == GachaRarity.Legendary ? 10 : rarity == GachaRarity.Epic ? 4 : rarity == GachaRarity.Rare ? 2 : 1;
    return level * 250 * multiplier;
  }

  double get currentDamage => baseDamage + (level * (isChef ? 2 : 5));
  double get currentFireRate => math.max(0.05, baseFireRate * (1 - (level * 0.02)));
  double get currentHp => baseHp + (level * 15.0); 

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
      GachaEntity(id: 'c1', name: 'Aprendiz', rarity: GachaRarity.Common, icon: Icons.person, isChef: true, lore: 'Chef básico.', favoredLocation: 'Ninguna', strongAgainst: 'Nada', weakAgainst: 'Todo', baseDamage: 10.0, baseFireRate: 0.3, baseHp: 100.0, isUnlocked: true),
      GachaEntity(id: 'c2', name: 'Cocinero de Comida Rápida', rarity: GachaRarity.Common, icon: Icons.fastfood, isChef: true, lore: 'Rápido pero descuidado.', favoredLocation: 'América', strongAgainst: 'Grasa', weakAgainst: 'Verduras', baseDamage: 12.0, baseFireRate: 0.35, baseHp: 80.0),
      GachaEntity(id: 'c3', name: 'Sushi Ninja', rarity: GachaRarity.Rare, icon: Icons.cut, isChef: true, lore: 'Cortes precisos.', favoredLocation: 'Asia', strongAgainst: 'Arroz', weakAgainst: 'Grasa', baseDamage: 15.0, baseFireRate: 0.25, baseHp: 120.0),
      GachaEntity(id: 'c4', name: 'Maestro Parrillero', rarity: GachaRarity.Rare, icon: Icons.outdoor_grill, isChef: true, lore: 'Fuego y carne.', favoredLocation: 'América', strongAgainst: 'Carne', weakAgainst: 'Dulces', baseDamage: 18.0, baseFireRate: 0.28, baseHp: 150.0),
      GachaEntity(id: 'c5', name: 'Vegan-Borg', rarity: GachaRarity.Epic, icon: Icons.smart_toy, isChef: true, lore: 'Rayos de clorofila.', favoredLocation: 'América', strongAgainst: 'Grasa', weakAgainst: 'Magia', baseDamage: 25.0, baseFireRate: 0.4, baseHp: 180.0),
      GachaEntity(id: 'c6', name: 'Croissant Hunter', rarity: GachaRarity.Legendary, icon: Icons.kebab_dining, isChef: true, lore: 'Leyenda de Francia.', favoredLocation: 'Europa', strongAgainst: 'Carbohidratos', weakAgainst: 'Asiático', baseDamage: 40.0, baseFireRate: 0.20, baseHp: 250.0),
      
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

  bool tryUpgrade(GachaEntity e, {required dynamic ecoController}) {
    int tokenCost = e.tokensNeededToUpgrade;
    int coinCost = e.coinsNeededToUpgrade;
    // Check if player has enough tokens and coins
    if (tokenCost > 0 && e.tokens >= tokenCost && ecoController.coins >= coinCost && e.level < e.maxLevel) {
      e.tokens -= tokenCost;
      ecoController.spendCoins(coinCost);
      e.level += 1;
      if (e.isChef) {
        // Registrar subida de nivel de chef para misiones
        try {
          ecoController.recordChefLevelUp();
        } catch (_) {}
      }
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

        // Otorgar siempre los tokens si ya estaba desbloqueado
        if (wasUnlocked) {
            if (rolled.rarity == GachaRarity.Common) tokensGranted = 2; // Añadido que los comunes den tokens también
            else if (rolled.rarity == GachaRarity.Rare) tokensGranted = 5;
            else if (rolled.rarity == GachaRarity.Epic) tokensGranted = 15;
            else if (rolled.rarity == GachaRarity.Legendary) tokensGranted = 50;
            
            rolled.tokens += tokensGranted;
        } else {
            rolled.isUnlocked = true;
        }

        _saveData(rolled);
        results.add(RollResult(entity: rolled, isNew: !wasUnlocked, tokensGranted: tokensGranted));
    }
    
    notifyListeners();
    return results;
  }

  GachaEntity _performSingleRoll(List<GachaEntity> pool, math.Random rand) {
      // Common → 50%, Rare → 30%, Epic → 15%, Legendary → 5% (Subida la probabilidad de cosas buenas)
      while(true) {
        double roll = rand.nextDouble() * 100;
        GachaRarity targetRarity;
        
        if (roll < 50) targetRarity = GachaRarity.Common;
        else if (roll < 80) targetRarity = GachaRarity.Rare;
        else if (roll < 95) targetRarity = GachaRarity.Epic;
        else targetRarity = GachaRarity.Legendary;

        var matchingPool = pool.where((e) => e.rarity == targetRarity).toList();
        if (matchingPool.isEmpty) continue; // Si no hay en este pool (ej extremo), reintenta.
        
        // Regla cambiada: Los comunes pueden salir duplicados para dar tokens de mejora
        return matchingPool[rand.nextInt(matchingPool.length)];
      }
  }

  double getTotalDamage(String location) {
      double d = activeChef.currentDamage + activeKnife.currentDamage;
      if (activeChef.favoredLocation == location) {
          d *= 1.5;
      }
      return d;
  }
}
