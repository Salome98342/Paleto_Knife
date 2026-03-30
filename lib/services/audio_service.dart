import 'package:audioplayers/audioplayers.dart';

enum _BgmTrack {
  none,
  menu,
  gameplay,
}

/// Servicio global de audio para música y efectos.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const String menuSongPath = 'assets/audio/menu/menu_song.mp3';
  static const String gameplaySongPath = 'assets/audio/gameplay/cuchillo.mp3';
  static const String coinCollectPath = 'assets/audio/sfx/coin_collect.mp3';

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
  final AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'sfx_player');

  bool _initialized = false;
  _BgmTrack _currentTrack = _BgmTrack.none;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.55);

    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.setVolume(0.9);

    _initialized = true;
  }

  String _normalizeAssetPath(String path) {
    if (path.startsWith('assets/')) {
      return path.substring('assets/'.length);
    }
    return path;
  }

  Future<void> _playBgm(String path, _BgmTrack track) async {
    await _ensureInitialized();

    if (_currentTrack == track && _bgmPlayer.state == PlayerState.playing) {
      return;
    }

    _currentTrack = track;
    await _bgmPlayer.stop();
    await _bgmPlayer.play(AssetSource(_normalizeAssetPath(path)));
  }

  Future<void> playMenuMusic() => _playBgm(menuSongPath, _BgmTrack.menu);

  Future<void> playGameplayMusic() => _playBgm(gameplaySongPath, _BgmTrack.gameplay);

  Future<void> stopMusic() async {
    await _ensureInitialized();
    _currentTrack = _BgmTrack.none;
    await _bgmPlayer.stop();
  }

  Future<void> playSfx(String path) async {
    await _ensureInitialized();
    await _sfxPlayer.play(AssetSource(_normalizeAssetPath(path)));
  }

  Future<void> playCoinCollect() => playSfx(coinCollectPath);
}
