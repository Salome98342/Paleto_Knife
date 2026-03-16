# 🎨 Prompts Ultra-Potentes para Generación de Sprites — Paleto Knife

## 📋 Documento de Generación de Assets con Contexto Completo
**Versión:** 2.0 (Optimizado para Gemini Pro & Stable Diffusion)  
**Fecha:** 9 de marzo de 2026  
**Uso:** Copy-paste estos prompts COMPLETOS en Gemini Pro, DALL-E 3, Midjourney o Stable Diffusion  
**Referencia:** GUIA_VISUAL_8BIT.md

---

## 🎮 CONTEXTO DEL JUEGO (Leer antes de generar)

**Paleto Knife (Knife Clicker)** es un RPG incremental de acción para móviles donde:

### 📖 Narrativa
- **Protagonista**: Chef Maestro, un cocinero experto que domina el arte del lanzamiento de cuchillos
- **Enemigos**: Amalgamas Culinarias — criaturas grotescas hechas de comida mutante viviente que han invadido las cocinas del mundo
- **Objetivo**: Derrotar oleadas de monstruos culinarios a través de 12 mundos temáticos (cocinas infernales, restaurantes abandonados, despensas malditas)
- **Mecánica Principal**: Combat de acción automático donde el chef lanza cuchillos hacia arriba mientras esquiva ataques enemigos moviéndose horizontalmente
- **Progresión**: Coleccionar oro, contratar sous-chefs asistentes, mejorar técnicas culinarias, desbloquear cuchillos de rareza creciente

### 🎨 Estética Visual
- **Estilo**: Pixel art 8-bit clásico inspirado en NES (Mega Man, Castlevania, Kirby)
- **Paleta**: Limitada a 16-24 colores por sprite, estilo arcade colorido
- **Temática**: Horror culinario humorístico — enemigos grotescos pero cómicos hechos de comida
- **Ambiente**: Cocinas y restaurantes con atmósfera oscura/apocalíptica pero manteniendo colores vibrantes de comida

---

## 🎯 Instrucciones Críticas para IA (Gemini Pro / DALL-E / Stable Diffusion)

### ⚠️ IMPORTANTE: Lee esto antes de copiar prompts

**Para obtener mejores resultados:**

1. **Copia el prompt COMPLETO** incluyendo toda la sección "GAME CONTEXT" al inicio
2. **NO modifiques** las dimensiones especificadas (16×16, 32×32, 48×48, etc.)
3. **Enfatiza al final**: `"pixel art, 8-bit NES style, retro video game sprite, no anti-aliasing, sharp pixels, transparent background"`
4. **Si Gemini genera con anti-aliasing**: Regenera añadiendo `"CRITICAL: use only sharp square pixels, no blur, no smooth edges, no gradients"`
5. **Si los colores no coinciden**: Especifica `"use ONLY these exact hex colors: [lista de colores del prompt]"`

### Para Gemini Pro específicamente:
```
Añade al FINAL del prompt:

"Style: Classic Nintendo Entertainment System (NES) sprite from 1985-1990.
Reference games: Mega Man 2, Castlevania, Super Mario Bros 3.
Pixel art technique: Each pixel is a perfect square, no anti-aliasing.
Output format: PNG with transparency, exact dimensions specified.
Color palette: Limited to colors specified above only."
```

### Configuración de Herramientas
```
Gemini Pro:      Modo "Generate Image", aspect ratio según dimensiones
DALL-E 3:        1024×1024, luego recortar/escalar con nearest-neighbor
Midjourney:      --style raw --quality 2 --no smooth, gradients, blur
Stable Diffusion: PixelArt LoRA, CFG Scale 7-9, Steps 30-50
```

---

# 👨‍🍳 CHEF MAESTRO — Protagonista

## Sprite 1: Chef Idle Animation (Animación de Espera)

### 🎮 GAME CONTEXT (Contexto del Juego)
**Quién es este personaje:**
- El Chef Maestro es el PROTAGONISTA del juego Paleto Knife
- Es un cocinero experto que ha dominado el arte marcial del lanzamiento de cuchillos
- Lucha contra Amalgamas Culinarias (monstruos de comida mutante) en cocinas apocalípticas
- En gameplay: aparece en la parte INFERIOR de la pantalla, dispara cuchillos hacia ARRIBA
- Se mueve horizontalmente (izquierda/derecha) para esquivar ataques enemigos

**Por qué necesitamos este sprite:**
- Animación IDLE = cuando el chef está quieto esperando (modo clicker, menús, entre combates)
- Debe verse profesional, heroico y ligeramente cómico
- Es el sprite más visto del juego — debe ser icónico y memorable

**Estilo del juego:**
- Pixel art 8-bit estilo NES (1985-1990) como Mega Man, Castlevania
- Temática: horror culinario humorístico
- Paleta colorida tipo arcade retro

---

### 📝 PROMPT COMPLETO PARA IA

```
GAME: Paleto Knife — 8-bit pixel art mobile RPG about a chef fighting food monsters

CHARACTER: Chef Maestro (Main Protagonist)
ROLE: Player character in combat mode, appears at bottom of screen, throws knives upward
CONTEXT: This is the IDLE animation (breathing, waiting, standing still)

Create a pixel art sprite sheet for a heroic chef character in classic 8-bit NES style.

═══════════════════════════════════════════════════════════════

🎯 TECHNICAL SPECIFICATIONS:
- Dimensions: 128×32 pixels (4 frames of 32×32 each, horizontal sprite sheet)
- Style: Classic Nintendo NES pixel art (1985-1990 era)
- Grid: Aligned to 16×16 pixel grid (each pixel is a perfect square)
- Background: Transparent (PNG with alpha channel)
- Output: Single horizontal strip with 4 animation frames

🎨 CHARACTER DESIGN:

BODY & CLOTHING:
- Tall white chef's hat (toque blanche) — 10-12 pixels tall, puffy rounded top
- White chef uniform/jacket with gray shading for depth
- Red neckerchief/bandana tied around neck (bright red, visible and prominent)
- White uniform should have black outline (1 pixel thick)
- Uniform has subtle folds/shadows using light gray

HEAD & FACE:
- Beige/tan skin tone for face and hands
- Simple expressive face style (like Mega Man or Mario)
- Two dot eyes (2×2 pixels each, black)
- Small smile or neutral mouth (3-4 pixels wide)
- Face is front-facing 3/4 view (slightly angled)

WEAPON:
- Silver kitchen knife held in right hand at his side
- Knife: 8-10 pixels long, simple blade + handle
- Held in relaxed downward position

POSTURE:
- Standing upright, heroic but relaxed pose
- Feet visible at bottom (simple shoes, 2-3 pixels visible)
- Arms at sides naturally
- Weight evenly distributed

═══════════════════════════════════════════════════════════════

🎨 COLOR PALETTE (USE ONLY THESE 8 COLORS):

#0F0F0F — Pure black (outlines, eyes, shadows)
#FFFFFF — Pure white (hat, uniform highlights)
#E0E0E0 — Light gray (uniform shading)
#4A4A4A — Dark gray (uniform shadows, details)
#FFE5B4 — Beige/tan (skin tone for face and hands)
#D4A373 — Darker tan (skin shadows and depth)
#FF0000 — Bright red (neckerchief — must be very visible)
#C0C0C0 — Silver (knife blade)

CRITICAL: Do NOT use any other colors. No gradients. No anti-aliasing.

═══════════════════════════════════════════════════════════════

📹 ANIMATION SEQUENCE (4 FRAMES — IDLE BREATHING):

Frame 1 (0ms): 
- Neutral standing pose
- Knife at side, relaxed
- Normal position

Frame 2 (125ms):
- ENTIRE sprite moves UP by 1 pixel (breathing in)
- Chest slightly expanded (1-2 pixels wider if space allows)
- Everything else same

Frame 3 (250ms):
- Return to exact Frame 1 position (neutral)

Frame 4 (375ms):
- ENTIRE sprite moves DOWN by 1 pixel (breathing out)
- Slight compression
- Everything else same

[500ms: Loop back to Frame 1]

ANIMATION STYLE:
- Very subtle breathing motion (only 1-2 pixel movement)
- Smooth, gentle, calm
- Conveys: "Ready for action" but relaxed

═══════════════════════════════════════════════════════════════

🎮 STYLE REFERENCES (8-bit NES era):

PRIMARY REFERENCES:
- Mega Man (NES) — simple, iconic, readable silhouette
- Mario (NES) — expressive despite low resolution
- Castlevania (NES) — heroic proportions

CHARACTER TRAITS TO CAPTURE:
- Instantly recognizable silhouette (tall hat is key)
- Heroic but not overly serious
- Professional chef aesthetic
- Slightly comedic (fighting food monsters)
- Clear readable features at small size

ARTISTIC RULES:
- Thick black outline (1 pixel) around ENTIRE character except where sprite edges meet
- No anti-aliasing on ANY edges (pure pixel-perfect squares)
- No smooth gradients (use dithering checkerboard pattern if transition needed)
- High contrast for readability
- All pixels perfectly aligned to grid

═══════════════════════════════════════════════════════════════

✅ VERIFICATION CHECKLIST (confirm before delivery):

☐ Exactly 128×32 pixels (4 frames horizontally of 32×32 each)
☐ Only uses the 8 specified hex colors (no others)
☐ Perfect pixel grid alignment (no subpixels)
☐ NO anti-aliasing or blur anywhere
☐ Black outline consistent (1px) around character
☐ Transparent background (PNG alpha)
☐ Breathing animation is subtle (1-2 pixel movement)
☐ Chef hat is the tallest part, very recognizable
☐ Red neckerchief is clearly visible
☐ Knife is visible in hand
☐ Face is simple but has personality
☐ Each frame is distinct and animates smoothly

═══════════════════════════════════════════════════════════════

💡 FOR AI IMAGE GENERATORS (Gemini/DALL-E/Midjourney):

Style keywords: "pixel art, 8-bit, NES style, retro video game sprite, Nintendo Entertainment System, 1980s arcade game, no anti-aliasing, sharp square pixels, sprite sheet"

Negative prompt: "smooth, gradient, 3D, realistic, anti-aliased, blurry, modern, high resolution, detailed shading"

Reference era: 1985-1990 Nintendo NES games
Reference games: Mega Man 2, Castlevania, Mario Bros 3, Kirby's Adventure

Output must be: PNG sprite sheet, transparent background, exactly 128×32 pixels
```

