// Sistema de efectos visuales (VFX) integrado con Flame
// Maneja partículas, shaders y efectos de ataque para bosses

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════
// ✨ EFFECTOS DE PARTÍCULAS
// ═══════════════════════════════════════════════════════════════

/// Particula individual
class GameParticle {
  late Vector2 position;
  late Vector2 velocity;
  late Color color;
  double size;
  double lifetime;
  double maxLifetime;
  double rotation;

  GameParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
    required this.rotation,
  }) : maxLifetime = lifetime;

  void update(double deltaTime) {
    position += velocity * deltaTime;
    lifetime -= deltaTime;
  }

  bool get isDead => lifetime <= 0;

  double get alpha => math.max(0, lifetime / maxLifetime);
}

/// emisor de partículas
class ParticleEmitter {
  final String effectName;
  final Color particleColor;
  final double particleSize;
  final int particleCount;
  final double emissionRate;
  final Duration particleLifetime;
  
  final List<GameParticle> particles = [];
  double emissionAccumulator = 0.0;
  bool isActive = true;

  ParticleEmitter({
    required this.effectName,
    required this.particleColor,
    required this.particleSize,
    required this.particleCount,
    required this.emissionRate,
    required this.particleLifetime,
  });

  /// Emite partículas en patrón radial
  void emitRadial(Vector2 center, double speed, double angle) {
    for (int i = 0; i < particleCount; i++) {
      final theta = (2 * math.pi * i / particleCount) + angle;
      final vx = math.cos(theta) * speed;
      final vy = math.sin(theta) * speed;

      particles.add(GameParticle(
        position: center.clone(),
        velocity: Vector2(vx, vy),
        color: particleColor,
        size: particleSize,
        lifetime: particleLifetime.inMilliseconds / 1000.0,
        rotation: theta,
      ));
    }
  }

  /// Emite partículas en explosión
  void emitExplosion(Vector2 center, double speed) {
    final random = math.Random();
    for (int i = 0; i < particleCount; i++) {
      final theta = random.nextDouble() * 2 * math.pi;
      final speedVariation = speed * (0.7 + random.nextDouble() * 0.6);
      final vx = math.cos(theta) * speedVariation;
      final vy = math.sin(theta) * speedVariation;

      particles.add(GameParticle(
        position: center.clone(),
        velocity: Vector2(vx, vy),
        color: particleColor.withValues(alpha: 0.8),
        size: particleSize * (0.6 + random.nextDouble() * 0.8),
        lifetime: particleLifetime.inMilliseconds / 1000.0,
        rotation: theta,
      ));
    }
  }

  /// Emite partículas en línea
  void emitLine(Vector2 start, Vector2 end, double speed) {
    final direction = (end - start).normalized();
    final random = math.Random();
    final distance = (end - start).length;
    
    for (int i = 0; i < particleCount; i++) {
      final t = i / math.max(1, particleCount - 1);
      final position = start + (direction * distance * t);
      
      // Velocidad principal + ruido
      final perpendicular = Vector2(-direction.y, direction.x);
      final noiseFactor = (random.nextDouble() - 0.5) * speed;
      final velocity = direction * speed + perpendicular * noiseFactor;

      particles.add(GameParticle(
        position: position,
        velocity: velocity,
        color: particleColor,
        size: particleSize,
        lifetime: particleLifetime.inMilliseconds / 1000.0,
        rotation: 0,
      ));
    }
  }

  /// Actualiza todas las partículas
  void update(double deltaTime) {
    for (var particle in particles) {
      particle.update(deltaTime);
    }
    if (particles.isNotEmpty) {
      particles.removeWhere((p) => p.isDead);
    }
  }

