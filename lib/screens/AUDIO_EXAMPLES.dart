import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_manager.dart';
import '../models/audio_settings.dart';
import '../widgets/audio_settings_modal.dart';

// ═══════════════════════════════════════════════════════════════
// EJEMPLO 1: main.dart - Inicialización completa
// ═══════════════════════════════════════════════════════════════

void mainExample() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AudioManager
  final audioManager = AudioManager();
  await audioManager.initialize();
  
  // Inicializar y cargar configuración guardada
  final audioSettings = AudioSettings();
  await audioSettings.initialize();
  
  // Aplicar configuración guardada al AudioManager
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
      home: const MenuScreenExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EJEMPLO 2: Menu Screen
// ═══════════════════════════════════════════════════════════════

class MenuScreenExample extends StatefulWidget {
  const MenuScreenExample({Key? key}) : super(key: key);

  @override
  State<MenuScreenExample> createState() => _MenuScreenExampleState();
}

class _MenuScreenExampleState extends State<MenuScreenExample> {
  @override
  void initState() {
    super.initState();
    _initializeMenuMusic();
  }

  void _initializeMenuMusic() {
    // Esperar un frame para acceder a context
    Future.microtask(() {
      final audioManager = AudioManager();
      audioManager.playMusic('menu/menu_song.mp3');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenido del menú
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'KNIFE CLICKER',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.amber[400],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Detener música de menú
                    AudioManager().stopMusic();
                    // Navegar (aquí irías a GameScreen)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ir a GameScreen')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                  ),
                  child: const Text('JUGAR'),
                ),
              ],
            ),
          ),
          // Botón de ajustes
          AudioSettingsButton(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EJEMPLO 3: Game Screen con StopWatch y controles
// ═══════════════════════════════════════════════════════════════

class GameScreenExample extends StatefulWidget {
  final String region;

  const GameScreenExample({
    Key? key,
    this.region = 'america',
  }) : super(key: key);

  @override
  State<GameScreenExample> createState() => _GameScreenExampleState();
}

class _GameScreenExampleState extends State<GameScreenExample> {
  int score = 0;
  bool isBossActive = false;

  @override
  void initState() {
    super.initState();
    _startGameMusic();
  }

  void _startGameMusic() {
    Future.microtask(() {
      final audioManager = AudioManager();
      final musicPath = 'gameplay/${widget.region}/${widget.region}_wave.mp3';
      audioManager.playMusic(musicPath);
    });
  }

  void _onTapGround() {
    score++;
    AudioManager().playSfx('sfx/lanzar_cuchillo.mp3');
  }

  void _onCoinCollect() {
    score += 10;
    AudioManager().playSfx('sfx/coin_collect.mp3');
  }

  void _onEnemyHit() {
    AudioManager().playSfx('sfx/hit.mp3');
  }

  void _activateBoss() {
    if (isBossActive) return;

    isBossActive = true;
    AudioManager().playSfx('sfx/alerta_boss.mp3');

    // Cambiar a música de boss después de la alerta
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final bossMusic =
            'gameplay/${widget.region}/boss_${widget.region}.mp3';
        AudioManager().playMusic(bossMusic);
      }
    });
  }

  void _defeatedBoss() {
    if (!isBossActive) return;

    isBossActive = false;
    AudioManager().stopMusic();
    AudioManager().playSfx('sfx/coin_collect.mp3');

    // Volver a música normal
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final musicPath = 'gameplay/${widget.region}/${widget.region}_wave.mp3';
        AudioManager().playMusic(musicPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenido del juego
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.amber[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _onTapGround,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: isBossActive
                            ? Colors.red[900]
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isBossActive ? Colors.red : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isBossActive ? '👹 BOSS' : '🎮 TAP',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _onCoinCollect,
                        child: const Text('Moneda'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _onEnemyHit,
                        child: const Text('Golpe'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _activateBoss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('BOSS'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _defeatedBoss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Derrotar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botón de ajustes
          AudioSettingsButton(),

          // Indicador de estado de audio (opcional)
          AudioStatusBar(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// EJEMPLO 4: Gacha/Shop Screen
// ═══════════════════════════════════════════════════════════════

class GachaScreenExample extends StatefulWidget {
  const GachaScreenExample({Key? key}) : super(key: key);

  @override
  State<GachaScreenExample> createState() => _GachaScreenExampleState();
}

class _GachaScreenExampleState extends State<GachaScreenExample> {
  int pulls = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      AudioManager().playMusic('tienda/shop.mp3');
    });
  }

  void _performPull() {
    setState(() => pulls++);
    AudioManager().playSfx('tienda/click_gacha.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GACHA',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.amber[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Tiradas: $pulls',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.amber[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amber[400]!,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: _performPull,
                        child: Text(
                          '🎁\nTIRAR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AudioSettingsButton(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EJEMPLO 5: Uso directo del AudioManager
// ═══════════════════════════════════════════════════════════════

class AudioUsageExamples {
  static void examplesOfUsage() async {
    final audioManager = AudioManager();

    // ========== REPRODUCIR MÚSICA ==========
    await audioManager.playMusic('menu/menu_song.mp3');
    await audioManager.playMusic('gameplay/america/america_wave.mp3');
    await audioManager.playMusic('gameplay/america/boss_america.mp3');

    // ========== CONTROLES DE MÚSICA ==========
    await audioManager.pauseMusic();
    await audioManager.resumeMusic();
    await audioManager.stopMusic();

    // ========== REPRODUCIR EFECTOS ==========
    await audioManager.playSfx('sfx/click_objetos.mp3');
    await audioManager.playSfx('sfx/coin_collect.mp3');
    await audioManager.playSfx('sfx/hit.mp3');
    await audioManager.playSfx('sfx/lanzar_cuchillo.mp3');
    await audioManager.playSfx('sfx/mejorarChef_Arma.mp3');
    await audioManager.playSfx('sfx/alerta_boss.mp3');
    await audioManager.playSfx('tienda/click_gacha.mp3');

    // ========== CONTROL DE VOLUMEN ==========
    await audioManager.setMusicVolume(0.5);   // 50%
    await audioManager.setMusicVolume(0.7);   // 70%
    await audioManager.setSfxVolume(0.8);     // 80%
    await audioManager.setSfxVolume(1.0);     // 100%

    // ========== TOGGLES ==========
    await audioManager.toggleMusic(true);     // Habilitar
    await audioManager.toggleMusic(false);    // Deshabilitar
    await audioManager.toggleSfx(true);
    await audioManager.toggleSfx(false);

    // ========== LEER ESTADO ==========
    bool isPlaying = audioManager.isMusicPlaying;
    bool isPaused = audioManager.isMusicPaused;
    String? currentMusic = audioManager.currentMusicPath;
    double musicVol = audioManager.musicVolume;
    double sfxVol = audioManager.sfxVolume;
    bool musicEnabled = audioManager.musicEnabled;
    bool sfxEnabled = audioManager.sfxEnabled;

    print('Música sonando: $isPlaying');
    print('Música pausada: $isPaused');
    print('Canción actual: $currentMusic');
    print('Volumen música: $musicVol');
    print('Volumen SFX: $sfxVol');
    print('Música habilitada: $musicEnabled');
    print('SFX habilitado: $sfxEnabled');
  }
}