---

### 🖼️ Visual Reference Description (For Manual Creation)

```
Visualize this:

    FRAME 1          FRAME 2          FRAME 3          FRAME 4
  (32×32 px)       (32×32 px)       (32×32 px)       (32×32 px)
  
     ████            ████             ████             ████
    ██  ██          ██  ██           ██  ██           ██  ██
    ██  ██    →     ██  ██     →     ██  ██     →     ██  ██
     ████            ████             ████             ████
      ██              ██               ██               ██
    ██████          ██████           ██████           ██████
    ██  ██          ██  ██           ██  ██           ██  ██
     ████            ████             ████             ████
      ██              ██               ██               ██
     █  █            █  █             █  █             █  █
     
   (neutral)      (+1px up)        (neutral)        (+1px down)
```

The chef should look like a pixel art hero from a classic NES game, wearing a chef outfit instead of armor, fighting with kitchen knives instead of swords.

---

## Sprite 2: Chef Throw Animation

### Prompt de Generación
```
Create a pixel art sprite sheet for a chef throwing a knife animation in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 192×32 pixels (6 frames of 32×32 each, horizontal layout)
- Style: Classic NES pixel art, no anti-aliasing
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent

CHARACTER DESIGN:
- Same chef from idle animation (see Sprite 1)
- Tall white chef's hat
- White uniform with red neckerchief
- Beige skin (#FFE5B4)
- Dynamic throwing pose

COLOR PALETTE (use only these):
#0F0F0F — Black (outlines)
#FFFFFF — White (hat, uniform)
#E0E0E0 — Light gray (shading)
#4A4A4A — Dark gray (shadows)
#FFE5B4 — Skin tone
#D4A373 — Skin shadows
#FF0000 — Red (neckerchief)
#C0C0C0 — Silver (knife)

ANIMATION SEQUENCE (6 frames):
Frame 1: Preparation - arm pulled back, knife behind head, body leaning back slightly
Frame 2: Wind-up - arm at 45° angle, body coiled
Frame 3: Release point - arm fully extended upward, knife at fingertips
Frame 4: Follow-through - arm still extended, NO knife visible (thrown), body leaning forward
Frame 5: Recovery - arm lowering to 45°, returning to center
Frame 6: Return to neutral - arm at side, back to idle pose

ANIMATION NOTES:
- Motion should flow smoothly from frame to frame
- Knife disappears after frame 3 (it's been thrown)
- Body should have some rotation/twist for realism
- Hat stays on head but can tilt slightly
- Facial expression can be determined/focused

STYLE REFERENCES:
- Action sprites from: Castlevania, Ninja Gaiden
- Dynamic but readable
- Clear silhouette changes between frames
- No motion blur (pure pixel art)

VERIFICATION CHECKLIST:
☐ Exactly 192×32 pixels (6 frames of 32×32)
☐ Only uses the 8 colors specified
☐ Knife visible in frames 1-3, gone in frames 4-6
☐ Smooth motion progression
☐ No anti-aliasing
☐ Transparent background
☐ Clear throwing arc visible
```

---

## Sprite 3: Chef Critical Hit Animation

### Prompt de Generación
```
Create a pixel art sprite sheet for a chef celebrating a critical hit in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 256×32 pixels (8 frames of 32×32 each, horizontal layout)
- Style: Classic NES pixel art with dramatic effects
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent

CHARACTER DESIGN:
- Same chef character (see Sprite 1)
- White chef's hat, uniform, red neckerchief
- Heroic/victorious pose
- Surrounded by star particles and flash effects

COLOR PALETTE:
#0F0F0F — Black (outlines)
#FFFFFF — White (hat, flash effects, stars)
#E0E0E0 — Light gray
#4A4A4A — Dark gray
#FFE5B4 — Skin tone
#D4A373 — Skin shadows
#FF0000 — Red (neckerchief)
#FFFF00 — Yellow (star sparkles)
#FF4500 — Orange (critical flash)

ANIMATION SEQUENCE (8 frames):
Frame 1-2: Full white flash (entire sprite in white/yellow)
Frame 3: Flash fading, chef posing with both arms up victoriously
Frame 4: Arms still up, 4 star sparkles appear around chef (corners)
Frame 5: Stars rotate 45°, slightly larger
Frame 6: Stars continue rotating, chef starts lowering arms
Frame 7: Stars fading out, chef lowering to normal pose
Frame 8: Return to idle, stars gone

EFFECTS:
- Stars should be 4×4 pixel 4-pointed stars
- Flash should make entire sprite briefly white
- Stars appear at: top-left, top-right, bottom-left, bottom-right (8px from character)
- Stars use colors #FFFF00 (yellow) and #FFFFFF (white highlights)

STYLE REFERENCES:
- Power-up effects from: Super Mario World, Mega Man
- Dramatic but quick impact
- Readable at gameplay speed (15 FPS)

VERIFICATION CHECKLIST:
☐ Exactly 256×32 pixels (8 frames)
☐ Frame 1-2 are white flash
☐ 4 stars appear in frames 4-6
☐ Stars rotate and fade properly
☐ Transparent background
☐ Color palette adhered to
```

---

# 👹 AMALGAMAS CULINARIAS — Enemigos

## Sprite 4: Pizza de Lava (Enemigo Elite)

### 🎮 GAME CONTEXT (Contexto del Juego)
**Qué es este enemigo:**
- Amalgama Culinaria = monstruo viviente hecho de comida mutante
- Pizza de Lava es un enemigo ELITE (tier medio-alto) del Mundo 1: Cocina Infernal
- Aparece en la parte SUPERIOR de la pantalla, dispara proyectiles hacia ABAJO al jugador
- Es una pizza circular poseída con tentáculos de pepperoni, queso fundido goteando, y ojos malignos
- Concepto: comida deliciosa pero corrompida, grotesca pero cómica

**Rol en gameplay:**
- Enemigo de dificultad media (más fuerte que Sushi, más débil que jefes)
- Tamaño: 48×48 px (más grande que el jugador — intimidante)
- Animación idle: tentáculos ondulando amenazadoramente
- Dispara proyectiles de salsa/queso fundido hacia el chef

**Estética:**
- Horror culinario: debe dar hambre Y miedo a la vez
- Colores rojos/naranjas/amarillos (fuego, salsa, queso)
- Ojos expresivos = personalidad (malvado pero tonto)
- Inspiración: enemigos de Kirby + comida del infierno

---

### 📝 PROMPT COMPLETO PARA IA

