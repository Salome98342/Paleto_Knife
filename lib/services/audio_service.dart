import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';

enum _BgmTrack { none, menu, gameplay, shop, settings }

/// Servicio global de audio para musica y efectos.
/// Optimizado para APK con manejo robusto de errores y ciclo de vida
class AudioService extends ChangeNotifier {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const String menuSongPath = 'audio/menu/menu_song.mp3';
  // Música de gameplay - usa la región America por defecto
  static const String gameplaySongPath = 'audio/gameplay/america/america_wave.mp3';
  static const String gameplayAsiaSongPath = 'audio/gameplay/asia/asia_wave.mp3';
  static const String gameplayEuropaSongPath = 'audio/gameplay/europa/europa_wave.mp3';
  // Música de tienda
  static const String shopSongPath = 'audio/tienda/shop.mp3';
  // Música de configuración (usar menu_song por defecto)
  static const String cuchilloMenuPath = 'audio/menu/menu_song.mp3';
  static const String coinCollectPath = 'audio/sfx/coin_collect.mp3';
  static const String hitSoundPath = 'audio/sfx/hit.mp3';
  static const String powerupSoundPath = 'audio/sfx/improve_weapon.mp3';
  static const String clickObjectsPath = 'audio/sfx/click_objetos.mp3';
  static const String clickGachaPath = 'audio/tienda/click_gacha.mp3';
  static const String bossAlertPath = 'audio/sfx/alerta_boss.mp3';
  static const String enemyDeathPath = 'audio/sfx/damage_enemy.mp3';
  static const String bossDeathPath = 'audio/sfx/muerte_boss.mp3';
  static const String knifeThrowPath = 'audio/sfx/lanzar_cuchillo.mp3';

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
  final List<AudioPlayer> _sfxPlayers = List.generate(
    4,
    (i) => AudioPlayer(playerId: 'sfx_player_$i'),
  );
  int _nextSfxIndex = 0;

  bool _initialized = false;
  _BgmTrack _currentTrack = _BgmTrack.none;
  String? _currentBgmPath; // Rastrear la canción actual
  String? _lastRegionMusicPath;
  
  // Flags y control de estado mejorados
  bool _isWeb = false;
  bool _isDisposed = false;
  final Map<String, String> _resolvedAssetPathCache = {};
  final Map<String, Uint8List> _audioBytesCache = {};
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
  bool get isInitialized => _initialized;
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
      
      // Configurar AudioContext para Android e iOS
      if (!_isWeb) {
        try {
          debugPrint('[AudioService] 🎚️ Configurando AudioContext detallado...');
          await _bgmPlayer.setAudioContext(
            AudioContext(
              android: AudioContextAndroid(
                isSpeakerphoneOn: true,
                stayAwake: true,
                contentType: AndroidContentType.music,
                usageType: AndroidUsageType.media,
                audioFocus: AndroidAudioFocus.gain,
              ),
              iOS: AudioContextIOS(
                category: AVAudioSessionCategory.playback,
                options: {
                  AVAudioSessionOptions.duckOthers,
                  AVAudioSessionOptions.defaultToSpeaker,
                },
              ),
            ),
          );
          debugPrint('[AudioService] ✓ AudioContext configurado correctamente para Android/iOS');
          debugPrint('[AudioService] ✓ Modo silencioso ignorado - Audio forzado');
        } catch (e) {
          debugPrint('[AudioService] ⚠️ Error configurando AudioContext con flags: $e');
          debugPrint('[AudioService] 💡 Intentando configuración alternativa sin flags...');
          // Fallback: intentar sin audioAttributesFlags
          try {
            await _bgmPlayer.setAudioContext(
              AudioContext(
                android: AudioContextAndroid(
                  isSpeakerphoneOn: true,
                  stayAwake: true,
                  contentType: AndroidContentType.music,
                  usageType: AndroidUsageType.media,
                  audioFocus: AndroidAudioFocus.gain,
                ),
              ),
            );
            debugPrint('[AudioService] ✓ Fallback: AudioContext sin flags configurado');
          } catch (e2) {
            debugPrint('[AudioService] ⚠️ Fallback AudioContext falló: $e2');
            // Fallback final: solo volumen
            try {
              await _bgmPlayer.setPlaybackRate(1.0);
              debugPrint('[AudioService] ✓ Fallback final: configuración mínima completada');
            } catch (e3) {
              debugPrint('[AudioService] ❌ Todos los fallbacks fallaron: $e3');
            }
          }
        }
      }
      
      debugPrint('[AudioService] ✓ BGM player configurado');

