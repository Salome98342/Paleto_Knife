import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import '../models/user.dart' as user_module;

typedef UserModel = user_module.UserModel;

/// Servicio de autenticación con Firebase Auth + Google Sign-In
/// Guarda datos automáticamente en Firebase Realtime Database
class FirebaseAuthService extends ChangeNotifier {
  static final FirebaseAuthService _instance =
      FirebaseAuthService._internal();

  factory FirebaseAuthService() {
    return _instance;
  }

  FirebaseAuthService._internal();

  static FirebaseAuthService get instance => _instance;

  // Firebase & Google Sign-In instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  User? _currentFirebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get firebaseUser => _currentFirebaseUser;
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _currentFirebaseUser != null;

  /// Inicializa el servicio y carga usuario guardado
  Future<void> initialize() async {
    try {
      _currentFirebaseUser = _auth.currentUser;
      if (_currentFirebaseUser != null) {
        await _loadUserFromDatabase();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[FirebaseAuthService] Error initializing: $e');
    }
  }

  /// Inicia sesión con Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Obtener cuenta de Google
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        _errorMessage = 'Sign-in fue cancelado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      // Crear credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _currentFirebaseUser = userCredential.user;

      if (_currentFirebaseUser == null) {
        throw Exception('No user returned from Firebase');
      }

      // Crear modelo de usuario
      _currentUser = UserModel(
        id: _currentFirebaseUser!.uid,
        email: _currentFirebaseUser!.email ?? googleAccount.email,
        username: _currentFirebaseUser!.displayName ??
            googleAccount.displayName ??
            googleAccount.email.split('@')[0],
        avatarUrl: _currentFirebaseUser!.photoURL ?? googleAccount.photoUrl,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Guardar en Realtime Database
      await _saveUserToDatabase();

      print('✓ Google Sign-In exitoso: ${_currentUser!.username}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] Sign-in error: $e');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentFirebaseUser = null;
      _currentUser = null;
      _errorMessage = null;
      print('✓ Sesión cerrada');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      debugPrint('[FirebaseAuthService] Sign-out error: $e');
      notifyListeners();
    }
  }

  /// Guarda usuario en Firebase Realtime Database
  Future<void> _saveUserToDatabase() async {
    if (_currentUser == null || _currentFirebaseUser == null) return;

    try {
      final userRef = _database.ref('users/${_currentFirebaseUser!.uid}');
      await userRef.set({
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'username': _currentUser!.username,
        'avatarUrl': _currentUser!.avatarUrl,
        'createdAt': _currentUser!.createdAt.toIso8601String(),
        'lastLogin': _currentUser!.lastLogin.toIso8601String(),
      });
      print('✓ Usuario guardado en base de datos');
    } catch (e) {
      print('Error saving user to database: $e');
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentFirebaseUser = userCredential.user;

      if (_currentFirebaseUser == null) {
        throw Exception('No user returned from Firebase');
      }

      await _loadUserFromDatabase();
      print('✓ Login con email exitoso: ${_currentUser!.username}');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] Sign-in error: $e');
      return false;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] Sign-in error: $e');
      return false;
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentFirebaseUser = userCredential.user;

      if (_currentFirebaseUser == null) {
        throw Exception('No user returned from Firebase');
      }

      // Establecer nombre de usuario en Firebase Auth
      await _currentFirebaseUser!.updateDisplayName(username);
      await _currentFirebaseUser!.reload();

      // Crear modelo de usuario
      _currentUser = UserModel(
        id: _currentFirebaseUser!.uid,
        email: email,
        username: username,
        avatarUrl: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Guardar en Realtime Database
      await _saveUserToDatabase();

      print('✓ Registro exitoso: $username');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] Sign-up error: $e');
      return false;
    } catch (e) {
      _errorMessage = 'Error al registrarse: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] Sign-up error: $e');
      return false;
    }
  }

  /// Obtiene mensaje de error legible del código de error de Firebase
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'Contraseña muy débil';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'too-many-requests':
        return 'Demasiados intentos, intenta más tarde';
      default:
        return 'Error: $code';
    }
  }

  /// Carga usuario desde Firebase Realtime Database
  Future<void> _loadUserFromDatabase() async {
    if (_currentFirebaseUser == null) return;

    try {
      final userRef = _database.ref('users/${_currentFirebaseUser!.uid}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _currentUser = UserModel(
          id: data['id'] ?? _currentFirebaseUser!.uid,
          email: data['email'] ?? _currentFirebaseUser!.email ?? '',
          username: data['username'] ??
              _currentFirebaseUser!.displayName ??
              'Usuario',
          avatarUrl: data['avatarUrl'],
          createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
          lastLogin: DateTime.parse(
              data['lastLogin'] ?? DateTime.now().toIso8601String()),
        );
        print('✓ Usuario cargado desde base de datos');
      } else {
        // Usuario no existe en BD, crear nuevo registro
        _currentUser = UserModel(
          id: _currentFirebaseUser!.uid,
          email: _currentFirebaseUser!.email ?? '',
          username: _currentFirebaseUser!.displayName ?? 'Usuario',
          avatarUrl: _currentFirebaseUser!.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        await _saveUserToDatabase();
      }
    } catch (e) {
      print('Error loading user from database: $e');
    }
  }

  /// Actualiza último login
  Future<void> updateLastLogin() async {
    if (_currentUser == null || _currentFirebaseUser == null) return;

    try {
      _currentUser = _currentUser!.copyWith(lastLogin: DateTime.now());
      final userRef = _database.ref('users/${_currentFirebaseUser!.uid}');
      await userRef.update({
        'lastLogin': _currentUser!.lastLogin.toIso8601String(),
      });
    } catch (e) {
      print('Error updating lastLogin: $e');
    }
  }

  /// Guarda datos del juego en la nube
  Future<void> saveGameData(Map<String, dynamic> gameData) async {
    if (_currentFirebaseUser == null) return;

    try {
      final gameRef = _database.ref('users/${_currentFirebaseUser!.uid}/gameData');
      await gameRef.set(gameData);
      print('✓ Datos del juego guardados');
    } catch (e) {
      print('Error saving game data: $e');
    }
  }

  /// Carga datos del juego desde la nube
  Future<Map<String, dynamic>?> loadGameData() async {
    if (_currentFirebaseUser == null) return null;

    try {
      final gameRef = _database.ref('users/${_currentFirebaseUser!.uid}/gameData');
      final snapshot = await gameRef.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error loading game data: $e');
      return null;
    }
  }
}
