# 🏗️ Arquitectura - Paleto Knife

## Visión General

Paleto Knife es una aplicación Flutter que implementa un **clicker game/autobattler** con arquitectura en capas basada en el patrón Provider para manejo de estado.

```
┌─────────────────────────────────────────────────────┐
│                   UI LAYER (Screens)                │
│        (Widgets que renderean la interfaz)          │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│            PROVIDER STATE LAYER                     │
│      (ChangeNotifier Controllers - Lógica)          │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│          BUSINESS LOGIC LAYER                       │
│  (Combat System, Enemy System, Wave System)         │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│          DATA & SERVICES LAYER                      │
│  (Storage, Audio, Models, Flame Components)         │
└─────────────────────────────────────────────────────┘
```

---

## Estructura de Directorios

### `/lib` - Código Principal

#### `main.dart`
- **Responsabilidad**: Punto de entrada de la aplicación
- **Qué hace**: Inicializa Provider, configura tema, carga servicios
- **Dependencias**: Material, Provider, AudioService, StorageService

#### `/controllers` - Controladores de Estado
Utilizan `ChangeNotifier` para notificar cambios a widgets observadores.

| Archivo | Responsabilidad |
|---------|-----------------|
| `game_controller.dart` | Estado global del juego (nivel, experiencia) |
| `chef_controller.dart` | Gestión de chefs (lista, selección, stats) |
| `combat_controller.dart` | Orquestación de combates (turno por turno/ automático) |
| `economy_controller.dart` | Dinero, gemas y currency |
| `world_controller.dart` | Mapa, locaciones, selección de región |

**Patrón de uso**:
```dart
final controller = context.watch<GameController>();  // Se rebuilda si cambia
final ctrl = context.read<ChefController>();         // Solo lectura, sin rebuild
```

#### `/screens` - Pantallas Principales
Componentes visuales principales del juego. Cada uno es un `StatefulWidget` que observa controladores.

| Pantalla | Contenido |
|----------|----------|
| `main_layout.dart` | Layout principal - barra de navegación + contenido |
| `gameplay_screen.dart` | Pantalla de combate automático |
| `world_view.dart` | Mapa interactivo con locaciones |
| `gacha_store_view.dart` | Tienda de gacha, tiradas de chefs |
| `chefs_view.dart` | Inventario y gestión de chefs |
| `quests_view.dart` | Misiones diarias y especiales |
| `profile_screen.dart` | Perfil del jugador |
| `settings_dialog.dart` | Configuración (volumen, idioma, etc.) |

#### `/widgets` - Componentes Reutilizables
Widgets menores que se usan en múltiples pantallas.

| Widget | Uso |
|--------|-----|
| `retro_style.dart` | Tema visual retro (colores, fuentes, estilos) |
| `element_type_table_widget.dart` | Tabla de 8 tipos de elementos |
| `enemy_card_widget.dart` | Card que muestra un enemigo |
| `hud_overlay.dart` | Overlay HUD durante combate |
| `pause_menu_overlay.dart` | Menú de pausa |
| `game_over_overlay.dart` | Pantalla de game over |
| etc. | Otros componentes |

#### `/services` - Servicios Globales
Servicios singleton que se inicializan en `main.dart` y se usan en toda la app.

| Servicio | Propósito |
|---------|-----------|
| `audio_service.dart` | Manejo de música (BGM) y efectos (SFX) |
| `storage_service.dart` | Persistencia en SharedPreferences |
| `ad_service.dart` | Sistema de anuncios |
| `audio_game_state.dart` | Estado de audio sincronizado con juego |

#### `/models` - Modelos de Datos
Clases que representan datos del juego.

| Modelo | Representa |
|--------|-----------|
| `game_state.dart` | Estado persistente del juego |
| `player.dart` | Datos del jugador principal |
| `chef.dart` | Sous chef (atributos, nivel, equipo) |
| `enemy.dart` | Enemigo en combate |
| `element_type.dart` | Tipo de elemento (enum + info) |
| `equipment.dart` | Equipo (arma, armadura, etc.) |
| `technique.dart` | Técnica especial |
| `sous_chef.dart` | Sous chef específico |
| `upgrade.dart` | Mejora de stats |
| `gacha_result.dart` | Resultado de tirada gach |
| `world.dart` | Mapa y locaciones |
| `projectile.dart` | Proyectl en combate |
| `reset_bonus.dart` | Bonificaciones de reset |

#### `/game` - Lógica Flame Engine
Componentes y sistemas de Flame (engine gráfico).

```
/game
├── /components         # Componentes renderables
│   ├── player_component.dart
│   ├── enemy_component.dart
│   └── effect_component.dart
├── /enemies           # Datos y comportamiento de enemigos
└── /player            # Componentes del jugador
```

#### `/game_logic` - Sistemas de Juego
Lógica de reglas independiente de la UI.

```
/game_logic
├── /combat_system
│   ├── combat_system.dart      # Cálculo de daño y flujo
│   ├── damage_calculator.dart  # Fórmulas de daño
│   └── modifier_system.dart    # Modificadores (Resist, Strong, etc.)
├── /enemy_system
│   ├── enemy_types.dart        # Catálogo de 21 enemigos
│   ├── enemy_modifiers.dart    # Modificadores (Armor, etc.)
│   └── boss_system/           # Lógica de bosses
└── /wave_system
    └── wave_manager.dart       # Olas de enemigos antes de boss
```

