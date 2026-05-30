import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress_data.dart';
import 'firebase_auth_service.dart';

/// Servicio para manejar la persistencia de datos del juego
/// Utiliza SharedPreferences para guardar el progreso localmente
class StorageService {
  static const String _gameStateKeyPrefix = 'knife_clicker_game_state';

  String _gameStateKey() {
    final userId = FirebaseAuthService.instance.firebaseUser?.uid;
    return userId == null || userId.isEmpty
      ? '${_gameStateKeyPrefix}_guest'
      : '${_gameStateKeyPrefix}_$userId';
  }

  /// Guarda el estado del juego en el almacenamiento local
  Future<bool> saveGameState(PlayerProgressData gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(gameState.toJson());
      return await prefs.setString(_gameStateKey(), jsonString);
    } catch (e) {
      debugPrint('Error guardando el estado del juego: $e');
      return false;
    }
  }

  /// Carga el estado del juego desde el almacenamiento local
  Future<PlayerProgressData?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_gameStateKey());

      if (jsonString == null) {
        return null; // No hay datos guardados
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerProgressData.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error cargando el estado del juego: $e');
      return null;
    }
  }

  /// Borra todos los datos guardados (reset del juego)
  Future<bool> clearGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_gameStateKey());
    } catch (e) {
      debugPrint('Error borrando el estado del juego: $e');
      return false;
    }
  }

  /// Verifica si existe un juego guardado
  Future<bool> hasGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_gameStateKey());
    } catch (e) {
      debugPrint('Error verificando el estado del juego: $e');
      return false;
    }
  }
}
