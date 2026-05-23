# 🔪 Paleto Knife 

## Nombre del proyecto
Paleto Knife 

## Descripción general
**Paleto Knife** es un juego Bullet Hell desarrollado en **Flutter** con un estilo visual retro de 8 bits. El jugador entrena chefs (sous chefs) para combatir contra enemigos, mejora su equipo, realiza tiradas de gacha y explora diferentes regiones del mundo para progresar en el juego.

## Gameplay y mecánicas (Bullet Hell clásico)
Paleto Knife fusiona mecánicas de /progresión con combate en tiempo real al estilo "bullet hell" clásico. Puntos clave:

- El jugador controla un chef que se mueve arrastrando (pan) en la pantalla; el jugador dispara automáticamente hacia arriba.
- Controles principales: arrastrar para mover, doble-tap para dash (dash otorga invulnerabilidad breve y genera una explosión circular de proyectiles).
- Enemigos utilizan patrones de ataque configurables: `straight`, `aimed`, `spread`, `radial`.
- Los bosses pueden tener patrones tipo Bullet Hell (radial/spread con numerosas balas y fases). Existe un helper para probar bosses (`spawnBoss`) en el engine.
- Colisiones: proyectiles usan pooling; las balas de enemigo dañan al jugador si el hitbox colisiona.
- Sistema de olas: el `PaletoGame` gestiona spawn, conteo de muertes, y aparición de bosses.

Consejos de gameplay y balance

- Ajusta `enemiesToKillNextWave` y `_currentSpawnInterval` en [lib/game/paleto_game.dart](lib/game/paleto_game.dart) para controlar ritmo.
- Modifica patrones en [lib/game_logic/enemy_system/attack_pattern.dart](lib/game_logic/enemy_system/attack_pattern.dart) y las definiciones en [lib/game_logic/enemy_system/enemy_types.dart](lib/game_logic/enemy_system/enemy_types.dart).
- Pooling de proyectiles está en `PaletoGame` (`_bulletPool`) con tamaño 300; reduce/aumenta según rendimiento.



Desde un entorno de desarrollo ejecuta la app y, desde la consola de debug o añadiendo un botón temporal que llame a `game.spawnBoss('elegant_asian')`, podrás invocar un boss con patrón radial para tests.

## Arquitectura y archivos clave
- `lib/game/paleto_game.dart`: motor principal, manejo de olas, spawn y colisiones.
- `lib/game/components/bullet.dart`: comportamiento de proyectiles y pooling.
- `lib/game/player/player.dart`: movimiento del jugador, dash (nova + invulnerabilidad), disparo automático.
- `lib/game/enemies/enemy.dart`: lógica de enemigos (spawn, takeDamage, patrones).
- `lib/game_logic/enemy_system/*`: definición de enemigos, patrones y bosses.
- `lib/widgets/combat_arena.dart`: UI del campo de combate y renderizado de proyectiles.

## Notas para desarrolladores
- Para ajustar dificultad, revisa `EnemyTypeDefinition` en [lib/game_logic/enemy_system/enemy_types.dart](lib/game_logic/enemy_system/enemy_types.dart) (HP, pattern.cooldown, bulletSpeed, bulletCount).
- Los sonidos de boss, hit y muerte están en `services/audio_service.dart` — úsalos para feedback en fases críticas.
- El sistema usa Flame; los componentes extienden `PositionComponent` y el loop principal está en `FlameGame`.

Si quieres, puedo:
- Reescribir todo el `README.md` con estas secciones ordenadas y ejemplos de tuning (valores recomendados).
- Generar un `DEVELOPER.md` con pasos rápidos para crear nuevos patrones y bosses.


## 🎮 Características Principales

### 🏪 Sistema de Chefs (Chef System)
- Recluta y entrena sous chefs mediante el sistema de gacha
- Cada chef tiene atributos únicos: nombre, nivel, experiencia, rareza
- Asigna equipamiento y técnicas especiales a cada chef
- Los chefs ganan experiencia en combate y suben de nivel

### ⚔️ Sistema de Combate (Combat System)
- **Autobattler**: El combate es automático basado en stats de chefs vs enemigos
- **Enemigos con elementos**: Fuego, agua, tierra, viento, lava, planta, maestro y neutral
- **Modificadores de enemigos**: Resist, Strong, Weak, Armor modifican la dificultad
- **Olas de enemigos**: Progresa a través de múltiples olas antes de enfrentar un boss
- **3 Regiones con dificultad progresiva**: Asia, Caribbean, Europe
- **3 Bosses únicos**: Cada región tiene su jefe final

### 🎲 Sistema de Gacha
- Realiza tiradas para obtener nuevos chefs
- Tasas de rareza balanceadas: Common, Uncommon, Rare, Epic, Legendary
- Animaciones visuales al revelar resultados
- Sistema de pity/garantía para tiradas garantizadas

### 🎵 Sistema de Audio
- **BGM (Background Music)**: Música de menú y de combate
- **SFX (Sound Effects)**: Efectos de sonido para acciones del jugador
- Control independiente de volumen para BGM y SFX
- Sistema de audio reactivo basado en estados del juego

