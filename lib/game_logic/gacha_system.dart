import 'dart:math';
import '../models/chef.dart';
import '../models/gacha_result.dart';
import 'chef_database.dart';
import 'progression_system.dart';

enum ChestType { common, rare, epic, legendary }

class GachaSystem {
  final Random _random = Random();
  final ProgressionSystem progressionSystem;

  // Pity counters
  int totalPulls = 0;
  int pullsSinceLastSSR = 0;
  int pullsSinceLastUR = 0;

  GachaSystem(this.progressionSystem);

  GachaResult pull(ChestType chestType) {
    totalPulls++;
    pullsSinceLastSSR++;
    pullsSinceLastUR++;

    ChefRarity designatedRarity;

    // Check Pity first (Overrides chest rates)
    if (pullsSinceLastUR >= 100) {
      designatedRarity = ChefRarity.UR;
    } else if (pullsSinceLastSSR >= 50) {
      designatedRarity = ChefRarity.SSR;
    } else {
      designatedRarity = _rollRarity(chestType);
    }

    // Reset pity if we got a high rarity
    if (designatedRarity == ChefRarity.UR) {
      pullsSinceLastUR = 0;
      pullsSinceLastSSR = 0;
    } else if (designatedRarity == ChefRarity.SSR) {
      pullsSinceLastSSR = 0;
    }

    final Chef pulledChefBase = _getRandomChefByRarity(designatedRarity);

    // Process progression and duplicates
    return progressionSystem.processPulledChef(pulledChefBase);
  }

  ChefRarity _rollRarity(ChestType chestType) {
    double roll = _random.nextDouble();

    switch (chestType) {
      case ChestType.common:
        if (roll < 0.90) return ChefRarity.R;
        return ChefRarity.SR;

      case ChestType.rare:
        if (roll < 0.60) return ChefRarity.R;
        if (roll < 0.90) return ChefRarity.SR;
        return ChefRarity.SSR;

      case ChestType.epic:
        if (roll < 0.60) return ChefRarity.SR;
        if (roll < 0.90) return ChefRarity.SSR;
        return ChefRarity.UR;

      case ChestType.legendary:
        if (roll < 0.70) return ChefRarity.SSR;
        return ChefRarity.UR;
    }
  }

  Chef _getRandomChefByRarity(ChefRarity rarity) {
    final pool = ChefDatabase.getChefsByRarity(rarity);
    if (pool.isEmpty) throw Exception('No chefs found for rarity \$rarity');
    return pool[_random.nextInt(pool.length)];
  }

  void resetPity() {
    totalPulls = 0;
    pullsSinceLastSSR = 0;
    pullsSinceLastUR = 0;
  }
}
