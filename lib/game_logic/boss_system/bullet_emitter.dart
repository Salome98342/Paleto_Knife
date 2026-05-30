import 'dart:math' as math;
import 'package:flame/components.dart';

/// Tipos de cartas de hechizo (Spell Cards)
enum SpellCardType {
  /// Ataque normal (bajo daño, patrones simples)
  nonSpell,

  /// Carta de hechizo (alto daño, patrones complejos)
  spellCard,

  /// Hechizo de supervivencia (jefe invulnerable, jugador esquiva)
  survivalSpell,
}

/// Configuración de un emisor de balas
/// Define lógica matemática para generar patrones complejos
class BulletEmitter {
  /// Número de balas por ciclo de disparo
  final int bulletCount;

  /// Velocidad de las balas
  final double bulletSpeed;

  /// Daño por bala
  final double bulletDamage;

  /// Ángulo inicial (radianes)
  final double initialAngle;

  /// Tipo de apuntado
  /// - 'aimed': Apunta hacia el jugador
  /// - 'static': Ángulos predefinidos
  /// - 'random': RNG dentro de spread
  final String aimType;

  /// Rango de dispersión (radianes)
  final double spreadAngle;

  /// Incremento de ángulo por ciclo (para espirales/rotativos)
  /// Si se establece, cada ciclo rota los ángulos
  final double angleIncrement;

  /// Modificador de aceleración tras disparo
  /// Ejemplo: 1.0 = velocidad constante, 1.05 = acelera 5% por frame
  final double accelerationMultiplier;

  /// Tiempo entre disparos (segundos)
  final double fireRate;

  /// Descripción para debug
  final String description;

  // Runtime
  double _elapsedTime = 0.0;
  double _currentAngle = 0.0;

  BulletEmitter({
    required this.bulletCount,
    required this.bulletSpeed,
    this.bulletDamage = 5.0,
    this.initialAngle = 0.0,
    this.aimType = 'static', // 'aimed', 'static', 'random'
    this.spreadAngle = math.pi / 6, // 30 grados por defecto
    this.angleIncrement = 0.0,
    this.accelerationMultiplier = 1.0,
    required this.fireRate,
    this.description = '',
  }) : _currentAngle = initialAngle;

  /// Actualizar tiempo transcurrido
  void update(double deltaTime) {
    _elapsedTime += deltaTime;
  }

  /// ¿Debe disparar?
  bool shouldFire() {
    if (_elapsedTime >= fireRate) {
      _elapsedTime = 0.0;
      return true;
    }
    return false;
  }

  /// Generar balas para este ciclo
  /// [playerPos] es necesario si aimType == 'aimed'
  /// [bossPos] es la posición del emisor (boss)
  List<BulletData> generateBullets({
    required Vector2 bossPos,
    Vector2? playerPos,
    math.Random? random,
  }) {
    final bullets = <BulletData>[];
    random ??= math.Random();

    _currentAngle += angleIncrement; // Rotar si es patrón rotativo

    for (int i = 0; i < bulletCount; i++) {
      late double angle;

      switch (aimType) {
        case 'aimed':
          if (playerPos == null) {
            angle = _currentAngle + (i - bulletCount / 2) * spreadAngle;
          } else {
            // Calcular vector hacia el jugador
            final direction = playerPos - bossPos;
            final baseAngle = math.atan2(direction.y, direction.x);
            angle = baseAngle + (i - bulletCount / 2) * spreadAngle;
          }
          break;

        case 'random':
          angle = _currentAngle + (random.nextDouble() - 0.5) * spreadAngle;
          break;

        case 'static':
        default:
          angle = _currentAngle + (i / bulletCount) * (2 * math.pi);
          break;
      }

      bullets.add(BulletData(
        position: bossPos.clone(),
        angle: angle,
        speed: bulletSpeed,
        damage: bulletDamage,
        acceleration: accelerationMultiplier,
      ));
    }

    return bullets;
  }

  /// Copiar con cambios
  BulletEmitter copyWith({
    int? bulletCount,
    double? bulletSpeed,
    double? bulletDamage,
    double? initialAngle,
    String? aimType,
    double? spreadAngle,
    double? angleIncrement,
    double? accelerationMultiplier,
    double? fireRate,
    String? description,
  }) {
    return BulletEmitter(
      bulletCount: bulletCount ?? this.bulletCount,
      bulletSpeed: bulletSpeed ?? this.bulletSpeed,
      bulletDamage: bulletDamage ?? this.bulletDamage,
      initialAngle: initialAngle ?? this.initialAngle,
      aimType: aimType ?? this.aimType,
      spreadAngle: spreadAngle ?? this.spreadAngle,
      angleIncrement: angleIncrement ?? this.angleIncrement,
      accelerationMultiplier: accelerationMultiplier ?? this.accelerationMultiplier,
      fireRate: fireRate ?? this.fireRate,
      description: description ?? this.description,
    );
  }
}

/// Datos de una bala generada
class BulletData {
  /// Posición inicial
  final Vector2 position;

  /// Ángulo en radianes
  final double angle;

  /// Velocidad inicial
  final double speed;

  /// Daño
  final double damage;

  /// Multiplicador de aceleración (1.0 = sin aceleración)
  final double acceleration;

  /// Velocidad actual (puede cambiar con aceleración)
  double get currentSpeed => speed * math.pow(acceleration, 0.016); // ~16ms per frame

  BulletData({
    required this.position,
    required this.angle,
    required this.speed,
    required this.damage,
    this.acceleration = 1.0,
  });
}

/// Conjunto de emisores que disparan juntos
/// Representa un "patrón" visual completo
class BulletEmitterCluster {
  /// Emisores en este cluster
  final List<BulletEmitter> emitters;

  /// Tiempo total del patrón (0 = infinito)
  final double duration;

  /// Descripción
  final String description;

  // Runtime
  double _elapsedTime = 0.0;

  BulletEmitterCluster({
    required this.emitters,
    required this.duration,
    this.description = '',
  });

  /// Actualizar todos los emisores
  void update(double deltaTime) {
    _elapsedTime += deltaTime;
    for (final emitter in emitters) {
      emitter.update(deltaTime);
    }
  }

  /// ¿Ha terminado el patrón?
  bool isFinished() => duration > 0 && _elapsedTime >= duration;

  /// Obtener todas las balas que deben dispararse ahora
  List<BulletData> getBullets({
    required Vector2 bossPos,
    Vector2? playerPos,
    math.Random? random,
  }) {
    final allBullets = <BulletData>[];

    for (final emitter in emitters) {
      if (emitter.shouldFire()) {
        allBullets.addAll(emitter.generateBullets(
          bossPos: bossPos,
          playerPos: playerPos,
          random: random,
        ));
      }
    }

    return allBullets;
  }
}
