import 'dart:convert';

/// Modelo de usuario autenticado
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  /// Convertir a JSON para guardarlo en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  /// Crear desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  /// Crear desde JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  /// Convertir a JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Copiar con cambios
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, username: $username)';
}
