enum ChefRarity { R, SR, SSR, UR }
enum ChefElement { fire, water, earth, hybrid, mixed }

class Chef {
  final String id;
  final String name;
  final ChefElement element;
  final ChefRarity rarity;
  final double baseAttack;
  final double speed;
  final String ability;
  final String passive;
  int level;
  int maxLevel;
  int tokens;

  Chef({
    required this.id,
    required this.name,
    required this.element,
    required this.rarity,
    required this.baseAttack,
    required this.speed,
    required this.ability,
    required this.passive,
    this.level = 1,
    required this.maxLevel,
    this.tokens = 0,
  });

  // Calculate upgrade cost
  int get upgradeCost {
    switch (rarity) {
      case ChefRarity.R:
        return 0; // R chefs don't level up this way
      case ChefRarity.SR:
        return level * 5;
      case ChefRarity.SSR:
        return level * 8;
      case ChefRarity.UR:
        return level * 12;
    }
  }

  bool get canUpgrade => level < maxLevel && tokens >= upgradeCost && rarity != ChefRarity.R;

  Chef copyWith({
    String? id,
    String? name,
    ChefElement? element,
    ChefRarity? rarity,
    double? baseAttack,
    double? speed,
    String? ability,
    String? passive,
    int? level,
    int? maxLevel,
    int? tokens,
  }) {
    return Chef(
      id: id ?? this.id,
      name: name ?? this.name,
      element: element ?? this.element,
      rarity: rarity ?? this.rarity,
      baseAttack: baseAttack ?? this.baseAttack,
      speed: speed ?? this.speed,
      ability: ability ?? this.ability,
      passive: passive ?? this.passive,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      tokens: tokens ?? this.tokens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'element': element.name,
      'rarity': rarity.name,
      'baseAttack': baseAttack,
      'speed': speed,
      'ability': ability,
      'passive': passive,
      'level': level,
      'maxLevel': maxLevel,
      'tokens': tokens,
    };
  }

  factory Chef.fromJson(Map<String, dynamic> json) {
    return Chef(
      id: json['id'],
      name: json['name'],
      element: ChefElement.values.firstWhere((e) => e.name == json['element'], orElse: () => ChefElement.mixed),
      rarity: ChefRarity.values.firstWhere((e) => e.name == json['rarity'], orElse: () => ChefRarity.R),
      baseAttack: (json['baseAttack'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      ability: json['ability'] ?? '',
      passive: json['passive'] ?? '',
      level: json['level'] ?? 1,
      maxLevel: json['maxLevel'] ?? 1,
      tokens: json['tokens'] ?? 0,
    );
  }
}
