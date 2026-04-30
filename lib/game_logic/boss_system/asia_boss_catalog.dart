// Catálogo completo de 5 bosses de Asia
// Integración de Danmaku patterns avanzados con sistema existente de bosses

import 'package:flutter/material.dart';
import 'boss.dart';
import 'boss_phase.dart';
import '../enemy_system/attack_pattern.dart';
import '../enemy_system/enemy_behavior.dart';
import '../enemy_system/danmaku_pattern.dart';
import '../enemy_system/enemy_state_machine.dart';

/// Catálogo mejorado con los 5 bosses de Asia basados en Danmaku
class AsiaBossCatalog {
  /// Obtiene todos los bosses de Asia
  static List<Boss> getAllBosses() => [
        _createGranDumpling(),
        _createVaporSpirit(),
        _createMotherRoot(),
        _createStoneMonk(),
        _createAncestralDragon(),
      ];

  // ═══════════════════════════════════════════════════════════════
  // 🥟 BOSS 1: GRAN DUMPLING ANCESTRAL
  // ═══════════════════════════════════════════════════════════════

  static Boss _createGranDumpling() {
    return Boss(
      id: 'asia_boss_1_gran_dumpling',
      name: '🥟 Gran Dumpling Ancestral',
      position: Offset.zero,
      maxHp: 250.0,
      phases: [
        // FASE 1: Introducción (100% - 60% HP)
        // Patrón simple radial
        BossPhase(
          id: 'dumpling_p1',
          phaseNumber: 1,
          hpThreshold: 0.6,
          description: '⚔️ Fase 1: Patrón Radial Básico',
          attackSpeedMultiplier: 1.0,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 80.0,
            preferredDistance: 200.0,
          ),
          attackPatterns: [
            // Patrón radial simple
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 1.2,
              bulletSpeed: 180.0,
              bulletDamage: 8.0,
              bulletCount: 8,
            ),
          ],
        ),

        // FASE 2: Aceleración (60% - 0% HP)
        // Patrón radial + dirigido
        BossPhase(
          id: 'dumpling_p2',
          phaseNumber: 2,
          hpThreshold: 0.0,
          description: '🔥 Fase 2: Patrón Mixto Radial + Dirigido',
          attackSpeedMultiplier: 1.4,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 120.0,
            preferredDistance: 150.0,
          ),
          attackPatterns: [
            // Radial más rápido
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.8,
              bulletSpeed: 220.0,
              bulletDamage: 10.0,
              bulletCount: 12,
            ),
            // Abanico dirigido
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.2,
              bulletSpeed: 200.0,
              bulletDamage: 7.0,
              bulletCount: 5,
              spreadAngle: 50.0,
            ),
          ],
        ),
      ],
      // Datos de danmaku (nuevo)
      danmakuPatterns: [
        DanmakuPresets.bossPhase1Radial(),
        DanmakuPresets.bossPhase2Spiral(),
      ],
      abilities: [
        EnemyAbilityPresets.tankShield(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌫️ BOSS 2: ESPÍRITU DE VAPOR
  // ═══════════════════════════════════════════════════════════════
  // Rol: Introduces immunity mechanics and evasion patterns
  // Dificultad: Media
  // Elementos: Agua 💧 + Aire 💨
  // Inspiración: Boss etéreo con fases de invulnerabilidad

  static Boss _createVaporSpirit() {
    return Boss(
      id: 'asia_boss_2_vapor_spirit',
      name: '🌫️ Espíritu de Vapor',
      position: Offset.zero,
      maxHp: 320.0,
      phases: [
        // FASE 1: Corporeal (100% - 60% HP)
        // Patrón espiral con movimiento fluido
        BossPhase(
          id: 'vapor_p1',
          phaseNumber: 1,
          hpThreshold: 0.6,
          description: '💧 Fase 1: Forma Corpórea - Espiral',
          attackSpeedMultiplier: 1.1,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 110.0,
            preferredDistance: 250.0,
          ),
          attackPatterns: [
            // Espiral rotatorio
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.9,
              bulletSpeed: 200.0,
              bulletDamage: 7.0,
              bulletCount: 1,
            ),
          ],
        ),

        // FASE 2: Etérea (60% - 30% HP)
        // Patrón onda senoidal con invocaciones
        BossPhase(
          id: 'vapor_p2',
          phaseNumber: 2,
          hpThreshold: 0.3,
          description: '🌫️ Fase 2: Forma Etérea - Ondas',
          attackSpeedMultiplier: 1.3,
          behavior: Behavior(
            type: BehaviorType.wander,
            speed: 110.0,
          ),
          attackPatterns: [
            // Múltiples patrones simultáneos
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.7,
              bulletSpeed: 190.0,
              bulletDamage: 6.0,
              bulletCount: 3,
              spreadAngle: 30.0,
            ),
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 1.2,
              bulletSpeed: 160.0,
              bulletDamage: 8.0,
              bulletCount: 16,
            ),
          ],
        ),

        // FASE 3: Rugido Final (30% - 0% HP)
        // Patrón caótico con máxima intensidad
        BossPhase(
          id: 'vapor_p3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description: '⚡ Fase 3: Tormenta de Vapor',
          attackSpeedMultiplier: 1.7,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 160.0,
            preferredDistance: 100.0,
          ),
          attackPatterns: [
            // Patrón denso
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.35,
              bulletSpeed: 260.0,
              bulletDamage: 8.0,
              bulletCount: 7,
              spreadAngle: 65.0,
            ),
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.5,
              bulletSpeed: 220.0,
              bulletDamage: 6.0,
              bulletCount: 20,
            ),
          ],
        ),
      ],
      danmakuPatterns: [
        DanmakuPresets.bossPhase2SineWave(),
        DanmakuPresets.bossPhase2Spiral(),
        DanmakuPresets.bossPhase3Laser(),
      ],
      abilities: [
        EnemyAbilityPresets.bossRegenerate(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌿 BOSS 3: RAÍZ MADRE
  // ═══════════════════════════════════════════════════════════════
  // Rol: Mechanics de regeneración y invocación
  // Dificultad: Media-Alta
  // Elementos: Planta 🌱 + Tierra 🧱
  // Inspiración: Boss con ciclo regenerativo

  static Boss _createMotherRoot() {
    return Boss(
      id: 'asia_boss_3_mother_root',
      name: '🌿 Raíz Madre',
      position: Offset.zero,
      maxHp: 380.0,
      phases: [
        // FASE 1: Crecida (100% - 65% HP)
        // Patrones básicos con invocación
        BossPhase(
          id: 'root_p1',
          phaseNumber: 1,
          hpThreshold: 0.65,
          description: '🌱 Fase 1: Enraizamiento - Invoca Espinas',
          attackSpeedMultiplier: 1.0,
          behavior: Behavior(
            type: BehaviorType.stationary,
            speed: 0.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 1.1,
              bulletSpeed: 180.0,
              bulletDamage: 8.0,
              bulletCount: 12,
            ),
          ],
        ),

        // FASE 2: Expansión (65% - 35% HP)
        // Patrones complejos + regeneración
        BossPhase(
          id: 'root_p2',
          phaseNumber: 2,
          hpThreshold: 0.35,
          description: '🌳 Fase 2: Expansión - Múltiples Patrones',
          attackSpeedMultiplier: 1.3,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 80.0,
            preferredDistance: 200.0,
          ),
          attackPatterns: [
            // Radial
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.9,
              bulletSpeed: 210.0,
              bulletDamage: 9.0,
              bulletCount: 16,
            ),
            // Spread dirigido
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.0,
              bulletSpeed: 230.0,
              bulletDamage: 10.0,
              bulletCount: 6,
              spreadAngle: 70.0,
            ),
          ],
        ),

        // FASE 3: Furia Final (35% - 0% HP)
        // Bullet hell total con patrón espiral
        BossPhase(
          id: 'root_p3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description: '🔥 Fase 3: Crecimiento Caótico',
          attackSpeedMultiplier: 1.8,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 120.0,
            preferredDistance: 210.0,
          ),
          attackPatterns: [
            // Patrón radial denso
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.45,
              bulletSpeed: 250.0,
              bulletDamage: 10.0,
              bulletCount: 24,
            ),
            // Patrón spread
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.65,
              bulletSpeed: 220.0,
              bulletDamage: 8.0,
              bulletCount: 8,
              spreadAngle: 80.0,
            ),
          ],
        ),
      ],
      danmakuPatterns: [
        DanmakuPresets.bossPhase1Radial(),
        DanmakuPresets.bossPhase3Explosive(),
        DanmakuPresets.endgameChaos(),
      ],
      abilities: [
        EnemyAbilityPresets.bossRegenerate(),
        EnemyAbilityPresets.eliteSummon(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🧘 BOSS 4: MONJE DE PIEDRA
  // ═══════════════════════════════════════════════════════════════
  // Rol: Advanced patterns and state management
  // Dificultad: Alta
  // Elementos: Tierra 🧱 + Neutral ⚪
  // Inspiración: Boss complejo con 3 fases reales

  static Boss _createStoneMonk() {
    return Boss(
      id: 'asia_boss_4_stone_monk',
      name: '🧘 Monje de Piedra',
      position: Offset.zero,
      maxHp: 440.0,
      phases: [
        // FASE 1: Meditación (100% - 70% HP)
        // Patrones simple pero rápido
        BossPhase(
          id: 'monk_p1',
          phaseNumber: 1,
          hpThreshold: 0.7,
          description: '🧘 Fase 1: Meditación - Patrón Radial Puro',
          attackSpeedMultiplier: 1.1,
          behavior: Behavior(
            type: BehaviorType.stationary,
            speed: 0.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.85,
              bulletSpeed: 210.0,
              bulletDamage: 10.0,
              bulletCount: 12,
            ),
          ],
        ),

        // FASE 2: Despertar (70% - 35% HP)
        // Patrones compuestos con movimiento
        BossPhase(
          id: 'monk_p2',
          phaseNumber: 2,
          hpThreshold: 0.35,
          description: '💪 Fase 2: Despertar - Espiral + Radial',
          attackSpeedMultiplier: 1.5,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 130.0,
            preferredDistance: 200.0,
          ),
          attackPatterns: [
            // Radial rápido
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.55,
              bulletSpeed: 230.0,
              bulletDamage: 9.0,
              bulletCount: 16,
            ),
            // Spread dirigido
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.75,
              bulletSpeed: 260.0,
              bulletDamage: 12.0,
              bulletCount: 3,
              spreadAngle: 45.0,
            ),
          ],
        ),

        // FASE 3: ILUMINACIÓN (35% - 0% HP)
        // BULLET HELL PURO
        BossPhase(
          id: 'monk_p3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description:
              '⚡ Fase 3: Iluminación - BULLET HELL TOTAL (Touhou-mode)',
          attackSpeedMultiplier: 2.0,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 150.0,
            preferredDistance: 110.0,
          ),
          attackPatterns: [
            // Patrón radial maximal
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.35,
              bulletSpeed: 290.0,
              bulletDamage: 12.0,
              bulletCount: 32,
            ),
            // Patrón spread máximo
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.45,
              bulletSpeed: 270.0,
              bulletDamage: 11.0,
              bulletCount: 9,
              spreadAngle: 95.0,
            ),
            // Patrón medio
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.55,
              bulletSpeed: 220.0,
              bulletDamage: 8.0,
              bulletCount: 7,
              spreadAngle: 65.0,
            ),
          ],
        ),
      ],
      danmakuPatterns: [
        DanmakuPresets.bossPhase1Radial(),
        DanmakuPresets.bossPhase2Spiral(),
        DanmakuPresets.endgameChaos(),
      ],
      abilities: [
        EnemyAbilityPresets.tankShield(),
        EnemyAbilityPresets.eliteBerserk(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🐉 BOSS 5: DRAGÓN DE MASA ANCESTRAL (FINAL BOSS)
  // ═══════════════════════════════════════════════════════════════
  // Rol: Ultimate challenge - Touhou final boss level
  // Dificultad: EXTREMA 🔴
  // Elementos: Tierra 🧱 + Master ⚫
  // Inspiración: Touhou final boss com 4 fases e sprites únicos

  static Boss _createAncestralDragon() {
    return Boss(
      id: 'asia_boss_5_ancestral_dragon',
      name: '🐉 Dragón de Masa Ancestral',
      position: Offset.zero,
      maxHp: 560.0,
      phases: [
        // FASE 1: DESPERTAR (100% - 75% HP)
        // Patrón moderado, jugador aprende el patrón
        BossPhase(
          id: 'dragon_p1',
          phaseNumber: 1,
          hpThreshold: 0.75,
          description: '🐉 Fase 1: Despertar - Introducción',
          attackSpeedMultiplier: 1.2,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 110.0,
            preferredDistance: 260.0,
          ),
          attackPatterns: [
            // Radial básico
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 1.05,
              bulletSpeed: 210.0,
              bulletDamage: 12.0,
              bulletCount: 16,
            ),
          ],
        ),

        // FASE 2: FUROR (75% - 50% HP)
        // Patrones compuestos, presión media
        BossPhase(
          id: 'dragon_p2',
          phaseNumber: 2,
          hpThreshold: 0.5,
          description: '🔥 Fase 2: Furor - Patrones Compuestos',
          attackSpeedMultiplier: 1.6,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 130.0,
            preferredDistance: 160.0,
          ),
          attackPatterns: [
            // Radial
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.65,
              bulletSpeed: 230.0,
              bulletDamage: 13.0,
              bulletCount: 20,
            ),
            // Spread
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.85,
              bulletSpeed: 260.0,
              bulletDamage: 14.0,
              bulletCount: 7,
              spreadAngle: 85.0,
            ),
          ],
        ),

        // FASE 3: CAOS (50% - 20% HP)
        // Bullet hell intenso con todos los patrones
        BossPhase(
          id: 'dragon_p3',
          phaseNumber: 3,
          hpThreshold: 0.2,
          description: '⚡ Fase 3: Caos - BULLET HELL SUPREMO',
          attackSpeedMultiplier: 1.9,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 150.0,
            preferredDistance: 190.0,
          ),
          attackPatterns: [
            // Mega radial
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.38,
              bulletSpeed: 270.0,
              bulletDamage: 14.0,
              bulletCount: 32,
            ),
            // Spread máximo
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.48,
              bulletSpeed: 290.0,
              bulletDamage: 15.0,
              bulletCount: 10,
              spreadAngle: 105.0,
            ),
            // Patrón medio adicional
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.58,
              bulletSpeed: 250.0,
              bulletDamage: 12.0,
              bulletCount: 8,
              spreadAngle: 75.0,
            ),
          ],
        ),

        // FASE 4: ÚLTIMA RAMA (20% - 0% HP)
        // Enrage mode - Todo simultaneo, screen shake, caos total
        BossPhase(
          id: 'dragon_p4',
          phaseNumber: 4,
          hpThreshold: 0.0,
          description:
              '🌪️ Fase 4: ÚLTIMA RAMA - ENRAGE TOTAL (Máxima Dificultad)',
          attackSpeedMultiplier: 2.3,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 170.0,
            preferredDistance: 90.0,
          ),
          attackPatterns: [
            // PATRÓN 1: Radial DENSO
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.28,
              bulletSpeed: 310.0,
              bulletDamage: 16.0,
              bulletCount: 40,
            ),
            // PATRÓN 2: Aimed MÚLTIPLE
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.38,
              bulletSpeed: 310.0,
              bulletDamage: 16.0,
              bulletCount: 12,
              spreadAngle: 125.0,
            ),
            // PATRÓN 3: Spread CAÓTICO
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 0.48,
              bulletSpeed: 290.0,
              bulletDamage: 14.0,
              bulletCount: 10,
              spreadAngle: 105.0,
            ),
            // PATRÓN 4: Straight ADICIONAL
            AttackPattern(
              type: AttackPatternType.straight,
              cooldown: 0.38,
              bulletSpeed: 260.0,
              bulletDamage: 12.0,
              bulletCount: 3,
            ),
          ],
        ),
      ],
      danmakuPatterns: [
        DanmakuPresets.bossPhase1Radial(),
        DanmakuPresets.bossPhase2Spiral(),
        DanmakuPresets.bossPhase3Laser(),
        DanmakuPresets.endgameChaos(),
      ],
      abilities: [
        EnemyAbilityPresets.tankShield(),
        EnemyAbilityPresets.eliteBerserk(),
        EnemyAbilityPresets.bossRegenerate(),
        EnemyAbilityPresets.eliteSummon(),
      ],
    );
  }
}

// Nota: Este catálogo se integra con el Boss.dart existente
// asegurando que todas las propiedades sean compatibles.
// Si Boss no tiene 'danmakuPatterns' o 'abilities', agregar:
//
// class Boss {
//   ...
//   final List<DanmakuConfig>? danmakuPatterns;
//   final List<EnemyAbility>? abilities;
// }
