/// ═══════════════════════════════════════════════════════════════════════════
/// EJEMPLOS DE INTEGRACIÓN - AudioManager con GameState
/// Muestra cómo usar el sistema de audio sincronizado con estados
/// ═══════════════════════════════════════════════════════════════════════════

// NOTE: This file contains example code in comments. No actual imports used here.

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 1: INTEGRACIÓN EN main.dart
// ═══════════════════════════════════════════════════════════════════════════

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AudioManager (incluye state manager)
  final audioManager = AudioManager();
  await audioManager.initialize();

  runApp(
    ChangeNotifierProvider<AudioManager>.value(
      value: audioManager,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
*/

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 2: INTEGRACIÓN EN MENU SCREEN
// ═══════════════════════════════════════════════════════════════════════════

/*
class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Reproducir música de menú al cargar
    Future.microtask(() {
      final audioManager = context.read<AudioManager>();
      
      // Cambiar estado a menú (automáticamente reproduce música)
      audioManager.stateManager.setState(AudioGameState.menu);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioManager = context.read<AudioManager>();
    
    if (state == AppLifecycleState.paused) {
      // App minimizada
      audioManager.pauseApp();
    } else if (state == AppLifecycleState.resumed) {
      // App vuelve al frente
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PALETO KNIFE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                // Reproducir sonido de click
                context.read<AudioManager>().playClick();
                
                // Navegar al juego
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'JUGAR',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Reproducir sonido de click
                context.read<AudioManager>().playClick();
                
                // Reproducir música de tienda
                context.read<AudioManager>().stateManager.setState(
                  AudioGameState.tienda,
                );
                
                // Navegar a tienda
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'TIENDA',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 3: INTEGRACIÓN EN GAME SCREEN (CON FLAME)
// ═══════════════════════════════════════════════════════════════════════════

/*
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late MyGameClass gameInstance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    gameInstance = MyGameClass();

    // Cambiar audio al estado de gameplay (América por defecto)
    Future.microtask(() {
      context.read<AudioManager>().stateManager.setState(
        AudioGameState.gameplay,
        region: 'america',
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioManager = context.read<AudioManager>();
    
    if (state == AppLifecycleState.paused) {
      audioManager.pauseApp();
      gameInstance.pauseEngine();
    } else if (state == AppLifecycleState.resumed) {
      audioManager.resumeApp();
      gameInstance.resumeEngine();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameInstance.removeFromParent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(game: gameInstance),
    );
  }
}

// Tu clase Flame Game
class MyGameClass extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Inicialización del juego
    super.onLoad();
  }

  void pauseEngine() {
    pauseEngine();
  }

  void resumeEngine() {
    resumeEngine();
  }
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 4: CAMBIAR A BOSS (DENTRO DEL GAMEPLAY)
// ═══════════════════════════════════════════════════════════════════════════

/*
// En tu componente/lógica de juego cuando aparece un boss:

class BossComponent extends PositionComponent {
  @override
  Future<void> onMount() async {
    super.onMount();
    
    // Cambiar a estado de boss
    AudioManager().stateManager.setState(
      AudioGameState.boss,
      region: 'america', // O la región actual
    );
    
    // La música boss se reproduce automáticamente
    // Y antes que nada, se reproduce sfx/alerta_boss.mp3
  }

  @override
  void onRemove() {
    super.onRemove();
    
    // Cuando el boss muere, volver a gameplay
    AudioManager().stateManager.setState(
      AudioGameState.gameplay,
      region: 'america',
    );
  }
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 5: USAR SFX EN EVENTOS
// ═══════════════════════════════════════════════════════════════════════════

/*
class PlayerComponent extends PositionComponent {
  void onHit() {
    // Reproducir sonido de golpe
    AudioManager().playHit();
  }

  void onKnife() {
    // Reproducir sonido de lanzar cuchillo
    AudioManager().playKnife();
  }

  void onCoinCollect(int amount) {
    // Reproducir sonido de moneda
    AudioManager().playCoin();
  }

  void onUpgrade() {
    // Reproducir sonido de mejora
    AudioManager().playUpgrade();
  }
}

class EnemyComponent extends PositionComponent {
  void onDeath() {
    // Click
    AudioManager().playClick();
  }
}

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Reproducir gacha
              AudioManager().playGacha();
              // ... abrir gacha
            },
            child: const Text('GACHA'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reproducir upgrade
              AudioManager().playUpgrade();
              // ... hacer upgrade
            },
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
  }
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// EJEMPLO 6: CAMBIAR REGIÓN (DURANTE GAMEPLAY)
// ═══════════════════════════════════════════════════════════════════════════

/*
// Cuando el jugador avanza a una nueva región

void advanceToRegion(String region) {
  final audioManager = AudioManager();
  
  // Cambiar estado (automáticamente cambia música)
  audioManager.stateManager.setState(
    AudioGameState.gameplay,
    region: region, // 'america', 'asia', 'europa'
  );
  
  // Reproducir efecto de transición
  audioManager.playUpgrade();
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// RESUMEN DE FLUJOS
// ═══════════════════════════════════════════════════════════════════════════

/*
FLUJO 1: Menú → Juego
  1. MenuScreen inicia → setS state(AudioGameState.menu)
  2. Usuario presiona "JUGAR" → playClick()
  3. Navega a GameScreen
  4. GameScreen inicia → setState(AudioGameState.gameplay, region: 'america')
  5. Música cambia automáticamente con fade

FLUJO 2: Gameplay → Boss
  1. BossComponent aparece → setState(AudioGameState.boss, region: 'america')
  2. Se reproduce sfx/alerta_boss.mp3
  3. Música cambia a boss music con fade
  4. BossComponent desaparece → setState(AudioGameState.gameplay)
  5. Música vuelve a gameplay con fade

FLUJO 3: Gameplay → Tienda → Gameplay
  1. Usuario entra a tienda → setState(AudioGameState.tienda)
  2. Música de tienda
  3. Usuario vuelve → setState(AudioGameState.gameplay)
  4. Música vuelve a gameplay

FLUJO 4: Eventos de SFX
  1. playHit() → sfx/hit.mp3 (no interrumpe música)
  2. playCoin() → sfx/coin_collect.mp3
  3. playKnife() → sfx/lanzar_cuchillo.mp3
  4. Y así para todos...

CICLO DE VIDA:
  1. App minimizada (AppLifecycleState.paused) → pauseApp()
  2. App vuelve (AppLifecycleState.resumed) → resumeApp()
*/

// ═══════════════════════════════════════════════════════════════════════════
// ESTRUCTURA DE ARCHIVOS FINAL
// ═══════════════════════════════════════════════════════════════════════════

/*
lib/
├── models/
│   ├── audio_game_state.dart               (Enum + State Manager)
│   └── [tus otros modelos]
├── services/
│   ├── audio_manager.dart                  (Manager mejorado)
│   └── [tus otros servicios]
├── screens/
│   ├── menu_screen.dart                    (Integración menú)
│   ├── game_screen.dart                    (Integración gameplay)
│   ├── shop_screen.dart                    (Integración tienda)
│   └── [otros screens]
└── main.dart                               (Inicialización)

assets/audio/
├── menu/
│   └── menu_song.mp3
├── gameplay/
│   ├── america/
│   │   ├── america_wave.mp3
│   │   └── boss_america.mp3
│   ├── asia/
│   │   ├── asia_wave.mp3
│   │   └── boss_asia.mp3
│   └── europa/
│       ├── europa_wave.mp3
│       └── boss_europa.mp3
├── sfx/
│   ├── hit.mp3
│   ├── coin_collect.mp3
│   ├── lanzar_cuchillo.mp3
│   ├── click_objetos.mp3
│   ├── mejorarChef_Arma.mp3
│   └── alerta_boss.mp3
└── tienda/
    ├── shop.mp3
    └── click_gacha.mp3
*/

class DummyClass {} // Archivo de documentación (no ejecutable)
