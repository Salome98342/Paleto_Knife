# Crear Bosses Personalizados - Ejemplos Avanzados

**Status**: 💡 Guía de customización  
**Objetivo**: Mostrar cómo crear bosses únicos con patrones propios

---

## 📐 Anatomía de un Boss Touhou

```
TouhouBossDefinition
│
├─ bossName: String
├─ bossDescription: String
├─ maxHp: double
├─ minimumPhases: int
│
├─ phase1: TouhouBossPhase
│  ├─ spellCards[0]: Non-Spell intro
│  ├─ spellCards[1]: Spell Card #1
│  └─ spellCards[2]: Spell Card #2
│
├─ phase2: TouhouBossPhase
│  └─ Cartas más intensas
│
└─ phase3: TouhouBossPhase
   └─ Cartas final boss
```

---

## 🎨 Ejemplo 1: Boss Simple (Principiante)

### Enemigo: "Cerdo de Fuego" 🔥

```dart
TouhouBossDefinition createFirePigBoss() {
  return TouhouBossDefinition(
    bossName: '🔥 Cerdo de Fuego - Testuz Ardiente',
    bossDescription: 'Enemigo introductorio para aprender patrones',
    maxHp: 120.0,
    minimumPhases: 3,
    
    // FASE 1: Simple (fuego recto)
    phase1: TouhouBossPhase(
      id: 'fire_pig_phase1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: 'Fuego Débil',
      damageMultiplier: 1.0,
      spellCards: [
        // Non-Spell: Fuego hacia arriba simple
        TouhouSpellCard(
          id: 'fire_simple_non_spell',
          name: 'Fire Breath',
          type: SpellCardType.nonSpell,
          maxHp: 30.0,
          maxDuration: 10.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 5,
                  bulletSpeed: 150.0,
                  bulletDamage: 2.0,
                  aimType: 'aimed',         // Hacia el jugador
                  spreadAngle: π / 12,      // Abanico pequeño
                  fireRate: 0.5,
                ),
              ],
            ),
          ],
          waypointsPattern: [(400, 150)],   // Quieto
          vfxTriggers: ['fire_burst'],
          pointsReward: 300,
        ),
        
        // Spell Card: Fuego en espiral
        TouhouSpellCard(
          id: 'fire_spiral_spell',
          name: 'Spiral Blaze',
          type: SpellCardType.spellCard,
          maxHp: 80.0,
          maxDuration: 20.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Espiral girando
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 120.0,
                  bulletDamage: 3.0,
                  aimType: 'static',
                  angleIncrement: 0.15,    // ← Key: rotación
                  fireRate: 0.4,
                ),
              ],
            ),
          ],
          waypointsPattern: [
            (400, 150),
            (300, 150),
            (500, 150),
            (400, 150),
          ],
          vfxTriggers: ['spiral_fire'],
          pointsReward: 600,
        ),
        
        // Otra Spell Card: Círculo defensivo
        TouhouSpellCard(
          id: 'fire_circle_spell',
          name: 'Defensive Ring',
          type: SpellCardType.spellCard,
          maxHp: 100.0,
          maxDuration: 25.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 100.0,
                  bulletDamage: 2.0,
                  aimType: 'static',
                  angleIncrement: 0.0,     // Círculo fijo
                  fireRate: 0.5,
                ),
              ],
            ),
          ],
          waypointsPattern: [(400, 150)],
          vfxTriggers: ['flame_ring'],
          pointsReward: 700,
        ),
      ],
    ),
    
    // FASE 2: Moderado
    phase2: TouhouBossPhase(
      id: 'fire_pig_phase2',
      phaseNumber: 2,
      hpThreshold: 0.35,
      phaseName: 'Fuego Medio',
      damageMultiplier: 1.3,                // 30% más daño
      spellCards: [
        // Non-Spell más fuerte
        TouhouSpellCard(
          id: 'fire_intense_non_spell',
          name: 'Inferno Breath',
          type: SpellCardType.nonSpell,
          maxHp: 50.0,
          maxDuration: 12.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 8,
                  bulletSpeed: 200.0,
                  bulletDamage: 4.0,
                  aimType: 'aimed',
                  spreadAngle: π / 6,
                  fireRate: 0.4,
                ),
              ],
            ),
          ],
          waypointsPattern: [(300, 150), (500, 150)],
          vfxTriggers: ['inferno_burst'],
          pointsReward: 400,
        ),
        
        // Dos espirales opuestas (patrón Mandala)
        TouhouSpellCard(
          id: 'fire_double_spiral',
          name: 'Twin Spirals',
          type: SpellCardType.spellCard,
          maxHp: 150.0,
          maxDuration: 30.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Espiral derecha
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 180.0,
                  bulletDamage: 4.0,
                  aimType: 'static',
                  angleIncrement: 0.12,
                  fireRate: 0.35,
                ),
                // Espiral izquierda (ángulo opuesto)
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 180.0,
                  bulletDamage: 4.0,
                  aimType: 'static',
                  angleIncrement: -0.12,
                  fireRate: 0.35,
                ),
              ],
            ),
          ],
          waypointsPattern: [
            (350, 100), (450, 100), (400, 200), (400, 150),
          ],
          vfxTriggers: ['twin_spirals'],
          pointsReward: 900,
        ),
        
        // Patrón Random
        TouhouSpellCard(
          id: 'fire_chaos_spell',
          name: 'Chaos Flames',
          type: SpellCardType.spellCard,
          maxHp: 130.0,
          maxDuration: 28.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Caótico (random)
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 180.0,
                  bulletDamage: 3.0,
                  aimType: 'random',
                  spreadAngle: 2 * π,      // 360° completo
                  fireRate: 0.3,
                ),
                // Apuntado para hacer daño
                BulletEmitter(
                  bulletCount: 6,
                  bulletSpeed: 220.0,
                  bulletDamage: 5.0,
                  aimType: 'aimed',
                  spreadAngle: π / 4,
                  fireRate: 0.5,
                ),
              ],
            ),
          ],
          waypointsPattern: [
            (200, 100), (600, 100), (200, 200), (600, 200),
          ],
          vfxTriggers: ['chaotic_flames'],
          pointsReward: 850,
        ),
      ],
    ),
    
    // FASE 3: Final
    phase3: TouhouBossPhase(
      id: 'fire_pig_phase3',
      phaseNumber: 3,
      hpThreshold: 0.0,
      phaseName: 'INFIERNO TOTAL',
      damageMultiplier: 1.6,                // 60% más daño
      spellCards: [
        // Non-Spell final
        TouhouSpellCard(
          id: 'fire_apocalypse_non_spell',
          name: 'Apocalyptic Fire',
          type: SpellCardType.nonSpell,
          maxHp: 70.0,
          maxDuration: 15.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 10,
                  bulletSpeed: 250.0,
                  bulletDamage: 6.0,
                  aimType: 'aimed',
                  spreadAngle: π / 8,
                  fireRate: 0.25,
                ),
              ],
            ),
          ],
          waypointsPattern: [(400, 150)],
          vfxTriggers: ['apocalypse_fire'],
          pointsReward: 500,
        ),
        
        // Última carta: Triple patrón del caos
        TouhouSpellCard(
          id: 'fire_final_spell',
          name: 'Eternal Inferno',
          type: SpellCardType.spellCard,
          maxHp: 200.0,
          maxDuration: 40.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Espiral rápida
                BulletEmitter(
                  bulletCount: 20,
                  bulletSpeed: 250.0,
                  bulletDamage: 5.0,
                  aimType: 'static',
                  angleIncrement: 0.08,
                  fireRate: 0.3,
                ),
                // Apuntado triple
                BulletEmitter(
                  bulletCount: 15,
                  bulletSpeed: 280.0,
                  bulletDamage: 6.0,
                  aimType: 'aimed',
                  spreadAngle: π / 3,
                  fireRate: 0.2,
                ),
                // Random para impredecible
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 200.0,
                  bulletDamage: 4.0,
                  aimType: 'random',
                  spreadAngle: π / 2,
                  fireRate: 0.4,
                ),
              ],
            ),
          ],
          waypointsPattern: [
            (200, 100), (600, 100), (200, 200), (600, 200),
            (400, 150), (400, 150),
          ],
          vfxTriggers: ['eternal_inferno', 'world_on_fire'],
          pointsReward: 1500,
          isBossInvulnerable: false,
        ),
        
        // Bonus: Survival spell (invulnerable, jugador esquiva)
        TouhouSpellCard(
          id: 'fire_survival_spell',
          name: 'Last Stand',
          type: SpellCardType.survivalSpell,      // ← Key
          maxHp: 0,                                // Sin HP
          maxDuration: 15.0,                       // Tiempo fijo
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 24,
                  bulletSpeed: 200.0,
                  bulletDamage: 3.0,
                  aimType: 'static',
                  angleIncrement: 0.05,
                  fireRate: 0.2,
                ),
              ],
            ),
          ],
          isBossInvulnerable: true,               // ← Key: Boss no recibe daño
          pointsReward: 2000,
        ),
      ],
    ),
  );
}
```

