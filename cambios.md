# Prompt Master para GitHub Copilot — Rediseño UI: Paleto Knife
> Versión 2 — Basado en análisis visual del build actual

---

## CONTEXTO DEL PROYECTO

Estás trabajando en **Paleto Knife**, un juego indie con las siguientes características:

- **Género**: Bullet Hell RPG Gacha
- **Inspiración**: Touhou Project (patrones de balas densos, personajes fuertes)
- **Temática**: Chefs que combaten amalgamas de comida mutante (dumplings, gyozas, etc.)
- **Mascota/Logo**: Capibara con personalidad marcada
- **Estética visual**: Pixel art 8-bit con sprites de chefs y monstruos de comida
- **Stack**: Flutter + Dart + Flame Engine

---

## DIAGNÓSTICO DEL BUILD ACTUAL

Antes de generar código, interioriza estos problemas reales identificados en el juego:

| Problema | Causa | Solución |
|---|---|---|
| Menús se sienten como wireframe | Botones son rectángulos planos sin profundidad | Efecto de relieve NES: borde superior claro, borde inferior oscuro |
| Falta de feedback interactivo | Sin estado "presionado" ni animación | GestureDetector + desplazamiento de 2-3px al presionar |
| Paleta apaga la energía del juego | Colores rojos/mostaza/gris sin cohesión | Paleta 8-bit de alto contraste con jerarquía clara |
| Bordes divisorios muy delgados | Líneas de 1px genéricas | BoxDecoration gruesa, estilo diálogo de JRPG clásico |
| Mezcla de responsabilidades | UI intentando vivir dentro de Flame | Separar: Flame = motor, Flutter = toda la UI via overlayBuilders |

---

## ARQUITECTURA CORRECTA

```
GameWidget (Flame)
└── overlayBuilders: {
      'MainMenu'      : (ctx, game) => MainMenuOverlay(game),
      'GachaScreen'   : (ctx, game) => GachaOverlay(game),
      'Inventory'     : (ctx, game) => InventoryOverlay(game),
      'StageSelect'   : (ctx, game) => StageSelectOverlay(game),
      'ResultScreen'  : (ctx, game) => ResultOverlay(game),
      'HUD'           : (ctx, game) => CombatHUD(game),
    }
```

**Regla absoluta**: 
- `Flame` maneja: game loop, oleadas, colisiones, sprites en combate, física de balas
- `Flutter` maneja: TODO lo que sea menú, panel, botón, card, inventario, gacha

---

## SISTEMA DE DISEÑO BASE

### Paleta de colores

```dart
// lib/ui/theme/paleto_colors.dart

class PaletoColors {
  // Fondos
  static const bgDeep       = Color(0xFF0D0D0D); // Negro carbón — fondo de pantallas
  static const bgPanel      = Color(0xFF1A1209); // Marrón oscuro quemado — interior de paneles
  static const bgPanelAlt   = Color(0xFF0F1A0D); // Verde oscuro podrid — variante

  // Bordes de panel (estilo NES — 3 tonos para el relieve)
  static const borderLight  = Color(0xFFE8C97A); // Dorado claro — borde superior/izquierdo (luz)
  static const borderMid    = Color(0xFF8B6914); // Dorado medio — borde principal
  static const borderDark   = Color(0xFF3D2B05); // Marrón oscuro — borde inferior/derecho (sombra)

  // Botones por jerarquía
  static const btnPrimary   = Color(0xFFD4380D); // Rojo fuego — acción principal (Combatir, Reclutar)
  static const btnPrimaryLt = Color(0xFFFF6B3D); // Rojo claro — borde superior del botón primario
  static const btnPrimaryDk = Color(0xFF7A1A00); // Rojo oscuro — borde inferior del botón primario

  static const btnGacha     = Color(0xFFFFB800); // Amarillo dorado — botones de gacha/invocación
  static const btnGachaLt   = Color(0xFFFFE066); // Amarillo claro — borde superior gacha
  static const btnGachaDk   = Color(0xFF7A5500); // Ámbar oscuro — borde inferior gacha

  static const btnSecondary = Color(0xFF2A4A2A); // Verde pantano — acción secundaria
  static const btnSecondaryLt = Color(0xFF4A8A4A);
  static const btnSecondaryDk = Color(0xFF0D1F0D);

  static const btnNeutral   = Color(0xFF2D2D2D); // Gris oscuro — botones inactivos/cancelar
  static const btnNeutralLt = Color(0xFF4A4A4A);
  static const btnNeutralDk = Color(0xFF111111);

  // Rarezas gacha
  static const rarityCommon    = Color(0xFF888888); // Gris
  static const rarityRare      = Color(0xFF4A90D9); // Azul
  static const rarityEpic      = Color(0xFF9B4DCA); // Púrpura
  static const rarityLegendary = Color(0xFFFFB800); // Dorado

  // Texto
  static const textPrimary  = Color(0xFFF5E6C8); // Crema cálido
  static const textSecondary= Color(0xFF9E8A6A); // Beige apagado
  static const textAccent   = Color(0xFFFFB800); // Dorado — nombres, énfasis

  // Elementos
  static const elemFire     = Color(0xFFFF4500);
  static const elemIce      = Color(0xFF00BFFF);
  static const elemPoison   = Color(0xFF7CFC00);
  static const elemElec     = Color(0xFFFFD700);
  static const elemDark     = Color(0xFF9932CC);
}
```

