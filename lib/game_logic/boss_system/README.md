# Sistema Touhou Boss - README

**Status:** ✅ Sistema Completo v1.0  
**Fecha:** 12 Abril 2026  
**Tiempo de Desarrollo:** ~200 tokens dedicados  
**Líneas de Código:** 1650+

---

## 🎮 ¿Qué es este Sistema?

Transformación completa del sistema de bosses para crear experiencias tipo **Touhou** (bullet-hell) con:

✅ **3 Fases por Boss** con dificultad escalante  
✅ **Spell Cards vs Non-Spells** (cartas de hechizo vs ataques normales)  
✅ **Patrones Matemáticos Avanzados** (espirales, mandalas, caótico)  
✅ **Movimiento Inteligente** con waypoints y easing  
✅ **Estado Dinámico** con transiciones suaves entre fases  
✅ **Escalabilidad** - Fácil crear nuevos bosses  

---

## 📁 Estructura de Archivos

```
lib/game_logic/boss_system/
├── README.md (este archivo)
├── TOUHOU_SYSTEM_GUIDE.md      📖 Guía completa del sistema
├── INTEGRATION_STEPS.md         🔧 Pasos para integrar
├── CUSTOM_BOSS_EXAMPLES.md      💡 Ejemplos de creación
│
├── bullet_emitter.dart          ✨ Generador de balas
├── touhou_spell_card.dart       🎴 Definición de cartas
├── boss_movement.dart           🚀 Sistema de movimiento
├── touhou_boss_factory.dart     🏭 Factory con 2 bosses
└── touhou_boss_controller.dart  🎛️ Orquestador principal
```

---

## 🚀 Inicio Rápido

### 1. Crear un Boss

```dart
// En touhou_boss_factory.dart
final boss = TouhouBossFactory.createElegantAsianBoss();
```

### 2. Inicializar en Juego

```dart
// En EnemyComponent.spawn()
_touhouController = TouhouBossController(
  bossDefinition: boss,
  position: Vector2(400, 150),
);
```

### 3. Update en Game Loop

```dart
void update(double deltaTime) {
  _touhouController!.update(deltaTime, playerPosition);
  position = _touhouController!.currentPosition;
}
```

---

## 🎯 Características Principales

### BulletEmitter - Generador de Balas

```dart
BulletEmitter(
  bulletCount: 12,          // Cantidad
  bulletSpeed: 200.0,       // Velocidad
  aimType: 'aimed',         // aimed, static, random
  spreadAngle: π/6,         // Dispersión
  angleIncrement: 0.05,     // Rotación (para espirales)
  fireRate: 0.3,            // Cadencia
)
```

**Tipos de Apuntado:**
- `'aimed'` - Calcula ángulo hacia el jugador
- `'static'` - Rotativo/circular fijo
- `'random'` - Completamente aleatorio

### TouhouSpellCard - Cartas de Hechizo

Cada carta es un **ataque completo** con:
- HP propio (independiente del boss)
- Duración en segundos
- Múltiples clusters de emisores
- Patrón de movimiento
- Efectos visuales

**SpellCardType:**
- `nonSpell` - Ataque débil, introduces patrón
- `spellCard` - Ataque fuerte principal
- `survivalSpell` - Fase invulnerable (esquiva tiempo)

### TouhouBossPhase - Fases Completas

Cada fase agrupa 3 cartas:
1. Non-Spell (calentamiento)
2. Spell Card (ataque principal)
3. Otra Spell Card (variación)

**Características:**
- Threshold de HP (cuándo comienza)
- Nombre de fase
- Multiplicador de daño por fase

### BossMovementSystem - Movimiento Inteligente

```dart
// Generar waypoints automáticamente
WaypointGenerator.generateCircular()      // Círculo
WaypointGenerator.generateFigure8()       // Figura-8
WaypointGenerator.generateSideToSide()    // Lado a lado
WaypointGenerator.generateRandom()        // Aleatorio
WaypointGenerator.generateSpiral()        // Espiral
```

