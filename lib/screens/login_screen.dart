import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/login_card.dart';

/// Pantalla de login mejorada
/// Se muestra solo si no hay sesión activa o falló el auto-login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bgController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Inicializar animaciones
  void _initializeAnimations() {
    // Animación de entrada slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    // Animación de fondo
    _bgController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_bgController);

    // Iniciar animación
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Fondo animado con gradiente
          _buildAnimatedBackground(),

          // Contenido principal
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _buildHeader(),
                  ),

                  // Login card con animación
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _slideController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LoginCard(
                          onLoginSuccess: () {
                            // El LoginCard ya navega
                          },
                        ),
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fondo animado con degradado
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0D1A),
                const Color(0xFF1A1A2E).withAlpha(
                  (200 + (_bgAnimation.value * 55)).toInt(),
                ),
                const Color(0xFF16213E).withAlpha(100),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget header decorativo
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _slideController,
      child: Column(
        children: [
          // Icono con animación de escala
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B00).withAlpha(100),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 60,
                color: Color(0xFFFF6B00),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Título principal
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFFFFD700),
                const Color(0xFFFF6B00),
              ],
            ).createShader(bounds),
            child: Text(
              '¡Bienvenido Chef!',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            'Prepárate para la batalla culinaria',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: const Color(0xFF8888AA),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget footer informativo
  Widget _buildFooter() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Column(
        children: [
          // Tarjeta informativa
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withAlpha(100),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu progreso está protegido en Google Play',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFF8888AA),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Versión
          Text(
            'v1.0.0',
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: const Color(0xFF444466),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
