/// Tipos de comportamiento de movimiento de enemigos
enum BehaviorType {
  /// Sigue directamente al jugador
  chase,

  /// Mantiene una distancia del jugador
  keepDistance,

  /// Movimiento errático y aleatorio
  wander,

  /// Orbita alrededor del jugador
  circlePlayer,

  /// Estático, no se mueve
  stationary,
}

/// Configuración del comportamiento de movimiento de un enemigo
class Behavior {
  /// Tipo de comportamiento
  final BehaviorType type;

  /// Velocidad de movimiento (píxeles por segundo)
  final double speed;

  /// Distancia deseada si applica (keepDistance, circlePlayer)
  final double preferredDistance;

  /// Aceleración para comportamientos erráticos
  final double acceleration;

  Behavior({
    required this.type,
    required this.speed,
    this.preferredDistance = 200.0,
    this.acceleration = 50.0,
  });

  /// Copia profunda
  Behavior copyWith({
    BehaviorType? type,
    double? speed,
    double? preferredDistance,
    double? acceleration,
  }) {
    return Behavior(
      type: type ?? this.type,
      speed: speed ?? this.speed,
      preferredDistance: preferredDistance ?? this.preferredDistance,
      acceleration: acceleration ?? this.acceleration,
    );
  }
}
