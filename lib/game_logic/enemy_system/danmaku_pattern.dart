// Sistema de patrones Danmaku avanzado para enemigos y bosses
// Permite crear patrones de balas complejos y reutilizables

import 'package:flame/components.dart';
import 'dart:math';

/// Tipos de patrones danmaku disponibles
enum DanmakuPatternType {
  /// Disparo radial (círculo)
  radial,

  /// Disparo recto hacia abajo
  straight,

  /// Abanico de proyectiles
  spread,

  /// Patrón espiral que rota
  spiral,

  /// Patrón de onda senoidal
  sineWave,

  /// Explosión retardada (dispara lentamente, luego explota en patrón)
  delayedExplosion,

  /// Láser continuo tipo Darius
  laser,

  /// Patrón dirigido al jugador
  aimed,

  /// Patrón personalizado (callback)
  custom,
}

/// Configura cómo se ejecuta un patrón danmaku
class DanmakuConfig {
  /// Tipo de patrón
  final DanmakuPatternType type;

  /// Tiempo entre ataques (segundos)
  final double cooldown;

  /// Velocidad de los proyectiles (píxeles/segundo)
  final double bulletSpeed;

  /// Daño por proyectil
  final double bulletDamage;

  /// Número de proyectiles por ataque
  final int bulletCount;

  /// Ángulo de apertura (para spread, aimed, etc)
  final double spreadAngle;

  /// Velocidad de rotación para spirales (radianes/segundo)
  final double rotationSpeed;

  /// Amplitud de onda senoidal
  final double amplitude;

  /// Frecuencia de onda senoidal
  final double frequency;

  /// Tiempo de vida del patrón (0 = infinito, usado en delayed_explosion)
  final double lifetime;

  /// Ángulo inicial (útil para spirales y radiación)
  final double initialAngle;

  /// Si es true, el patrón se alinea hacia el jugador
  final bool aimAtPlayer;

  /// Número de explosiones en delayed_explosion
  final int explosionCount;

  /// Retraso entre explosiones en delayed_explosion (segundos)
  final double explosionDelay;

  /// Duración del láser en patrón laser (segundos)
  final double laserDuration;

  /// Radio de la onda circular (para patrones radiales)
  final double radius;

  DanmakuConfig({
    required this.type,
    required this.cooldown,
    required this.bulletSpeed,
    this.bulletDamage = 5.0,
    this.bulletCount = 1,
    this.spreadAngle = 60.0,
    this.rotationSpeed = 1.0,
    this.amplitude = 50.0,
    this.frequency = 2.0,
    this.lifetime = 0.0,
    this.initialAngle = 0.0,
    this.aimAtPlayer = false,
    this.explosionCount = 3,
    this.explosionDelay = 0.5,
    this.laserDuration = 2.0,
    this.radius = 0.0,
  });

  /// Copia profunda
  DanmakuConfig copyWith({
    DanmakuPatternType? type,
    double? cooldown,
    double? bulletSpeed,
    double? bulletDamage,
    int? bulletCount,
    double? spreadAngle,
    double? rotationSpeed,
    double? amplitude,
    double? frequency,
    double? lifetime,
    double? initialAngle,
    bool? aimAtPlayer,
    int? explosionCount,
    double? explosionDelay,
    double? laserDuration,
    double? radius,
  }) {
    return DanmakuConfig(
      type: type ?? this.type,
      cooldown: cooldown ?? this.cooldown,
      bulletSpeed: bulletSpeed ?? this.bulletSpeed,
      bulletDamage: bulletDamage ?? this.bulletDamage,
      bulletCount: bulletCount ?? this.bulletCount,
      spreadAngle: spreadAngle ?? this.spreadAngle,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      amplitude: amplitude ?? this.amplitude,
      frequency: frequency ?? this.frequency,
      lifetime: lifetime ?? this.lifetime,
      initialAngle: initialAngle ?? this.initialAngle,
      aimAtPlayer: aimAtPlayer ?? this.aimAtPlayer,
      explosionCount: explosionCount ?? this.explosionCount,
      explosionDelay: explosionDelay ?? this.explosionDelay,
      laserDuration: laserDuration ?? this.laserDuration,
      radius: radius ?? this.radius,
    );
  }
}

/// Datos que se pasan al callback de patrón custom
class DanmakuCallbackData {
  /// Posición del enemigo que dispara
  final Vector2 enemyPosition;

  /// Posición del jugador
  final Vector2? playerPosition;

  /// Tiempo total desde que comenzó el patrón
  final double elapsedTime;

  /// Configuración del patrón
  final DanmakuConfig config;

  /// Índice de disparo actual
  final int shotIndex;