---

## 🌊 Ejemplo 2: Boss Avanzado (Tornado)

```dart
TouhouBossDefinition createTornadoBoss() {
  return TouhouBossDefinition(
    bossName: '💨 Guardián del Tornado',
    bossDescription: 'Boss com patrones circulares avanzados',
    maxHp: 180.0,
    minimumPhases: 3,
    
    phase1: TouhouBossPhase(
      id: 'tornado_phase1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: 'Viento Suave',
      damageMultiplier: 1.0,
      spellCards: [
        // Patrón circular simple
        TouhouSpellCard(
          id: 'tornado_wind_circle',
          name: 'Wind Circle',
          type: SpellCardType.nonSpell,
          maxHp: 50.0,
          maxDuration: 15.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 130.0,
                  bulletDamage: 2.0,
                  aimType: 'static',
                  angleIncrement: 0.0,     // Círculo fijo
                  fireRate: 0.5,
                ),
              ],
            ),
          ],
          // Usar WaypointGenerator para patrón
          waypointsPattern: 
            WaypointGenerator.generateCircular(
              center: Vector2(400, 150),
              radius: 80.0,
              pointCount: 8,
            ),
          vfxTriggers: ['wind_gust'],
          pointsReward: 400,
        ),
        
        // Patrón figura-8
        TouhouSpellCard(
          id: 'tornado_figure8',
          name: 'Infinity Wind',
          type: SpellCardType.spellCard,
          maxHp: 120.0,
          maxDuration: 25.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 150.0,
                  bulletDamage: 3.0,
                  aimType: 'static',
                  angleIncrement: 0.1,
                  fireRate: 0.35,
                ),
              ],
            ),
          ],
          waypointsPattern:
            WaypointGenerator.generateFigure8(
              center: Vector2(400, 150),
              scaleX: 120.0,
              scaleY: 100.0,
              pointCount: 16,
            ),
          vfxTriggers: ['infinity_pattern'],
          pointsReward: 700,
        ),
        
        // Patrón random (caótico)
        TouhouSpellCard(
          id: 'tornado_chaos_wind',
          name: 'Chaos Gust',
          type: SpellCardType.spellCard,
          maxHp: 100.0,
          maxDuration: 20.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 10,
                  bulletSpeed: 200.0,
                  bulletDamage: 4.0,
                  aimType: 'random',
                  spreadAngle: 2 * π,
                  fireRate: 0.4,
                ),
              ],
            ),
          ],
          waypointsPattern:
            WaypointGenerator.generateRandom(
              area: Rect.fromLTRB(250, 100, 550, 200),
              pointCount: 6,
            ),
          vfxTriggers: ['chaotic_wind'],
          pointsReward: 600,
        ),
      ],
    ),
    
    phase2: TouhouBossPhase(
      id: 'tornado_phase2',
      phaseNumber: 2,
      hpThreshold: 0.35,
      phaseName: 'Tormenta',
      damageMultiplier: 1.4,
      spellCards: [
        // Espiral saliente
        TouhouSpellCard(
          id: 'tornado_spiral_expand',
          name: 'Expanding Spiral',
          type: SpellCardType.spellCard,
          maxHp: 150.0,
          maxDuration: 30.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 20,
                  bulletSpeed: 200.0,
                  bulletDamage: 4.0,
                  aimType: 'static',
                  angleIncrement: 0.06,
                  fireRate: 0.3,
                ),
              ],
            ),
          ],
          waypointsPattern:
            WaypointGenerator.generateSpiral(
              center: Vector2(400, 150),
              radiusMin: 30.0,
              radiusMax: 150.0,
              pointCount: 20,
            ),
          vfxTriggers: ['expanding_spiral'],
          pointsReward: 900,
        ),
        
        // Triple patrón
        TouhouSpellCard(
          id: 'tornado_triple_spiral',
          name: 'Triple Vortex',
          type: SpellCardType.spellCard,
          maxHp: 180.0,
          maxDuration: 35.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Espiral 1
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 180.0,
                  bulletDamage: 4.0,
                  aimType: 'static',
                  angleIncrement: 0.12,
                  fireRate: 0.3,
                ),
                // Espiral 2 (opuesta)
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 180.0,
                  bulletDamage: 4.0,
                  aimType: 'static',
                  angleIncrement: -0.12,
                  fireRate: 0.3,
                ),
                // Apuntado rápido
                BulletEmitter(
                  bulletCount: 8,
                  bulletSpeed: 250.0,
                  bulletDamage: 5.0,
                  aimType: 'aimed',
                  spreadAngle: π / 6,
                  fireRate: 0.2,
                ),
              ],
            ),
          ],
          waypointsPattern: [(400, 150)],
          vfxTriggers: ['triple_vortex'],
          pointsReward: 1100,
        ),
        
        // Non-spell más forte
        TouhouSpellCard(
          id: 'tornado_windburst',
          name: 'Violent Burst',
          type: SpellCardType.nonSpell,
          maxHp: 80.0,
          maxDuration: 18.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 220.0,
                  bulletDamage: 5.0,
                  aimType: 'aimed',
                  spreadAngle: π / 4,
                  fireRate: 0.3,
                ),
              ],
            ),
          ],
          waypointsPattern: [(300, 150), (500, 150)],
          vfxTriggers: ['violent_burst'],
          pointsReward: 500,
        ),
      ],
    ),
    
    phase3: TouhouBossPhase(
      id: 'tornado_phase3',
      phaseNumber: 3,
      hpThreshold: 0.0,
      phaseName: 'TORMENTA APOCALÍPTICA',
      damageMultiplier: 1.7,
      spellCards: [
        // Última carta espectacular
        TouhouSpellCard(
          id: 'tornado_final_maelstrom',
          name: 'Eternal Maelstrom',
          type: SpellCardType.spellCard,
          maxHp: 250.0,
          maxDuration: 45.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                // Espiral RAPIDA grande
                BulletEmitter(
                  bulletCount: 24,
                  bulletSpeed: 280.0,
                  bulletDamage: 6.0,
                  aimType: 'static',
                  angleIncrement: 0.04,
                  fireRate: 0.2,
                ),
                // Espiral LENTA pequeña (opuesta)
                BulletEmitter(
                  bulletCount: 16,
                  bulletSpeed: 120.0,
                  bulletDamage: 5.0,
                  aimType: 'static',
                  angleIncrement: -0.15,
                  fireRate: 0.4,
                ),
                // Apuntado máximo
                BulletEmitter(
                  bulletCount: 12,
                  bulletSpeed: 300.0,
                  bulletDamage: 7.0,
                  aimType: 'aimed',
                  spreadAngle: π / 3,
                  fireRate: 0.15,
                ),
              ],
            ),
          ],
          waypointsPattern:
            WaypointGenerator.generateSideToSide(
              startPos: Vector2(400, 150),
              distance: 150.0,
              pointCount: 6,
            ),
          vfxTriggers: ['eternal_maelstrom', 'world_wind'],
          pointsReward: 2000,
        ),
      ],
    ),
  );
}
```

