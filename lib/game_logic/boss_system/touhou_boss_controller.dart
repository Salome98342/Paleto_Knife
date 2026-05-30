import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'touhou_spell_card.dart';
import 'touhou_boss_factory.dart';
import 'bullet_emitter.dart';
import 'boss_movement.dart';

/// Estados del boss tipo Touhou
enum TouhouBossState {
  /// Esperando para iniciar
  waiting,

  /// Transición de fase (invulnerable)
  phaseTransition,

  /// Ejecutando spell card
  spellCardActive,

  /// Derrotado
  defeated,
}

/// Controlador principal del boss tipo Touhou
/// Orquesta:
/// - Cambios de fase
/// - Spell Cards y Non-Spells
/// - Movimiento con waypoints
/// - Emisores de balas
/// - Estado general
class TouhouBossController extends ChangeNotifier {
  /// Definición del boss
  final TouhouBossDefinition bossDefinition;

  /// Posición actual
  Vector2 position;

  /// HP actual
  double _currentHp;

  /// Estado actual
  TouhouBossState _state = TouhouBossState.waiting;

  /// Fase actual (1, 2, 3)
  int _currentPhaseIndex = 0;

  /// Spell Card actual
  int _currentSpellCardIndex = 0;

  /// Sistemas
  late BossMovementSystem _movementSystem;
  final List<BulletData> _bulletsToSpawn = [];

  // Timers
  double _phaseTransitionTimer = 0.0;
  double _spellCardDurationTimer = 0.0;
  double _spellCardHpTimer = 0.0;

  // Random para algoritmos
  final math.Random _random = math.Random();

  // Callbacks para la UI y el juego
  void Function(int phaseNumber)? onPhaseChange;
  void Function(String cardName)? onSpellCardStart;
  void Function()? onSpellCardComplete;
  void Function()? onBossDefeated;
  void Function(List<BulletData> bullets)? onSpawnBullets;

  TouhouBossController({
    required this.bossDefinition,
    required this.position,
  }) : _currentHp = bossDefinition.baseMaxHp {
    _initializePhase();
  }

  // ========================
  // GETTERS
  // ========================

  double get currentHp => _currentHp;
  double get maxHp => bossDefinition.baseMaxHp;
  double get hpPercentage => (_currentHp / maxHp).clamp(0.0, 1.0);
  TouhouBossState get state => _state;
  int get currentPhaseNumber => _currentPhaseIndex + 1;

  TouhouBossPhase get currentPhase => bossDefinition.phases[_currentPhaseIndex];
  TouhouSpellCard get currentSpellCard =>
      currentPhase.spellCards[_currentSpellCardIndex];

  bool get isInvulnerable =>
      _state == TouhouBossState.phaseTransition ||
      currentSpellCard.isBossInvulnerable;

  Vector2 get currentPosition => position;

  // ========================
  // ACTUALIZACIÓN PRINCIPAL
  // ========================

  /// Actualizar el boss (llamar en el game loop)
  void update(double deltaTime, Vector2? playerPos) {
    if (_state == TouhouBossState.defeated) return;

    switch (_state) {
      case TouhouBossState.waiting:
        _startFirstPhase();
        break;

      case TouhouBossState.phaseTransition:
        _updatePhaseTransition(deltaTime);
        break;

      case TouhouBossState.spellCardActive:
        _updateSpellCard(deltaTime, playerPos);
        break;

      case TouhouBossState.defeated:
        break;
    }

    // Actualizar movimiento
    _movementSystem.update(deltaTime);
    position = _movementSystem.position;

    notifyListeners();
  }

  void _updatePhaseTransition(double deltaTime) {
    _phaseTransitionTimer += deltaTime;

    if (_phaseTransitionTimer >= currentPhase.transitionDuration) {
      _phaseTransitionTimer = 0.0;

      // Iniciar primera spell card de esta fase
      _currentSpellCardIndex = 0;
      _startSpellCard();
      _state = TouhouBossState.spellCardActive;
    }
  }

  void _updateSpellCard(double deltaTime, Vector2? playerPos) {
    final spellCard = currentSpellCard;

    // Actualizar timers
    _spellCardDurationTimer += deltaTime;
    _spellCardHpTimer += deltaTime;

    // Generar balas
    if (spellCard.bulletEmitterClusters.isNotEmpty) {
      for (final cluster in spellCard.bulletEmitterClusters) {
        cluster.update(deltaTime);
        final bullets = cluster.getBullets(
          bossPos: position,
          playerPos: playerPos,
          random: _random,
        );
        _bulletsToSpawn.addAll(bullets);
      }
    }

    // Enviar balas al juego
    if (_bulletsToSpawn.isNotEmpty) {
      onSpawnBullets?.call(_bulletsToSpawn);
      _bulletsToSpawn.clear();
    }

    // ¿Se agotó el tiempo de la spell card?
    if (spellCard.maxDuration > 0 &&
        _spellCardDurationTimer >= spellCard.maxDuration) {
      _moveToNextSpellCard();
      return;
    }

    // ¿Cambiar de fase?
    if (hpPercentage <= currentPhase.hpThreshold) {
      _moveToNextPhase();
    }
  }

