# -*- coding: utf-8 -*-
import re

with open("lib/game/paleto_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("  int enemiesToKillNextWave = 5;", "  int enemiesToKillNextWave = 15;\n  int enemiesSpawnedInWave = 0;")

new_spawn = r"""  void _spawnEnemy() {
    if (enemiesSpawnedInWave > enemiesToKillNextWave) return; // Wait for boss

    final isBoss = enemiesSpawnedInWave == enemiesToKillNextWave;
    
    try {
      final enemy = _enemyPool.firstWhere((e) => !e.isActive);
      final randomX = (math.Random().nextDouble() * (size.x - 80)) + 40;
      
      final randomAmalgam = locationData.amalgams[math.Random().nextInt(locationData.amalgams.length)];

      int patternLimit = 1;
      if (currentWave >= 3) patternLimit = 2; // Espirales
      if (currentWave >= 6) patternLimit = 3; // Radiales

      final pattern = math.Random().nextInt(patternLimit); 

      enemy.spawn(Vector2(randomX, 50), pattern, randomAmalgam, isBoss: isBoss);
      enemiesSpawnedInWave++;
    } catch (e) {
      // Ignorar
    }
  }

"""

content = re.sub(r'  void _spawnEnemy\(\) \{.*?(?=  void spawnBullet)', new_spawn, content, flags=re.DOTALL)

new_progress = r"""              // Progresion de Olas
              enemiesKilledInWave++;
              // +1 por el jefe
              if (enemiesKilledInWave >= enemiesToKillNextWave + 1) {
                currentWave++;
                enemiesKilledInWave = 0;
                enemiesSpawnedInWave = 0;
                enemiesToKillNextWave += (currentWave * 5); // Crece cant. por ola
                pauseEngine();
                overlays.add('WaveClear');
              }
"""
content = re.sub(r'              // Progresión de Olas.*?\n              \}', new_progress, content, flags=re.DOTALL)

new_reset = r"""  void resetGame() {
    currentWave = 1;
    enemiesKilledInWave = 0;
    enemiesSpawnedInWave = 0;
    enemiesToKillNextWave = 15;"""
content = re.sub(r'  void resetGame\(\) \{\n    currentWave = 1;\n    enemiesKilledInWave = 0;\n    enemiesToKillNextWave = 5;', new_reset, content)

with open("lib/game/paleto_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
