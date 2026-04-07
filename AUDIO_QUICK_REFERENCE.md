# 🎵 Sistema de Audio - Referencia Rápida

## 📌 Checklist de Implementación

- [ ] Todos los archivos MP3 están en `assets/audio/` con la estructura correcta
- [ ] `pubspec.yaml` tiene entrada en `assets`
- [ ] `AudioManager().initialize()` se llama en `main()`
- [ ] `AudioManager` está registrado en Provider
- [ ] `AudioSettings` está inicializado y cargando preferencias
- [ ] Botón `AudioSettingsButton()` está en Stack de pantallas
- [ ] Se llama a `playMusic()` al entrar a una pantalla
- [ ] Se llama a `stopMusic()` al salir de una pantalla

---

## ⚡ Uso Rápido

### Reproducir música
```dart
AudioManager().playMusic('menu/menu_song.mp3');
AudioManager().playMusic('gameplay/america/america_wave.mp3');
```

### Reproducir efectos
```dart
AudioManager().playSfx('sfx/coin_collect.mp3');
AudioManager().playSfx('sfx/hit.mp3');
```

### Controlar volumen
```dart
AudioManager().setMusicVolume(0.7);     // 70%
AudioManager().setSfxVolume(0.8);       // 80%
```

### Habilitar/Deshabilitar
```dart
AudioManager().toggleMusic(true);       // ON
AudioManager().toggleSfx(false);        // OFF
```

### Control de música
```dart
AudioManager().pauseMusic();
AudioManager().resumeMusic();
AudioManager().stopMusic();
```

---

## 🔥 Problemas comunes y soluciones

### ❌ "No se escucha nada"
```
1. Verifica que los archivos MP3 están en assets/audio/
2. Abre DevTools y busca [AudioManager] en Dart console
3. Verifica que no está todo muteado (toggleSfx/toggleMusic)
4. Reinicia la app
```

**Checklist de archivos:**
```
assets/
  audio/
    menu/
      ✅ menu_song.mp3
    gameplay/
      america/
        ✅ america_wave.mp3
        ✅ boss_america.mp3
      asia/
        ✅ asia_wave.mp3
        ✅ boss_asia.mp3
      europa/
        ✅ europa_wave.mp3
        ✅ boss_europa.mp3
    sfx/
      ✅ alerta_boss.mp3
      ✅ click_objetos.mp3
      ✅ coin_collect.mp3
      ✅ hit.mp3
      ✅ lanzar_cuchillo.mp3
      ✅ mejorarChef_Arma.mp3
    tienda/
      ✅ click_gacha.mp3
      ✅ shop.mp3
```

### ❌ "Audio duplicado o se superpone"
```dart
// ❌ MAL - Esto llama múltiples veces
while (true) {
  AudioManager().playSfx('sfx/hit.mp3');
}

// ✅ BIEN - Una única llamada
AudioManager().playSfx('sfx/hit.mp3');

// ✅ BIEN - Para múltiples eventos, usar debounce
if (!_isPlayingEffect) {
  _isPlayingEffect = true;
  AudioManager().playSfx('sfx/hit.mp3');
  Future.delayed(Duration(milliseconds: 100), () {
    _isPlayingEffect = false;
  });
}
```

### ❌ "Lag o stuttering"
```dart
// Los archivos MP3 pueden ser muy grandes
// Comprimir antes de agregar: ffmpeg -i input.mp3 -q:a 7 -f mp3 output.mp3

// En dispositivos Android, a veces hay problemas con AudioPlayer
// Solución: usar Flame.audio.bgm en lugar de AudioPlayer directo
```

### ❌ "La música no se pausa cuando apps entra a background"
```dart
// Agregar en main.dart después de crear la app:
WidgetsBinding.instance.window.onPlatformBrightness;

// O manejar en tu GameState:
@override
void onGameResumed() async {
  await AudioManager().resumeMusic();
}

@override
void onGamePaused() async {
  await AudioManager().pauseMusic();
}
```

### ❌ "Los cambios de volumen no se guardan"
```dart
// En tu AudioSettingsButton, debes guardar antes de cerrar:
Consumer2<AudioManager, AudioSettings>(
  builder: (context, audioManager, audioSettings, _) {
    return FloatingActionButton(
      onPressed: () async {
        // GUARDAR
        await audioSettings.setMusicVolume(audioManager.musicVolume);
        await audioSettings.setSfxVolume(audioManager.sfxVolume);
        await audioSettings.setMusicEnabled(audioManager.musicEnabled);
        await audioSettings.setSfxEnabled(audioManager.sfxEnabled);
        
        // MOSTRAR
        AudioSettingsModal.show(context);
      },
      child: Icon(Icons.volume_up),
    );
  }
)
```

### ❌ "El AudioManager no actualiza la UI"
```dart
// Asegúrate de usar Consumer en los widgets:
Consumer<AudioManager>(
  builder: (context, audioManager, _) {
    return Switch(
      value: audioManager.musicEnabled,
      onChanged: (value) async {
        await audioManager.toggleMusic(value);
        // No necesitas setState, Provider lo maneja automáticamente
      },
    );
  }
)
```

---

## 🎯 Guía de Transiciones Entre Pantallas

