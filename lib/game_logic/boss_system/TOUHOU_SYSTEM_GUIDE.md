# Sistema de Jefes Tipo Touhou - Guía Completa

**Fecha**: 2026-04-12  
**Status**: ✅ Sistema completo implementado  
**Complejidad**: Alto - Patrones avanzados de Touhou

---

## 📚 Descripción General

Este sistema transforma los bosses del juego en experiencias tipo Touhou (bullet-hell) completamente sofisticadas:

- **3 Fases** por boss con dificultad escalable
- **Spell Cards** (cartas de hechizo) vs **Non-Spells** (ataques normales)
- **Emisores de Balas Matemáticos** con patrones complejos
- **Movimiento Inteligente** con waypoints y easing
- **Estados Dinámicos** con transiciones suaves

---

## 🎯 Componentes Principales

### 1. **BulletEmitter** (`bullet_emitter.dart`)

Define **un único emisor de balas** con lógica matemática.

```dart
BulletEmitter(
  bulletCount: 12,        // Balas por disparo
  bulletSpeed: 200.0,     // Píxeles/segundo
  bulletDamage: 5.0,      // Daño por bala
  initialAngle: 0.0,      // Ángulo inicial (radianes)
  aimType: 'aimed',       // 'aimed', 'static', 'random'
  spreadAngle: π/6,       // Ángulo de dispersión
  angleIncrement: 0.05,   // Rotación por ciclo (para espirales)
  fireRate: 0.3,          // Segundos entre disparos
);
```

#### Tipos de Apuntado:
- **`'aimed'`**: Calcula vector hacia jugador, dispara en abanico
- **`'static'`**: Ángulos predefinidos (círculo completo)
- **`'random'`**: RNG dentro de spread (impredecible)

#### Ejemplos Prácticos:

```dart
// Patrón: Espiral que rota (Touhou clásico)
BulletEmitter(
  bulletCount: 16,
  bulletSpeed: 150.0,
  aimType: 'static',
  angleIncrement: 0.1,    // ← Rotación key
  fireRate: 0.4,
)

// Patrón: Abanico apuntado
BulletEmitter(
  bulletCount: 12,
  bulletSpeed: 200.0,
  aimType: 'aimed',       // ← Apunta al jugador
  spreadAngle: π/8,       // ← Abanico abierto
  fireRate: 0.35,
)

// Patrón: Mandala (dos espirales opuestas)
// Se usa en BulletEmitterCluster con dos emitters:
BulletEmitterCluster(
  emitters: [
    // Espiral 1: Rotación positiva
    BulletEmitter(..., angleIncrement: 0.12),
    // Espiral 2: Rotación negativa
    BulletEmitter(..., angleIncrement: -0.10),
  ],
)
```

---

### 2. **TouhouSpellCard** (`touhou_spell_card.dart`)

Define una **Carta de Hechizo** (un ataque/patrón completo).

```dart
TouhouSpellCard(
  id: 'elegant_fan_spell',
  name: 'Spell Card: Elegant Fan',
  type: SpellCardType.spellCard,    // spellCard, nonSpell, survivalSpell
  maxHp: 150.0,                     // HP de esta carta
  maxDuration: 35.0,                // Segundos (0 = infinito)
  bulletEmitterClusters: [
    BulletEmitterCluster(...),
  ],
  movementBehavior: Behavior(...),  // Cómo se mueve el boss
  waypointsPattern: [(200, 150), (600, 150)], // Ruta opcional
  pointsReward: 800,
  vfxTriggers: ['petal_burst'],     // FX a disparar
  isBossInvulnerable: false,        // ¿Resistente el boss?
);
```

#### Tipos de Carta:
- **`nonSpell`**: Ataque normal (bajo HP, bajo daño, corta duración)
- **`spellCard`**: Ataque principal (alto HP, alto daño, larga duración)
- **`survivalSpell`**: Boss invulnerable, jugador esquiva tiempo

---

### 3. **TouhouBossPhase** (`touhou_spell_card.dart`)

Define una **Fase Completa del Boss** (colección de Spell Cards).

