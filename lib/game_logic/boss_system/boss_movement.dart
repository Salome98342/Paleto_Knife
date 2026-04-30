import 'package:flame/components.dart';
import 'dart:math' as math;

/// Movimiento del boss entre waypoints
class BossMovementSystem {
  /// Posición actual
  Vector2 position;

  /// Waypoints a seguir
  List<Vector2> waypoints;

  /// Índice del waypoint actual
  int _currentWaypointIndex = 0;

  /// Velocidad de movimiento (píxeles por segundo)
  double speed;

  /// ¿Está en transición entre waypoints?
  bool _isMoving = true;

  /// Tiempo esperado en cada waypoint (segundos)
  final double pauseBetweenWaypoints;

  /// Tipo de interpolación
  /// - 'linear': línea recta
  /// - 'bezier': curva suave
  /// - 'bouncy': rebota in/out
  final String interpolationType;

  // Runtime
  double _timeAtCurrentWaypoint = 0.0;
  double _transitionProgress = 0.0; // 0.0 - 1.0

  BossMovementSystem({
    required this.position,
    required this.waypoints,
    required this.speed,
    this.pauseBetweenWaypoints = 0.5,
    this.interpolationType = 'bezier',
  });

  /// Actualizar posición
  void update(double deltaTime) {
    if (waypoints.isEmpty) return;

    if (!_isMoving) {
      // Esperando en waypoint
      _timeAtCurrentWaypoint += deltaTime;
      if (_timeAtCurrentWaypoint >= pauseBetweenWaypoints) {
        _moveToNextWaypoint();
      }
      return;
    }

    // Moviendo hacia waypoint
    final currentWaypoint = waypoints[_currentWaypointIndex];
    final nextWaypoint =
        waypoints[(_currentWaypointIndex + 1) % waypoints.length];

    final distance = currentWaypoint.distanceTo(nextWaypoint);
    final distanceToTravel = speed * deltaTime;
    _transitionProgress += distanceToTravel / distance;

    if (_transitionProgress >= 1.0) {
      _transitionProgress = 1.0;
      position = nextWaypoint.clone();
      _isMoving = false;
      _timeAtCurrentWaypoint = 0.0;
      _currentWaypointIndex = (_currentWaypointIndex + 1) % waypoints.length;
    } else {
      // Interpolar posición
      position = _interpolate(
        currentWaypoint,
        nextWaypoint,
        _transitionProgress,
        interpolationType,
      );
    }
  }

  /// Moverse al siguiente waypoint
  void _moveToNextWaypoint() {
    _isMoving = true;
    _transitionProgress = 0.0;
    _timeAtCurrentWaypoint = 0.0;
  }

  /// Interpolar entre dos puntos
  Vector2 _interpolate(
    Vector2 from,
    Vector2 to,
    double t, // 0.0 - 1.0
    String type,
  ) {
    final easeT = _easeFunction(t, type);
    return Vector2(
      from.x + (to.x - from.x) * easeT,
      from.y + (to.y - from.y) * easeT,
    );
  }

  /// Función de easing
  double _easeFunction(double t, String type) {
    switch (type) {
      case 'linear':
        return t;

      case 'bezier':
      case 'ease-in-out':
        // Suavizado con bezier cúbica
        return t < 0.5
            ? 2 * t * t
            : -1 + (4 - 2 * t) * t;

      case 'bouncy':
        // Rebote
        if (t < 0.5) {
          return 2 * t * t;
        } else {
          return -1 + (4 - 2 * t) * t;
        }

      default:
        return t;
    }
  }

  /// Establecer nuevos waypoints
  void setWaypoints(List<Vector2> newWaypoints) {
    if (newWaypoints.isEmpty) return;
    waypoints = newWaypoints;
    _currentWaypointIndex = 0;
    _transitionProgress = 0.0;
    _timeAtCurrentWaypoint = 0.0;
    _isMoving = true;
  }

  /// ¿Está el boss en movimiento?
  bool get isMoving => _isMoving;

  /// Waypoint actual
  Vector2 get currentWaypoint => waypoints[_currentWaypointIndex];
}

/// Sistema que genera waypoints automáticamente basados en patrones
class WaypointGenerator {
  /// Generar waypoints circulares
  static List<Vector2> generateCircular({
    required Vector2 center,
    required double radius,
    required int pointCount,
  }) {
    final waypoints = <Vector2>[];
    for (int i = 0; i < pointCount; i++) {
      final angle = (2 * math.pi * i) / pointCount;
      waypoints.add(Vector2(
        center.x + math.cos(angle) * radius,
        center.y + math.sin(angle) * radius,
      ));
    }
    return waypoints;
  }

  /// Generar waypoints de figura-8
  static List<Vector2> generateFigure8({
    required Vector2 center,
    required double scaleX,
    required double scaleY,
    required int pointCount,
  }) {
    final waypoints = <Vector2>[];
    for (int i = 0; i < pointCount; i++) {
      final t = (2 * math.pi * i) / pointCount;
      // Lemniscata (figura 8)
      final denominator = 1.0 + math.sin(t) * math.sin(t);
      final x = center.x + scaleX * math.cos(t) / denominator;
      final y = center.y + scaleY * math.sin(t) * math.cos(t) / denominator;
      waypoints.add(Vector2(x, y));
    }
    return waypoints;
  }

  /// Generar waypoints de línea (lado a lado)
  static List<Vector2> generateSideToSide({
    required Vector2 startPos,
    required double distance,
    required int pointCount,
  }) {
    final waypoints = <Vector2>[];
    for (int i = 0; i < pointCount; i++) {
      final offset = ((i % 2) == 0 ? 1.0 : -1.0) * distance;
      waypoints.add(Vector2(startPos.x + offset, startPos.y));
    }
    return waypoints;
  }

  /// Generar waypoints aleatorios dentro de un área
  static List<Vector2> generateRandom({
    required Vector2 areaCenter,
    required double areaWidth,
    required double areaHeight,
    required int pointCount,
    math.Random? random,
  }) {
    random ??= math.Random();
    final waypoints = <Vector2>[];

    for (int i = 0; i < pointCount; i++) {
      final x = areaCenter.x +
          (random.nextDouble() - 0.5) * areaWidth;
      final y = areaCenter.y +
          (random.nextDouble() - 0.5) * areaHeight;
      waypoints.add(Vector2(x, y));
    }

    return waypoints;
  }

  /// Generar espiral
  static List<Vector2> generateSpiral({
    required Vector2 center,
    required double radiusMin,
    required double radiusMax,
    required int pointCount,
  }) {
    final waypoints = <Vector2>[];
    for (int i = 0; i < pointCount; i++) {
      final t = i / pointCount;
      final angle = t * 4 * math.pi; // 2 rotaciones
      final radius = radiusMin + (radiusMax - radiusMin) * t;
      waypoints.add(Vector2(
        center.x + math.cos(angle) * radius,
        center.y + math.sin(angle) * radius,
      ));
    }
    return waypoints;
  }
}