```
GAME: Paleto Knife — 8-bit pixel art mobile RPG where a chef fights living food monsters

ENEMY: Pizza de Lava (Lava Pizza)
TYPE: Elite Enemy (Culinary Amalgam)
WORLD: Mundo 1 — Hellish Kitchen (Cocina Infernal)
ROLE: Mid-tier threatening enemy, appears at TOP of screen, shoots downward at player
CONCEPT: A possessed circular pizza with pepperoni tentacles, melting cheese, evil eyes

Create a pixel art enemy sprite sheet for a living lava pizza monster in 8-bit NES horror-comedy style.

═══════════════════════════════════════════════════════════════

🎯 TECHNICAL SPECIFICATIONS:
- Dimensions: 192×48 pixels (4 frames of 48×48 each, horizontal idle animation)
- Style: NES pixel art ENEMY (like Kirby bosses, Mega Man enemies)
- Grid: Aligned to 16×16 pixel grid (perfect square pixels)
- Background: Transparent (PNG with alpha)

ENEMY DESIGN:
- Circular pizza base (36-40 pixels diameter)
- Crust edge is brown/toasted (#8B4513)
- Red tomato sauce covering surface (#FF4500) with darker spots (#8B0000)
- Melted yellow cheese dripping down (#FFD700)
- 6 pepperoni tentacles extending from edges (animated)
- 2 asymmetrical eyes: one large (8×8px), one small (6×6px)
- Eyes are white (#FFFFFF) with red pupils (#FF0000)
- Eyes have evil/menacing expression
- Small bubbles of heat rising (2-3 particles per frame)

COLOR PALETTE:
#0F0F0F — Black (outlines, depths)
#8B4513 — Brown (crust)
#D2691E — Light brown (crust highlights)
#FF4500 — Bright red (sauce)
#8B0000 — Dark red (burnt spots)
#FFD700 — Yellow (cheese)
#FFA500 — Orange (cheese shading)
#FFFFFF — White (eyes)

TENTACLE DESIGN:
- Each tentacle: 12-16 pixels long, 4-6 pixels wide
- Made of curled pepperoni texture
- Darker red/brown gradient
- Tentacles should wave/undulate

ANIMATION (4 frames, idle):
Frame 1: Tentacles in neutral position
Frame 2: Tentacles wave slightly outward (2px)
Frame 3: Tentacles return to neutral
Frame 4: Tentacles wave slightly inward (2px)
[Loop back to Frame 1]

ADDITIONAL DETAILS:
- 3-4 cheese drips hanging down (8-12px long, animated dripping)
- Small heat particles (2×2 pixels) rising from surface
- Burnt/charred spots on pizza surface for texture
- Give it personality: angry but comical

STYLE REFERENCES:
- Enemy design like: Kirby bosses, Pizza Tower
- Grotesque but not too scary
- Exaggerated features for readability
- Thick black outlines (1px)

VERIFICATION CHECKLIST:
☐ Exactly 192×48 pixels (4 frames of 48×48)
☐ Circular pizza shape maintained
☐ 6 tentacles visible and animated
☐ Eyes convey personality
☐ Cheese drips animated
☐ Only uses specified color palette
☐ Transparent background
☐ No anti-aliasing
```

---

## Sprite 5: Sushi Viviente (Enemigo Común)

### 🎮 GAME CONTEXT (Contexto del Juego)
**Qué es este enemigo:**
- Sushi Viviente es un enemigo COMÚN (tier bajo) del Mundo 2: Restaurante Abandonado
- Amalgama Culinaria basada en nigiri sushi con ojos saltones y personalidad tonta
- Aparece en la parte SUPERIOR de la pantalla como todos los enemigos
- Más pequeño que Pizza de Lava (32×32 vs 48×48) = menos amenazante
- Concepto: cute-horror — se ve adorable pero está atacándote

**Rol en gameplay:**
- Enemigo débil, bueno para farmear oro rápidamente
- Se derrota fácil pero aparece en grupos grandes
- Animación simple de 3 frames (más barato en memoria)
- Dispara pequeños proyectiles de wasabi/jengibre

**Estética:**
- Estilo "Kirby enemy" — lindo pero peligroso
- Colores: rosa (salmón), blanco (arroz), verde oscuro (alga nori)
- Ojos ENORMES y expresivos (confundido/sorprendido)
- Debe verse tonto pero entrañable

---

### 📝 PROMPT COMPLETO PARA IA

```
GAME: Paleto Knife — 8-bit pixel art mobile RPG where a chef fights mutant food creatures

ENEMY: Sushi Viviente (Living Sushi)
TYPE: Common Enemy (Culinary Amalgam - low tier)
WORLD: Mundo 2 — Abandoned Restaurant
ROLE: Weak common enemy, cute but creepy, appears at TOP of screen
CONCEPT: Nigiri sushi with huge googly eyes, nori belt wrap, adorable but possessed

Create a pixel art enemy sprite for a living sushi creature in 8-bit NES cute-horror style.

═══════════════════════════════════════════════════════════════

🎯 TECHNICAL SPECIFICATIONS:
- Dimensions: 96×32 pixels (3 frames of 32×32 each, horizontal idle animation)
- Style: NES pixel art ENEMY (like Kirby enemies — cute but dangerous)
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent (PNG with alpha)

ENEMY DESIGN:
- Nigiri sushi shape: rectangular base of rice with salmon on top
- Rice base: white (#FFFFFF) with grain texture (subtle dithering)
- Salmon slice: pink (#FF69B4) with white fat lines
- Nori (seaweed) wrap: dark green (#006400) around middle like a belt
- 2 huge bulging eyes on rice portion (8×8 pixels each)
- Eyes are white with black pupils (googly/surprised expression)
- Tiny mouth with 2-3 rice grain "teeth"
- Small soy sauce drops falling from sides

COLOR PALETTE:
#0F0F0F — Black (outlines, pupils)
#FFFFFF — White (rice)
#F0F0F0 — Off-white (rice highlights)
#DEDEDE — Light gray (rice shadows)
#FF69B4 — Hot pink (salmon)
#FF1493 — Deeper pink (salmon shadows)
#006400 — Dark green (nori)
#8B4513 — Brown (soy sauce drops)

BODY PROPORTIONS:
- Width: 28 pixels
- Height: 24 pixels
- Rice base: 18 pixels tall
- Salmon top: 8 pixels tall
- Nori wrap: 4 pixels tall (center)

ANIMATION (3 frames, idle):
Frame 1: Eyes normal, nori straight
Frame 2: Eyes blink (smaller), nori wavy (slight movement)
Frame 3: Eyes open wide, nori slightly animated
[Loop back to Frame 1]

ADDITIONAL DETAILS:
- 2-3 soy sauce drops (2×2 pixels) dripping slowly
- Subtle rice grain texture (1-2 pixel dots)
- White fat lines on salmon (2-3 horizontal lines, 1 pixel thick)
- Nori should look slightly wet/shiny
- Give eyes personality: confused/surprised look

STYLE REFERENCES:
- Cute enemies like: Kirby series, Yoshi's Island
- Simple but expressive
- Comedic rather than threatening
- Clear silhouette

VERIFICATION CHECKLIST:
☐ Exactly 96×32 pixels (3 frames of 32×32)
☐ Rectangular sushi shape clear
☐ Eyes are huge and expressive
☐ Nori wraps around middle
☐ Salmon on top has fat lines
☐ Only uses 8 specified colors
☐ Transparent background
☐ Animation is subtle but visible
```

---

## Sprite 6: Ensalada Carnívora

### Prompt de Generación
```
Create a pixel art enemy sprite for a carnivorous salad monster in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 192×48 pixels (4 frames of 48×48 each, horizontal idle animation)
- Style: Plant horror monster, NES action game aesthetic
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent

ENEMY DESIGN:
- Main body: mass of lettuce leaves in layers (messy, organic)
- 2 cherry tomato eyes: round red (#FF4500) with black pupils
- Huge mouth with sharp carrot teeth (6-8 teeth visible)
- Cucumber tongue hanging out (green #32CD32)
- Multiple lettuce leaves acting as tentacles/arms
- Ranch dressing fluid dripping from leaves
- Aggressive, hungry expression

COLOR PALETTE:
#0F0F0F — Black (outlines, pupils, mouth interior)
#32CD32 — Lime green (lettuce)
#228B22 — Forest green (lettuce shadows)
#90EE90 — Light green (lettuce highlights, cucumber)
#FF4500 — Red-orange (cherry tomato eyes)
#FF8C00 — Dark orange (carrot teeth)
#FFFFFF — White (ranch dressing)
#E0E0E0 — Off-white (dressing shading)

BODY STRUCTURE:
- Roughly 40×40 pixels (fills most of frame)
- Lettuce leaves in 3-4 layers (depth)
- Mouth opening: 20×16 pixels (large and menacing)
- Teeth: Each 4×8 pixels, pointed
- Eyes: positioned asymmetrically (one higher)

ANIMATION (4 frames, idle):
Frame 1: Leaves spread out, mouth open
Frame 2: Leaves trembling/shaking (offset by 1-2 pixels)
Frame 3: Leaves contracting slightly, mouth wider
Frame 4: Leaves trembling opposite direction
[Loop back to Frame 1]

ADDITIONAL DETAILS:
- 4-6 lettuce leaf "tentacles" extending from main mass
- Leaves should be jagged/torn looking (organic edges)
- Carrot teeth should be sharp and prominent
- Cucumber tongue - animated licking/moving
- 3-4 ranch dressing drips (8-12 pixels long)
- Cherry tomato eyes should look crazed/hungry
- Small pepper flakes scattered on surface (black dots)

STYLE REFERENCES:
- Plant enemies like: Super Mario Piranha Plants, Castlevania Medusa heads
- Threatening but cartoonish
- Organic, flowing shape
- Exaggerated features (big mouth, teeth)

VERIFICATION CHECKLIST:
☐ Exactly 192×48 pixels (4 frames of 48×48)
☐ Lettuce leaves clearly visible in layers
☐ Mouth and teeth are prominent
☐ Cherry tomato eyes expressive
☐ Leaves animated/trembling
☐ Only uses 8 specified colors
☐ Transparent background
☐ Has personality: hungry and dangerous
```

