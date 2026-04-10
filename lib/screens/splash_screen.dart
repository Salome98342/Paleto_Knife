import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'experience_screen.dart';

/// Pantalla de presentación JimmySoft
/// Muestra logo + texto con animación fade-in/out
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startSplashSequence();
  }

  /// Inicializar animación de fade
  void _initializeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  /// Ejecutar secuencia del splash
  /// Fade-in (1.5s) → Pausa (1s) → Fade-out (1s) → Navegar
  Future<void> _startSplashSequence() async {
    // Permitir skip después de 500ms
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _canSkip = true);
    }

    // Fade-in: 1.5s
    if (mounted) {
      await _fadeController.forward();
    }

    // Pausa: 1s
    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // Fade-out: 1s
    if (mounted) {
      await _fadeController.reverse();
    }

    // Navegar a siguiente pantalla
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  /// Navegar a ExperienceScreen
  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ExperienceScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _canSkip ? _navigateToNextScreen : null,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo JimmySoft
                _buildLogo(),
                const SizedBox(height: 40),
                // Texto presentación
                _buildPresentation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget del logo
  Widget _buildLogo() {
    return Image.asset(
      'assets/jimmy_logo.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Center(
            child: Text(
              'JS',
              style: GoogleFonts.pressStart2p(
                fontSize: 48,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget del texto de presentación
  Widget _buildPresentation() {
    return Text(
      'JimmySoft presenta...',
      textAlign: TextAlign.center,
      style: GoogleFonts.pressStart2p(
        fontSize: 18,
        color: const Color(0xFFFFD700), // Amarillo pixel
        shadows: [
          const Shadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
