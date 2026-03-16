# 🎨 Guía Visual 8-bit — Paleto Knife

## 📋 Documento de Referencia de Arte
**Versión:** 1.0  
**Fecha:** 9 de marzo de 2026  
**Estilo:** Pixel Art 8-bit inspirado en NES  
**Plataforma:** Móvil (Flutter)

---

## 1. 📐 Resolución Base y Grid System

### Especificaciones Técnicas
```
Resolución lógica base: 320×180 px (16:9 retro)
Alternativa:           256×224 px (estilo NES auténtico)
Pixel grid:            Sin anti-aliasing, píxeles perfectos
Escala para móviles:   ×4 o ×5 (1280×720 / 1600×900)
Grid unit base:        16×16 px (1 tile)
```

### Reglas de Grid
- **Todos los sprites** deben alinearse al grid de 16×16 px
- Sprites pequeños: múltiplos de 8px (8, 16, 24, 32)
- Sprites medianos: múltiplos de 16px (16, 32, 48, 64)
- Sprites grandes: múltiplos de 32px (64, 96, 128)
- **NO usar subpixels** — mantener píxeles perfectos
- **NO usar anti-aliasing** — bordes nítidos siempre

### Escalado
- Usar escalado **nearest-neighbor** (no interpolación)
- Zoom integer-based (×2, ×3, ×4, ×5)
- Mantener aspect ratio 16:9 para móviles

---

## 2. 🎨 Paleta de Colores Maestra

### Paleta Global (22 colores)
Inspirada en NES con toque culinario moderno.

#### **Base Colors (UI y Fondos)**
```
#0F0F0F — Negro puro (outlines, sombras)
#1C1C1C — Gris oscuro (fondos)
#3A3A3A — Gris medio (paneles UI)
#6B6B6B — Gris claro (bordes, detalles)
#FFFFFF — Blanco puro (highlights, texto)
```

#### **Chef & Player Colors**
```
#FFE5B4 — Piel clara
#D4A373 — Piel oscura (sombras)
#FFFFFF — Gorra blanca chef
#4A4A4A — Detalles uniforme
#FF0000 — Detalles rojos (pañuelo, críticos)
```

#### **Knife & Weapon Colors**
```
#C0C0C0 — Acero básico (común)
#4A90E2 — Azul brillante (raro)
#9B59B6 — Púrpura (épico)
#FFD700 — Oro (legendario)
#FF1493 — Rosa neón (mítico)
```

#### **Enemy & Food Colors**
```
#FF4500 — Rojo tomate (salsa, lava)
#FFD700 — Amarillo queso (fondido)
#8B4513 — Marrón pan (tostado)
#32CD32 — Verde lechuga (ensaladas)
#FF69B4 — Rosa carne (cruda)
#8B0000 — Rojo oscuro (podrido)
```

#### **Effect Colors**
```
#FFFF00 — Amarillo (impacto normal)
#FF4500 — Naranja (crítico)
#00FF00 — Verde (curación)
#FF0000 — Rojo (daño recibido)
```

