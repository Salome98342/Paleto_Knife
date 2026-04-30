# 🚀 Quick Reference - Sistema Touhou Boss

## Inicio Rápido (5 min)

### Crear Boss
```dart
final boss = TouhouBossFactory.createElegantAsianBoss();
// o
final boss = TouhouBossFactory.createCaribbeanBoss();
```

### Inicializar
```dart
_touhouController = TouhouBossController(
  bossDefinition: boss,
  position: Vector2(400, 150),
);
```

### Update Loop
```dart
void update(double deltaTime) {
  _touhouController!.update(deltaTime, playerPos);
  position = _touhouController!.currentPosition;
}
```

### Daño
```dart
_touhouController!.takeDamage(10.0);  // Respecta invulnerabilidad
```

### Callbacks
```dart
boss.onSpawnBullets = (bullets) { /* spawn */ };
boss.onPhaseChange = (phase) { /* UI update */ };
boss.onBossDefeated = () { /* end battle */ };
```

---

## Patrones de Balas (Copy-Paste)

### Espiral Rotativa
```dart
BulletEmitter(
  bulletCount: 16,
  bulletSpeed: 150.0,
  aimType: 'static',
  angleIncrement: 0.1,  // ← Clave
  fireRate: 0.4,
)
```

### Abanico Apuntado
```dart
BulletEmitter(
  bulletCount: 12,
  bulletSpeed: 200.0,
  aimType: 'aimed',     // ← Apunta jugador
  spreadAngle: π/6,
  fireRate: 0.3,
)
```

### Mandala (Dual Espiral)
```dart
BulletEmitterCluster(
  emitters: [
    BulletEmitter(..., angleIncrement: 0.12),
    BulletEmitter(..., angleIncrement: -0.12),
  ],
)
```

### Caótico Random
```dart
BulletEmitter(
  bulletCount: 12,
  bulletSpeed: 200.0,
  aimType: 'random',
  spreadAngle: 2 * π,
  fireRate: 0.4,
)
```

---

## Waypoints (Copy-Paste)

### Círculo
```dart
WaypointGenerator.generateCircular(
  center: Vector2(400, 150),
  radius: 80.0,
  pointCount: 8,
)
```

### Figura-8
```dart
WaypointGenerator.generateFigure8(
  center: Vector2(400, 150),
  scaleX: 120.0,
  scaleY: 100.0,
  pointCount: 16,
)
```

### Lado a Lado
```dart
WaypointGenerator.generateSideToSide(
  startPos: Vector2(400, 150),
  distance: 150.0,
  pointCount: 4,
)
```

### Espiral
```dart
WaypointGenerator.generateSpiral(
  center: Vector2(400, 150),
  radiusMin: 50.0,
  radiusMax: 200.0,
  pointCount: 24,
)
```

---

## Crear Spell Card (Template)

```dart
TouhouSpellCard(
  id: 'unique_id',
  name: 'Spell Card Name',
  type: SpellCardType.spellCard,        // nonSpell, spellCard, survivalSpell
  maxHp: 150.0,
  maxDuration: 30.0,
  bulletEmitterClusters: [
    BulletEmitterCluster(
      emitters: [
        // Agrega emisores aquí
        BulletEmitter(...),
      ],
    ),
  ],
  waypointsPattern: [(400, 150)],
  vfxTriggers: ['effect_name'],
  pointsReward: 800,
)
```

---

## Crear Boss Completo (Template)

```dart
TouhouBossDefinition createMyBoss() {
  return TouhouBossDefinition(
    bossName: '🎯 Mi Boss',
    maxHp: 200.0,
    minimumPhases: 3,
    
    phase1: TouhouBossPhase(
      id: 'my_phase1',
      phaseNumber: 1,
      hpThreshold: 0.70,
      phaseName: 'Fase 1',
      damageMultiplier: 1.0,
      spellCards: [
        // 3 spell cards aquí
      ],
    ),
    
    phase2: TouhouBossPhase(...),
    phase3: TouhouBossPhase(...),
  );
}
```

---

## Balance (Ajustes Rápidos)

| Cambio | Efecto |
|--------|--------|
| ↓ bulletCount | Menos balas = fácil |
| ↑ bulletCount | Más balas = difícil |
| ↓ bulletSpeed | Más lentas = fácil |
| ↑ bulletSpeed | Más rápidas = difícil |
| ↑ fireRate | Menos ráfagas = fácil |
| ↓ fireRate | Más ráfagas = difícil |
| ↓ maxHp | HP menor = fácil |
| ↑ damageMultiplier | Boss hace más daño |