---

## Sprite 7: Golem de Pan (Boss)

### Prompt de Generación
```
Create a pixel art enemy sprite for a giant bread golem boss in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 256×64 pixels (4 frames of 64×64 each, horizontal idle animation)
- Style: Imposing boss character, NES Castlevania/Mega Man boss aesthetic
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent

ENEMY DESIGN:
- Humanoid body made from giant toasted baguette
- Broad shoulders, massive arms (disproportionately large)
- Legs shorter and sturdier (tree trunk style)
- Head: rounded bread loaf with deep hollow eyes
- Crust texture: brown/golden with cracks and fissures
- Exposed white bread crumb interior in cracks
- Green mold growing on shoulders and joints (#32CD32)
- Seeds (sesame/poppy) scattered on surface
- Breadcrumbs constantly falling from body (particles)

COLOR PALETTE:
#0F0F0F — Black (eye sockets, deep shadows, outlines)
#8B4513 — Dark brown (toasted crust)
#D2691E — Orange-brown (crust midtone)
#DEB887 — Tan (lighter crust areas)
#FFE5B4 — Beige (exposed bread crumb)
#FFFFFF — White (fresh crumb interior)
#32CD32 — Lime green (mold)
#006400 — Dark green (mold shadows)
#8B7355 — Brown-gray (sesame seeds)

BODY PROPORTIONS:
- Total height: 60 pixels (in frame)
- Head: 16×16 pixels
- Torso: 20×32 pixels
- Arms: 12 pixels wide, 40 pixels long
- Legs: 16 pixels wide, 24 pixels tall

SPECIFIC FEATURES:
- Eyes: Two deep black voids (8×8 pixels each), no pupils (scary/empty)
- Arms: Massive, hang down past hips, knuckles visible
- Fists: Large, blocky, cracked crust knuckles
- Shoulders: Green mold patches (8×8 pixel areas)
- Torso: Vertical crack down center showing white crumb
- Texture: Cross-hatch pattern on crust (diagonal lines 1px)
- Seeds: 1×1 pixel dots scattered (8-12 seeds)

ANIMATION (4 frames, boss idle):
Frame 1: Neutral standing pose, breathing
Frame 2: Chest expands slightly (1-2px), breadcrumbs fall
Frame 3: Return to neutral, different breadcrumb positions
Frame 4: Chest contracts, fists clench slightly
[Loop back to Frame 1]

PARTICLE EFFECTS:
- 6-8 breadcrumb particles per frame (2×2 pixels)
- Crumbs fall downward at different speeds
- Color: #FFE5B4 (beige)
- Position varies randomly near body

MOOD:
- Imposing and slow
- Ancient/decaying
- Silent menace
- Heavy, lumbering presence

STYLE REFERENCES:
- Boss design like: Mega Man bosses, Zelda stone guardians
- Clear silhouette even at distance
- Thick outlines (1-2px for boss presence)
- Detailed but readable
- Intimidating size

VERIFICATION CHECKLIST:
☐ Exactly 256×64 pixels (4 frames of 64×64)
☐ Humanoid shape clear
☐ Arms are disproportionately large
☐ Eyes are deep and empty (scary)
☐ Mold visible on body
☐ Breadcrumbs animated and falling
☐ Texture details visible but not cluttered
☐ Only uses 9 specified colors
☐ Transparent background
☐ Looks like a boss (intimidating)
```

---

## Sprite 8: Taco del Caos (Final Boss)

### Prompt de Generación
```
Create a pixel art enemy sprite for the final boss: a giant cosmic chaos taco in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 576×96 pixels (6 frames of 96×96 each, horizontal idle animation)
- Style: Epic final boss, NES final boss aesthetic with cosmic horror elements
- Grid: Aligned to 16×16 pixel grid
- Background: Transparent

ENEMY DESIGN:
- Giant taco shell (hard shell, U-shaped)
- Golden crispy tortilla with shine highlights
- Multiple living ingredients spilling out:
  - Red ground beef with texture
  - Green lettuce flowing out sides
  - Yellow melted cheese cascading
  - Red and green salsa dripping
- 4 eyes total: one on each ingredient (meat, lettuce, cheese, shell)
- Dark aura/energy surrounding entire taco
- Small ingredient "satellites" orbiting around it
- Menacing but absurd appearance

COLOR PALETTE:
#0F0F0F — Black (outlines, aura, pupils)
#3A0F7F — Dark purple (cosmic aura)
#FFD700 — Golden yellow (tortilla shell)
#FFA500 — Orange (tortilla shadows)
#8B4513 — Brown (shell edges, toasted)
#FF0000 — Bright red (beef, salsa)
#8B0000 — Dark red (beef shadows)
#32CD32 — Lime green (lettuce)
#228B22 — Forest green (lettuce depth)
#FFFF00 — Yellow (cheese)
#FFFFFF — White (highlights, eyes)

BODY STRUCTURE:
- Shell: 70 pixels wide, 60 pixels tall (U-shape)
- Tortilla thickness: 6-8 pixels
- Ingredients fill interior: 50×45 pixel area
- Eyes: 8×8 pixels each, positioned on different ingredients
- Aura: 8-12 pixel extension beyond body

SPECIFIC FEATURES:
- Tortilla shell: Golden with dark brown edge, diagonal line texture
- Ground beef: Chunky texture, multiple red tones
- Lettuce: Flowing out left and right sides (ribbon-like)
- Cheese: Melted, dripping downward (6-8 drip strands)
- Salsa: Both red and green, mixed, dripping
- Eyes: Horror-style, pupils looking in different directions
- Aura: Dark purple/black energy, wispy, animated

ANIMATION (6 frames, final boss idle):
Frame 1: Neutral floating pose, aura stable
Frame 2: Float up 2 pixels, aura expands outward
Frame 3: Ingredients shift slightly (beef bulges)
Frame 4: Float down 2 pixels, aura contracts
Frame 5: Ingredients shift again (cheese drips more)
Frame 6: Return to neutral, eyes blink
[Loop back to Frame 1]

ORBITING SATELLITES:
- 4 small ingredients orbit around main body
  - 1 tomato (8×8px, red)
  - 1 lettuce chunk (8×8px, green)
  - 1 cheese cube (8×8px, yellow)
  - 1 pepper (8×8px, red)
- Orbit radius: 40-50 pixels from center
- Position changes each frame (rotation)

EFFECTS:
- Dark aura pulses (alternates between 8px and 12px thickness)
- Cheese drips animate downward
- Salsa splashes occasionally
- Eyes occasionally all look at camera simultaneously (creepy)
- Small particle effects around aura (purple dots 2×2px)

MOOD & PERSONALITY:
- Cosmic horror meets absurd humor
- Multiple eyes give it alien/eldritch feel
- Living ingredients create chaos
- Imposing size and presence
- Final boss energy: intimidating but ridiculous

STYLE REFERENCES:
- Final bosses like: Mother Brain (Metroid), Giygas (Earthbound)
- Kirby boss absurdity
- Multiple phases implied by complex design
- Epic scale

VERIFICATION CHECKLIST:
☐ Exactly 576×96 pixels (6 frames of 96×96)
☐ Taco shape clear and recognizable
☐ 4 eyes visible on different ingredients
☐ All ingredients identifiable (beef, lettuce, cheese, salsa)
☐ Dark aura surrounds entire sprite
☐ 4 satellites orbit in each frame
☐ Animation shows floating/pulsing
☐ Only uses 11 specified colors
☐ Transparent background
☐ Looks epic and final-boss-worthy
☐ Balance between horror and comedy
```

---

# 🔪 CUCHILLOS — Armas del Chef

## Sprite 9: Cuchillo Común (Rareza 1 — Starter Weapon)

### 🎮 GAME CONTEXT (Contexto del Juego)
**Qué es este item:**
- Arma INICIAL del Chef Maestro — el primer cuchillo que tienes
- Se ve simple, básico, utilitarian (cuchillo de cocina común)
- En gameplay: el Chef LANZA estos cuchillos como proyectiles hacia arriba
- Los cuchillos ROTAN mientras vuelan (spin animation)
- Sistema de rareza: Común < Raro < Épico < Legendario < Mítico

**Rol en gameplay:**
- Arma básica tier 1 (la más débil pero confiable)
- Tamaño pequeño: 16×16 px (cabe en inventario, se ve rápido en vuelo)
- Sin efectos especiales (solo acero plateado simple)
- Los jugadores la reemplazan rápido pero es icónica (primera arma)

**Estética:**
- Debe verse como un cuchillo de chef REAL pero pixelado
- Colores: plata/gris (acero), marrón (mango de madera)
- Simple y limpio — establece el estándar visual para armas
- Inspiración: items de NES Zelda, Castlevania

---

### 📝 PROMPT COMPLETO PARA IA

