import 'package:shared_preferences/shared_preferences.dart';

/// Modelo para almacenar y recuperar configuración de audio
/// Usa SharedPreferences para persistencia local
class AudioSettings {
  static const String _musicVolumeKey = 'audio_music_volume';
  static const String _sfxVolumeKey = 'audio_sfx_volume';
  static const String _musicEnabledKey = 'audio_music_enabled';
  static const String _sfxEnabledKey = 'audio_sfx_enabled';

  // Valores por defecto
  static const double defaultMusicVolume = 0.7;
  static const double defaultSfxVolume = 0.8;
  static const bool defaultMusicEnabled = true;
  static const bool defaultSfxEnabled = true;

  late SharedPreferences _prefs;

  /// Inicializa AudioSettings y carga las preferencias guardadas
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== MÚSICA ====================

  /// Obtiene el volumen de música guardado
  double getMusicVolume() {
    return _prefs.getDouble(_musicVolumeKey) ?? defaultMusicVolume;
  }

  /// Guarda el volumen de música
  Future<void> setMusicVolume(double volume) async {
    await _prefs.setDouble(_musicVolumeKey, volume.clamp(0.0, 1.0));
  }

  /// Obtiene si la música está habilitada
  bool isMusicEnabled() {
    return _prefs.getBool(_musicEnabledKey) ?? defaultMusicEnabled;
  }

  /// Guarda si la música está habilitada
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(_musicEnabledKey, enabled);
  }

  // ==================== EFECTOS ====================

  /// Obtiene el volumen de efectos guardado
  double getSfxVolume() {
    return _prefs.getDouble(_sfxVolumeKey) ?? defaultSfxVolume;
  }

  /// Guarda el volumen de efectos
  Future<void> setSfxVolume(double volume) async {
    await _prefs.setDouble(_sfxVolumeKey, volume.clamp(0.0, 1.0));
  }

  /// Obtiene si los efectos están habilitados
  bool isSfxEnabled() {
    return _prefs.getBool(_sfxEnabledKey) ?? defaultSfxEnabled;
  }

  /// Guarda si los efectos están habilitados
  Future<void> setSfxEnabled(bool enabled) async {
    await _prefs.setBool(_sfxEnabledKey, enabled);
  }

  // ==================== UTILIDADES ====================

  /// Obtiene todos los ajustes como un mapa
  Map<String, dynamic> getAllSettings() {
    return {
      'musicVolume': getMusicVolume(),
      'sfxVolume': getSfxVolume(),
      'musicEnabled': isMusicEnabled(),
      'sfxEnabled': isSfxEnabled(),
    };
  }

  /// Restaura todos los ajustes a los valores por defecto
  Future<void> resetToDefaults() async {
    await Future.wait([
      setMusicVolume(defaultMusicVolume),
      setSfxVolume(defaultSfxVolume),
      setMusicEnabled(defaultMusicEnabled),
      setSfxEnabled(defaultSfxEnabled),
    ]);
  }
}
