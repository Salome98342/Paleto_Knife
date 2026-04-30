/// Central initialization point for the entire combat system
/// Call this once at app startup to initialize all combat catalogs

import 'enemy_system/enemy_types.dart';
import 'enemy_system/enemy_modifiers.dart';
import 'boss_system/boss_catalog.dart';

/// Initialize all combat system catalogs
/// Must be called before using any combat features
void initializeCombatSystem() {
  try {
    // Initialize element system (already in models but we reference it here semantically)
    // Elements initialize on first access in element_type.dart

    // Initialize enemy modifiers
    ModifierCatalog.initializeDefaults();

    // Initialize enemy type definitions
    EnemyTypesCatalog.initializeDefaults();

    // Initialize boss definitions
    BossCatalog.initializeDefaults();

    // Note: wave_system was removed as it duplicated PaletoGame's internal wave system
    // The game uses PaletoGame's manual wave management (currentWave, enemiesKilledInWave, etc)

    print('✅ Combat System Initialized Successfully');
    print('   - Enemy Modifiers: Ready');
    print('   - Enemy Types: ${EnemyTypesCatalog.getAll().length} enemies');
    print('   - Bosses: ${BossCatalog.getAll().length} bosses');
  } catch (e) {
    print('❌ Combat System Initialization Failed: $e');
    rethrow;
  }
}

/// Get initialization status
/// Returns true if all systems are initialized
bool isCombatSystemInitialized() {
  try {
    return EnemyTypesCatalog.getAll().isNotEmpty &&
        BossCatalog.getAll().isNotEmpty;
  } catch (e) {
    print('[ERROR] Catalog initialization failed: $e');
    return false;
  }
}

/// Get statistics about the combat system
Map<String, dynamic> getCombatSystemStats() {
  return {
    'totalEnemies': EnemyTypesCatalog.getAll().length,
    'enemiesByRegion': {
      'asia': EnemyTypesCatalog.getByRegion(Region.asia).length,
      'caribbean': EnemyTypesCatalog.getByRegion(Region.caribbean).length,
      'europe': EnemyTypesCatalog.getByRegion(Region.europe).length,
    },
    'totalBosses': BossCatalog.getAll().length,
    'modifiers': ['giant', 'armor', 'multiple'],
  };
}
