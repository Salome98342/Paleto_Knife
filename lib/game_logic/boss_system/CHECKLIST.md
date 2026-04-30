# ✅ Checklist Visual - Sistema Touhou Boss

**Para imprimir y tener a lado mientras integras**

---

## 📋 FASE 1: PRE-INTEGRACIÓN

### Lectura Requerida
- [ ] Lei QUICK_REFERENCE.md (5 min)
- [ ] Lei INTEGRATION_STEPS.md (Paso 1-2)
- [ ] Entendí qué es TouhouBossController

### Verificación de Archivos
- [ ] ✅ bullet_emitter.dart existe
- [ ] ✅ touhou_spell_card.dart existe
- [ ] ✅ boss_movement.dart existe
- [ ] ✅ touhou_boss_factory.dart existe
- [ ] ✅ touhou_boss_controller.dart existe

### Setup Inicial
- [ ] Abrí EnemyComponent.dart en editor
- [ ] Preparé los cambios en un branch git
- [ ] Tengo terminal lista para compilar

---

## 📝 FASE 2: ACTUALIZAR EnemyComponent

### Agregar Imports
```dart
import 'boss_system/touhou_boss_factory.dart';
import 'boss_system/touhou_boss_controller.dart';
```
- [ ] ✅ Imports agregados

### Actualizar Clase
```dart
class EnemyComponent extends PositionComponent {
  TouhouBossController? _touhouController;
  bool _isTouhouBoss = false;
  
  void _initializeTouhouBoss(String bossType, Vector2 startPos) {
    // ... código de INTEGRATION_STEPS.md ...
  }
}
```
- [ ] ✅ Variables agregadas
- [ ] ✅ Método _initializeTouhouBoss() creado
- [ ] ✅ Callbacks configurados

### Modificar spawn()
- [ ] Parámetro `isBoss` agregado
- [ ] Parámetro `bossType` agregado
- [ ] Bloque `if (isBoss && bossType != null)` agregado
- [ ] _initializeTouhouBoss() llamado correctamente

### Modificar update()
```dart
if (_isTouhouBoss && _touhouController != null) {
  _touhouController!.update(deltaTime, playerPos);
  position = _touhouController!.currentPosition;
  return;
}
```
- [ ] ✅ Bloque Touhou update agregado
- [ ] ✅ Return statement evita doble update

### Modificar takeDamage()
```dart
if (_isTouhouBoss && _touhouController != null) {
  if (!_touhouController!.isInvulnerable) {
    _touhouController!.takeDamage(damage, multiplier);
  }
  return;
}
```
- [ ] ✅ Respeta invulnerabilidad
- [ ] ✅ Daño aplicado correctamente

---

## 🧪 FASE 3: TESTING BÁSICO

### Compilar
```bash
flutter clean
flutter pub get
flutter run
```
- [ ] ✅ Compila sin errores
- [ ] ✅ No hay warnings de tipo
- [ ] ✅ App inicia correctamente

### Prueba Manual
- [ ] Spawn boss: `spawnEnemy(type: EnemyType.elegantAsian, isBoss: true)`
- [ ] ✅ Boss aparece en pantalla
- [ ] ✅ Boss está en posición correcta

### Verificar Movimiento
- [ ] ✅ Boss se mueve (waypoints activos)
- [ ] ✅ Posición se actualiza cada frame
- [ ] ✅ No hay jitter o saltos

### Verificar Balas
- [ ] ✅ Balas spawnan en pantalla
- [ ] ✅ Balas tienen velocidad correcta
- [ ] ✅ Balas no están todas en una posición

### Verificar Fases
- [ ] Aplicar daño masivo (debug)
- [ ] ✅ Fase cambia en 70% HP
- [ ] ✅ Efecto visual de transición
- [ ] ✅ Boss es invulnerable 1.5s

### Verificar Derrota
- [ ] Reducir HP a 0
- [ ] ✅ Boss desaparece
- [ ] ✅ onBossDefeated() se dispara
- [ ] ✅ Juego continúa sin crash

---

## 🎛️ FASE 4: BALANCE

### Dificultad Fase 1
- [ ] Playtest 2-3 minutos
- [ ] ¿Muy fácil? → Aumentar `bulletCount` o `bulletSpeed`
- [ ] ¿Muy difícil? → Disminuir o aumentar HP
- [ ] ✅ Siento que está balanceado

### Dificultad Fase 2
- [ ] __Transición suave desde Fase 1
- [ ] ✅ Notoriamente más difícil que Fase 1
- [ ] ✅ No imposible en Fase 2

### Dificultad Fase 3
- [ ] ✅ Boss final épico pero justo
- [ ] ✅ Patrón final es memorable
- [ ] ✅ Derrota es satisfactoria

### Ajustes Realizados
- [ ] bulletCount: `_____` → `_____`
- [ ] bulletSpeed: `_____` → `_____`
- [ ] fireRate: `_____` → `_____`
- [ ] Phase HP mult: `_____` → `_____`

---

## 🎨 FASE 5: PULIDO (OPCIONAL)

### Efectos Visuales
- [ ] ✅ Explosión en derrota
- [ ] ✅ Flash en transición de fase
- [ ] ✅ Partículas al spawnar balas

### Efectos Sonoros
- [ ] ✅ Sonido de transición de fase
- [ ] ✅ Sonido de spell card start
- [ ] ✅ Sonido final cuando muere

