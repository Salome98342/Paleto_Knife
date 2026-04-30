// Sistema de visuales para bosses - Sprites, animaciones y partículas
// Integración con Flame para renderizado de bosses asiáticos

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// 🎨 CONFIGURACIÓN DE SPRITES POR BOSS
// ═══════════════════════════════════════════════════════════════

/// Datos de sprite para cada boss
class BossSpriteConfig {
  final String bossId;
  final String spritePath;
  final Vector2 spriteSize;
  final int animationFrames;
  final List<BossPhaseVisual> phaseVisuals;
  final Color primaryColor;
  final String characterName;

  BossSpriteConfig({
    required this.bossId,
    required this.spritePath,
    required this.spriteSize,
    required this.animationFrames,
    required this.phaseVisuals,
    required this.primaryColor,
    required this.characterName,
  });
}

/// Datos visuales específicos por fase del boss
class BossPhaseVisual {
  final int phaseNumber;
  final String? spriteVariant;
  final Color phaseColor;
  final double animationSpeed;
  final String attackVFXType;
  final List<ParticleEffectConfig> particleEffects;

  BossPhaseVisual({
    required this.phaseNumber,
    this.spriteVariant,
    required this.phaseColor,
    required this.animationSpeed,
    required this.attackVFXType,
    required this.particleEffects,
  });
}

/// Configuración de efectos de partículas
class ParticleEffectConfig {
  final String effectName;
  final Color particleColor;
  final double particleSize;
  final int particleCount;
  final double emissionRate;
  final Duration particleLifetime;

  ParticleEffectConfig({
    required this.effectName,
    required this.particleColor,
    required this.particleSize,
    required this.particleCount,
    required this.emissionRate,
    required this.particleLifetime,
  });
}

// ═══════════════════════════════════════════════════════════════
// 🎯 PRESETS DE VISUALES POR BOSS
// ═══════════════════════════════════════════════════════════════