```
GAME: Paleto Knife — 8-bit pixel art mobile RPG about a chef throwing knives at food monsters

ITEM: Cuchillo Común (Common Chef's Knife)
TYPE: Weapon — Starter Tier (Rarity 1 of 5)
ROLE: Projectile weapon thrown by player, rotates while flying upward
CONCEPT: Basic utilitarian chef's knife, silver steel blade + wooden handle

Create a pixel art weapon sprite for a basic chef's knife in 8-bit NES item style.

═══════════════════════════════════════════════════════════════

🎯 TECHNICAL SPECIFICATIONS:
- Dimensions: 16×16 pixels (single frame, static item sprite)
- Style: NES weapon/item sprite (like Zelda swords, Mega Man weapons)
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent (PNG with alpha)

WEAPON DESIGN:
- Classic chef's knife profile (side view)
- Silver steel blade: 10 pixels long, 3 pixels wide at widest
- Dark brown wooden handle: 5 pixels long, 2-3 pixels wide
- Blade has subtle highlight line (1 pixel white)
- Simple, utilitarian design
- 45° angle orientation (diagonal)

COLOR PALETTE:
#0F0F0F — Black (outline)
#C0C0C0 — Silver (blade main)
#DEDEDE — Light silver (blade highlight)
#8B8B8B — Dark silver (blade shadow)
#8B4513 — Dark brown (handle)
#A0522D — Saddle brown (handle midtone)

BLADE DETAILS:
- Pointed tip (sharp triangle)
- Straight edge on top
- Slight curve on cutting edge (bottom)
- Single white highlight line along blade length (1px)
- No special effects or glows

HANDLE DETAILS:
- Simple cylindrical shape
- Dark to light gradient (2 tones only)
- Small rivet dots (1px each, 2 rivets)
- Rectangular guard between blade and handle (2×2px)

STYLE:
- Clean and simple
- Readable at small size
- No embellishments
- Starting-tier weapon aesthetic

VERIFICATION CHECKLIST:
☐ Exactly 16×16 pixels
☐ Knife fits within frame with small margin
☐ Only uses 6 colors specified
☐ Black outline (1px) around entire knife
☐ Blade has highlight
☐ Handle has basic detail
☐ Transparent background
☐ Looks like common/starter weapon
```

---

## Sprite 10: Santoku Azul (Rarity 2 - Raro)

### Prompt de Generación
```
Create a pixel art weapon sprite for a rare blue santoku knife in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 16×16 pixels (single frame, static)
- Style: NES weapon sprite with magical blue glow
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

WEAPON DESIGN:
- Japanese santoku knife profile (side view)
- Blue-tinted steel blade with magical shine
- Black handle with blue accents
- Small blue sparkle effect (1-2 particles)
- 45° angle orientation (diagonal)

COLOR PALETTE:
#0F0F0F — Black (outline, handle base)
#4A90E2 — Bright blue (blade main)
#6BB6FF — Sky blue (blade highlight)
#2B5A8F — Navy blue (blade shadows)
#1C1C1C — Dark gray (handle)
#4A90E2 — Blue (handle accent)
#FFFFFF — White (sparkle)

BLADE DETAILS:
- Santoku shape: straighter edge, less pointed tip
- Blue metallic appearance
- Two highlight lines (white and light blue)
- Granton edge (small dimples on blade, 2-3 dimples, 1px each)
- Slight blue aura (1px around blade)

HANDLE DETAILS:
- Modern black handle
- Blue accent line down center (1px)
- Ergonomic shape (slightly wider in middle)
- Silver rivet (1px, white)

SPECIAL EFFECTS:
- 1 blue sparkle particle (2×2px) near tip
- Faint blue glow outline (1px)
- Sparkle uses #FFFFFF (white) and #6BB6FF (blue)

STYLE:
- Clearly better than common knife
- Magical/special appearance
- Rare tier visual upgrade
- Cool color palette

VERIFICATION CHECKLIST:
☐ Exactly 16×16 pixels
☐ Santoku shape distinct from common knife
☐ Only uses 7 colors specified
☐ Blue color dominant
☐ Small sparkle effect visible
☐ Looks rarer/better than common
☐ Transparent background
```

---

## Sprite 11: Daga Púrpura (Rarity 3 - Épico)

### Prompt de Generación
```
Create a pixel art weapon sprite for an epic purple ornate dagger in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 16×16 pixels (single frame, static)
- Style: NES epic weapon with magical effects
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

WEAPON DESIGN:
- Ornate dagger with elegant curves
- Purple-tinted mystical blade
- Golden handle with gem inlay
- Multiple sparkle particles (2-3)
- Purple glow effect
- 45° angle orientation (diagonal)

COLOR PALETTE:
#0F0F0F — Black (outline)
#9B59B6 — Royal purple (blade main)
#D291FF — Light purple (blade highlight)
#6A3A7C — Dark purple (blade shadow)
#FFD700 — Gold (handle)
#FFA500 — Orange-gold (handle shadow)
#FF00FF — Magenta (gem)
#FFFFFF — White (sparkles, highlights)

BLADE DETAILS:
- Elegant curved blade (8-10 pixels long)
- Purple mystical metal
- Wavy magical pattern along blade (1px)
- Sharp pointed tip
- Multiple highlights (2-3 white pixels)
- Purple glow extends 1-2 pixels beyond blade

HANDLE DETAILS:
- Gold/brass material
- Ornate guard (cross shape, 4×4px)
- Central gem embedded (2×2px, magenta/hot pink)
- Decorative pommel at end (rounded, 2×2px)
- Engravings suggested (1px lines)

SPECIAL EFFECTS:
- 2-3 purple sparkle particles (2×2px each)
- Purple aura glow (2px around blade)
- Gem should glint/shine
- Sparkles positioned at: tip, middle, handle

STYLE:
- Epic tier appearance
- Ornate and detailed
- Magical/mystical aura
- Clearly superior to rare tier
- Fantasy RPG aesthetic

VERIFICATION CHECKLIST:
☐ Exactly 16×16 pixels
☐ Ornate design visible
☐ Only uses 8 colors specified
☐ Purple dominates color scheme
☐ Gold handle visible
☐ Gem visible and prominent
☐ 2-3 sparkles present
☐ Purple glow effect around blade
☐ Looks epic tier (very special)
☐ Transparent background
```

---

## Sprite 12: Cuchillo Dorado Legendario (Rarity 4)

### Prompt de Generación
```
Create a pixel art weapon sprite for a legendary golden ornate knife in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 16×16 pixels (single frame, static)
- Style: NES legendary weapon with intense effects
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

WEAPON DESIGN:
- Magnificent golden chef's knife
- Blade and handle entirely golden
- Multiple embedded rubies/gems
- Intense aura and particle effects
- Holy/divine appearance
- 45° angle orientation (diagonal)

COLOR PALETTE:
#8B4513 — Dark brown (outline, shadows)
#FFD700 — Pure gold (blade and handle main)
#FFFF00 — Bright yellow (highlights)
#FFA500 — Orange-gold (mid tones)
#FF4500 — Red-orange (deep shadows)
#FF0000 — Red (rubies)
#8B0000 — Dark red (ruby shadows)
#FFFFFF — White (intense shine, sparkles)

BLADE DETAILS:
- Majestic blade (10 pixels long)
- Entirely golden, no steel
- Multiple white highlight lines (3-4 lines)
- Ornate engravings (curved lines, 1px)
- Shining effect (alternating gold tones)
- Pointed prestigious tip

HANDLE DETAILS:
- Solid gold handle
- 3 ruby gems embedded (2×2px each)
- Intricate cross-guard (6×4px, ornate shape)
- Decorated pommel with center ruby
- Filigree patterns (1px decorative lines)

SPECIAL EFFECTS:
- 4-5 golden sparkles (2×2px each) surrounding knife
- Intense yellow glow (3px radius)
- Sparkles in various positions: top, bottom, sides
- Shine lines radiating from blade (3-4 lines, diagonal)
- Pulsing effect suggested by multiple glow intensities

STYLE:
- Legendary tier, obviously powerful
- Divine/holy weapon aesthetic
- Maximum detail within 16×16 constraint
- Radiates power visually
- Treasure-quality appearance

VERIFICATION CHECKLIST:
☐ Exactly 16×16 pixels
☐ Entirely golden (no silver)
☐ 3+ rubies visible
☐ 4-5 sparkles around knife
☐ Intense glow effect (3px)
☐ Shine lines visible
☐ Only uses 8 colors specified
☐ Brown outline instead of black (distinctive)
☐ Looks legendary (best so far)
☐ Transparent background
```

---

## Sprite 13: Cristal Mítico Arcoíris (Rarity 5 - Mítico)

