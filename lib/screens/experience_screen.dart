import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loading_screen.dart';

/// Pantalla de recomendación de audífonos
/// Muestra mensaje con fade-in/out rápido
class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startSequence();
  }

  /// Inicializar animación
  void _initializeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  /// Ejecutar secuencia
  /// Fade-in rápido → Mostrar 2s → Fade-out
  Future<void> _startSequence() async {
    // Fade-in: 500ms
    if (mounted) {
      await _fadeController.forward();
    }

    // Mostrar: 2 segundos
    if (mounted) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Fade-out: 500ms
    if (mounted) {
      await _fadeController.reverse();
    }

    // Navegar
    if (mounted) {
      _navigateToLoading();
    }
  }

  /// Navegar a LoadingScreen
  void _navigateToLoading() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de audífonos
              const Icon(
                Icons.headphones,
                size: 80,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(height: 30),
              // Texto principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Para una mejor experiencia\nusa audífonos 🎧',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
