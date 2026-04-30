import 'package:flutter/material.dart';
import '../widgets/retro_login_form.dart';

/// Pantalla de login mejorada
/// Se muestra solo si no hay sesión activa o falló el auto-login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const RetroLoginForm();
  }
}
