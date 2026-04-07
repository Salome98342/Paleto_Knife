/// ═══════════════════════════════════════════════════════════════════════════
/// AudioGameState - Máquina de estados para control de audio
/// Sincroniza el audio con los estados del juego (menú, gameplay, boss, tienda)
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';

/// Enum de estados del juego (para audio)
enum AudioGameState {
  menu,      // Pantalla de menú
  gameplay,  // Jugando normal
  boss,      // Peleando contra boss
  tienda,    // Shop/tienda
}

/// Extensión para obtener la música del estado
extension AudioGameStateAudio on AudioGameState {
  /// Obtiene ruta de música para este estado
  String getMusicPath({String? region}) {
    switch (this) {
      case AudioGameState.menu:
        return 'menu/menu_song.mp3';
      case AudioGameState.gameplay:
        region ??= 'america';
        return 'gameplay/$region/${region}_wave.mp3';
      case AudioGameState.boss:
        region ??= 'america';
        return 'gameplay/$region/boss_$region.mp3';
      case AudioGameState.tienda:
        return 'tienda/shop.mp3';
    }
  }

  /// Efecto de alerta para este estado (si aplica)
  String? getAlertSfx() {
    if (this == AudioGameState.boss) {
      return 'sfx/alerta_boss.mp3';
    }
    return null;
  }

  /// ¿Este estado es de gameplay?
  bool get isGameplay => this == AudioGameState.gameplay;

  /// ¿Este estado es de boss?
  bool get isBoss => this == AudioGameState.boss;

  /// ¿Este estado es interactivo (juego activo)?
  bool get isInteractive => isGameplay || isBoss;
}

/// Controlador de máquina de estados para audio
class AudioGameStateManager {
  static final AudioGameStateManager _instance = AudioGameStateManager._internal();

  factory AudioGameStateManager() {
    return _instance;
  }

  AudioGameStateManager._internal();

  /// Estado actual del juego
  AudioGameState _currentState = AudioGameState.menu;

  /// Región actual (para gameplay y boss)
  String _currentRegion = 'america';

  /// Listeners de cambios de estado
  final List<Function(AudioGameState oldState, AudioGameState newState)> _listeners = [];

  /// Stream controller para reactividad
  final _stateController = StreamController<AudioGameState>.broadcast();

  /// Stream de cambios de estado
  Stream<AudioGameState> get stateStream => _stateController.stream;

  /// Estado actual
  AudioGameState get currentState => _currentState;

  /// Región actual
  String get currentRegion => _currentRegion;

  /// Cambia el estado del juego
  /// [newState]: Nuevo estado
  /// [region]: Región (solo si aplica a gameplay o boss)
  void setState(AudioGameState newState, {String? region}) {
    // Si es el mismo estado Y misma región, no hacer nada
    if (newState == _currentState && region == _currentRegion) {
      return;
    }

    final oldState = _currentState;

    // Actualizar región si aplica
    if (newState.isGameplay || newState.isBoss) {
      if (region != null) {
        _currentRegion = region;
      }
    }

    _currentState = newState;

    // Notificar a listeners
    for (var listener in _listeners) {
      listener(oldState, newState);
    }

    // Emitir por stream
    _stateController.add(newState);
  }

  /// Agrega un listener de cambios de estado
  void addStateListener(
    Function(AudioGameState oldState, AudioGameState newState) listener,
  ) {
    _listeners.add(listener);
  }

  /// Remueve un listener
  void removeStateListener(
    Function(AudioGameState oldState, AudioGameState newState) listener,
  ) {
    _listeners.remove(listener);
  }

  /// Limpia todos los listeners (importante en dispose)
  void clearListeners() {
    _listeners.clear();
  }

  /// Limpia recursos
  void dispose() {
    clearListeners();
    _stateController.close();
  }
}
