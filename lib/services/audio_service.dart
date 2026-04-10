import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum _BgmTrack { none, menu, gameplay, shop, settings }

/// Servicio global de audio para musica y efectos.
/// Notifica cambios para integración con Provider
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
  static const String powerupSoundPath = 'assets/audio/sfx/powerup.mp3';
  static const String clickObjectsPath = 'assets/audio/sfx/click_objetos.mp3';
  static const String clickGachaPath = 'assets/audio/tienda/click_gacha.mp3';
  static const String bossAlertPath = 'assets/audio/sfx/alerta_boss.mp3';
  static const String enemyDeathPath = 'assets/audio/sfx/daño_a_enemigo.mp3';
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
  String? _lastRegionMusicPath; // Rastrear última música de región

  double _bgmVolume = 0.55;
  double _sfxVolume = 0.9;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isMusicPlaying = false;
  bool _isWeb = false; // Flag para deshabilitar audio en web

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get isMusicPlaying => _isMusicPlaying;
  double get musicVolume => _bgmVolume;  // Alias para compatibilidad

  static Future<void> init() async {
    await instance._ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    _isWeb = kIsWeb; // Detectar plataforma web

    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.55;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.9;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
    _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;

    // En web, no inicializar AudioPlayers para evitar errores
    if (_isWeb) {
      _initialized = true;
      notifyListeners();
      return;
    }

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);

    for (var player in _sfxPlayers) {
      await player.setReleaseMode(ReleaseMode.release);
      await player.setVolume(_sfxVolume);
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setBgmVolume(double v) async {
    _bgmVolume = v;
    if (_initialized) {
      await _bgmPlayer.setVolume(_bgmVolume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('bgm_volume', _bgmVolume);
      notifyListeners();
    }
  }

  String _normalizeAssetPath(String path) {
    if (path.startsWith('assets/')) {
      return path.substring('assets/'.length);
    }
    return path;
  }

  bool _isChangingTrack = false;

  Future<void> _playBgm(String path, _BgmTrack track) async {
    try {
      await _ensureInitialized();

      // No reproducir audio en web
      if (_isWeb) return;

      if (_currentTrack == track) {
        if (_bgmPlayer.state != PlayerState.playing) {
          await _bgmPlayer.resume();
        }
        return;
      }

      // Evitar condiciones de carrera si se llama rapido varias veces
      while (_isChangingTrack) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      _isChangingTrack = true;

      _currentTrack = track;

      // Guardar path si es gameplay (para recrear la región correcta después)
      if (track == _BgmTrack.gameplay) {
        _lastRegionMusicPath = path;
      }

      // Detener y liberar recursos del track anterior
      try {
        if (_bgmPlayer.state == PlayerState.playing ||
            _bgmPlayer.state == PlayerState.paused) {
          await _bgmPlayer.stop();
        }
      } catch (_) {
        // Ignorar posibles abortos preexistentes
      }

      // Pequena espera para que el plugin de audio libere el canal nativo
      await Future.delayed(const Duration(milliseconds: 100));

      await _bgmPlayer.play(AssetSource(_normalizeAssetPath(path)));
    } catch (e) {
      print('Error playing BGM: $e');
    } finally {
      _isChangingTrack = false;
    }
  }

  Future<void> playMenuMusic() => _playBgm(menuSongPath, _BgmTrack.menu);

  Future<void> playSettingsMusic() =>
      _playBgm(cuchilloMenuPath, _BgmTrack.settings);

  Future<void> playGameplayMusic() =>
      _playBgm(gameplaySongPath, _BgmTrack.gameplay);

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
    await _ensureInitialized();
    _currentTrack = _BgmTrack.none;
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playSfxInternal(String path, int index) async {
    try {
      await _ensureInitialized();

      // No reproducir SFX en web
      if (_isWeb) return;

      final player = _sfxPlayers[index];

      try {
        if (player.state == PlayerState.playing) {
          await player.stop();
        }
      } catch (_) {}

      await player.play(AssetSource(_normalizeAssetPath(path)));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  Future<void> playSfx(String path) async {
    // Reservamos el indice sincronamente antes de cualquier await
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
    _musicEnabled = enabled;
    if (enabled && _currentTrack != _BgmTrack.none) {
      await _bgmPlayer.resume();
    } else {
      await _bgmPlayer.pause();
    }
    notifyListeners();
  }

  /// Controla si los efectos están habilitados
  Future<void> toggleSfx(bool enabled) async {
    _sfxEnabled = enabled;
    if (!enabled) {
      // Detener todos los SFX en reproducción
      for (var player in _sfxPlayers) {
        try {
          await player.stop();
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  /// Establece el volumen de música
  Future<void> setMusicVolume(double volume) async {
    if (volume < 0 || volume > 1) return;
    _bgmVolume = volume;
    await _bgmPlayer.setVolume(_bgmVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgm_volume', _bgmVolume);
    notifyListeners();
  }

  /// Establece el volumen de efectos
  Future<void> setSfxVolume(double volume) async {
    if (volume < 0 || volume > 1) return;
    _sfxVolume = volume;
    for (var player in _sfxPlayers) {
      await player.setVolume(_sfxVolume);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', _sfxVolume);
    notifyListeners();
  }
}
