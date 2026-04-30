import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'dart:async';

/// Widget que observa el ciclo de vida de la aplicación y maneja el audio
/// Pausa la música cuando la app entra en background
/// Reanuda la música cuando la app vuelve al foreground
class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastState;
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[AppLifecycleObserver] 🔄 Observador de ciclo de vida registrado');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    debugPrint('[AppLifecycleObserver] 🔄 Observador de ciclo de vida removido');
    super.dispose();
  }

  /// Maneja cambios de estado con debounce para evitar pausas rápidas
  void _handleStateChange(AppLifecycleState state) {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Evitar procesar el mismo estado dos veces
    if (_lastState == state) {
      debugPrint('[AppLifecycleObserver] ⏭️ Estado duplicado ignorado: $state');
      return;
    }

    // Debounce: esperar un poco antes de procesar para evitar cambios rápidos
    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;

      debugPrint('[AppLifecycleObserver] 📱 Procesando estado: $state (anterior: $_lastState)');
      _lastState = state;

      switch (state) {
        case AppLifecycleState.resumed:
          // App en FOREGROUND - Reanuda audio
          debugPrint('[AppLifecycleObserver] ▶️ App en FOREGROUND - Reanudando audio');
          AudioService.instance.resumeApp();
          break;

        case AppLifecycleState.paused:
          // App en BACKGROUND - Pausa audio
          debugPrint('[AppLifecycleObserver] ⏸️ App en BACKGROUND - Pausando audio');
          AudioService.instance.pauseApp();
          break;

        case AppLifecycleState.inactive:
          // Estado transitorio entre resumed y paused
          // No hacer nada, evita interrupciones por cambios rápidos
          debugPrint('[AppLifecycleObserver] ⚠️ App INACTIVA (transitoria) - Sin acción');
          break;

        case AppLifecycleState.hidden:
          // App oculta pero no necesariamente en background
          // No pausar, el usuario podría volver rápidamente
          debugPrint('[AppLifecycleObserver] 👻 App OCULTA - Sin acción');
          break;

        case AppLifecycleState.detached:
          // App completamente detenida
          debugPrint('[AppLifecycleObserver] ❌ App DETENIDA');
          break;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleStateChange(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

