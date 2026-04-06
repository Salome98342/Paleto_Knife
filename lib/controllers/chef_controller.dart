import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../game_logic/chef_database.dart';
import '../models/chef.dart';
import '../models/gacha_result.dart';
import '../game_logic/gacha_system.dart';
import '../game_logic/progression_system.dart';
import '../game_logic/economy_system.dart';

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
    if (isChef) {
      switch (rarity) {
        case GachaRarity.Common: return 1; // R
        case GachaRarity.Rare: return 20;  // SR
        case GachaRarity.Epic: return 30;  // SSR
        case GachaRarity.Legendary: return 40; // UR
      }
    } else {
      switch (rarity) {
        case GachaRarity.Common: return 1;
        case GachaRarity.Rare: return 5;
        case GachaRarity.Epic: return 8;
        case GachaRarity.Legendary: return 10;
      }
    }
  }

  int get tokensNeededToUpgrade {
    if (level >= maxLevel) return -1;
    if (isChef) {
      switch (rarity) {
        case GachaRarity.Common: return 0; // R doesnt
        case GachaRarity.Rare: return level * 5; // SR
        case GachaRarity.Epic: return level * 8; // SSR
        case GachaRarity.Legendary: return level * 12; // UR
      }
    } else {
      int multiplier = rarity == GachaRarity.Legendary ? 10 : rarity == GachaRarity.Epic ? 4 : rarity == GachaRarity.Rare ? 2 : 1;
      return level * 5 * multiplier;
    }
  }

  int get coinsNeededToUpgrade {
    if (level >= maxLevel) return -1;
    if (isChef) {
      // Ajuste de economia de monedas para chefs 
      int multiplier = rarity == GachaRarity.Legendary ? 500 : rarity == GachaRarity.Epic ? 250 : rarity == GachaRarity.Rare ? 100 : 0;
      return level * multiplier;
    }
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
  
  // New systems
  late ProgressionSystem _progressionSystem;
  late GachaSystem _gachaSystem;
  late EconomySystem _economySystem;

  int _activeChefIndex = 0;
  int _activeKnifeIndex = -1; // -1 means no specific knife equiped, but let's default to first knife

  ChefController() {
    _economySystem = EconomySystem();
    _progressionSystem = ProgressionSystem(_economySystem);
    _gachaSystem = GachaSystem(_progressionSystem);
    _initializeData();
    _loadData();
  }

  GachaEntity get activeChef => allEntities[_activeChefIndex];
  GachaEntity get activeKnife => allEntities[_activeKnifeIndex == -1 ? allEntities.indexWhere((e) => !e.isChef) : _activeKnifeIndex];

  List<GachaEntity> get chefs => allEntities.where((e) => e.isChef).toList();
  List<GachaEntity> get knives => allEntities.where((e) => !e.isChef).toList();

  void _initializeData() {
    allEntities = [
      // KNIVES
      GachaEntity(id: 'k1', name: 'Cuchillo de Mesa', rarity: GachaRarity.Common, icon: Icons.kitchen, isChef: false, lore: 'Sin filo.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 5.0, baseFireRate: 0.0, isUnlocked: true), // unlocked default
      GachaEntity(id: 'k2', name: 'Cuchillo de Pan', rarity: GachaRarity.Common, icon: Icons.kitchen, isChef: false, lore: 'Con serrucho.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 8.0, baseFireRate: 0.0),
      GachaEntity(id: 'k3', name: 'Cuchilla de Carnicero', rarity: GachaRarity.Rare, icon: Icons.kitchen, isChef: false, lore: 'Pesada.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 15.0, baseFireRate: 0.0),
      GachaEntity(id: 'k4', name: 'Daga Curva', rarity: GachaRarity.Rare, icon: Icons.kitchen, isChef: false, lore: 'Cortes rapidos.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 12.0, baseFireRate: 0.0),
      GachaEntity(id: 'k5', name: 'Espada del Chef', rarity: GachaRarity.Epic, icon: Icons.whatshot, isChef: false, lore: 'Hoja perfecta.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 25.0, baseFireRate: 0.0),
      GachaEntity(id: 'k6', name: 'Excalibur de Acero', rarity: GachaRarity.Legendary, icon: Icons.whatshot, isChef: false, lore: 'Corta incluso el tejido del espacio-tiempo.', favoredLocation: '', strongAgainst: '', weakAgainst: '', baseDamage: 50.0, baseFireRate: 0.0),
    ];

    // Load new chefs from ChefDatabase
    for (var c in ChefDatabase.allChefs) {
      GachaRarity mappedRarity;
      switch (c.rarity) {
        case ChefRarity.R: mappedRarity = GachaRarity.Common; break;
        case ChefRarity.SR: mappedRarity = GachaRarity.Rare; break;
        case ChefRarity.SSR: mappedRarity = GachaRarity.Epic; break;
        case ChefRarity.UR: mappedRarity = GachaRarity.Legendary; break;
      }
      
      allEntities.add(GachaEntity(
        id: c.id,
        name: c.name,
        rarity: mappedRarity,
        icon: Icons.person, // Keep standard icon for now to not break UI
        isChef: true,
        lore: '\${c.ability} | \${c.passive}',
        favoredLocation: c.element.name, // Use element as location for UI synergy
        strongAgainst: 'Enemigos vulnerables a \${c.element.name}',
        weakAgainst: 'Resistencias',
        baseDamage: c.baseAttack,
        baseFireRate: 0.4 - (c.speed * 0.1), // Base translation
        baseHp: c.baseAttack * 3, // Base translation
        isUnlocked: c.rarity == ChefRarity.R && c.id == 'r_fire_1', // Unlocked default
      ));
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < allEntities.length; i++) {
      final e = allEntities[i];
      e.level = prefs.getInt('entity_level_${e.id}') ?? 1;
      e.tokens = prefs.getInt('entity_tokens_\${e.id}') ?? 0;
      if (e.id != 'k1' && e.id != 'r_fire_1') {
        e.isUnlocked = prefs.getBool('entity_unlocked_\${e.id}') ?? false;
      }      
      // Sincronizar con el backend de progresion
      if (e.isChef && e.isUnlocked) {
         try {
           final chef = ChefDatabase.allChefs.firstWhere((c) => c.id == e.id);
           _progressionSystem.forceUnlock(chef.copyWith(level: e.level, tokens: e.tokens));
         } catch (_) {}
      }    }
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
    if (e.isChef) {
         int coinCost = e.coinsNeededToUpgrade;
         if (ecoController.coins < coinCost) return false;

         if (_progressionSystem.upgradeChef(e.id)) {
            // Updated in backend, now sync it back
            final backendChef = _progressionSystem.getChef(e.id)!;
            ecoController.spendCoins(coinCost);
            e.level = backendChef.level;
            e.tokens = backendChef.tokens;
            try {
               ecoController.recordChefLevelUp();
            } catch (_) {}
            _saveData(e);
            notifyListeners();
            return true;
         }
         return false;
    } else {
        int tokenCost = e.tokensNeededToUpgrade;
        int coinCost = e.coinsNeededToUpgrade;
        if (tokenCost > 0 && e.tokens >= tokenCost && ecoController.coins >= coinCost && e.level < e.maxLevel) {
          e.tokens -= tokenCost;
          ecoController.spendCoins(coinCost);
          e.level += 1;
          _saveData(e);
          notifyListeners();
          return true;
        }
        return false;
    }
  }

  // GACHA SYSTEM LOGIC
  List<RollResult> rollGacha(bool isChefRoll, int amount, [String chestInfo = "", dynamic ecoController]) {
    final rand = math.Random();
    List<RollResult> results = [];

    // Filter relevant pool
    List<GachaEntity> pool = allEntities.where((e) => e.isChef == isChefRoll).toList();
    
    // Determine chest type
    ChestType targetChest = ChestType.common;
    if (chestInfo.toLowerCase().contains("raro")) targetChest = ChestType.rare;
    else if (chestInfo.toLowerCase().contains("legendario") || chestInfo.toLowerCase().contains("epico")) targetChest = ChestType.epic; // Mapear epico a legendario o épico basado en nombre
    if (chestInfo.toLowerCase().contains("epico")) targetChest = ChestType.epic;
    if (chestInfo.toLowerCase().contains("legendario")) targetChest = ChestType.legendary;
    
    for (int i = 0; i < amount; i++) {
      if (isChefRoll) {
        GachaResult res = _gachaSystem.pull(targetChest);
        
        GachaEntity rolled = allEntities.firstWhere((e) => e.id == res.chef.id);
        
        bool wasUnlocked = rolled.isUnlocked;
        int tokensGranted = res.tokensGranted;
        
        if (wasUnlocked) {
            rolled.tokens += tokensGranted;
            // Da oro por R duplicado
            if (res.goldGranted > 0 && ecoController != null) {
              ecoController.addCoins(res.goldGranted);
            }
        } else {
            rolled.isUnlocked = true;
        }

        _saveData(rolled);
        results.add(RollResult(entity: rolled, isNew: !wasUnlocked, tokensGranted: tokensGranted));
      } else {
        GachaEntity rolled = _performSingleRoll(pool, rand);
        
        bool wasUnlocked = rolled.isUnlocked;
        int tokensGranted = 0;

        if (wasUnlocked) {
            if (rolled.rarity == GachaRarity.Common) tokensGranted = 2;
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

  void processBossKillReward(dynamic eco, BuildContext context) {
    // 20% de probabilidad de drop especial por matar a un jefe
    final rand = math.Random();
    if (rand.nextDouble() < 0.20) {
       // Te regalamos un pull de caja Epic gratis como recompensa gorda! (o rara, ajustemos balance)
       final results = rollGacha(true, 1, "Raro", eco); // Cofre raro
       
       // Mostrar feedback al usuario del drop especial del Jefe
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           backgroundColor: Colors.purple,
           content: Text("¡El Jefe soltó un Cofre Raro! Obtenido: \${results.first.entity.name}"),
           duration: const Duration(seconds: 4),
         )
       );
    }
  }

  double getTotalDamage(String location) {
      double d = activeChef.currentDamage + activeKnife.currentDamage;
      
      String elemLocation = location.toLowerCase();
      // Mapear localizaciones de UI (Asia, America, Europa) a elementos
      if (elemLocation.contains('asia')) elemLocation = 'fire';
      else if (elemLocation.contains('america')) elemLocation = 'water';
      else if (elemLocation.contains('euro')) elemLocation = 'earth';

      if (activeChef.favoredLocation == location || activeChef.favoredLocation == elemLocation) {
          d *= 1.5;
      }
      return d;
  }
}
