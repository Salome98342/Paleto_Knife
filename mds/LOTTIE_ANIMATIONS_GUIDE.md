import 'package:flutter/material.dart';

/// GUÍA DE CONFIGURACIÓN: Animaciones Lottie para ChestComponent
/// 
/// Este archivo documenta qué archivos Lottie necesitas y cómo configurarlos

// ============================================================================
// ARCHIVOS LOTTIE REQUERIDOS
// ============================================================================

/*
Necesitas crear 3 archivos JSON en: assets/animations/chest/

1. chest_idle.json
   - Duración: ~2-3 segundos (loop)
   - Animación: Cofre respirando suavemente, suave movimiento vertical
   - Frame inicial: Cofre cerrado, ligeramente luminoso
   - Características:
     * Movimiento Y suave: -2 a +2 px
     * Opacidad ligera pulsante: 0.8 a 1.0
     * Glow suave alrededor del cofre

2. chest_shake.json
   - Duración: ~0.5 segundos (NO loop)
   - Animación: Sacudida rápida en X
   - Frame inicial: Cofre en posición normal
   - Frame final: Cofre ligeramente inclinado/rotado
   - Características:
     * Rotación: -2° a +2° alternando rápido
     * Desplazamiento X: -3 a +3 px
     * Aceleración: Rápida al inicio, lenta al final

3. chest_open.json
   - Duración: ~0.8 segundos (NO loop)
   - Animación: Apertura completa del cofre
   - Frame inicial: Cofre cerrado
   - Frame final: Cofre completamente abierto (tapa abierta 90°)
   - Características:
     * Tapa se abre con rotación suave
     * Luz/destello sale del cofre
     * Monedas/partículas vuelan
     * Efecto "pop" visual (escala)

*/

// ============================================================================
// RECOMENDACIONES TÉCNICAS LOTTIE
// ============================================================================

"""
HERRAMIENTAS PARA CREAR ANIMACIONES LOTTIE:
✓ Adobe Animate (exportar a JSON con Body Movin plugin)
✓ Lottie Files (https://lottiefiles.com/) - Template library
✓ Rive (https://rive.app/) - Editor online gratuito
✓ After Effects + Body Movin plugin - Más profesional

REQUISITOS TÉCNICOS:
- Formato: JSON válido (validar en jsonlint.com)
- Resolución: 100x100 a 200x200 px (mantener escalable)
- Color mode: RGB (evitar CMYK)
- Paleta: Usa los colores de PixelColors
  * Cofre: Oro (0xFFD4A574 o similar)
  * Fondo: Transparente (#00000000)
  * Brillo: Blanco/Amarillo (0xFFFFD700)

PASOS PARA EXPORTAR DESDE AFTER EFFECTS:
1. Crear composición 200x200 px
2. Importar/dibujar el cofre
3. Crear keyframes para movimiento
4. Instalar Body Movin plugin
5. Exportar como JSON
6. Colocar en assets/animations/chest/

PASOS PARA USAR EN LOTTIE FILES:
1. Ir a https://lottiefiles.com/featured
2. Descargar archivo .json de una animación existente
3. Editarla con el editor online
4. Descargar como JSON
5. Personalizar colores en el JSON con buscar/reemplazar

"""

// ============================================================================
// ESTRUCTURA DE CARPETAS RECOMENDADA
// ============================================================================

"""
assets/
├── animations/
│   ├── chest/
│   │   ├── chest_idle.json
│   │   ├── chest_shake.json
│   │   └── chest_open.json
│   ├── reward_card/
│   │   └── shimmer_effect.json (opcional)
│   └── ...
├── images/
│   └── ...
└── audio/
    └── ...
"""

// ============================================================================
// CÓDIGO DESCOMENTADO PARA ChestComponent (cuando tengas los JSON)
// ============================================================================

"""
En lib/game/components/chest_component.dart:

import 'package:flame_lottie/flame_lottie.dart';

// En onLoad():
@override
Future<void> onLoad() async {
  _basePosition = position.clone();
  
  // CARGAR LA ANIMACIÓN IDLE (default)
  try {
    await _loadAnimation('assets/animations/chest/chest_idle.json');
  } catch (e) {
    print('Error loading chest idle animation: \$e');
  }
  
  super.onLoad();
}

// Nuevo método para cargar animaciones
Future<void> _loadAnimation(String path) async {
  lottieComponent = LottieComponent(
    width: size.x,
    height: size.y,
  );
  
  // Si LottieComponent tiene un método loadAnimation (verificar documentación)
  // await lottieComponent.loadAnimation(path);
  
  // O usar un assetLoader:
  // final animationData = await rootBundle.loadString(path);
  // lottieComponent.setAnimation(animationData);
}

// En setIdleState():
void setIdleState() {
  if (_currentState == ChestState.idle) return;
  _currentState = ChestState.idle;
  _idleTimer = 0.0;
  _clickInProgress = false;
  
  // Aquí cargarías la animación
  _loadAnimation('assets/animations/chest/chest_idle.json');
}

// En setShakeState():
void setShakeState() {
  if (_currentState == ChestState.shake) return;
  _currentState = ChestState.shake;
  _shakeTimer = 0.0;
  _shakeCompleted = false;
  _clickInProgress = true;
  
  _loadAnimation('assets/animations/chest/chest_shake.json');
}

// En setOpenState():
Future<void> setOpenState() async {
  if (_currentState == ChestState.open) return;
  _currentState = ChestState.open;
  _clickInProgress = true;
  
  await _loadAnimation('assets/animations/chest/chest_open.json');
  
  // Esperar 800ms (duración de la animación)
  await Future.delayed(const Duration(milliseconds: 800));
  
  if (onChestOpened != null) {
    onChestOpened!();
  }
}
"""

