import 'package:flutter/material.dart';
import 'boss.dart';
import 'boss_phase.dart';
import '../enemy_system/attack_pattern.dart';
import '../enemy_system/enemy_behavior.dart';

/// Catálogo de bosses del juego
class BossCatalog {
  static final Map<String, Boss> _bosses = {};

  /// Registra un boss
  static void register(Boss boss) {
    _bosses[boss.id] = boss;
  }

  /// Obtiene un boss por ID
  static Boss? get(String id) => _bosses[id];

  /// Obtiene todos los bosses
  static List<Boss> getAll() => _bosses.values.toList();

  /// Limpia el catálogo
  static void clear() => _bosses.clear();

  /// Inicializa los bosses estándar
  static void initializeDefaults() {
    clear();

    // ============================================================
    // 🌏 ASIA BOSS: Gran Dumpling Ancestral
    // ============================================================
    register(_createGranDumplingAncestral());

    // ============================================================
    // 🌊 CARIBE BOSS: Rey Jerk Volcánico
    // ============================================================
    register(_createReyJerkVolcanico());

    // ============================================================
    // 🌿 EUROPA BOSS: Leviatán de Caldo
    // ============================================================
    register(_createLeviathan());
  }

  /// Gran Dumpling Ancestral - Boss de Asia (Elemento: Tierra)
  /// Counters: 🔥 Fuego, 🌋 Lava, 🌱 Planta
  static Boss _createGranDumplingAncestral() {
    return Boss(
      id: 'gran_dumpling_ancestral',
      name: 'Gran Dumpling Ancestral',
      position: Offset.zero,
      maxHp: 500.0,
      phases: [
        // FASE 1: Invocación (100% - 70% HP)
        BossPhase(
          id: 'dumpling_phase_1',
          phaseNumber: 1,
          hpThreshold: 0.7,
          description: 'Invocación - Se posiciona y comienza a invocar espíritus',
          attackSpeedMultiplier: 1.0,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 100.0,
            preferredDistance: 150.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.straight,
              cooldown: 1.5,
              bulletSpeed: 200.0,
              bulletDamage: 15.0,
              bulletCount: 2,
            ),
          ],
        ),

        // FASE 2: Armadura (70% - 30% HP)
        BossPhase(
          id: 'dumpling_phase_2',
          phaseNumber: 2,
          hpThreshold: 0.3,
          description: 'Armadura - Se endurece y ataca más frecuentemente',
          attackSpeedMultiplier: 1.5,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 120.0,
            preferredDistance: 120.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.0,
              bulletSpeed: 250.0,
              bulletDamage: 18.0,
              bulletCount: 4,
              spreadAngle: 60.0,
            ),
          ],
        ),

        // FASE 3: Ondas de choque (30% - 0% HP)
        BossPhase(
          id: 'dumpling_phase_3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description: 'Despertar Total - Genera ondas de choque devastadoras',
          attackSpeedMultiplier: 2.0,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 150.0,
            preferredDistance: 100.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.7,
              bulletSpeed: 300.0,
              bulletDamage: 20.0,
              bulletCount: 8,
            ),
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.5,
              bulletSpeed: 280.0,
              bulletDamage: 16.0,
              bulletCount: 1,
            ),
          ],
        ),
      ],
    );
  }

  /// Rey Jerk Volcánico - Boss del Caribe (Elemento: Fuego)
  /// Counters: 💧 Agua, 💨 Viento
  static Boss _createReyJerkVolcanico() {
    return Boss(
      id: 'rey_jerk_volcanico',
      name: 'Rey Jerk Volcánico',
      position: Offset.zero,
      maxHp: 480.0,
      phases: [
        // FASE 1: Melee (100% - 60% HP)
        BossPhase(
          id: 'jerk_phase_1',
          phaseNumber: 1,
          hpThreshold: 0.6,
          description: 'Furia - Se acerca y ataca directamente',
          attackSpeedMultiplier: 1.0,
          behavior: Behavior(
            type: BehaviorType.chase,
            speed: 160.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.straight,
              cooldown: 0.8,
              bulletSpeed: 320.0,
              bulletDamage: 17.0,
              bulletCount: 1,
            ),
          ],
        ),

        // FASE 2: Proyectiles (60% - 30% HP)
        BossPhase(
          id: 'jerk_phase_2',
          phaseNumber: 2,
          hpThreshold: 0.3,
          description: 'Inferno - Lanza torrentes de fuego',
          attackSpeedMultiplier: 1.4,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 140.0,
            preferredDistance: 180.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.1,
              bulletSpeed: 280.0,
              bulletDamage: 19.0,
              bulletCount: 6,
              spreadAngle: 70.0,
            ),
          ],
        ),

        // FASE 3: Explosiones (30% - 0% HP)
        BossPhase(
          id: 'jerk_phase_3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description: 'Combustión Total - Explosiones simultáneas',
          attackSpeedMultiplier: 1.8,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 170.0,
            preferredDistance: 140.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.6,
              bulletSpeed: 260.0,
              bulletDamage: 22.0,
              bulletCount: 10,
            ),
            AttackPattern(
              type: AttackPatternType.aimed,
              cooldown: 0.8,
              bulletSpeed: 300.0,
              bulletDamage: 18.0,
              bulletCount: 2,
            ),
          ],
        ),
      ],
    );
  }

  /// Leviatán de Caldo - Boss de Europa (Elemento: Agua)
  /// Counters: 🌱 Planta, 🌋 Lava
  static Boss _createLeviathan() {
    return Boss(
      id: 'leviathan_caldo',
      name: 'Leviatán de Caldo',
      position: Offset.zero,
      maxHp: 520.0,
      phases: [
        // FASE 1: Ondas (100% - 65% HP)
        BossPhase(
          id: 'leviathan_phase_1',
          phaseNumber: 1,
          hpThreshold: 0.65,
          description: 'Mareas - Lanza ondas de agua controladas',
          attackSpeedMultiplier: 0.9,
          behavior: Behavior(
            type: BehaviorType.keepDistance,
            speed: 110.0,
            preferredDistance: 170.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.straight,
              cooldown: 2.0,
              bulletSpeed: 220.0,
              bulletDamage: 16.0,
              bulletCount: 3,
            ),
          ],
        ),

        // FASE 2: División (65% - 30% HP)
        BossPhase(
          id: 'leviathan_phase_2',
          phaseNumber: 2,
          hpThreshold: 0.3,
          description: 'Fragmentación - Se divide en múltiples partes que atacan',
          attackSpeedMultiplier: 1.3,
          behavior: Behavior(
            type: BehaviorType.wander,
            speed: 130.0,
            acceleration: 60.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.2,
              bulletSpeed: 270.0,
              bulletDamage: 17.0,
              bulletCount: 5,
              spreadAngle: 50.0,
            ),
          ],
        ),

        // FASE 3: Inundación (30% - 0% HP)
        BossPhase(
          id: 'leviathan_phase_3',
          phaseNumber: 3,
          hpThreshold: 0.0,
          description: 'Diluvio - Lluvia de proyectiles en todas direcciones',
          attackSpeedMultiplier: 1.7,
          behavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 150.0,
            preferredDistance: 130.0,
          ),
          attackPatterns: [
            AttackPattern(
              type: AttackPatternType.radial,
              cooldown: 0.7,
              bulletSpeed: 290.0,
              bulletDamage: 20.0,
              bulletCount: 12,
            ),
            AttackPattern(
              type: AttackPatternType.spread,
              cooldown: 1.0,
              bulletSpeed: 250.0,
              bulletDamage: 15.0,
              bulletCount: 6,
              spreadAngle: 80.0,
            ),
          ],
        ),
      ],
    );
  }
}
