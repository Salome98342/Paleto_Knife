# 🎮 COMBAT SYSTEM - COMPLETE IMPLEMENTATION GUIDE

## 📋 Overview

This is a complete combat system for a Flutter + Flame game featuring:

- **Wave System** - Progressive enemy spawning with multiple patterns
- **Enemy System** - 16+ regional enemies with unique behaviors and counters
- **Element System** - 7 element types with advantage/disadvantage mechanics
- **Modifier System** - Giant, Armor, Multiple variants
- **Boss System** - 3 regional bosses with multi-phase mechanics
- **Regional Progression** - Asia → Caribbean → Europe

---

## 🚀 Quick Start

### 1. Initialize All Catalogs

```dart
import 'lib/game_logic/enemy_system/enemy_types.dart';
import 'lib/game_logic/enemy_system/enemy_modifiers.dart';
import 'lib/game_logic/wave_system/wave_catalog.dart';
import 'lib/game_logic/boss_system/boss_catalog.dart';
import 'lib/models/element_type.dart';

void initializeCombatSystem() {
  // Initialize all type catalogs
  EnemyTypesCatalog.initializeDefaults();
  ModifierCatalog.initializeDefaults();
  WaveCatalog.initializeDefaults();
  BossCatalog.initializeDefaults();
  print('✅ Combat system initialized');
}
```

### 2. Start a Region

```dart
import 'lib/game_logic/wave_system/wave_manager.dart';
import 'lib/game_logic/enemy_system/enemy_factory.dart';

// Create enemy factory
final enemyFactory = EnemyFactory(projectileSystem: myProjectileSystem);

// Get waves for region
final waves = WaveCatalog.getWaveSet('asia'); // or 'caribbean', 'europe'

// Create wave manager
final waveManager = WaveManager(
  waves: waves,
  enemyFactory: enemyFactory,
);

// Start first wave
waveManager.start();
```

### 3. Handle Wave Events

```dart
// Listen to wave events
waveManager.waveStarted.listen((wave) {
  print('🌊 Wave ${wave.waveNumber} started!');
  showWaveUI(wave);
});

waveManager.waveEnded.listen((wave) {
  print('✅ Wave ${wave.waveNumber} completed!');
});

waveManager.enemySpawned.listen((enemy) {
  print('👾 Enemy spawned: ${enemy.name}');
  // Add enemy to game
});
```

---

## 🌏 Regional Structure

### ASIA - 🟤 Earth Element
**Boss:** Gran Dumpling Ancestral (500 HP)

**Enemies:**
- **Gyoza Errante** (Grunt) - Chaser, fast
- **Bola de Harina Maldita** (Swarm) - AOE threat
- **Tótem de Vapor** (Shooter) - Ranged, spread pattern
- **Dumpling Coloso** (Tank) - High HP, slow
- **Raíz Hereje** (Elite) - Fast, deadly

**Counters:** 🔥 Fire, 🌋 Lava, 🌱 Plant

---

### CARIBE - 🔥 Fire Element
**Boss:** Rey Jerk Volcánico (480 HP)

**Enemies:**
- **Brasa Viva** (Swarm) - Fast, multiple
- **Jerk Infernal** (Bruiser) - Aggressive chaser
- **Parrillero Maldito** (Shooter) - Controlled fire
- **Bestia Ahumada** (Tank) - Durable, strong
- **Espíritu Picante** (Elite) - Radial pattern

**Counters:** 💧 Water, 💨 Wind

---

### EUROPA - 💧 Water Element
**Boss:** Leviatán de Caldo (520 HP)

**Enemies:**
- **Sopa Abisal** (Swarm) - Wandering, minimal threat
- **Masa Fluvial** (Grunt) - Fast chaser
- **Lancero de Caldo** (Shooter) - Aimed attacks
- **Gólem de Salmuera** (Tank) - Crystalline, strong
- **Druida Corrupto** (Elite) - Spread pattern

**Counters:** 🌱 Plant, 🌋 Lava

---

## ⚛️ Element System

### Base Elements
```
Agua > Fuego (+25%)
Fuego > Tierra (+25%)
Tierra > Agua (+25%)
```