### 📈 Sistema de Economía y Progresión
- **Monedas (Gold)**: Ganadas en combate, usadas para mejoras
- **Gemas (Gems)**: Moneda premium para tiradas de gacha
- **Experiencia (XP)**: Sistema de nivel para el jugador
- **Misiones (Quests)**: Objetivos diarios y especiales con recompensas
- **Daily Bonuses**: Logeos diarios dan recompensas

### 🌍 Sistema de Mundo (World System)
- **Mapa interactivo**: Selecciona locaciones del mapa para combatir
- **Progresión regional**: Desbloquea nuevas regiones conforme avanzas
- **Sistema de elementos**: Cada locación responde a un elemento específico
- **Indicadores de dificultad**: Muestra enemigos recomendados para cada zona

### 📦 Mejoras de Equipo (Equipment System)
- Diversos tipos de equipo: armas, armadura, accesorios
- Sistema de rareza y poder
- Equipamiento automático o manual

### 🛠️ Sistema de Técnicas
- Técnicas especiales que los chefs pueden aprender
- Diferentes tipos: ataque, defensa, soporte
- Combinaciones estratégicas para combate

## 🔧 Tecnologías utilizadas

| Componente | Tecnología |
|-----------|-----------|
| **Framework** | Flutter 3.9+ |
| **Lenguaje** | Dart 3.9+ |
| **Estado** | Provider 6.1.5 |
| **Gráficos/Motor** | Flame 1.18.0 |
| **Audio** | AudioPlayers 6.1.0 |
| **Almacenamiento** | SharedPreferences 2.5.5 |
| **Fuentes** | Google Fonts (Press Start 2P) |
| **Plataformas** | Android, iOS, Web, Windows |

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── controllers/                 # Controladores de estado
│   ├── chef_controller.dart
│   ├── combat_controller.dart
│   ├── economy_controller.dart
│   ├── game_controller.dart
│   └── world_controller.dart
├── screens/                     # Pantallas principales
│   ├── main_layout.dart
│   ├── gameplay_screen.dart
│   ├── world_view.dart
│   ├── chefs_view.dart
│   ├── gacha_store_view.dart
│   ├── quests_view.dart
│   ├── profile_screen.dart
│   └── settings_dialog.dart
├── services/                    # Servicios globales
│   ├── audio_service.dart
│   ├── storage_service.dart
│   ├── ad_service.dart
│   └── audio_game_state.dart
├── models/                      # Modelos de datos
│   ├── chef.dart
│   ├── player.dart
│   ├── element_type.dart
│   ├── game_state.dart
│   └── ... (otros modelos)
├── game/                        # Lógica de juego Flame
│   ├── components/
│   ├── enemies/
│   └── player/
├── game_logic/                  # Sistemas de juego
│   ├── combat_system/
│   ├── enemy_system/
│   └── wave_system/
└── widgets/                     # Componentes reutilizables
    ├── retro_style.dart
    ├── element_type_table_widget.dart
    └── ... (otros widgets)
```

## 📥 Instrucciones de instalación

### Prerrequisitos
- Flutter SDK (3.9+)
- Dart SDK (3.9+)
- Android Studio o Xcode (para compilación nativa)

### Instalación

```bash
# 1. Clonar repo
git clone <repo-url>
cd "Paleto Knife"

# 2. Instalar dependencias
flutter pub get
```

## ▶️ Pasos para ejecutar el proyecto

### Ejecutar en desarrollo

```bash
# Ejecutar en dispositivo/emulador conectado
flutter run

# Ejecutar en navegador
flutter run -d chrome

# Ejecutar en Windows
flutter run -d windows
```

### Construir artefactos

```bash
flutter build apk           # APK para Android
flutter build ios           # App para iOS
flutter build web           # Build para web
flutter build windows       # Ejecutable Windows
```

## 🎯 Estado Actual del Proyecto

### ✅ Completado
- Sistema de combate automático con 3 regiones
- 21 tipos de enemigos con modificadores
- 3 bosses únicos por región
- Sistema de gacha con tiradas
- Sistema de audio (BGM/SFX)
- UI retro estilo 8 bits
- Mapa interactivo
- Sistema de chefs y equipamiento
- Misiones y logros diarios
- Almacenamiento persistente

### 🔄 Mejoras Recientes
- Refactorización y limpieza de código (eliminados 12 archivos duplicados)
- Consolidación del servicio de audio
- Mejoras visuales del mapa (hover effects, animaciones)
- Redesign de tabla de tipos de elemento (4 columnas, iconos compactos)

### ⏳ En Desarrollo / Mejoras Futuras
- Balanceo de dificultad
- Sistema de bandas/cooperativo
- Mas tipos de enemigos
- Sistema de logros avanzado
- Optimización para web

## 📊 Estadísticas del Código

- **83 archivos Dart** activos
- **0 dependencias duplicadas**
- **Compilación limpia** (sin errores)
- **Cobertura**: Combat System, Audio System, Gacha System

## 🤝 Contribuciones

El proyecto está en desarrollo activo. Los sistemas principales están implementados y probados. Se acepta feedback sobre balanceo, nuevas features y optimizaciones.

## 👥 Autores o integrantes del equipo

- Como Jimmy Soft
- Salome Rodriguez Moscoso
- Kevin Santiago Trejos Serrano
- Manuel Felipe Londoño
- David Alejandro Escobar Garcia

## 📝 Licencia

Proyecto privado en desarrollo.

---

**Última actualización**: Abril 2026
**Versión**: 1.0.0
