# 🎵 AUDIO STATE-BASED SYSTEM - QUICK REFERENCE

## 🔴 SITUACIONES COMUNES - COPY & PASTE

### 1️⃣ Menú inicia
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    AudioManager().stateManager.setState(AudioGameState.menu);
  });
}
```

### 2️⃣ Juego comienza (con región)
```dart
Future.microtask(() {
  AudioManager().stateManager.setState(
    AudioGameState.gameplay,
    region: 'america',
  );
});
```

### 3️⃣ Cambiar región durante gameplay
```dart
void changeRegion(String region) {
  AudioManager().stateManager.setState(
    AudioGameState.gameplay,
    region: region,
  );
}
```

### 4️⃣ Boss aparece
```dart
@override
Future<void> onMount() async {
  AudioManager().stateManager.setState(
    AudioGameState.boss,
    region: 'america',
  );
  // ← Automáticamente:
  // 1. Reproduce sfx/alerta_boss.mp3
  // 2. Luego boss_america.mp3 con fade
}
```

### 5️⃣ Boss muere
```dart
void onBossDeath() {
  AudioManager().stateManager.setState(
    AudioGameState.gameplay,
    region: 'america', // Volver a región actual
  );
}
```

### 6️⃣ Tienda abre
```dart
void openShop() {
  AudioManager().stateManager.setState(AudioGameState.tienda);
}
```

### 7️⃣ Golpe al enemigo
```dart
void onEnemyHit() {
  AudioManager().playHit();
}
```

### 8️⃣ Moneda recolectada
```dart
void onCoin() {
  AudioManager().playCoin();
}
```

### 9️⃣ Cuchillo lanzado
```dart
void onAttack() {
  AudioManager().playKnife();
}
```

### 🔟 Botón presionado  
```dart
ElevatedButton(
  onPressed: () {
    AudioManager().playClick();
    // ... acción
  },
  child: const Text('CLICK'),
)
```

### 1️⃣1️⃣ Upgrade/Mejora
```dart
void onUpgrade() {
  AudioManager().playUpgrade();
}
```

### 1️⃣2️⃣ Gacha/Sorteo
```dart
void onGacha() {
  AudioManager().playGacha();
}
```

### 1️⃣3️⃣ App minimizada
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    AudioManager().pauseApp();
  } else if (state == AppLifecycleState.resumed) {
    AudioManager().resumeApp();
  }
}
```

---

## 🎸 MÉTODOS DISPONIBLES

### AudioManager

```dart
// MÚSICA
playMusic(path)                    // Reproduce música
playMusicWithFadeIn(path)          // Con fade in suave
stopMusic()                        // Detiene
pauseMusic()                       // Pausa
resumeMusic()                      // Reanuda

// SFX
playSfx(path)                      // Genérico
playHit()                          // Hit
playCoin()                         // Moneda
playKnife()                        // Cuchillo
playClick()                        // Click
playUpgrade()                      // Upgrade
playGacha()                        // Gacha

// VOLUMEN
setMusicVolume(0.0-1.0)            // % música
setSfxVolume(0.0-1.0)              // % SFX

// TOGGLES
toggleMusic(true/false)            // Habilitar/deshabilitar
toggleSfx(true/false)              // Habilitar/deshabilitar

// APP LIFECYCLE
pauseApp()                         // Minimizar
resumeApp()                        // Volver

// STATE MANAGER
stateManager.setState(state, region?)
stateManager.currentState
stateManager.currentRegion
```

---

## 🗺️ RUTAS DE AUDIO

### 🎵 MÚSICA

```
MENU:
  menu/menu_song.mp3

GAMEPLAY:
  gameplay/america/america_wave.mp3
  gameplay/asia/asia_wave.mp3
  gameplay/europa/europa_wave.mp3

BOSS:
  gameplay/america/boss_america.mp3
  gameplay/asia/boss_asia.mp3
  gameplay/europa/boss_europa.mp3

TIENDA:
  tienda/shop.mp3
```

### 🔊 SFX

```
sfx/hit.mp3
sfx/coin_collect.mp3
sfx/lanzar_cuchillo.mp3
sfx/click_objetos.mp3
sfx/mejorarChef_Arma.mp3
sfx/alerta_boss.mp3
tienda/click_gacha.mp3
```

---

## 📊 TABLA DE CAMBIOS DE ESTADO

| De    | A        | Acción                              |
|-------|----------|-------------------------------------|
| MENU  | GAMEPLAY | Fade out menu → fade in gameplay    |
| GAMEPLAY | BOSS   | Alerta (200ms) → boss music         |
| BOSS  | GAMEPLAY | Fade out boss → fade in gameplay    |
| CUALQUIERA | TIENDA | Fade out → fade in shop            |
| TIENDA | GAMEPLAY | Fade out → fade in gameplay         |