Interpolación: `linear`, `bezier`, `bouncy`

---

## 📊 Bosses Incluidos

### 1. Elegant Asian Boss (✿ 優雅な精 - Espíritu Elegante)

**Tema:** Gracia y elegancia oriental  
**HP Total:** ~300 (con multiplicadores)  
**Dificultad:** 🔴 Alta

**Fase 1 (70% HP):**
- Non-Spell "Spiraling Wind" - Espiral rotativa simple
- Spell Card "Elegant Fan" - Abanico + espiral dual
- Spell Card "Elegant Mandala" - Doble mandala

**Fase 2 (35% HP):**
- Más emisores por carta
- Daño x1.3
- Patrones más complejos

**Fase 3 (0% HP):**
- Final épico: "Final Elegance"
- Triple patrón (apuntado + espiral + caótico)
- Daño x1.5

---

### 2. Caribbean Storm Boss (☀ Cazador de Tormentas)

**Tema:** Tormenta y caos tropical  
**HP Total:** ~280  
**Dificultad:** 🔴 Alta

**Fase 1:** Patrones aire suave  
**Fase 2:** Doble/triple vórtices  
**Fase 3:** Tormenta apocalíptica  

---

## 🎨 Ejemplos de Patrones

### Espiral Rotativa (Clásico Touhou)
```dart
BulletEmitter(
  bulletCount: 16,
  bulletSpeed: 150.0,
  aimType: 'static',
  angleIncrement: 0.1,    // ← Clave: rotación
  fireRate: 0.4,
)
```

### Abanico Apuntado (Peligroso)
```dart
BulletEmitter(
  bulletCount: 12,
  bulletSpeed: 220.0,
  aimType: 'aimed',       // ← Apunta al jugador
  spreadAngle: π/6,       // ← Abanico abierto
  fireRate: 0.3,
)
```

### Mandala (Patrón Dual)
```dart
BulletEmitterCluster(
  emitters: [
    BulletEmitter(..., angleIncrement: 0.12),   // ← Derecha
    BulletEmitter(..., angleIncrement: -0.12),  // ← Izquierda
  ],
)
```

---

## 🔧 Integración en Código

### 1. Actualizar EnemyComponent

```dart
class EnemyComponent extends PositionComponent {
  TouhouBossController? _touhouController;
  
  void spawn(..., bool isBoss = false, String? bossType = null) {
    if (isBoss && bossType != null) {
      _initializeTouhouBoss(bossType, position);
      return;
    }
    // ... enemigo normal ...
  }
}
```

### 2. Conectar Callbacks

```dart
_touhouController!.onSpawnBullets = (bullets) {
  for (final bullet in bullets) {
    game.spawnBullet(bullet);
  }
};
```

### 3. Update Loop

```dart
void update(double deltaTime) {
  if (_touhouController != null) {
    _touhouController!.update(deltaTime, playerPos);
  }
}
```

Más detalles → Ver `INTEGRATION_STEPS.md`

---

## 💡 Crear Bosses Personalizados

### Estructura Básica

```dart
TouhouBossDefinition createMyBoss() {
  return TouhouBossDefinition(
    bossName: '🎯 Mi Boss Personalizado',
    maxHp: 200.0,
    phase1: TouhouBossPhase(
      spellCards: [
        // Non-Spell
        TouhouSpellCard(...),
        // Spell Cards
        TouhouSpellCard(...),
        TouhouSpellCard(...),
      ],
    ),
    phase2: TouhouBossPhase(...),
    phase3: TouhouBossPhase(...),
  );
}
```

**Ver ejemplos avanzados → `CUSTOM_BOSS_EXAMPLES.md`**

---

## ⚙️ Balance y Dificultad

### Fórmula HP por Fase

