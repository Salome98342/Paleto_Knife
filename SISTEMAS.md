# 🎮 Sistemas de Juego - Paleto Knife

## Descripción Detallada de Cada Sistema

---

## ⚔️ Sistema de Combate

**Ubicación**: `lib/game_logic/combat_system/`

### Características

- **Autobattler**: Combates son automáticos basados en stats
- **Turnos**: Cada chef ataca 1 vez por turno
- **Cálculo de Daño**: Fórmula basada en ATK, DEF, elemento, multiplicadores
- **Elementos**: 8 tipos eleméntales con ventajas/desventajas

### Fórmula de Daño

```
Daño Base = ATK del Atacante - DEF del Defensor
Daño Final = Daño Base × Modificador de Elemento × Modificador de Enemigo
```

### Modificadores de Enemigo

| Modificador | Efecto |
|------------|--------|
| **Resist** | Reduce daño recibido en 20% |
| **Strong** | Aumenta daño que hace en 25% |
| **Weak** | Aumenta daño recibido en 30% |
| **Armor** | Cada turno absorbe daño (como escudo) |

### Ventajas de Elemento

**Ciclo de Ventaja**:
- 🔥 Fuego > 🌱 Planta > 💧 Agua > 🔥 Fuego
- 🪨 Tierra > 💨 Viento > 🪨 Tierra
- 🌋 Lava > 🌊 Agua
- ⚪ Neutral : Sin ventaj/desventaja
- 👑 Maestro : ×1.5 daño contra todo

### Archivo Principal

**`combat_system.dart`**:
```dart
class CombatSystem {
  static int calculateDamage(Chef attacker, Enemy defender) {
    // Lógica de cálculo de daño
  }
  
  static bool checkElementAdvantage(ElementType atk, ElementType def) {
    // Verifica ventaja elemental
  }
  
  static int applyModifiers(int damage, EnemyModifier mod) {
    // Aplica modificadores de enemigo
  }
}
```

---

## 👥 Sistema de Chefs

**Ubicación**: `lib/models/chef.dart`, `lib/controllers/chef_controller.dart`

### Atributos de un Chef

| Atributo | Descripción |
|----------|------------|
| **ID** | Identificador único |
| **Nombre** | Nombre del sous chef |
| **Rareza** | Common → Epic → Legendary |
| **Nivel** | 1-100 (aumenta con XP) |
| **ATK** | Ataque |
| **DEF** | Defensa |
| **HP** | Health Points |
| **XP** | Experiencia actual |
| **Elemento** | Su tipo elemental |
| **Equipo** | Armas, armadura, accesorios asignados |
| **Técnicas** | Habilidades especiales |

### Sistema de Rareza

| Rareza | Probabilidad | Stats Base |
|--------|------------|----------|
| 🟦 Common | 60% | Bajos |
| 🟩 Uncommon | 25% | Medios |
| 🟪 Rare | 10% | Altos |
| 🟨 Epic | 4% | Muy Altos |
| 🟥 Legendary | 1% | Máximos |

### Crecimiento de Stats

- **Nivel**: Aumenta por XP ganada en combate
- **ATK/DEF**: Aumentan con equipo y mejoras
- **HP**: Aumenta con nivel y defensa

---

## 🎲 Sistema de Gacha

**Ubicación**: `lib/screens/gacha_store_view.dart`, `lib/models/gacha_result.dart`

### Mecánica

1. **Costo**: Gemas (moneda premium)
2. **Tasas**: 
   - Common: 60%
   - Uncommon: 25%
   - Rare: 10%
   - Epic: 4%
   - Legendary: 1%
3. **Pity System**: Garantía después de N tiradas sin legendary
4. **Animación**: Revelación visual del resultado

### Probabilidades por Ruta

**Pull Único**:
- Costo: 100 Gemas
- 1 Chef aleatorio

**Pull Multi (10x)**:
- Costo: 900 Gemas (11% de descuento)
- 10 Chefs
- Garantiza al menos 1 Rare+

---

## 🌍 Sistema de Mundo

**Ubicación**: `lib/models/world.dart`, `lib/controllers/world_controller.dart`

### Estructura del Mapa

