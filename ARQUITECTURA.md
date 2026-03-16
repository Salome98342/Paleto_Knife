# Knife Clicker - Arquitectura del Proyecto

## Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
├── models/                        # Modelos de datos
│   ├── upgrade.dart              # Modelo de mejoras/upgrades
│   └── game_state.dart           # Estado completo del juego
├── controllers/                   # Lógica de negocio
│   └── game_controller.dart      # Controlador principal del juego
├── services/                      # Servicios externos
│   └── storage_service.dart      # Persistencia de datos (SharedPreferences)
├── widgets/                       # Widgets reutilizables
│   ├── knife_button.dart         # Botón principal del cuchillo
│   ├── upgrade_card.dart         # Tarjeta de mejora
│   └── stats_panel.dart          # Panel de estadísticas
└── screens/                       # Pantallas de la aplicación
    └── game_screen.dart          # Pantalla principal del juego
```

## Descripción de Módulos

### 1. **Models** (`models/`)

Contiene las clases de datos que representan el estado del juego.

- **`upgrade.dart`**: Define el modelo `Upgrade` que representa una mejora en el juego.
  - Propiedades: id, nombre, descripción, costo base, multiplicador de costo, tipo, efecto, nivel
  - Métodos: cálculo de costo actual, efecto actual, compra de niveles
  - Serialización: `toJson()` y `fromJson()` para persistencia

- **`game_state.dart`**: Define el modelo `GameState` que almacena todo el estado del juego.
  - Propiedades: puntos, puntos totales, puntos por click, puntos por segundo, multiplicador global, total de clicks, lista de upgrades
  - Serialización completa para guardar/cargar el progreso

### 2. **Controllers** (`controllers/`)

Contiene la lógica central del juego usando el patrón ChangeNotifier.

- **`game_controller.dart`**: Controlador principal que gestiona toda la lógica del juego.
  - Inicialización del juego (carga de datos guardados)
  - Manejo de clicks del jugador
  - Sistema de compra de mejoras
  - Recalculo automático de estadísticas
  - Generación automática de puntos (auto-clickers)
  - Guardado automático periódico
  - Cálculo de puntos offline (puntos generados mientras la app está cerrada)

### 3. **Services** (`services/`)

Servicios que manejan operaciones externas como almacenamiento.

- **`storage_service.dart`**: Servicio de persistencia usando SharedPreferences.
  - Guardar estado del juego
  - Cargar estado del juego
  - Verificar existencia de datos guardados
  - Borrar progreso (reset)

### 4. **Widgets** (`widgets/`)

Componentes visuales reutilizables de la interfaz.

- **`knife_button.dart`**: Botón animado del cuchillo principal.
  - Animación de escala al presionar
  - Feedback táctil visual
  - Sombras dinámicas

- **`upgrade_card.dart`**: Tarjeta que muestra información de una mejora.
  - Muestra nombre, descripción, nivel y costo
  - Indicador visual de si se puede comprar
  - Colores diferentes según el tipo de mejora
  - Formato de números grandes (K, M, B)

- **`stats_panel.dart`**: Panel superior con estadísticas del jugador.
  - Muestra puntos actuales (grande y destacado)
  - Estadísticas secundarias: puntos por click, por segundo, multiplicador
  - Total de clicks realizados
  - Diseño con gradiente y sombras

### 5. **Screens** (`screens/`)

Pantallas completas de la aplicación.

- **`game_screen.dart`**: Pantalla principal del juego.
  - Integra todos los widgets
  - Maneja la interacción con el GameController
  - Animaciones de feedback al hacer click
  - Lista de mejoras disponibles
  - Diálogo de confirmación para reset

### 6. **Main** (`main.dart`)

Punto de entrada de la aplicación.
- Configuración de orientación (solo vertical para móviles)
- Configuración del tema de la app
- Inicialización de la primera pantalla

## Flujo de Datos

1. **Inicio de la App**:
   - `main.dart` inicia la aplicación
   - `GameScreen` se monta y crea un `GameController`
   - `GameController` intenta cargar datos guardados con `StorageService`
   - Si hay datos, se cargan; si no, se crea un nuevo juego
   - Se calculan puntos offline si aplica

2. **Click del Usuario**:
   - Usuario toca el `KnifeButton`
   - `GameScreen` llama a `gameController.handleClick()`
   - `GameController` actualiza puntos y notifica listeners
   - `GameScreen` se reconstruye mostrando nuevos valores
   - Animación visual de "+puntos" aparece

3. **Compra de Mejora**:
   - Usuario toca una `UpgradeCard`
   - `GameScreen` llama a `gameController.tryBuyUpgrade()`
   - `GameController` verifica si hay suficientes puntos
   - Si sí, resta puntos, aumenta nivel de upgrade, recalcula estadísticas
   - Notifica listeners y la UI se actualiza

4. **Generación Automática**:
   - `GameController` ejecuta un Timer cada 0.1 segundos
   - Si hay mejoras de auto-click, genera puntos automáticamente
   - Actualiza el estado y notifica a la UI

5. **Guardado**:
   - Timer de guardado automático ejecuta cada 30 segundos
   - `GameController` serializa el `GameState` a JSON
   - `StorageService` guarda en SharedPreferences
   - También se guarda al cerrar la app

## Patrones de Diseño Utilizados

1. **MVC (Model-View-Controller)**:
   - Models: `Upgrade`, `GameState`
   - Views: Widgets y Screens
   - Controller: `GameController`

2. **Observer Pattern (ChangeNotifier)**:
   - `GameController` extiende `ChangeNotifier`
   - Widgets escuchan cambios y se reconstruyen automáticamente

3. **Service Pattern**:
   - `StorageService` abstrae la lógica de persistencia
   - Fácil de cambiar a otra forma de almacenamiento

4. **Singleton (implícito)**:
   - Un solo `GameController` por sesión de juego

## Escalabilidad

El proyecto está preparado para extensiones futuras:

### Fácil de agregar:
- **Nuevas mejoras**: Solo agregar en el array de `_createInitialGameState()`
- **Nuevos tipos de upgrade**: Agregar al enum `UpgradeType` y actualizar lógica
- **Skins de cuchillos**: Agregar propiedad en `GameState` y cambiar icono en `KnifeButton`
- **Logros**: Crear modelo `Achievement` y sistema de verificación en `GameController`
- **Sonidos**: Agregar en el momento del click y compra de mejoras
- **Efectos visuales**: Expandir animaciones en widgets
- **Niveles del jugador**: Agregar sistema de XP basado en puntos totales
- **Economía completa**: Múltiples monedas, prestigio, etc.

### Posibles mejoras:
- Usar un gestor de estado más robusto (Riverpod, Bloc)
- Separar configuración de upgrades en archivo JSON
- Añadir pruebas unitarias y de integración
- Implementar analytics para trackear progresión
- Añadir sincronización en la nube (Firebase)

## Dependencias

- **flutter**: Framework principal
- **shared_preferences**: Persistencia local de datos

## Ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run

# Compilar APK para Android
flutter build apk --release
```

## Notas Técnicas

- El juego guarda automáticamente cada 30 segundos
- Los puntos offline se calculan al abrir la app basándose en el tiempo transcurrido
- La animación del auto-clicker se ejecuta cada 0.1 segundos para suavidad visual
- Los costos de upgrades escalan exponencialmente para balance del juego
- La UI es completamente responsive y optimizada para móviles
