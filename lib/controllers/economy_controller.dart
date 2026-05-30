import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../services/firebase_auth_service.dart';

class EconomyController extends ChangeNotifier {
  int _coins = 0;
  int _gems = 0; // Anadido
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
    // Escuchar cambios de autenticación para sincronizar con la nube
    FirebaseAuthService.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    // Si hay usuario autenticado, intentar cargar sus datos desde la nube
    final user = FirebaseAuthService.instance.firebaseUser;
    if (user != null) {
      _loadCloudData();
    }
  }

  Future<void> _loadCloudData() async {
    try {
      final cloud = await FirebaseAuthService.instance.loadGameData();
      if (cloud == null) return;

      // Merge simple numeric fields if existen en la nube
      _coins = (cloud['coins'] is int) ? cloud['coins'] as int : _coins;
      _gems = (cloud['gems'] is int) ? cloud['gems'] as int : _gems;
      _damageStat = (cloud['damageStat'] is int) ? cloud['damageStat'] as int : _damageStat;
      _fireRateStat = (cloud['fireRateStat'] is int) ? cloud['fireRateStat'] as int : _fireRateStat;

      _monstersKilled = (cloud['monstersKilled'] is int) ? cloud['monstersKilled'] as int : _monstersKilled;
      _chefsLeveledUp = (cloud['chefsLeveledUp'] is int) ? cloud['chefsLeveledUp'] as int : _chefsLeveledUp;
      _gamesPlayed = (cloud['gamesPlayed'] is int) ? cloud['gamesPlayed'] as int : _gamesPlayed;
      _coinsSpent = (cloud['coinsSpent'] is int) ? cloud['coinsSpent'] as int : _coinsSpent;

      // Guardar localmente la copia sincronizada
      await _saveData();
      notifyListeners();
    } catch (e) {
      debugPrint('[EconomyController] Error loading cloud data: $e');
    }
  }

  String get _scopeKey {
    final userId = FirebaseAuthService.instance.firebaseUser?.uid;
    return userId == null || userId.isEmpty ? 'guest' : userId;
  }

  String _key(String suffix) => 'eco_${_scopeKey}_$suffix';

  // Carga de datos guardados localmente
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_key('coins')) ?? 0;
    _gems = prefs.getInt(_key('gems')) ?? 0;
    _damageStat = prefs.getInt(_key('damageStat')) ?? 1;
    _fireRateStat = prefs.getInt(_key('fireRateStat')) ?? 1;

    // Quest stats
    _monstersKilled = prefs.getInt(_key('monstersKilled')) ?? 0;
    _chefsLeveledUp = prefs.getInt(_key('chefsLeveledUp')) ?? 0;
    _gamesPlayed = prefs.getInt(_key('gamesPlayed')) ?? 0;
    _coinsSpent = prefs.getInt(_key('coinsSpent')) ?? 0;

    // Iniciamos la wave en 1 cada vez que se abre la app (Mecanica Roguelite/Idle)
    _currentWave = 1;
    _playerHp = _maxHp; // Reiniciar vida
    notifyListeners();
  }

  // Guardado de datos
  Future<void> saveProgress() => _saveData();

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key('coins'), _coins);
    await prefs.setInt(_key('gems'), _gems); // Anadido
    await prefs.setInt(_key('damageStat'), _damageStat);
    await prefs.setInt(_key('fireRateStat'), _fireRateStat);

    // Quest stats
    await prefs.setInt(_key('monstersKilled'), _monstersKilled);
    await prefs.setInt(_key('chefsLeveledUp'), _chefsLeveledUp);
    await prefs.setInt(_key('gamesPlayed'), _gamesPlayed);
    await prefs.setInt(_key('coinsSpent'), _coinsSpent);
    // No guardamos la currentWave para que el jugador vuelva a farmear desde el inicio

    // Intentar sincronizar con la nube si hay usuario autenticado
    try {
      final user = FirebaseAuthService.instance.firebaseUser;
      if (user != null) {
        final gameData = {
          'coins': _coins,
          'gems': _gems,
          'damageStat': _damageStat,
          'fireRateStat': _fireRateStat,
          'monstersKilled': _monstersKilled,
          'chefsLeveledUp': _chefsLeveledUp,
          'gamesPlayed': _gamesPlayed,
          'coinsSpent': _coinsSpent,
        };
        await FirebaseAuthService.instance.saveGameData(gameData);
      }
    } catch (e) {
      debugPrint('[EconomyController] Error saving to cloud: $e');
    }
  }

  Future<void> reloadForCurrentUser() async {
    await _loadData();
    notifyListeners();
  }

  int get coins => _coins;
  int get gems => _gems; // Anadido
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
  int get fireRateUpgradeCost =>
      (75 * math.pow(1.3, _fireRateStat - 1)).toInt();

  // Crecimiento polinomico del dano
  double get currentDamage => 10.0 + (_damageStat * 1.5);

  // Cadencia (Shoot interval) arranca en 0.3s y baja hasta min 0.05s
  double get currentFireRate =>
      math.max(0.05, 0.3 - ((_fireRateStat - 1) * 0.02));

  void setMaxHp(double hp) {
    _maxHp = hp;
    _playerHp = hp;
    notifyListeners();
  }

  void restoreFullHp() {
    _playerHp = _maxHp;
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

  @override
  void dispose() {
    try {
      FirebaseAuthService.instance.removeListener(_onAuthChanged);
    } catch (_) {}
    super.dispose();
  }
}