```
Phase 1 HP = baseHp × 1.0
Phase 2 HP = baseHp × 1.3-1.4
Phase 3 HP = baseHp × 1.5-1.6
```

### Ajuste de Dificultad

**Más fácil:**
- ↓ `bulletCount` (menos balas)
- ↓ `bulletSpeed` (más lentas)
- ↑ `fireRate` (menos ráfagas)

**Más difícil:**
- ↑ `bulletCount` (más balas)
- ↑ `bulletSpeed` (más rápidas)
- ↓ `fireRate` (más ráfagas)

---

## 🎭 Estado del Boss

```
Estado: waiting
  ↓
Estado: phaseTransition (1.5s invulnerable)
  ↓
Estado: spellCardActive
  ├─ Si tiempo agotado → siguiente carta
  ├─ Si HP de carta agotado → siguiente carta
  └─ Si última carta → siguiente fase
  ↓
[Repetir fases 2 y 3]
  ↓
Estado: defeated
```

---

## 🔄 Callbacks Disponibles

```dart
boss.onPhaseChange = (int phase) { /* UI update */ };
boss.onSpellCardStart = (String name) { /* mostrar nombre */ };
boss.onSpellCardComplete = () { /* animación */ };
boss.onSpawnBullets = (List<BulletData> bullets) { /* spawn */ };
boss.onBossDefeated = () { /* victoria */ };
```

---

## 🧪 Testing

```dart
// Crear boss
final boss = TouhouBossController(
  bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
  position: Vector2(400, 150),
);

// Aplicar daño
boss.takeDamage(50.0);

// Verificar fase
expect(boss.currentPhaseIndex, 1);

// Simular time
boss.update(10.0, Vector2(400, 200));
```

---

## 💾 Cambios Recientes

**v1.0 (12 Abril 2026):**
- ✅ BulletEmitter con patrones matemáticos
- ✅ TouhouSpellCard con cartas independientes
- ✅ BossMovementSystem con waypoints
- ✅ TouhouBossFactory con 2 bosses completos
- ✅ TouhouBossController con máquina de estados
- ✅ Documentación completa

---

## 🚀 Próximas Mejoras

- [ ] Más bosses en TouhouBossFactory
- [ ] Sistema de focus mode (hitbox pequeño)
- [ ] Transiciones de fase animadas
- [ ] Efectos de sonido por Spell Card
- [ ] Grabación/replay de patrones
- [ ] Editor visual de Spell Cards
- [ ] Boss rush mode (múltiples bosses)

---

## 📖 Documentación

- **TOUHOU_SYSTEM_GUIDE.md** - Guía completa del sistema
- **INTEGRATION_STEPS.md** - Pasos de integración en código
- **CUSTOM_BOSS_EXAMPLES.md** - Ejemplos de bosses personalizados

---

## 🎓 Conceptos Clave

| Término | Significado |
|---------|------------|
| BulletEmitter | Genera balas en patrón matemático |
| SpellCard | Ataque completo (patrón + duración) |
| BulletEmitterCluster | Múltiples emisores disparando juntos |
| Phase | Sección del boss (70%, 35%, 0% HP) |
| Waypoint | Punto de movimiento en ruta |
| Invulnerable | Boss no recibe daño (transiciones) |
| SurvivalSpell | Fase donde jugador solo esquiva |

---

## ✨ Nota de Diseño

Este sistema fue crear **bosses memorables y difíciles** como en Touhou:
- ✅ Patrones visualmente emocionantes
- ✅ Escalada de dificultad clara
- ✅ Ataques con "nombres" (Spell Cards)
- ✅ Movimientos tácticos e inteligentes
- ✅ Equilibrio entre determinismo y caos

**Resultado:** Bosses que son **desafiantes pero justos**, donde el jugador puede estudiar patrones y mejorar.

---

**Sistema diseñado para ser:** Flexible, Extensible, Balanceado, Emocionante ✨

Preguntas o sugerencias → Revisar INTEGRATION_STEPS.md