### Prompt de Generación
```
Create a pixel art weapon sprite for a mythic crystal rainbow knife in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 16×16 pixels (single frame, WILL animate with 4 frame variant)
- Style: NES ultimate weapon with prismatic effects
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

WEAPON DESIGN:
- Crystalline blade (transparent/prismatic appearance)
- Arcane mystical handle with runes
- Rainbow halo effect surrounding entire knife
- Multiple colored particles orbiting
- Cosmic/otherworldly appearance
- 45° angle orientation (diagonal)

COLOR PALETTE:
#FFFFFF — White (outline, crystal core)
#FF1493 — Hot pink (primary mythic color)
#FF00FF — Magenta (blade accent)
#00FFFF — Cyan (crystal facets)
#FFFF00 — Yellow (particles)
#00FF00 — Lime green (particles)
#4B0082 — Indigo (handle runes)
#9400D3 — Dark violet (handle base)
#FFD700 — Gold (accents)

BLADE DETAILS:
- Crystalline blade (8-10 pixels), appears translucent
- Geometric facets (triangular shapes, 2-3 visible)
- Rainbow light refracts through it
- White core with colored edges
- Prismatic effect (multiple colors at edges)
- Appears to glow from within

HANDLE DETAILS:
- Mystical purple/violet base
- Glowing indigo runes (3-4 tiny runes, 1-2px each)
- Arcane symbols etched
- Crystal pommel (glowing)
- Guard has cosmic energy motif

SPECIAL EFFECTS:
- 6-8 particles orbiting knife (2×2px each)
- Particles are different colors: pink, yellow, cyan, green
- Large rainbow aura (4px radius)
- Aura has multiple color layers (gradual rainbow)
- Star sparkles (4-pointed stars, 2px)
- Energy trails suggested

RAINBOW AURA LAYERS (from outside to inside):
- Layer 1 (outer): Pink #FF1493
- Layer 2: Magenta #FF00FF
- Layer 3: Cyan #00FFFF
- Layer 4 (inner): White #FFFFFF (blade)

STYLE:
- Mythic tier, ultimate weapon
- Otherworldly, magical, cosmic
- Maximum visual effects
- Most detailed and colorful
- Legendary status obvious at glance
- Should make player feel powerful

VERIFICATION CHECKLIST:
☐ Exactly 16×16 pixels
☐ Crystal blade appearance (translucent looking)
☐ Rainbow effect visible
☐ 6-8 colored particles
☐ 4px rainbow aura
☐ Runes visible on handle
☐ White outline (distinctive from other tiers)
☐ Only uses 9 colors specified
☐ Most impressive looking weapon
☐ Transparent background
☐ Clearly mythic tier (ultimate)

---

ANIMATION VARIANT (4 frames):
Create 4 frames (64×16 pixels total) where:
- Frame 1: Particles at positions: 0°, 90°, 180°, 270°
- Frame 2: Particles rotated 22.5°
- Frame 3: Particles rotated 45°
- Frame 4: Particles rotated 67.5°
- Aura pulses slightly (alternates between 3px and 4px)
```

---

# 🎨 UI ELEMENTS

## Sprite 14: Iconos de Moneda (Top HUD)

### Prompt de Generación
```
Create a pixel art icon set for game currencies in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 48×16 pixels (3 icons of 16×16 each, horizontal layout)
- Style: Clean NES UI icons
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

---

ICON 1: ORO (Gold Coin)
Position: Pixels 0-16 (left)

DESIGN:
- Circular gold coin (12×12 pixels)
- Front-facing view
- Shiny metallic appearance
- Center symbol: $ or decorative pattern

COLORS:
#0F0F0F — Black (outline)
#FFD700 — Gold (main)
#FFFF00 — Yellow (highlights)
#FFA500 — Orange (shadows)
#8B4513 — Brown (edge)

DETAILS:
- Circular shape, perfect circle
- Shine spot top-right (2×2px bright yellow)
- Edge of coin visible (1px brown band)
- Center has embossed $ symbol (4×6px)
- Gradient from gold to orange (left to right)

---

ICON 2: FRAGMENTOS (Blue Gem)
Position: Pixels 16-32 (center)

DESIGN:
- Geometric gem shape (diamond/crystal)
- Bright blue with facets
- Sparkling appearance
- Front-facing view

COLORS:
#0F0F0F — Black (outline)
#4A90E2 — Bright blue (main)
#00FFFF — Cyan (highlights)
#2B5A8F — Navy (shadows)
#FFFFFF — White (shine)

DETAILS:
- Hexagonal gem shape (10×12 pixels)
- Multiple facets (3-4 geometric segments)
- Top has bright white shine (2×2px)
- Facets show different blue tones
- Crystal clear appearance
- Small sparkle (1px) at top-right

---

ICON 3: TOKENS (Golden Ticket)
Position: Pixels 32-48 (right)

DESIGN:
- Rectangular ticket/token
- Golden with red stripes
- Front-facing view
- Fancy/premium appearance

COLORS:
#0F0F0F — Black (outline, text)
#FFD700 — Gold (base)
#FFFF00 — Yellow (highlights)
#FF0000 — Red (stripes)
#8B0000 — Dark red (stripe shadows)

DETAILS:
- Rectangle shape (12×10 pixels)
- Gold background
- 2 red horizontal stripes across (2px tall each)
- Small text/number in center (1-2 tiny marks)
- Slight 3D depth (darker edge on bottom-right)
- Corner notches (1px, ticket style)

---

GENERAL STYLE:
- All three icons same visual weight
- Consistent outline thickness (1px black)
- Clearly distinguishable from each other
- Readable at small size
- Fit within 16×16 frame with 2px margin

VERIFICATION CHECKLIST:
☐ Exactly 48×16 pixels (3 icons of 16×16)
☐ Each icon centered in its 16×16 space
☐ Gold coin is circular and shiny
☐ Gem has facets and sparkle
☐ Ticket has stripes and looks premium
☐ All use only specified colors
☐ Consistent outline style
☐ Transparent background
☐ Icons clearly distinguishable
```

---

## Sprite 15: Bottom Navigation Icons

### Prompt de Generación
```
Create a pixel art icon set for navigation bar in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 160×32 pixels (5 icons of 32×32 each, horizontal layout)
- Style: Clean NES UI icons, bold and simple
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

---

ICON 1: COMBATE (Crossed Swords)
Position: Pixels 0-32 (leftmost)

DESIGN:
- Two swords crossed in X formation
- Silver blades
- Front-facing view
- Action/battle symbolism

COLORS:
#0F0F0F — Black (outline)
#C0C0C0 — Silver (blades)
#DEDEDE — Light silver (highlights)
#8B8B8B — Dark silver (shadows)
#8B4513 — Brown (handles)

DETAILS:
- Each sword: 24 pixels long, 4 pixels wide
- Crossed at center (45° angles)
- Blade highlights (1px lines)
- Simple handles (4×6 pixels each)
- Clean silhouette

---

ICON 2: COCINA (Pan with Fire)
Position: Pixels 32-64

DESIGN:
- Frying pan from side view
- Flames underneath
- Cooking/crafting symbolism

COLORS:
#0F0F0F — Black (outline, pan details)
#4A4A4A — Dark gray (pan)
#6B6B6B — Medium gray (pan highlights)
#FF4500 — Orange-red (flames)
#FFFF00 — Yellow (flame tips)

DETAILS:
- Pan: 20×8 pixel oval (horizontal)
- Handle: 10 pixels long, 2 pixels wide
- 3 flame shapes under pan (4-6 pixels tall each)
- Flames animated look (even if static frame)
- Pan slightly tilted

---

ICON 3: TÉCNICAS (Star with Lightning)
Position: Pixels 64-96 (center)

DESIGN:
- 4-pointed star
- Lightning bolt through center
- Magic/power symbolism

COLORS:
#0F0F0F — Black (outline)
#FFD700 — Gold (star)
#FFFF00 — Bright yellow (star highlights)
#FFFFFF — White (lightning bolt)
#4A90E2 — Blue (lightning shadow/effect)

DETAILS:
- Star: 20×20 pixels (4 main points)
- Lightning: 12 pixels tall, zigzag through center
- Star points are 6-8 pixels long each
- Lightning bolt 3-4 pixels wide
- Slight glow effect around star (optional 1px)

---

ICON 4: EQUIPO (Backpack)
Position: Pixels 96-128

DESIGN:
- Chef's backpack/bag
- Front-facing view
- Inventory/equipment symbolism

COLORS:
#0F0F0F — Black (outline, straps)
#8B4513 — Saddle brown (bag main)
#A0522D — Light brown (bag highlights)
#654321 — Dark brown (bag shadows)
#C0C0C0 — Silver (buckles)

DETAILS:
- Rounded rectangular bag (18×20 pixels)
- Two straps (3 pixels wide each)
- Front pocket (8×6 pixels)
- 2 silver buckles (3×3 pixels each)
- Slight 3D depth

---

ICON 5: PERFIL (Chef Silhouette)
Position: Pixels 128-160 (rightmost)

DESIGN:
- Silhouette of chef head and hat
- Front-facing view
- Profile/settings symbolism

COLORS:
#0F0F0F — Black (outline)
#FFFFFF — White (silhouette fill)
#E0E0E0 — Light gray (shading)

DETAILS:
- Chef hat: 16 pixels wide, 12 pixels tall (puffy top)
- Head: 16×16 pixel circle/oval below hat
- Minimalist face (2 dot eyes, small smile - optional)
- Simple and iconic
- Clear chef identity

---

GENERAL STYLE:
- All icons same visual weight and complexity
- Bold, simple shapes
- Easily recognizable at small size
- Consistent 1-2px black outlines
- Centered in 32×32 frame

VERIFICATION CHECKLIST:
☐ Exactly 160×32 pixels (5 icons of 32×32)
☐ Each icon centered in its 32×32 space
☐ All icons clearly represent their function
☐ Consistent outline thickness
☐ Only use specified colors per icon
☐ Icons distinguishable from each other
☐ Transparent background
☐ Readable at UI size
```