  DanmakuCallbackData({
    required this.enemyPosition,
    this.playerPosition,
    required this.elapsedTime,
    required this.config,
    required this.shotIndex,
  });
}

/// Datos de un proyectil que será generado por el patrón
class DanmakuBullet {
  /// Posición inicial del proyectil
  final Vector2 position;

  /// Dirección en radianes
  final double angle;

  /// Velocidad del proyectil
  final double speed;

  /// Daño del proyectil
  final double damage;

  /// Tipo de proyectil (para visuales)
  final String bulletType;

  DanmakuBullet({
    required this.position,
    required this.angle,
    required this.speed,
    required this.damage,
    this.bulletType = 'bullet',
  });
}

/// Función callback para patrones personalizados
/// Retorna lista de proyectiles a disparar
typedef DanmakuCallback = List<DanmakuBullet> Function(DanmakuCallbackData);

/// Gestor de patrones danmaku
/// Maneja la lógica de generación de patrones complejos
class DanmakuPatternGenerator {
  /// Calcula los proyectiles a disparar para el patrón actual
  static List<DanmakuBullet> generateBullets({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    Vector2? playerPosition,
    double elapsedTime = 0.0,
    int shotIndex = 0,
    DanmakuCallback? customCallback,
  }) {
    switch (config.type) {
      case DanmakuPatternType.radial:
        return _generateRadialPattern(
          config: config,
          enemyPosition: enemyPosition,
        );

      case DanmakuPatternType.straight:
        return _generateStraightPattern(
          config: config,
          enemyPosition: enemyPosition,
        );

      case DanmakuPatternType.spread:
        return _generateSpreadPattern(
          config: config,
          enemyPosition: enemyPosition,
          playerPosition: playerPosition,
        );

      case DanmakuPatternType.spiral:
        return _generateSpiralPattern(
          config: config,
          enemyPosition: enemyPosition,
          elapsedTime: elapsedTime,
        );

      case DanmakuPatternType.sineWave:
        return _generateSineWavePattern(
          config: config,
          enemyPosition: enemyPosition,
          elapsedTime: elapsedTime,
        );

      case DanmakuPatternType.delayedExplosion:
        return _generateDelayedExplosionPattern(
          config: config,
          enemyPosition: enemyPosition,
          elapsedTime: elapsedTime,
          shotIndex: shotIndex,
        );

      case DanmakuPatternType.laser:
        return _generateLaserPattern(
          config: config,
          enemyPosition: enemyPosition,
        );

      case DanmakuPatternType.aimed:
        return _generateAimedPattern(
          config: config,
          enemyPosition: enemyPosition,
          playerPosition: playerPosition,
        );

      case DanmakuPatternType.custom:
        if (customCallback == null) {
          return [];
        }
        return customCallback(
          DanmakuCallbackData(
            enemyPosition: enemyPosition,
            playerPosition: playerPosition,
            elapsedTime: elapsedTime,
            config: config,
            shotIndex: shotIndex,
          ),
        );
    }
  }

