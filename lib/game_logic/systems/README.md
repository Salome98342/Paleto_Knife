## Systems - Lógica de Juego Dinámica

Esta carpeta contiene **Systems**: lógica interactiva que cambia durante el gameplay.

### Estructura

```
systems/
├── gacha_system.dart        # Pity-based gacha para técnicas
├── economy_system.dart      # Gestión de recursos (oro, gemas, etc)
├── reward_system.dart       # Cálculo de recompensas finales de sesión
├── revive_system.dart       # Lógica de revivir con ads
├── session_sync_service.dart # Sincronización sesión → persistencia
└── README.md                # Este archivo
```

### Características Clave

**✓ Estado Mutable**: Mantienen estado que cambia durante gameplay
**✓ Sin inicialización Global**: Se crean cuando se necesitan (no en startup)
**✓ Con Efectos Secundarios**: Pueden modificar GameState
**✓ Inyectables**: Aceptan dependencias en constructor

### Ejemplo: GachaSystem

```dart
/// Sistema de Gacha con Pity para técnicas
class GachaSystem extends ChangeNotifier {
  int _pityCounter = 0;
  
  GachaSystem({int initialPity = 0}) : _pityCounter = initialPity;

  /// Realizar un gacha
  Technique pull() {
    _pityCounter++;
    
    // Pity: garantizado cada 50 tiradas
    bool guaranteed = _pityCounter >= 50;
    
    final technique = _selectTechnique(guaranteed);
    
    if (guaranteed) {
      _pityCounter = 0;  // Reset pity
    }
    
    notifyListeners();
    return technique;
  }
}
```

### Responsabilidades por System

#### gacha_system.dart
- Manejo de pity counter
- Lógica de gacha 4-star vs 5-star
- Probabilidades dinámicas

#### economy_system.dart
- Cálculo de ganancias (oro base + bonificadores)
- Gastos y validación de recursos
- Rewards offline

#### reward_system.dart
- Cálculo de recompensas finales de sesión
- Multiplicadores (x2 con ads)
- Estadísticas de runs

#### revive_system.dart
- Lógica de oferta de revive
- Integración con ads
- Recompensas post-revive

#### session_sync_service.dart
- Sincroniza recompensas de sesión a GameState persistente
- Validación de datos antes de sincronizar
- Logging de transferencia

### Patrón de Uso

```dart
// 1. Crear system (típicamente en GameplayScreen.initState)
late GachaSystem _gachaSystem = GachaSystem();

// 2. Usar system durante gameplay
void onPullButtonPressed() {
  final technique = _gachaSystem.pull();
  _addTechniqueToInventory(technique);
}

// 3. Acceder a estado si necesario
int get currentPity => _gachaSystem.pityCounter;

// 4. Sincronizar al finalizar (si aplica)
await SessionSyncService.syncSessionToProgress(
  sessionState: _gameState,
  gameController: _gameController,
);
```

### Ciclo de Vida

```
INICIO SESIÓN
  ↓
Systems creados (GachaSystem, RewardSystem, etc)
  ↓
GAMEPLAY ACTIVO
  ↓
Systems acumulan estado (pulls, recompensas, etc)
  ↓
FIN SESIÓN
  ↓
SessionSyncService transfiere datos a persistencia
  ↓
Systems destruidos
```

### Reglas de Diseño

❌ **NO HAGAS:**
- Crear systems en startup (son temporales)
- Acceder a catalogs para modificar datos
- Mezclar lógica de sesión con persistencia
- Tener estado que no se sincroniza

✅ **SIEMPRE:**
- Extiende ChangeNotifier si el estado cambia frecuentemente
- Valida antes de modificar estado (économy.spend())
- Sincroniza al finalizar GameplayScreen
- Prueba resiliencia a datos inválidos

### Integración Actual

| System | Creado en | Sincronización |
|--------|-----------|----------------|
| RewardSystem | GameplayScreen.initState | Después de ganar |
| ReviveSystem | GameplayScreen.initState | Después de revive |
| GachaSystem | ChefController operaciones | Manual (Gacha Store) |
| EconomyController | main.dart (Provider) | Auto-save GameController |

### TODO - Próximas Mejoras

- [ ] Crear shop_system.dart (compras en tienda)
- [ ] Crear upgrade_system.dart (mejoras de técnicas)
- [ ] Crear battle_modifiers.dart (modificadores temporales de combate)
- [ ] Centralizar inyección de dependencias