// ============================================================================
// ALTERNATIVA SIN LOTTIE (Si prefieres SVG animado)
// ============================================================================

"""
Si no quieres usar JSON Lottie, puedes usar:

1. SVG ANIMADO:
   - Usa 'flutter_svg' + 'vector_math'
   - Define animaciones con Transform.rotate() y Transform.translate()
   - Mantiene la estética pixel art

2. SPRITE SHEETS:
   - Usar SpriteAnimationComponent de Flame
   - Una imagen PNG con frames del cofre abierto/cerrado
   - frame_width: 80, frame_height: 70
   - Como en explosion.dart del proyecto

EJEMPLO CON SPRITE SHEET:
class ChestComponent extends SpriteAnimationComponent {
  @override
  Future<void> onLoad() async {
    animation = await game.images.fromAtlasJson(
      'treasure_chest.png',
      'treasure_chest.atlas',
    );
  }
}
"""

// ============================================================================
// VALIDACIÓN DE ARCHIVOS JSON LOTTIE
// ============================================================================

"""
Antes de usar un JSON Lottie, valida que tenga esta estructura:

{
  "v": "5.xx",          // Versión de Lottie
  "fr": 30,             // Frame rate (30 fps ideal)
  "ip": 0,              // Frame inicial
  "op": 90,             // Frame final (según duración)
  "w": 200,             // Ancho
  "h": 200,             // Alto
  "nm": "chest_idle",   // Nombre
  "ddd": 0,             // 3D (0 = 2D)
  "assets": [],         // Assets (imágenes, etc)
  "layers": [           // Capas de animación
    {
      "ddd": 0,
      "ind": 1,
      "ty": 4,           // Shape group
      "nm": "cofre",
      "sr": 1,
      "ks": {            // Transform
        "o": { ... },    // Opacity
        "r": { ... },    // Rotation
        "p": { ... },    // Position
        "s": { ... },    // Scale
        "a": { ... }     // Anchor
      },
      "shapes": [        // Formas (rectángulos, circles, etc)
        {
          "ty": "gr",
          "nm": "Group 1",
          "...": "..."
        }
      ]
    }
  ]
}

✓ v, fr, ip, op, w, h: REQUERIDO
✓ assets: array (puede estar vacío)
✓ layers: array con al menos 1 capa
✓ Validar en: https://jsonlint.com/
"""

// ============================================================================
// COLORES PARA USAR EN LOTTIE (PixelColors de tu proyecto)
// ============================================================================

class PixelColorsLottie {
  // Valores en formato hex para JSON Lottie
  static const String bgColor = '#0D0D1A';          // Fondo
  static const String bgPanel = '#1A1A2E';          // Panel
  static const String accentGold = '#FFD700';       // Oro
  static const String accentOrange = '#FF6B00';     // Naranja
  static const String healthGreen = '#44CC44';      // Verde
  static const String dangerRed = '#CC3333';        // Rojo
  static const String manaBlue = '#3399FF';         // Azul
  static const String borderGray = '#444466';       // Border
  static const String textWhite = '#E8E8E8';        // Texto
  static const String textDim = '#8888AA';          // Texto tenue

  // Para usar en After Effects / Lottie Files, convierte a decimal:
  // Hex: #FFD700 -> RGB: 255, 215, 0
}

// ============================================================================
// CHECKLIST FINAL
// ============================================================================

"""
✓ [ ] Crear/descargar archivos JSON Lottie
✓ [ ] Colocar en assets/animations/chest/
✓ [ ] Validar JSON syntax
✓ [ ] Probar cada animación individualmente
✓ [ ] Ajustar duraciones (idle 2s, shake 0.5s, open 0.8s)
✓ [ ] Descomenta el código en ChestComponent
✓ [ ] Prueba en dispositivo
✓ [ ] Ajusta tamaños si se ve muy grande/pequeño
✓ [ ] Añade SFX (sonidos) si lo deseas
"""
