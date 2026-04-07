# ⚡ COMBAT SYSTEM - QUICK REFERENCE

## 🚀 5-Minute Setup

```dart
// 1. Initialize
EnemyTypesCatalog.initializeDefaults();
ModifierCatalog.initializeDefaults();
WaveCatalog.initializeDefaults();
BossCatalog.initializeDefaults();

// 2. Create wave manager
final waves = WaveCatalog.getWaveSet('asia');
final waveManager = WaveManager(waves: waves, enemyFactory: enemyFactory);

// 3. Listen to events
waveManager.waveStarted.listen((w) => print('Wave ${w.waveNumber}'));
waveManager.enemySpawned.listen((e) => addEnemyToGame(e));

// 4. Update in game loop
waveManager.update(deltaTime);
```

---

## 📍 Regional Bosses

| Region | Boss | Element | HP | Counters |
|--------|------|---------|----|-----------| 
| 🌏 Asia | Gran Dumpling Ancestral | 🟤 Tierra | 500 | 🔥🌋🌱 |
| 🌊 Caribbean | Rey Jerk Volcánico | 🔥 Fuego | 480 | 💧💨 |
| 🌿 Europe | Leviatán de Caldo | 💧 Agua | 520 | 🌱🌋 |

---

## 👾 Enemy Count by Region

### 🌏 ASIA (16 enemies)
- 1x Dumpling Coloso (Tank)
- 1x Gyoza Errante (Grunt) 
- 1x Bola de Harina Maldita (Swarm)
- 1x Tótem de Vapor (Shooter)
- 1x Raíz Hereje (Elite)
- 1x Grunt (fallback)

### 🌊 CARIBBEAN (16 enemies)
- 1x Jerk Infernal (Bruiser)
- 1x Brasa Viva (Swarm)
- 1x Parrillero Maldito (Shooter)
- 1x Bestia Ahumada (Tank)
- 1x Espíritu Picante (Elite)
- 1x Shooter (fallback)

### 🌿 EUROPE (16 enemies)
- 1x Sopa Abisal (Swarm)
- 1x Lancero de Caldo (Shooter)
- 1x Masa Fluvial (Grunt)
- 1x Gólem de Salmuera (Tank)
- 1x Druida Corrupto (Elite)
- 1x Swarm (fallback)

---

## ⚛️ Element Advantages

```
Base Cycle:
  💧 > 🔥 (1.25x)
  🔥 > 🟤 (1.25x)
  🟤 > 💧 (1.25x)

Composites:
  💨 (💧+🔥) > 🟤 (1.3x) [AOE + Knockback]
  🌋 (🔥+🟤) > 💧 (1.3x) [Break Armor]
  🌱 (💧+🟤) > 🔥 (1.35x) [Poison]
```

---

## 🧬 Modifiers Quick Stats

| Modifier | HP | Damage | Scale | Effect |
|----------|----|---------|----|--------|
| Giant | +100% | - | 1.5x | Slow |
| Armor | - | -25% | 1.1x | Tank |
| Multiple | - | - | 1.0x | Spawn 2-3 clones |

---

## 🎯 Wave Structure (All Regions)

```
Wave 1: Single type intro
Wave 2: Two types mixed
Wave 3: New type + pressure
Wave 4: Tank introduced
Wave 5: Elite appears
Wave 6: BOSS FIGHT
```

---

## 👑 Boss Phases

```
Phase 1 (100%-70%): Intro, 1.0x speed
Phase 2 (70%-30%):  Escalation, 1.5x speed
Phase 3 (30%-0%):   Desperate, 2.0x speed
```

---

## 💡 Common Queries

```dart
// Get enemy definition
EnemyTypesCatalog.get('dumpling_coloso')?.name;

// Get all enemies of region
EnemyTypesCatalog.getByRegion(Region.asia);

// Get all tanks
EnemyTypesCatalog.getByRole('tank');

// Check element advantage
ElementType.water.getAdvantageAgainst(ElementType.fire); // 1.25

// Get wave set
WaveCatalog.getWaveSet('caribbean');

// Get boss
BossCatalog.get('rey_jerk_volcanico');
```

---

## 📊 Scalable Values

All HP/damage scales with:
- **Player Level** (or Wave Number)
- **Difficulty Multiplier** (1.0 - 1.5)
- **Modifiers** (Giant +100%, etc.)

```dart
scaledHP = baseHP * (1.0 + (level-1)*0.15) * difficultyMultiplier * modifierMultiplier
```

---

## 🎮 Spawn Patterns

- `burst` - All at once
- `stream` - Continuous spawn
- `random` - Unpredictable
- `circle` - Circular formation

---

## 📝 Enemy ID Format

`region_name_role` or `region_name_specific`

Examples:
- `dumpling_coloso`
- `gyoza_errante`
- `jerk_infernal`
- `sopa_abisal`

---

## 🚨 Remember!

✅ Initialize ALL catalogs before using
✅ Check element advantages for damage scaling
✅ Update wave manager every frame
✅ Boss phases auto-trigger based on HP %
✅ Modifiers stack multiplicatively

---

**For full documentation:** See `COMBAT_SYSTEM_COMPLETE.md`
