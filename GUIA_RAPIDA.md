# 🚀 Guía Rápida - Paleto Knife

## Instalación y Ejecución en 5 Minutos

### 1️⃣ Prerequisites
- **Flutter SDK** (3.9+): https://flutter.dev/docs/get-started/install
- **Dart SDK** (incluido con Flutter)
- Un dispositivo/emulador Android, iOS, o navegador web

### 2️⃣ Setup Inicial

```bash
# Clonar el repositorio
cd "C:\Users\User\OneDrive\Escritorio"
cd "Paleto Knife"

# Instalar dependencias
flutter pub get
```

### 3️⃣ Correr el Juego

```bash
# En emulador/dispositivo Android (por defecto)
flutter run

# En navegador web
flutter run -d chrome

# En Windows (aplicación nativa)
flutter run -d windows

# En iOS (requiere macOS)
flutter run -d ios
```

### 4️⃣ Desarrollo

```bash
# Hot reload (Recarga código sin reiniciar)
flutter run
# En la terminal: presiona 'r'

# Hot restart (Reinicia app pero mantiene estado)
# En la terminal: presiona 'R'

# Ejecutar análisis estático
dart analyze

# Ejecutar tests
flutter test
```

---

## Estructura Básica para Entender el Código

### Controladores (Controllers)
Manejan la lógica y estado del juego:

```
lib/controllers/
├── chef_controller.dart     → Gestiona chefs del jugador
├── combat_controller.dart   → Control del sistema de combate
├── economy_controller.dart  → Dinero, gemas, currency
├── game_controller.dart     → Estado global del juego
└── world_controller.dart    → Mapa y locaciones
```

**Cómo usarlos**:
```dart
final chefCtrl = context.watch<ChefController>();
final combat = context.watch<CombatController>();
```

### Pantallas (Screens)
Interfaces visuales principales:

```
lib/screens/
├── main_layout.dart         → Pantalla principal del juego
├── gameplay_screen.dart     → Pantalla de combate
├── world_view.dart          → Mapa interactivo
├── gacha_store_view.dart    → Tienda de gacha
├── chefs_view.dart          → Lista de chefs
└── quests_view.dart         → Misiones
```

### Servicios (Services)
Funcionalidades globales:

```
lib/services/
├── audio_service.dart       → Música y sonido (BGM/SFX)
├── storage_service.dart     → Guardar/cargar datos
└── ad_service.dart          → Sistema de anuncios
```

---

## Comandos Útiles

### Cleaning & Rebuilding
```bash
# Limpia outputs de build anteriores
flutter clean

# Obtiene dependencias nuevamente
flutter pub get

# Rebuilding completo
flutter clean && flutter pub get && flutter run
```

### Debugging
```bash
# Ver widgets siendo rebuildeados
flutter run --track-widget-creation

# Abrir DevTools
flutter pub global activate devtools
devtools

# Run con logs detallados
flutter run -v
```

### Build para Producción
```bash
# Android APK
flutter build apk --release

# App Bundle para Play Store
flutter build appbundle --release

# Web deployment
flutter build web --web-renderer html --release
# Luego subir el contenido de 'build/web/' a un servidor

# Windows
flutter build windows --release
```

---

## Primeras Cosas que Ver

### 1. Entendiendo el Combate
Archivo: `lib/game_logic/combat_system/combat_system.dart`
- Define cómo se calcula daño
- Modificadores de enemigos
- Lógica de olas

### 2. Entendiendo los Enemigos
Archivo: `lib/game_logic/enemy_system/enemy_types.dart`
- 21 tipos de enemigos
- Elementos y debilidades
- Stats base

### 3. Entendiendo el Flujo Principal
Archivo: `lib/main.dart`
- Punto de entrada
- Inicialización de servicios
- Setup del tema retro

---

## Troubleshooting Común

| Problema | Solución |
|----------|----------|
| `Flutter command not found` | Agregar Flutter al PATH: https://flutter.dev/docs/get-started/install |
| `Dependencias no se instalan` | `flutter pub get` o `flutter clean && flutter pub get` |
| `App no corre en Chrome` | Verificar `flutter doctor -v`, especial Chrome check |
| `Errores de assets (fuentes, imágenes)` | Ejecutar `flutter pub get` y `flutter clean` |
| `Errores de audio en web` | Assets pueden no cargar en dev web, usar `flutter build web` |

---

## Cómo Modificar el Juego

### Agregar un nuevo tipo de enemigo
1. Editar: `lib/game_logic/enemy_system/enemy_types.dart`
2. Agregar entrada en catálogo
3. Hot reload

### Cambiar música/sonidos
1. Colocar archivo .mp3 en `assets/audio/`
2. Actualizar `pubspec.yaml` con el asset
3. `flutter pub get`
4. Referenciar en `AudioService`

### Diseñar nueva pantalla
1. Crear archivo en `lib/screens/my_screen.dart`
2. Extender `StatefulWidget`
3. Agregar ruta en `main_layout.dart`
4. Usar `Provider` para acceder a controladores

---

## Recurso Rápido: Añadir un botón que realiza una acción

```dart
GestureDetector(
  onTap: () {
    // Tu código aquí
    final controller = context.read<GameController>();
    controller.doSomething();
  },
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: Colors.black)),
    child: Text('Click Me'),
  ),
)
```

---

## Próximos Pasos

1. **Explorar el código** - Revisa `lib/main.dart` como punto de entrada
2. **Ejecutar en tu dispositivo** - `flutter run`
3. **Modificar y experimentar** - Usa hot reload para iteración rápida
4. **Consultar README.md** - Para descripción del proyecto
5. **Ver ARQUITECTURA.md** - Para estructura más detallada

---

**¿Preguntas o problemas?** Revisa la consola de flutter con `-v` para logs detallados.

Última actualización: Abril 2026