  // ========================
  // DAÑO Y SALUD
  // ========================

  /// Aplicar daño al boss
  /// Ten en cuenta los efectos de player (focus mode, bombs, etc)
  void takeDamage(double damage, {double damageMultiplier = 1.0}) {
    if (isInvulnerable) {
      // Boss es invulnerable durante transición
      return;
    }

    // Aplicar multiplicadores
    double finalDamage = damage * damageMultiplier;

    // Multiplicador de fase
    finalDamage *= currentPhase.damageMultiplier;

    _currentHp -= finalDamage;

    // Checkear si está derrotado
    if (_currentHp <= 0) {
      _currentHp = 0;
      _state = TouhouBossState.defeated;
      onBossDefeated?.call();
    }

    // Checkear cambio de fase
    if (hpPercentage <= currentPhase.hpThreshold) {
      _moveToNextPhase();
    }

    notifyListeners();
  }

  // ========================
  // CAMBIOS DE FASE Y SPELL CARDS
  // ========================

  void _initializePhase() {
    if (_currentPhaseIndex >= bossDefinition.phases.length) {
      _state = TouhouBossState.defeated;
      return;
    }

    // Configurar waypoints iniciales
    _setupMovementWaypoints();
    _state = TouhouBossState.phaseTransition;
  }

  void _moveToNextPhase() {
    _currentPhaseIndex++;

    if (_currentPhaseIndex >= bossDefinition.phases.length) {
      _state = TouhouBossState.defeated;
      onBossDefeated?.call();
      return;
    }

    _currentSpellCardIndex = 0;
    _phaseTransitionTimer = 0.0;
    _state = TouhouBossState.phaseTransition;

    // Limpiar balas
    if (currentPhase.clearBulletsOnTransition) {
      // Llamar al juego para limpiar
    }

    onPhaseChange?.call(currentPhaseNumber);
    notifyListeners();
  }

  void _startFirstPhase() {
    if (_currentPhaseIndex == 0) {
      _state = TouhouBossState.phaseTransition;
      onPhaseChange?.call(1);
    }
  }

  void _startSpellCard() {
    _spellCardDurationTimer = 0.0;
    _spellCardHpTimer = 0.0;

    final spellCard = currentSpellCard;
    onSpellCardStart?.call(spellCard.name);

    // Configurar movimiento para esta spell card
    _setupMovementForSpellCard(spellCard);
  }

  void _moveToNextSpellCard() {
    _currentSpellCardIndex++;

    if (_currentSpellCardIndex >= currentPhase.spellCards.length) {
      // Completar la fase, ir a siguiente
      _moveToNextPhase();
      return;
    }

    _startSpellCard();
    onSpellCardComplete?.call();
  }

  // ========================
  // MOVIMIENTO
  // ========================

  void _setupMovementWaypoints() {
    final movement = BossMovementSystem(
      position: position,
      waypoints: [position], // Start
      speed: 100.0,
    );
    _movementSystem = movement;
  }

  void _setupMovementForSpellCard(TouhouSpellCard spellCard) {
    if (spellCard.waypointsPattern != null &&
        spellCard.waypointsPattern!.isNotEmpty) {
      // Usar waypoints predefinidos
      final waypoints = spellCard.waypointsPattern!
          .map((p) => Vector2(p.$1, p.$2))
          .toList();

      _movementSystem.setWaypoints(waypoints);
      _movementSystem.speed =
          100.0 * spellCard.movementSpeedMultiplier;
    }
  }

  // ========================
  // UTILIDADES
  // ========================

  /// Obtener descripción actual del boss
  String getDisplayName() {
    final phase = currentPhaseNumber;
    final spellCard = currentSpellCard.name;
    return '${bossDefinition.name} - Fase $phase: $spellCard';
  }

  /// Reset el boss al estado inicial
  void reset() {
    _currentHp = bossDefinition.baseMaxHp;
    _currentPhaseIndex = 0;
    _currentSpellCardIndex = 0;
    _state = TouhouBossState.waiting;
    _phaseTransitionTimer = 0.0;
    _spellCardDurationTimer = 0.0;
    _initializePhase();
    notifyListeners();
  }

}
