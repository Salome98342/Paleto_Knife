import 'dart:math' as math;
import 'package:flame/components.dart';
import 'touhou_spell_card.dart';
import 'bullet_emitter.dart';
import '../enemy_system/enemy_behavior.dart';

/// Factory que crea bosses tipo Touhou completos
class TouhouBossFactory {
  /// Crear un boss Asia elegante (Touhou-like)
  static TouhouBossDefinition createElegantAsianBoss() {
    return TouhouBossDefinition(
      id: 'elegant_asian_boss',
      name: '✿ 優雅な精 - Espíritu Elegante',
      baseMaxHp: 500.0,
      phases: [
        // FASE 1 (70% HP) - Introducción suave
        _createPhase1Elegant(),
        // FASE 2 (35% HP) - Intensidad media
        _createPhase2Elegant(),
        // FASE 3 (0% HP) - Desesperación final
        _createPhase3Elegant(),
      ],
      arenaSize: Vector2(800, 600),
      bossConstrainArea: Vector2(800, 300), // Superior de la pantalla
    );
  }

  /// Crear boss tropical caribeño (Touhou-like)
  static TouhouBossDefinition createCaribbeanBoss() {
    return TouhouBossDefinition(
      id: 'caribbean_boss',
      name: '☀ Cazador de Tormentas',
      baseMaxHp: 600.0,
      phases: [
        _createPhase1Caribbean(),
        _createPhase2Caribbean(),
        _createPhase3Caribbean(),
      ],
      arenaSize: Vector2(800, 600),
      bossConstrainArea: Vector2(800, 300),
    );
  }

  // ========================
  // FASE 1: ELEGANT ASIAN
  // ========================

