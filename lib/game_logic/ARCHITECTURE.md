# Game Logic - Arquitectura y Organización

## Visión General

`lib/game_logic/` contiene la **lógica central del juego**, separada en tres categorías claras:

```
game_logic/
├── catalogs/                    # 📊 Datos estáticos
│   ├── enemy_types.dart        # ✓ Definiciones de enemigos
│   ├── boss_catalog.dart       # ✓ Definiciones de bosses
│   ├── enemy_modifiers.dart    # ✓ Modificadores (giant, armor, etc)
│   └── README.md               # Guía de catalogs
│
├── systems/                     # ⚙️ Lógica dinámica
│   ├── gacha_system.dart       # ✓ Sistema de gacha con pity
│   ├── economy_system.dart     # ✓ Gestión de recursos
│   ├── reward_system.dart      # ✓ Cálculo de recompensas
│   ├── revive_system.dart      # ✓ Revive con ads
│   ├── session_sync_service.dart # ✓ Sincronización sesión→persistencia
│   └── README.md               # Guía de systems
│
├── controllers/                 # 🎮 Controladores de entidades
│   ├── enemy_controller.dart   # ✓ Lógica de enemigos
│   ├── player_controller.dart  # ✓ Lógica de jugador
│   └── [más controllers]
│
├── managers/                    # 📋 Gestores globales
│   ├── world_manager.dart      # ✓ Progresión de mundos
│   ├── projectile_system.dart  # ✓ Gestión de proyectiles
│   └── [más managers]
│
├── factories/                   # 🏭 Creadores de objetos
│   ├── enemy_factory.dart      # ✓ Factory de enemigos
│   └── [más factories]
│
├── enemy_system/                # 👾 Lógica específica de enemigos
│   ├── enemy_types.dart        # ✓ Definiciones (DEBE MOVER a catalogs/)
│   ├── attack_pattern.dart     # ✓ Patrones de ataque
│   ├── enemy_behavior.dart     # ✓ Comportamientos
│   ├── enemy_state_machine.dart # ✓ Estado machine
│   └── [enemigos específicos]
│
├── boss_system/                 # 👑 Lógica específica de bosses
│   ├── boss_catalog.dart       # ✓ Catálogo (DEBE MOVER a catalogs/)
│   ├── boss_phases.dart        # ✓ Fases de boss
│   ├── boss_visuals.dart       # ✓ Visuales y animaciones
│   └── boss_vfx.dart           # ✓ Efectos visuales
│
├── game_state.dart             # ✓ GameStateManager (sesión temporal)
│
├── combat_system_initializer.dart # ✓ Inicialización en startup
│
└── README.md                   # Este archivo
```

## Categorización

### 📊 Catalogs (datos estáticos)

**Ubicación**: `game_logic/catalogs/`

**Qué son**: Colecciones de definiciones de datos que NO cambian durante gameplay

**Ejemplos**:
- `EnemyTypesCatalog` - 20+ tipos de enemigos con stats base
- `BossCatalog` - Definiciones de bosses con fases
- `ModifierCatalog` - Modificadores aplicables a enemigos

**Usados por**: Factories, Controllers, Systems que necesitan leer datos

**Ciclo de vida**: Inicializados en startup, permanecen hasta fin de sesión

---

### ⚙️ Systems (lógica dinámica)

**Ubicación**: `game_logic/systems/`

**Qué son**: Lógica interactiva que maneja un aspecto del juego

**Ejemplos**:
- `GachaSystem` - Lógica de tiradas de gacha
- `RewardSystem` - Cálculo de recompensas finales
- `SessionSyncService` - Sincroniza sesión → persistencia
- `ReviveSystem` - Lógica de revivir con ads

**Usados por**: Controllers, Screens, UI

**Ciclo de vida**: Creados cuando se necesitan, destruidos al finalizar GameplayScreen

---

### 🎮 Controllers (control de entidades)

**Ubicación**: Distribuidos (deben consolidarse en `game_logic/controllers/`)

