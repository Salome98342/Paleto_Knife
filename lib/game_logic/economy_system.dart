import 'package:flutter/foundation.dart';

class EconomySystem {
  int _gold = 0;
  int _premiumCurrency = 0; // e.g. gems for gacha
  final Map<String, int> _items = {};

  EconomySystem();

  int get gold => _gold;
  int get premiumCurrency => _premiumCurrency;

  void addGold(int amount) {
    if (amount < 0) return;
    _gold += amount;
  }

  bool spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      return true;
    }
    return false;
  }

  void addPremiumCurrency(int amount) {
    if (amount < 0) return;
    _premiumCurrency += amount;
  }

  bool spendPremiumCurrency(int amount) {
    if (_premiumCurrency >= amount) {
      _premiumCurrency -= amount;
      return true;
    }
    return false;
  }

  // Obtain generic tokens (if a global token exists), or specific item tokens
  void addItem(String itemId, int quantity) {
    _items[itemId] = (_items[itemId] ?? 0) + quantity;
  }

  bool spendItem(String itemId, int quantity) {
    int current = _items[itemId] ?? 0;
    if (current >= quantity) {
      _items[itemId] = current - quantity;
      return true;
    }
    return false;
  }

  int getItemCount(String itemId) {
    return _items[itemId] ?? 0;
  }

  /// Recompensa tokens al chef específico después de derrotar un boss
  /// Los tokens se usan para mejoras específicas de chefs
  void rewardTokensFromBoss(String chefId, int amount) {
    if (amount <= 0) return;
    
    // Guardar tokens del chef específico usando formato: 'chef_tokens_<chefId>'
    final tokenKey = 'chef_tokens_$chefId';
    _items[tokenKey] = (_items[tokenKey] ?? 0) + amount;
    
    debugPrint('✨ Boss recompensa: +$amount tokens para chef $chefId');
  }
}