#### `/assets` - Recursos Estáticos
```
/assets
├── /audio
│   ├── /menu
│   │   └── menu_song.mp3
│   ├── /gameplay
│   │   └── gameplay_song.mp3
│   └── /sfx
│       ├── attack.mp3
│       ├── heal.mp3
│       └── ...
└── /images
    ├── /enemies
    ├── /equipment
    └── /ui
```

---

## Flujo de Datos

### Ciclo Típico de Actualización

```
1. Usuario interactúa (toca botón)
                ↓
2. Método en Controller ejecuta
   (ej: controller.doSomething())
                ↓
3. Controller llama lógica de negocio
   (ej: CombatSystem.calculateDamage())
                ↓
4. Controller actualiza su estado interno
   (ej: this.health = newHealth)
                ↓
5. Controller llama notifyListeners()
                ↓
6. Todos los Widgets observadores se rebuildan
   con el nuevo estado
                ↓
7. UI renderiza cambios
```

### Ejemplo Práctico

```dart
// En pantalla (Gameplay Screen)
Consumer<CombatController>(
  builder: (context, combat, _) {
    return GestureDetector(
      onTap: () {
        // Usuario toca pantalla
        combat.executeAttack();  // 1. Llama método del controller
      },
      child: Text('Enemy HP: ${combat.enemyHP}'),  // 7. Renderiza nuevo valor
    );
  },
);

// En CombatController
class CombatController extends ChangeNotifier {
  void executeAttack() {
    // 3. Lógica de negocio
    int damage = CombatSystem.calculateDamage(player, enemy);
    
    // 4. Actualiza estado
    enemyHP -= damage;
    
    // 5. Notifica observadores
    notifyListeners();
  }
}
```

---

## Patrones Implementados

### 1. Provider Pattern (State Management)
- **Qué**: Controladores extenden `ChangeNotifier`
- **Dónde**: `main.dart` con `MultiProvider`
- **Beneficio**: Desacoplamiento entre UI y lógica, reutilización fácil

### 2. Dependency Injection
```dart
// En main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => GameController()),
    ChangeNotifierProvider(create: (_) => ChefController()),
    // ...
  ],
)

// En screens
final game = context.read<GameController>();
```

### 3. Repository Pattern (implicit)
- `StorageService` maneja persistencia
- `AudioService` maneja reproducción de audio
- Separa interfaz de implementación

### 4. Singleton Services
- `AudioService`
- `StorageService`
- Instanciados una sola vez en `main.dart`

---

## Diagrama de Dependencias

```
main.dart (punto de entrada)
  ├── AudioService (singleton)
  ├── StorageService (singleton)
  │
  ├── GameController (ChangeNotifier)
  │   └── observado por: main_layout, gameplay_screen
  │
  ├── ChefController (ChangeNotifier)
  │   └── observado por: chefs_view, gameplay_screen
  │
  ├── CombatController (ChangeNotifier)
  │   └── observado por: gameplay_screen
  │   └── usa: CombatSystem, EnemySystemsystem, WaveSystem
  │
  ├── EconomyController (ChangeNotifier)
  │   └── observado por: gacha_store_view, profile_screen
  │
  └── WorldController (ChangeNotifier)
      └── observado por: world_view
```

---

## Flujos Principales

### 🎮 Flujo de Combate

```
user toca "start combat"
        ↓
CombatController.startCombat()
        ↓
CombatController crea enemigos (WaveSystem)
        ↓
CombatController auto-simula turnos en loop
        ↓
por cada turno:
  - CombatSystem.calculateDamage()
  - Actualiza HP
  - CombatController.notifyListeners() → UI rebuilda
        ↓
si enemigo muere:
  - EconomyController recibe dinero
  - Wave siguiente o Boss
        ↓
si derrota:
  - GameOver Overlay
  - Reset combat
```

### 🎲 Flujo de Gacha

```
usuario toca "pull"
        ↓
verifica si tiene gemas (EconomyController)
        ↓
genera número aleatorio
        ↓
determina rareza según tasas
        ↓
busca chef aleatorio de esa rareza
        ↓
GachaRevealOverlay anima revelación
        ↓
ChefController agrega chef a inventario
        ↓
StorageService guarda cambio
```

---

## Convenciones de Código

### Nombrado de Archivos
- Minúsculas con guiones: `my_controller.dart`
- Clases con PascalCase: `class MyController`
- Variables con camelCase: `myVariable`

### Estructura de Clase Controller
```dart
class MyController extends ChangeNotifier {
  // 1. Propiedades privadas
  int _value = 0;
  
  // 2. Getters
  int get value => _value;
  
  // 3. Métodos
  void doSomething() {
    _value++;
    notifyListeners();
  }
}
```

### Estructura de Pantalla
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyController>(
      builder: (context, controller, _) {
        return Center(
          child: Text(controller.value.toString()),
        );
      },
    );
  }
}
```

---

## Optimizaciones Implementadas

1. **Consolidación de Audio Service**: Un único `AudioService` extendiendo `ChangeNotifier`
2. **Eliminación de duplicados**: Removidos servicios duplicados (AudioManager, etc.)
3. **Lazy loading de widgets**: Widgets se cargan solo cuando son visibles
4. **Asset caching**: SharedPreferences cachea datos persistentes

---

## Posibles Mejoras Futuras

1. **Riverpod/Bloc**: Migrar de Provider a sistema más robusto
2. **Database local**: Pasar de SharedPreferences a Hive/Isar
3. **Networking**: Sincronización con servidor backend
4. **Modularización**: Dividir en packages separados por feature
5. **Testing**: Aumentar cobertura de unit tests

---

Última actualización: Abril 2026