**Qué son**: Controladores que manejan la lógica de una entidad del juego

**Ejemplos**:
- `EnemyController` - Actualiza y controla enemigos
- `PlayerController` - Actualiza jugador

**Usados por**: PaletoGame (Flame), GameplayScreen

---

### 📋 Managers (gestión global)

**Ubicación**: `game_logic/managers/` (debe crearse)

**Qué son**: Gestores de Sistema global

**Ejemplos**:
- `WorldManager` - Gestiona mundo actual, niveles, elementos
- `ProjectileSystem` - Pool de proyectiles

---

### 🏭 Factories (creadores)

**Ubicación**: `game_logic/factories/` (debe crearse)

**Qué son**: Crean instancias complejas basadas en catalogs

**Ejemplos**:
- `EnemyFactory` - Lee EnemyTypesCatalog, crea Enemy instances

---

## Reglas de Arquitectura

### ✅ BIEN HECHO
```dart
// Controllers leen Catalogs
final enemyDef = EnemyTypesCatalog.getById('lavaPizza');
final enemy = Enemy.fromDefinition(enemyDef);

// Systems son temporales
class GameplayScreen {
  late RewardSystem _rewardSystem = RewardSystem();  // Creado aquí
  
  void _onGameOver() {
    SessionSyncService.syncSessionToProgress(
      sessionState: _gameState,
      gameController: _gameController,
    );  // Sincroniza datos
  }
}

// Managers son globales
late final WorldManager _worldManager = WorldManager();
```

### ❌ ANTI-PATRÓN
```dart
// NO: System leyendo persistencia directamente
class RewardSystem {
  final GameController _gameController;  // ❌ Acoplamiento
  
  void finishRun() {
    _gameController.gold += coinsEarned;  // ❌ Modificación directa
  }
}

// CORRECTO: System prepara datos, servicio sincroniza
SessionSyncService.syncSessionToProgress(
  sessionState: _gameState,
  gameController: _gameController,
);
```

## Flujo de Integración Típico

```
1. STARTUP
   └─ combat_system_initializer.initializeCombatSystem()
      ├─ EnemyTypesCatalog.initializeDefaults()
      ├─ BossCatalog.initializeDefaults()
      ├─ ModifierCatalog.initializeDefaults()
      └─ WorldManager.initialize()

2. GAMEPLAY INIT (GameplayScreen.initState)
   └─ Crea Systems temporales:
      ├─ RewardSystem()
      ├─ ReviveSystem()
      └─ [otros systems]

3. GAMEPLAY LOOP
   └─ Controllers usan Catalogs:
      ├─ EnemyController lee AttackPattern
      ├─ PlayerController lee Player stats
      └─ Systems acumulan estado

4. GAMEPLAY END
   └─ SessionSyncService sincroniza:
      ├─ GameStateManager → GameState
      └─ GameState → SharedPreferences

5. CLEANUP
   └─ Systems destruidos, Catalogs permanecen
```

## Pendiente - Refactoring

- [ ] Mover `enemy_types.dart` a `catalogs/`
- [ ] Mover `boss_catalog.dart` a `catalogs/`
- [ ] Crear `game_logic/controllers/` (consolidar)
- [ ] Crear `game_logic/managers/` (mover WorldManager, ProjectileSystem)
- [ ] Crear `game_logic/factories/` (mover enemy_factory)
- [ ] Consolidar imports en todos los archivos

## Glosario

| Término | Significado |
|---------|-----------|
| Catalog | Definiciones estáticas (emum-like) que no cambian en gameplay |
| System | Lógica dinámica que mantiene estado mutable |
| Controller | Actualiza y controla comportamiento de una entidad |
| Manager | Gestor de un sistema global (Mundo, Proyectiles, etc) |
| Factory | Crea instancias complejas basadas en definiciones |
| Service | Utiliario que proporciona una funcionalidad (sync, storage, etc) |

---

**Última actualización**: 2026-04-12  
**Autor**: GitHub Copilot  
**Status**: Estructura propuesta, refactoring en progreso
