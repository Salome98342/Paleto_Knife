# Integración del Sistema Touhou - Guía Paso a Paso

**Status**: 📖 Documentación de integración  
**Objetivo**: Conectar `TouhouBossController` con `EnemyComponent` y el loop de juego

---

## 📋 Checklist de Integración

## Paso 1: Actualizar `EnemyComponent` (lib/game/enemies/enemy.dart)

### Cambios Requeridos:

```dart
// AGREGAR IMPORT
import '../game_logic/boss_system/touhou_boss_factory.dart';
import '../game_logic/boss_system/touhou_boss_controller.dart';
import 'package:vector_math/vector_math.dart';

class EnemyComponent extends PositionComponent {
  // ... código existente ...
  
  // ✅ AGREGAR NUEVO:
  TouhouBossController? _touhouController;
  bool _isTouhouBoss = false;

  // Modificar spawn() para soportar bosses Touhou
  void spawn(
    Vector2 spawnPos, {
    double healthMultiplier = 1.0,
    AttackPattern attackPattern = AttackPattern.standard,
    int createdAt = 0,
    bool isBoss = false,           // ← NUEVO
    String? bossType = null,       // ← NUEVO ('elegant_asian', 'caribbean')
  }) {
    position = spawnPos;
    health = (enemyType.health * healthMultiplier);
    maxHealth = health;
    
    // ✅ NUEVO BLOQUE: Detección de Boss Touhou
    if (isBoss && bossType != null) {
      _isTouhouBoss = true;
      _initializeTouhouBoss(bossType, spawnPos);
      return; // No ejecutar código de enemigo normal
    }
    
    // ... resto del código spawn() original ...
  }

  // ✅ NUEVO MÉTODO: Inicializar Boss Touhou
  void _initializeTouhouBoss(String bossType, Vector2 startPos) {
    late TouhouBossDefinition definition;
    
    // Seleccionar definición del boss
    if (bossType == 'elegant_asian') {
      definition = TouhouBossFactory.createElegantAsianBoss();
    } else if (bossType == 'caribbean') {
      definition = TouhouBossFactory.createCaribbeanBoss();
    } else {
      throw Exception('Boss type desconocido: $bossType');
    }

    // Crear controlador
    _touhouController = TouhouBossController(
      bossDefinition: definition,
      position: startPos,
    );

    // ✅ Configurar callbacks
    _touhouController!.onSpawnBullets = _onTouhouBulletsSpawn;
    _touhouController!.onPhaseChange = _onTouhouPhaseChange;
    _touhouController!.onSpellCardStart = _onTouhouSpellCardStart;
    _touhouController!.onSpellCardComplete = _onTouhouSpellCardComplete;
    _touhouController!.onBossDefeated = _onTouhouBossDefeated;

    // Usar HP del boss como salud principal
    health = definition.phase1.spellCards[0].maxHp * 1.2;
    maxHealth = health;
  }

  // ✅ NUEVOS CALLBACKS

  void _onTouhouBulletsSpawn(List<BulletData> bullets) {
    final gameRef = game;
    
    for (final bulletData in bullets) {
      // Convertir ángulo a dirección
      final direction = Vector2(
        cos(bulletData.angle),
        sin(bulletData.angle),
      );
      
      gameRef.spawnBullet(
        bulletData.position,
        direction * bulletData.speed,
        isPlayer: false,
        damage: bulletData.damage,
      );
    }
  }

  void _onTouhouPhaseChange(int phaseNumber) {
    print('🔄 Boss Fase $phaseNumber iniciada');
    // Aquí: Disparar eventos a UI, cambiar música, efectos
    game.audioManager?.playSound('phase_transition');
  }

  void _onTouhouSpellCardStart(String cardName) {
    print('✨ Spell Card: $cardName');
    // Aquí: Mostrar nombre en pantalla, efectos visuales
    game.uiManager?.showSpellCardName(cardName);
  }

  void _onTouhouSpellCardComplete() {
    print('✅ Spell Card completada');
  }

  void _onTouhouBossDefeated() {
    print('💀 Boss derrotado!');
    health = 0;
    // El onDeath() del EnemyComponent se llamará automáticamente
  }
}
```

---

## Paso 2: Actualizar `update()` para Touhou

```dart
class EnemyComponent extends PositionComponent {
  
  @override
  void update(double deltaTime) {
    // ✅ ACTUALIZACIÓN TOUHOU
    if (_isTouhouBoss && _touhouController != null) {
      final playerPos = game.playerComponent.position;
      
      _touhouController!.update(deltaTime, playerPos);
      position = _touhouController!.currentPosition;
      
      // Actualizar HP visual
      health = _touhouController!.currentHp;
      
      // No ejecutar lógica de enemigo normal
      return;
    }
    
    // ... código de enemigo normal (solo si no es Touhou)
    super.update(deltaTime);
  }
}
```

---

## Paso 3: Actualizar `takeDamage()` para Touhou

```dart
class EnemyComponent extends PositionComponent {
  
  @override
  void takeDamage(double damage, {double damageMultiplier = 1.0}) {
    // ✅ MANEJO TOUHOU
    if (_isTouhouBoss && _touhouController != null) {
      // Respetar invulnerabilidad
      if (!_touhouController!.isInvulnerable) {
        _touhouController!.takeDamage(damage, damageMultiplier: damageMultiplier);
      }
      return;
    }
    
    // ... código normal de daño...
    health -= damage * damageMultiplier;
    
    if (health <= 0) {
      onDeath();
    }
  }
}
```