```
Asia (Región 1)
├── Locación 1
├── Locación 2
└── Locación 3
    └── Boss: [Boss Asiático]

Caribbean (Región 2)
├── Locación 1
├── Locación 2
└── Locación 3
    └── Boss: [Boss Caribeño]

Europe (Región 3)
├── Locación 1
├── Locación 2
└── Locación 3
    └── Boss: [Boss Europeo]
```

### Locaciones

Cada locación tiene:
- **Nombre** (ej: "Tokio", "Miami", "París")
- **Elemento recomendado** (tipo para ventaja)
- **Color asociado** (visual)
- **Enemigos comunes** (lista de 5-8 enemigos)
- **Enemy modifier** (Resist, Strong, etc.)
- **Reward** (Oro, XP, Gemas)
- **Is Alert** (Indicador de boss)

### Bosses (3 Total)

| Boss | Región | Nivel | Modificadores |
|------|--------|-------|---------------|
| Boss #1 | Asia | 25+ | Strong, Armor |
| Boss #2 | Caribbean | 40+ | Weak, Strong |
| Boss #3 | Europe | 60+ | Armor, Strong, Resist |

---

## 🌊 Sistema de Olas (Waves)

**Ubicación**: `lib/game_logic/wave_system/`

### Progresión

1. **Ola 1-2**: Enemigos comunes (1-2 enemigos)
2. **Ola 3-4**: Enemigos más fuertes (2-3 enemigos)
3. **Ola 5-6**: Enemigos fuertes (3 enemigos)
4. **Ola 7**: Boss de la región (1 boss fuerte)

### Generación de Olas

```dart
class WaveManager {
  Wave generateWave(int waveNumber, Region region) {
    if (waveNumber < 7) {
      // Enemigos comunes
      return Wave(enemies: getCommonEnemies(region, waveNumber));
    } else {
      // Boss
      return Wave(enemies: [getBoss(region)]);
    }
  }
}
```

---

## 💰 Sistema de Economía

**Ubicación**: `lib/controllers/economy_controller.dart`

### Monedas

| Moneda | Uso | Obtención |
|--------|-----|-----------|
| 💛 **Gold** | Mejoras, revives | Combate, misiones |
| 💎 **Gems** | Gacha, pases premium | Compra, eventos |
| ⭐ **XP** | Nivel del jugador | Combate, misiones |

### Conversión

- **1 Gema** = ~10 Gold (para referencia)
- **Gacha 1x** = 100 Gems
- **Gacha 10x** = 900 Gems
- **Mejora promedio** = 500-5000 Gold

### Rewards por Combate

```dart
// Después de ganar un combate:
Gold: enemyLevel * 10
XP: enemyLevel * 5
Gems: waveBonus (solo si completa todo)
```

---

## 🔊 Sistema de Audio

**Ubicación**: `lib/services/audio_service.dart`

### Características

- **BGM (Background Music)**: Música ambiental
  - Menu Theme
  - Gameplay Theme
  - Boss Battle Theme
  
- **SFX (Sound Effects)**: Efectos cortos
  - attack.mp3
  - heal.mp3
  - defeat.mp3
  - victory.mp3
  - ui_click.mp3

### Control

```dart
final audio = context.read<AudioService>();

// Música
audio.playBGM('menu_song');
audio.setBgmVolume(0.8);  // 0.0 - 1.0
audio.toggleMusic();

// Efectos
audio.playSFX('attack');
audio.setSfxVolume(0.9);  // 0.0 - 1.0
audio.toggleSfx();
```

### Arquitectura

```
AudioService (ChangeNotifier)
├── _audioPlayer: AudioPlayer
├── _bgmPlayer: AudioPlayer
├── _sfxPlayers: List<AudioPlayer>
├── bgmVolume: double
├── sfxVolume: double
└── methods: playBGM(), playSFX(), setVolume()
```

---

## 💾 Sistema de Almacenamiento

**Ubicación**: `lib/services/storage_service.dart`

### Qué se Guarda

- Progreso del jugador
- Inventario de chefs
- Equipo
- Monedas
- Estadísticas

### Métodos

```dart
class StorageService {
  Future<void> saveGameState(GameState state);
  Future<GameState> loadGameState();
  Future<void> clearData();
}
```