  /// Patrón radial: círculo completo de proyectiles
  static List<DanmakuBullet> _generateRadialPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
  }) {
    final bullets = <DanmakuBullet>[];
    final angleStep = (2 * pi) / config.bulletCount;

    for (int i = 0; i < config.bulletCount; i++) {
      final angle = config.initialAngle + (angleStep * i);
      bullets.add(
        DanmakuBullet(
          position: enemyPosition.clone(),
          angle: angle,
          speed: config.bulletSpeed,
          damage: config.bulletDamage,
        ),
      );
    }

    return bullets;
  }

  /// Patrón recto: disparo hacia abajo
  static List<DanmakuBullet> _generateStraightPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
  }) {
    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: pi / 2, // Hacia abajo
        speed: config.bulletSpeed,
        damage: config.bulletDamage,
      ),
    ];
  }

  /// Patrón spread: abanico de proyectiles
  static List<DanmakuBullet> _generateSpreadPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    Vector2? playerPosition,
  }) {
    final bullets = <DanmakuBullet>[];
    double centerAngle = pi / 2; // Por defecto hacia abajo

    // Si aimAtPlayer, apuntar al jugador
    if (config.aimAtPlayer && playerPosition != null) {
      final direction = playerPosition - enemyPosition;
      centerAngle = atan2(direction.y, direction.x);
    }

    final angleStep = config.spreadAngle / (config.bulletCount - 1);
    final startAngle = centerAngle - (config.spreadAngle / 2);

    for (int i = 0; i < config.bulletCount; i++) {
      final angle = startAngle + (angleStep * i);
      bullets.add(
        DanmakuBullet(
          position: enemyPosition.clone(),
          angle: angle,
          speed: config.bulletSpeed,
          damage: config.bulletDamage,
        ),
      );
    }

    return bullets;
  }

  /// Patrón espiral: círculo que rota
  static List<DanmakuBullet> _generateSpiralPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    double elapsedTime = 0.0,
  }) {
    final angle =
        config.initialAngle + (config.rotationSpeed * elapsedTime);
    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: angle,
        speed: config.bulletSpeed,
        damage: config.bulletDamage,
      ),
    ];
  }

  /// Patrón onda senoidal: balas curvas
  static List<DanmakuBullet> _generateSineWavePattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    double elapsedTime = 0.0,
  }) {
    final sineOffset = sin(elapsedTime * config.frequency) * config.amplitude;
    final baseAngle = pi / 2; // Hacia abajo

    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: baseAngle + (sineOffset * 0.1), // Pequeña variación angular
        speed: config.bulletSpeed,
        damage: config.bulletDamage,
      ),
    ];
  }

  /// Patrón explosión retardada: proyectil lento que explota
  static List<DanmakuBullet> _generateDelayedExplosionPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    double elapsedTime = 0.0,
    int shotIndex = 0,
  }) {
    // Solo disparar si es momento de hacerlo
    final timeSinceLastShot = (elapsedTime % (config.explosionDelay * 2));
    if (timeSinceLastShot > config.explosionDelay) {
      return [];
    }

    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: pi / 2,
        speed: config.bulletSpeed * 0.3, // Más lento
        damage: config.bulletDamage,
        bulletType: 'delayed_explosion',
      ),
    ];
  }

  /// Patrón láser: línea continua
  static List<DanmakuBullet> _generateLaserPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
  }) {
    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: pi / 2,
        speed: config.bulletSpeed,
        damage: config.bulletDamage,
        bulletType: 'laser',
      ),
    ];
  }

  /// Patrón dirigido: apunta siempre al jugador
  static List<DanmakuBullet> _generateAimedPattern({
    required DanmakuConfig config,
    required Vector2 enemyPosition,
    Vector2? playerPosition,
  }) {
    if (playerPosition == null) {
      return [];
    }

    final direction = playerPosition - enemyPosition;
    final angle = atan2(direction.y, direction.x);

    return [
      DanmakuBullet(
        position: enemyPosition.clone(),
        angle: angle,
        speed: config.bulletSpeed,
        damage: config.bulletDamage,
      ),
    ];
  }
}

/// Gestor de composición de múltiples patrones
/// Permite que un enemigo/boss dispare múltiples patrones simultáneamente
class ComposedDanmakuPattern {
  /// Lista de patrones que se ejecutan simultáneamente
  final List<DanmakuConfig> patterns;

  /// Nombre descriptivo del patrón compuesto
  final String name;

  /// Cooldown total (se aplica a todos los sub-patrones)
  late double totalCooldown;

  ComposedDanmakuPattern({
    required this.patterns,
    required this.name,
  }) {
    // El cooldown es el mínimo de los patrones
    totalCooldown = patterns.isNotEmpty
        ? patterns.map((p) => p.cooldown).reduce((a, b) => a < b ? a : b)
        : 1.0;
  }

  /// Genera todos los proyectiles de todos los patrones
  List<DanmakuBullet> generateAllBullets({
    required Vector2 enemyPosition,
    Vector2? playerPosition,
    double elapsedTime = 0.0,
    int shotIndex = 0,
    Map<int, DanmakuCallback>? customCallbacks,
  }) {
    final allBullets = <DanmakuBullet>[];

    for (int i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final bullets = DanmakuPatternGenerator.generateBullets(
        config: pattern,
        enemyPosition: enemyPosition,
        playerPosition: playerPosition,
        elapsedTime: elapsedTime,
        shotIndex: shotIndex,
        customCallback: customCallbacks?[i],
      );
      allBullets.addAll(bullets);
    }

    return allBullets;
  }
}

/// Presets de patrones comunes para bosses y enemigos
class DanmakuPresets {
  // ===== ENEMIGOS BÁSICOS =====

  /// Patrón para GRUNT: Disparo simple rápido
  static DanmakuConfig gruntBasic() => DanmakuConfig(
        type: DanmakuPatternType.straight,
        cooldown: 1.5,
        bulletSpeed: 200.0,
        bulletDamage: 5.0,
        bulletCount: 1,
      );

  /// Patrón para SHOOTER: Disparo dirigido rápido
  static DanmakuConfig shooterAimed() => DanmakuConfig(
        type: DanmakuPatternType.aimed,
        cooldown: 1.2,
        bulletSpeed: 250.0,
        bulletDamage: 7.0,
        bulletCount: 1,
        aimAtPlayer: true,
      );

