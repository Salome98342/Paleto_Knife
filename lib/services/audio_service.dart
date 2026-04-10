import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

enum _BgmTrack { none, menu, gameplay, shop, settings }

/// Servicio global de audio para musica y efectos.
/// Optimizado para APK con manejo robusto de errores y ciclo de vida
class AudioService extends ChangeNotifier {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const String menuSongPath = 'assets/audio/menu/menu_song.mp3';
  // Música de gameplay - usa la región America por defecto
  static const String gameplaySongPath = 'assets/audio/gameplay/america/america_wave.mp3';
  static const String gameplayAsiaSongPath = 'assets/audio/gameplay/asia/asia_wave.mp3';
  static const String gameplayEuropaSongPath = 'assets/audio/gameplay/europa/europa_wave.mp3';
  // Música de tienda
  static const String shopSongPath = 'assets/audio/tienda/shop.mp3';
  // Música de configuración (usar menu_song por defecto)
  static const String cuchilloMenuPath = 'assets/audio/menu/menu_song.mp3';
  static const String coinCollectPath = 'assets/audio/sfx/coin_collect.mp3';
  static const String hitSoundPath = 'assets/audio/sfx/hit.mp3';
  static const String powerupSoundPath = 'assets/audio/sfx/improve_weapon.mp3';
  static const String clickObjectsPath = 'assets/audio/sfx/click_objetos.mp3';
  static const String clickGachaPath = 'assets/audio/tienda/click_gacha.mp3';
  static const String bossAlertPath = 'assets/audio/sfx/alerta_boss.mp3';
  static const String enemyDeathPath = 'assets/audio/sfx/damage_enemy.mp3';
  static const String bossDeathPath = 'assets/audio/sfx/muerte_boss.mp3';
  static const String knifeThrowPath = 'assets/audio/sfx/lanzar_cuchillo.mp3';

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
  final List<AudioPlayer> _sfxPlayers = List.generate(
    4,
    (i) => AudioPlayer(playerId: 'sfx_player_$i'),
  );
  int _nextSfxIndex = 0;

  bool _initialized = false;
  _BgmTrack _currentTrack = _BgmTrack.none;
  String? _lastRegionMusicPath;
  
  // Flags y control de estado mejorados
  bool _isWeb = false;
  bool _isDisposed = false;
  Timer? _initRetryTimer;
  int _initRetries = 0;
  static const int _maxInitRetries = 3;
  static const Duration _initRetryDelay = Duration(seconds: 1);

  double _bgmVolume = 0.55;
  double _sfxVolume = 0.9;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isMusicPlaying = false;

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get isMusicPlaying => _isMusicPlaying;
  double get musicVolume => _bgmVolume;