### Tecnología

- **SharedPreferences**: Para clave-valor simple (datos persistentes)
- **Serialización**: JSON para estructura compleja

---

## 🎯 Sistema de Misiones

**Ubicación**: `lib/screens/quests_view.dart`

### Tipos de Misiones

| Tipo | Descripción | Refresh |
|------|-----------|---------|
| **Daily** | Misiones diarias simples | Cada día |
| **Special** | Objetivos únicos | Una vez |
| **Challenge** | Desafíos difíciles | Semanalmente |

### Estructura Misión

```dart
class Quest {
  String id;
  String title;
  String description;
  QuestType type;
  int targetValue;        // ej: "Derrota 10 enemigos"
  int currentProgress;
  List<Reward> rewards;
  bool isCompleted;
}
```

### Rewards por Misión

- Gold
- XP
- Gems (raro)
- Equipo especial (muy raro)

---

## 📊 Sistema de Enemigos

**Ubicación**: `lib/game_logic/enemy_system/enemy_types.dart`

### 21 Enemigos Disponibles

**Grupo Fuego (5)**:
1. Flame Sprite (Básico)
2. Inferno Dragon (Fuerte)
3. Lava Beast
4. Phoenix
5. Emberking (Boss)

**Grupo Agua (4)**:
1. Water Elemental
2. Aquatic Beast
3. Tidal Leviathan
4. Tsunami (Boss)

**Grupo Tierra (4)**:
1. Stone Golem
2. Earth Crawler
3. Crystal Sentinel
4. Mountain Titan (Boss)

**Grupo Viento (3)**:
1. Wind Sprite
2. Tornado Vortex
3. Storm Lord (Boss)

**Grupo Lava (2)**:
1. Magma Elemental
2. Volcano Golem

**Grupo Planta (2)**:
1. Vine Creature
2. Forest Guardian

**Grupo Neutral (1)**:
1. Common Slime

### Estadísticas Base por Nivel

```dart
int calculateEnemyHP(int level) => 20 + (level * 2);
int calculateEnemyATK(int level) => 5 + (level * 1.5);
int calculateEnemyDEF(int level) => 2 + level;
```

---

## 🛠️ Sistema de Equipo

**Ubicación**: `lib/models/equipment.dart`

### Tipos de Equipo

| Tipo | Bonificación |
|------|-------------|
| **Espada** | +ATK |
| **Armadura** | +DEF |
| **Anillo** | +HP |
| **Gema** | +ATK o +DEF |

### Rareza de Equipo

- Common (Stats bajos)
- Uncommon (Stats medios)
- Rare (Stats altos)
- Epic (Stats muy altos + bonus passive)
- Legendary (Stats máximos + bonus único)

### Sistema de Mejora

```
Equipo Nivel 1 → Equipo Nivel 2 (costo: Gold)
Equipo Nivel 2 → Equipo Nivel 3 (costo: Gold + Material)
```

---

## ⚙️ Sistema de Técnicas

**Ubicación**: `lib/models/technique.dart`

### Tipos de Técnicas

| Tipo | Efecto |
|------|--------|
| **Ataque** | Daño aumentado 150% en turno |
| **Defensa** | Absorbe 50% del daño siguiente |
| **Soporte** | Cura 30% HP a aliado |
| **Control** | Paralyze enemigo 1 turno |

### Mecánica de Uso

- Cada chef puede aprender 1-3 técnicas
- Técnica usa cooldown (cada N turnos)
- Se aprenden en combate o a traves de entrenamiento

---

## 📱 Sistema de Notificaciones

**Ubicación**: `lib/widgets/notifications/`

Realtime notificaciones para:
- Misión completada
- Reward obtenido
- Chef nuevo en gacha
- Evento especial

---

## 🎨 Sistema Visual

**ubicación**: `lib/widgets/retro_style.dart`

### Tema Retro

- **Colores**: Paleta de 8-bit limitada
- **Fuente**: Press Start 2P (pixel art)
- **Bordes**: Bordes gruesos estilo retro
- **Animaciones**: Fade, Scale, Slide (flutter_animate)

---

Última actualización: Abril 2026
