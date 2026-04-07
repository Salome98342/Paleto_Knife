import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/audio_game_state.dart';

/// AudioManager es un singleton global que maneja toda la reproducción de audio.
/// Gestiona música de fondo (BGM) y efectos de sonido (SFX) de forma independiente.
/// Además, integra máquina de estados para sincronización automática de audio.
class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  // Instancias de AudioPlayer
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;

  // Estado actual
  String? _currentMusicPath;
  bool _isMusicPlaying = false;
  bool _isMusicPaused = false;

  // Volúmenes
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;

  // Toggles
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  // Estado del juego
  late AudioGameStateManager _stateManager;

  // Transiciones suaves
  Timer? _fadeOutTimer;
  Timer? _fadeInTimer;
  static const int _fadeDurationMs = 300; // Duración de fade in/out

  // Getters
  String? get currentMusicPath => _currentMusicPath;
  bool get isMusicPlaying => _isMusicPlaying;
  bool get isMusicPaused => _isMusicPaused;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  /// Inicializa el AudioManager. DEBE ser llamado en main() o en la App.
  Future<void> initialize() async {
    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();

      // Configurar listeners para detectar fin de música
      _musicPlayer.onPlayerComplete.listen((_) {
        _isMusicPlaying = false;
        _isMusicPaused = false;
        _currentMusicPath = null;
        notifyListeners();
      });

      // Inicializar state manager
      _stateManager = AudioGameStateManager();
      
      // Escuchar cambios de estado
      _stateManager.addStateListener(_onGameStateChanged);

      // Precargamos los audios en cache de Flame
      await _preloadAllAudios();

      if (kDebugMode) {
        print('[AudioManager] Inicializado correctamente con máquina de estados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error en inicialización: $e');
      }
    }
  }

  /// Precarga todos los audios en el audioCache de Flame para mejor rendimiento
  Future<void> _preloadAllAudios() async {
    final audioList = [
      // Música
      'menu/menu_song.mp3',
      'gameplay/america/america_wave.mp3',
      'gameplay/america/boss_america.mp3',
      'gameplay/asia/asia_wave.mp3',
      'gameplay/asia/boss_asia.mp3',
      'gameplay/europa/europa_wave.mp3',
      'gameplay/europa/boss_europa.mp3',
      // SFX
      'sfx/alerta_boss.mp3',
      'sfx/click_objetos.mp3',
      'sfx/coin_collect.mp3',
      'sfx/hit.mp3',
      'sfx/lanzar_cuchillo.mp3',
      'sfx/mejorarChef_Arma.mp3',
      'tienda/click_gacha.mp3',
      'tienda/shop.mp3',
    ];

    try {
      for (final audio in audioList) {
        await FlameAudio.audioCache.load('audio/$audio');
      }
      if (kDebugMode) {
        print('[AudioManager] Todos los audios precargados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error precargando audios: $e');
      }
    }
  }

  // ==================== MÚSICA ====================

  /// Reproduce música. Si ya hay música sonando, la detiene primero.
  /// [path] debe ser la ruta relativa dentro de assets/audio/
  /// Ejemplo: 'menu/menu_song.mp3', 'gameplay/america/boss_america.mp3'
  Future<void> playMusic(String path) async {
    try {
      // Si la misma canción ya está sonando, no hacer nada
      if (_currentMusicPath == path && _isMusicPlaying) {
        if (kDebugMode) {
          print('[AudioManager] Música ya está sonando: $path');
        }
        return;
      }

      // Detener música anterior
      if (_musicPlayer.state == PlayerState.playing) {
        await _musicPlayer.stop();
      }

      _currentMusicPath = path;

      // Reproducir con volumen actual (si está habilitada)
      if (_musicEnabled) {
        await _musicPlayer.play(
          AssetSource('audio/$path'),
          volume: _musicVolume,
        );
        _isMusicPlaying = true;
        _isMusicPaused = false;
        if (kDebugMode) {
          print('[AudioManager] Reproduciendo música: $path');
        }
      } else {
        _isMusicPlaying = false;
        if (kDebugMode) {
          print('[AudioManager] Música deshabilitada, no reproduciéndose: $path');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error reproduciendo música: $e');
      }
    }
  }

  /// Pausa la música actual
  Future<void> pauseMusic() async {
    try {
      if (_isMusicPlaying && !_isMusicPaused) {
        await _musicPlayer.pause();
        _isMusicPaused = true;
        _isMusicPlaying = false;
        if (kDebugMode) {
          print('[AudioManager] Música pausada');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error pausando música: $e');
      }
    }
  }

  /// Reanuda la música pausada
  Future<void> resumeMusic() async {
    try {
      if (_isMusicPaused) {
        await _musicPlayer.resume();
        _isMusicPlaying = true;
        _isMusicPaused = false;
        if (kDebugMode) {
          print('[AudioManager] Música reanudada');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error reanudando música: $e');
      }
    }
  }

  /// Detiene la música
  Future<void> stopMusic() async {
    try {
      if (_musicPlayer.state == PlayerState.playing ||
          _musicPlayer.state == PlayerState.paused) {
        await _musicPlayer.stop();
      }
      _isMusicPlaying = false;
      _isMusicPaused = false;
      _currentMusicPath = null;
      if (kDebugMode) {
        print('[AudioManager] Música detenida');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error deteniendo música: $e');
      }
    }
  }

  // ==================== EFECTOS DE SONIDO ====================

  /// Reproduce un efecto de sonido. Puede haber múltiples SFX simultáneamente.
  /// [path] debe ser la ruta relativa dentro de assets/audio/
  /// Ejemplo: 'sfx/click_objetos.mp3', 'sfx/coin_collect.mp3'
  Future<void> playSfx(String path) async {
    try {
      if (!_sfxEnabled) {
        if (kDebugMode) {
          print('[AudioManager] SFX deshabilitado, no reproduciéndose: $path');
        }
        return;
      }

      await _sfxPlayer.play(
        AssetSource('audio/$path'),
        volume: _sfxVolume,
      );

      if (kDebugMode) {
        print('[AudioManager] Reproduciendo SFX: $path');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error reproduciendo SFX: $e');
      }
    }
  }

  // ==================== VOLUMEN ====================

  /// Establece el volumen de la música (0.0 - 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      _musicVolume = volume.clamp(0.0, 1.0);
      await _musicPlayer.setVolume(_musicVolume);
      if (kDebugMode) {
        print('[AudioManager] Volumen música: $_musicVolume');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error configurando volumen música: $e');
      }
    }
  }

  /// Establece el volumen de los efectos (0.0 - 1.0)
  Future<void> setSfxVolume(double volume) async {
    try {
      _sfxVolume = volume.clamp(0.0, 1.0);
      await _sfxPlayer.setVolume(_sfxVolume);
      if (kDebugMode) {
        print('[AudioManager] Volumen SFX: $_sfxVolume');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error configurando volumen SFX: $e');
      }
    }
  }

  // ==================== TOGGLES ====================

  /// Habilita o deshabilita la música
  Future<void> toggleMusic(bool enabled) async {
    try {
      _musicEnabled = enabled;

      if (!enabled) {
        await pauseMusic();
      } else if (_isMusicPaused || (_currentMusicPath != null && !_isMusicPlaying)) {
        await resumeMusic();
      }

      if (kDebugMode) {
        print('[AudioManager] Música ${enabled ? 'habilitada' : 'deshabilitada'}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error toggling música: $e');
      }
    }
  }

  /// Habilita o deshabilita los efectos de sonido
  Future<void> toggleSfx(bool enabled) async {
    try {
      _sfxEnabled = enabled;
      if (kDebugMode) {
        print('[AudioManager] SFX ${enabled ? 'habilitado' : 'deshabilitado'}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error toggling SFX: $e');
      }
    }
  }

  // ==================== MÁQUINA DE ESTADOS ====================

  /// Llamado automáticamente cuando cambia el estado del juego
  void _onGameStateChanged(AudioGameState oldState, AudioGameState newState) {
    if (kDebugMode) {
      print('[AudioManager] Estado cambió: $oldState → $newState');
    }

    // Obtener música para nuevo estado
    final newMusicPath = newState.getMusicPath(
      region: _stateManager.currentRegion,
    );

    // Si hay alerta SFX (bosses), reproducirla
    final alertSfx = newState.getAlertSfx();
    if (alertSfx != null) {
      _scheduleAlertSfx(alertSfx);
    }

    // Cambiar música con transición suave
    _transitionMusic(newMusicPath);
  }

  /// Programa un SFX de alerta (boss) antes de reproducir su música
  void _scheduleAlertSfx(String alertPath) {
    Future.delayed(Duration(milliseconds: 100), () {
      playSfx(alertPath);
    });
  }

  /// Realiza transición suave entre canciones
  void _transitionMusic(String newMusicPath) async {
    // Si ya está la misma canción, no hacer nada
    if (_currentMusicPath == newMusicPath && _isMusicPlaying) {
      return;
    }

    // Fade out de la música actual
    await _fadeOutMusic();

    // Cambiar música
    if (_musicEnabled) {
      await playMusicWithFadeIn(newMusicPath);
    } else {
      _currentMusicPath = newMusicPath;
    }
  }

  /// Reproduce música con fade in suave
  Future<void> playMusicWithFadeIn(String path) async {
    try {
      // Detener música anterior
      if (_musicPlayer.state == PlayerState.playing) {
        await _musicPlayer.stop();
      }

      _currentMusicPath = path;

      // Reproducir con volumen 0 (antes de fade in)
      if (_musicEnabled) {
        await _musicPlayer.play(
          AssetSource('audio/$path'),
          volume: 0.0,
        );
        _isMusicPlaying = true;
        _isMusicPaused = false;

        // Fade in
        await _fadeInMusic();

        if (kDebugMode) {
          print('[AudioManager] Música reproducida con fade in: $path');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error reproduciendo música con fade in: $e');
      }
    }
  }

  /// Fade out de la música actual
  Future<void> _fadeOutMusic() async {
    _fadeOutTimer?.cancel();

    if (!_isMusicPlaying || _currentMusicPath == null) {
      return;
    }

    const steps = 10;
    final stepDuration = Duration(milliseconds: _fadeDurationMs ~/ steps);
    double currentVolume = _musicVolume;

    for (int i = 0; i < steps; i++) {
      _fadeOutTimer = Timer(stepDuration * (i + 1), () async {
        currentVolume = _musicVolume * (1.0 - (i + 1) / steps);
        await _musicPlayer.setVolume(currentVolume);
      });
    }

    // Esperar a que termine el fade
    await Future.delayed(Duration(milliseconds: _fadeDurationMs));

    // Asegurar volumen en 0 y detener
    await _musicPlayer.setVolume(0.0);
    await _musicPlayer.stop();
  }

  /// Fade in de la música actual
  Future<void> _fadeInMusic() async {
    _fadeInTimer?.cancel();

    if (!_isMusicPlaying || _currentMusicPath == null) {
      return;
    }

    const steps = 10;
    final stepDuration = Duration(milliseconds: _fadeDurationMs ~/ steps);
    double currentVolume = 0.0;

    for (int i = 0; i < steps; i++) {
      _fadeInTimer = Timer(stepDuration * (i + 1), () async {
        currentVolume = _musicVolume * ((i + 1) / steps);
        await _musicPlayer.setVolume(currentVolume);
      });
    }

    // Esperar a que termine el fade
    await Future.delayed(Duration(milliseconds: _fadeDurationMs));

    // Asegurar volumen correcto
    await _musicPlayer.setVolume(_musicVolume);
  }

  // ==================== MÉTODOS ESPECÍFICOS DE SFX ====================

  /// Reproduce sonido de golpe
  void playHit() {
    playSfx('sfx/hit.mp3');
  }

  /// Reproduce sonido de moneda
  void playCoin() {
    playSfx('sfx/coin_collect.mp3');
  }

  /// Reproduce sonido de lanzar cuchillo
  void playKnife() {
    playSfx('sfx/lanzar_cuchillo.mp3');
  }

  /// Reproduce sonido de click
  void playClick() {
    playSfx('sfx/click_objetos.mp3');
  }

  /// Reproduce sonido de mejora
  void playUpgrade() {
    playSfx('sfx/mejorarChef_Arma.mp3');
  }

  /// Reproduce sonido de gacha
  void playGacha() {
    playSfx('tienda/click_gacha.mp3');
  }

  // ==================== CICLO DE VIDA DE LA APP ====================

  /// Pausa todo el audio (minimizar app, etc)
  void pauseApp() {
    if (kDebugMode) {
      print('[AudioManager] App pausada');
    }
    pauseMusic();
  }

  /// Reanuda el audio
  void resumeApp() {
    if (kDebugMode) {
      print('[AudioManager] App reanudada');
    }
    resumeMusic();
  }

  /// Obtiene el estado manager (para cambiar estados)
  AudioGameStateManager get stateManager => _stateManager;

  // ==================== LIMPIEZA ====================

  /// Libera recursos. Llamar en dispose() si es necesario
  Future<void> dispose() async {
    try {
      _fadeOutTimer?.cancel();
      _fadeInTimer?.cancel();
      _stateManager.removeStateListener(_onGameStateChanged);
      _stateManager.dispose();
      await _musicPlayer.dispose();
      await _sfxPlayer.dispose();
      if (kDebugMode) {
        print('[AudioManager] Recursos liberados');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] Error liberando recursos: $e');
      }
    }
    super.dispose();
  }
}