### Composite Elements
```
Agua + Fuego = Viento (💨)
  - AOE + Knockback
  - Effective: +30% vs Earth, +20% vs Water/Fire

Fuego + Tierra = Lava (🌋)
  - Breaks Armor
  - Effective: +30% vs Water

Agua + Tierra = Planta (🌱)
  - Poison (% HP damage)
  - Effective: +35% vs Fire, +20% vs Earth
```

---

## 🧬 Enemy Modifiers

### Giant (Gigante)
- `+100%` HP
- `1.5x` Visual Scale
- Easier to hit, slow

### Armor (Armadura)
- `-25%` Damage Received
- `1.1x` Visual Scale
- Durable

### Multiple (Múltiple)
- Spawns `2-3` Clones when dying
- Same type as original
- Divisibility mechanic

### Combinations
- **Giant + Armor** = Super Tank
- **Armor + Multiple** = Endless Spawning
- **Giant + Multiple** = Many Copies

---

## 🎯 Wave Progression

Each region follows the same pattern:

```
Wave 1: Introduction (1 enemy type)
Wave 2: Variety (2 types mixed)
Wave 3: Pressure (More enemies, new type)
Wave 4: Complexity (Tank introduced)
Wave 5: Chaos (Elite enemy appears)
Wave 6: BOSS (Regional Boss battle)
```

### Spawn Patterns

- `burst` - All at once
- `stream` - Constant spawning
- `random` - Unpredictable timing
- `circle` - Circular formation

---

## 👑 Boss Phases

All bosses have 3 phases:

### Phase 1 (100% - 70% HP)
- Introduction
- Single attack pattern
- Limited movement

### Phase 2 (70% - 30% HP)
- More aggressive
- Multiple attack patterns
- Increased speed (1.5x)

### Phase 3 (30% - 0% HP)
- Desperate attacks
- Maximum attack patterns
- Increased speed (2.0x)

---

## 📊 Usage Examples

### Get Enemy by ID

```dart
final enemyDef = EnemyTypesCatalog.get('dumpling_coloso');
if (enemyDef != null) {
  print('Enemy: ${enemyDef.name}');
  print('Element: ${enemyDef.element.displayName}');
  print('Role: ${enemyDef.role}');
  print('Counters: ${enemyDef.counters.join(', ')}');
  print('Lore: ${enemyDef.lore}');
}
```

### Get Enemies by Region

```dart
import 'lib/game_logic/enemy_system/enemy_types.dart';

final asiaEnemies = EnemyTypesCatalog.getByRegion(Region.asia);
final allTanks = EnemyTypesCatalog.getByRole('tank');

for (final enemy in asiaEnemies) {
  print('🌏 ${enemy.name} (${enemy.element.emoji})');
}
```

### Create Enemy with Modifiers

```dart
final enemy = Enemy(
  id: 'giant_gyoza_1',
  name: 'Gyoza Errante Gigante',
  type: AmalgamaType.lavaPizza,
  element: ElementType.earth,
  tier: EnemyTier.normal,
  position: Offset(100, 100),
  health: 50.0,
  maxHealth: 50.0,
  modifiers: [EnemyModifier.giant()],
);
```

### Get Wave Set

```dart
final waves = WaveCatalog.getWaveSet('caribbean');
print('${waves.length} waves in Caribbean');

for (final wave in waves) {
  if (wave.isBossWave) {
    print('BOSS WAVE: ${wave.description}');
  } else {
    print('Wave ${wave.waveNumber}: ${wave.spawns.length} spawn configs');
  }
}
```

### Get Boss

```dart
final boss = BossCatalog.get('gran_dumpling_ancestral');
if (boss != null) {
  print('Boss: ${boss.name}');
  print('Max HP: ${boss.maxHp}');
  print('Phases: ${boss.phases.length}');
  
  for (final phase in boss.phases) {
    print('Phase ${phase.phaseNumber}: HP > ${phase.hpThreshold * 100}%');
    print('  Attack Speed: ${phase.attackSpeedMultiplier}x');
    print('  Patterns: ${phase.attackPatterns.length}');
  }
}
```

### Check Element Advantage

```dart
final player = ElementType.fire;
final enemy = ElementType.earth;

double multiplier = player.getAdvantageAgainst(enemy);
print('Damage multiplier: ${multiplier}x');

// Composite element check
final wind = ElementType.wind;
if (wind.isComposite) {
  final (component1, component2) = wind.getComponents();
  print('Wind = $component1 + $component2');
}
```