---

# 🌍 FONDOS (BACKGROUNDS)

## Sprite 16: Mundo 1 - Cocina Infernal (3 Capas Parallax)

### Prompt de Generación
```
Create a parallax background set for a hellish kitchen level in 8-bit NES style.

TECHNICAL SPECS:
- Total Dimensions: 1280×540 pixels (3 separate layers)
  - Layer 1 (Back): 1280×180 pixels
  - Layer 2 (Mid): 1280×180 pixels  
  - Layer 3 (Front): 1280×180 pixels
- Style: NES action game background, Castlevania/Mega Man aesthetic
- Grid: Aligned to 16×16 pixel grid
- Format: 3 separate PNG files
- Background: NOT transparent (solid backgrounds)

---

LAYER 1 (BACKGROUND) — "Horno y Brasas"
File: bg_world01_layer01.png
Dimensions: 1280×180 pixels
Parallax Speed: 0.2x (slowest)

CONTENT:
- Massive brick oven/furnace in background
- Glowing red coals and flames visible inside
- Dark red/orange sky (hellish atmosphere)
- Distant kitchen equipment silhouettes

COLOR PALETTE:
#8B0000 — Dark red (base sky)
#B22222 — Firebrick red (mid tones)
#FF4500 — Orange-red (flames)
#4A4A4A — Dark gray (bricks)
#6B6B6B — Medium gray (brick highlights)
#0F0F0F — Black (shadows, dark areas)

DETAILS:
- Central large oven opening: 200×120 pixels
- Brick texture (8×4 pixel bricks in pattern)
- Red glow emanating from oven (gradient)
- Smoke/heat waves at top (wavy lines)
- Coals visible in oven (small red/orange pixels)
- Very atmospheric, depth suggested

---

LAYER 2 (MIDGROUND) — "Estanterías y Utensilios"
File: bg_world01_layer02.png
Dimensions: 1280×180 pixels
Parallax Speed: 0.5x (medium)

CONTENT:
- Metal shelving units with cooking tools
- Hanging pots and pans
- Utensil racks
- Industrial kitchen equipment

COLOR PALETTE:
#1C1C1C — Very dark gray (background shadows)
#4A4A4A — Dark gray (metal shelves)
#6B6B6B — Medium gray (metal highlights)
#C0C0C0 — Light silver (pots, pans)
#8B4513 — Saddle brown (wooden handles)
#8B0000 — Dark red (accent lighting from layer 1)

DETAILS:
- 3-4 shelf units spanning the width
- Hanging hooks with pots (every 80-100 pixels)
- Utensils visible: ladles, knives, spatulas
- Shelf depth suggested by gray tones
- Items partially silhouetted
- Semi-transparent elements (alpha 80%) to not obscure gameplay

---

LAYER 3 (FOREGROUND) — "Mesón de Trabajo"
File: bg_world01_layer03.png
Dimensions: 1280×180 pixels
Parallax Speed: 1.0x (same as gameplay, ground level)

CONTENT:
- Wooden work counter/table at bottom
- Cutting boards
- Small ingredient items scattered
- Floor tiles

COLOR PALETTE:
#8B4513 — Saddle brown (wooden counter)
#A0522D — Sienna brown (counter highlights)
#654321 — Dark brown (counter shadows)
#4A4A4A — Dark gray (floor)
#6B6B6B — Medium gray (floor tiles)
#0F0F0F — Black (tile lines, gaps)

DETAILS:
- Counter spans bottom 60 pixels of height
- Wooden plank texture (horizontal lines, 1px)
- 2-3 cutting boards on counter (small rectangles)
- Scattered items: onion, tomato, knife (tiny sprites 8×8px)
- Floor below counter (bottom 40 pixels)
- Floor has tile pattern (16×16px tiles)
- Counter has slight 3D depth (darker side visible)

---

COMPOSITION NOTES:
- Layer 1 darkest/most atmospheric
- Layer 2 medium detail and opacity
- Layer 3 most detailed but doesn't obstruct play area
- Colors warm throughout (reds, oranges, browns)
- Lighting from oven in back (key light source)
- All layers seamlessly tile horizontally if needed
- Leave center-top and center areas relatively clear for gameplay

VERIFICATION CHECKLIST:
☐ Three separate files created
☐ Layer 1: 1280×180px (back)
☐ Layer 2: 1280×180px (mid)
☐ Layer 3: 1280×180px (front)
☐ Each uses only specified palette
☐ Layers have visual depth distinction
☐ No transparency (solid BGs)
☐ Horizontal tiling seamless
☐ Center gameplay area not obstructed
☐ Hellish kitchen theme clear
☐ NES aesthetic maintained
```

---

# ✨ EFECTOS Y PARTICLES

## Sprite 17: Efectos de Impacto

### Prompt de Generación
```
Create a pixel art effect sprite sheet for combat impacts in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 128×64 pixels (organized grid)
  - Top row (64×32): Normal impact (4 frames, 16×16 each)
  - Bottom row (64×32): Critical impact (4 frames, 16×16 each)
- Style: NES action game effects (Mega Man, Contra style)
- Grid: Aligned to 8×8 pixel grid
- Background: Transparent

---

TOP ROW: IMPACTO NORMAL
Frames 1-4 (16×16 pixels each)

Frame 1 (Initial):
- Small burst center (4×4 pixels)
- Yellow color (#FFFF00)
- 4 pixels radiating from center (north, south, east, west directions)

Frame 2 (Expansion):
- Burst expands (8×8 pixels)
- 8 particles flying outward (2×2 pixels each)
- Particles at 45° intervals (star pattern)
- Colors: #FFFF00 (yellow) and #FFFFFF (white)

Frame 3 (Peak):
- Particles reach maximum distance (12 pixels from center)
- Particles same size (2×2 pixels)
- Colors fading (more white than yellow)
- Center dissipating

Frame 4 (Fade):
- Particles smaller (1×1 pixels)
- Further out (14 pixels from center)
- Very light color (#E0E0E0)
- Effect ending

COLOR PALETTE (Normal):
#0F0F0F — Black (optional outline)
#FFFF00 — Bright yellow (primary)
#FFFFFF — White (highlights)
#FFD700 — Gold (midtone)
#E0E0E0 — Light gray (fade)

---

BOTTOM ROW: IMPACTO CRÍTICO
Frames 1-4 (16×16 pixels each)

Frame 1 (Flash):
- Large white flash (12×12 pixels)
- Cross shape overlaid (8 pixels long arms)
- Colors: #FFFFFF (white), #FFFF00 (yellow)

Frame 2 (Explosion):
- Large starburst (14×14 pixels)
- 8 sharp rays extending from center
- Orange and yellow mix
- Very bright, intense

Frame 3 (Shockwave):
- Ring expanding outward (12 pixel radius)
- 12-16 particles flying in all directions (2×2 each)
- Colors: #FF4500 (orange), #FFFF00 (yellow), #FFFFFF (white)
- More chaotic than normal impact

Frame 4 (Sparkles):
- Multiple 4-pointed stars (3-4 stars, 4×4 pixels each)
- Positioned randomly in frame
- Slowly fading
- Stars yellow/orange/white

COLOR PALETTE (Critical):
#0F0F0F — Black (outline for stars)
#FF4500 — Orange-red (primary)
#FFFF00 — Bright yellow (secondary)
#FFFFFF — White (flash, highlights)
#FFD700 — Gold (particles)

---

ANIMATION TIMING:
- Normal Impact: 4 frames at 20 FPS = 0.2 seconds
- Critical Impact: 4 frames at 15 FPS = 0.27 seconds (slightly slower for emphasis)

STYLE NOTES:
- Normal is quick, clean, simple
- Critical is dramatic, larger, more particles
- Both should read clearly at gameplay speed
- Particles are simple squares (2×2 or 4×4 pixels)
- No complex shapes, keep particles basic

VERIFICATION CHECKLIST:
☐ Exactly 128×64 pixels total
☐ Top row: 4 frames normal impact (16×16 each)
☐ Bottom row: 4 frames critical impact (16×16 each)
☐ Normal uses yellow/white palette
☐ Critical uses orange/yellow/white palette
☐ Frame progression makes sense (expand then fade)
☐ Transparent background
☐ Particles are simple shapes
☐ Critical visibly more impressive than normal
```

---

## Sprite 18: Particles Universales