### Tipografía

```dart
// lib/ui/theme/paleto_text.dart
// Fuentes recomendadas (añadir en pubspec.yaml via google_fonts):
// - Press Start 2P  → títulos, headers, botones
// - VT323           → números, stats, contadores (muy legible en pequeño)
// - Silkscreen      → texto de lore, descripciones de items

class PaletoText {
  static TextStyle header({double size = 16, Color? color}) => TextStyle(
    fontFamily: 'PressStart2P',
    fontSize: size,
    color: color ?? PaletoColors.textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle stat({double size = 20, Color? color}) => TextStyle(
    fontFamily: 'VT323',
    fontSize: size,
    color: color ?? PaletoColors.textAccent,
    letterSpacing: 2.0,
  );

  static TextStyle body({double size = 12, Color? color}) => TextStyle(
    fontFamily: 'Silkscreen',
    fontSize: size,
    color: color ?? PaletoColors.textSecondary,
    height: 1.6,
  );
}
```

---

## PROMPT BASE PARA COPILOT

Copia este bloque completo al iniciar cada sesión con Copilot:

---

```
Actúa como un desarrollador Flutter senior especializado en UI/UX para videojuegos indie pixel art.

PROYECTO: Paleto Knife — RPG Gacha Bullet Hell, pixel art 8-bit, inspirado en Touhou Project.
Chefs protagonistas luchan contra amalgamas de comida mutante (dumplings gigantes, gyozas, etc.)

ARQUITECTURA ESTABLECIDA:
- Flame Engine maneja EXCLUSIVAMENTE: game loop, colisiones, sprites de combate, física de balas
- Flutter maneja TODA la UI de menús a través de overlayBuilders del GameWidget
- NO construir menús dentro de Flame. Toda pantalla de menú es un Widget de Flutter.

PROBLEMA ACTUAL A RESOLVER:
Los menús actuales se ven como wireframes. Botones planos sin profundidad, sin feedback al presionar,
bordes divisorios delgados, paleta sin cohesión. Necesitan "juiciness" y sentirse físicos.

REGLAS DE DISEÑO NO NEGOCIABLES:
1. CERO BorderRadius.circular() — todo ortogonal, en bloques pixel art
2. Todos los botones deben tener estado "presionado" evidente (hundirse 2-3px)
3. Simular relieve NES en panels y botones: borde superior/izquierdo claro, inferior/derecho oscuro
4. FilterQuality.none en TODOS los Image widgets con pixel art (para no difuminar píxeles)
5. Usar centerSlice en paneles de pixel art para scaling sin deformación
6. Fondo siempre oscuro (Color(0xFF0D0D0D) base), elementos con alto contraste
7. Fuente principal: Press Start 2P para headers/botones, VT323 para stats/números

PALETA PRINCIPAL:
- Fondo panel:    #1A1209 (marrón quemado)
- Borde luz:      #E8C97A (dorado claro)
- Borde sombra:   #3D2B05 (marrón oscuro)
- Botón primario: #D4380D (rojo fuego)
- Botón gacha:    #FFB800 (dorado)
- Texto principal:#F5E6C8 (crema)

COMPONENTES BASE YA DEFINIDOS (respeta esta nomenclatura):
- RetroButton     → botón reutilizable con efecto de hundimiento
- RetroMenuBox    → contenedor con borde de relieve NES
- ResourceChip    → chip de recurso/moneda
- RarityBorder    → contenedor con borde coloreado por rareza
- StatBar         → barra de estadística animada
- PixelDivider    → línea divisoria gruesa estilo retro
```

---

## PROMPTS POR COMPONENTE

Usa cada bloque de forma independiente después del prompt base:

---

### COMPONENTE 1 — RetroButton