      // Configurar SFX players
      debugPrint('[AudioService] 🔊 Configurando ${_sfxPlayers.length} SFX players...');
      for (int i = 0; i < _sfxPlayers.length; i++) {
        final player = _sfxPlayers[i];
        await _initAudioPlayer(
          player,
          ReleaseMode.release,
          _sfxVolume,
        );
        
        // Configurar AudioContext para cada SFX player también
        if (!_isWeb) {
          try {
            await player.setAudioContext(
              AudioContext(
                android: AudioContextAndroid(
                  isSpeakerphoneOn: true,
                  stayAwake: false,
                  contentType: AndroidContentType.sonification,
                  usageType: AndroidUsageType.notification,
                  audioFocus: AndroidAudioFocus.none,
                ),
                iOS: AudioContextIOS(
                  category: AVAudioSessionCategory.playback,
                ),
              ),
            );
            debugPrint('[AudioService] ✓ AudioContext configurado para SFX player $i (silencio ignorado)');
          } catch (e) {
            debugPrint('[AudioService] ⚠️ Error configurando AudioContext SFX $i: $e');
            // Fallback sin flags
            try {
              await player.setAudioContext(
                AudioContext(
                  android: AudioContextAndroid(
                    isSpeakerphoneOn: true,
                    stayAwake: false,
                    contentType: AndroidContentType.sonification,
                    usageType: AndroidUsageType.notification,
                    audioFocus: AndroidAudioFocus.none,
                  ),
                ),
              );
              debugPrint('[AudioService] ✓ Fallback: AudioContext SFX $i sin flags');
            } catch (e2) {
              debugPrint('[AudioService] ⚠️ Fallback SFX $i falló: $e2');
            }
          }
        }
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
        debugPrint('[AudioService] 🔄 Reintentando... ($_initRetries/$_maxInitRetries)');
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
    var normalized = path;
    if (normalized.startsWith('lib/assets/')) {
      normalized = normalized.substring('lib/assets/'.length);
    }
    if (normalized.startsWith('assets/')) {
      normalized = normalized.substring('assets/'.length);
    }
    return normalized;
  }

  Future<String> _resolveAssetBundleKey(String path) async {
    final normalizedPath = _normalizeAssetPath(path);

    final cached = _resolvedAssetPathCache[normalizedPath];
    if (cached != null) {
      return cached;
    }

    final key = 'lib/assets/$normalizedPath';
    try {
      await rootBundle.load(key);
    } catch (_) {
      // Devolvemos igualmente la clave esperada para mantener una sola convención.
    }

    _resolvedAssetPathCache[normalizedPath] = key;
    return key;
  }

  /// Crea un Source con estrategia correcta para Web vs Nativo
  Future<Source> _getAudioSource(String path) async {
    final assetKey = await _resolveAssetBundleKey(path);

    if (_isWeb) {
      // En Web, usar UrlSource con la URL absoluta del asset
      // Los assets en Flutter Web están en /assets/
      final assetUrl = 'assets/$assetKey';
      debugPrint('[AudioService] Web UrlSource: $assetUrl');
      return UrlSource(assetUrl);
    }

    // En Android/iOS, reproducir bytes evita inconsistencias con claves de AssetSource.
    try {
      final cached = _audioBytesCache[assetKey];
      if (cached != null) {
        return BytesSource(cached);
      }

      final byteData = await rootBundle.load(assetKey);
      final bytes = byteData.buffer.asUint8List();
      _audioBytesCache[assetKey] = bytes;
      return BytesSource(bytes);
    } catch (e) {
      debugPrint('[AudioService] ❌ Failed loading audio bytes for $assetKey: $e');
      rethrow;
    }
  }