  static TouhouBossPhase _createPhase1Elegant() {
    return TouhouBossPhase(
      id: 'elegant_phase_1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: '初段 - Primer Movimiento',
      damageMultiplier: 1.0,
      spellCards: [
        // Non-Spell: Radial simple y lento
        TouhouSpellCard(
          id: 'elegant_1_1_nonspell',
          name: 'Non-Spell: Spiraling Wind',
          type: SpellCardType.nonSpell,
          maxHp: 80.0,
          maxDuration: 25.0,
          description: 'Viento suave en espiral',
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 8,
                  bulletSpeed: 120.0,
                  bulletDamage: 3.0,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.05, // Rota lentamente
                  fireRate: 0.3,
                ),
              ],
              duration: 0,
            ),
          ],
          movementBehavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 60.0,
          ),
          waypointsPattern: [
            (200, 150),
            (600, 150),
            (600, 250),
            (200, 250),
          ],
          pointsReward: 300,
          vfxTriggers: ['wind_spiral'],
        ),

        // Spell Card: Abanico elegante
        TouhouSpellCard(
          id: 'elegant_1_2_spellcard',
          name: 'Spell Card: Elegant Fan',
          type: SpellCardType.spellCard,
          maxHp: 150.0,
          maxDuration: 35.0,
          hpMultiplier: 1.2,
          description: 'Abanico de pétalos letales',
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Abanico apuntado
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 200.0,
                  bulletDamage: 5.0,
                  aimType: 'aimed',
                  spreadAngle: math.pi / 8, // Ángulo abierto
                  fireRate: 0.4,
                  description: 'Dispersión elegante',
                ),
                // Complementario: circular lento
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 100.0,
                  bulletDamage: 2.0,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.08,
                  fireRate: 0.5,
                ),
              ],
              duration: 0,
            ),
          ],
          movementBehavior: Behavior(
            type: BehaviorType.stationary,
            speed: 0.0,
          ),
          pointsReward: 800,
          vfxTriggers: ['petal_burst', 'wind_gust'],
        ),
      ],
    );
  }

  static TouhouBossPhase _createPhase2Elegant() {
    return TouhouBossPhase(
      id: 'elegant_phase_2',
      phaseNumber: 2,
      hpThreshold: 0.35,
      phaseName: '二段 - Segundo Movimiento',
      damageMultiplier: 1.3,
      spellCards: [
        // Spell Card: Mandala elegante
        TouhouSpellCard(
          id: 'elegant_2_1_spellcard',
          name: 'Spell Card: Elegant Mandala',
          type: SpellCardType.spellCard,
          maxHp: 200.0,
          maxDuration: 40.0,
          hpMultiplier: 1.3,
          description: 'Mandala de flores cósmicas',
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Mandala central
                BulletEmitter(
                  bulletCount: 24,
                  bulletSpeed: 180.0,
                  bulletDamage: 4.0,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.12,
                  fireRate: 0.6,
                ),
                // Contra-mandala
                BulletEmitter(
                  bulletCount: 20,
                  bulletSpeed: 120.0,
                  bulletDamage: 3.0,
                  initialAngle: math.pi / 12,
                  aimType: 'static',
                  angleIncrement: -0.10,
                  fireRate: 0.6,
                ),
              ],
              duration: 0,
            ),
          ],
          movementBehavior: Behavior(
            type: BehaviorType.circlePlayer,
            speed: 60.0,
          ),
          pointsReward: 1200,
          vfxTriggers: ['mandala_burst', 'mystic_aura'],
        ),
      ],
    );
  }

  static TouhouBossPhase _createPhase3Elegant() {
    return TouhouBossPhase(
      id: 'elegant_phase_3',
      phaseNumber: 3,
      hpThreshold: 0.0,
      phaseName: '終段 - Movimiento Final',
      damageMultiplier: 1.6,
      spellCards: [
        // Spell Card: Desesperación final
        TouhouSpellCard(
          id: 'elegant_3_1_survival',
          name: 'Spell Card: Final Elegance',
          type: SpellCardType.spellCard,
          maxHp: 300.0,
          maxDuration: 50.0,
          hpMultiplier: 1.5,
          description: 'Última danza antes del final',
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Radial apuntado
                BulletEmitter(
                  bulletCount: 20,
                  bulletSpeed: 250.0,
                  bulletDamage: 6.0,
                  aimType: 'aimed',
                  spreadAngle: math.pi / 12,
                  fireRate: 0.3,
                ),
                // Espiral defensivo
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 140.0,
                  bulletDamage: 4.0,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.15,
                  fireRate: 0.35,
                ),
                // Aleatorio caótico
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 180.0,
                  bulletDamage: 3.0,
                  aimType: 'random',
                  spreadAngle: math.pi / 3,
                  fireRate: 0.4,
                ),
              ],
              duration: 0,
            ),
          ],
          movementBehavior: Behavior(
            type: BehaviorType.wander,
            speed: 100.0,
          ),
          pointsReward: 2000,
          vfxTriggers: ['extreme_burst', 'chaos_vortex', 'final_aura'],
        ),
      ],
    );
  }

  // ========================
  // CARIBBEAN BOSS PHASES
  // ========================

  static TouhouBossPhase _createPhase1Caribbean() {
    return TouhouBossPhase(
      id: 'caribbean_phase_1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: 'Tempestad Inicial',
      damageMultiplier: 1.1,
      spellCards: [
        TouhouSpellCard(
          id: 'caribbean_1_1_nonspell',
          name: 'Non-Spell: Storm Wind',
          type: SpellCardType.nonSpell,
          maxHp: 100.0,
          maxDuration: 25.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 10,
                  bulletSpeed: 150.0,
                  bulletDamage: 3.5,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.04,
                  fireRate: 0.35,
                ),
              ],
              duration: 0,
            ),
          ],
          pointsReward: 350,
          vfxTriggers: ['storm_clouds'],
        ),
        TouhouSpellCard(
          id: 'caribbean_1_2_spellcard',
          name: 'Spell Card: Hurricane Dance',
          type: SpellCardType.spellCard,
          maxHp: 180.0,
          maxDuration: 40.0,
          hpMultiplier: 1.25,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 220.0,
                  bulletDamage: 5.5,
                  aimType: 'aimed',
                  spreadAngle: math.pi / 6,
                  fireRate: 0.45,
                ),
              ],
              duration: 0,
            ),
          ],
          pointsReward: 1000,
          vfxTriggers: ['hurricane_spin'],
        ),
      ],
    );
  }

  static TouhouBossPhase _createPhase2Caribbean() {
    return TouhouBossPhase(
      id: 'caribbean_phase_2',
      phaseNumber: 2,
      hpThreshold: 0.35,
      phaseName: 'Ojo de la Tormenta',
      damageMultiplier: 1.4,
      spellCards: [
        TouhouSpellCard(
          id: 'caribbean_2_1_spellcard',
          name: 'Spell Card: Eye of Hurricane',
          type: SpellCardType.spellCard,
          maxHp: 250.0,
          maxDuration: 45.0,
          hpMultiplier: 1.4,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 28,
                  bulletSpeed: 200.0,
                  bulletDamage: 4.5,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.14,
                  fireRate: 0.5,
                ),
                BulletEmitter(
                  bulletCount: 24,
                  bulletSpeed: 140.0,
                  bulletDamage: 3.5,
                  initialAngle: math.pi / 14,
                  aimType: 'static',
                  angleIncrement: -0.12,
                  fireRate: 0.5,
                ),
              ],
              duration: 0,
            ),
          ],
          pointsReward: 1500,
          vfxTriggers: ['tornado_vortex'],
        ),
      ],
    );
  }

  static TouhouBossPhase _createPhase3Caribbean() {
    return TouhouBossPhase(
      id: 'caribbean_phase_3',
      phaseNumber: 3,
      hpThreshold: 0.0,
      phaseName: 'Furia Total',
      damageMultiplier: 1.7,
      spellCards: [
        TouhouSpellCard(
          id: 'caribbean_3_1_final',
          name: 'Spell Card: Apocalyptic Storm',
          type: SpellCardType.spellCard,
          maxHp: 350.0,
          maxDuration: 55.0,
          hpMultiplier: 1.6,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 24,
                  bulletSpeed: 280.0,
                  bulletDamage: 7.0,
                  aimType: 'aimed',
                  spreadAngle: math.pi / 10,
                  fireRate: 0.3,
                ),
                BulletEmitter(
                  bulletCount: 20,
                  bulletSpeed: 160.0,
                  bulletDamage: 5.0,
                  initialAngle: 0.0,
                  aimType: 'static',
                  angleIncrement: 0.18,
                  fireRate: 0.4,
                ),
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 220.0,
                  bulletDamage: 4.0,
                  aimType: 'random',
                  spreadAngle: math.pi / 2.5,
                  fireRate: 0.35,
                ),
              ],
              duration: 0,
            ),
          ],
          pointsReward: 2500,
          vfxTriggers: ['apocalypse_burst', 'storm_chaos'],
        ),
      ],
    );
  }
}

/// Definición de un boss tipo Touhou
class TouhouBossDefinition {
  final String id;
  final String name;
  final double baseMaxHp;
  final List<TouhouBossPhase> phases;
  final Vector2 arenaSize;
  final Vector2 bossConstrainArea; // Área donde el boss puede moverse

  TouhouBossDefinition({
    required this.id,
    required this.name,
    required this.baseMaxHp,
    required this.phases,
    required this.arenaSize,
    required this.bossConstrainArea,
  });
}
