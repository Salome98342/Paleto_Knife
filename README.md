# Knife Clicker

Un juego híbrido de **clicker incremental** y **combate de acción** desarrollado en Flutter para dispositivos móviles Android.

## 🎮 Descripción

Knife Clicker es un juego que combina dos modos de juego:

### 🔘 Modo Clicker (Incremental)
Juego tipo clicker clásico donde acumulas puntos haciendo click en un cuchillo y compras mejoras para:
- Aumentar puntos por click
- Generar puntos automáticamente 
- Multiplicar tus ganancias

### ⚔️ Modo Combate (Acción)
Modo de acción donde controlas un personaje que debe derrotar enemigos a través de diferentes mundos con:
- Disparo automático del jugador y enemigos
- Movimiento horizontal para esquivar ataques
- Poder especial con cooldown
- Escalado progresivo de dificultad por mundos

## ✨ Características Principales

### Modo Clicker
- ✅ Sistema de click con feedback visual animado
- ✅ Múltiples tipos de mejoras (click, auto-generación, multiplicadores)
- ✅ Progresión exponencial balanceada
- ✅ Guardado automático cada 30 segundos
- ✅ Puntos offline (genera puntos mientras la app está cerrada)
- ✅ Interfaz responsive optimizada para móviles

### Modo Combate
- ✅ Sistema de proyectiles con detección de colisiones
- ✅ Movimiento horizontal del jugador
- ✅ Disparo automático para jugador y enemigos
- ✅ Poder especial temporal con indicador visual de cooldown
- ✅ Sistema de mundos con escalado progresivo de dificultad
- ✅ Barras de vida para jugador y enemigos
- ✅ Efectos visuales y animaciones fluidas

## 📁 Arquitectura del Proyecto

```
lib/
├── main.dart                           # Punto de entrada
├── models/                             # Modelos de datos
│   ├── upgrade.dart                   # Modelo de mejoras (clicker)
│   ├── game_state.dart                # Estado del juego clicker
│   ├── projectile.dart                # Modelo de proyectiles
│   ├── player.dart                    # Modelo del jugador
│   ├── enemy.dart                     # Modelo de enemigos
│   └── world.dart                     # Modelo de mundos
├── controllers/                        # Controladores de lógica
│   ├── game_controller.dart           # Controlador del modo clicker
│   └── combat_controller.dart         # Controlador del modo combate
├── game_logic/                         # Lógica específica de juego
│   ├── projectile_system.dart         # Sistema de proyectiles
│   ├── player_controller.dart         # Control del jugador
│   ├── enemy_controller.dart          # Control de enemigos
│   └── world_manager.dart             # Gestión de mundos
├── services/                           # Servicios externos
│   └── storage_service.dart           # Persistencia con SharedPreferences
├── widgets/                            # Componentes visuales
│   ├── knife_button.dart              # Botón del cuchillo (clicker)
│   ├── upgrade_card.dart              # Tarjeta de mejora
│   ├── stats_panel.dart               # Panel de estadísticas
│   ├── movement_controls.dart         # Controles de movimiento
│   ├── power_button.dart              # Botón de poder especial
│   └── combat_arena.dart              # Arena de combate
└── screens/                            # Pantallas
    ├── menu_screen.dart               # Menú principal
    ├── game_screen.dart               # Pantalla modo clicker
    └── combat_screen.dart             # Pantalla modo combate
```

## 🎯 Mecánicas de Combate

### Sistema de Disparo Automático
- El jugador dispara proyectiles automáticamente hacia arriba
- Los enemigos disparan proyectiles hacia abajo
- La velocidad de disparo se basa en `attackSpeed` configurable
- Los proyectiles se destruyen al colisionar o salir de pantalla

### Movimiento del Jugador
- Botones de movimiento izquierda/derecha en la interfaz
- El jugador se mueve horizontalmente para esquivar proyectiles
- El movimiento está limitado a los bordes de la pantalla
- Velocidad de movimiento configurable en el modelo Player

### Poder Especial
- Se activa presionando el botón de poder
- Efectos durante el poder activo:
  - **x2 daño** en los proyectiles del jugador
  - **+50% velocidad de ataque**
  - Efecto visual brillante en el jugador
- Duración: 5 segundos (configurable)
- Cooldown: 15 segundos (configurable)
- Indicador visual circular muestra el progreso

### Sistema de Mundos
Los mundos escalan progresivamente:

| Mundo | Nombre | Dificultad | Recompensas |
|-------|--------|-----------|-------------|
| 1 | Novato | x1.0 | x1.0 |
| 2 | Intermedio | x1.5 | x1.5 |
| 3 | Avanzado | x2.0 | x2.0 |
| 4 | Maestro | x3.0 | x3.0 |

