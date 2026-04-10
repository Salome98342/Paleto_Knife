/// ============================================
/// DEBUGGING AUDIO - Paleto Knife
/// ============================================
/// 
/// Para debuggear por qué no suena la música:
/// 

## PAS 1: VER LOS LOGS
Cuando ejecutes `flutter run -d <device>` o abras el APK, busca en la consola:

```
[🎵 AUDIO] Intentando reproducir: assets/audio/menu/menu_song.mp3
[🎵 AUDIO] _initialized=true, _isWeb=false
[🎵 AUDIO] Playing from: AssetSource(assets/audio/menu/menu_song.mp3)
[🎵 AUDIO] ✅ Playing: assets/audio/menu/menu_song.mp3
```

Si aparecen estos logs → El audio debería sonar
Si dicen error → Copiar el error exacto


## PASO 2: PRUEBA MANUAL CON PANTALLA DE TEST
1. En audio_test_screen.dart (ya creada)
2. Agregá a main.dart para que se abra primero:
   - Cambia `const SplashScreen()` por `const AudioTestScreen()`
3. Flutter run y prueba cada botón

## PASO 3: VERIFICAR
- ¿AudioService se inicializa? (buscar logs)
- ¿El archivo exists? `assets/audio/menu/menu_song.mp3`
- ¿Es Android/iOS? (no funciona en web)
- ¿Volumen del dispositivo está activado?


## LOGS QUE DEBERÍA HABER

### Al iniciar:
```
[AudioService] 🔍 _isWeb = false (kIsWeb = false)
[AudioService] 🔧 Inicializando AudioService en Android/iOS...
[AudioService] ✓ Preferencias cargadas: BGM=0.55, SFX=0.9
[AudioService] 🎵 Configurando BGM player...
[AudioService] ✓ BGM player configurado
[AudioService] 🔊 Configurando 4 SFX players...
[AudioService] ✓ SFX players configurados
[AudioService] ✅ INICIALIZACIÓN COMPLETADA
```

### Al ir a MainLayout:
```
[MainLayout] 🎵 Iniciando música de menú
[🎵 AUDIO] Intentando reproducir: assets/audio/menu/menu_song.mp3
[🎵 AUDIO] _initialized=true, _isWeb=false
[🎵 AUDIO] Playing from: AssetSource(assets/audio/menu/menu_song.mp3)
[🎵 AUDIO] ✅ Playing: assets/audio/menu/menu_song.mp3
```

Si ves "✅ Playing", la música DEBERÍA estar sonando.


## ERRORES COMUNES

### Error: "No such file or directory"
→ Ruta incorrecta en assets. Verificar que sea exacta: `assets/audio/menu/menu_song.mp3`

### Error: "Format error"
→ El archivo MP3 está corrupto. Reemplazarlo.

### Dice "initialized=false"
→ AudioService.init() no se ejecutó o falló. Ver logs de inicialización.

### Dice "MEDIA_ELEMENT_ERROR" (en web)
→ Normal. Audio no funciona en web, solo Android/iOS.

---
