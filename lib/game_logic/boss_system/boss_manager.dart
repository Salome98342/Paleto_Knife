import 'dart:async';
import 'package:flutter/material.dart';
import 'boss.dart';
import 'boss_phase.dart';
import '../enemy_system/attack_pattern.dart';
import '../enemy_system/enemy_behavior.dart';

/// Estados del BossManager
enum BossManagerState {
  idle,
  incoming, // Boss está por llegar
  fighting,
  phaseTransition,
  defeated,
}

/// Callback para eventos del boss
typedef void OnBossEventCallback(Boss boss);
typedef void OnBossPhaseChangeCallback(Boss boss, BossPhase oldPhase, BossPhase newPhase);
typedef void OnBossStateCallback(BossManagerState state);

/// Factory de bosses predefinidos
class BossFactory {
  /// Crea el boss del nivel
  static Boss createBoss({
    required String bossId,
    required Offset position,
  }) {
    switch (bossId) {
      case 'final_boss':
        return _createFinalBoss(position);
      default:
        throw Exception('Unknown boss: $bossId');
    }
  }

  /// Boss final con 3 fases
  static Boss _createFinalBoss(Offset position) {
    final phases = [
      // Fase 1: (100% - 70%) Patrón simple, movimiento defensivo
      BossPhase(
        id: 'phase_1',
        phaseNumber: 1,
        hpThreshold: 0.7,
        description: 'Fase 1: Patrón básico',
        behavior: Behavior(
          type: BehaviorType.circlePlayer,
          speed: 100.0,
          preferredDistance: 200.0,
        ),
        attackPatterns: [
          AttackPattern(
            type: AttackPatternType.radial,
            cooldown: 2.0,
            bulletSpeed: 300.0,
            bulletDamage: 8.0,
            bulletCount: 8,
          ),
        ],
        attackSpeedMultiplier: 1.0,
      ),

      // Fase 2: (70% - 40%) Patrón combinado, mayor agresividad
      BossPhase(
        id: 'phase_2',
        phaseNumber: 2,
        hpThreshold: 0.4,
        description: 'Fase 2: Patrón agresivo',
        behavior: Behavior(
          type: BehaviorType.circlePlayer,
          speed: 150.0,
          preferredDistance: 150.0,
        ),
        attackPatterns: [
          AttackPattern(
            type: AttackPatternType.radial,
            cooldown: 1.5,
            bulletSpeed: 350.0,
            bulletDamage: 10.0,
            bulletCount: 12,
          ),
          AttackPattern(
            type: AttackPatternType.aimed,
            cooldown: 2.0,
            bulletSpeed: 400.0,
            bulletDamage: 12.0,
            bulletCount: 1,
          ),
        ],
        attackSpeedMultiplier: 1.3,
      ),

      // Fase 3: (40% - 0%) Desesperación, patrón caótico
      BossPhase(
        id: 'phase_3',
        phaseNumber: 3,
        hpThreshold: 0.0,
        description: 'Fase 3: Desesperación',
        behavior: Behavior(
          type: BehaviorType.chase,
          speed: 200.0,
        ),
        attackPatterns: [
          AttackPattern(
            type: AttackPatternType.radial,
            cooldown: 0.8,
            bulletSpeed: 350.0,
            bulletDamage: 12.0,
            bulletCount: 16,
          ),
          AttackPattern(
            type: AttackPatternType.spread,
            cooldown: 1.2,
            bulletSpeed: 300.0,
            bulletDamage: 10.0,
            bulletCount: 8,
            spreadAngle: 180.0,
          ),
        ],
        attackSpeedMultiplier: 1.6,
      ),
    ];

    return Boss(
      id: 'final_boss',
      name: 'Final Boss',
      phases: phases,
      maxHp: 500.0,
      position: position,
    );
  }
}

/// Gestiona los bosses
class BossManager {
  /// Boss actual
  Boss? _currentBoss;

  /// Estado actual
  BossManagerState _state = BossManagerState.idle;

  /// Fase anterior (para detectar cambios)
  BossPhase? _lastPhase;

  /// Timer para la llegada del boss
  Timer? _incomingTimer;

  /// Duración de la animación de llegada
  final double incomingDuration = 1.5;

  /// Callbacks
  final _onBossStart = StreamController<Boss>.broadcast();
  final _onBossDefeated = StreamController<Boss>.broadcast();
  final _onPhaseChange =
      StreamController<({Boss boss, BossPhase newPhase})>.broadcast();
  final _onStateChanged = StreamController<BossManagerState>.broadcast();

  /// Obtiene el boss actual
  Boss? get currentBoss => _currentBoss;

  /// Obtiene el estado actual
  BossManagerState get state => _state;

  /// Stream de eventos
  Stream<Boss> get bossStarted => _onBossStart.stream;
  Stream<Boss> get bossDefeated => _onBossDefeated.stream;
  Stream<({Boss boss, BossPhase newPhase})> get phaseChanged =>
      _onPhaseChange.stream;
  Stream<BossManagerState> get stateChanged => _onStateChanged.stream;

  /// Prepara un boss para entrar
  void prepareBoss(String bossId, Offset position) {
    if (_state != BossManagerState.idle) return;

    _state = BossManagerState.incoming;
    _onStateChanged.add(_state);

    _currentBoss = BossFactory.createBoss(bossId: bossId, position: position);
    _lastPhase = _currentBoss!.currentPhase;

    // Timer para la animación de llegada
    _incomingTimer =
        Timer(Duration(milliseconds: (incomingDuration * 1000).toInt()), () {
      _state = BossManagerState.fighting;
      _onStateChanged.add(_state);
      _onBossStart.add(_currentBoss!);
    });
  }

  /// Cancelar la entrada del boss (ej: if there are still enemies)
  void cancelIncoming() {
    if (_state == BossManagerState.incoming) {
      _incomingTimer?.cancel();
      _state = BossManagerState.idle;
      _currentBoss = null;
      _onStateChanged.add(_state);
    }
  }

  /// Actualiza el estado del boss (llamar cada frame)
  void update(double deltaTime) {
    if (_currentBoss == null || _state != BossManagerState.fighting) {
      return;
    }

    // Verificar cambios de fase
    if (_currentBoss!.currentPhase != _lastPhase) {
      _lastPhase = _currentBoss!.currentPhase;
      _state = BossManagerState.phaseTransition;
      _onStateChanged.add(_state);
      _onPhaseChange.add(
        (boss: _currentBoss!, newPhase: _currentBoss!.currentPhase),
      );

      // Corta pausa en la transición de fase
      Future.delayed(Duration(milliseconds: 300), () {
        if (_currentBoss != null && _currentBoss!.isAlive) {
          _state = BossManagerState.fighting;
          _onStateChanged.add(_state);
        }
      });
    }

    // Verificar si el boss fue derrotado
    if (!_currentBoss!.isAlive) {
      _state = BossManagerState.defeated;
      _onStateChanged.add(_state);
      _onBossDefeated.add(_currentBoss!);
    }
  }

  /// Daña el boss
  void damageBoss(double damage) {
    _currentBoss?.takeDamage(damage);
  }

  /// Reinicia el manager
  void reset() {
    _incomingTimer?.cancel();
    _currentBoss = null;
    _lastPhase = null;
    _state = BossManagerState.idle;
  }

  /// Limpia recursos
  void dispose() {
    _incomingTimer?.cancel();
    _onBossStart.close();
    _onBossDefeated.close();
    _onPhaseChange.close();
    _onStateChanged.close();
  }
}
