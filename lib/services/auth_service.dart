import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Servicio de autenticación - SIMULADO para desarrollo
/// En producción, usar: google_sign_in (para Google) o play_games (para Play Games)
class AuthService {
  static const String _userKey = 'auth_user';
  static const String _emailKey = 'auth_email';

  UserModel? _currentUser;

  AuthService._internal() {
    _initialize();
  }

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  /// Inicializar datos guardados
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);

      if (userStr != null) {
        // En producción, parsear JSON real
        print('✓ Sesión previa encontrada: $userStr');
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  /// Login interactivo - SIMULADO
  /// En producción: GoogleSignIn.signIn()
  Future<bool> signIn() async {
    try {
      print('=== Iniciando Login (SIMULADO) ===');

      // Simular delay de autenticación
      await Future.delayed(const Duration(milliseconds: 1500));

      // Crear usuario simulado
      _currentUser = UserModel(
        id: 'chef_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Paleto Chef',
        avatarUrl: null,
      );

      // Guardar sesión
      await _saveSession();

      print('✓ Login exitoso: ${_currentUser!.name}');
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  /// Login silencioso - SIMULADO
  /// Intenta recuperar sesión anterior
  /// NO muestra UI
  Future<bool> signInSilently() async {
    try {
      print('=== Intentando auto-login silencioso ===');

      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);

      if (userStr != null) {
        // Hay sesión previa
        print('✓ Auto-login exitoso');

        // Recuperar usuario
        _currentUser = UserModel(
          id: 'chef_restored',
          name: 'Paleto Chef',
          avatarUrl: null,
        );

        // Simular validación
        await Future.delayed(const Duration(milliseconds: 800));

        return true;
      }

      print('✗ No hay sesión guardada - Ir a LoginScreen');
      return false;
    } catch (e) {
      print('Silent sign in error: $e');
      return false;
    }
  }

  /// Verificar si está autenticado
  Future<bool> isSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);
      return userStr != null;
    } catch (e) {
      print('Error checking sign in status: $e');
      return false;
    }
  }

  /// Obtener usuario actual
  UserModel? getUser() {
    return _currentUser;
  }

  /// Logout
  Future<void> signOut() async {
    try {
      print('=== Logout ===');

      _currentUser = null;

      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_emailKey);

      print('✓ Logout completado');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Guardar sesión en SharedPreferences
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUser != null) {
        // En producción, guardar JSON real
        await prefs.setString(_userKey, _currentUser.toString());
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }
}
