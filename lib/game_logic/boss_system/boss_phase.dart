import '../enemy_system/attack_pattern.dart';
import '../enemy_system/enemy_behavior.dart';

/// Definición de una fase de boss
class BossPhase {
  /// Identificador de la fase
  final String id;

  /// Número de la fase (1, 2, 3, etc)
  final int phaseNumber;

  /// Umbral de HP en el que comienza esta fase (0.0 - 1.0)
  /// Ej: 0.7 significa que la fase comienza al 70% de HP
  final double hpThreshold;

  /// Patrones de ataque disponibles en esta fase
  final List<AttackPattern> attackPatterns;

  /// Comportamiento de movimiento
  final Behavior behavior;

  /// Multiplicador de velocidad de ataque
  final double attackSpeedMultiplier;

  /// Descripción de la fase (para debug/UI)
  final String description;

  BossPhase({
    required this.id,
    required this.phaseNumber,
    required this.hpThreshold,
    required this.attackPatterns,
    required this.behavior,
    this.attackSpeedMultiplier = 1.0,
    this.description = '',
  });

  /// Copia profunda
  BossPhase copyWith({
    String? id,
    int? phaseNumber,
    double? hpThreshold,
    List<AttackPattern>? attackPatterns,
    Behavior? behavior,
    double? attackSpeedMultiplier,
    String? description,
  }) {
    return BossPhase(
      id: id ?? this.id,
      phaseNumber: phaseNumber ?? this.phaseNumber,
      hpThreshold: hpThreshold ?? this.hpThreshold,
      attackPatterns: attackPatterns ?? this.attackPatterns,
      behavior: behavior ?? this.behavior,
      attackSpeedMultiplier: attackSpeedMultiplier ?? this.attackSpeedMultiplier,
      description: description ?? this.description,
    );
  }
}