  Future<void> _playBgm(String path, _BgmTrack track) async {
    if (_isDisposed) {
      debugPrint('[AudioService] ⚠️ Service disposed, skipping playback');
      return;
    }
    
    try {
      final normalizedPath = _normalizeAssetPath(path);
      debugPrint('[AUDIO DEBUG] Playing: $normalizedPath');
      
      // Bloquear inicialización correctamente
      if (!_initialized) {
        await _ensureInitialized();
        if (!_initialized) {
          debugPrint('[🎵 AUDIO] ❌ Initialization failed');
          return;
        }
      }

      debugPrint('[🎵 AUDIO] _initialized=$_initialized, _isWeb=$_isWeb');

      // Si es la misma pista con el mismo path en reproducción, no hacer nada
      if (_currentBgmPath == path && _currentTrack == track && _bgmPlayer.state == PlayerState.playing) {
        debugPrint('[🎵 AUDIO] Same track already playing (path: $path)');
        return;
      }

      _currentTrack = track;
      _currentBgmPath = path;

      // Detener música actual si está en reproducción
      try {
        if (_bgmPlayer.state != PlayerState.stopped) {
          debugPrint('[🎵 AUDIO] Stopping current track...');
          await _bgmPlayer.stop();
          await _bgmPlayer.release();
          // Delay más largo en Web para permitir que se libere completamente
          final stopDelay = _isWeb 
              ? const Duration(milliseconds: 300)
              : const Duration(milliseconds: 100);
          await Future.delayed(stopDelay);
        }
      } catch (e) {
        debugPrint('[🎵 AUDIO] Error stopping: $e');
      }

      // Reproducir nueva canción
      debugPrint('[🎵 AUDIO] Playing: $normalizedPath');
      
      try {
        final audioSource = await _getAudioSource(path);
        debugPrint('[🎵 AUDIO] Source type: ${audioSource.runtimeType} (Web: $_isWeb)');
        
        // Intentar reproducir con manejo de errores específico
        try {
          await _bgmPlayer.play(audioSource);
          _isMusicPlaying = true;
          debugPrint('[🎵 AUDIO] ✅ Playing exitosamente: $normalizedPath');
        } catch (playError) {
          debugPrint('[🎵 AUDIO] ❌ Error inicial en play: $playError');
          
          // Fallback: intentar setAudioContext nuevamente y reintentar
          if (!_isWeb) {
            debugPrint('[🎵 AUDIO] 🔧 Intentando configurar AudioContext nuevamente...');
            try {
              await _bgmPlayer.setAudioContext(
                AudioContext(
                  android: AudioContextAndroid(
                    isSpeakerphoneOn: true,
                    stayAwake: true,
                    contentType: AndroidContentType.music,
                    usageType: AndroidUsageType.media,
                  ),
                ),
              );
              await Future.delayed(const Duration(milliseconds: 200));
              await _bgmPlayer.play(audioSource);
              _isMusicPlaying = true;
              debugPrint('[🎵 AUDIO] ✅ Fallback: Playing exitosamente: $normalizedPath');
            } catch (fallbackError) {
              debugPrint('[🎵 AUDIO] ❌ Fallback con flags falló: $fallbackError');
              // Intentar sin flags como último recursojsonObject
              try {
                await _bgmPlayer.setAudioContext(
                  AudioContext(
                    android: AudioContextAndroid(
                      isSpeakerphoneOn: true,
                      stayAwake: true,
                      contentType: AndroidContentType.music,
                      usageType: AndroidUsageType.media,
                    ),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 200));
                await _bgmPlayer.play(audioSource);
                _isMusicPlaying = true;
                debugPrint('[🎵 AUDIO] ✅ Fallback final: Playing exitosamente: $normalizedPath');
              } catch (finalError) {
                debugPrint('[🎵 AUDIO] ❌ Fallback final también falló: $finalError');
                _isMusicPlaying = false;
                rethrow;
              }
            }
          } else {
            _isMusicPlaying = false;
            rethrow;
          }
        }
      } catch (e) {
        debugPrint('[🎵 AUDIO] ❌ Play error final: $e');
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
    _lastRegionMusicPath = gameplaySongPath;  // Guardar para playLastGameplayMusic()
    return _playBgm(gameplaySongPath, _BgmTrack.gameplay);
  }

  // Métodos para reproducir música de gameplay según la región
  Future<void> playAmericaMusic() {
    _lastRegionMusicPath = 'audio/gameplay/caribe/caribe_wave.mp3';
    return _playBgm('audio/gameplay/caribe/caribe_wave.mp3', _BgmTrack.gameplay);
  }

  Future<void> playCarribeMusic() {
    _lastRegionMusicPath = 'audio/gameplay/caribe/caribe_wave.mp3';
    return _playBgm('audio/gameplay/caribe/caribe_wave.mp3', _BgmTrack.gameplay);
  }

  Future<void> playAsiaMusic() {
    _lastRegionMusicPath = 'audio/gameplay/asia/asia_wave.mp3';
    return _playBgm('audio/gameplay/asia/asia_wave.mp3', _BgmTrack.gameplay);
  }

  Future<void> playEuropaMusic() {
    _lastRegionMusicPath = 'audio/gameplay/europa/europa_wave.mp3';
    return _playBgm('audio/gameplay/europa/europa_wave.mp3', _BgmTrack.gameplay);
  }

  // Métodos para reproducir música de boss según la región
  Future<void> playAmericaBossMusic() {
    _lastRegionMusicPath = 'audio/gameplay/caribe/boss_caribe.mp3';
    return _playBgm('audio/gameplay/caribe/boss_caribe.mp3', _BgmTrack.gameplay);
  }

  Future<void> playCarribeBossMusic() {
    _lastRegionMusicPath = 'audio/gameplay/caribe/boss_caribe.mp3';
    return _playBgm('audio/gameplay/caribe/boss_caribe.mp3', _BgmTrack.gameplay);
  }

  Future<void> playAsiaBossMusic() {
    _lastRegionMusicPath = 'audio/gameplay/asia/boss_asia.mp3';
    return _playBgm('audio/gameplay/asia/boss_asia.mp3', _BgmTrack.gameplay);
  }

  Future<void> playEuropaBossMusic() {
    _lastRegionMusicPath = 'audio/gameplay/europa/boss_europa.mp3';
    return _playBgm('audio/gameplay/europa/boss_europa.mp3', _BgmTrack.gameplay);
  }

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
    if (_isDisposed || !_initialized || !_sfxEnabled) return;

    try {
      final player = _sfxPlayers[index];
      final normalizedPath = _normalizeAssetPath(path);
      debugPrint('[AUDIO DEBUG] Playing SFX: $normalizedPath');

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
      final audioSource = await _getAudioSource(path);
      await player.play(audioSource).timeout(
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

  /// Test directo para verificar si el audio funciona en el sistema
  Future<void> testAudio() async {
    debugPrint('[AUDIO TEST] Iniciando test de audio...');
    try {
      final player = AudioPlayer();
      debugPrint('[AUDIO TEST] Reproduciedo: audio/menu/menu_song.mp3');
      
      // Web usa UrlSource, nativo usa AssetSource
        final source = await _getAudioSource('audio/menu/menu_song.mp3');
      
      await player.play(source);
      debugPrint('[AUDIO TEST] ✅ Audio test reproducido exitosamente');
      await Future.delayed(const Duration(seconds: 3));
      await player.stop();
      await player.dispose();
    } catch (e) {
      debugPrint('[AUDIO TEST] ❌ Error en test de audio: $e');
    }
  }

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
      // Solo pausar si realmente está en reproducción
      if (_bgmPlayer.state == PlayerState.playing) {
        debugPrint('[AudioService] ⏸️ Pausando BGM (pauseApp)');
        await _bgmPlayer.pause();
        _isMusicPlaying = false;
        notifyListeners();
      }
    } on Exception catch (e) {
      debugPrint('[AudioService] ⚠️ Error pausando app: $e');
    }
  }

  /// Reanuda la música cuando la app vuelve
  /// Más robusto: intenta reanudar o reiniciar si es necesario
  Future<void> resumeApp() async {
    if (_isDisposed || _isWeb || !_initialized) return;
    
    try {
      // Solo reanudar si hay una canción que reproducir
      if (_currentTrack != _BgmTrack.none) {
        final playerState = _bgmPlayer.state;
        
        if (playerState == PlayerState.paused) {
          // Si está pausada, solo reanudar
          debugPrint('[AudioService] ▶️ Reanudando BGM (resumeApp)');
          await _bgmPlayer.resume();
          _isMusicPlaying = true;
          notifyListeners();
        } else if (playerState == PlayerState.stopped || playerState == PlayerState.completed) {
          // Si se detuvo completamente, reiniciar desde el principio
          debugPrint('[AudioService] 🔄 BGM se detuvo, reiniciando (resumeApp)');
          if (_currentBgmPath != null) {
            await _playBgm(_currentBgmPath!, _currentTrack);
          } else {
            // Fallback: reproducir última música de region si existe
            await playLastGameplayMusic();
          }
        }
        // Si ya está reproduciendo, no hacer nada
      }
    } on Exception catch (e) {
      debugPrint('[AudioService] ⚠️ Error reanudando app: $e');
    }
  }

  /// Getter para volumen maestro (promedio de música y SFX)
  double get masterVolume => (_bgmVolume + _sfxVolume) / 2;

  /// Establece el volumen maestro (afecta música y SFX por igual)
  Future<void> setMasterVolume(double volume) async {
    if (_isDisposed) return;
    if (volume < 0 || volume > 1) return;

    await setMusicVolume(volume);
    await setSfxVolume(volume);
  }

  /// Método de diagnóstico: Reinicia el contexto de audio para Android
  Future<void> resetAudioContext() async {
    if (_isDisposed || _isWeb || !_initialized) {
      debugPrint('[AudioService] ⚠️ No se puede resetear contexto (disposed=$_isDisposed, web=$_isWeb, init=$_initialized)');
      return;
    }

    try {
      debugPrint('[AudioService] 🔄 Reseteando AudioContext para BGM player...');
      await _bgmPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
      debugPrint('[AudioService] ✓ AudioContext reseteado exitosamente');
      
      // Reintentar reproducir si estaba en reproducción
      if (_isMusicPlaying && _currentBgmPath != null) {
        debugPrint('[AudioService] 🎵 Reintentando reproducir: $_currentBgmPath');
        await Future.delayed(const Duration(milliseconds: 100));
        final audioSource = await _getAudioSource(_currentBgmPath!);
        await _bgmPlayer.play(audioSource);
        debugPrint('[AudioService] ✅ Reanudado después del reset');
      }
    } catch (e) {
      debugPrint('[AudioService] ❌ Error reseteando AudioContext: $e');
    }
  }

  /// Diagnóstico completo de audio
  Future<void> diagnosticsAudio() async {
    debugPrint('[AUDIO LOG] ========== DIAGNÓSTICO DE AUDIO ==========');
    debugPrint('[AUDIO LOG] - Disposed: $_isDisposed');
    debugPrint('[AUDIO LOG] - Web: $_isWeb');
    debugPrint('[AUDIO LOG] - Initialized: $_initialized');
    debugPrint('[AUDIO LOG] - Music Enabled: $_musicEnabled');
    debugPrint('[AUDIO LOG] - SFX Enabled: $_sfxEnabled');
    debugPrint('[AUDIO LOG] - BGM Volume: $_bgmVolume');
    debugPrint('[AUDIO LOG] - SFX Volume: $_sfxVolume');
    debugPrint('[AUDIO LOG] - Current Track: $_currentTrack');
    debugPrint('[AUDIO LOG] - Current BGM Path: $_currentBgmPath');
    debugPrint('[AUDIO LOG] - Music Playing: $_isMusicPlaying');
    debugPrint('[AUDIO LOG] - BGM Player State: ${_bgmPlayer.state}');
    debugPrint('[AUDIO LOG] - SFX Players Count: ${_sfxPlayers.length}');
    for (int i = 0; i < _sfxPlayers.length; i++) {
      debugPrint('[AUDIO LOG] - SFX Player $i State: ${_sfxPlayers[i].state}');
    }
    debugPrint('[AUDIO LOG] ============================================');
  }

  /// Fuerza la reinicialización completa del AudioService
  /// Útil cuando el audio deja de funcionar después de algunos minutos
  /// O cuando el usuario cambia configuración de sonido del sistema
  Future<void> forceReinitialize() async {
    debugPrint('[AudioService] 🔧 FORCE REINITIALIZE - Reiniciando sistema de audio...');
    
    try {
      // Detener todo
      _initialized = false;
      _isMusicPlaying = false;
      
      // Limpiar players
      try {
        await _bgmPlayer.stop();
        await _bgmPlayer.release();
      } catch (e) {
        debugPrint('[AudioService] ⚠️ Error deteniendo BGM: $e');
      }
      
      for (var player in _sfxPlayers) {
        try {
          await player.stop();
        } catch (e) {
          debugPrint('[AudioService] ⚠️ Error deteniendo SFX: $e');
        }
      }
      
      // Esperar un poco
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reinicializar
      await _ensureInitialized();
      
      debugPrint('[AudioService] ✅ FORCE REINITIALIZE completado exitosamente');
    } catch (e) {
      debugPrint('[AudioService] ❌ Error en FORCE REINITIALIZE: $e');
    }
  }

  /// Diagnóstico específico para Android
  /// Verifica si el audio está realmente siendo enviado al dispositivo
  Future<Map<String, dynamic>> getAndroidAudioStatus() async {
    final status = <String, dynamic>{
      'initialized': _initialized,
      'isWeb': _isWeb,
      'musicEnabled': _musicEnabled,
      'sfxEnabled': _sfxEnabled,
      'bgmVolume': _bgmVolume,
      'sfxVolume': _sfxVolume,
      'isMusicPlaying': _isMusicPlaying,
      'bgmPlayerState': _bgmPlayer.state.toString(),
      'currentTrack': _currentTrack.toString(),
      'currentBgmPath': _currentBgmPath,
    };
    
    debugPrint('[AudioService] 📊 Status Android: $status');
    return status;
  }
}

