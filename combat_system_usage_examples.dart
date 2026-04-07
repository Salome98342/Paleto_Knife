// ignore_for_file: unused_import, unused_local_variable, null_comparison, unnecessary_null_comparison, dead_code

import 'lib/game_logic/combat_system_initializer.dart';
import 'lib/game_logic/enemy_system/enemy_types.dart';
import 'lib/game_logic/enemy_system/enemy_factory.dart';
import 'lib/game_logic/wave_system/wave_catalog.dart';
import 'lib/game_logic/boss_system/boss_catalog.dart';

/// Real-world usage example demonstrating the combat system in a game context
/// This shows how CombatGameScreen and other game components would use the system

void main() {
  print('🎮 COMBAT SYSTEM USAGE EXAMPLES\n');

  // Initialize system (done once in main.dart)
  initializeCombatSystem();
  
  // Example 1: Starting a combat encounter
  print('━' * 60);
  print('EXAMPLE 1: Starting Combat in a Region');
  print('━' * 60);
  
  startRegionalCombat('asia');
  
  // Example 2: Creating individual enemies
  print('\n━' * 60);
  print('EXAMPLE 2: Creating Custom Enemies');
  print('━' * 60);
  
  createAndDisplayEnemy('dumpling_coloso');
  
  // Example 3: Starting a boss fight
  print('\n━' * 60);
  print('EXAMPLE 3: Starting Boss Fight');
  print('━' * 60);
  
  initiateBossFight('gran_dumpling_ancestral');
  
  // Example 4: Getting wave progressions
  print('\n━' * 60);
  print('EXAMPLE 4: Wave Progression System');
  print('━' * 60);
  
  displayWaveProgression('caribbean');
  
  print('\n✅ ALL USAGE EXAMPLES COMPLETED SUCCESSFULLY\n');
}

/// Example 1: How CombatGameScreen would start regional combat
void startRegionalCombat(String region) {
  print('\n📍 Starting combat in: $region');
  
  try {
    // Get all waves for this region
    final waves = WaveCatalog.getWaveSet(region);
    print('   ✓ Loaded ${waves.length} waves');
    
    // Show enemy spawns for first wave
    if (waves.isNotEmpty) {
      final firstWave = waves[0];
      print('   ✓ Wave 1 spawns:');
      for (var spawn in firstWave.enemySpawns) {
        print('      - ${spawn.enemyType}: x${spawn.quantity} (pattern: ${spawn.spawnPattern})');
      }
    }
    
    print('   ✓ Combat ready - enemies can begin spawning');
    print('   ✓ Wave manager can now track progression');
    
  } catch (e) {
    print('   ❌ Failed to start combat: $e');
  }
}

/// Example 2: Creating individual enemies with modifiers
void createAndDisplayEnemy(String enemyId) {
  print('\n📍 Creating enemy: $enemyId');
  
  try {
    // Get enemy definition
    final enemyDef = EnemyTypesCatalog.get(enemyId);
    print('   ✓ Enemy: ${enemyDef.name}');
    print('   ✓ Element: ${enemyDef.element.displayName}');
    print('   ✓ Lore: ${enemyDef.lore}');
    print('   ✓ Role: ${enemyDef.role}');
    print('   ✓ Base HP: ${enemyDef.baseHealth}');
    print('   ✓ Counters: ${enemyDef.counters.join(", ")}');
    
    // Show how to create with modifiers
    print('\n   Creating with Giant modifier:');
    print('      - Base HP: ${enemyDef.baseHealth}');
    print('      - Giant multiplier: x2.0');
    print('      - Final HP: ${enemyDef.baseHealth * 2.0}');
    print('      - Visual scale: 1.5x');
    
  } catch (e) {
    print('   ❌ Failed to create enemy: $e');
  }
}

/// Example 3: Starting a boss encounter
void initiateBossFight(String bossId) {
  print('\n📍 Starting boss fight: $bossId');
  
  try {
    // Get boss definition
    final boss = BossCatalog.get(bossId);
    print('   ✓ Boss: ${boss.name}');
    print('   ✓ Base HP: ${boss.baseHealth}');
    print('   ✓ Region: ${boss.region.name}');
    print('   ✓ Element: ${boss.element.displayName}');
    print('   ✓ Number of phases: ${boss.phases.length}');
    
    // Show phase progression
    print('\n   Phase Progression:');
    double hpThreshold = 100;
    for (int i = 0; i < boss.phases.length; i++) {
      final phase = boss.phases[i];
      print('      Phase ${i + 1} (@${phase.hpThreshold * 100}% HP):');
      print('         - Behavior: ${phase.behavior}');
      print('         - Attack patterns: ${phase.attackPatterns.length}');
      print('         - Attack speed: ${phase.attackSpeedMultiplier}x');
    }
    
    print('\n   ✓ Boss encounter ready');
    
  } catch (e) {
    print('   ❌ Failed to start boss fight: $e');
  }
}

/// Example 4: Displaying wave progression
void displayWaveProgression(String region) {
  print('\n📍 Wave progression for $region:');
  
  try {
    final waves = WaveCatalog.getWaveSet(region);
    
    for (int i = 0; i < waves.length; i++) {
      final wave = waves[i];
      final isBossWave = i == waves.length - 1;
      
      print('   Wave ${i + 1}${isBossWave ? ' (BOSS)' : ''}:');
      
      int totalEnemies = 0;
      for (var spawn in wave.enemySpawns) {
        print('      - ${spawn.enemyType} x${spawn.quantity} (${spawn.spawnPattern})');
        totalEnemies += spawn.quantity;
      }
      
      print('      Total enemies: $totalEnemies');
      print('      Difficulty: ${wave.difficultyMultiplier}x');
    }
    
  } catch (e) {
    print('   ❌ Failed to display waves: $e');
  }
}
