## 🎮 QUICK START - Sistema de Combate

### ⚡ En 5 minutos:

**1. Copiar archivos**
Ya están en `lib/game_logic/`

**2. Usar en tu GameScreen de Flame**
```dart
import 'game_logic/combat_cycle.dart';

class GameScreen extends PositionComponent {
  late CombatCycle cycle;

  @override
  Future<void> onLoad() async {
    // Crear ciclo
    cycle = CombatCycleFactory.createSimpleCycle();
    
    // Listeners
    cycle.waveManager.enemySpawned.listen((enemy) {
      // Mostrar enemigo
    });
    
    cycle.bossManager.bossStarted.listen((boss) {
      // Mostrar boss
    });
    
    // Iniciar
    cycle.start();
  }

  @override
  void update(double dt) {
    cycle.update(dt);
    
    // Eliminar muertos
    // Mostrar UI, etc
  }
}
```

**3. Listo 🎉**

---

## 📚 Documentación

- `README_COMBAT_SYSTEM.md` - Guía completa
- `COMBAT_SYSTEM_SUMMARY.md` - Overview visual
- `lib/game_logic/combat_system_examples.dart` - 6 ejemplos

---

## 🎯 Lo que incluye

✅ WaveManager - Gestiona oleadas automáticamente
✅ EnemyFactory - Crea enemigos con tipos distintos
✅ 6 tipos de enemigos - Cada uno con comportamiento diferente
✅ BossManager - Bosses con fase dinámicas
✅ CombatCycle - Orquestador completo
✅ Event-driven - Fácil integrar con UI

---

## 🚀 Comandos útiles

```dart
// Crear ciclo
final cycle = CombatCycleFactory.createSimpleCycle();

// Iniciar
cycle.start();

// Actualizar cada frame
cycle.update(deltaTime);

// Acceder a lógica
cycle.getActiveEnemies()        // Lista de enemigos
cycle.activeBoss                 // Boss actual
cycle.bossManager.damageBoss()   // Dañar boss

// Listeners
cycle.waveManager.waveStarted
cycle.waveManager.waveEnded
cycle.waveManager.enemySpawned
cycle.waveManager.stateChanged

cycle.bossManager.bossStarted
cycle.bossManager.bossDefeated
cycle.bossManager.phaseChanged
cycle.bossManager.stateChanged

// Info
cycle.getStatusInfo()            // String con estado actual
```

---

## 🆕 Agregar nuevo enemigo

```dart
// En EnemyTypesCatalog.initializeDefaults() o por separado:
EnemyTypesCatalog.register(
  EnemyTypeDefinition(
    id: 'shaman',
    name: 'Shaman',
    baseHealth: 30.0,
    behavior: Behavior(
      type: BehaviorType.keepDistance,
      speed: 110.0,
    ),
    attackPattern: AttackPattern(
      type: AttackPatternType.radial,
      cooldown: 3.0,
      bulletSpeed: 250.0,
      bulletDamage: 10.0,
      bulletCount: 6,
    ),
    debugColor: 0xFF00FFFF, // Cyan
  ),
);

// Usar en oleadas
EnemySpawnConfig(
  enemyType: 'shaman',
  quantity: 2,
  spawnPattern: 'burst',
)
```

---

## 🔧 Crear oleada personalizada

```dart
final myWaves = [
  Wave(
    id: 'my_wave_1',
    waveNumber: 1,
    description: 'Mi primera oleada',
    spawns: [
      EnemySpawnConfig(
        enemyType: 'grunt',
        quantity: 10,
        spawnPattern: 'stream',
        delayBetweenSpawns: 0.5,
      ),
      EnemySpawnConfig(
        enemyType: 'elite',
        quantity: 1,
        spawnPattern: 'burst',
      ),
    ],
    difficultyMultiplier: 1.1,
  ),
];

final cycle = CombatCycle(waves: myWaves);
cycle.start();
```

---

## 📂 Archivos creados

```
lib/game_logic/wave_system/
  ├── enemy_spawn_config.dart
  ├── wave.dart
  └── wave_manager.dart

lib/game_logic/enemy_system/
  ├── enemy_behavior.dart
  ├── attack_pattern.dart
  ├── enemy_types.dart
  └── enemy_factory.dart

lib/game_logic/boss_system/
  ├── boss_phase.dart
  ├── boss.dart
  └── boss_manager.dart

lib/game_logic/
  ├── combat_cycle.dart
  └── combat_system_examples.dart

README_COMBAT_SYSTEM.md
COMBAT_SYSTEM_SUMMARY.md
QUICK_START_COMBAT.md (este archivo)
```

**Total: ~1,900 líneas de código**

---

## 🎬 Ejemplo completo

```dart
import 'game_logic/combat_cycle.dart';

void hacerPrueba() {
  // Crear
  final cycle = CombatCycleFactory.createSimpleCycle();
  
  // Listeners (UI, etc)
  cycle.waveManager.waveStarted.listen((wave) {
    print('🌊 ¡ONDA ${wave.waveNumber}!');
  });
  
  cycle.waveManager.waveEnded.listen((wave) {
    print('✅ Onda completada');
  });
  
  cycle.bossManager.bossStarted.listen((boss) {
    print('👑 ${boss.name} ha llegado');
  });
  
  // Iniciar
  cycle.start();
  
  // Simular gameplay
  for (int i = 0; i < 100; i++) {
    cycle.update(0.016); // 60 FPS
    
    // Dañar enemigos/boss
    for (final enemy in cycle.getActiveEnemies()) {
      if (Random().nextDouble() > 0.98) {
        enemy.takeDamage(10);
      }
    }
    
    if (cycle.activeBoss != null) {
      cycle.bossManager.damageBoss(5);
    }
  }
  
  cycle.dispose();
}
```

---

## ❓ Preguntas frecuentes

**P: ¿Cómo agrego más fases al boss?**
R: En `boss_manager.dart`, agrega más `BossPhase` en la lista `phases` con umbrales diferentes.

**P: ¿Puedo cambiar los patrones de ataque del boss?**
R: Sí, en cada `BossPhase` hay `attackPatterns` que puedes modificar.

**P: ¿Cómo integro con UI de oleadas/boss?**
R: Escucha los streams: `waveManager.waveStarted`, `bossManager.phaseChanged`, etc.

**P: ¿Puedo agregar sonidos/partículas?**
R: Sí, en los listeners puedes agregar efectos cuando se spawnea enemigo, fase cambia, etc.

**P: ¿Es compatible con el sistema de audio existente?**
R: Sí, es completamente independiente. Puedes agregar AudioManager en los listeners.

---

**¿Dudas? Lee `README_COMBAT_SYSTEM.md` para documentación completa**