  /// Patrón para TANK: Disparo radial lento
  static DanmakuConfig tankRadial() => DanmakuConfig(
        type: DanmakuPatternType.radial,
        cooldown: 2.0,
        bulletSpeed: 150.0,
        bulletDamage: 10.0,
        bulletCount: 8,
      );

  /// Patrón para SWARM: Abanico rápido
  static DanmakuConfig swarmSpread() => DanmakuConfig(
        type: DanmakuPatternType.spread,
        cooldown: 0.8,
        bulletSpeed: 180.0,
        bulletDamage: 3.0,
        bulletCount: 5,
        spreadAngle: 45.0,
      );

  /// Patrón para ELITE: Espiral hipnótica
  static DanmakuConfig eliteSpiral() => DanmakuConfig(
        type: DanmakuPatternType.spiral,
        cooldown: 0.3,
        bulletSpeed: 200.0,
        bulletDamage: 6.0,
        bulletCount: 1,
        rotationSpeed: 3.0,
      );

  // ===== BOSSES FASE 1 =====

  /// Boss Fase 1: Patrón radial simple
  static DanmakuConfig bossPhase1Radial() => DanmakuConfig(
        type: DanmakuPatternType.radial,
        cooldown: 1.5,
        bulletSpeed: 200.0,
        bulletDamage: 8.0,
        bulletCount: 12,
      );

  /// Boss Fase 1: Patrón spread dirigido
  static DanmakuConfig bossPhase1Aimed() => DanmakuConfig(
        type: DanmakuPatternType.spread,
        cooldown: 2.0,
        bulletSpeed: 220.0,
        bulletDamage: 10.0,
        bulletCount: 7,
        spreadAngle: 60.0,
        aimAtPlayer: true,
      );

  // ===== BOSSES FASE 2 =====

  /// Boss Fase 2: Espiral rótativa
  static DanmakuConfig bossPhase2Spiral() => DanmakuConfig(
        type: DanmakuPatternType.spiral,
        cooldown: 0.5,
        bulletSpeed: 200.0,
        bulletDamage: 6.0,
        bulletCount: 1,
        rotationSpeed: 5.0,
      );

  /// Boss Fase 2: Onda senoidal
  static DanmakuConfig bossPhase2SineWave() => DanmakuConfig(
        type: DanmakuPatternType.sineWave,
        cooldown: 1.0,
        bulletSpeed: 180.0,
        bulletDamage: 7.0,
        bulletCount: 1,
        frequency: 3.0,
        amplitude: 100.0,
      );

  // ===== BOSSES FASE 3 =====

  /// Boss Fase 3: Explosión retardada + patrón radial completo
  static DanmakuConfig bossPhase3Explosive() => DanmakuConfig(
        type: DanmakuPatternType.delayedExplosion,
        cooldown: 0.3,
        bulletSpeed: 150.0,
        bulletDamage: 5.0,
        explosionCount: 5,
        explosionDelay: 0.4,
      );

  /// Boss Fase 3: Láser continuo
  static DanmakuConfig bossPhase3Laser() => DanmakuConfig(
        type: DanmakuPatternType.laser,
        cooldown: 1.0,
        bulletSpeed: 300.0,
        bulletDamage: 15.0,
        laserDuration: 2.0,
      );

  // ===== COMPOSICIONES AVANZADAS =====

  /// Composición: Radial + Espiral (Boss avanzado)
  static ComposedDanmakuPattern radialPlusSpiral() =>
      ComposedDanmakuPattern(
        name: 'radial_spiral',
        patterns: [
          bossPhase1Radial().copyWith(cooldown: 1.5),
          bossPhase2Spiral().copyWith(cooldown: 1.5),
        ],
      );

  /// Composición: Spread dirigido + Onda senoidal
  static ComposedDanmakuPattern aimedPlusSineWave() =>
      ComposedDanmakuPattern(
        name: 'aimed_sine_wave',
        patterns: [
          bossPhase1Aimed().copyWith(cooldown: 2.0),
          bossPhase2SineWave().copyWith(cooldown: 2.0),
        ],
      );

  /// Composición: Patrón de ENDGAME - Todos los patrones
  static ComposedDanmakuPattern endgameChaos() =>
      ComposedDanmakuPattern(
        name: 'endgame_chaos',
        patterns: [
          bossPhase1Radial().copyWith(bulletCount: 16, cooldown: 0.8),
          bossPhase2Spiral().copyWith(rotationSpeed: 7.0, cooldown: 0.8),
          bossPhase3Laser()
              .copyWith(bulletSpeed: 350.0, bulletDamage: 20.0, cooldown: 0.8),
        ],
      );
}
