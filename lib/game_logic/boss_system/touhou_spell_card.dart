import 'bullet_emitter.dart';
import '../enemy_system/enemy_behavior.dart';

/// Define una Spell Card (Carta de Hechizo) tipo Touhou
/// Contiene toda la lógica de una fase de ataque específica
class TouhouSpellCard {
  /// Identificador único
  final String id;

  /// Nombre para UI
  final String name;

  /// Tipo de carta
  final SpellCardType type;

  /// Descripción/lore
  final String description;

  /// HP de la carta (si se agota, pasa a siguiente spell)
  final double maxHp;

  /// Duración máxima de la carta en segundos
  /// Si se agota el tiempo sin derrotar el boss, pasa a siguiente spell
  /// 0 = infinito (hasta agotar HP)
  final double maxDuration;

  /// Multiplicador de HP para esta carta
  /// Ejemplo: 1.2 = 20% más HP que el calculado
  final double hpMultiplier;

  /// Clusters de emisores de balas
  /// Cada cluster dispara simultáneamente
  final List<BulletEmitterCluster> bulletEmitterClusters;

  /// Comportamiento de movimiento del boss durante esta carta
  /// null = sin movimiento
  final Behavior? movementBehavior;

  /// Multiplicador de velocidad de movimiento
  final double movementSpeedMultiplier;

  /// ¿Puntos de ruta para el movimiento?
  /// Si se proporciona, el boss navega entre estos puntos
  final List<(double x, double y)>? waypointsPattern;

  /// Recompensa de puntos
  final int pointsReward;

  /// Recompensa de items
  /// Ejemplo: drops de power-ups al completar
  final Map<String, int>? itemRewards;

  /// Efectos visuales/VFX a usar
  final List<String> vfxTriggers;

  /// ¿Es invulnerable durante esta carta?
  final bool isBossInvulnerable;

  /// Color del nombre para UI
  final String uiColorHex;

  TouhouSpellCard({
    required this.id,
    required this.name,
    required this.type,
    required this.maxHp,
    required this.maxDuration,
    required this.bulletEmitterClusters,
    this.description = '',
    this.hpMultiplier = 1.0,
    this.movementBehavior,
    this.movementSpeedMultiplier = 1.0,
    this.waypointsPattern,
    this.pointsReward = 500,
    this.itemRewards,
    this.vfxTriggers = const [],
    this.isBossInvulnerable = false,
    this.uiColorHex = '#FFFFFF',
  });

  /// Copiar con cambios
  TouhouSpellCard copyWith({
    String? id,
    String? name,
    SpellCardType? type,
    String? description,
    double? maxHp,
    double? maxDuration,
    double? hpMultiplier,
    List<BulletEmitterCluster>? bulletEmitterClusters,
    Behavior? movementBehavior,
    double? movementSpeedMultiplier,
    List<(double x, double y)>? waypointsPattern,
    int? pointsReward,
    Map<String, int>? itemRewards,
    List<String>? vfxTriggers,
    bool? isBossInvulnerable,
    String? uiColorHex,
  }) {
    return TouhouSpellCard(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      maxHp: maxHp ?? this.maxHp,
      maxDuration: maxDuration ?? this.maxDuration,
      hpMultiplier: hpMultiplier ?? this.hpMultiplier,
      bulletEmitterClusters:
          bulletEmitterClusters ?? this.bulletEmitterClusters,
      movementBehavior: movementBehavior ?? this.movementBehavior,
      movementSpeedMultiplier:
          movementSpeedMultiplier ?? this.movementSpeedMultiplier,
      waypointsPattern: waypointsPattern ?? this.waypointsPattern,
      pointsReward: pointsReward ?? this.pointsReward,
      itemRewards: itemRewards ?? this.itemRewards,
      vfxTriggers: vfxTriggers ?? this.vfxTriggers,
      isBossInvulnerable: isBossInvulnerable ?? this.isBossInvulnerable,
      uiColorHex: uiColorHex ?? this.uiColorHex,
    );
  }
}

/// Una fase completa del boss (puede tener múltiples Spell Cards)
class TouhouBossPhase {
  /// Identificador único
  final String id;

  /// Número de fase (1, 2, 3)
  final int phaseNumber;

  /// Umbral de HP para iniciar esta fase (0.0 - 1.0)
  /// Ej: 0.67 = fase 2 comienza al 67% de HP
  final double hpThreshold;

  /// Cartas de hechizo en orden
  final List<TouhouSpellCard> spellCards;

  /// Duración de transición (segundos)
  final double transitionDuration;

  /// ¿Limpiar balas durante transición?
  final bool clearBulletsOnTransition;

  /// Descripción de la fase
  final String phaseName;

  /// Multiplicador de daño base del boss
  final double damageMultiplier;

  TouhouBossPhase({
    required this.id,
    required this.phaseNumber,
    required this.hpThreshold,
    required this.spellCards,
    this.transitionDuration = 1.5,
    this.clearBulletsOnTransition = true,
    this.phaseName = '',
    this.damageMultiplier = 1.0,
  });

  /// Obtener HP total de la fase (suma de todas las spell cards)
  double getTotalPhaseHp() {
    return spellCards.fold(0.0, (sum, card) => sum + (card.maxHp * card.hpMultiplier));
  }
}
