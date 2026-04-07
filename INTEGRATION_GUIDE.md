# 🎮 INTEGRACIÓN VISUAL - PASO A PASO

## 1️⃣ IMPORTA en main.dart

```dart
import 'screens/combat_test_screen.dart';

void main() async {
  // ... tu código existente ...
  
  runApp(
    MultiProvider(
      providers: [
        // ... providers existentes ...
      ],
      child: const KnifeClickerApp(),
    ),
  );
}

class KnifeClickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // ... tus otras rutas ...
        '/combat': (context) => const CombatTestScreen(),
      },
    );
  }
}
```

## 2️⃣ NAVEGA a la pantalla

```dart
// Desde cualquier botón o pantalla
Navigator.pushNamed(context, '/combat');

// O con argumentos
Navigator.of(context).pushNamed('/combat');
```

## 3️⃣ QUÉ VES

- **Oleadas progresivas** (Wave 1, 2, 3)
- **Enemigos** que spawnean con animaciones
- **Boss** que llega después de todas las oleadas
- **UI** mostrando estado en tiempo real
- **Botones** para Pausar, Reanudar, Reiniciar

---

## Alternativa: Integrar directamente en tu GameScreen

Si ya tienes un GameScreen de Flame:

```dart
import 'game/combat_game.dart';

class MyGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: CombatGame()),
    );
  }
}
```

---

## Archivos de Referencia

### Lógica (Para entender el flujo)
- `lib/game_logic/combat_cycle.dart` - Orquestador
- `lib/game_logic/wave_system/wave_manager.dart` - Oleadas
- `lib/game_logic/enemy_system/enemy_factory.dart` - Enemigos
- `lib/game_logic/boss_system/boss_manager.dart` - Bosses

### Visuals (Lo que renderiza)
- `lib/game/components/component_enemy.dart` - Render enemigo
- `lib/game/components/component_boss.dart` - Render boss
- `lib/game/components/ui_displays.dart` - UI
- `lib/game/components/combat_game_screen.dart` - Pantalla
- `lib/game/combat_game.dart` - Juego Flame
- `lib/screens/combat_test_screen.dart` - Pantalla de prueba

---

## 🛠️ Troubleshooting

### Error: "AmalgamaType no encontrado"
✅ Ya corregido en enemy_factory.dart

### Error: "TextPaint no encontrado"
✅ Ya agregado import en combat_game_screen.dart

### Error: "EnemyTypesCatalog.get(...) retorna null"
✅ Ya hay default a 'grunt' en ComponentEnemy

---

## 📊 Estado de Compilación

Todos los archivos están listos para compilar:
- ✅ enemy_factory.dart - Imports corregidos
- ✅ component_enemy.dart - Manejo de nulls
- ✅ component_boss.dart - Listo
- ✅ ui_displays.dart - Listo
- ✅ combat_game_screen.dart - TextPaint import agregado
- ✅ combat_game.dart - Listo
- ✅ combat_test_screen.dart - Listo

---

## 🎯 Próximos pasos

1. Copia el código de integración arriba a tu main.dart
2. Ejecuta: `flutter pub get`
3. Ejecuta: `flutter run`
4. Navega a `/combat`
5. ¡Disfruta! 🎮