---

## Estados del Boss

```
waiting
  ↓ (start)
phaseTransition (1.5s invulnerable)
  ↓
spellCardActive (generando balas)
  ├─ Tiempo agotado? → siguiente carta
  ├─ HP carta agotado? → siguiente carta
  └─ HP boss cruzó threshold? → siguiente fase
  ↓
[Repetir fases 2 y 3]
  ↓
defeated
```

---

## Integración Mínima

### En EnemyComponent.spawn()
```dart
if (isBoss && bossType != null) {
  _isTouhouBoss = true;
  _touhouController = TouhouBossController(
    bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
    position: position,
  );
  _touhouController!.onSpawnBullets = (bullets) {
    for (final b in bullets) game.spawnBullet(b);
  };
  return;
}
```

### En EnemyComponent.update()
```dart
if (_isTouhouBoss && _touhouController != null) {
  _touhouController!.update(deltaTime, game.player.position);
  position = _touhouController!.currentPosition;
  health = _touhouController!.currentHp;
  return;
}
```

### En EnemyComponent.takeDamage()
```dart
if (_isTouhouBoss && _touhouController != null) {
  if (!_touhouController!.isInvulnerable) {
    _touhouController!.takeDamage(damage, damageMultiplier: multiplier);
  }
  return;
}
```

---

## Debugging

```dart
// Ver HP actual
print('Boss HP: ${boss.currentHp}');

// Ver fase actual (0, 1, 2)
print('Phase: ${boss.currentPhaseIndex}');

// Ver invulnerabilidad
print('Invulnerable: ${boss.isInvulnerable}');

// Ver estado
print('State: ${boss.state}');  // waiting, transition, active, defeated
```

---

## Callbacks

| Callback | Parámetro | Uso |
|----------|-----------|-----|
| `onSpawnBullets` | `List<BulletData>` | Spawn bullets en game |
| `onPhaseChange` | `int phase` | Update UI/audio |
| `onSpellCardStart` | `String name` | Show card name |
| `onSpellCardComplete` | - | Animation/feedback |
| `onBossDefeated` | - | Victory logic |

---

## Frecuencias Recomendadas

| Configuración | Fácil | Normal | Difícil |
|--------------|-------|--------|---------|
| bulletCount | 8-10 | 12-16 | 20-24 |
| bulletSpeed | 150 | 180-200 | 250+ |
| fireRate | 0.5 | 0.3-0.4 | 0.2-0.25 |
| phaseHP mult | 1.2 | 1.3-1.4 | 1.5-1.6 |

---

## Archivos Documentación

| Archivo | Cuándo Leer |
|---------|------------|
| `README.md` | Quiero visión general |
| `TOUHOU_SYSTEM_GUIDE.md` | Quiero entender TODO |
| `INTEGRATION_STEPS.md` | Voy a integrar ahora |
| `CUSTOM_BOSS_EXAMPLES.md` | Quiero crear boss nuevo |
| `ARCHITECTURE_DIAGRAM.md` | Quiero ver diagramas |
| `EXECUTIVE_SUMMARY.md` | Quiero resumen ejecutivo |

---

## Snippets Útiles

### Verificar si hay balas generadas
```dart
int bulletCount = 0;
boss.onSpawnBullets = (bullets) {
  bulletCount += bullets.length;
};
```

### Test de daño
```dart
final initialHp = boss.currentHp;
boss.takeDamage(50.0);
assert(boss.currentHp < initialHp);
```

### Log de transiciones
```dart
boss.onPhaseChange = (phase) {
  print('🔄 Transición a Fase ${phase + 1}');
  print('   HP: ${boss.currentHp} / ${boss.maxHp}');
  print('   Daño x${boss.currentDamageMultiplier}');
};
```

---

## Emojis Clave

- ✨ Emisor de balas
- 🎴 Spell Card
- 🚀 Movimiento
- 🏭 Factory
- 🎛️ Controller
- 🔄 State transition
- 💀 Boss defeated
- 🎯 Abanico apuntado
- ⭕ Círculo/espiral
- 🌀 Caótico

---

**Más detalles: Lee la documentación completa**
