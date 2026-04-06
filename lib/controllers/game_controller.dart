import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/technique.dart';
import '../models/sous_chef.dart';
import '../services/storage_service.dart';

/// Controlador principal del juego que maneja toda la logica de progresion
/// Utiliza ChangeNotifier para notificar cambios a la UI
class GameController extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  GameState _gameState = GameState();
  Timer? _saveTimer;

  bool _isInitialized = false;

  // Getters para acceder al estado del juego
  double get gold => _gameState.gold;
  int get knifeFragments => _gameState.knifeFragments;
  int get currentLevel => _gameState.currentLevel;
  int get relicChests => _gameState.relicChests;
  int get cultHearts => _gameState.cultHearts;

  // Stats del Chef
  double get baseDamage => _gameState.baseDamage;
  double get attackSpeed => _gameState.attackSpeed;
  double get critChance => _gameState.critChance;
  double get critMultiplier => _gameState.critMultiplier;
  double get accuracy => _gameState.accuracy;
  double get goldBonus => _gameState.goldBonus;

  // Колecciones
  List<Technique> get techniques => _gameState.techniques;
  List<SousChef> get sousChefs => _gameState.sousChefs;

  bool get isInitialized => _isInitialized;
  GameState get gameState => _gameState;

  /// Inicializa el juego, cargando datos guardados o creando un nuevo juego
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Intentar cargar el estado guardado
    final savedState = await _storageService.loadGameState();

    if (savedState != null) {
      _gameState = savedState;
      // TODO: Calcular recompensas offline (oro de sous-chefs mientras la app estaba cerrada)
      _calculateOfflineRewards();
    } else {
      // Crear un nuevo juego con tecnicas base
      _gameState = _createInitialGameState();
    }

    // Iniciar temporizador de guardado automatico
    _startAutoSaveTimer();

    _isInitialized = true;
    notifyListeners();
  }

  /// Crea el estado inicial del juego con las tecnicas predefinidas
  GameState _createInitialGameState() {
    return GameState(
      // Stats iniciales del Chef
      baseDamage: 10.0,
      attackSpeed: 1.0,
      critChance: 0.05,
      critMultiplier: 2.0,
      accuracy: 0.90,
      goldBonus: 0.0,

      // Recursos iniciales
      gold: 0,
      knifeFragments: 0,
      currentLevel: 1,

      // Tecnicas base (ver technique.dart para la lista completa)
      techniques: Technique.getDefaultTechniques(),

      // Sous-chefs (se desbloquean al avanzar)
      sousChefs: [],

      // Cuchillos, joyas, reliquias e idolos (se desbloquean durante el juego)
      knives: [],
      jewels: [],
      relics: [],
      idols: [],
    );
  }

  /// Calcula las recompensas offline (oro generado por sous-chefs)
  void _calculateOfflineRewards() {
    final now = DateTime.now();
    final lastSave = _gameState.lastSaveTime;
    final secondsOffline = now.difference(lastSave).inSeconds;

    if (secondsOffline > 0) {
      final dps = _gameState.getTotalSousChefDps();
      if (dps > 0) {
        // Limitar a maximo 4 horas de recompensas offline
        final cappedSeconds = secondsOffline > 14400 ? 14400 : secondsOffline;
        final offlineGold = dps * cappedSeconds;

        _gameState.gold += offlineGold;

        debugPrint(
          'Recompensas offline: ${offlineGold.toStringAsFixed(0)} oro (${cappedSeconds}s)',
        );
      }
    }

    _gameState.lastSaveTime = now;
  }

  /// Anade oro al jugador (llamado cuando derrota enemigos)
  void addGold(double amount) {
    final bonusMultiplier = 1.0 + _gameState.goldBonus;
    final finalAmount = amount * bonusMultiplier;

    _gameState.gold += finalAmount;
    notifyListeners();
  }

  /// Anade fragmentos de cuchillo (llamado cuando derrota jefes)
  void addKnifeFragments(int amount) {
    _gameState.knifeFragments += amount;
    notifyListeners();
  }

  /// Actualiza el nivel actual del jugador y calcula el mundo actual
  void setCurrentLevel(int level) {
    if (_gameState.currentLevel != level) {
      _gameState.currentLevel = level;

      // Actualizar el mundo actual (cada 20 niveles)
      _gameState.currentWorld = ((level - 1) ~/ 20) + 1;

      // Actualizar el nivel mas alto alcanzado
      if (level > _gameState.resetState.highestLevelReached) {
        _gameState.resetState.highestLevelReached = level;
      }

      notifyListeners();
    }
  }

  /// Procesa los drops de un enemigo derrotado
  /// SEGUN DOCUMENTO: 8% cofre de reliquia, 3% corazon de culto
  void processEnemyDefeat(int enemyLevel) {
    final dropResult = _gameState.processEnemyDrops();

    if (dropResult.gotRelicChest) {
      debugPrint('!Cofre de reliquia obtenido!');
    }

    if (dropResult.gotCultHeart) {
      debugPrint('!Corazon de culto obtenido!');
    }

    notifyListeners();
  }

  /// Abre un cofre de reliquia
  /// Genera una reliquia aleatoria segun el mundo actual
  bool tryOpenRelicChest() {
    if (_gameState.relicChests <= 0) {
      return false;
    }

    _gameState.relicChests--;

    // Generar reliquia (el metodo ya esta en game_state.dart)
    final relic = _gameState.generateRandomRelic();
    _gameState.relics.add(relic);

    debugPrint('Reliquia obtenida: ${relic.name} (Tier ${relic.tier})');

    notifyListeners();
    return true;
  }

  /// Usa un corazon de culto para obtener un idolo
  bool tryUseCultHeart() {
    if (_gameState.cultHearts <= 0) {
      return false;
    }

    _gameState.cultHearts--;

    // Generar idolo aleatorio (el metodo ya esta en game_state.dart)
    final idol = _gameState.generateRandomIdol();
    _gameState.idols.add(idol);

    debugPrint('Idolo obtenido: ${idol.name}');

    notifyListeners();
    return true;
  }

  /// Sube el nivel de un cuchillo usando fragmentos
  /// SEGUN DOCUMENTO: Requiere fragmentos segun la rareza
  bool tryUpgradeKnife(int knifeIndex) {
    if (knifeIndex < 0 || knifeIndex >= _gameState.knives.length) {
      return false;
    }

    final knife = _gameState.knives[knifeIndex];
    final requiredFragments = knife.rarity.fragmentsForUpgrade;

    if (knife.fragments < requiredFragments) {
      return false;
    }

    // Consumir fragmentos y subir nivel
    knife.fragments -= requiredFragments;
    knife.levelUp();

    // Recalcular stats si esta equipado
    if (knife.isEquipped) {
      _gameState.applyEquipmentBoosts();
    }

    debugPrint('${knife.name} subio a nivel ${knife.abilityLevel}');

    notifyListeners();
    return true;
  }

  /// Anade fragmentos a un cuchillo especifico
  void addKnifeFragmentsToKnife(int knifeIndex, int amount) {
    if (knifeIndex >= 0 && knifeIndex < _gameState.knives.length) {
      _gameState.knives[knifeIndex].fragments += amount;
      notifyListeners();
    }
  }

  /// Intenta comprar un nivel de una tecnica
  bool tryBuyTechnique(Technique technique) {
    final cost = technique.currentCost;

    // Verificar si el jugador tiene suficiente oro
    if (_gameState.gold < cost) {
      return false;
    }

    // Restar el costo
    _gameState.gold -= cost;

    // Subir nivel de la tecnica
    technique.levelUp();

    // Aplicar los efectos al GameState
    _gameState.applyTechniqueBoosts();

    notifyListeners();

    return true;
  }

  /// Intenta contratar o mejorar un Sous-chef
  bool tryHireSousChef(SousChef chef) {
    final cost = chef.currentCost;

    if (_gameState.gold < cost) {
      return false;
    }

    _gameState.gold -= cost;

    // Si el chef no esta en la lista, agregarlo
    if (!_gameState.sousChefs.contains(chef)) {
      _gameState.sousChefs.add(chef);
    }

    // Aumentar el nivel del chef
    chef.level++;

    notifyListeners();

    return true;
  }

  /// Desbloquea un Sous-chef cuando el jugador alcanza un mundo especifico
  /// Desbloquea un Sous-chef cuando el jugador alcanza un mundo especifico
  void unlockSousChef(SousChef chef) {
    if (!_gameState.sousChefs.contains(chef)) {
      _gameState.sousChefs.add(chef);
      notifyListeners();
    }
  }

  /// Equipa un cuchillo
  void equipKnife(int knifeIndex) {
    if (knifeIndex >= 0 && knifeIndex < _gameState.knives.length) {
      // Desequipar todos
      for (var knife in _gameState.knives) {
        knife.isEquipped = false;
      }

      // Equipar el seleccionado
      _gameState.knives[knifeIndex].isEquipped = true;

      // Recalcular stats con el nuevo equipo
      _gameState.applyEquipmentBoosts();

      notifyListeners();
    }
  }

  /// Equipa una joya (collar o anillo)
  void equipJewel(int jewelIndex) {
    if (jewelIndex >= 0 && jewelIndex < _gameState.jewels.length) {
      final jewel = _gameState.jewels[jewelIndex];

      // Desequipar otras joyas del mismo tipo
      for (var j in _gameState.jewels) {
        if (j.type == jewel.type) {
          j.isEquipped = false;
        }
      }

      // Equipar la seleccionada
      jewel.isEquipped = true;

      // Recalcular stats
      _gameState.applyEquipmentBoosts();

      notifyListeners();
    }
  }

  /// Realiza un reinicio (prestige) si el jugador esta en nivel 150+
  /// SEGUN DOCUMENTO: Nivel minimo 150, tokens = floor(level/150)
  bool tryPerformReset() {
    if (!_gameState.resetState.canReset(_gameState.currentLevel)) {
      return false;
    }

    // Realizar el reinicio (calcula y asigna tokens automaticamente)
    final tokensEarned = _gameState.resetState.performReset(
      _gameState.currentLevel,
    );

    // Reiniciar progreso
    _gameState.currentLevel = 1;
    _gameState.gold = 0;
    _gameState.relicChests = 0;
    _gameState.relicChestProgress = 0;
    _gameState.cultHearts = 0;
    _gameState.cultHeartProgress = 0;
    _gameState.currentWorld = 1;

    // Mantener equipamiento y tecnicas pero resetear progreso de niveles de sous-chefs
    for (var chef in _gameState.sousChefs) {
      chef.level = 0;
    }

    // Aplicar bonos de reinicio
    _gameState.applyResetBonuses();

    notifyListeners();

    debugPrint('Reinicio completado! Tokens ganados: $tokensEarned');

    return true;
  }

  /// Inicia el temporizador de guardado automatico
  void _startAutoSaveTimer() {
    _saveTimer?.cancel();

    _saveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      saveGame();
    });
  }

  /// Guarda el juego manualmente
  Future<void> saveGame() async {
    _gameState.lastSaveTime = DateTime.now();
    await _storageService.saveGameState(_gameState);
    debugPrint('Juego guardado');
  }

  /// Reinicia el juego (borra todo el progreso)
  Future<void> resetGame() async {
    await _storageService.clearGameState();
    _gameState = _createInitialGameState();
    notifyListeners();
    debugPrint('Juego reiniciado');
  }

  /// Limpia los recursos cuando el controlador se destruye
  @override
  void dispose() {
    _saveTimer?.cancel();
    saveGame(); // Guardar antes de cerrar
    super.dispose();
  }
}