class BossSpritePresets {
  // 🥟 GRAN DUMPLING
  static BossSpriteConfig granDumpling() {
    return BossSpriteConfig(
      bossId: 'asia_boss_1_gran_dumpling',
      spritePath: 'lib/assets/bosses/gran_dumpling/sprite.png',
      spriteSize: Vector2(128, 128),
      animationFrames: 8,
      characterName: 'Gran Dumpling Ancestral',
      primaryColor: Colors.orange,
      phaseVisuals: [
        // Fase 1: Color naranja suave
        BossPhaseVisual(
          phaseNumber: 1,
          spriteVariant: null, // Mismo sprite
          phaseColor: Colors.orange,
          animationSpeed: 0.1,
          attackVFXType: 'radial_burst',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'radial_projectiles',
              particleColor: Colors.orange,
              particleSize: 8.0,
              particleCount: 8,
              emissionRate: 1.2,
              particleLifetime: Duration(milliseconds: 1500),
            ),
          ],
        ),
        // Fase 2: Color naranja intenso + rojo
        BossPhaseVisual(
          phaseNumber: 2,
          spriteVariant: 'phase2_angry',
          phaseColor: Colors.red,
          animationSpeed: 0.15,
          attackVFXType: 'spiral_burst',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'spiral_projectiles',
              particleColor: Colors.deepOrange,
              particleSize: 10.0,
              particleCount: 12,
              emissionRate: 0.8,
              particleLifetime: Duration(milliseconds: 1800),
            ),
            ParticleEffectConfig(
              effectName: 'phase_transition',
              particleColor: Colors.yellow,
              particleSize: 6.0,
              particleCount: 20,
              emissionRate: 2.0,
              particleLifetime: Duration(milliseconds: 800),
            ),
          ],
        ),
      ],
    );
  }

  // 🌫️ VAPOR SPIRIT
  static BossSpriteConfig vaporSpirit() {
    return BossSpriteConfig(
      bossId: 'asia_boss_2_vapor_spirit',
      spritePath: 'lib/assets/bosses/vapor_spirit/sprite.png',
      spriteSize: Vector2(120, 140),
      animationFrames: 10,
      characterName: 'Espíritu de Vapor',
      primaryColor: Colors.blueGrey,
      phaseVisuals: [
        // Fase 1: Forma corpórea, azul suave
        BossPhaseVisual(
          phaseNumber: 1,
          spriteVariant: null,
          phaseColor: Colors.cyan,
          animationSpeed: 0.12,
          attackVFXType: 'wave_pattern',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'water_spray',
              particleColor: Colors.cyan,
              particleSize: 6.0,
              particleCount: 10,
              emissionRate: 0.9,
              particleLifetime: Duration(milliseconds: 1600),
            ),
          ],
        ),
        // Fase 2: Forma etérea, bruma azul
        BossPhaseVisual(
          phaseNumber: 2,
          spriteVariant: 'phase2_ethereal',
          phaseColor: Colors.blue,
          animationSpeed: 0.14,
          attackVFXType: 'ethereal_waves',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'ethereal_mist',
              particleColor: Colors.blue.withValues(alpha: 0.6),
              particleSize: 12.0,
              particleCount: 15,
              emissionRate: 1.2,
              particleLifetime: Duration(milliseconds: 2000),
            ),
          ],
        ),
        // Fase 3: Tormenta, azul oscuro + electricidad
        BossPhaseVisual(
          phaseNumber: 3,
          spriteVariant: 'phase3_storm',
          phaseColor: Colors.indigo,
          animationSpeed: 0.18,
          attackVFXType: 'lightning_burst',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'lightning_arcs',
              particleColor: Colors.yellowAccent,
              particleSize: 4.0,
              particleCount: 25,
              emissionRate: 1.5,
              particleLifetime: Duration(milliseconds: 1200),
            ),
            ParticleEffectConfig(
              effectName: 'storm_winds',
              particleColor: Colors.indigo,
              particleSize: 8.0,
              particleCount: 12,
              emissionRate: 0.8,
              particleLifetime: Duration(milliseconds: 1500),
            ),
          ],
        ),
      ],
    );
  }

  // 🌿 MADRE RAÍZ
  static BossSpriteConfig motherRoot() {
    return BossSpriteConfig(
      bossId: 'asia_boss_3_mother_root',
      spritePath: 'lib/assets/bosses/mother_root/sprite.png',
      spriteSize: Vector2(140, 150),
      animationFrames: 12,
      characterName: 'Raíz Madre',
      primaryColor: Colors.green,
      phaseVisuals: [
        // Fase 1: Enraizado, verde natural
        BossPhaseVisual(
          phaseNumber: 1,
          spriteVariant: null,
          phaseColor: Colors.green,
          animationSpeed: 0.08,
          attackVFXType: 'root_spread',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'root_thorns',
              particleColor: Colors.green,
              particleSize: 8.0,
              particleCount: 12,
              emissionRate: 1.0,
              particleLifetime: Duration(milliseconds: 1700),
            ),
          ],
        ),
        // Fase 2: Expansión, verde oscuro + marrón
        BossPhaseVisual(
          phaseNumber: 2,
          spriteVariant: 'phase2_expanded',
          phaseColor: Colors.teal,
          animationSpeed: 0.12,
          attackVFXType: 'vine_whip',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'vine_growth',
              particleColor: Colors.teal,
              particleSize: 10.0,
              particleCount: 14,
              emissionRate: 1.1,
              particleLifetime: Duration(milliseconds: 1900),
            ),
            ParticleEffectConfig(
              effectName: 'earth_dust',
              particleColor: Colors.brown,
              particleSize: 6.0,
              particleCount: 8,
              emissionRate: 0.7,
              particleLifetime: Duration(milliseconds: 1300),
            ),
          ],
        ),
        // Fase 3: Caos, verde neon + rojo
        BossPhaseVisual(
          phaseNumber: 3,
          spriteVariant: 'phase3_corrupted',
          phaseColor: Colors.lime,
          animationSpeed: 0.16,
          attackVFXType: 'chaos_explosion',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'chaos_energy',
              particleColor: Colors.lime,
              particleSize: 12.0,
              particleCount: 20,
              emissionRate: 1.4,
              particleLifetime: Duration(milliseconds: 1600),
            ),
            ParticleEffectConfig(
              effectName: 'corruption_aura',
              particleColor: Colors.red,
              particleSize: 8.0,
              particleCount: 10,
              emissionRate: 0.9,
              particleLifetime: Duration(milliseconds: 1400),
            ),
          ],
        ),
      ],
    );
  }

  // 🧘 MONJE DE PIEDRA
  static BossSpriteConfig stoneMonk() {
    return BossSpriteConfig(
      bossId: 'asia_boss_4_stone_monk',
      spritePath: 'lib/assets/bosses/stone_monk/sprite.png',
      spriteSize: Vector2(110, 145),
      animationFrames: 9,
      characterName: 'Monje de Piedra',
      primaryColor: Colors.grey,
      phaseVisuals: [
        // Fase 1: Meditación, gris sereno
        BossPhaseVisual(
          phaseNumber: 1,
          spriteVariant: null,
          phaseColor: Colors.grey,
          animationSpeed: 0.06,
          attackVFXType: 'meditation_aura',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'stone_aura',
              particleColor: Colors.grey,
              particleSize: 7.0,
              particleCount: 8,
              emissionRate: 0.8,
              particleLifetime: Duration(milliseconds: 1400),
            ),
          ],
        ),
        // Fase 2: Despertar, gris + dorado
        BossPhaseVisual(
          phaseNumber: 2,
          spriteVariant: 'phase2_awakened',
          phaseColor: Colors.amber,
          animationSpeed: 0.11,
          attackVFXType: 'ki_burst',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'ki_energy',
              particleColor: Colors.amber,
              particleSize: 9.0,
              particleCount: 16,
              emissionRate: 1.2,
              particleLifetime: Duration(milliseconds: 1700),
            ),
            ParticleEffectConfig(
              effectName: 'stone_fragments',
              particleColor: Colors.grey,
              particleSize: 6.0,
              particleCount: 12,
              emissionRate: 1.0,
              particleLifetime: Duration(milliseconds: 1200),
            ),
          ],
        ),
        // Fase 3: Iluminación, dorado brillante
        BossPhaseVisual(
          phaseNumber: 3,
          spriteVariant: 'phase3_enlightened',
          phaseColor: Colors.yellow,
          animationSpeed: 0.14,
          attackVFXType: 'enlightenment_blast',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'enlightenment_light',
              particleColor: Colors.yellow,
              particleSize: 11.0,
              particleCount: 24,
              emissionRate: 1.5,
              particleLifetime: Duration(milliseconds: 1500),
            ),
            ParticleEffectConfig(
              effectName: 'spiritual_energy',
              particleColor: Colors.white,
              particleSize: 5.0,
              particleCount: 16,
              emissionRate: 1.3,
              particleLifetime: Duration(milliseconds: 1300),
            ),
          ],
        ),
      ],
    );
  }

  // 🐉 DRAGÓN ANCESTRAL
  static BossSpriteConfig ancestralDragon() {
    return BossSpriteConfig(
      bossId: 'asia_boss_5_ancestral_dragon',
      spritePath: 'lib/assets/bosses/ancestral_dragon/sprite.png',
      spriteSize: Vector2(160, 200),
      animationFrames: 14,
      characterName: 'Dragón de Masa Ancestral',
      primaryColor: Colors.deepPurple,
      phaseVisuals: [
        // Fase 1: Despertar, púrpura suave
        BossPhaseVisual(
          phaseNumber: 1,
          spriteVariant: null,
          phaseColor: Colors.purple,
          animationSpeed: 0.10,
          attackVFXType: 'ancient_breath',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'ancience_mist',
              particleColor: Colors.purple,
              particleSize: 9.0,
              particleCount: 14,
              emissionRate: 1.0,
              particleLifetime: Duration(milliseconds: 1800),
            ),
          ],
        ),
        // Fase 2: Furor, púrpura oscuro + rojo
        BossPhaseVisual(
          phaseNumber: 2,
          spriteVariant: 'phase2_enraged',
          phaseColor: Colors.deepOrange,
          animationSpeed: 0.13,
          attackVFXType: 'dragon_fire',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'fire_breath',
              particleColor: Colors.deepOrange,
              particleSize: 11.0,
              particleCount: 18,
              emissionRate: 1.2,
              particleLifetime: Duration(milliseconds: 1900),
            ),
            ParticleEffectConfig(
              effectName: 'smoke_cloud',
              particleColor: Colors.grey,
              particleSize: 12.0,
              particleCount: 10,
              emissionRate: 0.8,
              particleLifetime: Duration(milliseconds: 1600),
            ),
          ],
        ),
        // Fase 3: Caos, rojo neon + negro
        BossPhaseVisual(
          phaseNumber: 3,
          spriteVariant: 'phase3_chaos',
          phaseColor: Colors.red,
          animationSpeed: 0.15,
          attackVFXType: 'chaos_maelstrom',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'chaos_vortex',
              particleColor: Colors.red,
              particleSize: 13.0,
              particleCount: 28,
              emissionRate: 1.6,
              particleLifetime: Duration(milliseconds: 1700),
            ),
            ParticleEffectConfig(
              effectName: 'dark_energy',
              particleColor: Colors.black87,
              particleSize: 7.0,
              particleCount: 16,
              emissionRate: 1.2,
              particleLifetime: Duration(milliseconds: 1400),
            ),
          ],
        ),
        // Fase 4: Enrage total, multicolor caótico
        BossPhaseVisual(
          phaseNumber: 4,
          spriteVariant: 'phase4_ultimate',
          phaseColor: Colors.white,
          animationSpeed: 0.18,
          attackVFXType: 'ultimate_chaos',
          particleEffects: [
            ParticleEffectConfig(
              effectName: 'ultimate_explosion',
              particleColor: Colors.white,
              particleSize: 15.0,
              particleCount: 32,
              emissionRate: 1.8,
              particleLifetime: Duration(milliseconds: 1800),
            ),
            ParticleEffectConfig(
              effectName: 'reality_rupture',
              particleColor: Colors.cyan,
              particleSize: 10.0,
              particleCount: 20,
              emissionRate: 1.5,
              particleLifetime: Duration(milliseconds: 1600),
            ),
            ParticleEffectConfig(
              effectName: 'ancient_power',
              particleColor: Colors.purple,
              particleSize: 8.0,
              particleCount: 16,
              emissionRate: 1.4,
              particleLifetime: Duration(milliseconds: 1500),
            ),
          ],
        ),
      ],
    );
  }

  /// Obtiene todas las configuraciones de sprites
  static List<BossSpriteConfig> getAllConfigs() => [
        granDumpling(),
        vaporSpirit(),
        motherRoot(),
        stoneMonk(),
        ancestralDragon(),
      ];

  /// Obtiene configuración por ID de boss
  static BossSpriteConfig? getConfigById(String bossId) {
    try {
      return getAllConfigs().firstWhere((config) => config.bossId == bossId);
    } catch (e) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎬 SISTEMA DE ANIMACIÓN DE BOSSES
// ═══════════════════════════════════════════════════════════════

/// Manager para animaciones y efectos visuales de bosses
class BossVisualManager {
  final String bossId;
  late BossSpriteConfig spriteConfig;
  late BossPhaseVisual currentPhaseVisual;
  int currentPhase = 1;
  int currentFrame = 0;
  double animationAccumulator = 0.0;

  BossVisualManager(this.bossId) {
    spriteConfig = BossSpritePresets.getConfigById(bossId) ??
        BossSpritePresets.granDumpling();
    currentPhaseVisual = spriteConfig.phaseVisuals[0];
  }

  /// Transición a una nueva fase
  void transitionToPhase(int phaseNumber) {
    if (phaseNumber > 0 && phaseNumber <= spriteConfig.phaseVisuals.length) {
      currentPhase = phaseNumber;
      currentPhaseVisual = spriteConfig.phaseVisuals[phaseNumber - 1];
      currentFrame = 0;
      animationAccumulator = 0.0;
    }
  }

  /// Actualiza la animación (llamar cada frame)
  void update(double deltaTime) {
    animationAccumulator += deltaTime;
    final frameDuration = 1.0 / (currentPhaseVisual.animationSpeed * 60.0);

    if (animationAccumulator >= frameDuration) {
      currentFrame =
          (currentFrame + 1) % spriteConfig.animationFrames;
      animationAccumulator = 0.0;
    }
  }

  /// Obtiene el color de la fase actual
  Color getPhaseColor() => currentPhaseVisual.phaseColor;

  /// Obtiene el tipo de efecto VFX
  String getAttackVFXType() => currentPhaseVisual.attackVFXType;

  /// Obtiene los efectos de partículas
  List<ParticleEffectConfig> getParticleEffects() =>
      currentPhaseVisual.particleEffects;
}
