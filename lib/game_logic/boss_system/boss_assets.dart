// Archivo de configuración de assets para el sistema de bosses Danmaku
// Este archivo mapea qué archivos de sprites se necesitan para cada boss

/// Configuración de rutas de assets para bosses
class BossAssetConfig {
  // Gran Dumpling
  static const String granDumplingSprite = 'lib/assets/bosses/gran_dumpling/sprite.png';
  static const String granDumplingPhase2 = 'lib/assets/bosses/gran_dumpling/phase2_angry.png';

  // Vapor Spirit
  static const String vaporSpiritSprite = 'lib/assets/bosses/vapor_spirit/sprite.png';
  static const String vaporSpiritPhase2 = 'lib/assets/bosses/vapor_spirit/phase2_ethereal.png';
  static const String vaporSpiritPhase3 = 'lib/assets/bosses/vapor_spirit/phase3_storm.png';

  // Mother Root
  static const String motherRootSprite = 'lib/assets/bosses/mother_root/sprite.png';
  static const String motherRootPhase2 = 'lib/assets/bosses/mother_root/phase2_expanded.png';
  static const String motherRootPhase3 = 'lib/assets/bosses/mother_root/phase3_corrupted.png';

  // Stone Monk
  static const String stoneMonkSprite = 'lib/assets/bosses/stone_monk/sprite.png';
  static const String stoneMonkPhase2 = 'lib/assets/bosses/stone_monk/phase2_awakened.png';
  static const String stoneMonkPhase3 = 'lib/assets/bosses/stone_monk/phase3_enlightened.png';

  // Ancestral Dragon
  static const String ancestralDragonSprite = 'lib/assets/bosses/ancestral_dragon/sprite.png';
  static const String ancestralDragonPhase2 = 'lib/assets/bosses/ancestral_dragon/phase2_enraged.png';
  static const String ancestralDragonPhase3 = 'lib/assets/bosses/ancestral_dragon/phase3_chaos.png';
  static const String ancestralDragonPhase4 = 'lib/assets/bosses/ancestral_dragon/phase4_ultimate.png';

  /// Obtiene la ruta del sprite para un boss en una fase específica
  static String getSpritePathForBoss(String bossId, int phase) {
    switch (bossId) {
      case 'asia_boss_1_gran_dumpling':
        return phase == 1 ? granDumplingSprite : granDumplingPhase2;

      case 'asia_boss_2_vapor_spirit':
        return switch (phase) {
          1 => vaporSpiritSprite,
          2 => vaporSpiritPhase2,
          _ => vaporSpiritPhase3,
        };

      case 'asia_boss_3_mother_root':
        return switch (phase) {
          1 => motherRootSprite,
          2 => motherRootPhase2,
          _ => motherRootPhase3,
        };

      case 'asia_boss_4_stone_monk':
        return switch (phase) {
          1 => stoneMonkSprite,
          2 => stoneMonkPhase2,
          _ => stoneMonkPhase3,
        };

      case 'asia_boss_5_ancestral_dragon':
        return switch (phase) {
          1 => ancestralDragonSprite,
          2 => ancestralDragonPhase2,
          3 => ancestralDragonPhase3,
          _ => ancestralDragonPhase4,
        };

      default:
        return 'lib/assets/bosses/placeholder.png';
    }
  }
}

/// Rutas de assets necesarias (para verificación)
class BossAssetDirectories {
  static const List<String> requiredDirectories = [
    'lib/assets/bosses/gran_dumpling/',
    'lib/assets/bosses/vapor_spirit/',
    'lib/assets/bosses/mother_root/',
    'lib/assets/bosses/stone_monk/',
    'lib/assets/bosses/ancestral_dragon/',
  ];

  static const List<String> requiredFiles = [
    // Gran Dumpling
    'lib/assets/bosses/gran_dumpling/sprite.png',
    'lib/assets/bosses/gran_dumpling/phase2_angry.png',
    
    // Vapor Spirit
    'lib/assets/bosses/vapor_spirit/sprite.png',
    'lib/assets/bosses/vapor_spirit/phase2_ethereal.png',
    'lib/assets/bosses/vapor_spirit/phase3_storm.png',
    
    // Mother Root
    'lib/assets/bosses/mother_root/sprite.png',
    'lib/assets/bosses/mother_root/phase2_expanded.png',
    'lib/assets/bosses/mother_root/phase3_corrupted.png',
    
    // Stone Monk
    'lib/assets/bosses/stone_monk/sprite.png',
    'lib/assets/bosses/stone_monk/phase2_awakened.png',
    'lib/assets/bosses/stone_monk/phase3_enlightened.png',
    
    // Ancestral Dragon
    'lib/assets/bosses/ancestral_dragon/sprite.png',
    'lib/assets/bosses/ancestral_dragon/phase2_enraged.png',
    'lib/assets/bosses/ancestral_dragon/phase3_chaos.png',
    'lib/assets/bosses/ancestral_dragon/phase4_ultimate.png',
  ];

  /// Verifica si todos los assets existen
  static Future<bool> verifyAssetsExist() async {
    // TODO: Implementar verificación de archivos
    // Por ahora retorna true para permitir ejecución
    return true;
  }
}

/// Especificaciones técnicas de los sprites
class BossSpriteSpecifications {
  static const Map<String, SpriteSpec> specs = {
    'asia_boss_1_gran_dumpling': SpriteSpec(
      width: 128,
      height: 128,
      animationFrames: 8,
      frameRate: 12,
    ),
    'asia_boss_2_vapor_spirit': SpriteSpec(
      width: 120,
      height: 140,
      animationFrames: 10,
      frameRate: 15,
    ),
    'asia_boss_3_mother_root': SpriteSpec(
      width: 140,
      height: 150,
      animationFrames: 12,
      frameRate: 18,
    ),
    'asia_boss_4_stone_monk': SpriteSpec(
      width: 110,
      height: 145,
      animationFrames: 9,
      frameRate: 14,
    ),
    'asia_boss_5_ancestral_dragon': SpriteSpec(
      width: 160,
      height: 200,
      animationFrames: 14,
      frameRate: 20,
    ),
  };
}

/// Especificación de un sprite
class SpriteSpec {
  final int width;
  final int height;
  final int animationFrames;
  final int frameRate;

  const SpriteSpec({
    required this.width,
    required this.height,
    required this.animationFrames,
    required this.frameRate,
  });
}
