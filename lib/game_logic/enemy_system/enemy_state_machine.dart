// Sistema de máquina de estados para enemigos inteligentes
// Permite que los enemigos cambien de estado (idle, repositioning, attack, ability, retreat)
// basado en condiciones como HP, distancia al jugador, patrón de ataque, etc.

import 'dart:math';

/// Estados posibles de un enemigo
enum EnemyStateType {
  /// Esperando o movimiento lento
  idle,

  /// Reposicionándose para atacar
  reposition,

  /// Atacando activamente
  attack,

  /// Usando habilidades especiales (escudo, dash, etc)
  ability,

  /// Retirándose cuando está bajo de HP
  retreat,
}

/// Datos utilizados por la máquina de estados para tomar decisiones
class EnemyStateData {
  /// HP actual del enemigo (0.0 a 1.0)
  final double healthRatio;

  /// Distancia al jugador (píxeles)
  final double distanceToPlayer;

  /// Tiempo desde el último ataque (segundos)
  final double timeSinceLastShot;

  /// Tiempo total que ha estado en el estado actual (segundos)
  final double stateElapsedTime;

  /// Velocidad actual del enemigo
  final double currentSpeed;

  /// Tipo de rol del enemigo (grunt, tank, shooter, etc)
  final String role;

  /// Si el enemigo está bajo Alert condition
  final bool isAlert;

  EnemyStateData({
    required this.healthRatio,
    required this.distanceToPlayer,
    required this.timeSinceLastShot,
    required this.stateElapsedTime,
    required this.currentSpeed,
    required this.role,
    required this.isAlert,
  });
}

/// Transición entre estados
class StateTransition {
  /// Estado destino
  final EnemyStateType targetState;

  /// Condición que debe cumplirse para la transición
  /// Retorna true si la transición debe ocurrir
  final bool Function(EnemyStateData) condition;

  /// Prioridad de la transición (mayor = más importante)
  final int priority;

  StateTransition({
    required this.targetState,
    required this.condition,
    this.priority = 0,
  });
}

/// Comportamiento de un estado específico
class StateAction {
  /// Velocidad relativa (0.0 = parado, 1.0 = velocidad normal, 2.0 = doble)
  final double speedMultiplier;

  /// Si debe atacar en este estado
  final bool shouldAttack;

  /// Cooldown de ataque modificado (1.0 = normal, 0.5 = el doble de rápido)
  final double attackCooldownMultiplier;

  /// Si debe usar una habilidad especial
  final bool shouldUseAbility;

  /// Descripción para debugging
  final String description;

  StateAction({
    required this.speedMultiplier,
    required this.shouldAttack,
    required this.attackCooldownMultiplier,
    required this.shouldUseAbility,
    required this.description,
  });
}

/// Máquina de estados para enemigos
/// Maneja la transición entre estados y las acciones del enemigo
class EnemyStateMachine {
  /// Estado actual
  EnemyStateType _currentState = EnemyStateType.idle;

  /// Time en estado actual
  double _stateElapsedTime = 0.0;

  /// Transiciones disponibles desde cada estado
  late final Map<EnemyStateType, List<StateTransition>> _transitions;

  /// Acciones para cada estado
  late final Map<EnemyStateType, StateAction> _stateActions;

  EnemyStateMachine() {
    _initializeTransitions();
    _initializeStateActions();
  }

