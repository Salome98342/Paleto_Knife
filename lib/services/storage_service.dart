import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

/// Servicio para manejar la persistencia de datos del juego
/// Utiliza SharedPreferences para guardar el progreso localmente
class StorageService {
  static const String _gameStateKey = 'knife_clicker_game_state';

  /// Guarda el estado del juego en el almacenamiento local
  Future<bool> saveGameState(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(gameState.toJson());
      return await prefs.setString(_gameStateKey, jsonString);
    } catch (e) {
      print('Error guardando el estado del juego: $e');
      return false;
    }
  }

  /// Carga el estado del juego desde el almacenamiento local
  Future<GameState?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_gameStateKey);

      if (jsonString == null) {
        return null; // No hay datos guardados
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(jsonMap);
    } catch (e) {
      print('Error cargando el estado del juego: $e');
      return null;
    }
  }

  /// Borra todos los datos guardados (reset del juego)
  Future<bool> clearGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_gameStateKey);
    } catch (e) {
      print('Error borrando el estado del juego: $e');
      return false;
    }
  }

  /// Verifica si existe un juego guardado
  Future<bool> hasGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_gameStateKey);
    } catch (e) {
      print('Error verificando el estado del juego: $e');
      return false;
    }
  }
}