### Prompt de Generación
```
Create a pixel art particle sprite sheet for various effects in 8-bit NES style.

TECHNICAL SPECS:
- Dimensions: 64×64 pixels (4×4 grid of 16×16 tiles)
- Style: Simple NES particles
- Grid: Each particle centered in 16×16 tile
- Background: Transparent

---

GRID LAYOUT (16 particles):

Row 1 (Yellow/Gold particles):
[1] Sparkle — 4-pointed star (8×8px), yellow/white
[2] Coin glint — Small shine effect (6×6px), gold
[3] Fire spark — Flame shape (6×8px), yellow/orange
[4] Lightning — Small zigzag bolt (4×10px), white/cyan

Row 2 (Blue/Cyan particles):
[5] Water drop — Teardrop shape (4×6px), blue
[6] Ice crystal — 6-pointed star (8×8px), cyan/white
[7] Blue sparkle — Diamond shape (6×6px), blue
[8] Magic wisp — Swirl shape (8×8px), purple/blue

Row 3 (Red/Orange particles):
[9] Blood drop — Rounded drop (4×6px), red
[10] Explosion bit — Irregular shape (6×6px), orange
[11] Critical star — 8-pointed star (8×8px), orange/white
[12] Flame bit — Small flame (5×7px), red/yellow

Row 4 (Misc colors):
[13] Smoke puff — Cloud shape (8×6px), gray
[14] Dust cloud — Irregular cluster (7×5px), tan
[15] Green sparkle — 4-pointed star (6×6px), green
[16] Purple flash — Cross shape (8×8px), purple/pink

---

DETAILED SPECS:

[1] SPARKLE (Yellow):
- 4-pointed star shape
- Center: 2×2 pixels yellow
- 4 arms extending (2 pixels each direction)
- Tips white, base yellow
Colors: #FFFF00 (yellow), #FFFFFF (white)

[2] COIN GLINT (Gold):
- Symmetrical shine lines
- 3 lines crossing at center
- 2×2 pixel bright center
Colors: #FFD700 (gold), #FFFFFF (white)

[3] FIRE SPARK (Orange):
- Upward teardrop/flame shape
- Pointed top, rounded bottom
- 6 pixels wide, 8 pixels tall
Colors: #FFD700 (yellow), #FF4500 (orange)

[4] LIGHTNING (Electric):
- Vertical zigzag
- 2 bends, sharp angles
- 4 pixels wide, 10 pixels tall
Colors: #FFFFFF (white), #00FFFF (cyan)

[5] WATER DROP (Blue):
- Classic teardrop shape
- Rounded bottom, point at top
- 4 pixels wide, 6 pixels tall
- Single white pixel as shine
Colors: #4A90E2 (blue), #FFFFFF (shine)

[6] ICE CRYSTAL (Cyan):
- Snowflake-like, 6 points
- Geometric, symmetrical
- 8×8 pixels
Colors: #00FFFF (cyan), #FFFFFF (white)

[7] BLUE SPARKLE (Blue):
- Diamond/rhombus shape
- 6×6 pixels
- Simple fill
Colors: #4A90E2 (blue), #FFFFFF (center)

[8] MAGIC WISP (Purple):
- Curved swirl shape
- 3-4 pixel curve trail
- 8×8 area
Colors: #9B59B6 (purple), #FF00FF (magenta)

[9] BLOOD DROP (Red):
- Small round drop
- 4×6 pixels
- Darker at bottom
Colors: #FF0000 (red), #8B0000 (dark red)

[10] EXPLOSION BIT (Orange):
- Irregular jagged shape
- 6×6 pixels
- Random outline
Colors: #FF4500 (orange), #FFD700 (yellow)

[11] CRITICAL STAR (Orange/White):
- 8-pointed star
- Alternating long/short points
- 8×8 pixels
Colors: #FF4500 (orange), #FFFFFF (white), #FFFF00 (yellow)

[12] FLAME BIT (Red):
- Small upward flame
- Wavy edges
- 5×7 pixels
Colors: #FF4500 (red), #FFFF00 (yellow tip)

[13] SMOKE PUFF (Gray):
- Puffy cloud shape
- 3 connected circles
- 8×6 pixels
Colors: #6B6B6B (gray), #4A4A4A (dark gray)

[14] DUST CLOUD (Tan):
- Cluster of small pixels
- Irregular, scattered
- 7×5 pixels overall
Colors: #D2B48C (tan), #A0522D (brown)

[15] GREEN SPARKLE (Green):
- 4-pointed star
- Same as #1 but green
- 6×6 pixels
Colors: #32CD32 (lime), #FFFFFF (white)

[16] PURPLE FLASH (Purple):
- Cross/plus shape
- Thick arms (2 pixels)
- 8×8 pixels
Colors: #9B59B6 (purple), #FF00FF (magenta), #FFFFFF (center)

---

STYLE NOTES:
- All particles very simple (3-8 pixels per dimension)
- Clear silhouettes
- Bold colors
- Each particle recognizable instantly
- Can be used for many effect types

VERIFICATION CHECKLIST:
☐ Exactly 64×64 pixels (4×4 grid)
☐ 16 unique particles
☐ Each centered in 16×16 tile
☐ All particles simple shapes
☐ Distinct silhouettes
☐ Transparent background
☐ Colors specified for each
☐ No anti-aliasing
```

---

# 📦 NOTAS FINALES DE IMPLEMENTACIÓN

## Workflow Recomendado

### Orden de Creación (Prioridad)
1. **Chef Idle** — Necesario para testear gameplay inmediatamente
2. **Cuchillo Común** — Proyectil básico
3. **Enemigo Pizza (1 frame idle)** — Target básico
4. **Impacto Normal** — Feedback visual
5. **UI Icons (monedas)** — HUD funcional

### Después (Fase 2)
- Chef Throw animation
- Más enemigos
- Cuchillos de rareza superior
- Bottom Nav icons
- Fondos (layer 3 primero, luego 2 y 1)

### Polish Final (Fase 3)
- Chef Critical y Celebration
- Boss enemigos
- Critical impact effects
- Particle effects completos
- Cuchillo Mítico con animación

---

## Herramientas de Edición Post-Generación

### Si la IA genera con anti-aliasing
```
Aseprite:
1. Edit > Adjustments > Brightness/Contrast
2. Increase Contrast to maximum
3. Edit > Posterize (reduce colors)
4. Manually clean edges

O usar filtro: Filters > Outline > Remove
```

### Asegurar Píxeles Perfectos
```
GIMP:
1. Image > Scale Image
2. Interpolation: None (Nearest Neighbor)
3. Filters > Blur > Pixelize (si es necesario)
```

### Extraer Paletas
```
Aseprite:
1. Sprite > Color Mode > Indexed
2. Sprite > Properties > Show Palette
3. Palette > Load/Save Palette
```

---

## Formato de Exportación

### Para Flutter
```
- Format: PNG-32
- Compression: None or Low
- Color Space: sRGB
- Metadata: Remove all
- Dimensions: Exact as specified
- DPI: Not important for games (pixel-perfect)
```

### Nomenclatura de Archivos
```
Sprites: spritename_animation_frame.png
  Ejemplo: chef_idle_01.png, chef_idle_02.png

UI: ui_element_name.png
  Ejemplo: ui_icon_gold.png

Backgrounds: bg_worldXX_layerXX.png
  Ejemplo: bg_world01_layer01.png

Effects: fx_type_description.png
  Ejemplo: fx_impact_normal.png
```

---

## Testing en Flutter

### Asset Loading Test
```dart
// En pubspec.yaml
flutter:
  assets:
    - assets/sprites/chef/
    - assets/sprites/enemies/
    - assets/sprites/weapons/
    - assets/ui/
    - assets/backgrounds/
    - assets/effects/

// Test sprite
Image.asset(
  'assets/sprites/chef/chef_idle_01.png',
  filterQuality: FilterQuality.none, // ¡CRÍTICO!
  scale: 4.0, // Escala para móvil
)
```

---

## Verificación de Calidad

### Checklist Final por Sprite
- [ ] Dimensiones exactas según spec
- [ ] Solo usa colores de la paleta especificada
- [ ] Sin anti-aliasing/blur
- [ ] Fondo transparente (o sólido para BG)
- [ ] Outline consistente (generalmente 1px negro)
- [ ] Centrado en frame si aplica
- [ ] Animación fluida (si es secuencia)
- [ ] Legible a tamaño real de juego
- [ ] Estilo consistente con otros sprites
- [ ] Nombre de archivo correcto

---

*Documento creado para Paleto Knife — 9 de marzo de 2026*  
*Versión 1.0 — Prompts Completos de Generación*  
*Referencia: GUIA_VISUAL_8BIT.md*

---

## 🚀 ¿Listo para Generar?

**Next Steps:**
1. Copia el prompt del sprite que quieras crear
2. Úsalo en tu herramienta de generación de IA favorita
3. Añade al final: "pixel art, 8-bit, NES style, no anti-aliasing, sharp pixels"
4. Genera múltiples variaciones
5. Selecciona la mejor
6. Edita en Aseprite para perfeccionar grid alignment
7. Exporta según especificaciones
8. Integra en Flutter
9. ¡A JUGAR!

**Cada prompt es autocontenido** y tiene toda la información necesaria para generar un sprite perfecto sin necesidad de contexto adicional.