```dart
TouhouBossPhase(
  id: 'elegant_phase_1',
  phaseNumber: 1,
  hpThreshold: 0.70,  // Comienza al 70% de HP
  phaseName: '初段 - Primer Movimiento',
  damageMultiplier: 1.0,  // Boss hace 1x daño
  spellCards: [
    TouhouSpellCard(...),   // Non-Spell
    TouhouSpellCard(...),   // Spell Card #1
    TouhouSpellCard(...),   // Spell Card #2
  ],
)
```

---

### 4. **BossMovementSystem** (`boss_movement.dart`)

Maneja **movimiento inteligente con waypoints**.

```dart
BossMovementSystem(
  position: Vector2(400, 150),
  waypoints: [Vector2(200, 150), Vector2(600, 150)],
  speed: 100.0,                    // Píxeles/segundo
  pauseBetweenWaypoints: 0.5,      // Segundos en cada waypoint
  interpolationType: 'bezier',     // 'linear', 'bezier', 'bouncy'
)
```

#### WaypointGenerator - Generar Patrones:

```dart
// Círculo
WaypointGenerator.generateCircular(
  center: Vector2(400, 150),
  radius: 100.0,
  pointCount: 8,
)

// Figura-8
WaypointGenerator.generateFigure8(
  center: Vector2(400, 150),
  scaleX: 150.0,
  scaleY: 100.0,
  pointCount: 16,
)

// Lado a lado
WaypointGenerator.generateSideToSide(
  startPos: Vector2(400, 150),
  distance: 150.0,
  pointCount: 4,
)

// Espiral
WaypointGenerator.generateSpiral(
  center: Vector2(400, 150),
  radiusMin: 50.0,
  radiusMax: 200.0,
  pointCount: 24,
)
```

---

### 5. **TouhouBossController** (`touhou_boss_controller.dart`)

**Orquestador principal** que maneja todo.

```dart
// Crear boss
final boss = TouhouBossController(
  bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
  position: Vector2(400, 150),
);

// Callbacks
boss.onPhaseChange = (phaseNum) {
  print('🔄 Fase $phaseNum iniciada!');
};

boss.onSpellCardStart = (name) {
  print('✨ Spell Card: $name');
};

boss.onSpawnBullets = (bullets) {
  for (final bullet in bullets) {
    game.spawnBullet(bullet);
  }
};

boss.onBossDefeated = () {
  print('💀 Boss derrotado!');
};

// En game loop
void update(double deltaTime) {
  boss.update(deltaTime, playerPosition);
}

// Aplicar daño
boss.takeDamage(10.0, damageMultiplier: 2.0); // crítico
```

---

## 🏭 Factory Predefinida

### Bosses Disponibles:

```dart
// Boss Asia elegante (3 fases completas)
TouhouBossFactory.createElegantAsianBoss()

// Boss Caribe tempestad (3 fases completas)
TouhouBossFactory.createCaribbeanBoss()
```

Cada uno tiene:
- ✅ 3 Fases con dificultad escalante
- ✅ Spell Cards vs Non-Spells alterados
- ✅ Patrones visuales únicos
- ✅ Movimientos tácticos
- ✅ Equilibrio de dificultad

---

## 🎮 Integración en Gameplay

### En `EnemyComponent` (lib/game/enemies/enemy.dart):

```dart
class EnemyComponent extends PositionComponent {
  late TouhouBossController? _touhouController;
  
  void spawn(..., bool isBoss = false) {
    if (isBoss) {
      // Crear boss tipo Touhou
      final definition = TouhouBossFactory.createElegantAsianBoss();
      _touhouController = TouhouBossController(
        bossDefinition: definition,
        position: position,
      );
      
      // Configurar callbacks
      _touhouController!.onSpawnBullets = (bullets) {
        for (final bullet in bullets) {
          game.spawnBullet(
            bullet.position,
            Vector2(cos(bullet.angle), sin(bullet.angle)) * bullet.speed,
            isPlayer: false,
          );
        }
      };
    }
  }
  
  void update(double deltaTime) {
    if (_touhouController != null) {
      _touhouController!.update(deltaTime, game.player.position);
      position = _touhouController!.currentPosition;
    }
  }
  
  void takeDamage(double damage) {
    if (_touhouController != null && !_touhouController!.isInvulnerable) {
      _touhouController!.takeDamage(damage);
    }
  }
}
```

