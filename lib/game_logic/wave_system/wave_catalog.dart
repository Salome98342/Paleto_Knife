import 'wave.dart';
import 'enemy_spawn_config.dart';

/// Catálogo de oleadas predefinidas por región
class WaveCatalog {
  static final Map<String, List<Wave>> _waveSets = {};

  /// Registra un conjunto de oleadas para una región
  static void registerWaveSet(String regionId, List<Wave> waves) {
    _waveSets[regionId] = waves;
  }

  /// Obtiene el conjunto de oleadas de una región
  static List<Wave> getWaveSet(String regionId) {
    return _waveSets[regionId] ?? [];
  }

  /// Obtiene todas las regiones disponibles
  static List<String> getAvailableRegions() => _waveSets.keys.toList();

  /// Limpia el catálogo
  static void clear() => _waveSets.clear();

  /// Inicializa los conjuntos de oleadas
  static void initializeDefaults() {
    clear();

    // ============================================================
    // 🌏 ASIA - Dumpling Coloso Boss
    // ============================================================
    registerWaveSet('asia', [
      // Wave 1: Introducción
      Wave(
        id: 'asia_wave_1',
        waveNumber: 1,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'gyoza_errante',
            quantity: 3,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.2,
          ),
        ],
        difficultyMultiplier: 1.0,
        description: 'Introducción suave con Gyozas',
      ),

      // Wave 2: Primeras tandas
      Wave(
        id: 'asia_wave_2',
        waveNumber: 2,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'gyoza_errante',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.4,
          ),
          EnemySpawnConfig(
            enemyType: 'bola_harina_maldita',
            quantity: 4,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.1,
          ),
        ],
        difficultyMultiplier: 1.1,
        description: 'Mezcla de Gyozas y Bolas de Harina',
      ),

      // Wave 3: Presión
      Wave(
        id: 'asia_wave_3',
        waveNumber: 3,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'bola_harina_maldita',
            quantity: 6,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.15,
          ),
          EnemySpawnConfig(
            enemyType: 'totem_vapor',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
        ],
        difficultyMultiplier: 1.2,
        description: 'Presión aumenta: Más bolas y primer Tótem',
      ),

      // Wave 4: Dificultad
      Wave(
        id: 'asia_wave_4',
        waveNumber: 4,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'totem_vapor',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 2.0,
          ),
          EnemySpawnConfig(
            enemyType: 'dumpling_coloso',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'gyoza_errante',
            quantity: 3,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.5,
          ),
        ],
        difficultyMultiplier: 1.3,
        description: 'Primer tanque: El Dumpling Coloso',
      ),

      // Wave 5: Caos
      Wave(
        id: 'asia_wave_5',
        waveNumber: 5,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'raiz_hereje',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'bola_harina_maldita',
            quantity: 5,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.2,
          ),
          EnemySpawnConfig(
            enemyType: 'totem_vapor',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
        ],
        difficultyMultiplier: 1.4,
        description: 'Elite aparece: ¡Prepárate para el Jefe!',
      ),

      // BOSS WAVE
      Wave(
        id: 'asia_boss_wave',
        waveNumber: 6,
        spawns: [], // Sin enemigos menores, solo el boss
        isBossWave: true,
        difficultyMultiplier: 1.5,
        description: 'BOSS: Gran Dumpling Ancestral',
      ),
    ]);

    // ============================================================
    // 🌊 CARIBE - Rey Jerk Volcánico Boss
    // ============================================================
    registerWaveSet('caribbean', [
      // Wave 1: Fuego inicial
      Wave(
        id: 'caribbean_wave_1',
        waveNumber: 1,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'brasa_viva',
            quantity: 4,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.1,
          ),
        ],
        difficultyMultiplier: 1.0,
        description: 'Introducción: Brasas Vivas',
      ),

      // Wave 2: Intensidad
      Wave(
        id: 'caribbean_wave_2',
        waveNumber: 2,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'brasa_viva',
            quantity: 3,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.3,
          ),
          EnemySpawnConfig(
            enemyType: 'jerk_infernal',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
        ],
        difficultyMultiplier: 1.1,
        description: 'Primer Jerk Infernal',
      ),

      // Wave 3: Presión creciente
      Wave(
        id: 'caribbean_wave_3',
        waveNumber: 3,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'parrillero_maldito',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 1.5,
          ),
          EnemySpawnConfig(
            enemyType: 'brasa_viva',
            quantity: 5,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.15,
          ),
        ],
        difficultyMultiplier: 1.2,
        description: 'Parrilleros controlando el fuego',
      ),

      // Wave 4: Dominio
      Wave(
        id: 'caribbean_wave_4',
        waveNumber: 4,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'bestia_ahumada',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'jerk_infernal',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 2.0,
          ),
          EnemySpawnConfig(
            enemyType: 'parrillero_maldito',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
        ],
        difficultyMultiplier: 1.3,
        description: 'Tank caribeño: Bestia Ahumada',
      ),

      // Wave 5: Final
      Wave(
        id: 'caribbean_wave_5',
        waveNumber: 5,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'espiritu_picante',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'bestia_ahumada',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'brasa_viva',
            quantity: 6,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.2,
          ),
        ],
        difficultyMultiplier: 1.4,
        description: 'Elite del Caribe: ¡Casi listo para el Boss!',
      ),

      // BOSS WAVE
      Wave(
        id: 'caribbean_boss_wave',
        waveNumber: 6,
        spawns: [],
        isBossWave: true,
        difficultyMultiplier: 1.5,
        description: 'BOSS: Rey Jerk Volcánico',
      ),
    ]);

    // ============================================================
    // 🌿 EUROPA - Leviatán de Caldo Boss
    // ============================================================
    registerWaveSet('europe', [
      // Wave 1: Agua inicial
      Wave(
        id: 'europe_wave_1',
        waveNumber: 1,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'sopa_abisal',
            quantity: 5,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.1,
          ),
        ],
        difficultyMultiplier: 1.0,
        description: 'Introducción: Sopas Abisales',
      ),

      // Wave 2: Variedad
      Wave(
        id: 'europe_wave_2',
        waveNumber: 2,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'masa_fluvial',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.5,
          ),
          EnemySpawnConfig(
            enemyType: 'sopa_abisal',
            quantity: 3,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.15,
          ),
        ],
        difficultyMultiplier: 1.1,
        description: 'Mezcla de Sopas y Masas Fluviales',
      ),

      // Wave 3: Presión
      Wave(
        id: 'europe_wave_3',
        waveNumber: 3,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'lancero_caldo',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 1.8,
          ),
          EnemySpawnConfig(
            enemyType: 'sopa_abisal',
            quantity: 4,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.2,
          ),
        ],
        difficultyMultiplier: 1.2,
        description: 'Lanceros atacan desde lejos',
      ),

      // Wave 4: Resistencia
      Wave(
        id: 'europe_wave_4',
        waveNumber: 4,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'golem_salmuera',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'lancero_caldo',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 2.0,
          ),
          EnemySpawnConfig(
            enemyType: 'masa_fluvial',
            quantity: 2,
            spawnPattern: 'stream',
            delayBetweenSpawns: 0.6,
          ),
        ],
        difficultyMultiplier: 1.3,
        description: 'Tank europeo: Gólem de Salmuera',
      ),

      // Wave 5: Caos acuático
      Wave(
        id: 'europe_wave_5',
        waveNumber: 5,
        spawns: [
          EnemySpawnConfig(
            enemyType: 'druida_corrupto',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'golem_salmuera',
            quantity: 1,
            spawnPattern: 'burst',
            delayBetweenSpawns: 0.0,
          ),
          EnemySpawnConfig(
            enemyType: 'sopa_abisal',
            quantity: 6,
            spawnPattern: 'circle',
            delayBetweenSpawns: 0.2,
          ),
        ],
        difficultyMultiplier: 1.4,
        description: 'Elite de Europa: ¡El Leviatán está cerca!',
      ),

      // BOSS WAVE
      Wave(
        id: 'europe_boss_wave',
        waveNumber: 6,
        spawns: [],
        isBossWave: true,
        difficultyMultiplier: 1.5,
        description: 'BOSS: Leviatán de Caldo',
      ),
    ]);
  }
}