### UI
- [ ] ✅ Nombre de Spell Card mostrado
- [ ] ✅ Número de fase visible
- [ ] ✅ Barra de HP actualiza correctamente
- [ ] ✅ Invulnerabilidad visual clara

---

## 📊 FASE 6: VALIDACIÓN FINAL

### Testing Completo
- [ ] ✅ Boss spawns correctamente
- [ ] ✅ Fase 1 es jugable
- [ ] ✅ Transición a Fase 2 funciona
- [ ] ✅ Fase 2 es más difícil
- [ ] ✅ Transición a Fase 3 funciona
- [ ] ✅ Fase 3 es final épico
- [ ] ✅ Boss muere al llegar 0 HP
- [ ] ✅ No hay crashes

### Checks de Calidad
- [ ] ✅ Código compila sin warnings
- [ ] ✅ Null-safety es 100%
- [ ] ✅ No hay memory leaks (Dart GC)
- [ ] ✅ Performance aceptable (60 FPS)

### Documentation
- [ ] ✅ Actualicé comentarios en código
- [ ] ✅ Documenté cambios en git
- [ ] ✅ Creé PR con descripción

---

## 🚀 FASE 7: EXTENSIÓN (FUTURO)

### Crear Nuevo Boss
- [ ] Lei CUSTOM_BOSS_EXAMPLES.md
- [ ] Lei template generic
- [ ] Creé nuevo boss en factory
- [ ] Testeé nuevo boss
- [ ] ✅ Funciona igual que Elegant Asian

### Más Bosses
- [ ] Boss 3: _____________________
- [ ] Boss 4: _____________________
- [ ] Boss 5: _____________________

### Features Avanzadas
- [ ] Focus Mode (hitbox pequeño)
- [ ] Bomb System (clear + penalty)
- [ ] Score Multipliers
- [ ] Boss Rush Mode

---

## 💡 TIPS Y NOTAS

### Si No Spawnan Balas
1. Verifica callback `onSpawnBullets` está conectado
2. Verifica que `game.spawnBullet()` existe
3. Debug: `print()` en onSpawnBullets
4. Check: ¿BulletEmitterCluster tiene emitters?

### Si Boss No Se Mueve
1. Verifica `BossMovementSystem` inicializado
2. Verifica `waypointsPattern` no está vacío
3. Debug: print currentPosition en update
4. Check: ¿moveSystem.update() se llama?

### Si Fases No Cambian
1. Verifica `damageMultiplier` en cada fase
2. Verifica thresholds: 0.70, 0.35, 0.0
3. Debug: print currentPhaseIndex
4. Check: ¿HP se reduce?

### Si Hay Crashes
1. Check null-safety (? vs !)
2. Verifica imports están correctos
3. Busca casting incorrecto
4. Ver stack trace en terminal

---

## 📱 CHEATSHEET RÁPIDA

### Crear Boss en Gameplay
```dart
final definition = TouhouBossFactory.createElegantAsianBoss();
spawnEnemy(bossType: definition, isBoss: true);
```

### Ver Estado Boss
```dart
print('HP: ${_touhouController?.currentHp}');
print('Phase: ${_touhouController?.currentPhaseIndex}');
print('Invulnerable: ${_touhouController?.isInvulnerable}');
```

### Hacer Debug
```dart
// En takeDamage
print('Damage: $damage, Boss HP: $_bossHp');

// En update
print('Position: ${position.x}, ${position.y}');

// En onSpawnBullets
print('Bullets spawned: ${bullets.length}');
```

### Patrones de Balance Rápido

**Más Fácil (50%):**
```dart
bulletCount = 8
bulletSpeed = 150.0
fireRate = 0.5
```

**Normal (100%):**
```dart
bulletCount = 12
bulletSpeed = 200.0
fireRate = 0.3
```

**Más Difícil (150%):**
```dart
bulletCount = 18
bulletSpeed = 280.0
fireRate = 0.2
```

---

## 📞 REFERENCIA DE ARCHIVOS

| Archivo | Para Qué |
|---------|----------|
| INTEGRATION_STEPS.md | Pasos exactos (copia código) |
| QUICK_REFERENCE.md | Snippets listos (copy-paste) |
| TOUHOU_SYSTEM_GUIDE.md | Entender cómo funciona |
| CUSTOM_BOSS_EXAMPLES.md | Crear nuevo boss |
| ARCHITECTURE_DIAGRAM.md | Ver diagramas |
| README.md | Descripción general |

---

## ⏱️ TIEMPO ESTIMADO

| Fase | Tiempo |
|------|--------|
| Pre-integración | 15 min |
| Actualizar código | 45 min |
| Testing básico | 30 min |
| Balance | 60 min |
| Pulido (opcional) | 120 min |
| **Total** | **~2.5 horas** |

---

## ✨ CELEBRACIÓN

- [ ] ✅ Boss spawns
- [ ] ✅ Balas generan
- [ ] ✅ Fases cambian
- [ ] ✅ Boss muere

**🎉 ¡INTEGRACIÓN COMPLETADA! 🎉**

---

**Próximo paso:** Lee [CUSTOM_BOSS_EXAMPLES.md](CUSTOM_BOSS_EXAMPLES.md) para crear tus propios bosses.

**Soporte:** Si hay problemas, check [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) flujos de datos.
