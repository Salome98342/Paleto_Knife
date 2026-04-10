import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/main_layout.dart' as main_layout;

/// Tarjeta de login reutilizable
/// Contiene:
/// - Logo del juego
/// - Nombre del juego
/// - Botón de Google Play Games
/// - Botón de continuar como invitado
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
  bool _isLoading = false;

  /// Intentar login con Google Play Games
  Future<void> _handleLoginGoogle() async {
    setState(() => _isLoading = true);

    try {
      final auth = AuthService();
      final success = await auth.signIn();

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Navegar a pantalla del juego
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const main_layout.MainLayout()),
          );

          widget.onLoginSuccess?.call();
        } else {
          _showErrorSnackbar('Login fallido. Intenta de nuevo.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error durante login: $e');
      }
    }
  }

  /// Continuar como invitado
  Future<void> _handleGuestLogin() async {
    // Simplemente navegar al juego sin autenticar
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const main_layout.MainLayout()),
      );
    }
  }

  /// Mostrar error en snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFCC3333),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFD700);
    const accentAlt = Color(0xFFFF6B00);
    const cardBg = Color(0xFF16213E);
    const borderColor = Color(0xFF444466);

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
              _buildTitle(),
              const SizedBox(height: 32),
              // Botón Google Play Games
              _buildGooglePlayButton(accentAlt),
              const SizedBox(height: 14),
              // Botón Continuar como invitado
              _buildGuestButton(),
              const SizedBox(height: 20),
              // Divider
              _buildDivider(),
              const SizedBox(height: 20),
              // Texto informativo
              _buildInfoText(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget logo del juego
  Widget _buildGameLogo() {
    return Image.asset(
      'assets/images/PaletoLogo.png',
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

  /// Widget título
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'PALETO KNIFE',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 16,
            color: const Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Clicker & Combat RPG',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: const Color(0xFFFF6B00),
          ),
        ),
      ],
    );
  }

  /// Botón Google Play Games
  Widget _buildGooglePlayButton(Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleLoginGoogle,
          icon: Icon(_isLoading ? Icons.hourglass_bottom : Icons.games),
          label: Text(
            _isLoading ? 'Autenticando...' : 'Iniciar con Google Play',
            style: GoogleFonts.pressStart2p(fontSize: 10),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withAlpha(128),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: color.withAlpha(150),
          ),
        ),
      ),
    );
  }

  /// Botón continuar como invitado
  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGuestLogin,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFFFD700),
            width: 2,
          ),
          foregroundColor: const Color(0xFFFFD700),
          disabledForegroundColor: const Color(0xFFFFD700).withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'Continuar como Invitado',
          style: GoogleFonts.pressStart2p(fontSize: 9),
        ),
      ),
    );
  }

  /// Divisor visual
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF444466).withAlpha(100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: const Color(0xFF8888AA),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF444466).withAlpha(100),
          ),
        ),
      ],
    );
  }

  /// Texto informativo
  Widget _buildInfoText() {
    return Column(
      children: [
        Text(
          '🔒 Tu progreso está seguro',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: const Color(0xFF8888AA),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Puedes jugar offline y sincronizar después',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: const Color(0xFF666688),
          ),
        ),
      ],
    );
  }
}
