import 'package:flutter/material.dart';
import '../services/audio_service.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[AppLifecycleObserver] 🔄 Observador de ciclo de vida registrado');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[AppLifecycleObserver] 🔄 Observador de ciclo de vida removido');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[AppLifecycleObserver] 📱 Estado de app cambió: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[AppLifecycleObserver] ▶️ App en FOREGROUND - Reanudando audio');
        AudioService.instance.resumeApp();
        break;
      
      case AppLifecycleState.paused:
        debugPrint('[AppLifecycleObserver] ⏸️ App en BACKGROUND - Pausando audio');
        AudioService.instance.pauseApp();
        break;
      
      case AppLifecycleState.detached:
        debugPrint('[AppLifecycleObserver] ❌ App DETENIDA');
        break;
      
      case AppLifecycleState.hidden:
        // En Flutter 3.13+, hidden state para multi-window apps
        debugPrint('[AppLifecycleObserver] 👻 App OCULTA');
        break;
      
      case AppLifecycleState.inactive:
        debugPrint('[AppLifecycleObserver] ⚠️ App INACTIVA');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
