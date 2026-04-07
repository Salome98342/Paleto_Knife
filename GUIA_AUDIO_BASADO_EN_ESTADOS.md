# 🎵 SISTEMA DE AUDIO BASADO EN STATES - GUÍA COMPLETA

## 📋 Visión General

Sistema de audio **completamente sincronizado** con los estados del juego (menú, gameplay, boss, tienda). 

**Características principales:**
- ✅ Máquina de estados automática (GameState → Música específica)
- ✅ Transiciones suaves (fade in/fade out)
- ✅ SFX específicos ligados a eventos
- ✅ Sin solapamientos de música
- ✅ Ciclo de vida de app (pause/resume)
- ✅ Integración total con Flame

---

## 🏗️ Arquitectura

```
AudioManager (singleton)
    ├── playMusic() / stopMusic()
    ├── playSfx()
    ├── Fade In/Out
    ├── StateManager listener
    └── Volume control

AudioGameStateManager (singleton)
    ├── currentState (enum)
    ├── currentRegion
    └── listeners & stream

AudioGameState (enum)
    ├── MENU → "menu/menu_song.mp3"
    ├── GAMEPLAY → "gameplay/{region}/{region}_wave.mp3"
    ├── BOSS → "gameplay/{region}/boss_{region}.mp3" + alerta
    └── TIENDA → "tienda/shop.mp3"

Game States & Listeners
    ├── MenuScreen → men
    ├── GameScreen → gameplay
    ├── BossComponent → boss
    └── ShopScreen → tienda
```

---