**Escalado por mundo:**
- **Velocidad de ataque enemigo**: +10% por nivel
- **Daño enemigo**: +15% por nivel
- **Vida enemigo**: +50% por nivel
- **Estadísticas del jugador**: también escalan al avanzar

### Detección de Colisiones
- Sistema de hitboxes rectangulares
- Proyectiles del jugador detectan colisión con enemigos
- Proyectiles enemigos detectan colisión con el jugador
- Los proyectiles se destruyen al impactar

## 🚀 Instalación y Ejecución

### Requisitos
- Flutter SDK 3.9.2 o superior
- Dart 3.9.2 o superior
- Android Studio o VS Code con extensiones de Flutter

### Pasos

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd knife_clicker
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en dispositivo/emulador**
```bash
flutter run
```

4. **Compilar APK para Android**
```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2  # Persistencia local
```

## 🎨 Características Técnicas

### Patrones de Diseño
- **MVC**: Separación de Modelos, Vistas y Controladores
- **Observer (ChangeNotifier)**: Actualización reactiva de la UI
- **Service Pattern**: Abstracción de servicios externos
- **Component-based**: Widgets reutilizables y modulares

### Rendimiento
- Game loop optimizado a 60 FPS
- Actualización eficiente de proyectiles
- Eliminación automática de proyectiles inactivos
- Gestión adecuada de memoria con dispose()

### Persistencia
- Guardado automático cada 30 segundos (modo clicker)
- Serialización JSON de todo el estado del juego
- Cálculo de puntos offline basado en tiempo transcurrido

## 🎮 Cómo Jugar

### Modo Clicker
1. Haz click en el cuchillo para ganar puntos
2. Compra mejoras cuando tengas suficientes puntos
3. Mejoras de **Click Power**: aumentan puntos por click
4. Mejoras de **Auto Clicker**: generan puntos automáticamente
5. Mejoras de **Multiplicador**: amplifican todas las ganancias
6. Tu progreso se guarda automáticamente

### Modo Combate
1. Usa los botones ⬅️ ➡️ para moverte y esquivar proyectiles
2. Tu personaje dispara automáticamente hacia arriba
3. Evita los proyectiles enemigos
4. Presiona el botón ⚡ para activar tu poder especial
5. Derrota al enemigo para avanzar al siguiente mundo
6. En cada mundo, tus estadísticas y las del enemigo aumentan

## 🔧 Configuración del Juego

### Ajustar Dificultad del Modo Combate

Edita `lib/models/player.dart`:
```dart
Player({
  this.health = 100,              // Vida inicial
  this.attackSpeed = 1.0,         // Disparos por segundo
  this.baseDamage = 10,           // Daño base
  this.movementSpeed = 300,       // Velocidad de movimiento
  this.powerDuration = 5.0,       // Duración del poder
  this.powerCooldown = 15.0,      // Cooldown del poder
})
```

Edita `lib/models/enemy.dart`:
```dart
Enemy({
  this.attackSpeed = 0.5,         // Disparos por segundo
  this.baseDamage = 5,            // Daño base
})
```

### Ajustar Balance del Modo Clicker

Edita `lib/controllers/game_controller.dart` en `_createInitialGameState()`:
```dart
Upgrade(
  baseCost: 10,                   // Costo inicial
  costMultiplier: 1.15,           // Escalado de costo
  effect: 1,                      // Efecto base
)
```

## 🌟 Futuras Mejoras

### Planeadas
- [ ] Más tipos de enemigos con patrones únicos
- [ ] Jefes finales por mundo
- [ ] Sistema de logros
- [ ] Skins de personajes y cuchillos
- [ ] Efectos de sonido y música
- [ ] Más poderes especiales
- [ ] Sistema de estadísticas y records
- [ ] Sincronización en la nube (Firebase)

### Posibles Expansiones
- [ ] Modo historia
- [ ] Multijugador cooperativo
- [ ] Eventos especiales limitados
- [ ] Sistema de clanes
- [ ] Tabla de clasificación global

## 📄 Licencia

Este proyecto está desarrollado como demostración educativa.

## 👨‍💻 Desarrollo

Desarrollado completamente en Flutter siguiendo mejores prácticas de:
- Arquitectura limpia y escalable
- Código modular y reutilizable
- Documentación completa
- Gestión eficiente de recursos
- Optimización para dispositivos móviles

---

**Versión:** 1.0.0  
**Última actualización:** 2026
