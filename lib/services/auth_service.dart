import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Servicio de autenticación con registro e inicio de sesión propios
class AuthService {
  static const String _userKey = 'auth_user';
  static const String _allUsersKey = 'auth_all_users';

  UserModel? _currentUser;

  AuthService._internal() {
    _initialize();
  }

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  /// Inicializar y recuperar usuario guardado
  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userKey);

      if (userJsonString != null) {
        _currentUser = UserModel.fromJsonString(userJsonString);
        print('✓ Usuario recuperado: ${_currentUser!.username}');
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  // ============= VALIDACIONES =============

  /// Validar formato de email
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validar username (mínimo 3 caracteres, sin espacios)
  bool _isValidUsername(String username) {
    return username.length >= 3 &&
        !username.contains(' ') &&
        username.replaceAll(RegExp(r'[a-zA-Z0-9_-]'), '').isEmpty;
  }

  /// Verificar si email ya existe
  Future<bool> _emailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getStringList(_allUsersKey) ?? [];

      for (String userJson in allUsersJson) {
        final user = UserModel.fromJsonString(userJson);
        if (user.email.toLowerCase() == email.toLowerCase()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  /// Verificar si username ya existe
  Future<bool> _usernameExists(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getStringList(_allUsersKey) ?? [];

      for (String userJson in allUsersJson) {
        final user = UserModel.fromJsonString(userJson);
        if (user.username.toLowerCase() == username.toLowerCase()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // ============= REGISTRO =============

  /// Registrar nuevo usuario
  /// Retorna Map con {success: bool, message: String}
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
  }) async {
    try {
      print('=== Registrando usuario ===');

      // Validación de email
      if (email.isEmpty) {
        return {'success': false, 'message': 'El correo no puede estar vacío'};
      }
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Formato de correo inválido'
        };
      }

      // Validación de username
      if (username.isEmpty) {
        return {
          'success': false,
          'message': 'El nombre de usuario no puede estar vacío'
        };
      }
      if (!_isValidUsername(username)) {
        return {
          'success': false,
          'message':
              'Usuario debe tener 3+ caracteres (solo letras, números, _ y -)'
        };
      }

      // Verificar si email existe
      if (await _emailExists(email)) {
        return {
          'success': false,
          'message': 'Este correo ya está registrado'
        };
      }

      // Verificar si username existe
      if (await _usernameExists(username)) {
        return {
          'success': false,
          'message': 'Este nombre de usuario ya existe'
        };
      }

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));

      // Crear usuario
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: username,
      );

      // Guardar usuario
      await _saveCurrentUser();
      await _saveUserToList(_currentUser!);

      print('✓ Usuario registrado exitosamente: $username');
      return {
        'success': true,
        'message': '¡Cuenta creada exitosamente!'
      };
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Error al registrar: $e'
      };
    }
  }

  // ============= LOGIN =============

  /// Iniciar sesión con email y username
  /// Retorna Map con {success: bool, message: String}
  Future<Map<String, dynamic>> login({
    required String email,
    required String username,
  }) async {
    try {
      print('=== Iniciando sesión ===');

      if (email.isEmpty || username.isEmpty) {
        return {
          'success': false,
          'message': 'Correo y usuario son requeridos'
        };
      }

      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));

      // Buscar usuario
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getStringList(_allUsersKey) ?? [];

      for (String userJson in allUsersJson) {
        final user = UserModel.fromJsonString(userJson);
        if (user.email.toLowerCase() == email.toLowerCase() &&
            user.username.toLowerCase() == username.toLowerCase()) {
          // Actualizar último login
          _currentUser = user.copyWith(
            lastLogin: DateTime.now(),
          );

          // Guardar
          await _saveCurrentUser();
          await _updateUserInList(_currentUser!);

          print('✓ Sesión iniciada: ${_currentUser!.username}');
          return {
            'success': true,
            'message': 'Bienvenido'
          };
        }
      }

      return {
        'success': false,
        'message': 'Correo o usuario incorrecto'
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Error al iniciar sesión: $e'
      };
    }
  }

  // ============= SESIÓN =============

  /// Auto-login silencioso
  Future<bool> signInSilently() async {
    try {
      print('=== Auto-login silencioso ===');

      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userKey);

      if (userJsonString != null) {
        _currentUser = UserModel.fromJsonString(userJsonString);
        print('✓ Auto-login exitoso: ${_currentUser!.username}');

        // Simular validación
        await Future.delayed(const Duration(milliseconds: 500));
        return true;
      }

      print('✗ No hay sesión guardada');
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      print('✓ Logout completado');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // ============= PERSISTENCIA =============

  /// Guardar usuario actual
  Future<void> _saveCurrentUser() async {
    try {
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, _currentUser!.toJsonString());
      }
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  /// Guardar usuario en lista de todos los usuarios
  Future<void> _saveUserToList(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getStringList(_allUsersKey) ?? [];

      allUsersJson.add(user.toJsonString());

      await prefs.setStringList(_allUsersKey, allUsersJson);
    } catch (e) {
      print('Error saving user to list: $e');
    }
  }

  /// Actualizar usuario en lista
  Future<void> _updateUserInList(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getStringList(_allUsersKey) ?? [];

      // Encontrar índice del usuario
      int index = allUsersJson.indexWhere((json) {
        final u = UserModel.fromJsonString(json);
        return u.id == user.id;
      });

      if (index != -1) {
        allUsersJson[index] = user.toJsonString();
        await prefs.setStringList(_allUsersKey, allUsersJson);
      }
    } catch (e) {
      print('Error updating user in list: $e');
    }
  }
}
