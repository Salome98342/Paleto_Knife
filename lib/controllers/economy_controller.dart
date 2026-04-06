import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class EconomyController extends ChangeNotifier {
  int _coins = 0;
  int _gems = 0; // Anadido
  int _playerLevel = 1;
  int _currentWave = 1;
  int _damageStat = 1;
  int _fireRateStat = 1;
  
  // Quest and Stats tracking
  int _monstersKilled = 0;
  int _chefsLeveledUp = 0;
  int _gamesPlayed = 0;
  int _coinsSpent = 0;

  // Variables de Vida de la sesion actual
  double _maxHp = 100.0;
  double _playerHp = 100.0;
  
  // Variables de sesion para el overlay de "Game Over"
  int _sessionCoins = 0;
  int _sessionGems = 0;

  EconomyController() {
    _loadData();
  }

  // Carga de datos guardados localmente
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    _gems = prefs.getInt('gems') ?? 0;
    _damageStat = prefs.getInt('damageStat') ?? 1;
    _fireRateStat = prefs.getInt('fireRateStat') ?? 1;
    
    // Quest stats 
    _monstersKilled = prefs.getInt('monstersKilled') ?? 0;
    _chefsLeveledUp = prefs.getInt('chefsLeveledUp') ?? 0;
    _gamesPlayed = prefs.getInt('gamesPlayed') ?? 0;
    _coinsSpent = prefs.getInt('coinsSpent') ?? 0;

    // Iniciamos la wave en 1 cada vez que se abre la app (Mecanica Roguelite/Idle)
    _currentWave = 1;
    _playerHp = _maxHp; // Reiniciar vida
    notifyListeners();
  }

  // Guardado de datos
  Future<void> saveProgress() => _saveData();
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('gems', _gems); // Anadido
    await prefs.setInt('damageStat', _damageStat);
    await prefs.setInt('fireRateStat', _fireRateStat);

    // Quest stats
    await prefs.setInt('monstersKilled', _monstersKilled);
    await prefs.setInt('chefsLeveledUp', _chefsLeveledUp);
    await prefs.setInt('gamesPlayed', _gamesPlayed);
    await prefs.setInt('coinsSpent', _coinsSpent);
    // No guardamos la currentWave para que el jugador vuelva a farmear desde el inicio
  }

  int get coins => _coins;
  int get gems => _gems; // Anadido
  int get playerLevel => _playerLevel;
  int get currentWave => _currentWave;
  int get damageStat => _damageStat;
  int get fireRateStat => _fireRateStat;
  double get playerHp => _playerHp;
  double get maxHp => _maxHp;
  int get sessionCoins => _sessionCoins;
  int get sessionGems => _sessionGems;

  int get monstersKilled => _monstersKilled;
  int get chefsLeveledUp => _chefsLeveledUp;
  int get gamesPlayed => _gamesPlayed;
  int get coinsSpent => _coinsSpent;

  // Crecimiento exponencial
  int get upgradeCost => (50 * math.pow(1.25, _damageStat - 1)).toInt();
  int get fireRateUpgradeCost => (75 * math.pow(1.3, _fireRateStat - 1)).toInt();
  
  // Crecimiento polinomico del dano
  double get currentDamage => 10.0 + (_damageStat * 1.5);

  // Cadencia (Shoot interval) arranca en 0.3s y baja hasta min 0.05s
  double get currentFireRate => math.max(0.05, 0.3 - ((_fireRateStat - 1) * 0.02));

  void setMaxHp(double hp) {
    _maxHp = hp;
    _playerHp = hp;
    notifyListeners();
  }

  void takeDamage(double amount) {
    _playerHp = math.max(0.0, _playerHp - amount);
    notifyListeners();
  }

  void resetRun() {
    _gamesPlayed++; // Se jugo otra partida
    _saveData();
    _playerHp = _maxHp;
    _currentWave = 1;
    _sessionCoins = 0;
    _sessionGems = 0;
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveData();
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      _coinsSpent += amount; // Para la quest
      _saveData();
      notifyListeners();
    }
  }

  void recordChefLevelUp() {
    _chefsLeveledUp++;
    _saveData();
    notifyListeners();
  }

  void addGems(int amount) {
    _gems += amount;
    _saveData();
    notifyListeners();
  }

  void spendGems(int amount) {
    if (_gems >= amount) {
      _gems -= amount;
      _saveData();
      notifyListeners();
    }
  }

  void addRewardsFromEnemy(int wave, {bool isBoss = false}) {
    _monstersKilled++; // Incrementamos el stat de monstruos eliminados
    if (_currentWave != wave) {
      _currentWave = wave;
      _saveData();
    }
    
    final dropCoins = (5 * (1 + wave * 0.2)).toInt() * (isBoss ? 5 : 1);
    _coins += dropCoins;
    _sessionCoins += dropCoins;

    if (isBoss) {
       final dropGems = 2 + (wave * 0.5).toInt();
       _gems += dropGems;
       _sessionGems += dropGems;
    }

    _saveData();
    notifyListeners();
  }

  bool tryUpgradeDamage() {
    final cost = upgradeCost;
    if (_coins >= cost) {
      _coins -= cost;
      _damageStat++;
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool tryUpgradeFireRate() {
    final cost = fireRateUpgradeCost;
    if (_coins >= cost) {
      _coins -= cost;
      _fireRateStat++;
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }
}