## 🚀 PASO 1: INICIALIZACIÓN EN main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Crear e inicializar AudioManager
  final audioManager = AudioManager();
  await audioManager.initialize();
  
  // 2. Proporcionar a toda la app
  runApp(
    ChangeNotifierProvider<AudioManager>.value(
      value: audioManager,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
    final audioManager = context.read<AudioManager>();
    
    if (state == AppLifecycleState.paused) {
      audioManager.pauseApp();
    } else if (state == AppLifecycleState.resumed) {
      audioManager.resumeApp();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paleto Knife',
      theme: ThemeData.dark(),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 🎮 PASO 2: INTEGRACIÓN EN SCREENS

### MenuScreen

```dart
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    
    // Al abrir menú, cambiar a estado MENU
    // Esto automáticamente reproduce menu_song.mp3
    Future.microtask(() {
      context.read<AudioManager>().stateManager.setState(
        AudioGameState.menu,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // 1. Reproducir efecto de click
              context.read<AudioManager>().playClick();
              
              // 2. Navegar a GameScreen
              // GameScreen automáticamente cambiará a GAMEPLAY
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            },
            child: const Text('JUGAR'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AudioManager>().playClick();
              
              // Cambiar a TIENDA
              context.read<AudioManager>().stateManager.setState(
                AudioGameState.tienda,
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
            },
            child: const Text('TIENDA'),
          ),
        ],
      ),
    );
  }
}
```

### GameScreen

```dart
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
    
    // Cambiar a GAMEPLAY (región América por defecto)
    Future.microtask(() {
      context.read<AudioManager>().stateManager.setState(
        AudioGameState.gameplay,
        region: 'america',
      );
    });
  }

  @override
  void dispose() {
    gameInstance.removeFromParent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: gameInstance),
    );
  }
}
```

---

## 🔥 PASO 3: INTEGRACIÓN CON FLAME

### En tu FlameGame

```dart
class MyGameClass extends FlameGame {
  late AudioManager audioManager;
  String currentRegion = 'america';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Obtener AudioManager
    audioManager = AudioManager();
    
    // Asegurar estado en GAMEPLAY
    audioManager.stateManager.setState(
      AudioGameState.gameplay,
      region: currentRegion,
    );
  }

  // Cuando aparece un boss
  void onBossSpawn(String bossRegion) {
    audioManager.stateManager.setState(
      AudioGameState.boss,
      region: bossRegion,
    );
  }

  // Cuando el boss muere
  void onBossDeath() {
    audioManager.stateManager.setState(
      AudioGameState.gameplay,
      region: currentRegion,
    );
  }

  // Cuando cambias de región
  void changeRegion(String newRegion) {
    currentRegion = newRegion;
    audioManager.stateManager.setState(
      AudioGameState.gameplay,
      region: newRegion,
    );
  }
}
```

### En componentes Flame

```dart
// Componente del jugador
class PlayerComponent extends PositionComponent {
  void onAttack() {
    AudioManager().playKnife();
  }

  void onHit() {
    AudioManager().playHit();
  }
}

// Componente del enemigo
class EnemyComponent extends PositionComponent {
  void collectGold(int amount) {
    AudioManager().playCoin();
  }

  void onDeath() {
    AudioManager().playClick();
  }
}

// Componente de boss
class BossComponent extends PositionComponent {
  late String bossRegion;

  @override
  Future<void> onMount() async {
    super.onMount();
    
    bossRegion = AudioManager().stateManager.currentRegion;
    
    // Automáticamente cambiar a BOSS
    AudioManager().stateManager.setState(
      AudioGameState.boss,
      region: bossRegion,
    );
  }

  @override
  void onRemove() {
    super.onRemove();
    
    // Volver a GAMEPLAY
    AudioManager().stateManager.setState(
      AudioGameState.gameplay,
      region: bossRegion,
    );
  }
}
```

---

## 📊 MAPEO DE AUDIO POR ESTADO

### Estado: MENU
```
Música: menu/menu_song.mp3 (loop)
SFX permitidos: playClick()
Transición: fade in suave
```

### Estado: GAMEPLAY
```
Música: gameplay/{region}/{region}_wave.mp3
  - 'gameplay/america/america_wave.mp3'
  - 'gameplay/asia/asia_wave.mp3'
  - 'gameplay/europa/europa_wave.mp3'

SFX permitidos: playHit(), playCoin(), playKnife()
Transición: fade in/out
```

### Estado: BOSS
```
Pre-música: sfx/alerta_boss.mp3 (200ms antes)
Música: gameplay/{region}/boss_{region}.mp3
  - 'gameplay/america/boss_america.mp3'
  - 'gameplay/asia/boss_asia.mp3'
  - 'gameplay/europa/boss_europa.mp3'

SFX permitidos: todos (prioridad máxima)
Transición: fade in/out
```

### Estado: TIENDA
```
Música: tienda/shop.mp3 (loop)
SFX específicos: playUpgrade(), playGacha()
Transición: fade in/out
```

---

## 🔊 MÉTODOS DE SFX ESPECÍFICOS

```dart
// Sonido de golpe
AudioManager().playHit();              // sfx/hit.mp3

// Moneda/recompensa
AudioManager().playCoin();             // sfx/coin_collect.mp3

// Cuchillo
AudioManager().playKnife();            // sfx/lanzar_cuchillo.mp3

// Click genérico
AudioManager().playClick();            // sfx/click_objetos.mp3

// Mejora/upgrade
AudioManager().playUpgrade();          // sfx/mejorarChef_Arma.mp3

// Gacha/sorteo
AudioManager().playGacha();            // tienda/click_gacha.mp3
```

---

## 🔄 FLUJO DE ESTADOS

```
Inicio
  ↓
main.dart → initialize AudioManager
  ↓
MenuScreen → setState(MENU)
  ↓
Usuario presiona "JUGAR" + playClick()
  ↓
GameScreen → setState(GAMEPLAY, 'america')
  ↓
├─ Durante gameplay:
│  ├─ playHit() en eventos
│  ├─ playCoin() en recompensas
│  └─ changeRegion('asia') → setState(GAMEPLAY, 'asia')
│
├─ Boss aparece:
│  └─ setState(BOSS, 'america')
│     → alerta_boss.mp3
│     → boss_america.mp3
│
├─ Boss muere:
│  └─ setState(GAMEPLAY, 'america')
│     → vuelta a music de gameplay
│
└─ Tienda:
   └─ setState(TIENDA)
      → shop.mp3
      → playGacha(), playUpgrade()

App minimizada → pauseApp()
App vuelve → resumeApp()
```

---

## 🎯 REGLAS CRÍTICAS

1. **Nunca 2 músicas simultáneamente**
   - Fade out anterior antes de fade in nueva
   - `playMusicWithFadeIn()` maneja todo

2. **Boss tiene prioridad**
   - Siempre: BOSS > GAMEPLAY > MENU > TIENDA
   - Al salir del boss, volver al estado anterior

3. **No repetir la misma canción**
   - `playMusic()` verifica si ya está sonando
   - `setState()` comprueba cambios reales

4. **SFX no interrumpen música**
   - SFX en player separado
   - Respetan volumen de música

5. **Transiciones limpias**
   - Fade out: 300ms
   - Fade in: 300ms
   - Alerta de boss: 200ms antes

6. **Ciclo de vida de app**
   - Minimizar: `pauseApp()`  → pausa música
   - Volver: `resumeApp()` → reanuda música

---

## 📁 ARCHIVOS CREADOS

```
✅ lib/models/audio_game_state.dart
   - Enum AudioGameState
   - AudioGameStateManager

✅ lib/services/audio_manager.dart (mejorado)
   - playMusic() / playMusicWithFadeIn()
   - playSfx() + métodos específicos
   - Fade in/out automático
   - State listener integrado

✅ lib/screens/AUDIO_STATE_INTEGRATION_EXAMPLES.dart
   - Integración main.dart
   - Integración screens
   - Cambio de región
   - Manejo de boss

✅ lib/screens/FLAME_AUDIO_INTEGRATION.dart
   - Integración FlameGame
   - Componentes audio-aware
   - Ejemplos de eventos
```

---

## ✅ CHECKLIST FINAL

- [ ] Archivos creados en ubicaciones correctas
- [ ] AudioManager inicializado en main.dart
- [ ] WidgetsBindingObserver para app lifecycle
- [ ] MenuScreen cambia a MENU state
- [ ] GameScreen cambia a GAMEPLAY state
- [ ] FlameGame conoce sobre estado
- [ ] Componentes reproducen SFX en eventos
- [ ] Boss cambia a BOSS state con alerta
- [ ] Assets de audio existen y son accesibles
- [ ] Fade in/out suena bien
- [ ] Sin solapamientos de música

---

## 🐛 DEBUGGING

**Habilitar logs detallados:**
```dart
// Ya implementado con kDebugMode
// Ver console para:
// [AudioManager] Reproduciendo música: path
// [AudioManager] Estado cambió: oldState → newState
// [AudioManager] Fade in/out completado
```

**Verificar estado actual:**
```dart
final manager = AudioManager();
print(manager.stateManager.currentState);      // AudioGameState
print(manager.stateManager.currentRegion);     // Región actual
print(manager.currentMusicPath);               // Música sonando
print(manager.isMusicPlaying);                 // ¿Reproduciéndose?
```

**Probar cambios de estado:**
```dart
// En console o botón de debug
AudioManager().stateManager.setState(AudioGameState.boss, region: 'america');
```

---

## 🎉 YA ESTÁ HECHO

- ✅ Máquina de estados audio
- ✅ Fade in/out
- ✅ SFX específicos
- ✅ Integración Flame
- ✅ Ciclo de vida app
- ✅ Sin solapamientos
- ✅ Documentación completa

**¡Tu audio está 100% sincronizado con el juego!**
