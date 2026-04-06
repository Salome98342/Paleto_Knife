import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _BgmTrack {
  none,
  menu,
  gameplay,
  shop,
  settings,
}

/// Servicio global de audio para musica y efectos.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const String menuSongPath = 'assets/audio/menu/menu_song.mp3';
  static const String gameplaySongPath = 'assets/audio/gameplay/cuchillo.mp3';
  static const String shopSongPath = 'assets/audio/gameplay/shop.mp3';
  static const String cuchilloMenuPath = 'assets/audio/gameplay/cuchillo_menu.mp3'; // Cancion de config
  static const String coinCollectPath = 'assets/audio/sfx/coin_collect.mp3';
  static const String hitSoundPath = 'assets/audio/sfx/hit.mp3';
  static const String powerupSoundPath = 'assets/audio/sfx/powerup.mp3';

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
  final List<AudioPlayer> _sfxPlayers = List.generate(4, (i) => AudioPlayer(playerId: 'sfx_player_$i'));
  int _nextSfxIndex = 0;

  bool _initialized = false;
  _BgmTrack _currentTrack = _BgmTrack.none;
  
  double _bgmVolume = 0.55;
  double _sfxVolume = 0.9;
  
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  static Future<void> init() async {
    await instance._ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _bgmVolume = prefs.getDouble('bgm_volume') ?? 0.55;
    _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.9;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);

    for (var player in _sfxPlayers) {
      await player.setReleaseMode(ReleaseMode.release);
      await player.setVolume(_sfxVolume);
    }

    _initialized = true;
  }
  
  Future<void> setBgmVolume(double v) async {
    _bgmVolume = v;
    if (_initialized) {
        await _bgmPlayer.setVolume(_bgmVolume);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('bgm_volume', _bgmVolume);
    }
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v;
    if (_initialized) {
        for (var player in _sfxPlayers) {
          await player.setVolume(_sfxVolume);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('sfx_volume', _sfxVolume);
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
      
      // Detener y liberar recursos del track anterior
      try {
        if (_bgmPlayer.state == PlayerState.playing || _bgmPlayer.state == PlayerState.paused) {
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

  Future<void> playSettingsMusic() => _playBgm(cuchilloMenuPath, _BgmTrack.settings);

  Future<void> playGameplayMusic() => _playBgm(gameplaySongPath, _BgmTrack.gameplay);
  
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
}