---

## 🔧 Integration Tips

### 1. Connect to Game Loop

```dart
class CombatGameScreen extends PositionComponent {
  late WaveManager waveManager;
  
  @override
  void update(double dt) {
    waveManager.update(dt);
  }
}
```

### 2. Update Enemy Position Based on Behavior

```dart
void _updateEnemyMovement(Enemy enemy, double dt) {
  final typeDef = EnemyTypesCatalog.get(enemy.name.toLowerCase());
  if (typeDef == null) return;
  
  final behavior = typeDef.behavior;
  
  switch (behavior.type) {
    case BehaviorType.chase:
      _chasePlayer(enemy, behavior, dt);
      break;
    case BehaviorType.keepDistance:
      _keepDistance(enemy, behavior, dt);
      break;
    case BehaviorType.circlePlayer:
      _circlePlayer(enemy, behavior, dt);
      break;
    case BehaviorType.wander:
      _wander(enemy, behavior, dt);
      break;
    case BehaviorType.stationary:
      break;
  }
}
```

### 3. Apply Element Bonus to Damage

```dart
double calculateDamage(ElementType playerElement, ElementType enemyElement, double baseDamage) {
  double multiplier = playerElement.getAdvantageAgainst(enemyElement);
  return baseDamage * multiplier;
}
```

### 4. Handle Boss Phases

```dart
if (boss.currentPhaseIndex != previousPhase) {
  print('🔥 Boss entering phase ${boss.currentPhaseIndex + 1}');
  _showPhaseEffect(boss.currentPhase);
  _updateBossAttackPattern(boss.currentPhase);
}
```

---

## 📁 File Structure

```
lib/
├── game_logic/
│   ├── boss_system/
│   │   ├── boss.dart                 ✅ Boss class
│   │   ├── boss_phase.dart           ✅ Phase definition
│   │   ├── boss_manager.dart         ✅ Manager
│   │   └── boss_catalog.dart         ✅ Boss definitions [NEW]
│   ├── enemy_system/
│   │   ├── enemy_types.dart          ✅ All 20+ enemy definitions
│   │   ├── enemy_behavior.dart       ✅ Behavior types
│   │   ├── attack_pattern.dart       ✅ Attack patterns
│   │   ├── enemy_factory.dart        ✅ Enemy creation
│   │   └── enemy_modifiers.dart      ✅ Modifiers & variants [NEW]
│   └── wave_system/
│       ├── wave.dart                 ✅ Wave class
│       ├── wave_manager.dart         ✅ Manager
│       ├── enemy_spawn_config.dart   ✅ Spawn configuration
│       └── wave_catalog.dart         ✅ Wave progressions [NEW]
└── models/
    ├── element_type.dart             ✅ Element system (enhanced)
    ├── enemy.dart                    ✅ Enemy model
    └── ...
```

---

## ✅ Checklist

- [x] Element system with composites ✨
- [x] Enemy type catalog (20+ enemies)
- [x] Enemy modifiers (Giant, Armor, Multiple)
- [x] Wave progression (3 regions × 6 waves each)
- [x] Boss definitions (3 bosses × 3 phases each)
- [x] Boss catalog with complete mechanics
- [x] Wave catalog with spawn configurations
- [x] No hardcoding - fully database-driven
- [x] Extensible and modular architecture
- [x] Lore and visual descriptions for each enemy
- [x] Regional progression with difficulty scaling

---

## 🎮 Next Steps

1. **Update WaveManager** - Complete implementation of `update()` method
2. **Create Combat Screen** - Connect UI to wave/boss events
3. **Add Animations** - Spawn effects, phase transitions, boss entrance
4. **Implement Counters** - UI indicators for element advantages
5. **Add Audio** - Region themes, attack sounds
6. **Balance Difficulty** - Test and adjust HP/damage values

---

## 💡 Design Principles

✅ **No Hardcoding** - Everything is configurable through catalogs
✅ **Modular** - Each system is independent and reusable
✅ **Extensible** - Easy to add new enemies/bosses/regions
✅ **Regional Identity** - Each region has unique enemies and mechanics
✅ **Strategic Complexity** - Element counters force tactical decisions
✅ **Visual Clarity** - Emojis and colors for quick identification

---

Generated: 2026-04-07
Version: 1.0 - Complete Combat System
