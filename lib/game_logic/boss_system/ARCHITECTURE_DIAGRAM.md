# Diagrama de Arquitectura - Sistema Touhou Boss

## 🏗️ Estructura General

```
UserInput (Damage)
    ↓
TouhouBossController (Orquestador Principal)
    ├─ state: waiting → transition → active → defeated
    ├─ currentPhaseIndex: 0, 1, 2
    ├─ currentSpellCardIndex: 0, 1, 2
    │
    ├─→ onSpawnBullets(bullets)        → PaletoGame.spawnBullet()
    ├─→ onPhaseChange(phase)           → UI/Audio updates
    ├─→ onSpellCardStart(name)         → Show spell name
    ├─→ onSpellCardComplete()          → Animation
    └─→ onBossDefeated()               → Game over logic
    
    ├─ BossMovementSystem
    │  ├─ currentPosition: Vector2
    │  ├─ waypoints: List<Vector2>
    │  └─ update(deltaTime)
    │
    └─ TouhouBossPhase (3 per boss)
       ├─ phase1: HP 70%-100%
       ├─ phase2: HP 35%-70%
       ├─ phase3: HP 0%-35%
       │
       └─ spellCards: [3 cartas]
          ├─ Card 0: Non-Spell (weak intro)
          ├─ Card 1: Spell Card (strong)
          └─ Card 2: Spell Card (variant)
             │
             └─ BulletEmitterCluster
                ├─ Emitter 1: 12 bullets spiral
                ├─ Emitter 2: 16 bullets aimed
                └─ Emitter 3: 8 bullets random
                   │
                   └─ BulletData (position, angle, speed, damage)
```

## 🔄 Flujo de Update (Game Loop)

```
Frame Start
    ↓
PaletoGame.update(deltaTime)
    ├─ Player movement
    ├─ Enemy update
    │  └─ EnemyComponent.update(deltaTime)
    │     └─ if (isTouhouBoss)
    │        └─ TouhouBossController.update(deltaTime, playerPos)
    │           ├─ Update movement: position = movementSystem.update()
    │           ├─ Check phase threshold: if currentHp < threshold → nextPhase()
    │           ├─ Update current spell card: spellCardTimer += deltaTime
    │           ├─ Generate bullets: bullets = currentEmitter.generateBullets()
    │           └─ Fire onSpawnBullets(bullets) callback
    │
    ├─ Bullets update
    ├─ Collision detection
    │  └─ If bullet hits boss → boss.takeDamage()
    │
    └─ Damage application
       └─ if !isInvulnerable → currentHp -= damage
```

## 📊 Clase: TouhouBossController

```
TouhouBossController
├── Properties
│  ├─ bossDefinition: TouhouBossDefinition
│  ├─ currentPosition: Vector2
│  ├─ currentHp: double
│  ├─ maxHp: double
│  ├─ currentPhaseIndex: int (0, 1, 2)
│  ├─ currentSpellCardIndex: int (0, 1, 2)
│  ├─ state: TouhouBossState (waiting, transition, active, defeated)
│  ├─ isInvulnerable: bool
│  │
│  └─ movementSystem: BossMovementSystem
│
├── Methods
│  ├─ update(deltaTime, playerPos)
│  ├─ takeDamage(damage, damageMultiplier)
│  ├─ _updatePhaseTransition()
│  ├─ _moveToNextPhase()
│  ├─ _updateSpellCard()
│  └─ _moveToNextSpellCard()
│
└── Callbacks
   ├─ onSpawnBullets(List<BulletData>)
   ├─ onPhaseChange(int phaseNumber)
   ├─ onSpellCardStart(String name)
   ├─ onSpellCardComplete()
   └─ onBossDefeated()
```

## 🎴 Clase: TouhouSpellCard

```
TouhouSpellCard
├── Basic Info
│  ├─ id: String
│  ├─ name: String
│  ├─ type: SpellCardType (nonSpell, spellCard, survivalSpell)
│  │
│  ├─ maxHp: double (carte HP independiente)
│  ├─ currentHp: double
│  ├─ maxDuration: double (segundos)
│  ├─ currentDuration: double
│  │
│  └─ isBossInvulnerable: bool (survival spells)
│
├── Bullet Generation
│  └─ bulletEmitterClusters: List<BulletEmitterCluster>
│     └─ [emitters que generan balas]
│
├── Movimiento
│  ├─ movementBehavior: MovementBehavior
│  └─ waypointsPattern: List<Vector2>
│
└── Efectos
   ├─ vfxTriggers: List<String>
   └─ pointsReward: int
```

## ✨ Clase: BulletEmitter

```
BulletEmitter
├── Configuración Balas
│  ├─ bulletCount: int (cuántas por disparo)
│  ├─ bulletSpeed: double (píxeles/segundo)
│  ├─ bulletDamage: double
│  └─ initialAngle: double
│
├── Apuntado
│  ├─ aimType: String ('aimed', 'static', 'random')
│  ├─ spreadAngle: double (abanico)
│  └─ angleIncrement: double (rotación para espiral)
│
├── Cadencia
│  ├─ fireRate: double (segundos entre disparos)
│  └─ fireTimer: double (timer actual)
│
└── Methods
   └─ generateBullets(bossPos, playerPos, deltaTime)
      └─ List<BulletData> (balas a spawnear)
```