  /// Inicializa las transiciones entre estados
  void _initializeTransitions() {
    _transitions = {
      EnemyStateType.idle: [
        // idle → reposition: Si distancia es muy grande
        StateTransition(
          targetState: EnemyStateType.reposition,
          condition: (data) =>
              data.distanceToPlayer > 400 && !data.isAlert,
          priority: 10,
        ),
        // idle → attack: Si está en rango y puede atacar
        StateTransition(
          targetState: EnemyStateType.attack,
          condition: (data) =>
              data.distanceToPlayer < 300 && data.timeSinceLastShot > 0.5,
          priority: 20,
        ),
        // idle → retreat: Si está muy bajo de HP
        StateTransition(
          targetState: EnemyStateType.retreat,
          condition: (data) => data.healthRatio < 0.2,
          priority: 100,
        ),
        // idle → ability: Si está mediado de HP, usa habilidad defensiva
        StateTransition(
          targetState: EnemyStateType.ability,
          condition: (data) =>
              data.healthRatio < 0.5 &&
              data.healthRatio > 0.2 &&
              data.stateElapsedTime > 3.0,
          priority: 60,
        ),
      ],
      EnemyStateType.reposition: [
        // reposition → attack: Si llegó al rango
        StateTransition(
          targetState: EnemyStateType.attack,
          condition: (data) => data.distanceToPlayer < 300,
          priority: 20,
        ),
        // reposition → idle: Si estuvo reposicionándose mucho tiempo
        StateTransition(
          targetState: EnemyStateType.idle,
          condition: (data) => data.stateElapsedTime > 5.0,
          priority: 5,
        ),
        // reposition → retreat: Si está muy bajo
        StateTransition(
          targetState: EnemyStateType.retreat,
          condition: (data) => data.healthRatio < 0.2,
          priority: 100,
        ),
      ],
      EnemyStateType.attack: [
        // attack → idle: Si ya no está en rango
        StateTransition(
          targetState: EnemyStateType.idle,
          condition: (data) => data.distanceToPlayer > 400,
          priority: 10,
        ),
        // attack → reposition: Si el jugador se aleja demasiado
        StateTransition(
          targetState: EnemyStateType.reposition,
          condition: (data) =>
              data.distanceToPlayer > 350 &&
              data.stateElapsedTime > 2.0,
          priority: 15,
        ),
        // attack → retreat: Si está muy bajo
        StateTransition(
          targetState: EnemyStateType.retreat,
          condition: (data) => data.healthRatio < 0.2,
          priority: 100,
        ),
        // attack → ability: Si acaba de disparar y quiere usar habilidad
        StateTransition(
          targetState: EnemyStateType.ability,
          condition: (data) =>
              data.healthRatio < 0.4 &&
              data.stateElapsedTime > 1.5,
          priority: 50,
        ),
      ],
      EnemyStateType.ability: [
        // ability → attack: Después de usar habilidad, vuelve a atacar
        StateTransition(
          targetState: EnemyStateType.attack,
          condition: (data) => data.stateElapsedTime > 1.0,
          priority: 30,
        ),
        // ability → retreat: Si sigue bajo de HP
        StateTransition(
          targetState: EnemyStateType.retreat,
          condition: (data) => data.healthRatio < 0.1,
          priority: 100,
        ),
      ],
      EnemyStateType.retreat: [
        // retreat → idle: Si recuperó algo de HP
        StateTransition(
          targetState: EnemyStateType.idle,
          condition: (data) => data.healthRatio > 0.4,
          priority: 10,
        ),
        // retreat → attack: Si tiene buena distancia y está más sano
        StateTransition(
          targetState: EnemyStateType.attack,
          condition: (data) =>
              data.healthRatio > 0.5 &&
              data.distanceToPlayer < 250,
          priority: 5,
        ),
      ],
    };
  }

  /// Inicializa las acciones para cada estado
  void _initializeStateActions() {
    _stateActions = {
      EnemyStateType.idle: StateAction(
        speedMultiplier: 0.3,
        shouldAttack: false,
        attackCooldownMultiplier: 1.0,
        shouldUseAbility: false,
        description: 'Esperando o movimiento lento',
      ),
      EnemyStateType.reposition: StateAction(
        speedMultiplier: 1.2,
        shouldAttack: false,
        attackCooldownMultiplier: 1.0,
        shouldUseAbility: false,
        description: 'Moviéndose a posición de ataque',
      ),
      EnemyStateType.attack: StateAction(
        speedMultiplier: 0.5,
        shouldAttack: true,
        attackCooldownMultiplier: 1.0,
        shouldUseAbility: false,
        description: 'Atacando activamente',
      ),
      EnemyStateType.ability: StateAction(
        speedMultiplier: 0.0,
        shouldAttack: false,
        attackCooldownMultiplier: 0.0,
        shouldUseAbility: true,
        description: 'Usando habilidad especial (escudo/dash/etc)',
      ),
      EnemyStateType.retreat: StateAction(
        speedMultiplier: 1.5,
        shouldAttack: true,
        attackCooldownMultiplier: 0.7,
        shouldUseAbility: false,
        description: 'Retirándose mientras dispara',
      ),
    };
  }

  /// Obtiene el estado actual
  EnemyStateType get currentState => _currentState;

  /// Obtiene el tiempo en el estado actual
  double get stateElapsedTime => _stateElapsedTime;

  /// Obtiene la acción para el estado actual
  StateAction get currentAction => _stateActions[_currentState]!;

  /// Obtiene descripción del estado actual
  String get currentStateDescription =>
      _stateActions[_currentState]!.description;

  /// Actualiza la máquina de estados
  void update(double dt, EnemyStateData stateData) {
    _stateElapsedTime += dt;

    // Buscar las mejores transiciones (mayor prioridad)
    final availableTransitions = _transitions[_currentState] ?? [];

    // Filtrar transiciones válidas y ordenar por prioridad
    final validTransitions = availableTransitions
        .where((t) => t.condition(stateData))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // Ejecutar la transición de mayor prioridad
    if (validTransitions.isNotEmpty) {
      final transition = validTransitions.first;
      _transitionTo(transition.targetState);
    }
  }

  /// Transiciona a un nuevo estado
  void _transitionTo(EnemyStateType newState) {
    if (_currentState == newState) return;

    _currentState = newState;
    _stateElapsedTime = 0.0;
  }

  /// Obtiene el multiplicador de velocidad para el estado actual
  double getSpeedMultiplier() => currentAction.speedMultiplier;

  /// Obtiene si debe atacar en el estado actual
  bool shouldAttack() => currentAction.shouldAttack;

  /// Obtiene el multiplicador del cooldown de ataque
  double getAttackCooldownMultiplier() =>
      currentAction.attackCooldownMultiplier;

