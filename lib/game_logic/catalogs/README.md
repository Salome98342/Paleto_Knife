## Catalogs - Datos Estáticos del Juego

Esta carpeta contiene **Catalogs**: definiciones de datos estáticas que almacenan información sobre enemigos, bosses, olas, etc.

### Estructura

```
catalogs/
├── enemy_types.dart          # Definiciones de 20+ tipos de enemigos
├── boss_catalog.dart         # Configuraciones de bosses multi-fase
├── enemy_modifiers.dart     # Modificadores (giant, armor, multiple)
├── wave_catalog.dart        # Progresiones de olas por región
└── README.md                # Este archivo
```

### Características Clave

**✓ Datos Estáticos**: Cada catalog contiene datos que NO cambian durante la sesión
**✓ Inicialización en Startup**: Inicializados en `combat_system_initializer.dart`
**✓ Sin Efectos Secundarios**: Solo getters, sin modificación de estado
**✓ Reutilizable**: Multiples sistemas pueden leerlos simultáneamente

### Ejemplo: EnemyTypesCatalog

```dart
// Definir enemigos del juego
class EnemyTypesCatalog {
  static final _definitions = <String, EnemyTypeDefinition>{
    'lavaPizza': EnemyTypeDefinition(
      name: 'Lava Pizza',
      region: Region.caribbean,
      element: ElementType.fire,
      baseHealth: 50,
    ),
    // ... 20+ enemigos más
  };

  // Inicializar en startup
  static void initializeDefaults() { /* ... */ }

  // Lecturas
  static Iterable<EnemyTypeDefinition> getAll() => _definitions.values;
  static EnemyTypeDefinition? getById(String id) => _definitions[id];
  static Iterable<EnemyTypeDefinition> getByRegion(Region region) => ...;
}
```

### Integración

Los catalogs son inicializados en:
```dart
// lib/game_logic/combat_system_initializer.dart
void initializeCombatSystem() {
  EnemyTypesCatalog.initializeDefaults();
  BossCatalog.initializeDefaults();
  ModifierCatalog.initializeDefaults();
  WaveCatalog.initializeDefaults();
}
```

Y utilizados por:
- `enemy_factory.dart` - Lee EnemyTypesCatalog para crear enemigos
- `boss_system/` - Lee BossCatalog para fases y comportamientos
- `wave_system/` - Lee WaveCatalog para progresiones

### Reglas de Diseño

❌ **NO HAGAS:**
- Modificar catalogs durante gameplay
- Acceder a datos internos privados
- Crear instances (son todas estáticas)
- Guardar referencias a objetos del catalog

✅ **SIEMPRE:**
- Lee via getters públicos
- Asume que los datos pueden cambiar entre versiones
- Usa copias si necesitas modificar
- Inicializa en startup

### Próximas Adiciones

Considera agregar catalogs para:
- `knife_catalog.dart` - Definiciones de cuchillos
- `jewel_catalog.dart` - Definiciones de joyas
- `technique_catalog.dart` - Catálogo tec técnicas del chef
