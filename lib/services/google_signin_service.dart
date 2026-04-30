import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart' as user_module;

typedef User = user_module.UserModel;

/// Servicio de autenticación con Google Sign-In
class GoogleSignInService extends ChangeNotifier {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal();

  static GoogleSignInService get instance => _instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  GoogleSignInAccount? get currentUser => _currentUser;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentUser != null;

  /// Inicializa el servicio y carga usuario almacenado
  Future<void> initialize() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _loadUserFromStorage();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[GoogleSignInService] Error initializing: $e');
    }
  }

  /// Inicia sesión con Google
  Future<bool> signIn() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        _errorMessage = 'Sign-in fue cancelado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = account;

      // Crear usuario con datos de Google
      _user = User(
        id: account.id,
        email: account.email,
        username: account.displayName ?? account.email.split('@')[0],
        avatarUrl: account.photoUrl,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Guardar en storage
      await _saveUserToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[GoogleSignInService] Sign-in error: $e');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _user = null;

      // Borrar de storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_user');

      notifyListeners();
    } catch (e) {
      debugPrint('[GoogleSignInService] Sign-out error: $e');
    }
  }

  /// Desconecta la cuenta completamente
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      _user = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_user');

      notifyListeners();
    } catch (e) {
      debugPrint('[GoogleSignInService] Disconnect error: $e');
    }
  }

  /// Guarda usuario en SharedPreferences
  Future<void> _saveUserToStorage() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': _user!.id,
        'email': _user!.email,
        'username': _user!.username,
        'avatarUrl': _user!.avatarUrl,
        'createdAt': _user!.createdAt.toIso8601String(),
        'lastLogin': _user!.lastLogin.toIso8601String(),
      });
      await prefs.setString('google_user', userJson);
      debugPrint('[GoogleSignInService] Usuario guardado en storage');
    } catch (e) {
      debugPrint('[GoogleSignInService] Error saving user: $e');
    }
  }

  /// Carga usuario de SharedPreferences
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('google_user');

      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        _user = User(
          id: data['id'],
          email: data['email'],
          username: data['username'],
          avatarUrl: data['avatarUrl'],
          createdAt: DateTime.parse(data['createdAt']),
          lastLogin: DateTime.parse(data['lastLogin']),
        );
        debugPrint('[GoogleSignInService] Usuario cargado de storage');
      }
    } catch (e) {
      debugPrint('[GoogleSignInService] Error loading user: $e');
    }
  }

  /// Actualiza último login
  Future<void> updateLastLogin() async {
    if (_user != null) {
      _user = _user!.copyWith(lastLogin: DateTime.now());
      await _saveUserToStorage();
      notifyListeners();
    }
  }
}
