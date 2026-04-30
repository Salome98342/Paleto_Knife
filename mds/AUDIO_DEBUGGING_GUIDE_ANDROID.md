# 🔧 GUÍA DE DEBUGGING DE AUDIO EN ANDROID
**Fecha:** 14 de Abril 2026  
**Versión:** v2 (Mejorada con nuevos métodos)

---

## ⚡ INICIO RÁPIDO - Soluciona en 2 minutos

### Paso 1️⃣: Verificar Modo Silencioso
```
🔴 ESTO DETIENE TODO EL SONIDO EN ANDROID:
- El switch lateral del dispositivo está en posición ROJA (silencioso)
- Solución: Desliza el switch a la posición de sonido
```

### Paso 2️⃣: Verificar Volumen del Sistema
```
📢 Sube el volumen manualmente:
1. Presiona los botones de VOLUMEN ARRIBA (lado del dispositivo)
2. Verifica que el ícono de volumen muestre un nivel visible
3. Si está en 0, sube manualmente
```

### Paso 3️⃣: Ejecutar Diagnóstico en Consola
```dart
// En la consola de Flutter DevTools:
await AudioService.instance.diagnosticsAudio();

// Busca en los logs algo similar a:
[AUDIO LOG] - Initialized: true
[AUDIO LOG] - Web: false
[AUDIO LOG] - Music Enabled: true
[AUDIO LOG] - BGM Player State: PlayerState.playing
```

---

## 🚨 Si el audio SIGUE sin sonar...

### Opción A: Reiniciar Completo del Audio Service
```dart
// Esto reinicia completamente el sistema de audio
await AudioService.instance.forceReinitialize();

// Luego intenta reproducir
await AudioService.instance.playMenuMusic();
```

### Opción B: Verificar Estado Detallado
```dart
// Obtiene mapa completo de estado
final status = await AudioService.instance.getAndroidAudioStatus();
print('Status: $status');
```

### Opción C: Reset del Contexto de Audio (Antigua forma)
```dart
// Esto solo resetea el AudioContext sin reinitializar todo
await AudioService.instance.resetAudioContext();
```

---

## 🧪 TEST DE AUDIO DIRECTO

### Test Básico
```dart
await AudioService.instance.testAudio();
// Espera 3 segundos a que suene un audio
```

### Test Manual - Reproducir cada canción
```dart
// Menú
await AudioService.instance.playMenuMusic();
await Future.delayed(Duration(seconds: 3));

// Gameplay Caribe
await AudioService.instance.playCarribeMusic();
await Future.delayed(Duration(seconds: 3));

// SFX
await AudioService.instance.playCoinCollect();
await AudioService.instance.playHitSound();
```

---

## 📊 INTERPRETACIÓN DE DIAGNÓSTICOS

### Si ves esto ✅ TODO ESTÁ BIEN:
```
[AUDIO LOG] - Initialized: true
[AUDIO LOG] - Web: false (es un dispositivo Android real)
[AUDIO LOG] - Music Enabled: true
[AUDIO LOG] - BGM Player State: PlayerState.playing
```

### Si ves esto ⚠️ PROBLEMA:
```
[AUDIO LOG] - Initialized: false
→ AudioService no se inicializó correctly
→ Solución: Llamar a AudioService.instance.forceReinitialize()
```

### Si ves esto ⚠️ PROBLEMA:
```
[AUDIO LOG] - BGM Player State: PlayerState.stopped
→ BGM está detenido aunque debería estar tocando
→ Solución: Llamar a playMenuMusic() o playGameplayMusic()
```

### Si ves esto ⚠️ PROBLEMA:
```
[AUDIO LOG] - Music Enabled: false
→ Música está deshabilitada
→ Solución: await AudioService.instance.toggleMusic(true);
```

---

## 🛠️ MÉTODOS DE DEBUGGING DISPONIBLES

### diagnosticsAudio() - Reporte completo
```dart
// Imprime estado completo en logs
await AudioService.instance.diagnosticsAudio();
```

### getAndroidAudioStatus() - Mapa de estado
```dart
// Retorna un Map con todas las variables de estado
final status = await AudioService.instance.getAndroidAudioStatus();
// Útil para enviar a logs remotos o mostrar en UI
```

### forceReinitialize() - NUEVO en v2
```dart
// Reinicia completo el sistema de audio
// Útil cuando el audio deja de sonar después de 5+ minutos
await AudioService.instance.forceReinitialize();
```

### testAudio() - Test directo
```dart
// Reproduce un audio de prueba
// Si escuchas el sonido, el sistema está funcionando
await AudioService.instance.testAudio();
```

### resetAudioContext() - Reset moderado
```dart
// Solo reinicia el AudioContext de Android
// Menos invasivo que forceReinitialize()
await AudioService.instance.resetAudioContext();
```

---

## 🎯 FLUJO DE SOLUCIÓN DE PROBLEMAS

