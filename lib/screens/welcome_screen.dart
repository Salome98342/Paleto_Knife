import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/welcome_message_service.dart';
import 'main_layout.dart';

/// Pantalla de bienvenida que muestra un mensaje personalizado
/// Se muestra después del login exitoso
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startWelcomeSequence();
  }

  /// Inicializar animaciones
  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  /// Ejecutar secuencia de bienvenida
  Future<void> _startWelcomeSequence() async {
    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();

    // Esperar 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    // Navegar a pantalla principal
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.getUser();

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Center(
          child: Text(
            'Error: Usuario no encontrado',
            style: GoogleFonts.pressStart2p(
              color: const Color(0xFFCC3333),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final welcomeMessage =
        WelcomeMessageService.getRandomWelcomeMessage(user.username);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Fondo con gradiente animado
          _buildAnimatedBackground(),
          // Contenido principal
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildWelcomeContent(welcomeMessage, user.username),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fondo animado
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D0D1A),
            const Color(0xFF1A1A2E).withAlpha(200),
            const Color(0xFF16213E).withAlpha(100),
          ],
        ),
      ),
    );
  }

  /// Contenido de bienvenida
  Widget _buildWelcomeContent(String message, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono decorativo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 3,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B00).withAlpha(50),
                  const Color(0xFFFFD700).withAlpha(50),
                ],
              ),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 40),
          // Mensaje de bienvenida
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: const Color(0xFFFFD700),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Texto secundario
          Text(
            'Iniciando aventura...',
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: const Color(0xFFFF6B00),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          // Indicador de carga
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// Indicador de carga decorativo
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            final offset = (_fadeController.value * 3 - index).abs();
            final opacity = (1 - offset.clamp(0.0, 1.0)).toDouble();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
