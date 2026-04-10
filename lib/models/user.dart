/// Modelo de usuario autenticado
class UserModel {
  final String id;
  final String name;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  /// Convertir a JSON para guardarlo en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  /// Crear desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name)';
}