```
¿El audio no suena?
    │
    ├─ ¿El switch lateral está silencioso?
    │   └─ SÍ → Desliza a sonido ✅
    │
    ├─ ¿El volumen del sistema es 0?
    │   └─ SÍ → Sube manualmente ✅
    │
    ├─ ¿AudioService.diagnosticsAudio() muestra initialized=true?
    │   ├─ NO → Llama a forceReinitialize() → Test de nuevo
    │   └─ SÍ → Continúa...
    │
    ├─ ¿BGM Player State es PlayerState.playing?
    │   ├─ NO → Llama a playMenuMusic() → Test de nuevo
    │   └─ SÍ → Continúa...
    │
    ├─ ¿Music Enabled es true?
    │   ├─ NO → Llama a toggleMusic(true) → Test de nuevo
    │   └─ SÍ → Continúa...
    │
    └─ PROBLEMA CRÍTICO - Contáctame con:
       - Output completo de diagnosticsAudio()
       - Output completo de getAndroidAudioStatus()
       - Logs de la consola
       - Modelo del dispositivo Android
```

---

## 📱 TESTING EN DISPOSITIVO FÍSICO

### Paso 1: Conectar Dispositivo
```bash
adb devices
# Debe mostrar tu dispositivo
```

### Paso 2: Ejecutar en Debug
```bash
flutter run
```

### Paso 3: Abrir Consola de Flutter
- Presiona `d` en la terminal para DevTools
- Tab "Logging"
- Busca `[AUDIO LOG]`

### Paso 4: Ejecutar Tests
```dart
// En la consola de Dart:

// Test 1: Diagnóstico
AudioService.instance.diagnosticsAudio()

// Test 2: Status
AudioService.instance.getAndroidAudioStatus()

// Test 3: Audio sounds
AudioService.instance.testAudio()

// Test 4: Reproducir canciones
AudioService.instance.playMenuMusic()
```

---

## 🔍 LOGS IMPORTANTES QUE BUSCAR

### Logs de Inicialización
```
[AudioService] 🔧 Inicializando AudioService en Android/iOS...
[AudioService] ✓ Preferencias cargadas: BGM=0.55, SFX=0.9
[AudioService] 🎵 Configurando BGM player...
[AudioService] 🎚️ Configurando AudioContext detallado...
[AudioService] ✓ AudioContext configurado correctamente para Android/iOS
[AudioService] ✓ Modo silencioso ignorado - Audio forzado
```

Si NO ves esos logs:
- AudioService no se inicializó
- Revisa que `AudioService.init()` se llame en `main()`

### Logs de Reproducción
```
[🎵 AUDIO] Playing: audio/menu/menu_song.mp3
[🎵 AUDIO] Source type: AssetSource (Web: false)
[🎵 AUDIO] ✅ Playing exitosamente: audio/menu/menu_song.mp3
```

Si ves errores aquí, la ruta del archivo está mal.

### Logs de Fallback
```
[🎵 AUDIO] ❌ Error inicial en play: ...
[🎵 AUDIO] 🔧 Intentando configurar AudioContext nuevamente...
[🎵 AUDIO] ✅ Fallback: Playing exitosamente: ...
```

Esto es NORMAL - el sistema está intentando recuperarse.

---

## 🔬 DEBUGGING PROFUNDO

### Verificar Archivos de Audio
```bash
# Listar archivos que Flutter ve
ls assets/audio/
ls assets/audio/menu/
ls assets/audio/gameplay/
ls assets/audio/sfx/

# Todos deben existir:
# - assets/audio/menu/menu_song.mp3
# - assets/audio/gameplay/caribe/caribe_wave.mp3
# - assets/audio/gameplay/asia/asia_wave.mp3
# - etc...
```

### Verificar pubspec.yaml
```yaml
flutter:
  assets:
    - assets/   # ✅ Debe tener este
```

### Verificar AndroidManifest.xml
```xml
<!-- Debe tener estos permisos: -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### Verificar ProGuard Rules
```pro
# android/app/proguard-rules.pro debe tener:
-keep class com.google.android.exoplayer2.** { *; }
-keep class xyz.luan.audioplayers.** { *; }
-keep class android.media.** { *; }
```

---

## ✅ CHECKLIST FINAL

- [ ] Switch lateral del dispositivo está en SONIDO (no silencioso)
- [ ] Volumen del sistema está arriba (no en 0)
- [ ] `flutter run` sin errors
- [ ] `AudioService.instance.diagnosticsAudio()` muestra `Initialized: true`
- [ ] `AudioService.instance.testAudio()` produce sonido
- [ ] `AudioService.instance.playMenuMusic()` produce sonido
- [ ] Todos los archivos .mp3 existen en `assets/audio/`
- [ ] `pubspec.yaml` tiene `assets: - assets/`
- [ ] `AndroidManifest.xml` tiene los permisos requeridos

---

## 💬 SI NADA FUNCIONA

1. Ejecuta:
   ```dart
   await AudioService.instance.forceReinitialize();
   ```

2. Espera 2 segundos

3. Ejecuta:
   ```dart
   await AudioService.instance.playMenuMusic();
   ```

4. Si AÚN no hay sonido:
   - Reinicia el dispositivo completamente
   - Ejecuta `flutter clean`
   - Ejecuta `flutter pub get`
   - Ejecuta `flutter run` de nuevo

---

**Última actualización:** 14 de Abril 2026  
**Estado:** Listo para production