  @override
  void dispose() {
    _isDisposed = true;
    _initRetryTimer?.cancel();
    _bgmPlayer.dispose();
    for (var player in _sfxPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  static Future<void> init() async {
    await instance._ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized || _isDisposed) return;

    // Detectar si es web ANTES de chequear
    _isWeb = kIsWeb;
    debugPrint('[AudioService] 🔍 _isWeb = $_isWeb (kIsWeb = $kIsWeb)');
    
    if (_isWeb) {
      debugPrint('[AudioService] Corriendo en Web - Audio deshabilitado (AudioPlayers no soporta web)');
      _initialized = true;
      if (!_isDisposed) notifyListeners();
      return;
    }

    try {
      debugPrint('[AudioService] 🔧 Inicializando AudioService en Android/iOS...');
      final prefs = await SharedPreferences.getInstance();
      _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.55;
      _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.9;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
      
      debugPrint('[AudioService] ✓ Preferencias cargadas: BGM=$_bgmVolume, SFX=$_sfxVolume');

      // Configurar BGM player con reintentos
      debugPrint('[AudioService] 🎵 Configurando BGM player...');
      await _initAudioPlayer(
        _bgmPlayer,
        ReleaseMode.loop,
        _bgmVolume,
      );
      debugPrint('[AudioService] ✓ BGM player configurado');

      // Configurar SFX players
      debugPrint('[AudioService] 🔊 Configurando ${_sfxPlayers.length} SFX players...');
      for (var player in _sfxPlayers) {
        await _initAudioPlayer(
          player,
          ReleaseMode.release,
          _sfxVolume,
        );
      }
      debugPrint('[AudioService] ✓ SFX players configurados');

      _initialized = true;
      _initRetries = 0;
      debugPrint('[AudioService] ✅ INICIALIZACIÓN COMPLETADA');
      if (!_isDisposed) notifyListeners();
    } catch (e, stack) {
      debugPrint('[AudioService] ❌ ERROR inicializando: $e');
      debugPrint('[AudioService] Stack: $stack');
      
      // Reintentar conexión con backoff exponencial
      if (_initRetries < _maxInitRetries) {
        _initRetries++;
        debugPrint('[AudioService] 🔄 Reintentando... (${_initRetries}/$_maxInitRetries)');
        _initRetryTimer?.cancel();
        _initRetryTimer = Timer(
          _initRetryDelay * _initRetries,
          () => _ensureInitialized(),
        );
      } else {
        debugPrint('[AudioService] ❌ MÁXIMO DE REINTENTOS ALCANZADO');
      }
    }
  }

  Future<void> _initAudioPlayer(
    AudioPlayer player,
    ReleaseMode releaseMode,
    double volume,
  ) async {
    try {
      await player.setReleaseMode(releaseMode);
      await player.setVolume(volume);
    } catch (e) {
      debugPrint('[AudioService] Error configurando player: $e');
      rethrow;
    }
  }

  String _normalizeAssetPath(String path) {
    // AudioPlayers v6.1.0 necesita el path completo con 'assets/'
    // No remover nada - devolver el path tal cual
    return path;
  }

  bool _isChangingTrack = false;

  Future<void> _playBgm(String path, _BgmTrack track) async {
    if (_isDisposed) {
      debugPrint('[AudioService] ⚠️ Service disposed, skipping playback');
      return;
    }
    
    try {
      debugPrint('[🎵 AUDIO] Intentando reproducir: $path');
      
      // Asegurar que esté inicializado
      await _ensureInitialized();
      
      debugPrint('[🎵 AUDIO] _initialized=$_initialized, _isWeb=$_isWeb');

      if (_isWeb) {
        debugPrint('[🎵 AUDIO] Web detected - audio deshabilitado');
        return;
      }
      
      if (!_initialized) {
        debugPrint('[🎵 AUDIO] ❌ Not initialized');
        return;
      }

      // Si es la misma pista en reproducción, no hacer nada
      if (_currentTrack == track && _bgmPlayer.state == PlayerState.playing) {
        debugPrint('[🎵 AUDIO] Same track already playing');
        return;
      }

      _currentTrack = track;

      // Detener música actual si está en reproducción
      try {
        if (_bgmPlayer.state != PlayerState.stopped) {
          debugPrint('[🎵 AUDIO] Stopping current track...');
          await _bgmPlayer.stop();
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('[🎵 AUDIO] Error stopping: $e');
      }

      // Reproducir nueva canción
      debugPrint('[🎵 AUDIO] Playing: $path');
      
      try {
        await _bgmPlayer.play(AssetSource(path));
        _isMusicPlaying = true;
        debugPrint('[🎵 AUDIO] ✅ Playing: $path');
      } catch (e) {
        debugPrint('[🎵 AUDIO] ❌ Play error: $e');
        _isMusicPlaying = false;
      }
      
      if (!_isDisposed) notifyListeners();
      
    } catch (e, stack) {
      debugPrint('[🎵 AUDIO] ❌ _playBgm error: $e');
      debugPrint('[🎵 AUDIO] Stack: $stack');
    }
  }

  Future<void> playMenuMusic() {
    debugPrint('[AudioService] ▶ Reproduciendo música de menú');
    return _playBgm(menuSongPath, _BgmTrack.menu);
  }

  Future<void> playSettingsMusic() {
    debugPrint('[AudioService] ▶ Reproduciendo música de configuración');
    return _playBgm(cuchilloMenuPath, _BgmTrack.settings);
  }

  Future<void> playGameplayMusic() {
    debugPrint('[AudioService] ▶ Reproduciendo música de gameplay');
    return _playBgm(gameplaySongPath, _BgmTrack.gameplay);
  }

  // Métodos para reproducir música de gameplay según la región
  Future<void> playAmericaMusic() =>
      _playBgm('assets/audio/gameplay/america/america_wave.mp3', _BgmTrack.gameplay);

  Future<void> playAsiaMusic() =>
      _playBgm('assets/audio/gameplay/asia/asia_wave.mp3', _BgmTrack.gameplay);

  Future<void> playEuropaMusic() =>
      _playBgm('assets/audio/gameplay/europa/europa_wave.mp3', _BgmTrack.gameplay);

  // Métodos para reproducir música de boss según la región
  Future<void> playAmericaBossMusic() =>
      _playBgm('assets/audio/gameplay/america/boss_america.mp3', _BgmTrack.gameplay);

  Future<void> playAsiaBossMusic() =>
      _playBgm('assets/audio/gameplay/asia/boss_asia.mp3', _BgmTrack.gameplay);

  Future<void> playEuropaBossMusic() =>
      _playBgm('assets/audio/gameplay/europa/boss_europa.mp3', _BgmTrack.gameplay);

  /// Reproduce la última música de region que se estaba tocando (para volver desde tienda)
  Future<void> playLastGameplayMusic() async {
    if (_lastRegionMusicPath != null) {
      await _playBgm(_lastRegionMusicPath!, _BgmTrack.gameplay);
    } else {
      // Fallback a America si no hay última música
      await playAmericaMusic();
    }
  }

  Future<void> playShopMusic() => _playBgm(shopSongPath, _BgmTrack.shop);

  Future<void> stopMusic() async {
    if (_isDisposed) return;
    
    try {
      await _ensureInitialized();
      if (!_initialized) return;

      _currentTrack = _BgmTrack.none;
      _isMusicPlaying = false;
      
      if (!_isWeb) {
        await _bgmPlayer.stop().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('[AudioService] Timeout deteniendo música');
          },
        );
      }
      
      if (!_isDisposed) notifyListeners();
    } on Exception catch (e) {
      debugPrint('[AudioService] Error deteniendo música: $e');
    }
  }

