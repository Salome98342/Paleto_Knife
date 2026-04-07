import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════
// SISTEMA DINÁMICO DE AUDIO POR REGIONES
// World-Based Music Architecture
// ═══════════════════════════════════════════════════════════════

/// Enum para las regiones del juego
enum GameRegion {
  america('america'),
  asia('asia'),
  europa('europa');

  final String code;
  const GameRegion(this.code);

  /// Obtiene la ruta de música de onda/normal
  String get waveMusic => 'gameplay/$code/${code}_wave.mp3';

  /// Obtiene la ruta de música de boss
  String get bossMusic => 'gameplay/$code/boss_$code.mp3';
}

/// Clase para manejar estado de música por región
class RegionMusicState {
  final GameRegion region;
  String? currentMusicPath;
  bool isBossActive = false;
  double transitionProgress = 0.0;

  RegionMusicState({required this.region});

  String get activeMusic {
    return isBossActive ? region.bossMusic : region.waveMusic;
  }

  void reset() {
    currentMusicPath = null;
    isBossActive = false;
    transitionProgress = 0.0;
  }
}

/// Manager dinámico para audio por región
/// Escalable para agregar más regiones o tipos de música
class RegionAudioManager {
  static final RegionAudioManager _instance = RegionAudioManager._internal();

  factory RegionAudioManager() {
    return _instance;
  }

  RegionAudioManager._internal();

  late Map<GameRegion, RegionMusicState> _regionStates = {
    for (final region in GameRegion.values)
      region: RegionMusicState(region: region),
  };

  GameRegion _currentRegion = GameRegion.america;

  // Duración de transición entre canciones (en ms)
  static const int transitionDuration = 800;

  // Callbacks para eventos
  VoidCallback? onRegionChanged;
  Function(GameRegion)? onBossActivated;
  Function(GameRegion)? onBossDefeated;

  // ==================== GETTERS ====================

  GameRegion get currentRegion => _currentRegion;
  RegionMusicState get currentRegionState => _regionStates[_currentRegion]!;
  bool get isBossActive => currentRegionState.isBossActive;

  // ==================== INICIALIZACIÓN ====================

  Future<void> initialize() async {
    if (kDebugMode) {
      print('[RegionAudioManager] Inicializado');
    }
  }

  // ==================== CAMBIO DE REGIÓN ====================

  /// Cambia a una nueva región con transición suave
  /// [newRegion] - La nueva región
  /// [smooth] - Si true, hace transición gradual del volumen
  Future<void> switchToRegion(
    GameRegion newRegion, {
    bool smooth = true,
  }) async {
    if (_currentRegion == newRegion && !currentRegionState.isBossActive) {
      if (kDebugMode) {
        print('[RegionAudioManager] Ya estás en ${newRegion.code}');
      }
      return;
    }

    if (kDebugMode) {
      print('[RegionAudioManager] Cambiando a región: ${newRegion.code}');
    }

    _currentRegion = newRegion;
    currentRegionState.isBossActive = false;

    if (smooth) {
      await _transitionToMusic(_currentRegion.waveMusic);
    } else {
      // Cambio instantáneo
      await FlameAudio.bgm.play(_currentRegion.waveMusic);
      currentRegionState.currentMusicPath = _currentRegion.waveMusic;
    }

    onRegionChanged?.call();
  }

  // ==================== TRANSICIONES DE MÚSICA ====================

  /// Transición suave entre canciones
  Future<void> _transitionToMusic(String musicPath) async {
    try {
      // Para implementación real, necesitarías controlar el volumen
      await FlameAudio.bgm.play(musicPath);
      currentRegionState.currentMusicPath = musicPath;
      currentRegionState.transitionProgress = 1.0;

      if (kDebugMode) {
        print('[RegionAudioManager] Transición a: $musicPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RegionAudioManager] Error en transición: $e');
      }
    }
  }

  // ==================== BOSS ====================

  /// Activa el boss y cambia la música
  Future<void> activateBoss() async {
    if (currentRegionState.isBossActive) {
      if (kDebugMode) {
        print('[RegionAudioManager] Boss ya está activo');
      }
      return;
    }

    if (kDebugMode) {
      print('[RegionAudioManager] Activando boss en ${_currentRegion.code}');
    }

    currentRegionState.isBossActive = true;
    await _transitionToMusic(_currentRegion.bossMusic);

    onBossActivated?.call(_currentRegion);
  }

  /// Derrota el boss y vuelve a música normal
  Future<void> defeatBoss() async {
    if (!currentRegionState.isBossActive) {
      if (kDebugMode) {
        print('[RegionAudioManager] No hay boss activo');
      }
      return;
    }

    if (kDebugMode) {
      print('[RegionAudioManager] Derrotado boss en ${_currentRegion.code}');
    }

    currentRegionState.isBossActive = false;
    await _transitionToMusic(_currentRegion.waveMusic);

    onBossDefeated?.call(_currentRegion);
  }

