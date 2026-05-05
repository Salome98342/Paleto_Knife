import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador de ajustes de la aplicación
/// Maneja temas, tamaños de fuente y otras preferencias del usuario
class SettingsController extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode'; // 'dark' o 'light'
  static const String _fontSizeMultiplierKey = 'font_size_multiplier';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Valores por defecto
  static const String _defaultTheme = 'dark';
  static const double _defaultFontSizeMultiplier = 1.0;

  // Estados actuales
  late String _themeMode;
  late double _fontSizeMultiplier;

  // Getters
  String get themeMode => _themeMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  bool get isDarkMode => _themeMode == 'dark';
  bool get isInitialized => _isInitialized;

  /// Inicializa el controlador cargando las preferencias guardadas
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _themeMode = _prefs.getString(_themeModeKey) ?? _defaultTheme;
      _fontSizeMultiplier =
          _prefs.getDouble(_fontSizeMultiplierKey) ?? _defaultFontSizeMultiplier;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error inicializando SettingsController: $e');
      _themeMode = _defaultTheme;
      _fontSizeMultiplier = _defaultFontSizeMultiplier;
      _isInitialized = true;
    }
  }

  /// Cambia el tema entre 'dark' y 'light'
  Future<void> setThemeMode(String mode) async {
    if (_themeMode == mode) return;

    try {
      _themeMode = mode;
      await _prefs.setString(_themeModeKey, mode);
      notifyListeners();
    } catch (e) {
      print('Error guardando tema: $e');
    }
  }

  /// Alterna entre modo oscuro y claro
  Future<void> toggleThemeMode() async {
    final newMode = isDarkMode ? 'light' : 'dark';
    await setThemeMode(newMode);
  }

  /// Establece el multiplicador de tamaño de fuente
  /// Valores recomendados: 0.8 (pequeño), 1.0 (normal), 1.2 (grande), 1.4 (muy grande)
  Future<void> setFontSizeMultiplier(double multiplier) async {
    if (_fontSizeMultiplier == multiplier) return;

    try {
      _fontSizeMultiplier = multiplier.clamp(0.8, 1.4);
      await _prefs.setDouble(_fontSizeMultiplierKey, _fontSizeMultiplier);
      notifyListeners();
    } catch (e) {
      print('Error guardando tamaño de fuente: $e');
    }
  }

  /// Aumenta el tamaño de la fuente
  Future<void> increaseFontSize() async {
    final newSize = (_fontSizeMultiplier + 0.1).clamp(0.8, 1.4);
    await setFontSizeMultiplier(newSize);
  }

  /// Disminuye el tamaño de la fuente
  Future<void> decreaseFontSize() async {
    final newSize = (_fontSizeMultiplier - 0.1).clamp(0.8, 1.4);
    await setFontSizeMultiplier(newSize);
  }

  /// Reinicia los ajustes a los valores por defecto
  Future<void> resetToDefaults() async {
    try {
      _themeMode = _defaultTheme;
      _fontSizeMultiplier = _defaultFontSizeMultiplier;
      await _prefs.setString(_themeModeKey, _defaultTheme);
      await _prefs.setDouble(_fontSizeMultiplierKey, _defaultFontSizeMultiplier);
      notifyListeners();
    } catch (e) {
      print('Error reiniciando ajustes: $e');
    }
  }
}
