import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../ui/theme/paleto_colors.dart';
import '../services/firebase_auth_service.dart';
import '../controllers/economy_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/chef_controller.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_layout.dart' as main_layout;

/// Formulario de login retro 8-bit hermoso
class RetroLoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const RetroLoginForm({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<RetroLoginForm> createState() => _RetroLoginFormState();
}

class _RetroLoginFormState extends State<RetroLoginForm>
    with TickerProviderStateMixin {
  late FirebaseAuthService _authService;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _authService = FirebaseAuthService.instance;

    // Animación de entrada
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Validar formulario
  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showErrorSnackbar('Por favor ingresa un email');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showErrorSnackbar('Por favor ingresa un email válido');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar('Por favor ingresa una contraseña');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showErrorSnackbar('La contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (_isSignUp) {
      if (_usernameController.text.isEmpty) {
        _showErrorSnackbar('Por favor ingresa un nombre de usuario');
        return false;
      }
      if (_confirmPasswordController.text != _passwordController.text) {
        _showErrorSnackbar('Las contraseñas no coinciden');
        return false;
      }
    }
    return true;
  }

  /// Validar email
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<void> _refreshAccountState() async {
    await Future.wait([
      context.read<EconomyController>().reloadForCurrentUser(),
      context.read<GameController>().reloadForCurrentUser(),
      context.read<ChefController>().reloadForCurrentUser(),
    ]);
  }

  /// Manejar login
  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    final success = await _authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success && _authService.user != null) {
        await _refreshAccountState();
        _showSuccessSnackbar('¡Bienvenido ${_authService.user!.username}!');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            ),
          );
          widget.onLoginSuccess?.call();
        }
      } else {
        _showErrorSnackbar(_authService.errorMessage ?? 'Error al iniciar sesión');
      }
    }
  }

  /// Manejar registro
  Future<void> _handleSignUp() async {
    if (!_validateForm()) return;

    final success = await _authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (mounted) {
      if (success && _authService.user != null) {
        await _refreshAccountState();
        _showSuccessSnackbar('¡Registro exitoso! Bienvenido ${_authService.user!.username}!');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            ),
          );
          widget.onLoginSuccess?.call();
        }
      } else {
        _showErrorSnackbar(_authService.errorMessage ?? 'Error al registrarse');
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

  /// Mostrar diálogo para recuperar contraseña
  Future<void> _showPasswordResetDialog() async {
    final String? email = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String emailValue = _emailController.text.trim();

        return AlertDialog(
          backgroundColor: PaletoColors.bgPanel,
          title: Text(
            'RECUPERAR CONTRASEÑA',
            style: GoogleFonts.pressStart2p(fontSize: 10, color: PaletoColors.textAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ingresa tu email para recibir instrucciones',
                  style: GoogleFonts.robotoMono(color: PaletoColors.textPrimary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: emailValue,
                  onChanged: (value) => emailValue = value,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.robotoMono(color: PaletoColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'tu@email.com',
                    hintStyle: GoogleFonts.robotoMono(color: PaletoColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop<String>(null),
              child: Text('CANCELAR', style: GoogleFonts.pressStart2p(fontSize: 7, color: PaletoColors.textAccent)),
            ),
            TextButton(
              onPressed: () {
                final email = emailValue.trim();
                if (email.isEmpty || !_isValidEmail(email)) {
                  _showErrorSnackbar('Por favor ingresa un email válido');
                  return;
                }
                Navigator.of(ctx).pop(email);
              },
              child: Text('ENVIAR', style: GoogleFonts.pressStart2p(fontSize: 7, color: PaletoColors.textAccent)),
            ),
          ],
        );
      },
    );

    if (email == null || !mounted) return;

    final ok = await _authService.sendPasswordReset(email: email);
    if (!mounted) return;

    if (ok) {
      _showSuccessSnackbar('Email de recuperación enviado');
    } else {
      _showErrorSnackbar(_authService.errorMessage ?? 'Error al enviar email');
    }
  }

  /// Mostrar snackbar de error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.pressStart2p(fontSize: 8),
        ),
        backgroundColor: PaletoColors.btnPrimary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostrar snackbar de éxito
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.pressStart2p(fontSize: 8),
        ),
        backgroundColor: PaletoColors.btnSecondary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletoColors.bgDeep,
      body: Stack(
        children: [
          // Fondo decorativo con patrón
          _buildBackgroundPattern(),

          // Contenido principal
          SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    _buildLogo(),
                    const SizedBox(height: 32),

                    // Título
                    _buildTitle(),
                    const SizedBox(height: 32),

                    // Tarjeta del formulario
                    _buildFormCard(),
                    const SizedBox(height: 32),

                    // Toggle entre login y signup
                    _buildToggleButton(),
                    const SizedBox(height: 16),

                    // Botón de invitado
                    _buildGuestButton(),
                    const SizedBox(height: 40),

                    // Contacto de soporte
                    _buildSupportFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construir fondo decorativo
  Widget _buildBackgroundPattern() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PaletoColors.bgDeep,
            PaletoColors.bgPanelAlt,
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.05,
          child: Image.asset(
            'lib/assets/stripes_pattern.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// Construir logo
  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: PaletoColors.borderLight, width: 3),
          left: BorderSide(color: PaletoColors.borderLight, width: 3),
          bottom: BorderSide(color: PaletoColors.borderDark, width: 3),
          right: BorderSide(color: PaletoColors.borderDark, width: 3),
        ),
        color: PaletoColors.bgPanel,
      ),
      child: Image.asset(
        'lib/assets/PaletoLogo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.restaurant,
              size: 60,
              color: PaletoColors.textAccent,
            ),
          );
        },
      ),
    );
  }

  /// Construir título
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'PALETO KNIFE',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 18,
            color: PaletoColors.textAccent,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                color: PaletoColors.borderDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: PaletoColors.btnPrimaryLt,
          ),
        ),
      ],
    );
  }

  /// Construir tarjeta del formulario
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: PaletoColors.borderLight, width: 3),
          left: BorderSide(color: PaletoColors.borderLight, width: 3),
          bottom: BorderSide(color: PaletoColors.borderDark, width: 3),
          right: BorderSide(color: PaletoColors.borderDark, width: 3),
        ),
        color: PaletoColors.bgPanel,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de email
          _buildTextField(
            controller: _emailController,
            label: 'EMAIL',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: !_authService.isLoading,
          ),
          const SizedBox(height: 16),

          // Campo de usuario (solo en signup)
          if (_isSignUp) ...[
            _buildTextField(
              controller: _usernameController,
              label: 'USUARIO',
              icon: Icons.person,
              enabled: !_authService.isLoading,
            ),
            const SizedBox(height: 16),
          ],

          // Campo de contraseña
          _buildPasswordField(
            controller: _passwordController,
            label: 'CONTRASEÑA',
            showPassword: _showPassword,
            onToggle: () {
              setState(() => _showPassword = !_showPassword);
            },
            enabled: !_authService.isLoading,
          ),
          const SizedBox(height: 8),

          // Enlace para recuperar contraseña (solo en login)
          if (!_isSignUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _authService.isLoading ? null : _showPasswordResetDialog,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: Text(
                  '¿OLVIDASTE TU CONTRASEÑA?',
                  style: GoogleFonts.pressStart2p(fontSize: 6, color: PaletoColors.textSecondary),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Campo de confirmar contraseña (solo en signup)
          if (_isSignUp) ...[
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'CONFIRMAR',
              showPassword: _showConfirmPassword,
              onToggle: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
              enabled: !_authService.isLoading,
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 24),

          // Botón principal
          _buildMainButton(),
        ],
      ),
    );
  }

  /// Construir campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: PaletoColors.textAccent,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: PaletoColors.borderDark, width: 2),
              left: BorderSide(color: PaletoColors.borderDark, width: 2),
              bottom: BorderSide(color: PaletoColors.borderLight, width: 2),
              right: BorderSide(color: PaletoColors.borderLight, width: 2),
            ),
            color: PaletoColors.bgPanelAlt,
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: GoogleFonts.robotoMono(
              color: PaletoColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              prefixIcon: Icon(
                icon,
                color: PaletoColors.textAccent,
                size: 18,
              ),
              hintText: label.toLowerCase(),
              hintStyle: GoogleFonts.robotoMono(
                color: PaletoColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construir campo de contraseña
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: PaletoColors.textAccent,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: PaletoColors.borderDark, width: 2),
              left: BorderSide(color: PaletoColors.borderDark, width: 2),
              bottom: BorderSide(color: PaletoColors.borderLight, width: 2),
              right: BorderSide(color: PaletoColors.borderLight, width: 2),
            ),
            color: PaletoColors.bgPanelAlt,
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: !showPassword,
            style: GoogleFonts.robotoMono(
              color: PaletoColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              prefixIcon: Icon(
                Icons.lock,
                color: PaletoColors.textAccent,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: enabled ? onToggle : null,
                child: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: PaletoColors.textAccent,
                  size: 18,
                ),
              ),
              hintText: label.toLowerCase(),
              hintStyle: GoogleFonts.robotoMono(
                color: PaletoColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construir botón principal
  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _authService.isLoading ? null : (_isSignUp ? _handleSignUp : _handleLogin),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _authService.isLoading
                  ? PaletoColors.borderMid
                  : PaletoColors.borderLight,
              width: 3,
            ),
            left: BorderSide(
              color: _authService.isLoading
                  ? PaletoColors.borderMid
                  : PaletoColors.borderLight,
              width: 3,
            ),
            bottom: BorderSide(
              color: _authService.isLoading
                  ? PaletoColors.borderMid
                  : PaletoColors.borderDark,
              width: 3,
            ),
            right: BorderSide(
              color: _authService.isLoading
                  ? PaletoColors.borderMid
                  : PaletoColors.borderDark,
              width: 3,
            ),
          ),
          color: _authService.isLoading ? PaletoColors.btnNeutral : PaletoColors.btnPrimary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: _authService.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PaletoColors.textAccent,
                  ),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isSignUp ? 'CREAR CUENTA' : 'JUGAR',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: PaletoColors.textPrimary,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      color: PaletoColors.borderDark,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Construir botón de toggle
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: _authService.isLoading
          ? null
          : () {
              setState(() => _isSignUp = !_isSignUp);
              _emailController.clear();
              _passwordController.clear();
              _usernameController.clear();
              _confirmPasswordController.clear();
            },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: PaletoColors.borderLight, width: 2),
            left: BorderSide(color: PaletoColors.borderLight, width: 2),
            bottom: BorderSide(color: PaletoColors.borderDark, width: 2),
            right: BorderSide(color: PaletoColors.borderDark, width: 2),
          ),
          color: PaletoColors.bgPanel,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          _isSignUp ? '¿TIENES CUENTA? INICIA SESIÓN' : '¿NUEVA CUENTA? CREAR',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: PaletoColors.textAccent,
          ),
        ),
      ),
    );
  }

  /// Construir botón de invitado
  Widget _buildGuestButton() {
    return GestureDetector(
      onTap: _authService.isLoading ? null : _handleGuestLogin,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: PaletoColors.borderLight, width: 2),
            left: BorderSide(color: PaletoColors.borderLight, width: 2),
            bottom: BorderSide(color: PaletoColors.borderDark, width: 2),
            right: BorderSide(color: PaletoColors.borderDark, width: 2),
          ),
          color: PaletoColors.btnSecondary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'JUGAR COMO INVITADO',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: PaletoColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Pie de soporte con correo de la empresa
  Widget _buildSupportFooter() {
    const supportEmail = 'ecdj.jimmy.soft@gmail.com';

    return InkWell(
      onTap: () async {
        await Clipboard.setData(const ClipboardData(text: supportEmail));
        if (mounted) {
          _showSuccessSnackbar('Correo de soporte copiado');
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              'SOPORTE',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: PaletoColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, size: 16, color: PaletoColors.textAccent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    supportEmail,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: PaletoColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Toca para copiar',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 5,
                color: PaletoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
