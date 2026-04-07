import 'package:flutter/material.dart';
import 'boss_phase.dart';

/// Configuración de un boss
class Boss {
  /// Identificador único
  final String id;

  /// Nombre del boss
  final String name;

  /// Fases del boss
  final List<BossPhase> phases;

  /// HP máximo
  final double maxHp;

  /// Posición actual
  Offset position;

  /// HP actual
  double currentHp;

  /// Si está vivo
  bool isAlive;

  /// Fase actual
  late BossPhase _currentPhase;

  /// Índice de la fase actual
  int _currentPhaseIndex = 0;

  Boss({
    required this.id,
    required this.name,
    required this.phases,
    required this.maxHp,
    required this.position,
  })  : currentHp = maxHp,
        isAlive = true {
    _currentPhase = phases[0];
  }

  /// Obtiene la fase actual
  BossPhase get currentPhase => _currentPhase;

  /// Obtiene el índice de la fase actual
  int get currentPhaseIndex => _currentPhaseIndex;

  /// Porcentaje de HP (0.0 - 1.0)
  double get hpPercentage {
    if (maxHp <= 0) return 0;
    return (currentHp / maxHp).clamp(0.0, 1.0);
  }

  /// Recibe daño
  void takeDamage(double damage) {
    currentHp -= damage;
    if (currentHp <= 0) {
      currentHp = 0;
      isAlive = false;
    }
    _updatePhase();
  }

  /// Actualiza la fase actual basada en HP
  void _updatePhase() {
    for (int i = phases.length - 1; i >= 0; i--) {
      if (hpPercentage <= phases[i].hpThreshold) {
        if (i != _currentPhaseIndex) {
          _currentPhaseIndex = i;
          _currentPhase = phases[i];
        }
        break;
      }
    }
  }

  /// Reinicia el boss
  void reset() {
    currentHp = maxHp;
    isAlive = true;
    _currentPhaseIndex = 0;
    _currentPhase = phases[0];
  }

  /// Obtiene el multiplicador de dificultad basado en la fase actual
  double getDifficultyMultiplier() {
    return 1.0 + (_currentPhaseIndex * 0.3); // +30% dificultad por fase
  }
}