### Reglas de Uso
- **Máximo 6-8 colores por sprite**
- Usar **dithering en patrón checker** para transiciones
- Evitar gradientes suaves (solo 2-3 tonos por color)
- Outlines siempre en negro (#0F0F0F)
- Highlights siempre en blanco o color más claro

---

## 3. 👨‍🍳 Chef Maestro — Sprite Principal

### Dimensiones
- **Tamaño base:** 32×32 px
- **Variante alta definición:** 48×48 px (para pantalla de perfil)
- **Hitbox:** 20×28 px (centro del sprite)

### Diseño Visual
```
Elementos clave:
┌─────────────────────────────┐
│ 🧑‍🍳 CHEF MAESTRO            │
├─────────────────────────────┤
│ • Gorra alta de chef blanca │
│ • Uniforme blanco/gris      │
│ • Pañuelo rojo al cuello    │
│ • Cuchillo en mano derecha  │
│ • Pose frontal/3/4          │
│ • Rostro simple (dots)      │
│ • Silueta reconocible       │
└─────────────────────────────┘
```

### Animaciones Requeridas

#### **Idle (4 frames, 8 FPS)**
```
Frame 1: Postura neutral
Frame 2: Pequeña respiración (1px arriba)
Frame 3: Neutral
Frame 4: Pequeña respiración (1px abajo)
→ Loop continuo
```

#### **Lanzar Cuchillo (6 frames, 12 FPS)**
```
Frame 1: Preparación (brazo atrás)
Frame 2: Impulso (brazo medio)
Frame 3: Lanzamiento (brazo extendido)
Frame 4: Release (sin cuchillo)
Frame 5: Recuperación (brazo bajando)
Frame 6: Return to idle
→ Trigger: cada disparo automático
```

#### **Crítico (8 frames, 15 FPS)**
```
Frame 1-2: Flash blanco (full sprite)
Frame 3-4: Pose heroica (brazos arriba)
Frame 5-6: Estrellas alrededor (4 particles)
Frame 7-8: Return to idle
→ Trigger: critical hit confirmado
```

#### **Celebración (10 frames, 12 FPS)**
```
Frame 1-3: Salto pequeño
Frame 4-6: Brazo arriba con cuchillo
Frame 7-9: Giro ligero
Frame 10: Pose victoriosa
→ Trigger: enemigo derrotado
```

#### **Daño Recibido (4 frames, 20 FPS)**
```
Frame 1: Flash rojo
Frame 2: Knockback (2px atrás)
Frame 3: Recuperación
Frame 4: Return to idle
→ Trigger: al recibir daño
```

### Paleta del Chef
```
Colores usados (7 total):
#0F0F0F — Outline
#FFFFFF — Gorra y uniforme
#FFE5B4 — Cara/manos
#D4A373 — Sombras piel
#4A4A4A — Detalles uniforme
#FF0000 — Pañuelo
#C0C0C0 — Cuchillo base
```

---

## 4. 👹 Amalgamas Culinarias — Enemigos

### Sistema de Tamaños
```
Minion:  32×32 px  (enemigos comunes)
Elite:   48×48 px  (sub-jefes)
Boss:    64×64 px  (jefes de mundo)
         96×96 px  (jefe final)
```

### Diseño General
- **Silueta exagerada** y memorable
- **Ojos grandes** y expresivos (terror/humor)
- **Partes del cuerpo desproporcionadas**
- **Texturas food-based** (reconocibles al instante)
- **Animación idle** mínima (2-4 frames)

---

### 🍕 Enemigo 1: Pizza de Lava

#### **Concepto**
Pizza circular con tentáculos de pepperoni, queso fundido goteando, ojos en el centro.

#### **Especificaciones**
```
Tamaño:      48×48 px (Elite tier)
Colores:     #FF4500 (salsa), #FFD700 (queso),
             #8B4513 (bordes), #0F0F0F (outline)
Forma:       Circular con 6 tentáculos
Ojos:        2× blancos con pupila roja
Animación:   Tentáculos ondulando (4 frames)
```

#### **Detalles Visuales**
- Base redonda de masa (borde marrón tostado)
- Salsa roja con textura pixelada (dithering)
- Queso amarillo goteando hacia abajo (3-4 gotas)
- Pepperoni negro en superficie
- Tentáculos salen del perímetro
- Ojos asimétricos (uno más grande)
- Pequeñas burbujas de calor (particles)

---

### 🍣 Enemigo 2: Sushi Viviente

#### **Concepto**
Nigiri gigante con ojos saltones, algas envolventes, arroz con dientes.

#### **Especificaciones**
```
Tamaño:      32×32 px (Minion tier)
Colores:     #FFFFFF (arroz), #FF69B4 (salmón),
             #006400 (alga nori), #0F0F0F (outline)
Forma:       Rectangular con alga envolvente
Ojos:        2× grandes y saltones
Animación:   Alga moviéndose (3 frames)
```

#### **Detalles Visuales**
- Base de arroz blanco con textura granular
- Salmón rosa encima con líneas de grasa
- Alga nori envolviendo como cinturón
- Ojos enormes y gelatinosos
- Pequeña boca con 2-3 dientes de arroz
- Gotas de salsa soya cayendo

---

### 🥗 Enemigo 3: Ensalada Carnívora

#### **Concepto**
Lechuga viva con hojas afiladas, tomates como ojos, dientes de zanahoria.

#### **Especificaciones**
```
Tamaño:      48×48 px (Elite tier)
Colores:     #32CD32 (lechuga), #FF4500 (tomate),
             #FF8C00 (zanahoria), #0F0F0F (outline)
Forma:       Masa de hojas con boca grande
Ojos:        2× tomates cherry rojos
Animación:   Hojas temblando (4 frames)
```

#### **Detalles Visuales**
- Hojas verdes en capas (3-4 tonos de verde)
- Tomates cherry como ojos malvados
- Boca enorme con dientes de zanahoria afilados
- Pepino como lengua verde
- Hojas moviéndose como tentáculos
- Gotas de aderezo ranch goteando

---

### 🍞 Enemigo 4: Golem de Pan

#### **Concepto**
Humanoide de pan gigante con moho verde, miga expuesta, brazos masivos.

#### **Especificaciones**
```
Tamaño:      64×64 px (Boss tier)
Colores:     #8B4513 (pan tostado), #32CD32 (moho),
             #FFE5B4 (miga), #0F0F0F (outline)
Forma:       Humanoide robusto
Ojos:        2× huecos negros profundos
Animación:   Respiración pesada (4 frames)
```

#### **Detalles Visuales**
- Cuerpo de baguette gigante tostada
- Corteza crujiente con grietas
- Moho verde creciendo en hombros
- Brazos desproporcionadamente grandes
- Miga blanca expuesta en cortes
- Ojos vacíos que dan miedo
- Migas cayendo constantemente (particles)
- Textura de semillas en superficie

---

### 🌮 Enemigo 5: Taco del Caos (Boss Final)

#### **Concepto**
Taco gigante flotante con múltiples capas, ingredientes vivos, aura oscura.

#### **Especificaciones**
```
Tamaño:      96×96 px (Final Boss)
Colores:     #FFD700 (tortilla), #FF0000 (salsa),
             #32CD32 (guacamole), #0F0F0F (aura)
Forma:       Taco gigante con fases
Ojos:        4× ojos en diferentes ingredientes
Animación:   Flotación + ingredientes moviéndose (6 frames)
```

#### **Detalles Visuales**
- Tortilla dorada gigante crujiente
- Carne molida roja con textura
- Lechuga verde saliendo por los lados
- Queso fundido amarillo brillante
- Salsa roja y verde goteando
- Ojos múltiples en cada ingrediente
- Aura oscura pulsante alrededor
- Pequeños ingredientes orbitando (satellites)

---

## 5. 🔪 Cuchillos y Proyectiles

### Dimensiones
- **Sprite de cuchillo:** 16×16 px
- **Proyectil en vuelo:** 12×12 px (simplificado)
- **Hitbox:** 8×8 px (centro)

### Sistema de Rareza

#### **Común (Gris)**
```
Color principal: #C0C0C0
Efecto:          Sin brillo
Diseño:          Cuchillo simple de acero
Outline:         #0F0F0F
```

#### **Raro (Azul)**
```
Color principal: #4A90E2
Efecto:          Pequeño brillo (1px blanco)
Diseño:          Cuchillo con filo azulado
Outline:         #0F0F0F
Particles:       1 estela azul (trail)
```

#### **Épico (Púrpura)**
```
Color principal: #9B59B6
Efecto:          Brillo medio (2px alternando)
Diseño:          Cuchillo ornamentado
Outline:         #0F0F0F
Particles:       2-3 chispas púrpuras
```

#### **Legendario (Oro)**
```
Color principal: #FFD700
Efecto:          Brillo intenso (3px pulsante)
Diseño:          Cuchillo dorado con gemas
Outline:         #8B4513 (marrón oscuro)
Particles:       4-5 destellos dorados
Aura:            Pequeño glow amarillo (2px)
```

#### **Mítico (Rosa Neón)**
```
Color principal: #FF1493
Efecto:          Brillo arcoíris (animado)
Diseño:          Cuchillo cristalino brillante
Outline:         #FFFFFF (blanco)
Particles:       6-8 estrellas multicolor
Aura:            Glow rosa intenso (4px)
Trail:           Estela arcoíris (8 frames)
```

### Variantes de Cuchillos

#### **Cuchillo de Chef (Común)**
```
16×16 px
Hoja plateada simple
Mango marrón oscuro
Sin efectos especiales
```

#### **Santoku Azul (Raro)**
```
16×16 px
Hoja azul metálica
Mango negro con detalles
Pequeña estela azul
```

#### **Cuchillo Púrpura (Épico)**
```
16×16 px
Hoja púrpura brillante
Mango dorado
Gemas incrustadas (2px)
```

#### **Daga Dorada (Legendario)**
```
16×16 px
Hoja completamente dorada
Mango con rubí central
Destellos constantes
```

#### **Cristal Mítico (Mítico)**
```
16×16 px
Hoja cristalina transparente
Mango arcano con runas
Efecto prismático
```

### Animación de Proyectil
```
Frame 1: Rotación 0°
Frame 2: Rotación 90°
Frame 3: Rotación 180°
Frame 4: Rotación 270°
→ Loop a 24 FPS (rotación rápida)
```

---

## 6. 🖼️ UI Retro — Interfaz de Usuario

### Filosofía de Diseño
- **Máxima legibilidad** en pantallas pequeñas
- **Iconos claros** sin texto cuando sea posible
- **Feedback visual inmediato** en todas las acciones
- **Jerarquía visual** clara (importante = grande)

---

### Top HUD (Barra Superior)

#### **Layout**
```
┌─────────────────────────────────────────┐
│ 💰 999.9K  💎 1.2K  🎟️ 45   [⚙️] [❓] │
└─────────────────────────────────────────┘
   Oro      Fragmentos  Tokens  Ajustes
```

#### **Especificaciones**
- **Altura:** 32 px
- **Fondo:** #1C1C1C con borde #6B6B6B (2px)
- **Iconos:** 16×16 px cada uno
- **Separación:** 8px entre elementos
- **Tipografía:** Pixel font 8px (números)

#### **Elementos Individuales**

**Oro (Moneda principal)**
```
Icono:    Moneda dorada 16×16 px
          (#FFD700 con brillo #FFFFFF)
Texto:    Blanco #FFFFFF
Formato:  999.9K (con sufijos K/M/B)
```

**Fragmentos (Moneda premium)**
```
Icono:    Gema azul 16×16 px
          (#4A90E2 con facetas)
Texto:    Cyan claro #00FFFF
Formato:  1234 (sin decimales)
```

**Tokens (Moneda especial)**
```
Icono:    Ticket dorado 16×16 px
          (#FFD700 con líneas rojas)
Texto:    Amarillo #FFFF00
Formato:  45 (entero)
```

---

### Bottom Navigation (Barra Inferior)

#### **Layout**
```
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│    ⚔️    │    👨‍🍳    │    ⚡    │    🎒    │    👤    │
│ COMBATE  │  COCINA  │ TÉCNICAS │  EQUIPO  │  PERFIL  │
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

#### **Especificaciones**
- **Altura:** 64 px
- **Botones:** 64×64 px cada uno (mismo ancho que altura)
- **Icono:** 32×32 px centrado
- **Texto:** 8px debajo del icono
- **Fondo activo:** #3A3A3A
- **Fondo inactivo:** #1C1C1C
- **Borde:** #6B6B6B (2px superior)

#### **Iconos Detallados**

**Combate (Pantalla principal)**
```
Icono:       Dos espadas cruzadas
Tamaño:      32×32 px
Colores:     #C0C0C0 (acero), #0F0F0F (outline)
Estado:      Animación sutil cuando activo
```

**Cocina (Crafting/Upgrades)**
```
Icono:       Sartén con fuego
Tamaño:      32×32 px
Colores:     #4A4A4A (sartén), #FF4500 (fuego)
Animación:   Llamas oscilando (2 frames)
```

**Técnicas (Skills/Poderes)**
```
Icono:       Estrella con rayos
Tamaño:      32×32 px
Colores:     #FFD700 (estrella), #FFFFFF (rayos)
Animación:   Rotación lenta
```

**Equipo (Inventario)**
```
Icono:       Mochila de chef
Tamaño:      32×32 px
Colores:     #8B4513 (cuero), #C0C0C0 (hebillas)
Badge:       Número en esquina (items nuevos)
```

**Perfil (Stats/Settings)**
```
Icono:       Silueta de chef
Tamaño:      32×32 px
Colores:     #FFFFFF (silueta), #0F0F0F (fondo)
```

---

### Paneles de Contenido

#### **Panel Estándar**
```
┌───────────────────────────────────┐
│ ╔═══════════════════════════════╗ │ ← Borde exterior 4px
│ ║                               ║ │
│ ║     CONTENIDO AQUÍ            ║ │
│ ║                               ║ │
│ ╚═══════════════════════════════╝ │
└───────────────────────────────────┘

Fondo:          #1C1C1C
Borde externo:  #6B6B6B (4px)
Borde interno:  #3A3A3A (2px)
Padding:        8px interno
```

#### **Panel de Mejora (Upgrade Card)**
```
┌─────────────────────────────┐
│ [ICONO] NOMBRE MEJORA       │ ← 24px altura
├─────────────────────────────┤
│ Descripción corta aquí      │ ← 16px altura
│ con efecto de la mejora     │
├─────────────────────────────┤
│ Nivel: 5  Costo: 💰 1.2K    │ ← 20px altura
│ [   COMPRAR   ]             │ ← Botón 32px
└─────────────────────────────┘

Tamaño total:   Ancho flexible × 92px altura
Icono mejora:   24×24 px (esquina superior izq)
Botón comprar:  Estado cambia según oro disponible
```

**Estados del botón:**
```
Disponible:   #32CD32 (verde) + outline #0F0F0F
No disponible: #8B0000 (rojo oscuro) + gris
Presionado:   Escala 0.95 + flash blanco
```

#### **Panel de Estadísticas (Combat Screen)**
```
┌─────────────────────────────┐
│ ❤️ 850 / 1000               │ ← Vida jugador
│ ██████████░░░░              │ ← Barra 85%
├─────────────────────────────┤
│ 👹 PIZZA DE LAVA        Lv.5│ ← Nombre enemigo
│ ████████████████████░░░░    │ ← Vida 90%
└─────────────────────────────┘

Barra de vida:   
  Jugador: Verde #32CD32 / rojo bajo #FF0000
  Enemigo: Rojo #FF4500 / gris #3A3A3A
  Altura: 8px
  Outline: Negro #0F0F0F (1px)
```

---

### Botones y Controles

#### **Botón de Movimiento (Izquierda/Derecha)**
```
Tamaño:        64×64 px (táctil óptimo)
Forma:         Octágono pixel art
Icono:         Flecha 32×32 px
Colores:
  Normal:      #3A3A3A (fondo), #FFFFFF (flecha)
  Presionado:  #6B6B6B (fondo), #FFFFFF (flecha)
Posición:      Esquinas inferiores (izq/der)
```

#### **Botón de Poder Especial**
```
Tamaño:        80×80 px (destacado)
Forma:         Círculo pixelado
Icono:         Rayo 48×48 px (#FFFF00)
Borde:         Animado (rotación)
Estados:
  Listo:       Brillando (pulso amarillo)
  Cooldown:    Gris + barra circular progreso
  Activo:      Flash rápido blanco/amarillo
Posición:      Centro derecho pantalla
```

---

### Notificaciones y Feedback

#### **Números Flotantes (Daño)**
```
Tamaño:        16px (normal), 24px (crítico)
Duración:      1.5 segundos
Animación:     Flota hacia arriba + fade out
Colores:
  Daño normal:   #FFFFFF
  Crítico:       #FFFF00 (parpadeo)
  Curación:      #32CD32
  Miss:          #6B6B6B
Outline:         #0F0F0F (2px, legibilidad)
```

#### **Toast Notifications**
```
┌─────────────────────────────┐
│ ✅ ¡Item Obtenido!          │
│ Cuchillo Legendario x1      │
└─────────────────────────────┘

Tamaño:         280×48 px
Posición:       Centro superior (desliza desde arriba)
Duración:       3 segundos
Fondo:          #3A3A3A + outline #FFD700 (2px)
Animación:      Slide in/out con easing
```

---

## 7. 🌍 Fondos y Ambientación

### Sistema de Mundos
Cada mundo tiene 3 capas parallax para profundidad.

---

### Mundo 1: Cocina Infernal

#### **Capas**
```
Capa 3 (Fondo): Horno gigante con brasas (#8B0000)
                Movimiento: 0.2x velocidad cámara
                
Capa 2 (Medio): Estanterías con utensilios (#4A4A4A)
                Movimiento: 0.5x velocidad cámara
                
Capa 1 (Frente): Mesón de trabajo (#8B4513)
                 Movimiento: 1.0x velocidad cámara
```

#### **Paleta Específica**
```
#8B0000 — Rojo oscuro (fuego, brasas)
#FF4500 — Naranja brillante (llamas)
#4A4A4A — Gris metálico (utensilios)
#8B4513 — Marrón (madera)
#0F0F0F — Negro (sombras, profundidad)
```

#### **Elementos Animados**
- Llamas oscilando (3 frames, loop)
- Vapor subiendo (particles)
- Brasas palpitando (2 tonos alternando)

---

### Mundo 2: Restaurante Abandonado

#### **Capas**
```
Capa 3 (Fondo): Ventanas rotas con luna (#C0C0C0)
                Siluetas de ciudad al fondo
                
Capa 2 (Medio): Mesas y sillas volteadas (#8B4513)
                Telarañas en esquinas
                
Capa 1 (Frente): Piso de losetas agrietadas (#6B6B6B)
                 Manchas oscuras
```

#### **Paleta Específica**
```
#1C1C1C — Negro azulado (noche)
#4A4A4A — Gris (paredes)
#8B4513 — Marrón (muebles)
#C0C0C0 — Plata (luz de luna)
#006400 — Verde oscuro (moho)
```

#### **Elementos Animados**
- Cortinas moviendose (viento)
- Luna parpadeando detrás de nubes
- Polvo cayendo (particles)

---

### Mundo 3: Despensa Maldita

#### **Capas**
```
Capa 3 (Fondo): Estanterías altas con productos (#3A3A3A)
                Oscuridad profunda arriba
                
Capa 2 (Medio): Cajas apiladas desorganizadas (#8B4513)
                Latas gigantes
                
Capa 1 (Frente): Piso de concreto agrietado (#6B6B6B)
                 Pequeñas raíces saliendo
```

#### **Paleta Específica**
```
#0F0F0F — Negro (sombras)
#3A3A3A — Gris oscuro (estanterías)
#8B4513 — Marrón (cajas)
#32CD32 — Verde neón (moho brillante)
#8B0000 — Rojo (manchas sospechosas)
```

#### **Elementos Animados**
- Moho brillante pulsando
- Ojos en la oscuridad (2 puntos blancos)
- Goteo constante (particles)

---

### Mundo 4: Horno Volcánico (Boss Final)

#### **Capas**
```
Capa 3 (Fondo): Volcán activo con lava (#FF4500)
                Cielo rojo intenso
                
Capa 2 (Medio): Plataformas de piedra flotantes (#4A4A4A)
                Cascadas de lava
                
Capa 1 (Frente): Isla central de roca (#1C1C1C)
                 Grietas con magma visible
```

#### **Paleta Específica**
```
#8B0000 — Rojo sangre (cielo)
#FF4500 — Naranja lava (brillante)
#FFD700 — Amarillo (núcleo lava)
#4A4A4A — Gris roca
#0F0F0F — Negro (roca enfriada)
```

#### **Elementos Animados**
- Lava fluyendo (4 frames)
- Burbujas explotando (particles)
- Chispas volando (particles)
- Plataformas temblando levemente

---

## 8. ✨ Efectos Visuales

### Sistema de Particles

#### **Reglas Generales**
- Máximo **20 particles activas** simultáneas
- Tamaño: 2×2 px o 4×4 px
- Vida: 0.5 - 2.0 segundos
- Movimiento: trayectoria simple (lineal o parabólica)

---

### Efectos de Combate

#### **Impacto Normal**
```
Trigger:    Proyectil toca enemigo
Particles:  6× cuadrados 4×4 px
Color:      #FFFF00 (amarillo)
Patrón:     Explosión radial simple
Duración:   0.3 segundos
```

#### **Impacto Crítico**
```
Trigger:    Critical hit
Particles:  12× estrellas 4×4 px + 8× líneas
Color:      #FF4500 (naranja) + #FFFFFF (blanco)
Patrón:     Explosión grande + flash screen
Duración:   0.6 segundos
Sonido:     (recomendado: "CRIT!" en pixeles)
```

#### **MISS**
```
Trigger:    Proyectil falla hitbox
Visual:     Texto "MISS" en 16×16 px
Color:      #6B6B6B (gris)
Animación:  Fade out rápido
Duración:   0.5 segundos
```

#### **Daño Recibido (Jugador)**
```
Trigger:    Jugador es golpeado
Efecto:     Flash rojo en sprite (2 frames)
Particles:  4× gotas rojas 2×2 px
Color:      #FF0000 (rojo)
Duración:   0.4 segundos
Screen:     Pequeño screen shake (2px)
```

---

### Efectos de Proyectil

#### **Trail Normal**
```
Particles:  1 cada 0.1s
Tamaño:     2×2 px
Color:      Según rareza del cuchillo
Duración:   0.3s (fade out)
```

#### **Trail Legendario**
```
Particles:  2 cada 0.05s
Tamaño:     4×4 px
Color:      #FFD700 con sparkles #FFFFFF
Duración:   0.5s
Efecto:     Pequeño glow alrededor
```

#### **Trail Mítico**
```
Particles:  3 cada 0.03s
Tamaño:     4×4 px + 2 estrellas 2×2 px
Color:      Arcoíris (6 colores alternando)
Duración:   0.8s
Efecto:     Después-imágenes (ghosting)
```

---

### Efectos de Enemigo

#### **Spawn de Enemigo**
```
Animación:  8 frames (0.4s total)
Frame 1-2:  Portal oscuro (#0F0F0F)
Frame 3-4:  Enemigo aparece (fade in 50%)
Frame 5-6:  Enemigo aparece (fade in 80%)
Frame 7-8:  Enemigo completo + particles
Particles:  8× humo gris 4×4 px
```

#### **Muerte de Enemigo**
```
Animación:  10 frames (0.6s total)
Frame 1-3:  Flash blanco
Frame 4-6:  Sprite fragmentándose
Frame 7-9:  Explosión de comida
Frame 10:   Desaparición completa
Particles:  
  - 12× pedazos de comida 4×4 px
  - 6× humo #6B6B6B
  - 1× texto "DERROTADO" (opcional)
```

---

### Efectos de UI

#### **Botón Presionado**
```
Frame 1:    Escala 1.0
Frame 2:    Escala 0.95 + outline blanco
Frame 3:    Escala 1.0
Duración:   0.15s total
```

#### **Item Obtenido**
```
Animación:  Item aparece desde abajo
Frames:     
  1-4:   Slide up + escala 0.5→1.2
  5-8:   Escala 1.2→1.0 + rotación
  9-12:  Brillo alrededor (pulso)
Particles:  8× estrellas doradas
Duración:   1.0s total
```

#### **Levelup / Upgrade**
```
Efecto:     Rayo dorado desde arriba
Animación:  
  Frame 1-3:  Luz bajando (#FFD700)
  Frame 4-6:  Impacto en jugador
  Frame 7-10: Aura dorada expandiendo
Particles:  16× estrellas emergiendo
Sonido:     (recomendado)
Duración:   0.8s
```

---

## 9. 🔤 Tipografía Pixel

### Font Principal
**Recomendado:** Press Start 2P (Google Fonts)  
**Alternativa:** Pixel Operator, VT323

### Tamaños y Usos

#### **Texto Grande (Títulos)**
```
Tamaño:     16px
Uso:        Títulos de pantalla, nombres de enemigos
Color:      #FFFFFF con outline #0F0F0F (2px)
Tracking:   +2px (espaciado entre letras)
```

#### **Texto Medio (UI)**
```
Tamaño:     12px
Uso:        Botones, labels, stats
Color:      #FFFFFF o según contexto
Outline:    #0F0F0F (1px)
```

#### **Texto Pequeño (Detalles)**
```
Tamaño:     8px
Uso:        Descripciones, tooltips, números pequeños
Color:      #C0C0C0 (gris claro)
Outline:    #0F0F0F (1px)
```

### Formato de Números

#### **Números Grandes**
```
< 1,000:        "999"
< 1,000,000:    "999.9K"
< 1,000,000,000: "999.9M"
≥ 1,000,000,000: "999.9B"

Ejemplos:
  850       → "850"
  1,250     → "1.2K"
  45,600    → "45.6K"
  3,200,000 → "3.2M"
```

### Reglas de Legibilidad
- **Siempre usar outline negro** en texto sobre fondos variados
- Máximo **2 líneas de texto** en botones
- Contraste mínimo 4.5:1 (WCAG AA)
- **No usar itálicas** (rompe el pixel grid)
- **No usar bold** (duplicar el grosor manualmente si es necesario)

---

## 10. 📏 Principios de Consistencia

### Checklist de Diseño

Antes de aprobar cualquier sprite, verificar:

#### **✓ Grid Alignment**
- [ ] Sprite se alinea al grid de 8px o 16px
- [ ] No hay subpixels
- [ ] Dimensiones son múltiplos válidos

#### **✓ Paleta**
- [ ] Solo usa colores de la paleta maestra
- [ ] Máximo 6-8 colores por sprite
- [ ] Outline es negro #0F0F0F (salvo excepciones)

#### **✓ Estilo Visual**
- [ ] Grosor de outline consistente (1px generalmente)
- [ ] Mismo nivel de detalle que sprites similares
- [ ] Proporciones reconocibles

#### **✓ Iluminación**
- [ ] Luz viene desde arriba-izquierda
- [ ] Sombras son 1-2 tonos más oscuro
- [ ] Highlights son 1-2 tonos más claro

#### **✓ Animación**
- [ ] Número de frames apropiado (2-8 típicamente)
- [ ] Velocidad de animación consistente con sprites similares
- [ ] Loop suave (primer y último frame compatibles)

#### **✓ Exportación**
- [ ] Formato PNG sin compresión
- [ ] Sin anti-aliasing
- [ ] Fondo transparente (excepto backgrounds)
- [ ] Nombre de archivo descriptivo

---

### Convenciones de Nomenclatura

#### **Sprites de Personajes**
```
chef_idle_01.png
chef_throw_01.png
chef_crit_01.png

enemy_pizza_idle_01.png
enemy_sushi_spawn_01.png
```

#### **UI Elements**
```
ui_button_combat.png
ui_icon_gold.png
ui_panel_upgrade.png
```

#### **Proyectiles**
```
knife_common_01.png
knife_legendary_01.png
projectile_trail_blue.png
```

#### **Efectos**
```
fx_impact_normal_01.png
fx_explosion_large_01.png
fx_particle_spark.png
```

#### **Fondos**
```
bg_world01_layer01.png
bg_world01_layer02.png
bg_world01_layer03.png
```

---

### Reglas de Sombras

#### **Sombras Simples**
```
Personajes:  Oval 16×8 px en el suelo
             Color: #0F0F0F con alpha 50%
             Siempre debajo del sprite

Objetos:     1px offset abajo-derecha
             Color: 1-2 tonos más oscuro

UI:          2px offset abajo-derecha
             Color: #0F0F0F
```

---

### Sistema de Proporciones

#### **Relaciones de Tamaño**
```
Cuchillo pequeño:  16×16 px  (base)
Chef:              32×32 px  (×2)
Enemigo normal:    32-48 px  (×2-3)
Boss:              64-96 px  (×4-6)
```

Mantener estas proporciones asegura que todos los sprites se vean balanceados juntos.

---

## 11. 🎯 Ejemplos de Composición

### Pantalla de Combate (Layout Completo)

```
┌─────────────────────────────────────────┐ ← Top HUD (32px)
│ 💰 999.9K  💎 1.2K  🎟️ 45   [⚙️] [❓] │
├─────────────────────────────────────────┤
│                                         │
│          👹 PIZZA DE LAVA    Lv.5      │ ← Enemy info (48px)
│          ████████████████░░░░           │
│                                         │
│ ╔═══════════════════════════════════╗   │
│ ║                                   ║   │
│ ║         [ENEMIGO AQUÍ]            ║   │ ← Combat area
│ ║              🔪↓                  ║   │   (flexible)
│ ║                                   ║   │
│ ║                                   ║   │
│ ║              🔪↑                  ║   │
│ ║         [JUGADOR AQUÍ]            ║   │
│ ║                                   ║   │
│ ╚═══════════════════════════════════╝   │
│                                         │
│ ❤️ 850 / 1000                   [⚡]   │ ← Player info (48px)
│ ██████████░░░░                          │
│                                         │
│  ⬅️                            ➡️       │ ← Controls (64px)
├─────────────────────────────────────────┤
│  ⚔️  │  👨‍🍳  │  ⚡  │  🎒  │  👤       │ ← Bottom nav (64px)
└─────────────────────────────────────────┘

Total Height: 
  - Top HUD: 32px
  - Enemy info: 48px
  - Combat area: flexible (resto)
  - Player info: 48px
  - Controls: 64px
  - Bottom nav: 64px
```

---

## 12. 📦 Assets a Generar (Checklist)

### Fase 1: Esenciales
- [ ] Chef idle (4 frames, 32×32)
- [ ] Chef throw (6 frames, 32×32)
- [ ] Cuchillo común (16×16)
- [ ] Enemigo Pizza (48×48, idle 4 frames)
- [ ] Enemigo Sushi (32×32, idle 3 frames)
- [ ] UI icons: oro, fragmentos, tokens (16×16 c/u)
- [ ] Bottom nav icons (32×32 × 5)
- [ ] Fondo Mundo 1 (3 capas)
- [ ] Efectos: impacto normal, crítico

### Fase 2: Expansión
- [ ] Chef crítico (8 frames)
- [ ] Chef celebración (10 frames)
- [ ] Cuchillos rareza: raro, épico, legendario (16×16 c/u)
- [ ] Enemigo Ensalada (48×48)
- [ ] Enemigo Golem Pan (64×64)
- [ ] Fondo Mundo 2 y 3
- [ ] Efectos de trail legendario
- [ ] UI panels y botones completos

### Fase 3: Polish
- [ ] Chef daño (4 frames)
- [ ] Cuchillo mítico con animación completa
- [ ] Boss Taco (96×96, 6 frames idle)
- [ ] Fondo Mundo 4 (boss arena)
- [ ] Efectos de spawn y muerte enemigos
- [ ] Particles adicionales
- [ ] Animaciones de UI (levelup, item obtenido)

---

## 13. 🔧 Implementación Técnica (Flutter)

### Recomendaciones de Código

#### **Cargar Sprites**
```dart
// preferences en pubspec.yaml
flutter:
  assets:
    - assets/sprites/
    - assets/ui/
    - assets/backgrounds/
    - assets/effects/

// Cargar sprite sheet
final spriteSheet = await Flame.images.load('chef_idle.png');
```

#### **Escalar Píxeles Perfectos**
```dart
Paint()
  ..filterQuality = FilterQuality.none // ¡CRÍTICO!
  ..isAntiAlias = false
```

#### **Animaciones**
```dart
final idleAnimation = SpriteAnimation.fromFrameData(
  spriteSheet,
  SpriteAnimationData.sequenced(
    amount: 4,      // frames
    stepTime: 0.125, // 8 FPS
    textureSize: Vector2(32, 32),
  ),
);
```

---

## 14. 📚 Referencias Visuales

### Inspiración Recomendada
- **NES Classics:** Super Mario Bros 3, Mega Man 2, Castlevania
- **UI Retro:** Stardew Valley, Shovel Knight
- **Pixel Art Moderno:** Celeste, Dead Cells (simplificar)
- **Color Palettes:** Lospec.com (buscar "NES", "8-bit")

### Herramientas Sugeridas
- **Aseprite** — Editor pixel art profesional
- **Piskel** — Editor online gratuito
- **Lospec Palette List** — Paletas pre-hechas
- **GraphicsGale** — Alternativa gratuita

---

## 15. ✅ Validación Final

Antes de considerar completa la guía visual, verificar:

- [✓] Paleta de 22 colores definida y documentada
- [✓] Resolución base y grid system especificado
- [✓] Chef con 5 animaciones diseñadas
- [✓] 5 enemigos únicos con concepto completo
- [✓] Sistema de rareza de cuchillos (5 niveles)
- [✓] UI completa con HUD, nav y paneles
- [✓] 4 mundos con fondos parallax
- [✓] 10+ efectos visuales especificados
- [✓] Tipografía y formato de números
- [✓] Principios de consistencia documentados
- [✓] Layout de pantalla de combate
- [✓] Checklist de assets a generar
- [✓] Recomendaciones técnicas para Flutter

---

## 📌 Conclusión

Esta guía establece una **identidad visual completa y consistente** para *Paleto Knife* en estilo pixel art 8-bit.

Todos los elementos visuales (sprites, UI, fondos, efectos) están diseñados para:
1. Ser reconocibles instantáneamente
2. Mantener coherencia estética
3. Funcionar en pantallas móviles pequeñas
4. Escalar perfectamente sin distorsión
5. Crear una experiencia retro auténtica pero pulida

**Siguiente paso sugerido:**  
Generar los sprites de Fase 1 usando esta guía como referencia exacta, comenzando por el Chef y los cuchillos básicos para testear rápidamente en el juego.

---

*Documento creado para Paleto Knife — 9 de marzo de 2026*  
*Versión 1.0 — Guía Visual Completa 8-bit*