---

## ⚙️ CONFIGURACIÓN EN main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final audioManager = AudioManager();
  await audioManager.initialize();  // ← IMPORTANTE
  
  runApp(
    ChangeNotifierProvider<AudioManager>.value(
      value: audioManager,
      child: const MyApp(),
    ),
  );
}
```

---

## 🎯 REGLAS

1. **Una música a la vez** ✅
2. **SFX simultáneos permitidos** ✅
3. **Fade in/out: 300ms** ✅
4. **Alerta boss: antes de música** ✅
5. **Boss tiene prioridad** ✅
6. **No repetir canción** ✅
7. **Pausar app → pauseApp()** ✅

---

## 🔍 DEBUGGING

```dart
// Ver estado actual
print(AudioManager().stateManager.currentState);
print(AudioManager().stateManager.currentRegion);

// Ver qué música está sonando
print(AudioManager().currentMusicPath);
print(AudioManager().isMusicPlaying);

// Ver volúmenes
print(AudioManager().musicVolume);
print(AudioManager().sfxVolume);

// Ver si está habilitado
print(AudioManager().musicEnabled);
print(AudioManager().sfxEnabled);
```

---

## 📦 TRANSICIONES ENTRE PANTALLAS

```dart
// MENÚ → GAMEPLAY
onPressed: () {
  AudioManager().playClick();
  AudioManager().stateManager.setState(
    AudioGameState.gameplay,
    region: 'america',
  );
  Navigator.push(...);
}

// GAMEPLAY → TIENDA
onPressed: () {
  AudioManager().playClick();
  AudioManager().stateManager.setState(AudioGameState.tienda);
  Navigator.push(...);
}

// TIENDA → GAMEPLAY
onPressed: () {
  AudioManager().playClick();
  AudioManager().stateManager.setState(
    AudioGameState.gameplay,
    region: currentRegion,
  );
  Navigator.pop(...);
}
```

---

## 🎊 EJEMPLOS COMPLETOS

### Componente de Enemigo
```dart
class EnemyComponent extends PositionComponent {
  void takeDamage() {
    AudioManager().playHit();
  }

  void giveLoot(int gold) {
    AudioManager().playCoin();
  }

  void die() {
    AudioManager().playClick();
    removeFromParent();
  }
}
```

### Componente de Jugador
```dart
class PlayerComponent extends PositionComponent {
  void attack() {
    AudioManager().playKnife();
  }

  void takeDamage() {
    AudioManager().playHit();
  }
}
```

### Componente de Boss
```dart
class BossComponent extends PositionComponent {
  final String bossRegion = 'america';

  @override
  Future<void> onMount() async {
    super.onMount();
    AudioManager().stateManager.setState(
      AudioGameState.boss,
      region: bossRegion,
    );
  }

  void die() {
    AudioManager().playUpgrade();
    AudioManager().stateManager.setState(
      AudioGameState.gameplay,
      region: bossRegion,
    );
    removeFromParent();
  }
}
```

---

## ✅ CHECKLIST IMPLEMENTACIÓN

- [ ] AudioManager inicializado en `main()`
- [ ] MultiProvider configurado
- [ ] WidgetsBindingObserver en main
- [ ] MenuScreen → setState(MENU)
- [ ] GameScreen → setState(GAMEPLAY)
- [ ] BossComponent → setState(BOSS) en onMount
- [ ] ShopScreen → setState(TIENDA)
- [ ] playHit() en eventos de daño
- [ ] playCoin() en recompensas
- [ ] playKnife() en ataques
- [ ] playClick() en botones
- [ ] playUpgrade() en mejoras
- [ ] playGacha() en sorteos
- [ ] pauseApp() en minimización
- [ ] resumeApp() al volver

---

## 🐛 TROUBLESHOOTING

**Problema: Sonidos se solapan**
→ Usar solo `setState()` para cambios grandes
→ Evitar llamar `playMusic()` directamente

**Problema: Música no cambia en BOSS**
→ Verificar que `region` es correcto
→ Ver logs: `[AudioManager] Estado cambió`

**Problema: SFX muy silenciosos**
→ Verificar `setSfxVolume()`
→ Verificar que no está muteado

**Problema: App pausada no pausa audio**
→ Agregar `WidgetsBindingObserver`
→ Llamar `pauseApp()` en lifecycle

---

## 📝 RESUMEN

✨ Sistema **completamente automático**
✨ **Estado → Música correcta**
✨ **Sin código duplicado**
✨ **Listo para producción**

---

**¡Ya está todo listo! Solo copia, pega y ajusta rutas de audio.**