  Future<void> _playSfxInternal(String path, int index) async {
    if (_isDisposed || _isWeb || !_initialized || !_sfxEnabled) return;

    try {
      final player = _sfxPlayers[index];
      final normalizedPath = _normalizeAssetPath(path);

      // Detener SFX actual de forma segura
      try {
        if (player.state == PlayerState.playing) {
          await player.stop().timeout(const Duration(milliseconds: 500));
        }
      } on Exception catch (e) {
        debugPrint('[AudioService] Error deteniendo SFX anterior: $e');
      }

      // Pequeña espera
      await Future.delayed(const Duration(milliseconds: 50));

      // Reproducir con timeout
      await player.play(AssetSource(normalizedPath)).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('[AudioService] Timeout reproduciendo SFX: $normalizedPath');
        },
      );
    } on Exception catch (e) {
      debugPrint('[AudioService] Error reproduciendо SFX: $e');
    }
  }

  Future<void> playSfx(String path) async {
    if (_isDisposed || !_initialized) return;
    
    // Obtener índice de forma sincrónica
    final int currentIndex = _nextSfxIndex;
    _nextSfxIndex = (_nextSfxIndex + 1) % _sfxPlayers.length;

    await _playSfxInternal(path, currentIndex);
  }

  Future<void> playCoinCollect() => playSfx(coinCollectPath);
  Future<void> playHitSound() => playSfx(hitSoundPath);
  Future<void> playPowerupSound() => playSfx(powerupSoundPath);
  Future<void> playClickSound() => playSfx(clickObjectsPath);
  Future<void> playClickGacha() => playSfx(clickGachaPath);
  Future<void> playBossAlert() => playSfx(bossAlertPath);
  Future<void> playEnemyDeath() => playSfx(enemyDeathPath);
  Future<void> playBossDeath() => playSfx(bossDeathPath);
  Future<void> playKnifeThrow() => playSfx(knifeThrowPath);

  // Alias compatibles con audio_manager para evitar refactoring
  void playClick() => playClickSound();
  void playGacha() => playClickGacha();
  void playUpgrade() => playPowerupSound();
  void playKnife() => playKnifeThrow();

  /// Controla si la música está habilitada
  Future<void> toggleMusic(bool enabled) async {
    if (_isDisposed) return;
    
    _musicEnabled = enabled;
    
    if (_isWeb || !_initialized) {
      if (!_isDisposed) notifyListeners();
      return;
    }

    try {
      if (enabled && _currentTrack != _BgmTrack.none) {
        await _bgmPlayer.resume();
        _isMusicPlaying = true;
      } else {
        await _bgmPlayer.pause();
        _isMusicPlaying = false;
      }
    } on Exception catch (e) {
      debugPrint('[AudioService] Error toggleando música: $e');
    }
    
    if (!_isDisposed) notifyListeners();
  }

  /// Controla si los efectos están habilitados
  Future<void> toggleSfx(bool enabled) async {
    if (_isDisposed) return;
    
    _sfxEnabled = enabled;

    if (!enabled && !_isWeb && _initialized) {
      try {
        for (var player in _sfxPlayers) {
          if (player.state == PlayerState.playing) {
            await player.stop();
          }
        }
      } on Exception catch (e) {
        debugPrint('[AudioService] Error deteniendo SFX: $e');
      }
    }
    
    if (!_isDisposed) notifyListeners();
  }

  /// Establece el volumen de música
  Future<void> setMusicVolume(double volume) async {
    if (_isDisposed) return;
    if (volume < 0 || volume > 1) return;

    _bgmVolume = volume;

    if (!_isWeb && _initialized) {
      try {
        await _bgmPlayer.setVolume(_bgmVolume);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('bgm_volume', _bgmVolume);
      } on Exception catch (e) {
        debugPrint('[AudioService] Error estableciendo volumen BGM: $e');
      }
    }
    
    if (!_isDisposed) notifyListeners();
  }

  /// Establece el volumen de efectos
  Future<void> setSfxVolume(double volume) async {
    if (_isDisposed) return;
    if (volume < 0 || volume > 1) return;

    _sfxVolume = volume;

    if (!_isWeb && _initialized) {
      try {
        for (var player in _sfxPlayers) {
          await player.setVolume(_sfxVolume);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('sfx_volume', _sfxVolume);
      } on Exception catch (e) {
        debugPrint('[AudioService] Error estableciendo volumen SFX: $e');
      }
    }
    
    if (!_isDisposed) notifyListeners();
  }

  /// Pausa toda la música cuando la app se pausa
  Future<void> pauseApp() async {
    if (_isDisposed || _isWeb || !_initialized) return;
    
    try {
      if (_bgmPlayer.state == PlayerState.playing) {
        await _bgmPlayer.pause();
      }
    } on Exception catch (e) {
      debugPrint('[AudioService] Error pausando app: $e');
    }
  }

  /// Reanuda la música cuando la app vuelve
  Future<void> resumeApp() async {
    if (_isDisposed || _isWeb || !_initialized) return;
    
    try {
      if (_currentTrack != _BgmTrack.none &&
          _bgmPlayer.state == PlayerState.paused) {
        await _bgmPlayer.resume();
      }
    } on Exception catch (e) {
      debugPrint('[AudioService] Error reanudando app: $e');
    }
  }
}