  // ==================== CONTROL GENERAL ====================

  /// Pausa toda la música
  Future<void> pauseAll() async {
    try {
      await FlameAudio.bgm.pause();
      if (kDebugMode) {
        print('[RegionAudioManager] Música pausada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RegionAudioManager] Error pausando: $e');
      }
    }
  }

  /// Reanuda la música
  Future<void> resumeAll() async {
    try {
      await FlameAudio.bgm.resume();
      if (kDebugMode) {
        print('[RegionAudioManager] Música reanudada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RegionAudioManager] Error reanudando: $e');
      }
    }
  }

  /// Detiene toda la música
  Future<void> stopAll() async {
    try {
      await FlameAudio.bgm.stop();
      for (var state in _regionStates.values) {
        state.reset();
      }
      if (kDebugMode) {
        print('[RegionAudioManager] Música detenida');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RegionAudioManager] Error deteniendo: $e');
      }
    }
  }

  // ==================== ESTADÍSTICAS ====================

  /// Obtiene información de todas las regiones
  Map<String, dynamic> getFullStatus() {
    return {
      'currentRegion': _currentRegion.code,
      'isBossActive': isBossActive,
      'currentMusic': currentRegionState.currentMusicPath,
      'regions': {
        for (final region in GameRegion.values)
          region.code: {
            'waveMusic': region.waveMusic,
            'bossMusic': region.bossMusic,
            'isBossActive': _regionStates[region]!.isBossActive,
          }
      }
    };
  }

  void printStatus() {
    if (kDebugMode) {
      print('[RegionAudioManager] Estado actual:');
      print(getFullStatus().toString());
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// EJEMPLOS DE USO
// ═══════════════════════════════════════════════════════════════

class RegionAudioExamples {
  static Future<void> demonstrateUsage() async {
    final regionAudio = RegionAudioManager();

    // Inicializar
    await regionAudio.initialize();

    // ========== CAMBIAR REGIÓN ==========
    await regionAudio.switchToRegion(GameRegion.america);
    await regionAudio.switchToRegion(GameRegion.asia);
    await regionAudio.switchToRegion(GameRegion.europa);

    // ========== BOSS ==========
    await regionAudio.activateBoss();
    // [El boss lucha...]
    await regionAudio.defeatBoss();

    // ========== CONTROL ==========
    await regionAudio.pauseAll();
    await regionAudio.resumeAll();
    await regionAudio.stopAll();

    // ========== ESTADO ==========
    regionAudio.printStatus();
    // ignore: unused_local_variable
    final status = regionAudio.getFullStatus();
  }
}

// ═══════════════════════════════════════════════════════════════
// INTEGRACIÓN CON FLUTTER WIDGET
// ═══════════════════════════════════════════════════════════════

/// Widget para cambiar entre regiones interactivamente
class RegionSelectorWidget extends StatefulWidget {
  const RegionSelectorWidget({Key? key}) : super(key: key);

  @override
  State<RegionSelectorWidget> createState() => _RegionSelectorWidgetState();
}

class _RegionSelectorWidgetState extends State<RegionSelectorWidget> {
  late RegionAudioManager regionAudio;

  @override
  void initState() {
    super.initState();
    regionAudio = RegionAudioManager();
    _setupCallbacks();
  }

  void _setupCallbacks() {
    regionAudio.onRegionChanged = () {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Región: ${regionAudio.currentRegion.code.toUpperCase()}',
            ),
          ),
        );
      }
    };

    regionAudio.onBossActivated = (region) {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡BOSS ACTIVADO!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

    regionAudio.onBossDefeated = (region) {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡BOSS DERROTADO!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Región: ${regionAudio.currentRegion.code.toUpperCase()}',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botones de región
            Wrap(
              spacing: 16,
              children: GameRegion.values.map((region) {
                final isActive = regionAudio.currentRegion == region;
                return ElevatedButton(
                  onPressed: () async {
                    await regionAudio.switchToRegion(region);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.blue : Colors.grey,
                  ),
                  child: Text(
                    region.code.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Botones de control
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await regionAudio.activateBoss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('ACTIVAR BOSS'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await regionAudio.defeatBoss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('DERROTAR BOSS'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await regionAudio.pauseAll();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('PAUSAR'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await regionAudio.resumeAll();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('REANUDAR'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Estado actual
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Región: ${regionAudio.currentRegion.code}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text(
                    'Boss activo: ${regionAudio.isBossActive}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text(
                    'Música actual: ${regionAudio.currentRegionState.currentMusicPath ?? 'N/A'}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
