import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/game_loader_service.dart';
import 'login_screen.dart';
import 'main_layout.dart' as main_layout;

/// Pantalla de carga
/// Imagen de fondo full-screen con indicador de progreso abajo
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingText = 'Cargando...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  /// Función principal de inicialización
  /// Ejecuta carga de recursos + auto-login en paralelo
  Future<void> _initializeGame() async {
    try {
      // Ejecutar carga de recursos y auto-login en paralelo
      final results = await Future.wait([
        _loadGameResources(),
        _attemptAutoLogin(),
      ]);

      // Verificar resultado del auto-login
      // results[0] = carga de recursos (void)
      // results[1] = resultado de login (bool)
      final bool logged = results[1] as bool;

      // Navegar a la siguiente pantalla
      if (mounted) {
        _navigateToNextScreen(logged);
      }
    } catch (e) {
      print('Error during game initialization: $e');
      if (mounted) {
        _navigateToNextScreen(false); // Ir a login en caso de error
      }
    }
  }

  /// Cargar recursos del juego
  Future<void> _loadGameResources() async {
    try {
      final loader = GameLoaderService();
      await loader.loadAssets();

      if (mounted) {
        setState(() => _progress = 0.6);
      }
    } catch (e) {
      print('Error loading resources: $e');
    }
  }

  /// Intentar auto-login silencioso
  Future<bool> _attemptAutoLogin() async {
    try {
      final auth = AuthService();
      final logged = await auth.signInSilently();

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _loadingText = logged ? 'Iniciando sesión...' : 'Cargando...';
        });
      }

      // Pequeña pausa para que se vea la animación
      await Future.delayed(const Duration(milliseconds: 500));

      return logged;
    } catch (e) {
      print('Error during auto-login: $e');
      return false;
    }
  }

  /// Navegar a la siguiente pantalla
  /// Si logged=true → GameScreen
  /// Si logged=false → LoginScreen
  void _navigateToNextScreen(bool logged) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => logged ? const main_layout.MainLayout() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo full-screen y responsive
            _buildBackgroundImage(screenHeight, screenWidth),
            
            // Overlay oscuro semi-transparente
            Container(
              color: Colors.black.withAlpha(76), // 30% opacidad
            ),

            // Contenido: Loader abajo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomLoader(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget fondo full-screen responsive
  Widget _buildBackgroundImage(double screenHeight, double screenWidth) {
    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
      ),
      child: Image.asset(
        'assets/paleto_art.png',
        fit: BoxFit.cover, // Cubre todo sin dejar espacios
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 80,
                color: Color(0xFFFFD700),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget loader en la parte inferior (responsive)
  Widget _buildBottomLoader(BuildContext context) {
    const accent = Color(0xFFFFD700);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 400;
    final padSize = isSmallScreen ? 16.0 : 20.0;
    final fontSize = isSmallScreen ? 10.0 : 12.0;

    return SingleChildScrollView(
      reverse: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(padSize, padSize, padSize, padSize + mediaQuery.viewInsets.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(0),
              Colors.black.withAlpha(230),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Texto "Cargando"
            Text(
              _loadingText,
              style: GoogleFonts.pressStart2p(
                fontSize: fontSize,
                color: accent,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: isSmallScreen ? 14 : 20),

            // Barra de progreso horizontal
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: _progress,
                valueColor: const AlwaysStoppedAnimation<Color>(accent),
                backgroundColor: accent.withAlpha(50),
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 12),

            // Porcentaje
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.pressStart2p(
                fontSize: isSmallScreen ? 9.0 : 10.0,
                color: accent.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
