import '../models/chef.dart';
import '../models/gacha_result.dart';
import 'economy_system.dart';

class ProgressionSystem {
  final Map<String, Chef> _ownedChefs = {};
  final EconomySystem economySystem;

  ProgressionSystem(this.economySystem);

  List<Chef> get ownedChefs => _ownedChefs.values.toList();

  void forceUnlock(Chef chef) {
    _ownedChefs[chef.id] = chef;
  }

  GachaResult processPulledChef(Chef chefBase) {
    if (_ownedChefs.containsKey(chefBase.id)) {
      // Duplicate logic
      int tokensToGive = 0;
      int goldToGive = 0;

      if (chefBase.rarity == ChefRarity.R) {
        goldToGive = 100; // Example gold amount for R dupes
        economySystem.addGold(goldToGive);
      } else {
        // SR, SSR, UR give tokens to the specific chef
        tokensToGive = _getTokensForDuplicate(chefBase.rarity);
        _ownedChefs[chefBase.id]!.tokens += tokensToGive;
      }

      return GachaResult(
        chef: _ownedChefs[chefBase.id]!,
        isDuplicate: true,
        tokensGranted: tokensToGive,
        goldGranted: goldToGive,
      );
    } else {
      // New chef
      Chef newChef = chefBase.copyWith();
      _ownedChefs[chefBase.id] = newChef;

      return GachaResult(
        chef: newChef,
        isDuplicate: false,
      );
    }
  }

  int _getTokensForDuplicate(ChefRarity rarity) {
    switch (rarity) {
      case ChefRarity.SR: return 10;
      case ChefRarity.SSR: return 20;
      case ChefRarity.UR: return 50;
      default: return 0;
    }
  }

  bool canUpgrade(String chefId) {
    final chef = _ownedChefs[chefId];
    if (chef == null) return false;
    return chef.canUpgrade;
  }

  bool upgradeChef(String chefId) {
    final chef = _ownedChefs[chefId];
    if (chef == null) return false;

    if (chef.canUpgrade) {
      chef.tokens -= chef.upgradeCost;
      chef.level++;
      return true;
    }
    return false;
  }

  Chef? getChef(String id) {
    return _ownedChefs[id];
  }
}