---

## ⚙️ Casos de Uso

### Crear Patrón Personalizado:

```dart
// Spell Card: Tornado de pétalos
TouhouSpellCard(
  id: 'custom_petal_tornado',
  name: 'Petal Tornado',
  type: SpellCardType.spellCard,
  maxHp: 200.0,
  maxDuration: 40.0,
  bulletEmitterClusters: [
    BulletEmitterCluster(
      emitters: [
        // Espiral rápida hacia el jugador
        BulletEmitter(
          bulletCount: 16,
          bulletSpeed: 250.0,
          bulletDamage: 5.0,
          aimType: 'aimed',
          angleIncrement: 0.2,
          fireRate: 0.35,
        ),
        // Círculo defensivo lento
        BulletEmitter(
          bulletCount: 12,
          bulletSpeed: 100.0,
          bulletDamage: 2.0,
          aimType: 'static',
          angleIncrement: -0.08,
          fireRate: 0.5,
        ),
      ],
      duration: 0,
    ),
  ],
  waypointsPattern: [
    (200, 150), (600, 150), (400, 100), (400, 200),
  ],
  vfxTriggers: ['tornado_effect', 'petal_shower'],
  pointsReward: 1500,
);
```

---

## 🎨 Balance y Dificultad

### Fase 1 (70% HP):
- Non-Spells: `fireRate=0.3-0.4`, `bulletCount=8-10`
- Spell Cards: `maxHp=150-180`, `bulletSpeed=150-200`

### Fase 2 (35% HP):
- Spell Cards: `maxHp=200-250`, `bulletSpeed=200-250`
- `angleIncrement` más alto (patrones más complejos)

### Fase 3 (0% HP):
- Spell Cards: `maxHp=300-350`, `bulletSpeed=250-300`
- Múltiples emitters por cluster
- Mezcla de `'aimed'`, `'static'`, `'random'`

---

## 🔄 Flujo de Ejecución

```
BOSS INIT
  ↓
Waiting → Phase Transition (invulnerable 1.5s)
  ↓
Spell Card #1 (Non-Spell)
  ├─ Generar balas cada frame
  ├─ Actualizar waypoints
  └─ Checkear: ¿HP agotado? ¿Tiempo agotado?
  ↓
Spell Card #2 (Spell Card)
  ├─ Patrones más complejos
  ├─ Duración más larga
  └─ Boss se mueve táctico
  ↓
[Si hay más Spell Cards, repetir]
  ↓
Phase Transition → FASE 2
  ├─ Limpiar balas
  ├─ Aumentar daño 30%
  └─ Patrones más complejos
  ↓
[Fases 2 y 3 continúan similar]
  ↓
BOSS DEFEATED
```

---

## 🚀 TODO - Mejoras Futuras

- [ ] Integrar Focus Mode del jugador (hitbox más pequeña)
- [ ] Sistema de I-frames después de bombing
- [ ] Penalización de daño durante bomb animation
- [ ] Grabación/replay de patrones
- [ ] Editor visual de Spell Cards
- [ ] Sistema de scoring con multiplicadores
- [ ] Efectos de sonido por Spell Card
- [ ] Transiciones de fase animadas

---

## 📖 Referencia Rápida

| Concepto | Dónde | Uso |
|----------|-------|-----|
| Emisor | `BulletEmitter` | Define matemática de disparo |
| Patrón Visual | `BulletEmitterCluster` | Múltiples emisores juntos |
| Ataque | `TouhouSpellCard` | Carta de hechizo completa |
| Fase | `TouhouBossPhase` | Colección de cartas |
| Orquestación | `TouhouBossController` | Gestor principal |

---

**Sistema diseñado para ser**: Flexible, Extensible, Balanceado, Visualmente emocionante ✨
