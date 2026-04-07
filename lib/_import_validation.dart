// ignore_for_file: unused_import

// Archivo para verificar que todos los imports funcionan
// Este archivo NO se usa en producción, solo para validación

// Test imports de lógica
import 'game_logic/wave_system/wave.dart';
import 'game_logic/wave_system/wave_manager.dart';
import 'game_logic/wave_system/enemy_spawn_config.dart';
import 'game_logic/enemy_system/enemy_behavior.dart';
import 'game_logic/enemy_system/attack_pattern.dart';
import 'game_logic/enemy_system/enemy_types.dart';
import 'game_logic/enemy_system/enemy_factory.dart';
import 'game_logic/boss_system/boss.dart';
import 'game_logic/boss_system/boss_phase.dart';
import 'game_logic/boss_system/boss_manager.dart';
import 'game_logic/combat_cycle.dart';

// Test imports de visuals
import 'game/components/component_enemy.dart';
import 'game/components/component_boss.dart';
import 'game/components/ui_displays.dart';
import 'game/components/combat_game_screen.dart';
import 'game/combat_game.dart';
import 'screens/combat_test_screen.dart';

// Este archivo nunca se ejecuta, solo verifica imports
void dummyFunction() {
  print('Todos los imports son válidos');
}
