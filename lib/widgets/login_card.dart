import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_auth_service.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_layout.dart' as main_layout;

/// Tarjeta de login con Firebase Authentication + Google Sign-In
class LoginCard extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginCard({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  late FirebaseAuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = FirebaseAuthService.instance;
  }

  /// Manejar sign-in con Google
  Future<void> _handleGoogleSignIn() async {
    final success = await _authService.signInWithGoogle();

    if (mounted) {
      if (success && _authService.user != null) {
        _showSuccessSnackbar('¡Bienvenido ${_authService.user!.username}!');

        // Pequeño delay antes de navegar
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // Navegar a pantalla de bienvenida
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            ),
          );

          widget.onLoginSuccess?.call();
        }
      } else {
        _showErrorSnackbar(
            _authService.errorMessage ?? 'Error al iniciar sesión con Google');
      }
    }
  }

  /// Continuar como invitado
  Future<void> _handleGuestLogin() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const main_layout.MainLayout()),
      );
    }
  }

  /// Mostrar error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFCC3333),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar éxito
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF44CC44),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    const accentAlt = Color(0xFFFF6B00);
    const cardBg = Color(0xFF16213E);

    return Card(
      color: cardBg,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: accent,
          width: 3,
        ),
      ),
      shadowColor: accent.withAlpha(100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBg,
              cardBg.withAlpha(230),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo del juego
              _buildGameLogo(),
              const SizedBox(height: 28),

              // Título
              Column(
                children: [
                  Text(
                    'PALETO KNIFE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clicker & Combat RPG',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: accentAlt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Descripción
              Text(
                'Inicia sesión con Google para guardar tu progreso en la nube',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Botón Google Sign-In
              _buildGoogleSignInButton(accentAlt),
              const SizedBox(height: 16),

              // Botón Continuar como invitado
              _buildGuestButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget logo
  Widget _buildGameLogo() {
    return Image.asset(
      'lib/assets/PaletoLogo.png',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.restaurant,
            size: 50,
            color: Color(0xFFFFD700),
          ),
        );
      },
    );
  }

  /// Botón Google Sign-In
  Widget _buildGoogleSignInButton(Color accentAlt) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _authService.isLoading ? null : _handleGoogleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentAlt,
              foregroundColor: Colors.black87,
              disabledBackgroundColor: accentAlt.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 8,
            ),
            child: _authService.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black87),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/google_logo.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 24);
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SIGN IN WITH GOOGLE',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Botón Continuar como invitado
  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _handleGuestLogin,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFFFD700),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'PLAY AS GUEST',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: const Color(0xFFFFD700),
          ),
        ),
      ),
    );
  }
}
