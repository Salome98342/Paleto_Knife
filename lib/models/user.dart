import 'dart:convert';

/// Modelo de usuario autenticado con perfil personalizable
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  
  // Campos personalizables del perfil
  final String? bio;
  final String? favoriteColor;
  final int totalGamesPlayed;
  final int highestLevel;
  final int totalCoinsEarned;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.bio,
    this.favoriteColor,
    this.totalGamesPlayed = 0,
    this.highestLevel = 0,
    this.totalCoinsEarned = 0,
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
      'bio': bio,
      'favoriteColor': favoriteColor,
      'totalGamesPlayed': totalGamesPlayed,
      'highestLevel': highestLevel,
      'totalCoinsEarned': totalCoinsEarned,
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
      bio: json['bio'] as String?,
      favoriteColor: json['favoriteColor'] as String?,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      highestLevel: json['highestLevel'] as int? ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] as int? ?? 0,
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
    String? bio,
    String? favoriteColor,
    int? totalGamesPlayed,
    int? highestLevel,
    int? totalCoinsEarned,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      bio: bio ?? this.bio,
      favoriteColor: favoriteColor ?? this.favoriteColor,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      highestLevel: highestLevel ?? this.highestLevel,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, username: $username)';
}