  /// Obtiene si debe usar habilidad especial
  bool shouldUseAbility() => currentAction.shouldUseAbility;
}

/// Gestor de habilidades especiales para enemigos
class EnemyAbility {
  /// Nombre de la habilidad
  final String name;

  /// Descripción
  final String description;

  /// Cooldown de la habilidad (segundos)
  final double cooldown;

  /// Duración del efecto (0 = instantáneo)
  final double duration;

  /// Tipo de habilidad
  final EnemyAbilityType type;

  /// Valor numérico (escudo HP, dash distance, etc)
  final double value;

  /// Callback ejecutado cuando se activa la habilidad
  final Function? onActivate;

  /// Callback ejecutado cuando termina la habilidad
  final Function? onDeactivate;

  EnemyAbility({
    required this.name,
    required this.description,
    required this.cooldown,
    required this.duration,
    required this.type,
    required this.value,
    this.onActivate,
    this.onDeactivate,
  });
}

/// Tipos de habilidades especiales
enum EnemyAbilityType {
  /// Escudo temporal que reduce daño
  shield,

  /// Dash corto de movimiento
  dash,

  /// Invocación de enemigos menores
  summon,

  /// Aumento temporal de velocidad
  berserk,

  /// Regeneración de HP
  heal,

  /// Fusión con otros enemigos (para swarms)
  fuse,

  /// Explosión al morir/activar
  explosion,
}

/// Presets de habilidades comunes
class EnemyAbilityPresets {
  /// Escudo temporal para TANK
  static EnemyAbility tankShield() => EnemyAbility(
        name: 'Escudo de Masa',
        description: 'Crea un escudo temporal que reduce 50% del daño',
        cooldown: 5.0,
        duration: 2.0,
        type: EnemyAbilityType.shield,
        value: 0.5, // 50% reduction
      );

  /// Dash corto para GRUNT
  static EnemyAbility gruntDash() => EnemyAbility(
        name: 'Dash Rápido',
        description: 'Se desplaza rápidamente por 0.3 segundos',
        cooldown: 3.0,
        duration: 0.3,
        type: EnemyAbilityType.dash,
        value: 500.0, // píxeles de movimiento
      );

  /// Berserk para ELITE
  static EnemyAbility eliteBerserk() => EnemyAbility(
        name: 'Frenesí',
        description: 'Aumenta velocidad de ataque y movimiento 50%',
        cooldown: 6.0,
        duration: 3.0,
        type: EnemyAbilityType.berserk,
        value: 1.5, // 1.5x multiplicador
      );

  /// Invocación para ELITE
  static EnemyAbility eliteSummon() => EnemyAbility(
        name: 'Invocación',
        description: 'Invoca 3 enemigos menores para ayuda',
        cooldown: 8.0,
        duration: 0.0, // Instantáneo
        type: EnemyAbilityType.summon,
        value: 3.0, // cantidad de enemigos
      );

  /// Fusión para SWARM
  static EnemyAbility swarmFuse() => EnemyAbility(
        name: 'Fusión',
        description: 'Se fusiona con otros swarms para ser más fuerte',
        cooldown: 4.0,
        duration: 2.0,
        type: EnemyAbilityType.fuse,
        value: 1.0,
      );

  /// Regeneración para BOSS
  static EnemyAbility bossRegenerate() => EnemyAbility(
        name: 'Regeneración Ancestral',
        description: 'Recupera HP lentamente',
        cooldown: 7.0,
        duration: 3.0,
        type: EnemyAbilityType.heal,
        value: 10.0, // HP por segundo
      );

  /// Explosión de venganza para cualquiera
  static EnemyAbility explosionOnDeath() => EnemyAbility(
        name: 'Explosión de Venganza',
        description: 'Al morir, explota en patrón radial',
        cooldown: 0.0,
        duration: 0.0,
        type: EnemyAbilityType.explosion,
        value: 1.0,
      );
}

/// Gestor de cooldown de habilidades
class AbilityCooldownManager {
  /// Mapa de nombre habilidad → tiempo restante de cooldown
  final Map<String, double> _cooldowns = {};

  /// Registra una habilidad
  void registerAbility(String abilityName, double cooldown) {
    _cooldowns[abilityName] = 0.0;
  }

  /// Actualiza los cooldowns
  void update(double dt) {
    _cooldowns.forEach((key, value) {
      if (value > 0) {
        _cooldowns[key] = value - dt;
      }
    });
  }

  /// Verifica si una habilidad está disponible
  bool isAvailable(String abilityName) {
    return _cooldowns[abilityName] == null || _cooldowns[abilityName]! <= 0;
  }

  /// Activa una habilidad (inicia su cooldown)
  void activateAbility(String abilityName, double cooldown) {
    _cooldowns[abilityName] = cooldown;
  }

  /// Obtiene el tiempo restante de cooldown
  double getRemainingCooldown(String abilityName) {
    return max(0, _cooldowns[abilityName] ?? 0.0);
  }
}
