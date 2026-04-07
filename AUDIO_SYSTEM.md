# 🎵 Sistema Completo de Audio - Guía de Integración

## 📋 Contenido

1. [Estructura de archivos](#estructura-de-archivos)
2. [Inicialización en main()](#inicialización-en-main)
3. [Integración en GameWidget](#integración-en-gamewidget)
4. [Uso en diferentes pantallas](#uso-en-diferentes-pantallas)
5. [Ejemplos de reproducción](#ejemplos-de-reproducción)
6. [Mejor prácticas](#mejores-prácticas)

---

## 📁 Estructura de archivos

```
lib/
├── services/
│   └── audio_manager.dart          # Singleton global (YA CREADO)
├── models/
│   └── audio_settings.dart         # Persistencia de settings (YA CREADO)
├── widgets/
│   └── audio_settings_modal.dart   # UI de ajustes (YA CREADO)
└── screens/
    ├── menu_screen.dart            # Pantalla de menú
    ├── game_screen.dart            # Pantalla de juego
    ├── gacha_screen.dart           # Pantalla de tienda/gacha
    └── settings_screen.dart        # Pantalla de configuración
```

---

## 🚀 Inicialización en main()

Este es el paso más importante. Debes inicializar el AudioManager antes de que la app se inicie:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_manager.dart';
import 'models/audio_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AudioManager
  final audioManager = AudioManager();
  await audioManager.initialize();
  
  // Inicializar y cargar configuración guardada
  final audioSettings = AudioSettings();
  await audioSettings.initialize();
  
  // Aplicar configuración guardada
  await audioManager.setMusicVolume(audioSettings.getMusicVolume());
  await audioManager.setSfxVolume(audioSettings.getSfxVolume());
  await audioManager.toggleMusic(audioSettings.isMusicEnabled());
  await audioManager.toggleSfx(audioSettings.isSfxEnabled());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioManager>.value(value: audioManager),
        Provider<AudioSettings>.value(value: audioSettings),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knife Clicker',
      theme: ThemeData.dark(),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 🎮 Integración en GameWidget

Esta es la integración más importante. El botón de ajustes debe estar siempre accesible encima del GameWidget:

```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'widgets/audio_settings_modal.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MyGameClass gameInstance;

  @override
  void initState() {
    super.initState();
    gameInstance = MyGameClass();
    _startGameMusic();
  }

  void _startGameMusic() {
    // Reproducir música según el nivel/región
    final audioManager = AudioManager();
    // Ejemplo: reproducir música de América
    audioManager.playMusic('gameplay/america/america_wave.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // GameWidget principal
          GameWidget(game: gameInstance),
          
          // Botón de ajustes de audio ENCIMA del GameWidget
          AudioSettingsButton(
            onPressed: () => AudioSettingsModal.show(context),
          ),
          
          // Opcional: Mostrar estado de audio
          AudioStatusBar(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 16, top: 16),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameInstance.removeFromParent();
    super.dispose();
  }
}
```

---

## 📱 Uso en diferentes pantallas

### Pantalla de Menú

```dart
import 'package:flutter/material.dart';
import 'services/audio_manager.dart';
import 'screens/game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciar música de menú
    AudioManager().playMusic('menu/menu_song.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Tu contenido del menú aquí
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Detener música de menú y navegar a juego
                AudioManager().stopMusic();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              child: const Text('JUGAR'),
            ),
          ),
          
          // Botón de ajustes
          AudioSettingsButton(),
        ],
      ),
    );
  }
}
```

### Pantalla de Tienda/Gacha

```dart
class GachaScreen extends StatefulWidget {
  const GachaScreen({Key? key}) : super(key: key);

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  @override
  void initState() {
    super.initState();
    // Cambiar a música de tienda
    AudioManager().playMusic('tienda/shop.mp3');
  }

  void _onGachaPull() {
    // Reproducir sonido de click
    AudioManager().playSfx('tienda/click_gacha.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Tu contenido de gacha aquí
          Center(
            child: ElevatedButton(
              onPressed: _onGachaPull,
              child: const Text('TIRAR'),
            ),
          ),
          AudioSettingsButton(),
        ],
      ),
    );
  }
}
```

---

## 🔊 Ejemplos de reproducción

### Durante el gameplay

```dart
// En tu GameState o componente Flame

class MyGameClass extends FlameGame {
  late AudioManager audioManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    audioManager = AudioManager();
    
    // Reproducir música según región
    await audioManager.playMusic('gameplay/america/america_wave.mp3');
  }

  void onEnemyHit() {
    // Sonido de golpe
    audioManager.playSfx('sfx/hit.mp3');
  }

  void onCoinCollect() {
    // Sonido de moneda
    audioManager.playSfx('sfx/coin_collect.mp3');
  }

  void onKnifeLaunch() {
    // Sonido de lanzar cuchillo
    audioManager.playSfx('sfx/lanzar_cuchillo.mp3');
  }

  void onBossAlert() {
    // Sonido de alerta
    audioManager.playSfx('sfx/alerta_boss.mp3');
    
    // Cambiar a música de boss (esperar a que termine la SFX)
    Future.delayed(const Duration(milliseconds: 200), () {
      audioManager.playMusic('gameplay/america/boss_america.mp3');
    });
  }

  void onWeaponUpgrade() {
    // Sonido de mejora
    audioManager.playSfx('sfx/mejorarChef_Arma.mp3');
  }
}
```

### Cambiar región/world

```dart
Future<void> switchToAmerica() async {
  final audioManager = AudioManager();
  await audioManager.stopMusic();
  await audioManager.playMusic('gameplay/america/america_wave.mp3');
}

Future<void> switchToAsia() async {
  final audioManager = AudioManager();
  await audioManager.stopMusic();
  await audioManager.playMusic('gameplay/asia/asia_wave.mp3');
}

Future<void> switchToEuropa() async {
  final audioManager = AudioManager();
  await audioManager.stopMusic();
  await audioManager.playMusic('gameplay/europa/europa_wave.mp3');
}

Future<void> switchToBoss(String region) async {
  final audioManager = AudioManager();
  await audioManager.stopMusic();
  
  final bossMusic = {
    'america': 'gameplay/america/boss_america.mp3',
    'asia': 'gameplay/asia/boss_asia.mp3',
    'europa': 'gameplay/europa/boss_europa.mp3',
  };
  
  await audioManager.playMusic(bossMusic[region]!);
}
```

---

## 💾 Guardando cambios de volumen

Los cambios de volumen se guardan automáticamente:

```dart
class AudioSettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioManager, AudioSettings>(
      builder: (context, audioManager, audioSettings, _) => Positioned(
        top: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: () async {
            // Guardar settings antes de abrir el modal
            await audioSettings.setMusicVolume(audioManager.musicVolume);
            await audioSettings.setSfxVolume(audioManager.sfxVolume);
            await audioSettings.setMusicEnabled(audioManager.musicEnabled);
            await audioSettings.setSfxEnabled(audioManager.sfxEnabled);
            
            // Mostrar modal
            AudioSettingsModal.show(context);
          },
          child: const Icon(Icons.volume_up),
        ),
      ),
    );
  }
}
```

---

## 📞 Llamadas a métodos comunes

```dart
// Instancia global
final audioManager = AudioManager();

// ========== MÚSICA ==========
await audioManager.playMusic('menu/menu_song.mp3');
await audioManager.pauseMusic();
await audioManager.resumeMusic();
await audioManager.stopMusic();

// ========== EFECTOS ==========
await audioManager.playSfx('sfx/click_objetos.mp3');
await audioManager.playSfx('sfx/coin_collect.mp3');

// ========== VOLUMEN ==========
await audioManager.setMusicVolume(0.5);  // 50%
await audioManager.setSfxVolume(0.8);    // 80%

// ========== TOGGLES ==========
await audioManager.toggleMusic(true);    // Habilitar
await audioManager.toggleMusic(false);   // Deshabilitar
await audioManager.toggleSfx(true);
await audioManager.toggleSfx(false);

// ========== ESTADO ==========
print(audioManager.isMusicPlaying);      // bool
print(audioManager.isMusicPaused);       // bool
print(audioManager.currentMusicPath);    // String?
print(audioManager.musicVolume);         // double (0.0 - 1.0)
print(audioManager.musicEnabled);        // bool
```

---

## ✅ Mejores prácticas

### 1. **Evitar múltiples reproductores**
```dart
// ❌ MAL - Esto crea múltiples efectos simultáneos no deseados
for (int i = 0; i < 10; i++) {
  AudioManager().playSfx('sfx/hit.mp3');
}

// ✅ BIEN - Una única llamada
AudioManager().playSfx('sfx/hit.mp3');
```

### 2. **Usar la misma canción no reproduce duplicados**
```dart
// ✅ BIEN - Si ya está sonando, no hace nada
AudioManager().playMusic('gameplay/america/america_wave.mp3');
AudioManager().playMusic('gameplay/america/america_wave.mp3');
```

### 3. **Cambiar de canción correctamente**
```dart
// ✅ BIEN - Detener y reproducir nueva
AudioManager().stopMusic();
AudioManager().playMusic('menu/menu_song.mp3');

// O simplemente llamar playMusic (que detiene la anterior)
AudioManager().playMusic('menu/menu_song.mp3');
```

### 4. **Persistencia automática**
```dart
// El AudioManager notifica cambios automáticamente
// Los listeners (UI) se actualizan en tiempo real
// SharedPreferences guarda los cambios
```

### 5. **Debugging**
```dart
// Todos los eventos están logeados en consola
// Busca [AudioManager] en la consola para ver qué pasa

// En kDebugMode = false, no hay print (mejor rendimiento)
```

---

## 🐛 Troubleshooting

### "No se escucha audio"
1. Verifica que los archivos MP3 están en `assets/audio/`
2. Verifica que `pubspec.yaml` tiene la entrada en assets
3. Revisa que `AudioManager.initialize()` fue llamado en `main()`
4. Abre DevTools y busca `[AudioManager]` en los logs

### "Audio duplicado o lag"
1. Asegúrate de usar `AudioManager()` singleton (no crear instancias nuevas)
2. Verifica que no estás llamando `playMusic()` múltiples veces
3. Los archivos MP3 deben ser de buena calidad pero no demasiado grandes

### "Volumen no se guarda"
1. Verifica que `AudioSettings` fue inicializado
2. Llama a `setMusicVolume()` o `setSfxVolume()` antes de cerrar la app

---

## 📦 pubspec.yaml (requerimientos ya incluidos)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0
  flame_audio: ^2.12.0
  audioplayers: ^6.1.0
  provider: ^6.1.5+1
  shared_preferences: ^2.5.5

# Assets - verifica que esto esté en pubspec.yaml
assets:
  - assets/audio/menu/
  - assets/audio/gameplay/america/
  - assets/audio/gameplay/asia/
  - assets/audio/gameplay/europa/
  - assets/audio/sfx/
  - assets/audio/tienda/
```

---

## 🎯 Resumen de integración rápida

1. ✅ Los 3 archivos ya están creados:
   - `lib/services/audio_manager.dart`
   - `lib/models/audio_settings.dart`
   - `lib/widgets/audio_settings_modal.dart`

2. ✅ Actualiza `lib/main.dart` con el código de inicialización

3. ✅ Agrega el `AudioSettingsButton()` en tus `Scaffold` dentro de un `Stack`

4. ✅ Llama a `AudioManager().playMusic()` y `AudioManager().playSfx()` según sea necesario

5. ✅ ¡Listo! El sistema está totalmente operacional

---

**¡Tu sistema de audio está listo para ser un juego profesional! 🎮🔊**