---

## 🔧 Template Genérico

```dart
TouhouBossDefinition createCustomBoss() {
  return TouhouBossDefinition(
    bossName: '🎯 Nombre del Boss',
    bossDescription: 'Descripción',
    maxHp: 150.0,
    minimumPhases: 3,
    
    phase1: TouhouBossPhase(
      id: 'custom_phase1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: 'Fase 1',
      damageMultiplier: 1.0,
      spellCards: [
        // Non-Spell (fácil)
        TouhouSpellCard(
          id: 'custom_non_spell_1',
          name: 'Non-Spell Name',
          type: SpellCardType.nonSpell,
          maxHp: 50.0,
          maxDuration: 10.0,
          bulletEmitterClusters: [
            BulletEmitterCluster(
              emitters: [
                BulletEmitter(
                  bulletCount: 8,
                  bulletSpeed: 150.0,
                  bulletDamage: 2.0,
                  aimType: 'aimed',
                  spreadAngle: π / 6,
                  fireRate: 0.4,
                ),
              ],
            ),
          ],
          waypointsPattern: [(400, 150)],
          vfxTriggers: ['effect_1'],
          pointsReward: 300,
        ),
        
        // Spell Card (difícil)
        // ... copiar estructura anterior ...
      ],
    ),
    
    // phase2 y phase3 similar...
  );
}
```

---

## 📝 Registro de Creación de Bosses

| Boss | Dificultad | Patrones | HP | Creador |
|------|-----------|----------|-----|---------|
| Elegant Asian | 🔴 Alta | Abanico, Espiral | 300 | Sistema |
| Caribbean | 🔴 Alta | Mandala, Caótico | 280 | Sistema |
| Fire Pig | 🟡 Media | Espiral, Círculo | 120 | Documentación |
| Tornado | 🔴 Alta | Figura-8, Espiral | 180 | Documentación |

Puedes registrar tus bosses aquí para mantener track.

---

**Nota**: Si creas un boss especialmente bueno, compártelo para agregarlo a la librería oficial.
