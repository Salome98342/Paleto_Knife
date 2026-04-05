import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class EconomyController extends ChangeNotifier {
  int _coins = 0;
  int _playerLevel = 1;
  int _currentWave = 1;
  int _damageStat = 1;
  int _fireRateStat = 1;

  // Variables de Vida de la sesiÃ³n actual
  int _maxHp = 3;
  int _playerHp = 3;

  EconomyController() {
    _loadData();
  }

  // Carga de datos guardados localmente
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    _damageStat = prefs.getInt('damageStat') ?? 1;
    _fireRateStat = prefs.getInt('fireRateStat') ?? 1;
    // Iniciamos la wave en 1 cada vez que se abre la app (MecÃ¡nica Roguelite/Idle)
    _currentWave = 1;
    _playerHp = _maxHp; // Reiniciar vida
    notifyListeners();
  }

  // Guardado de datos
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('damageStat', _damageStat);
    await prefs.setInt('fireRateStat', _fireRateStat);
    // No guardamos la currentWave para que el jugador vuelva a farmear desde el inicio
  }

  int get coins => _coins;
  int get playerLevel => _playerLevel;
  int get currentWave => _currentWave;
  int get damageStat => _damageStat;
  int get fireRateStat => _fireRateStat;
  int get playerHp => _playerHp;
  int get maxHp => _maxHp;

  // Crecimiento exponencial
  int get upgradeCost => (50 * math.pow(1.25, _damageStat - 1)).toInt();
  int get fireRateUpgradeCost => (75 * math.pow(1.3, _fireRateStat - 1)).toInt();
  
  // Crecimiento polin�mico del da�o
  double get currentDamage => 10.0 + (_damageStat * 1.5);

  // Cadencia (Shoot interval) arranca en 0.3s y baja hasta min 0.05s
  double get currentFireRate => math.max(0.05, 0.3 - ((_fireRateStat - 1) * 0.02));

  void takeDamage(int amount) {
    _playerHp = math.max(0, _playerHp - amount);
    notifyListeners();
  }

  void resetRun() {
    _playerHp = _maxHp;
    _currentWave = 1;
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveData();
    notifyListeners();
  }

  void addCoinsFromEnemy(int wave) {
    // Sincronizar la wave actual con la UI
    if (_currentWave != wave) {
      _currentWave = wave;
      _saveData();
    }
    
    // Drop base + escalado por la ola (wave) 
    final drop = 5 * (1 + wave * 0.2);
    _coins += drop.toInt();
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
