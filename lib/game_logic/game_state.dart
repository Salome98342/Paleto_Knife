import 'package:flutter/foundation.dart';

/// Estados posibles del juego
enum GameStatus {
  playing,      // Jugando normalmente
  dead,         // El jugador murió
  reviveOffered, // Se ofrece revivir con anuncio
  revived,      // El jugador revivió
  gameOver,     // Juego terminado (sin revive disponible)
  rewardScreen, // Pantalla de recompensas final
}

/// Gestiona el estado global del juego
///
/// Responsabilidades:
/// - Trackear vida del jugador
/// - Gestionar estado (playing, dead, gameOver, etc)
/// - Controlar si el revive fue usado
/// - Acumular recompensas
class GameStateManager extends ChangeNotifier {
  // =========================
  // ESTADO DEL JUEGO
  // =========================

  GameStatus _status = GameStatus.playing;
  int _playerHealth = 100;
  int _maxHealth = 100;
  bool _hasRevived = false; // Solo 1 revive por run

  // =========================
  // RECOMPENSAS ACUMULADAS
  // =========================

  int _coinsEarned = 0;
  int _gemsEarned = 0;
  int _enemiesDefeated = 0;
  int _totalDamageDealt = 0;
  int _timePlayedSeconds = 0;

  // Multiplicador de recompensas (x2 si vio anuncio)
  int _rewardMultiplier = 1;
  bool _doubleRewardUsed = false; // Solo una vez

  // =========================
  // GETTERS
  // =========================

  GameStatus get status => _status;
  int get playerHealth => _playerHealth;
  int get maxHealth => _maxHealth;
  bool get hasRevived => _hasRevived;
  bool get canRevive => !_hasRevived && _status == GameStatus.dead;

  // Recompensas
  int get coinsEarned => _coinsEarned * _rewardMultiplier;
  int get gemsEarned => _gemsEarned * _rewardMultiplier;
  int get enemiesDefeated => _enemiesDefeated;
  int get totalDamageDealt => _totalDamageDealt;
  int get timePlayedSeconds => _timePlayedSeconds;
  int get rewardMultiplier => _rewardMultiplier;
  bool get doubleRewardUsed => _doubleRewardUsed;

  // =========================
  // SETTERS & ACTIONS
  // =========================

  /// Cambiar el estado del juego
  void setStatus(GameStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  /// Aplicar daño al jugador
  void takeDamage(int damage) {
    final newHealth = (_playerHealth - damage).clamp(0, _maxHealth);
    _playerHealth = newHealth;

    if (_playerHealth == 0 && _status == GameStatus.playing) {
      _status = GameStatus.dead;
    }

    notifyListeners();
  }

  /// Sanar al jugador
  void heal(int amount) {
    _playerHealth = (_playerHealth + amount).clamp(0, _maxHealth);
    notifyListeners();
  }

  /// El jugador debe estar muerto antes de llamar esto
  void revivePlayer({int healthAmount = 50}) {
    if (!canRevive) return;

    _hasRevived = true;
    _playerHealth = healthAmount.clamp(1, _maxHealth);
    _status = GameStatus.revived;

    notifyListeners();
  }

  /// Reanudar el juego después de revivir
  void resumeAfterRevive() {
    _status = GameStatus.playing;
    notifyListeners();
  }

  /// Terminar el juego (ir a pantalla de recompensas)
  void finishGame() {
    _status = GameStatus.gameOver;
    notifyListeners();
  }

  /// Ir a pantalla de recompensas
  void showRewardScreen() {
    _status = GameStatus.rewardScreen;
    notifyListeners();
  }

  // =========================
  // RECOMPENSAS
  // =========================

  /// Agregar monedas ganadas
  void addCoins(int amount) {
    _coinsEarned += amount;
    notifyListeners();
  }

  /// Agregar gemas ganadas
  void addGems(int amount) {
    _gemsEarned += amount;
    notifyListeners();
  }

  /// Registrar enemigo derrotado
  void addEnemyDefeated() {
    _enemiesDefeated += 1;
    notifyListeners();
  }

  /// Registrar daño total
  void addDamage(int damage) {
    _totalDamageDealt += damage;
    notifyListeners();
  }

  /// Actualizar tiempo jugado
  void updatePlayTime(int seconds) {
    _timePlayedSeconds = seconds;
    notifyListeners();
  }

  // =========================
  // MULTIPLICADOR DE RECOMPENSAS
  // =========================

  /// Duplicar recompensas (solo disponible una vez)
  void doubleRewards() {
    if (_doubleRewardUsed || _rewardMultiplier != 1) return;

    _rewardMultiplier = 2;
    _doubleRewardUsed = true;

    notifyListeners();
  }

  /// Obtener recompensas finales (para guardar en base de datos)
  Map<String, int> getFinalRewards() {
    return {
      'coins': coinsEarned,
      'gems': gemsEarned,
      'enemiesDefeated': _enemiesDefeated,
      'totalDamage': _totalDamageDealt,
      'timePlayedSeconds': _timePlayedSeconds,
    };
  }

  // =========================
  // FUNCIONES DE UTILIDAD
  // =========================

  /// Reiniciar el estado del juego para una nueva partida
  void resetGame() {
    _status = GameStatus.playing;
    _playerHealth = _maxHealth;
    _hasRevived = false;

    _coinsEarned = 0;
    _gemsEarned = 0;
    _enemiesDefeated = 0;
    _totalDamageDealt = 0;
    _timePlayedSeconds = 0;

    _rewardMultiplier = 1;
    _doubleRewardUsed = false;

    notifyListeners();
  }

  /// Debug: obtener resumen del estado
  String getDebugSummary() {
    return '''
GameState Debug:
- Status: $_status
- Health: $_playerHealth / $_maxHealth
- Can Revive: $canRevive
- Has Revived: $_hasRevived
- Coins: _coinsEarned (x$_rewardMultiplier)
- Gems: $_gemsEarned (x$_rewardMultiplier)
- Enemies: $_enemiesDefeated
- Damage: $_totalDamageDealt
- Time: $_timePlayedSeconds s
''';
  }
}