## 🚀 Clase: BossMovementSystem

```
BossMovementSystem
├── Posición
│  ├─ position: Vector2 (actualizada cada frame)
│  ├─ waypoints: List<Vector2>
│  └─ currentWaypointIndex: int
│
├── Movimiento
│  ├─ speed: double (píxeles/segundo)
│  ├─ interpolationType: String ('linear', 'bezier', 'bouncy')
│  └─ pauseBetweenWaypoints: double
│
└── Methods
   ├─ update(deltaTime)
   │  └─ position = interpolate(waypoints[current], waypoints[next])
   │
   └─ WaypointGenerator.generate*()
      ├─ generateCircular()     → círculo
      ├─ generateFigure8()      → figura-8
      ├─ generateSideToSide()   → lado a lado
      ├─ generateSpiral()       → espiral
      └─ generateRandom()       → puntos aleatorios
```

## 📈 Flujo de Daño

```
PlayerWeapon fires
    ↓
Collision detected
    ↓
boss.takeDamage(damage, multiplier=1.0)
    ├─ if (isInvulnerable) return
    │  (respeta invulnerabilidad en transiciones)
    │
    ├─ currentHp -= damage × multiplier
    │
    ├─ Check if spell card HP exhausted
    │  └─ if (spellCardHp <= 0) → _moveToNextSpellCard()
    │
    └─ Check if phase threshold crossed
       └─ if (currentHp < nextPhaseThreshold)
          └─ _moveToNextPhase() (invulnerable 1.5s)
```

## 🎯 Transición de Fases

```
Fase 1 (70%-100% HP)
    │
    ├─ Spell Cards 1, 2, 3
    │
    └─ currentHp cruza 70% threshold
       ↓
Transition (state = transition, invulnerable 1.5s)
    ├─ Clear bullets
    ├─ Position reset
    └─ damageMultiplier × 1.3
    ↓
Fase 2 (35%-70% HP)
    │
    ├─ Más emisores, patrones complejos
    │
    └─ currentHp cruza 35% threshold
       ↓
Transition (invulnerable, igual como arriba)
    ↓
Fase 3 (0%-35% HP)
    │
    ├─ Patrones épicos, triple emisores
    │
    └─ currentHp <= 0
       ↓
Final Transition → state = defeated
    ↓
onBossDefeated() callback
```

## 🏭 TouhouBossFactory

```
TouhouBossFactory
├─ static createElegantAsianBoss()
│  └─ Returns TouhouBossDefinition with 3 phases
│     ├─ Phase 1: Elegant Fan patterns
│     ├─ Phase 2: Mandala enhancements
│     └─ Phase 3: Final Elegance triple emitter
│
└─ static createCaribbeanBoss()
   └─ Returns TouhouBossDefinition with 3 phases
      ├─ Phase 1: Wind patterns
      ├─ Phase 2: Double spirals
      └─ Phase 3: Apocalyptic storm

// Para crear nuevo boss:
// 1. Define TouhouBossDefinition
// 2. Add static method in factory
// 3. Call con TouhouBossController(definition, position)
```

## 📱 Integración en EnemyComponent

```
EnemyComponent
├─ spawn(pos, isBoss, bossType)
│  ├─ if (isBoss)
│  │  └─ _initializeTouhouBoss(bossType, pos)
│  │     └─ _touhouController = TouhouBossController(...)
│  │        ├─ onSpawnBullets → _onTouhouBulletsSpawn(bullets)
│  │        ├─ onPhaseChange → game.audioManager.playSound('phase_transition')
│  │        └─ etc.
│  │
│  └─ [normal enemy logic]
│
├─ update(deltaTime)
│  ├─ if (_isTouhouBoss)
│  │  └─ _touhouController!.update(deltaTime, playerPos)
│  │     └─ position = _touhouController!.currentPosition
│  │
│  └─ [normal enemy update]
│
└─ takeDamage(damage)
   ├─ if (_isTouhouBoss)
   │  └─ _touhouController!.takeDamage(damage)
   │
   └─ [normal damage logic]
```

## 🎮 Configuración en PaletoGame

```
PaletoGame
├─ spawnEnemy(type, position, isBoss)
│  ├─ if (isBoss && [ELEGANT_ASIAN, CARIBBEAN].contains(type))
│  │  └─ enemy.spawn(pos, isBoss: true, bossType: 'elegant_asian')
│  │
│  └─ [normal spawn]
│
└─ update(deltaTime)
   ├─ [standard loop]
   │
   └─ [bullets appear when spawned via callback]
```

---

**Nota:** Este diagrama muestra la arquitectura lógica. Para un diagrama de flujo específico de integración, ver `INTEGRATION_STEPS.md`.
