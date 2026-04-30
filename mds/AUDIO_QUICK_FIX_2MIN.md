# ⚡ GUÍA RÁPIDA - SOLUCIONA EN 2 MINUTOS
**Tiempo aproximado:** 2-5 minutos  
**Última actualización:** 14 de Abril 2026

---

## 🚨 LA MÚSICA EN ANDROID NO SUENA

### ☑️ PASO 1: VERIFICAR MODO SILENCIOSO (30 segundos)

**¿El dispositivo está en modo silencioso?**

```
Busca en el LADO del dispositivo:
- Si hay un SWITCH ROJO hacia la izquierda = SILENCIO 🔴
- Si hay un SWITCH hacia la derecha = SONIDO 🔊
```

**Acción:**
```
1. Mira el lado del dispositivo
2. Si hay switch rojo/naranja = DESLIZA HACIA ARRIBA
3. Si no hay switch = SALTA AL PASO 2
```

✅ **Si lo moviste:** Ya debería tener sonido. Intenta de nuevo.

---

## 🔊 PASO 2: VERIFICAR VOLUMEN (30 segundos)

**¿El volumen de música está en 0?**

```
1. Presiona los BOTONES DE VOLUMEN en el lado del dispositivo
2. Presiona ARRIBA repetidamente
3. Espera a ver que sube la barra de volumen en pantalla
```

✅ **Si subiste el volumen:** Ya debería tener sonido. Intenta de nuevo.

---

## 🧪 PASO 3: TEST DE AUDIO (1 minuto)

**En la consola de Flutter (abrir DevTools):**

```dart
// Ejecuta esto:
await AudioService.instance.testAudio();

// Espera 3 segundos
// ¿Escuchas un sonido?
```

- ✅ **SÍ:** El audio funciona. Intenta jugar de nuevo.
- ❌ **NO:** Continúa al Paso 4.

---

## 🔧 PASO 4: REINICIALIZAR AUDIO (2 minutos)

**En la consola de Flutter:**

```dart
// Ejecuta esto:
await AudioService.instance.forceReinitialize();

// Espera 3 segundos

// Luego intenta:
await AudioService.instance.playMenuMusic();

// ¿Escuchas la música de menú?
```

- ✅ **SÍ:** ¡Problema resuelto! 🎉
- ❌ **NO:** Ve al Paso 5.

---

## 📊 PASO 5: DIAGNÓSTICO DETALLADO (1 minuto)

**En la consola de Flutter:**

```dart
// Ejecuta esto:
await AudioService.instance.diagnosticsAudio();

// Copia todos los logs que empiezan con [AUDIO LOG]
```

**Busca estas líneas:**

```
[AUDIO LOG] - Initialized: true
[AUDIO LOG] - Web: false
[AUDIO LOG] - Music Enabled: true
[AUDIO LOG] - BGM Player State: PlayerState.playing
```

**Si ves esto:**
- `Initialized: false` → Ejecuta `forceReinitialize()` de nuevo
- `Music Enabled: false` → Ejecuta `toggleMusic(true)`
- `BGM Player State: PlayerState.stopped` → Intenta reproducir música de nuevo

---

## ✅ CHECKLIST DE 60 SEGUNDOS

- [ ] Switch del dispositivo está en SONIDO (no rojo)
- [ ] Volumen está arriba (no en 0)
- [ ] Ejecuté `testAudio()` y escuché sonido
- [ ] Ejecuté `forceReinitialize()` y sonó
- [ ] Ahora la música de menú suena

---

## 💬 SI NADA DE ARRIBA FUNCIONÓ

1. Reinicia el dispositivo completamente
2. En la terminal, ejecuta:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Intenta los pasos 1-4 de nuevo

---

## 📞 INFORMACIÓN IMPORTANTE PARA REPORTAR

Si el audio sigue sin funcionar, tienes que reportar:

1. **Output de diagnosticsAudio():**
   ```dart
   await AudioService.instance.diagnosticsAudio();
   // Copia TODO lo que dice [AUDIO LOG]
   ```

2. **Output de getAndroidAudioStatus():**
   ```dart
   await AudioService.instance.getAndroidAudioStatus();
   // Copia el resultado completo
   ```

3. **Información del dispositivo:**
   - Modelo: _____________________
   - Versión Android: _____________________
   - ¿Está en modo desarrollo? Sí / No
   - ¿Es dispositivo real o emulador? _____________________

---

**📝 Versión:** 1.0  
**✅ Estado:** Listo para usar