### Menu → Game
```dart
// En MenuScreen:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => GameScreen()),
);

// En GameScreen.initState():
void initState() {
  super.initState();
  AudioManager().playMusic('gameplay/america/america_wave.mp3');
}
```

### Game → Gacha
```dart
// Detener música de juego
AudioManager().stopMusic();

// Mostrar pantalla de gacha
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => GachaScreen()),
);

// En GachaScreen.initState():
void initState() {
  super.initState();
  AudioManager().playMusic('tienda/shop.mp3');
}
```

### Anything → Menu
```dart
// Limpiar todo
AudioManager().stopMusic();

// Volver al menú
Navigator.popUntil(context, (route) => route.isFirst);

// O en MenuScreen.initState():
AudioManager().playMusic('menu/menu_song.mp3');
```

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────┐
│                  AudioManager                    │
│  ┌──────────────────┬──────────────────────────┐ │
│  │  _musicPlayer    │      _sfxPlayer          │ │
│  │  (BGM)           │      (Efectos)           │ │
│  └──────────────────┴──────────────────────────┘ │
│                                                   │
│  • Singleton global                              │
│  • Controla play/pause/resume/stop               │
│  • Volumen independiente                         │
│  • Notifica cambios con ChangeNotifier           │
└─────────────────────────────────────────────────┘
          ↓
┌──────────────────────────────────────────────────┐
│             AudioSettingsModal                    │
│  • UI para ajustar volumen                       │
│  • Toggles para habilitar/deshabilitar          │
│  • Design oscuro premium                         │
└──────────────────────────────────────────────────┘
          ↓
┌──────────────────────────────────────────────────┐
│             SharedPreferences                     │
│  • Persiste settings de audio                    │
│  • Se carga en main()                            │
│  • Se actualiza en tiempo real                   │
└──────────────────────────────────────────────────┘
```

---

## 🚀 Optimizaciones Avanzadas

### Precarga de audios (ya incluido)
```dart
// Los audios se precarga en initialize()
// Esto hace que la reproducción sea instantánea
await FlameAudio.audioCache.load('audio/path');
```

### Transiciones suave entre canciones
```dart
// Usa Region Audio Manager para transiciones automáticas
Future<void> switchWithTransition(String newMusic) async {
  // Opcionalmente reducir volumen
  audioManager.setMusicVolume(0.3);
  
  // Esperar
  await Future.delayed(Duration(milliseconds: 300));
  
  // Cambiar canción
  audioManager.stopMusic();
  audioManager.playMusic(newMusic);
  
  // Restaurar volumen
  audioManager.setMusicVolume(0.7);
}
```

### Memory leak prevention
```dart
// En dispose() de screens:
@override
void dispose() {
  // El AudioManager se mantiene global
  // Pero limpia referencias al salir
  super.dispose();
}

// Al cerrar la app (en main):
@override
void dispose() async {
  await AudioManager().dispose();
  super.dispose();
}
```

---

## ✅ Checklist antes de producción

- [ ] Todos los audios están comprimidos (no deben exceder 1MB cada uno)
- [ ] Se prueban todos los sonidos en dispositivos reales
- [ ] La música se pausa correctamente en background
- [ ] Los volúmenes se guardan y cargan correctamente
- [ ] No hay memory leaks (perfiles en Android Studio)
- [ ] El audio funciona en dispositivos sin audio (muted)
- [ ] Los SFX no interrumpen la música
- [ ] Las transiciones entre pantallas son suaves
- [ ] Se puede cambiar región sin glitches de audio
- [ ] Los bosses tienen transición de música clara

---

## 📱 Testing en Dispositivos

### Android
```bash
# Ver logs de audio
adb logcat | grep AudioManager

# Probar en emulador (puede tener problemas de audio)
flutter run -d emulator-5554
```

### iOS
```bash
# Usar dispositivo real para mejor resultado
# El simulador puede tener latencia de audio
flutter run -d iphone
```

---

## 🎮 Integración con Flame

Si usas componentes Flame, accede al AudioManager así:

```dart
class MyGameComponent extends Component {
  late AudioManager audioManager;
  
  @override
  Future<void> onLoad() async {
    audioManager = AudioManager();
    // Ahora puedes usarlo en updare()
  }
  
  @override
  void update(double dt) {
    // Reproducir sonido en evento
    audioManager.playSfx('sfx/hit.mp3');
  }
}
```

---

## 🛑 Shutdown Graceful

```dart
// En tu app principal
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AudioManager().pauseMusic();
        break;
      case AppLifecycleState.resumed:
        AudioManager().resumeMusic();
        break;
      case AppLifecycleState.detached:
        AudioManager().dispose();
        break;
      default:
        break;
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Tu app aquí
  }
}
```

---

## 📚 Recursos Útiles

- **Flame Audio**: https://flame-engine.org/doc/latest/tutorials/level_4/sounds_and_images/
- **Audioplayers**: https://pub.dev/packages/audioplayers
- **FlameAudio**: https://pub.dev/packages/flame_audio
- **Best practices**: https://flutter.dev/docs/development/best-practices

---

**¡Tu sistema de audio está production-ready! 🚀**
