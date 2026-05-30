import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// dart:typed_data not required directly
// dart:convert removed (not used)
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
  UserModel? get currentUser => _currentUser;  // Getter público para pantalla de perfil
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

      _ensureFallbackUser(googleAccount.email, googleAccount.displayName);

      // Guardar en Realtime Database
      await _saveUserToDatabase();

      debugPrint('✓ Google Sign-In exitoso: ${_currentUser!.username}');
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
        'bio': _currentUser!.bio,
        'favoriteColor': _currentUser!.favoriteColor,
        'totalGamesPlayed': _currentUser!.totalGamesPlayed,
        'highestLevel': _currentUser!.highestLevel,
        'totalCoinsEarned': _currentUser!.totalCoinsEarned,
      });
      debugPrint('✓ Usuario guardado en base de datos');
    } catch (e) {
      debugPrint('Error saving user to database: $e');
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
      final currentUsername = _currentUser?.username ??
          _currentFirebaseUser?.displayName ??
          email.split('@').first;
      _ensureFallbackUser(email, currentUsername);
      debugPrint('✓ Login con email exitoso: $currentUsername');
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

  /// Envía un email de recuperación de contraseña
  Future<bool> sendPasswordReset({
    required String email,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      debugPrint('✓ Password reset email sent to $email');
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] sendPasswordReset error: $e');
      return false;
    } catch (e) {
      _errorMessage = 'Error al enviar recuperación: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('[FirebaseAuthService] sendPasswordReset error: $e');
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

      _ensureFallbackUser(email, username);

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

      debugPrint('✓ Registro exitoso: $username');
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
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          lastLogin: data['lastLogin'] != null
              ? DateTime.parse(data['lastLogin'] as String)
              : DateTime.now(),
          bio: data['bio'] as String?,
          favoriteColor: data['favoriteColor'] as String?,
          totalGamesPlayed: data['totalGamesPlayed'] as int? ?? 0,
          highestLevel: data['highestLevel'] as int? ?? 0,
          totalCoinsEarned: data['totalCoinsEarned'] as int? ?? 0,
        );
        debugPrint('✓ Usuario cargado desde base de datos');
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
      debugPrint('Error loading user from database: $e');
      _ensureFallbackUser(
        _currentFirebaseUser?.email,
        _currentFirebaseUser?.displayName,
      );
      if (_currentUser == null && _currentFirebaseUser != null) {
        _currentUser = UserModel(
          id: _currentFirebaseUser!.uid,
          email: _currentFirebaseUser!.email ?? '',
          username: _currentFirebaseUser!.displayName ??
              (_currentFirebaseUser!.email ?? 'Usuario').split('@')[0],
          avatarUrl: _currentFirebaseUser!.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
      }
    }
  }

  void _ensureFallbackUser(String? email, String? displayName) {
    if (_currentFirebaseUser == null) return;

    _currentUser ??= UserModel(
      id: _currentFirebaseUser!.uid,
      email: email ?? _currentFirebaseUser!.email ?? '',
      username: displayName ??
          _currentFirebaseUser!.displayName ??
          (email ?? _currentFirebaseUser!.email ?? 'Usuario').split('@')[0],
      avatarUrl: _currentFirebaseUser!.photoURL,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
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
      debugPrint('Error updating lastLogin: $e');
    }
  }

  /// Guarda datos del juego en la nube
  Future<void> saveGameData(Map<String, dynamic> gameData) async {
    if (_currentFirebaseUser == null) return;

    try {
      final gameRef = _database.ref('users/${_currentFirebaseUser!.uid}/gameData');
      await gameRef.set(gameData);
      debugPrint('✓ Datos del juego guardados');
    } catch (e) {
      debugPrint('Error saving game data: $e');
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
      debugPrint('Error loading game data: $e');
      return null;
    }
  }

  /// Cierra sesión del usuario actual
  Future<bool> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signOut();
      await _googleSignIn.signOut();
      _currentUser = null;
      _currentFirebaseUser = null;
      _errorMessage = null;
      
      debugPrint('✓ Sesión cerrada');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error signing out: $e');
      return false;
    }
  }

  /// Actualiza el perfil del usuario
  Future<bool> updateUserProfile({
    String? username,
    String? bio,
    String? favoriteColor,
    String? avatarUrl,
  }) async {
    if (_currentUser == null || _currentFirebaseUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar en Firebase Auth si cambia el nombre
      if (username != null && username != _currentUser!.username) {
        await _currentFirebaseUser!.updateDisplayName(username);
        await _currentFirebaseUser!.reload();
      }

      // Preparar datos para actualizar
      Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (favoriteColor != null) updateData['favoriteColor'] = favoriteColor;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      // Actualizar en Realtime Database
      final userRef = _database.ref('users/${_currentFirebaseUser!.uid}');
      await userRef.update(updateData);

      // Actualizar modelo local
      _currentUser = _currentUser!.copyWith(
        username: username,
        bio: bio,
        favoriteColor: favoriteColor,
        avatarUrl: avatarUrl,
      );

      debugPrint('✓ Perfil actualizado');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Elimina la cuenta del usuario
  Future<bool> deleteUserAccount() async {
    if (_currentUser == null || _currentFirebaseUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final uid = _currentFirebaseUser!.uid;

      // Eliminar datos de la BD
      await _database.ref('users/$uid').remove();

      // Eliminar usuario de Firebase Auth
      await _currentFirebaseUser!.delete();

      // Limpiar estado local
      _currentUser = null;
      _currentFirebaseUser = null;
      _errorMessage = null;

      debugPrint('✓ Cuenta eliminada');
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al eliminar cuenta: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting account: $e');
      return false;
    }
  }

  /// Método auxiliar para guardar URL de avatar
  Future<bool> updateAvatarUrl(String avatarUrl) async {
    if (_currentUser == null || _currentFirebaseUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar URL de foto en Firebase Auth
      await _currentFirebaseUser!.updatePhotoURL(avatarUrl);
      await _currentFirebaseUser!.reload();

      // Actualizar en BD
      final userRef = _database.ref('users/${_currentFirebaseUser!.uid}');
      await userRef.update({'avatarUrl': avatarUrl});

      // Actualizar modelo local
      _currentUser = _currentUser!.copyWith(avatarUrl: avatarUrl);

      debugPrint('✓ Avatar actualizado');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar avatar: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating avatar: $e');
      return false;
    }
  }

  /// Selecciona imagen del dispositivo (galería o cámara) y la sube a Firebase Storage.
  /// Al terminar actualiza la URL en Auth y Realtime DB.
  Future<bool> pickAndUploadAvatar({ImageSource source = ImageSource.gallery}) async {
    if (_currentFirebaseUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      return false;
    }

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
      if (file == null) return false;

      final bytes = await file.readAsBytes();
      final uid = _currentFirebaseUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid/avatar.jpg');

      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      await uploadTask;
      final url = await ref.getDownloadURL();

      // Actualizar URL en Auth y en Realtime DB
      return await updateAvatarUrl(url);
    } catch (e) {
      _errorMessage = 'Error al subir avatar: $e';
      notifyListeners();
      debugPrint('[FirebaseAuthService] upload avatar error: $e');
      return false;
    }
  }
}