---

## Paso 4: Integración en `GameplayScreen` (opcional UI)

```dart
class GameplayScreen extends StatefulWidget {
  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late PaletoGame gameRef;
  String? _currentSpellCardName;
  int _currentPhase = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ... Flame game widget ...
        PaletoGame(
          onBossCreated: (enemy) {
            // Cuando se crea un boss, obtener el controller
            if (enemy._isTouhouBoss && enemy._touhouController != null) {
              setState(() {
                _currentPhase = enemy._touhouController!.currentPhaseIndex + 1;
              });
            }
          },
        ),
        
        // ✅ Overlay UI para Spell Card
        if (_currentSpellCardName != null)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '✨ $_currentSpellCardName',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  shadows: [Shadow(blurRadius: 10)],
                ),
              ),
            ),
          ),

        // ✅ Indicador de Fase
        Positioned(
          top: 20,
          right: 20,
          child: Text(
            'FASE $_currentPhase',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## Paso 5: Crear Boss en Gameplay

### En `PaletoGame.spawnEnemy()`:

```dart
class PaletoGame extends FlameGame {
  
  void spawnEnemy({
    required EnemyType type,
    Vector2? position,
    bool isBoss = false,
  }) {
    final spawnPos = position ?? _getRandomSpawnPosition();
    final enemy = EnemyComponent(enemyType: type);
    
    // ✅ NUEVO: Soporte para bosses Touhou
    if (isBoss && [EnemyType.elegantAsian, EnemyType.caribbean].contains(type)) {
      final bossType = type == EnemyType.elegantAsian 
        ? 'elegant_asian' 
        : 'caribbean';
      
      enemy.spawn(
        spawnPos,
        isBoss: true,
        bossType: bossType,
      );
    } else {
      enemy.spawn(spawnPos);
    }
    
    add(enemy);
  }
}
```

---

## Paso 6: Tests de Integración (opcional)

```dart
// En test/boss_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:paleto_knife/game_logic/boss_system/touhou_boss_controller.dart';
import 'package:paleto_knife/game_logic/boss_system/touhou_boss_factory.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('Touhou Boss Integration', () {
    
    test('Boss se crea correctamente', () {
      final boss = TouhouBossController(
        bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
        position: Vector2(400, 150),
      );
      
      expect(boss.currentHp, greaterThan(0));
      expect(boss.currentPhaseIndex, equals(0));
    });

    test('Daño reduce HP correctamente', () {
      final boss = TouhouBossController(
        bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
        position: Vector2(400, 150),
      );
      
      final hpAntes = boss.currentHp;
      boss.takeDamage(10.0);
      
      expect(boss.currentHp, lessThan(hpAntes));
      expect(boss.currentHp, equals(hpAntes - 10.0));
    });

    test('Fase cambia al alcanzar threshold', () {
      final boss = TouhouBossController(
        bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
        position: Vector2(400, 150),
      );
      
      final initialPhase = boss.currentPhaseIndex;
      
      // Daño severo para pasar a Fase 2
      while (boss.currentHp > boss.maxHp * 0.35) {
        boss.takeDamage(50.0);
      }
      
      boss.update(0.1, Vector2(400, 200));
      
      expect(boss.currentPhaseIndex, greaterThan(initialPhase));
    });

    test('Boss es invulnerable durante transición', () {
      final boss = TouhouBossController(
        bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
        position: Vector2(400, 150),
      );
      
      // Forzar transición de fase
      while (boss.currentHp > boss.maxHp * 0.35) {
        boss.takeDamage(50.0);
      }
      
      expect(boss.isInvulnerable, true);
    });

    test('Bullets se generan en update', () {
      final boss = TouhouBossController(
        bossDefinition: TouhouBossFactory.createElegantAsianBoss(),
        position: Vector2(400, 150),
      );
      
      final bulletsSpawned = <BulletData>[];
      boss.onSpawnBullets = (bullets) {
        bulletsSpawned.addAll(bullets);
      };
      
      boss.update(0.5, Vector2(400, 200));
      
      // Después de 0.5s, debería haber balas
      expect(bulletsSpawned.isNotEmpty, true);
    });
  });
}
```

---

## 🎯 Checklist de Verificación

- [ ] `EnemyComponent` importa `TouhouBossController`
- [ ] `spawn()` acepta parámetros `isBoss` y `bossType`
- [ ] `_initializeTouhouBoss()` crea controlador correctamente
- [ ] `update()` llama a `_touhouController!.update()`
- [ ] `takeDamage()` respeta invulnerabilidad
- [ ] Callbacks están conectados (`onSpawnBullets`, `onPhaseChange`, etc)
- [ ] Las balas se spawnean en la posición correcta
- [ ] Las fases transicionan correctamente
- [ ] El boss muere cuando HP = 0
- [ ] No hay crashes o errores de null-safety

---

## 🚀 Próximos Pasos Después de Integración

1. **Testing Manual**: Spawn un boss y verifica:
   - ¿Aparecen balas?
   - ¿Se mueve el boss?
   - ¿Transiciona de fase?

2. **Balance**: Ajusta HP/daño si es muy fácil/difícil
3. **Efectos**: Agrega VFX y sonidos
4. **Más Bosses**: Crea bosses adicionales con TouhouBossFactory
5. **UI Polish**: Anima nombres de Spell Cards