  /// Limpia todas las partículas
  void clear() {
    particles.clear();
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎨 EFECTOS VISUALES ESPECÍFICOS POR TIPO DE ATAQUE
// ═══════════════════════════════════════════════════════════════

/// Efecto visual para ataque radial
class RadialBurstVFX {
  final Vector2 position;
  final Color color;
  final double radius;
  double animationTime = 0;
  final double duration = 0.6;

  RadialBurstVFX({
    required this.position,
    required this.color,
    required this.radius,
  });

  void update(double deltaTime) {
    animationTime += deltaTime;
  }

  bool get isFinished => animationTime >= duration;

  double get progress => animationTime / duration;

  /// Radio actual de expansión
  double get currentRadius => radius * progress;

  /// Opacidad del efecto
  double get alpha => math.max(0, 1 - progress);
}

/// Efecto visual para ataque en espiral
class SpiralAttackVFX {
  final Vector2 position;
  final Color color;
  final double radiusMax;
  double animationTime = 0;
  final double duration = 1.2;
  final double rotationSpeed = 8.0; // Radianes por segundo

  SpiralAttackVFX({
    required this.position,
    required this.color,
    required this.radiusMax,
  });

  void update(double deltaTime) {
    animationTime += deltaTime;
  }

  bool get isFinished => animationTime >= duration;

  double get progress => animationTime / duration;

  double get currentRotation => animationTime * rotationSpeed;

  double get currentRadius => radiusMax * progress;

  double get alpha => math.max(0, 1 - progress);
}

/// Efecto visual para rayo láser
class LaserVFX {
  final Vector2 start;
  final Vector2 end;
  final Color color;
  double animationTime = 0;
  final double duration = 0.8;

  LaserVFX({
    required this.start,
    required this.end,
    required this.color,
  });

  void update(double deltaTime) {
    animationTime += deltaTime;
  }

  bool get isFinished => animationTime >= duration;

  double get progress => animationTime / duration;

  /// Grosor del rayo actual
  double get currentThickness => 8.0 * (1 - progress);

  double get alpha => math.max(0, 1 - progress);

  /// Glow del rayo
  double get glowIntensity => 1.0 - (progress * 0.7);
}

/// Efecto de explosión de caos
class ChaosExplosionVFX {
  final Vector2 position;
  final double radiusMax;
  double animationTime = 0;
  final double duration = 1.5;
  final List<Vector2> shockWaves = [];

  ChaosExplosionVFX({
    required this.position,
    required this.radiusMax,
  });

  void update(double deltaTime) {
    animationTime += deltaTime;
  }

  bool get isFinished => animationTime >= duration;

  double get progress => animationTime / duration;

  double get alpha => math.max(0, 1 - log(0.001 + progress) / log(0.001));

  /// Cantidad de ondas de choque
  int get shockWaveCount => (progress * 5).toInt();

  double getShockWaveRadiusAt(int index) =>
      radiusMax * (index / shockWaveCount);

  double log(double x) => math.log(x);
}

// ═══════════════════════════════════════════════════════════════
// 🌪️ MANAGER DE VFX
// ═══════════════════════════════════════════════════════════════

class BossVFXManager {
  final Map<String, ParticleEmitter> emitters = {};
  final List<RadialBurstVFX> radialEffects = [];
  final List<SpiralAttackVFX> spiralEffects = [];
  final List<LaserVFX> laserEffects = [];
  final List<ChaosExplosionVFX> chaosEffects = [];

  /// Crear emisor de partículas
  void createEmitter(
    String name, {
    required Color color,
    required double particleSize,
    required int particleCount,
    required double emissionRate,
    required Duration lifetime,
  }) {
    emitters[name] = ParticleEmitter(
      effectName: name,
      particleColor: color,
      particleSize: particleSize,
      particleCount: particleCount,
      emissionRate: emissionRate,
      particleLifetime: lifetime,
    );
  }

  /// Comenzar efecto radial
  void startRadialBurst({
    required Vector2 position,
    required Color color,
    required double radius,
  }) {
    radialEffects.add(
      RadialBurstVFX(position: position, color: color, radius: radius),
    );
  }

  /// Comenzar efecto espiral
  void startSpiralAttack({
    required Vector2 position,
    required Color color,
    required double radiusMax,
  }) {
    spiralEffects.add(
      SpiralAttackVFX(position: position, color: color, radiusMax: radiusMax),
    );
  }

  /// Comenzar efecto láser
  void startLaser({
    required Vector2 start,
    required Vector2 end,
    required Color color,
  }) {
    laserEffects.add(
      LaserVFX(start: start, end: end, color: color),
    );
  }

  /// Comenzar explosión de caos
  void startChaosExplosion({
    required Vector2 position,
    required double radiusMax,
  }) {
    chaosEffects.add(
      ChaosExplosionVFX(position: position, radiusMax: radiusMax),
    );
  }

  /// Emitir partículas radiales
  void emitRadialParticles({
    required String emitterName,
    required Vector2 center,
    required double speed,
    double angle = 0,
  }) {
    emitters[emitterName]?.emitRadial(center, speed, angle);
  }

  /// Emitir partículas en explosión
  void emitExplosion({
    required String emitterName,
    required Vector2 center,
    required double speed,
  }) {
    emitters[emitterName]?.emitExplosion(center, speed);
  }

  /// Emitir partículas en línea
  void emitLine({
    required String emitterName,
    required Vector2 start,
    required Vector2 end,
    required double speed,
  }) {
    emitters[emitterName]?.emitLine(start, end, speed);
  }

  /// Actualizar todos los efectos
  void update(double deltaTime) {
    // Actualizar emisores
    for (var emitter in emitters.values) {
      emitter.update(deltaTime);
    }

    // Actualizar efectos
    radialEffects.removeWhere((e) => e.isFinished);
    for (var effect in radialEffects) {
      effect.update(deltaTime);
    }

    spiralEffects.removeWhere((e) => e.isFinished);
    for (var effect in spiralEffects) {
      effect.update(deltaTime);
    }

    laserEffects.removeWhere((e) => e.isFinished);
    for (var effect in laserEffects) {
      effect.update(deltaTime);
    }

    chaosEffects.removeWhere((e) => e.isFinished);
    for (var effect in chaosEffects) {
      effect.update(deltaTime);
    }
  }

  /// Limpiar todos los efectos
  void clear() {
    for (var emitter in emitters.values) {
      emitter.clear();
    }
    radialEffects.clear();
    spiralEffects.clear();
    laserEffects.clear();
    chaosEffects.clear();
  }

  /// Obtener todas las partículas activas
  List<GameParticle> getAllParticles() {
    final allParticles = <GameParticle>[];
    for (var emitter in emitters.values) {
      allParticles.addAll(emitter.particles);
    }
    return allParticles;
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎯 PRESETS DE VFX POR TIPO DE ATAQUE
// ═══════════════════════════════════════════════════════════════

class BossVFXPresets {
  /// Ataque radial simple
  static void setupRadialAttack(
    BossVFXManager manager, {
    required Vector2 position,
    required Color color,
  }) {
    manager.startRadialBurst(
      position: position,
      color: color,
      radius: 150.0,
    );
    manager.emitRadialParticles(
      emitterName: 'radial_projectiles',
      center: position,
      speed: 200.0,
    );
  }

  /// Ataque en espiral
  static void setupSpiralAttack(
    BossVFXManager manager, {
    required Vector2 position,
    required Color color,
  }) {
    manager.startSpiralAttack(
      position: position,
      color: color,
      radiusMax: 180.0,
    );
    manager.emitRadialParticles(
      emitterName: 'spiral_projectiles',
      center: position,
      speed: 220.0,
      angle: 0.5,
    );
  }

  /// Ataque láser
  static void setupLaserAttack(
    BossVFXManager manager, {
    required Vector2 start,
    required Vector2 end,
    required Color color,
  }) {
    manager.startLaser(
      start: start,
      end: end,
      color: color,
    );
    manager.emitLine(
      emitterName: 'laser_core',
      start: start,
      end: end,
      speed: 100.0,
    );
  }

  /// Explosión de caos
  static void setupChaosExplosion(
    BossVFXManager manager, {
    required Vector2 position,
  }) {
    manager.startChaosExplosion(
      position: position,
      radiusMax: 250.0,
    );
    manager.emitExplosion(
      emitterName: 'chaos_energy',
      center: position,
      speed: 300.0,
    );
    manager.emitExplosion(
      emitterName: 'chaos_fragments',
      center: position,
      speed: 250.0,
    );
  }
}