```
Genera el widget RetroButton con estas especificaciones:

- GestureDetector que detecta onTapDown, onTapUp, onTapCancel
- En estado normal: el botón tiene un offset de (0,0) y bordes de relieve completos
- En estado presionado: AnimatedContainer que en 60ms mueve el contenido 2px hacia abajo
  y colapsa el borde inferior (simula hundimiento físico)
- BoxDecoration con BoxShadow sin blur para simular relieve pixel art:
    * Borde superior: offset(0,-2), color claro (borde de luz)
    * Borde inferior: offset(0,3), color oscuro (borde de sombra)
    * Borde izquierdo: offset(-2,0), color claro
    * Borde derecho: offset(3,0), color oscuro
- Parámetros del widget:
    * String label
    * VoidCallback onPressed
    * Color baseColor (requerido)
    * Color lightBorder (requerido)
    * Color darkBorder (requerido)
    * double width (opcional)
    * Widget? icon (opcional, aparece a la izquierda del label)
    * bool enabled (default true)
- El label usa fuente Press Start 2P, mayúsculas, tamaño 10-12
- Cuando enabled=false, aplicar opacidad 0.4 y deshabilitar interacción
- Añadir sonido hook: un VoidCallback? onSoundEffect que se llama en onTapDown
  para que el sistema de audio del juego lo conecte externamente

Dame el widget completo con su StatefulWidget y el AnimatedContainer.
```

---

### COMPONENTE 2 — RetroMenuBox

```
Genera el widget RetroMenuBox con estas especificaciones:

- Contenedor base con BoxDecoration de color #1A1209
- Sin border radius (todo ortogonal)
- Simulación de borde NES usando BoxShadow en cascada sin blur:
    * 2px arriba/izquierda: Color(0xFFE8C97A) — luz
    * 4px arriba/izquierda adicional: Color(0xFF8B6914) — borde medio
    * 2px abajo/derecha: Color(0xFF3D2B05) — sombra
    * 4px abajo/derecha adicional: Color(0xFF1A0D00) — sombra profunda
- Padding interno: EdgeInsets.all(12) por defecto, personalizable
- Parámetros:
    * Widget child (requerido)
    * EdgeInsets? padding
    * Color? backgroundColor
    * String? title (si se provee, renderiza un header dentro del box con PixelDivider debajo)
    * bool hasScanlines (default false — si true, superpone un CustomPainter de scanlines)
- Si hasScanlines=true, el CustomPainter dibuja líneas horizontales cada 4px
  con opacidad 0.06 (efecto CRT sutil, no intrusivo)

Incluye también el PixelDivider: un widget de 2px de altura, color #8B6914,
con bordes de 1px arriba en #E8C97A y 1px abajo en #3D2B05.
```

---

### COMPONENTE 3 — RarityBorder

```
Genera el widget RarityBorder para mostrar la rareza de personajes/armas:

Enum PaletoRarity { common, rare, epic, legendary }

Colores por rareza:
- common:    border #888888, glow transparente
- rare:      border #4A90D9, glow rgba(74,144,217,0.3)
- epic:      border #9B4DCA, glow rgba(155,77,202,0.35)
- legendary: border #FFB800, glow rgba(255,184,0,0.4)

Para legendary: añadir AnimationController que hace pulsar el glow
entre opacidad 0.3 y 0.6 en un ciclo de 1.5 segundos (CurvedAnimation con Curves.easeInOut)

Parámetros:
- Widget child
- PaletoRarity rarity
- double borderWidth (default 3.0)

El borde debe ser ortogonal (sin radius).
```

---

### COMPONENTE 4 — ResourceChip

```
Genera el widget ResourceChip para mostrar monedas y recursos en el HUD:

- Layout Row: [icono pixel art] [espacio 4px] [valor numérico]
- El valor usa VT323, tamaño 22, color #FFB800
- Al cambiar el valor, animar con TweenAnimationBuilder que interpola
  el número anterior al nuevo en 600ms (efecto de contador que rueda)
- Parámetros:
    * String assetPath (ruta al icono, renderizado con FilterQuality.none)
    * int value
    * double iconSize (default 20)
- Fondo: pequeño RetroMenuBox comprimido (padding horizontal 8, vertical 4)
```

---

### PANTALLA — Gacha / Reclutar Chefs

```
Usando RetroButton, RetroMenuBox, RarityBorder y ResourceChip ya generados,
crea la pantalla GachaOverlay completa:

LAYOUT (Column principal):
1. Header: RetroMenuBox con título "RECLUTAR CHEFS" + ResourceChip de moneda gacha
2. Área central: AnimatedSwitcher que alterna entre:
   a. Estado idle: ilustración del chef de reclutamiento (placeholder Container negro 200x200)
      con texto "Toca para invocar" parpadeando (OpacityAnimation 0.4↔1.0 cada 800ms)
   b. Estado animando: placeholder para la animación de pull (Container negro con texto "...")
   c. Estado resultado: GridView de CardResultWidget (ver abajo)
3. Footer: Row con dos RetroButton:
   - "x1 PULL" — color primario rojo, muestra costo con icono
   - "x10 PULL" — color dorado gacha, muestra costo x10

CardResultWidget (interno, no exportar por separado):
- RarityBorder envolviendo un Stack:
    * Fondo oscuro del color de la rareza al 20% de opacidad
    * Sprite del personaje (placeholder Container 80x80 con FilterQuality.none)
    * Nombre del personaje abajo en Press Start 2P tamaño 8
    * Badge de rareza: texto "★★★" en color de rareza

GachaOverlay debe ser un StatefulWidget con:
- Estado: GachaState { idle, animating, showResult }
- Lista de GachaResult para poblar el grid
- Método _performPull() que cambia estado, espera 1.5s (simula animación) y pasa a showResult
- Recibe como parámetro la referencia al game para llamar game.overlays.remove('GachaScreen')
  al cerrar

Asegúrate que toda la pantalla tenga fondo semi-transparente (Colors.black87)
para que el GameWidget de Flame sea visible detrás.
```

---

### PANTALLA — HUD de Combate

```
Crea el CombatHUD como overlay de Flutter sobre Flame:

Debe ser un widget completamente transparente al centro (el juego debe verse)
con elementos solo en los bordes:

TOP (SafeArea):
- Izquierda: HP bar del chef
  * Etiqueta "HP" en Press Start 2P tamaño 8
  * Barra custom con CustomPainter: fondo #1A0D00, relleno en degradado #FF4500→#FFB800
  * Valor numérico debajo en VT323: "080/100"
  * Animación: cuando HP baja, el relleno hace un flash blanco de 200ms
- Derecha: Boss HP bar (misma estructura, color #9B4DCA para bosses)
- Centro: nombre del stage/boss en Press Start 2P tamaño 7, opacidad 0.8

BOTTOM (pegado al borde inferior):
- Izquierda: skill especial — círculo de carga con CustomPainter (arco que se llena)
  Icono de llama en el centro, "LISTO" parpadeando cuando está al 100%
- Derecha: contador de score en VT323 tamaño 28, color #FFB800
  con TweenAnimationBuilder para el efecto de números que ruedan

Toda la HUD se monta via overlayBuilders y recibe el PaletoKnifeGame
para leer game.playerHP, game.bossHP, game.score como ValueNotifier o similar.
```

---

### PANTALLA — Stage Select

```
Crea StageSelectOverlay con:

CONCEPTO VISUAL: "Menú de restaurante corrupto" — cada zona es una sección del menú

Layout: Column con:
1. RetroMenuBox como header: "SELECCIONAR MISIÓN" 
2. ListView de StageCard (scroll vertical)
3. Footer: RetroButton "VOLVER"

StageCard widget:
- RetroMenuBox como contenedor base
- Row con:
    * Número de stage en VT323 tamaño 32 (ej. "01")
    * Column con:
        - Nombre del stage en Press Start 2P tamaño 10
        - Descripción corta en Silkscreen tamaño 11
        - Row de estrellas Michelin (dificultad): 1-3 estrellas
          La estrella 3 (máxima dificultad) renderiza en color #FF4500 y tiene
          forma diferente (usar Icon o emoji ☠ en su lugar)
    * Si el stage está desbloqueado: flecha "▶" en color #FFB800
    * Si está bloqueado: candado icon con opacidad 0.4

Estado de cada card: locked, available, completed
- completed: añadir badge "✓" verde en esquina superior derecha
- locked: toda la card en opacidad 0.5, sin GestureDetector activo

Pasar al widget una List<StageData> con { id, name, description, difficulty, state }
```

---

## CHECKLIST ANTES DE INTEGRAR CÓDIGO DE COPILOT

Antes de pegar cualquier widget generado en el proyecto, verifica:

- [ ] `FilterQuality.none` en todos los `Image` con pixel art
- [ ] Cero `BorderRadius.circular()` en componentes de UI del juego
- [ ] Todos los `Text` con pixel art fonts (no `TextStyle()` sin `fontFamily`)
- [ ] Los `AnimationController` hacen `dispose()` en el `State`
- [ ] Los overlays llaman correctamente a `game.overlays.remove()`
- [ ] Los colores usan la paleta de `PaletoColors`, no hardcoded inline
- [ ] Los `GestureDetector` tienen `onTapDown` (no solo `onTap`) para feedback inmediato

---

## TONO Y FILOSOFÍA DE DISEÑO

> Paleto Knife no es un juego que pida permiso. La cocina está en llamas,
> los ingredientes son monstruosos y el capibara chef no tiene miedo.
> Los menús deben sentirse como herramientas de guerra culinaria —
> físicos, contundentes, con carácter. Cada botón que presiones
> debe sentirse como clavar un cuchillo en una tabla de cortar.
> Nada es suave. Nada es redondeado. Todo es Paleto Knife.