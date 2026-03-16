# 🔪 KNIFE CLICKER - LÓGICA COMPLETA DEL JUEGO

## Documento Técnico de Funcionamiento Total

---

## 📑 ÍNDICE

1. [Estructura General](#estructura-general)
2. [Sistema de Navegación y UI](#sistema-de-navegación-y-ui)
3. [Sistema de Combate](#sistema-de-combate)
4. [Sistema de Progresión](#sistema-de-progresión)
5. [Sistema de Recursos](#sistema-de-recursos)
6. [Sistema de Mejoras](#sistema-de-mejoras)
7. [Sistema de Sous-chefs](#sistema-de-sous-chefs)
8. [Sistema de Cuchillos (Skins)](#sistema-de-cuchillos-skins)
9. [Sistema de Equipamiento](#sistema-de-equipamiento)
10. [Sistema de Reinicio (Prestigio)](#sistema-de-reinicio-prestigio)
11. [Loops de Juego](#loops-de-juego)
12. [Sistemas Auxiliares](#sistemas-auxiliares)

---

## 🏗️ ESTRUCTURA GENERAL

### Concepto del Juego
**Knife Clicker** es un **clicker incremental con elementos RPG** donde:
- **Protagonista**: Chef Maestro
- **Enemigos**: Amalgamas Culinarias (criaturas de comida mutante viviente)
- **Objetivo**: Progresar derrotando amalgamas, mejorando habilidades culinarias, y reiniciando estratégicamente para bonificaciones permanentes
- **Género**: Idle/Clicker RPG con progresión incremental

### Arquitectura del Código

```
Main.java
├── Game Loop (render)
│   ├── Update Logic (delta time)
│   ├── Input Handling
│   ├── Rendering (sprites, UI, effects)
│   └── Auto-save System
│
├── Managers (sistemas del juego)
│   ├── AssassinManager (sous-chefs activos)
│   ├── ShopManager (contratación de sous-chefs)
│   ├── UpgradeManager (mejoras del chef)
│   ├── ResetManager (sistema de prestigio)
│   ├── SkinManager (cuchillos y cajas)
│   ├── EquipmentManager (joyas, reliquias, ídolos)
│   ├── UIManager (interfaz y navegación)
│   ├── ParticleManager (efectos visuales)
│   ├── SoundManager (música y SFX)
│   ├── SpriteRenderSystem (sprites procedurales)
│   └── SaveManager (persistencia)
│
├── Game State (variables globales)
│   ├── world (mundo actual 1-12)
│   ├── level (nivel actual dentro del mundo)
│   ├── coins (oro disponible)
│   ├── playerDamage (daño base del chef)
│   ├── Statistics (oro total, enemigos matados, clics)
│   └── Timers (auto-save, combo, idle)
│
└── Entities (objetos del juego)
    ├── Enemy (amalgama actual en pantalla)
    ├── Projectiles (cuchillos lanzados)
    ├── FloatingTexts (textos de daño, MISS, etc.)
    └── Particles (efectos visuales)
```

---

## 🖼️ SISTEMA DE NAVEGACIÓN Y UI

### Estados de la Interfaz (UIState)

El juego tiene **7 pantallas principales**:

```java
enum UIState {
    MENU,        // Pantalla inicial
    GAME,        // Pantalla principal de juego
    SHOP,        // Tienda de contratación (Cocina)
    UPGRADES,    // Mejoras del chef (Técnicas)
    SKINS,       // Cuchillos y cajas de botín
    RESET,       // Pantalla de reinicio
    EQUIPMENT    // Equipamiento (joyas, reliquias, ídolos)
}
```

### Navegación entre Pantallas

```
┌─────────────┐
│    MENU     │ (Pantalla inicial)
└──────┬──────┘
       │ "START GAME"
       ▼
┌─────────────────────────────────────────┐
│             GAME                        │ (Pantalla principal)
│  ┌─────────────────────────────────┐   │
│  │  Botones de navegación:         │   │
│  │  [COCINA] [TÉCNICAS] [CUCHILLOS]│   │
│  │  [EQUIPO] [REINICIAR]           │   │
│  └─────────────────────────────────┘   │
└──┬────┬────┬────┬────┬────────────────┘
   │    │    │    │    │
   ▼    ▼    ▼    ▼    ▼
 SHOP  UPGR SKINS EQUIP RESET
   │    │    │    │    │
   └────┴────┴────┴────┘
        [BACK]
         ▼
       GAME
```

### Detalles de Cada Pantalla

#### 1️⃣ PANTALLA MENU (Menú Principal)
**Elementos:**
- Logo del juego (texture o texto grande)
- Botón "START GAME"
- Fondo con color degradado

**Lógica:**
```
AL PRESIONAR "START GAME":
  1. Cambiar UIState a GAME
  2. Crear botones de navegación del juego
  3. Comenzar música de fondo (si no está sonando)
```

#### 2️⃣ PANTALLA GAME (Juego Principal)
**Elementos Visuales:**

**Superior Izquierda - Panel de Recursos (INFO/Cyan):**
- 💰 Oro actual
- 🎫 Tokens de reinicio disponibles
- 📦 Cofres de Reliquias (cantidad + barra de progreso)
- ❤️ Corazones de Culto (cantidad + barra de progreso)

**Superior Derecha - Panel de Combate (DANGER/Red):**
- ⚔️ DPS Total (daño por segundo combinado)
- 👥 Sous-chefs contratados (total)
- 🎖️ Sous-chefs equipados (X/5)
- 📈 Bonificaciones activas:
  - % Daño Total
  - % Crítico
- 🔪 Skin equipada actualmente

**Centro - Enemigo (Amalgama Culinaria):**
- Sprite visual del enemigo (generado proceduralmente)
- Barra de vida (con animación de daño)
- Nombre de la amalgama
- Tipo elemental (🌊 Agua, 🔥 Fuego, 🌱 Tierra)
- Tier (Normal, Elite, ⭐ Chef Menor, 👑 Chef de Temporada)
- Modificadores (Gigante, Crujiente, Desbordado)

**Centro-Abajo - Panel de Estadísticas del Chef (PRIMARY/Blue):**

*Columna 1:*
- **DAÑO BASE**: Valor final del daño del chef
- **CRÍTICO**: Probabilidad de crítico (%)

*Columna 2:*
- **DAÑO CRÍTICO**: Multiplicador de crítico (%)
- **PRECISIÓN**: Probabilidad de acierto (% - verde si 100%, naranja si menos)

*Columna 3:*
- **ORO**: Bonificación de oro (%)
- **VELOCIDAD**: Bonificación de velocidad de ataque (%)

**Inferior - Información de Progreso:**
- Mundo actual (1-12)
- Nivel actual dentro del mundo
- Progreso de nivel (X/10)
- Progreso de mundo (X/100)

**Parte Inferior - Botones de Navegación:**
- [COCINA] → Pantalla de contratación de sous-chefs
- [TÉCNICAS] → Pantalla de mejoras del chef
- [CUCHILLOS] → Pantalla de skins y cajas
- [EQUIPO] → Pantalla de equipamiento
- [REINICIAR] → Pantalla de reinicio (solo disponible desde nivel 150)

**Efectos Visuales:**
- Proyectiles de cuchillos volando hacia el enemigo
- Partículas de daño (colores según elemento)
- Textos flotantes (números de daño, MISS, CRÍTICO)
- Animación de cuchillo del jugador al hacer clic
- Efectos de golpe al impactar al enemigo

**Lógica de Interacción:**
```
AL HACER CLIC EN LA PANTALLA:
  1. Verificar precisión del chef
     SI precisiónActual >= random(0-100):
        ÉXITO:
          - Calcular daño del chef (con críticos, bonificaciones)
          - Crear proyectil visual hacia enemigo
          - Aplicar daño al enemigo
          - Reproducir sonido de impacto
          - Incrementar combo
          - Mostrar número de daño flotante
        
     SINO:
        FALLO:
          - Crear proyectil que pasa de largo
          - Reproducir sonido de fallo
          - Resetear combo
          - Mostrar texto "MISS!" en gris
  
  2. Incrementar contador de clics totales

AUTO-ATAQUE (cada frame):
  1. Sous-chefs atacan automáticamente (DPS)
  2. Crear proyectiles desde sous-chefs equipados (visual)
  3. Aplicar daño acumulado de todos los sous-chefs
  4. Actualizar barra de vida del enemigo

AL DERROTAR ENEMIGO:
  1. Calcular recompensa de oro
  2. Aplicar bonificaciones de oro (+% por mejoras, equipamiento, reinicios)
  3. Agregar oro al jugador
  4. Incrementar contador de enemigos matados
  5. Incrementar nivel
  6. Verificar drops especiales (cofres, corazones)
  7. Generar nuevo enemigo (spawnEnemy)
  8. Verificar cambio de mundo (cada 10 niveles)
  9. Reproducir sonido de victoria
```

#### 3️⃣ PANTALLA SHOP (Cocina - Contratación de Sous-chefs)
**Elementos:**
- Botón [BACK] (volver al juego)
- Lista de sous-chefs disponibles (scroll vertical)

**Cada Sous-chef muestra:**
- Nombre del sous-chef
- Elemento culinario (ícono)
- DPS base
- Costo actual (escalado según compras)
- Cantidad ya contratada
- Mundo requerido (si no desbloqueado aún)
- Botón de compra (verde si puedes, gris si no)

**Lista de Sous-chefs:**
| Nombre | DPS | Mundo | Costo Base | Elemento |
|--------|-----|-------|------------|----------|
| Chef Aprendiz | 1 | 1 | 50 | - |
| Chef de Línea | 5 | 1 | 200 | - |
| Chef Sushiman | 15 | 2 | 800 | 🌊 Agua |
| Chef Parrillero | 25 | 3 | 2,000 | 🔥 Fuego |
| Chef Panadero | 40 | 4 | 5,000 | 🌱 Tierra |
| Chef Marinero | 75 | 5 | 15,000 | 🌊 Agua |
| Chef Asador | 150 | 6 | 50,000 | 🔥 Fuego |
| Chef Vegetariano | 300 | 7 | 150,000 | 🌱 Tierra |
| Chef de Vapor | 600 | 8 | 500,000 | 🌊 Agua |
| Chef Volcánico | 1,200 | 9 | 2,000,000 | 🔥 Fuego |
| Chef Herbolario | 2,500 | 10 | 8,000,000 | 🌱 Tierra |
| Chef Ejecutivo | 5,000 | 11 | 35,000,000 | - |

**Lógica de Compra:**
```
AL PRESIONAR BOTÓN DE UN SOUS-CHEF:
  1. Verificar requisitos:
     - ¿Tengo suficiente oro?
     - ¿Está desbloqueado el mundo requerido?
  
  SI cumple requisitos:
    a. Restar oro: coins -= costoActual
    b. Añadir sous-chef a AssassinManager
    c. Incrementar contador de compras de ese sous-chef
    d. Recalcular costo: nuevoCosto = base * 1.18^compras
    e. Reproducir sonido de compra
    f. Guardar juego
  
  SINO:
    - Reproducir sonido de error
    - (Opcional) Mostrar mensaje de error
```

#### 4️⃣ PANTALLA UPGRADES (Técnicas - Mejoras del Chef)
**Elementos:**
- Botón [BACK] (volver al juego)
- Lista de mejoras disponibles (5 mejoras)

**Mejoras Disponibles:**

1. **Afilado de Cuchillos** (Sharp Edge)
   - Efecto: +1 daño por nivel
   - Costo base: 100 oro
   - Color: Amarillo

2. **Destreza Manual** (Quick Hands)
   - Efecto: +5% velocidad de ataque por nivel
   - Costo base: 150 oro
   - Color: Verde

3. **Estrella Michelin** (Lucky Coin)
   - Efecto: +10% oro por nivel
   - Costo base: 200 oro
   - Color: Dorado

4. **Corte de Precisión** (Precision Strike)
   - Efecto: +2% probabilidad de crítico por nivel
   - Costo base: 250 oro
   - Color: Rojo

5. **Técnica Letal** (Deadly Force)
   - Efecto: +25% daño crítico por nivel
   - Costo base: 300 oro
   - Color: Púrpura

6. **Precisión Culinaria** (Accuracy)
   - Efecto: +5% precisión por nivel
   - Costo base: 200 oro
   - Base: 85% precisión sin mejoras
   - Color: Cyan

**Cada mejora muestra:**
- Icono/Color identificativo
- Nombre de la mejora
- Nivel actual
- Efecto por nivel
- Bonificación total actual
- Costo del siguiente nivel
- Botón de compra

**Lógica de Mejora:**
```
AL PRESIONAR BOTÓN DE UNA MEJORA:
  1. Verificar si tienes suficiente oro
  
  SI tienes oro:
    a. Restar oro: coins -= costoActual
    b. Incrementar nivel de la mejora
    c. Recalcular costo: nuevoCosto = base * 1.18^nivel
    d. Aplicar bonificación inmediatamente
    e. Reproducir sonido de mejora
    f. Guardar juego
  
  SINO:
    - Reproducir sonido de error

CÁLCULO DE BONIFICACIONES:
  - Daño: +nivel
  - Velocidad: nivel * 0.05 (5% por nivel)
  - Oro: nivel * 0.10 (10% por nivel)
  - Crítico: nivel * 0.02 (2% por nivel)
  - Daño Crítico: nivel * 0.25 (25% por nivel)
  - Precisión: 0.85 + (nivel * 0.05)
```

#### 5️⃣ PANTALLA SKINS (Cuchillos y Cajas)
**Elementos:**
- Botón [BACK] (volver al juego)

**Sección 1: Cajas de Botín**
- Título: "=== LOOT BOXES ==="
- **Basic Box**: 100 oro
  - Todas las rarezas disponibles
- **Silver Box**: 500 oro
  - Mejores probabilidades de rarezas altas

**Sección 2: Tus Cuchillos**
- Título: "=== YOUR SKINS ==="
- Lista de todos los cuchillos que posees
- Cada cuchillo muestra:
  - Nombre
  - Rareza (Común, Rara, Épica, Legendaria, Mítica)
  - Nivel de habilidad actual
  - Tipo de habilidad y bonificación
  - Fragmentos actuales / Fragmentos necesarios para subir
  - Botón [EQUIPAR] o [DESEQUIPAR]
  - Botón [MEJORAR] (si tienes fragmentos suficientes)

**Sistema de Rarezas:**
| Rareza | Probabilidad | Fragmentos para Mejora | Color |
|--------|--------------|------------------------|-------|
| Común | 60% | 1 | Gris |
| Rara | 25% | 2 | Azul |
| Épica | 10% | 5 | Púrpura |
| Legendaria | 4% | 10 | Naranja |
| Mítica | 1% | 25 | Rojo brillante |

**Tipos de Habilidades:**
- **Damage Boost**: +10% daño por nivel
- **Critical Boost**: +5% probabilidad de crítico por nivel
- **Gold Boost**: +15% oro por nivel
- **Attack Speed**: +8% velocidad de ataque por nivel
- **Multi-Strike**: +3% probabilidad de doble golpe por nivel

**Lógica de Cajas:**
```
AL ABRIR UNA CAJA:
  1. Verificar si tienes oro suficiente
  2. Restar oro
  3. Generar rareza aleatoria según probabilidades:
     - random(0-100)
     - 0-60: Común
     - 60-85: Rara
     - 85-95: Épica
     - 95-99: Legendaria
     - 99-100: Mítica
  
  4. Seleccionar skin aleatoria de esa rareza
  5. SI ya tienes esa skin:
        - Añadir fragmentos (según rareza)
        - Mostrar: "Fragmento de [nombre]"
     SINO:
        - Desbloquear skin
        - Mostrar: "Nueva skin: [nombre]"
  
  6. Reproducir sonido de caja
  7. Mostrar animación/efecto visual
  8. Guardar juego
```

**Lógica de Equipar:**
```
AL EQUIPAR SKIN:
  1. Desequipar skin anterior (si había)
  2. Equipar nueva skin
  3. Aplicar bonificaciones de la skin
  4. Actualizar visual del cuchillo en pantalla de juego
  5. Guardar juego

AL DESEQUIPAR SKIN:
  1. Quitar bonificaciones
  2. Volver a skin por defecto
  3. Guardar juego
```

**Lógica de Mejora:**
```
AL MEJORAR SKIN:
  1. Verificar fragmentos suficientes
  2. Restar fragmentos
  3. Incrementar nivel de habilidad
  4. Aumentar bonificación
  5. Reproducir sonido de mejora
  6. Guardar juego
```

#### 6️⃣ PANTALLA EQUIPMENT (Equipamiento)
**Elementos:**
- Botón [BACK] (volver al juego)

**Diseño de Pantalla:**
```
┌─────────────────────────────────────────┐
│              EQUIPAMIENTO               │
├─────────────────────┬───────────────────┤
│   SLOTS EQUIPADOS   │   INVENTARIO      │
├─────────────────────┼───────────────────┤
│ JOYAS:              │ [Tabs]            │
│  • Collar: [slot]   │ • Joyas           │
│  • Anillo: [slot]   │ • Reliquias       │
│                     │ • Ídolos          │
│ RELIQUIAS:          │                   │
│  • Slot 1: [slot]   │ [Lista scrollable]│
│  • Slot 2: [slot]   │                   │
│                     │                   │
│ ÍDOLO:              │                   │
│  • [slot]           │                   │
│                     │                   │
│ SOUS-CHEFS:         │                   │
│  • [slot 1/5]       │                   │
│  • [slot 2/5]       │                   │
│  • [slot 3/5]       │                   │
│  • [slot 4/5]       │                   │
│  • [slot 5/5]       │                   │
└─────────────────────┴───────────────────┘
```

**3 Tipos de Equipamiento:**

**A. JOYAS (Jewels) - 2 slots:**
- **Collar** (Necklace): +15-40% daño base según tier
- **Anillo** (Ring): +8-25% oro según tier

Ambos pueden tener **bonificación elemental** adicional:
- +20-100% daño a un elemento específico (Agua/Fuego/Tierra)

**Tiers de Joyas:**
| Tier | Bonificación Collar | Bonificación Anillo |
|------|---------------------|---------------------|
| 1 | +15% daño | +8% oro |
| 2 | +20% daño | +12% oro |
| 3 | +25% daño | +16% oro |
| 4 | +30% daño | +20% oro |
| 5 | +40% daño | +25% oro |

**B. RELIQUIAS (Relics) - 2 slots:**
Potencian sous-chefs específicos o elementos:
- **Potenciación**: +50-200% DPS según tier
- **Afinidad Elemental**: Potencian sous-chefs de un elemento

**Ejemplos:**
- "Espada del Chef Sushiman" → +100% DPS al Chef Sushiman
- "Emblema del Fuego" → +50% DPS a todos los sous-chefs de Fuego

**Tiers de Reliquias:**
| Tier | Bonificación |
|------|-------------|
| 1 | +50% DPS |
| 2 | +80% DPS |
| 3 | +120% DPS |
| 4 | +150% DPS |
| 5 | +200% DPS |

**C. ÍDOLOS (Idols) - 1 slot:**
Ofrecen **gran poder a cambio de penalización**:

Ejemplos:
- **Cuchillo Carnicero** (Berserker Idol):
  - ✅ +100% daño del chef
  - ❌ -50% oro

- **Cuchara de Oro** (Greed Idol):
  - ✅ +200% oro
  - ❌ -50% daño del chef

- **Batidor Relámpago** (Swiftness Idol):
  - ✅ +100% velocidad de ataque
  - ❌ -25% daño

**D. SOUS-CHEFS EQUIPADOS - 5 slots:**
Solo los sous-chefs en estos 5 slots atacan automáticamente.
- Puedes tener 100 sous-chefs contratados pero solo 5 activos
- Estrategia: equipar los más fuertes o los que mejor sinergia tengan

**Obtención de Equipamiento:**

**Joyas:**
- Objetivo: Derrotar 250 enemigos

**Reliquias:**
- Drop: Cofres de Reliquias
- Probabilidad: 8% por enemigo derrotado
- Cuando consigues 3 cofres: obtienes 1 Reliquia aleatoria

**Ídolos:**
- Drop: Corazones de Culto
- Probabilidad: 3% por enemigo derrotado
- Cuando consigues 3 corazones: obtienes 1 Ídolo aleatorio

**Lógica de Equipamiento:**
```
AL EQUIPAR ITEM:
  1. Verificar si hay slot disponible
  2. SI slot está ocupado:
        - Desequipar item anterior
        - Volver item al inventario
  3. Equipar nuevo item
  4. Aplicar bonificaciones/penalizaciones
  5. Recalcular stats totales
  6. Guardar juego

AL DESEQUIPAR ITEM:
  1. Quitar del slot
  2. Remover bonificaciones/penalizaciones
  3. Volver item al inventario
  4. Recalcular stats totales
  5. Guardar juego

RECÁLCULO DE STATS:
  - Sumar todas las bonificaciones de todos los items equipados
  - Aplicar penalizaciones de ídolos
  - Calcular multiplicadores finales
  - Actualizar panel de estadísticas en pantalla de juego
```

#### 7️⃣ PANTALLA RESET (Reinicio/Prestigio)
**Elementos:**
- Botón [BACK] (volver al juego)
- Información de reinicio

**Requisito para Aparecer:**
- Nivel ≥ 150

**Información Mostrada:**
```
┌──────────────────────────────────────┐
│         REINICIAR PROGRESO           │
├──────────────────────────────────────┤
│                                      │
│  Nivel Actual: [nivel]               │
│  Nivel Máximo Alcanzado: [maxLevel] │
│                                      │
│  Tokens que obtendrás:               │
│    [floor(nivel / 150)] tokens       │
│                                      │
│  Tokens Totales Actuales: [tokens]  │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  BONIFICACIONES PERMANENTES POR      │
│  REINICIO:                           │
│                                      │
│  ⚔️  +5% Daño Global                 │
│  💰 +3% Oro Global                   │
│  ⚡ +2% Velocidad de Ataque         │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  BONIFICACIONES ACTUALES:            │
│  • Daño: +[reinicios * 5]%          │
│  • Oro: +[reinicios * 3]%           │
│  • Velocidad: +[reinicios * 2]%     │
│                                      │
│  ─────────────────────────────────   │
│                                      │
│  AL REINICIAR PERDERÁS:              │
│  ❌ Nivel y Mundo (vuelves a 1-1)   │
│  ❌ Oro acumulado                    │
│  ❌ Sous-chefs contratados           │
│  ❌ Mejoras de técnicas              │
│  ❌ Progreso de cofres/corazones     │
│                                      │
│  MANTENDRÁS:                         │
│  ✅ Skins desbloqueadas              │
│  ✅ Equipamiento (joyas/reliquias)   │
│  ✅ Estadísticas globales            │
│  ✅ Bonificaciones de reinicios      │
│  ✅ Tokens de reinicio               │
│                                      │
│      [CONFIRMAR REINICIO]            │
│                                      │
└──────────────────────────────────────┘
```

**Lógica de Reinicio:**
```
AL CONFIRMAR REINICIO:
  1. Calcular tokens ganados: floor(nivel / 150)
  2. Añadir tokens al total
  3. Incrementar contador de reinicios totales
  4. Actualizar nivel máximo alcanzado (si corresponde)
  5. Aplicar bonificaciones permanentes:
     - damageBonus += 0.05
     - goldBonus += 0.03
     - attackSpeedBonus += 0.02
  
  6. RESETEAR:
     - world = 1
     - level = 1
     - coins = 0
     - playerDamage = 5 (base inicial)
     - Vaciar AssassinManager (borrar sous-chefs)
     - Resetear niveles de mejoras a 0
     - relicChestProgress = 0
     - cultHeartProgress = 0
  
  7. MANTENER:
     - Skins desbloqueadas y sus niveles
     - Equipamiento en inventario y equipado
     - Estadísticas globales
     - Tokens y bonificaciones
  
  8. Generar nuevo enemigo nivel 1
  9. Guardar juego
  10. Volver a pantalla GAME

FÓRMULA DE TOKENS:
  tokens = floor(nivel / 150)
  
  Ejemplos:
  - Nivel 149: 0 tokens
  - Nivel 150: 1 token
  - Nivel 299: 1 token
  - Nivel 300: 2 tokens
  - Nivel 500: 3 tokens
```

---

## ⚔️ SISTEMA DE COMBATE

### Mecánica de Click (Ataque Manual)

```
FLUJO DE ATAQUE MANUAL:
1. Jugador hace clic en la pantalla
2. Sistema verifica PRECISIÓN:
   
   precisionBase = 85%
   precisionTotal = precisionBase + (nivelMejoraPrecision * 5%)
   random = random(0-100)
   
   SI random <= precisionTotal:
      ✅ ACIERTO
   SINO:
      ❌ FALLO

3A. ACIERTO:
   a. Calcular daño base:
      dañoBase = playerDamage + mejorasDaño
   
   b. Aplicar multiplicadores:
      multiplicadorTotal = 
        (1 + skinBonus) *
        (1 + resetBonus) *
        (1 + equipmentBonus)
      
      dañoFinal = dañoBase * multiplicadorTotal
   
   c. Verificar CRÍTICO:
      probCritico = mejoraCritico + skinCritico + equipmentCritico
      
      SI random(0-100) <= probCritico:
         multiplicadorCritico = 1.5 + (mejoraDañoCritico * 0.25)
         dañoFinal *= multiplicadorCritico
         Mostrar "CRÍTICO!" en texto flotante (rojo)
   
   d. Aplicar ventaja/desventaja ELEMENTAL:
      SI skinEquipada tiene elemento:
         dañoFinal *= elementalMultiplier
   
   e. Crear proyectil visual
   f. Aplicar daño al enemigo: enemy.takeDamage(dañoFinal)
   g. Incrementar combo: currentCombo++
   h. Mostrar número de daño flotante
   i. Reproducir sonido de impacto
   j. Generar partículas de impacto (color según elemento)
   k. Actualizar estadísticas: totalClicksDone++

3B. FALLO:
   a. Crear proyectil que pasa de largo (trayectoria fuera del enemigo)
   b. Resetear combo: currentCombo = 0
   c. Mostrar "MISS!" en gris
   d. Reproducir sonido de fallo
   e. Generar partículas grises
```

### Sistema de DPS Automático (Sous-chefs)

```
CADA FRAME (deltaTime):
1. Calcular DPS total de tous-chefs equipados:
   
   dpsTotal = 0
   
   Para cada sous-chef en equipmentManager.getEquippedAssassins():
      dpsBase = assassin.getDps()
      
      // Aplicar bonificaciones de reliquias
      SI hay reliquia que potencia este sous-chef:
         dpsBase *= (1 + relicBonus)
      
      SI hay reliquia de elemento y sous-chef es de ese elemento:
         dpsBase *= (1 + relicBonus)
      
      // Aplicar bonificaciones de reinicio
      dpsBase *= (1 + resetAttackSpeedBonus)
      
      // Aplicar penalizaciones de ídolo (si aplica)
      SI ídolo equipado afecta DPS:
         dpsBase *= idolPenalty
      
      dpsTotal += dpsBase

2. Calcular daño este frame:
   dañoEsteFrame = dpsTotal * deltaTime

3. Aplicar al enemigo:
   enemy.takeDamage(dañoEsteFrame)

4. Generar proyectiles visuales (decorativos):
   Cada X segundos, crear proyectil desde sous-chef equipado random
   hacia el enemigo

5. Actualizar progreso de drops:
   relicChestProgress += dañoEsteFrame / enemyMaxHealth
   cultHeartProgress += dañoEsteFrame / enemyMaxHealth
```

### Sistema Elemental Culinario

```
3 ELEMENTOS BASE:
┌──────────┬──────────┬──────────┐
│   🌊     │   🔥     │   🌱     │
│  AGUA    │  FUEGO   │  TIERRA  │
└──────────┴──────────┴──────────┘
    ↓          ↓          ↓
 [Vapor]   [Lava]    [Planta]
 (Sub)     (Sub)      (Sub)

VENTAJAS Y DESVENTAJAS:

AGUA vs FUEGO: 1.5x daño (el agua apaga el fuego)
AGUA vs TIERRA: 0.66x daño (tierra absorbe agua)
AGUA vs AGUA: 1.0x daño (neutral)

FUEGO vs TIERRA: 1.5x daño (fuego quema vegetales)
FUEGO vs AGUA: 0.66x daño (agua apaga fuego)
FUEGO vs FUEGO: 1.0x daño (neutral)

TIERRA vs AGUA: 1.5x daño (tierra absorbe agua)
TIERRA vs FUEGO: 0.66x daño (fuego quema)
TIERRA vs TIERRA: 1.0x daño (neutral)

VAPOR → Variante fuerte de AGUA
LAVA → Variante fuerte de FUEGO
PLANTA → Variante fuerte de TIERRA

Mismas ventajas pero más potentes.

APLICACIÓN EN COMBATE:
1. Sous-chef con elemento ataca:
   daño *= elementalMultiplier(atacante, enemigo)

2. Jugador con skin elemental ataca:
   daño *= elementalMultiplier(skin, enemigo)

3. Equipamiento con bonificación elemental:
   SI ataque es del elemento de la joya:
      daño += jewelBonus (ej. +50%)
```

### Efectos de Estado

```
VENENO (Poison):
- Aplicado por: Ataques de elemento PLANTA
- Efecto: 2% HP máxima del enemigo por segundo
- Duración: 3 segundos
- Visual: Partículas verdes en el enemigo

ARMADURA (Armor):
- Algunos enemigos tienen "stacks de armadura"
- Efecto: Reducción de daño 5% por stack (max 50%)
- Ruptura: Ataques de LAVA rompen armadura permanentemente

COMBO:
- Se incrementa con cada golpe exitoso del jugador
- Se resetea al fallar un ataque o tras 3 segundos sin golpear
- Bonificación: +1% daño por punto de combo (visual)
```

### Muerte del Enemigo

```
CUANDO enemy.currentHealth <= 0:
1. Marcar enemigo como muerto
2. Reproducir animación de muerte
3. Generar partículas de explosión

4. CALCULAR RECOMPENSAS:
   a. Oro base del enemigo:
      goldBase = enemy.goldReward
   
   b. Aplicar multiplicadores:
      goldFinal = goldBase *
        (1 + mejoraOro) *
        (1 + skinOroBonus) *
        (1 + resetOroBonus) *
        (1 + equipmentOroBonus) *
        idolModifier
   
   c. Añadir oro al jugador:
      coins += goldFinal
      totalGoldEarned += goldFinal
   
   d. Verificar drops especiales:
      // Cofre de Reliquia
      SI random(0-100) <= 8:
         relicChestsOwned++
         relicChestProgress = 0
         
         SI relicChestsOwned >= 3:
            generarReliquiaAleatoria()
            relicChestsOwned -= 3
      
      // Corazón de Culto
      SI random(0-100) <= 3:
         cultHeartsOwned++
         cultHeartProgress = 0
         
         SI cultHeartsOwned >= 3:
            generarIdoloAleatorio()
            cultHeartsOwned -= 3

5. INCREMENTAR PROGRESO:
   level++
   totalEnemiesKilled++
   
   SI level % 10 == 0:
      world++
      level = 0
      Mostrar mensaje: "¡Nuevo Mundo desbloqueado!"

6. GENERAR NUEVO ENEMIGO:
   spawnEnemy()

7. Reproducir sonido de victoria
8. Mostrar texto de oro ganado
9. Guardar juego (si han pasado >10 segundos desde último guardado)
```

---

## 📈 SISTEMA DE PROGRESIÓN

### Estructura de Niveles

```
PROGRESIÓN:
Mundo 1: Niveles 1-10
Mundo 2: Niveles 11-20  (requiere 10 enemigos derrotados mundo 1)
Mundo 3: Niveles 21-30
...
Mundo 12: Niveles 111-120

Nivel Máximo Teórico: Infinito
Nivel de Reinicio Recomendado: 150+

CADA MUNDO:
- Desbloquea nuevos sous-chefs
- Enemigos más fuertes
- Mayor recompensa de oro
- Nuevos tipos de amalgamas
```

### Escalado de Enemigos

```
CÁLCULO DE HP DEL ENEMIGO:
healthBase = 20 * (1.23 ^ nivel)

Ejemplo:
- Nivel 1: 20 HP
- Nivel 10: 140 HP
- Nivel 50: 83,000 HP
- Nivel 100: 3,300,000 HP
- Nivel 150: 145,000,000 HP

MULTIPLICADORES ADICIONALES:
- Normal: 1.0x HP, 1.0x oro
- Elite: 5.0x HP, 3.0x oro
- ⭐ Chef Menor (Mini-Boss): 15.0x HP, 7.0x oro
- 👑 Chef de Temporada (Boss): 50.0x HP, 20.0x oro

PROBABILIDADES DE APARICIÓN:
- Normal: 80%
- Elite: 15%
- Chef Menor: 4% (cada 25 enemigos aprox)
- Chef de Temporada: 1% (cada 100 enemigos aprox)
```

### Sistema de Tiers

```java
enum EnemyTier {
    NORMAL,      // Amalgamas comunes
    ELITE,       // Amalgamas mejoradas
    MINI_BOSS,   // Chef Menor (aparece cada ~25 enemigos)
    BOSS         // Chef de Temporada (aparece cada ~100 enemigos)
}

APARICIÓN SEGÚN NIVEL:
SI nivel % 10 == 0:
   → Chef de Temporada (100% garantizado)
SINO SI nivel % 5 == 0:
   → Chef Menor (80% probabilidad)
SINO:
   random = random(0-100)
   SI random <= 15:
      → Elite
   SINO:
      → Normal
```

### Sistema de Modificadores

```java
enum EnemyModifier {
    GIGANTE,      // Gigante: +30% HP, +20% oro, +50% tamaño visual
    ARMORED,      // Crujiente: +20% HP, stacks de armadura (reducción daño)
    MULTIPLE      // Desbordado: +50% HP, +30% oro, múltiples partes visuales
}

PROBABILIDAD DE MODIFICADORES:
Nivel 1-50:
  - Normal: 0-10% chance de 1 modificador
  - Elite: 100% chance de 1 modificador

Nivel 51+:
  - Normal: 10-30% chance de 1 modificador
  - Elite: 100% chance de 1 + 30% de segundo
  - Mini-Boss: 1-2 modificadores
  - Boss: 2-3 modificadores
```

### Rotación Elemental

```
ELEMENTO DEL ENEMIGO SEGÚN NIVEL:
Nivel 1-100: Fuego (amalgamas asadas y horneadas)
Nivel 101-200: Agua (amalgamas marinas y hervidas)
Nivel 201-300: Tierra (amalgamas vegetales y horneadas)
Nivel 301+: Ciclo cada 50 niveles

cycleLength = nivel <= 300 ? 100 : 50
cycle = (nivel / cycleLength) % 3

0 → Fuego
1 → Agua
2 → Tierra
```

---

## 💰 SISTEMA DE RECURSOS

### Oro (Gold/Coins)

```
OBTENCIÓN:
1. Derrotar enemigos (principal)
   oro = goldReward * multiplicadores

2. Bonos idle (cuando vuelves después de cerrar el juego)
   - No implementado aún en esta versión

GASTO:
1. Contratar sous-chefs
2. Comprar mejoras
3. Abrir cajas de skins
4. (Futuro) Comprar equipamiento directamente

MULTIPLICADORES:
✅ Mejora "Estrella Michelin": +10% por nivel
✅ Skin con Gold Boost: +15% por nivel de habilidad
✅ Anillo (joya): +8-25% según tier
✅ Bonificación de reinicio: +3% por reinicio
✅ Ídolo "Cuchara de Oro": +200% (con -50% daño)

CÁLCULO FINAL:
goldFinal = goldBase *
  (1 + 0.10 * nivelMejoraOro) *
  (1 + skinGoldBonus) *
  (1 + 0.03 * reinicios) *
  (1 + jewelGoldBonus) *
  idolMultiplier
```

### Tokens de Reinicio

```
OBTENCIÓN:
- Al reiniciar desde nivel 150+
- Fórmula: floor(nivel / 150)

USO:
- (Futuro) Comprar bonificaciones especiales
- (Futuro) Desbloquear contenido exclusivo
- Actualmente: Solo acumulación

NO SE PIERDEN AL REINICIAR
```

### Fragmentos de Skins

```
OBTENCIÓN:
- Abrir cajas y obtener skin duplicada
- Cantidad según rareza:
  - Común: 1 fragmento
  - Rara: 2 fragmentos
  - Épica: 5 fragmentos
  - Legendaria: 10 fragmentos
  - Mítica: 25 fragmentos

USO:
- Mejorar nivel de habilidad de skins
- Costo: Misma cantidad que otorga la rareza

TRACKING:
- Se guarda por cada skin individualmente
- Mapa: {nombreSkin: cantidadFragmentos}
```

### Cofres y Corazones

```
COFRES DE RELIQUIA:
- Probabilidad: 8% por enemigo derrotado
- Acumulación: Necesitas 3 para abrir
- Recompensa: 1 Reliquia aleatoria (tier basado en nivel actual)

CORAZONES DE CULTO:
- Probabilidad: 3% por enemigo derrotado
- Acumulación: Necesitas 3 para abrir
- Recompensa: 1 Ídolo aleatorio

PROGRESO:
- Se muestra barra de progreso en panel de recursos
- Se resetea al reiniciar (coffres se pierden)
- Los items ya obtenidos se mantienen
```

---

## 🎖️ SISTEMA DE MEJORAS

### Mejoras del Chef (PlayerUpgrade)

```
5 MEJORAS PRINCIPALES + 1 NUEVA:

1. Afilado de Cuchillos
   - Base: 100 oro
   - Efecto: +1 daño
   - Aplicación: playerDamage += nivel

2. Destreza Manual
   - Base: 150 oro
   - Efecto: +5% velocidad de ataque
   - Aplicación: attackSpeedMultiplier = 1 + (nivel * 0.05)

3. Estrella Michelin
   - Base: 200 oro
   - Efecto: +10% oro
   - Aplicación: goldMultiplier = 1 + (nivel * 0.10)

4. Corte de Precisión
   - Base: 250 oro
   - Efecto: +2% crítico
   - Aplicación: critChance = nivel * 0.02

5. Técnica Letal
   - Base: 300 oro
   - Efecto: +25% daño crítico
   - Aplicación: critMultiplier = 1.5 + (nivel * 0.25)

6. Precisión Culinaria
   - Base: 200 oro
   - Efecto: +5% precisión
   - Aplicación: accuracy = 0.85 + (nivel * 0.05)
   - Máximo: 100% (nivel 3+)

ESCALADO DE COSTO:
costoNivel = costoBase * (1.18 ^ nivel)

Ejemplo (Afilado de Cuchillos - 100 base):
- Nivel 1: 100 oro
- Nivel 2: 118 oro
- Nivel 3: 139 oro
- Nivel 10: 523 oro
- Nivel 20: 2,739 oro
- Nivel 50: 100,000+ oro

RESETEO:
- Se pierden al reiniciar
- Debes comprarlas de nuevo cada run
```

### Sistema de Acumulación de Stats

```
CÁLCULO DE DAÑO FINAL DEL CHEF:

1. DAÑO BASE:
   dañoBase = 5 (inicial) + mejoraAfilado

2. APLICAR MULTIPLICADORES:
   multiplicadorSkin = 1 + skinDamageBonus
   multiplicadorReinicio = 1 + (reinicios * 0.05)
   multiplicadorEquipment = 1 + totalEquipmentDamageBonus
   multiplicadorIdolo = idolDamageModifier (puede ser >1 o <1)
   
   dañoFinal = dañoBase * 
               multiplicadorSkin *
               multiplicadorReinicio *
               multiplicadorEquipment *
               multiplicadorIdolo

3. CRÍTICO:
   critChance = mejoraCritico +
                skinCriticoBonus +
                equipmentCriticoBonus
   
   critMultiplier = 1.5 + (mejoraLethal * 0.25)
   
   SI critico:
      dañoFinal *= critMultiplier

4. ELEMENTAL:
   SI ataque tiene elemento Y enemigo tiene debilidad:
      dañoFinal *= 1.5
   SI ataque tiene elemento Y enemigo tiene resistencia:
      dañoFinal *= 0.66

EJEMPLO REAL (nivel 100, 5 reinicios):
- dañoBase: 5 + 50 (mejora nivel 50) = 55
- Skin +50%: 55 * 1.5 = 82.5
- Reinicios +25%: 82.5 * 1.25 = 103.125
- Collar tier 3 +25%: 103.125 * 1.25 = 128.9
- ídolo +100%: 128.9 * 2 = 257.8
- Crítico x3.5: 257.8 * 3.5 = 902.3
→ Daño final por clic: 902
```

---

## 👨‍🍳 SISTEMA DE SOUS-CHEFS

### Mecánica General

```
CONTRATACIÓN:
1. Sous-chef está en la tienda (ShopManager)
2. Jugador paga el costo
3. Sous-chef se añade a AssassinManager (owned)
4. Contador de compras incrementa
5. Costo escala: base * 1.18^compras

EQUIPAMIENTO:
1. Sous-chefs contratados aparecen en pantalla EQUIPMENT
2. Jugador puede equipar hasta 5 sous-chefs
3. Solo los equipados generan DPS
4. Puedes cambiarlos en cualquier momento sin costo

ESTRATEGIA:
- Contratar muchos sous-chefs débiles VS pocos sous-chefs fuertes
- Equipar los que mejor sinergia tengan con reliquias
- Considerar ventajas elementales según mundo actual
```

### Lista Completa de Sous-chefs

```
┌────────────────────────────────────────────────────┐
│ NOMBRE             │ DPS │ MUNDO │ COSTO    │ ELEM │
├────────────────────┼─────┼───────┼──────────┼──────┤
│ Chef Aprendiz      │ 1   │ 1     │ 50       │ -    │
│ Chef de Línea      │ 5   │ 1     │ 200      │ -    │
│ Chef Sushiman      │ 15  │ 2     │ 800      │ 🌊   │
│ Chef Parrillero    │ 25  │ 3     │ 2K       │ 🔥   │
│ Chef Panadero      │ 40  │ 4     │ 5K       │ 🌱   │
│ Chef Marinero      │ 75  │ 5     │ 15K      │ 🌊   │
│ Chef Asador        │ 150 │ 6     │ 50K      │ 🔥   │
│ Chef Vegetariano   │ 300 │ 7     │ 150K     │ 🌱   │
│ Chef de Vapor      │ 600 │ 8     │ 500K     │ 🌊   │
│ Chef Volcánico     │ 1.2K│ 9     │ 2M       │ 🔥   │
│ Chef Herbolario    │ 2.5K│ 10    │ 8M       │ 🌱   │
│ Chef Ejecutivo     │ 5K  │ 11    │ 35M      │ -    │
└────────────────────────────────────────────────────┘

PATRÓN:
- Cada 3 mundos se repite ciclo elemental (Agua → Fuego → Tierra)
- Los últimos sous-chefs son neutros (sin elemento)
- DPS escala exponencialmente
```

### Sinergia con Otros Sistemas

```
POTENCIACIÓN POR RELIQUIAS:
- Reliquia específica: +50-200% DPS a un sous-chef
- Reliquia elemental: +50-200% DPS a todos de ese elemento

BONIFICACIÓN DE REINICIO:
- +2% velocidad de ataque por reinicio
- Aplica a TODOS los sous-chefs

PENALIZACIÓN DE ÍDOLO:
- Algunos ídolos NO afectan sous-chefs
- Ejemplo: "Cuchillo Carnicero" solo afecta daño del chef

EQUIPAMIENTO:
- Solo los 5 equipados atacan
- Resto permanecen "dormidos" en el inventario
```

---

## 🔪 SISTEMA DE CUCHILLOS (SKINS)

### Mecánica de Skins

```
FUNCIÓN:
- Cambio visual del cuchillo
- Bonificación de habilidad especial
- Nivel de habilidad mejorable con fragmentos

OBTENCIÓN:
1. Abrir cajas (Basic Box, Silver Box)
2. Obtener skin nueva → desbloquea
3. Obtener skin duplicada → fragmentos

EQUIPAMIENTO:
- Solo 1 skin equipada a la vez
- Puedes cambiar en cualquier momento sin costo
- Bonificaciones se aplican/quitan automáticamente
```

### Tipos de Habilidades

```
1. DAMAGE BOOST
   - Bonificación: +10% daño por nivel
   - Aplica a: Daño del chef
   - Ejemplo: Nivel 5 = +50% daño

2. CRITICAL BOOST
   - Bonificación: +5% probabilidad crítico por nivel
   - Aplica a: Probabilidad de crítico
   - Ejemplo: Nivel 3 = +15% crítico

3. GOLD BOOST
   - Bonificación: +15% oro por nivel
   - Aplica a: Oro ganado al matar enemigos
   - Ejemplo: Nivel 4 = +60% oro

4. ATTACK SPEED BOOST
   - Bonificación: +8% velocidad de ataque por nivel
   - Aplica a: Velocidad de ataque global
   - Ejemplo: Nivel 2 = +16% velocidad

5. MULTI-STRIKE
   - Bonificación: +3% probabilidad doble golpe por nivel
   - Aplica a: Probabilidad de atacar 2 veces
   - Ejemplo: Nivel 5 = 15% chance de doble golpe
```

### Sistema de Rarezas

```
COMÚN (Gris):
- Probabilidad: 60%
- Fragmentos para mejorar: 1
- Skins: 5 skins comunes

RARA (Azul):
- Probabilidad: 25%
- Fragmentos para mejorar: 2
- Skins: 3 skins raras

ÉPICA (Púrpura):
- Probabilidad: 10%
- Fragmentos para mejorar: 5
- Skins: 2 skins épicas

LEGENDARIA (Naranja):
- Probabilidad: 4%
- Fragmentos para mejorar: 10
- Skins: 2 skins legendarias

MÍTICA (Rojo brillante):
- Probabilidad: 1%
- Fragmentos para mejorar: 25
- Skins: 1 skin mítica

Total: 13 skins
```

### Progresión de Skills

```
MEJORA DE HABILIDAD:
1. Obtener fragmentos suficientes (según rareza)
2. Pagar fragmentos
3. Nivel de habilidad aumenta
4. Bonificación aumenta

Nivel Máximo: Ilimitado (teóricamente)
Nivel Práctico: 5-10 (dependiendo de rareza)

EJEMPLO - Skin Épica con Gold Boost:
- Nivel 1: +15% oro (desbloqueada)
- Nivel 2: +30% oro (cuesta 5 fragmentos)
- Nivel 3: +45% oro (cuesta 5 fragmentos)
- Nivel 4: +60% oro (cuesta 5 fragmentos)
- ...

ACUMULACIÓN:
- Solo puedes tener 1 skin equipada
- Las bonificaciones NO se acumulan entre skins
- Cada skin tiene su progresión independiente
```

---

## 💎 SISTEMA DE EQUIPAMIENTO

### Joyas (Jewels)

```
2 SLOTS:
- Collar (Necklace)
- Anillo (Ring)

COLLAR:
- Bonificación: +15-40% daño según tier
- Especial: Puede tener bonificación elemental
  - Elemental: +20-100% daño a amalgamas de ese elemento

ANILLO:
- Bonificación: +8-25% oro según tier
- Especial: Puede tener bonificación elemental
  - Elemental: +15-80% oro de amalgamas de ese elemento

TIERS: 1-5
- Tier superior → mayor bonificación
- Tier aleatorio al obtener (basado en nivel actual)

OBTENCIÓN:
- Recompensa por matar X enemigos (objetivo: 250)
- Tier basado en mundo actual

LÓGICA DE OBTENCIÓN:
CADA vez que matas enemigo:
  contadorEnemigos++
  
  SI contadorEnemigos >= 250:
     contadorEnemigos = 0
     tier = max(1, min(5, world / 2))
     joyaAleatoria = generarJoya(tier)
     añadirAlInventario(joyaAleatoria)
     Mostrar notificación: "¡Nueva joya!"
```

### Reliquias (Relics)

```
2 SLOTS DE EQUIPAMIENTO

FUNCIÓN:
- Potenciar sous-chefs específicos o elementos

TIPOS:
1. Reliquia Específica:
   - Nombre: "Espada del Chef Sushiman"
   - Efecto: +50-200% DPS al Chef Sushiman

2. Reliquia Elemental:
   - Nombre: "Emblema del Fuego"
   - Efecto: +50-200% DPS a todos los sous-chefs de Fuego

TIERS: 1-5
- Mayor tier → mayor bonificación

OBTENCIÓN:
- Drops: Cofres de Reliquia (8% por enemigo)
- Necesitas 3 cofres para abrir
- Recompensa: 1 Reliquia aleatoria

GENERACIÓN:
tierReliquia = max(1, min(5, world / 2))
tipoAleatorio = random(específica o elemental)

SI específica:
  sous-chefAleatorio = elegirUno(tous-chefs desbloqueados)
  bonificación = 0.50 + (tier * 0.30)
  nombrar: "Emblema de [sous-chef]"

SI elemental:
  elementoAleatorio = elegirUno(AGUA, FUEGO, TIERRA)
  bonificación = 0.50 + (tier * 0.30)
  nombrar: "Tomo de [elemento]"
```

### Ídolos (Idols)

```
1 SLOT DE EQUIPAMIENTO

FUNCIÓN:
- Gran bonificación a cambio de penalización

ÍDOLOS DISPONIBLES:

1. Cuchillo Carnicero (Berserker Idol):
   ✅ +100% daño del chef
   ❌ -50% oro ganado

2. Cuchara de Oro (Greed Idol):
   ✅ +200% oro ganado
   ❌ -50% daño del chef

3. Batidor Relámpago (Swiftness Idol):
   ✅ +100% velocidad de ataque
   ❌ -25% daño del chef

OBTENCIÓN:
- Drops: Corazones de Culto (3% por enemigo)
- Necesitas 3 corazones para abrir
- Recompensa: 1 Ídolo aleatorio

ESTRATEGIA:
- Usar Berserker en early game (más daño, menos oro OK)
- Usar Greed en late game (mucho oro para mejoras)
- Usar Swiftness para farming rápido

IMPORTANTE:
- Las penalizaciones son SIGNIFICATIVAS
- Debes desbloquear varios ídolos para cambiar según estrategia
- Solo puedes equipar 1 a la vez
```

### Sous-chefs Equipados

```
5 SLOTS DE COMBATE

FUNCIÓN:
- Solo los sous-chefs en estos slots generan DPS
- Los no equipados permanecen inactivos

ESTRATEGIA:
1. Equipar los 5 sous-chefs más fuertes
2. Considerar reliquias:
   - SI tienes reliquia de "Chef Sushiman" → equipar Chef Sushiman
3. Considerar ventaja elemental:
   - SI mundo actual es Fuego → equipar sous-chefs de Agua
4. Cambiar configuración según mundo

LÓGICA:
soloSousChefs = assassinManager.getOwned()
equipados = equipmentManager.getEquippedAssassins() // max 5

DPS = 0
Para cada assassin en equipados:
  DPS += assassin.getDps() * bonificaciones

Para assassin NO equipado:
  → No contribuye al DPS
```

---

## 🔄 SISTEMA DE REINICIO (PRESTIGIO)

### Mecánica de Prestigio

```
DISPONIBLE DESDE: Nivel 150+

RECOMPENSAS POR REINICIAR:
1. Tokens: floor(nivel / 150)
   - Nivel 150-299: 1 token
   - Nivel 300-449: 2 tokens
   - Nivel 450-599: 3 tokens
   - etc.

2. Bonificaciones Permanentes (por cada reinicio):
   - +5% daño global
   - +3% oro global
   - +2% velocidad de ataque global

SE RESETEA:
❌ Mundo y nivel (vuelves a 1-1)
❌ Oro acumulado
❌ Sous-chefs contratados (vuelves sin ninguno)
❌ Niveles de mejoras (vuelven a 0)
❌ Progreso de cofres/corazones

SE MANTIENE:
✅ Skins desbloqueadas y sus niveles
✅ Equipamiento (joyas, reliquias, ídolos)
✅ Tokens acumulados
✅ Bonificaciones de reinicios anteriores
✅ Estadísticas globales
✅ Nivel máximo alcanzado (récord)
```

### Estrategia de Reinicio

```
CUÁNDO REINICIAR:
1. Primera vez: Nivel 150 (para empezar a acumular bonificaciones)
2. Luego: Cada vez que la progresión se vuelve lenta
3. Óptimo: Cada 150-200 niveles

BENEFICIOS:
- Bonificaciones permanentes aceleran próximos runs
- Cada reinicio hace el siguiente más rápido
- Acumulación exponencial de poder

CÁLCULO DE PODER:
Reinicio 1: +5% daño, +3% oro
Reinicio 2: +10% daño, +6% oro
Reinicio 3: +15% daño, +9% oro
...
Reinicio 10: +50% daño, +30% oro

Después de 10 reinicios:
- Haces 1.5x más daño base
- Ganas 1.3x más oro base
- Atacas 1.2x más rápido

¡Progreso muchísimo más rápido!
```

---

## 🔁 LOOPS DE JUEGO

### Core Loop (Loop Principal)

```
┌─────────────────────────────────────────┐
│         1. ATACAR ENEMIGO               │
│  • Click del jugador (daño manual)      │
│  • Sous-chefs (DPS automático)          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    2. ENEMIGO RECIBE DAÑO               │
│  • Aplicar ventajas elementales         │
│  • Verificar críticos                   │
│  • Actualizar barra de vida             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    3. ENEMIGO DERROTADO                 │
│  • Obtener oro                          │
│  • Drops especiales (cofres/corazones)  │
│  • Incrementar nivel                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    4. GASTAR RECURSOS                   │
│  • Contratar sous-chefs                 │
│  • Comprar mejoras                      │
│  • Abrir cajas de skins                 │
│  • Equipar items                        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    5. PROGRESIÓN                        │
│  • Avanzar niveles y mundos             │
│  • Desbloquear contenido                │
│  • Acumular poder                       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│    6. REINICIAR (Nivel 150+)            │
│  • Obtener tokens                       │
│  • Bonificaciones permanentes           │
│  • Volver a 1-1 MÁS FUERTE              │
└──────────────┬──────────────────────────┘
               │
               └──────────► REPETIR ◄───────┘
```

### Session Loop (Loop de Sesión)

```
┌──────── INICIO DE SESIÓN ────────┐
│  1. Cargar partida guardada      │
│  2. Verificar tiempo offline     │
│  3. (Futuro) Calcular bonus idle │
│  4. Mostrar pantalla MENU        │
└──────────────┬───────────────────┘
               │
               ▼
         [START GAME]
               │
               ▼
┌──────── GAMEPLAY ACTIVO ─────────┐
│  1. Atacar enemigos              │
│  2. Navegar entre pantallas      │
│  3. Comprar mejoras/sous-chefs   │
│  4. Abrir cajas                  │
│  5. Equipar items                │
│  6. (Opcional) Reiniciar         │
└──────────────┬───────────────────┘
               │
               ▼
┌────── AUTO-SAVE (cada 10s) ──────┐
│  • Guardar todo el progreso      │
│  • Guardar timestamp             │
└──────────────┬───────────────────┘
               │
               ▼
┌──────── FIN DE SESIÓN ───────────┐
│  1. Al cerrar juego/app          │
│  2. Guardar una última vez       │
│  3. Registrar tiempo de salida   │
└──────────────────────────────────┘
```

### Progression Loop (Loop de Progresión)

```
CORTO PLAZO (1 minuto):
- Derrotar 5-10 enemigos
- Ganar suficiente oro para 1 mejora o sous-chef
- Incrementar poder inmediato

MEDIANO PLAZO (10-30 minutos):
- Avanzar 1-3 mundos
- Contratar 3-5 sous-chefs nuevos
- Abrir 2-3 cajas de skins
- Obtener 1-2 piezas de equipamiento

LARGO PLAZO (1-2 horas):
- Llegar a nivel 150+
- Prepararse para reiniciar
- Maximizar builds antes de reinicio

MUY LARGO PLAZO (múltiples sesiones):
- Acumular 10+ reinicios
- Coleccionar todas las skins
- Optimizar equipamiento perfecto
- Llegar a niveles 500+
```

---

## 🛠️ SISTEMAS AUXILIARES

### Sistema de Guardado

```
AUTO-SAVE:
- Cada 10 segundos
- Al cambiar de pantalla
- Al realizar compra importante
- Al cerrar/pausar la app

DATOS GUARDADOS:
1. Progreso Base:
   - world, level, coins
   - playerDamage
   - Estadísticas (oro total, enemigos, clics)

2. Mejoras:
   - Nivel de cada mejora
   - (Se recalculan bonificaciones al cargar)

3. Sous-chefs:
   - Cantidad de cada sous-chef
   - (Se re-añaden al AssassinManager)

4. Skins:
   - Skins desbloqueadas
   - Nivel de habilidad de cada una
   - Fragmentos acumulados
   - Skin equipada actual

5. Equipamiento:
   - Joyas en inventario y equipadas
   - Reliquias en inventario y equipadas
   - Ídolos en inventario y equipado
   - Sous-chefs equipados (nombres)

6. Reinicio:
   - Tokens totales
   - Reinicios totales
   - Nivel máximo alcanzado
   - Bonificaciones permanentes

7. Drops:
   - Cofres de reliquia (cantidad + progreso)
   - Corazones de culto (cantidad + progreso)

8. Timestamp:
   - lastPlayTime (para bonus idle futuro)

FORMATO:
- JSON serializado
- Guardado en: preferences de LibGDX
- Clave: "knifeclicker_save"
```

### Sistema de Partículas

```
TIPOS DE PARTÍCULAS:

1. IMPACTO DE CUCHILLO:
   - Color: Según elemento del ataque
   - Forma: Explosión radial
   - Duración: 0.5s
   - Ocasión: Al golpear enemigo

2. CRÍTICO:
   - Color: Amarillo brillante
   - Forma: Estrellas/destellos
   - Duración: 0.8s
   - Ocasión: Al hacer crítico

3. FALLO (MISS):
   - Color: Gris
   - Forma: Polvo/nube
   - Duración: 0.3s
   - Ocasión: Al fallar ataque

4. MUERTE DE ENEMIGO:
   - Color: Mix de colores
   - Forma: Explosión grande
   - Duración: 1.5s
   - Ocasión: Al derrotar enemigo

5. COMPRA:
   - Color: Verde/dorado
   - Forma: Brillo ascendente
   - Duración: 1s
   - Ocasión: Al comprar algo

6. LEVEL UP:
   - Color: Azul brillante
   - Forma: Anillo expansivo
   - Duración: 1.2s
   - Ocasión: Al subir de nivel/mundo

LÓGICA:
particleManager.addParticles(x, y, count, color, velocityX, velocityY, lifetime)

CADA FRAME:
- Actualizar posición de todas las partículas
- Reducir lifetime
- Eliminar partículas muertas
- Renderizar partículas vivas
```

### Sistema de Textos Flotantes

```
TIPOS DE TEXTOS:

1. DAÑO:
   - Contenido: Número de daño
   - Color: Blanco (normal), Amarillo (crítico)
   - Tamaño: Normal (normal), Grande (crítico)
   - Movimiento: Hacia arriba + desvanecimiento

2. MISS:
   - Contenido: "MISS!"
   - Color: Gris
   - Tamaño: Mediano
   - Movimiento: Hacia arriba lento

3. ORO GANADO:
   - Contenido: "+X gold"
   - Color: Dorado
   - Tamaño: Mediano
   - Movimiento: Hacia arriba flotante

4. LEVEL UP:
   - Contenido: "LEVEL UP!"
   - Color: Verde brillante
   - Tamaño: Grande
   - Movimiento: Expansión + fade

5. ITEMS:
   - Contenido: "Nueva [item]!"
   - Color: Según rareza/tipo
   - Tamaño: Mediano
   - Movimiento: Ascendente

CLASE FloatingText:
- float x, y (posición)
- String text
- Color color
- float lifetime (3 segundos)
- float velocityY (velocidad de ascenso)

CADA FRAME:
- y += velocityY * delta
- lifetime -= delta
- alpha = lifetime / 3.0 (desvanecimiento)
- SI lifetime <= 0: eliminar
```

### Sistema de Audio

```
MÚSICA:
- Background Music: Loop infinito
- Volumen: 0.3 (30%)
- Archivo: "music_background.mp3"
- Reproducción: Al iniciar juego

EFECTOS DE SONIDO (SFX):

1. knife_throw.wav
   - Ocasión: Al hacer clic / lanzar cuchillo

2. hit.wav
   - Ocasión: Al impactar enemigo

3. miss.wav
   - Ocasión: Al fallar ataque

4. critical.wav
   - Ocasión: Al hacer crítico

5. enemy_death.wav
   - Ocasión: Al derrotar enemigo

6. purchase.wav
   - Ocasión: Al comprar algo

7. upgrade.wav
   - Ocasión: Al mejorar algo

8. loot_box.wav
   - Ocasión: Al abrir caja

9. equip.wav
   - Ocasión: Al equipar item

10. level_up.wav
    - Ocasión: Al subir de nivel

11. error.wav
    - Ocasión: Al intentar compra sin oro suficiente

LÓGICA:
soundManager.playSound("nombre_sonido")

CONFIGURACIÓN:
- Volumen global: Ajustable en settings (futuro)
- Mute: Opcional (futuro)
- SFX individuales: 0.5 (50% volumen)
```

### Sistema de Sprites Procedurales

```
GENERACIÓN DE SPRITES DE ENEMIGOS:

BASADO EN:
- ElementType (color base)
- EnemyTier (tamaño, detalles)
- Modifiers (variaciones visuales)

COLORES POR ELEMENTO:
- AGUA: Azul (#4495FF)
- FUEGO: Rojo-Naranja (#FF5533)
- TIERRA: Verde (#55AA33)
- VAPOR: Cyan (#5DDDFF)
- LAVA: Rojo oscuro (#CC2222)
- PLANTA: Verde oscuro (#338822)

TAMAÑO POR TIER:
- Normal: 1.0x (120px)
- Elite: 1.2x (144px)
- Mini-Boss: 1.5x (180px)
- Boss: 2.0x (240px)

MODIFICADOR VISUAL:
- GIGANTE: +50% tamaño adicional
- CRUJIENTE: Borde grueso oscuro (armadura)
- DESBORDADO: Múltiples "partes" alrededor

GENERACIÓN:
1. Crear ShapeRenderer
2. Dibujar forma base (círculo o cuadrado)
3. Añadir detalles según tier
4. Aplicar color de elemento
5. Añadir efectos de modificadores
6. Opcional: Ojos, boca, detalles extra

RENDERIZADO:
spriteSystem.renderEnemy(enemy, batch)
```

---

## 📊 FÓRMULAS IMPORTANTES

### Escalado de Costos

```
MEJORAS:
costo = costoBase * (1.18 ^ nivel)

SOUS-CHEFS:
costo = costoBase * (1.18 ^ compras)

EJEMPLO (sous-chef de 100 base):
Compra 1: 100
Compra 2: 118
Compra 3: 139
Compra 10: 523
Compra 20: 2,739
Compra 50: 101,740
```

### Escalado de HP de Enemigos

```
healthBase = 20 * (1.23 ^ nivel)

MULTIPLICADORES:
- Normal: x1.0
- Elite: x5.0
- Mini-Boss: x15.0
- Boss: x50.0

MODIFICADORES:
- Gigante: +30%
- Crujiente: +20%
- Desbordado: +50%

FÓRMULA FINAL:
health = 20 * (1.23^nivel) * tierMultiplier * modifierMultipliers

EJEMPLO:
Nivel 100 Boss Gigante Desbordado:
= 20 * (1.23^100) * 50 * 1.30 * 1.50
= 20 * 1,654,776 * 50 * 1.95
= 3,223,715,400 HP (3.2 billones)
```

### Multiplicadores de Daño

```
DAÑO FINAL = 
  (dañoBase + mejorasBono) *
  (1 + skinBonus) *
  (1 + resetBonus) *
  (1 + equipmentBonus) *
  idolMultiplier *
  elementalMultiplier *
  critMultiplier (si aplica)

EJEMPLO DETALLADO:
- Base: 5
- Mejora Afilado nivel 50: +50 = 55
- Skin +50%: 55 * 1.5 = 82.5
- 5 reinicios (+25%): 82.5 * 1.25 = 103.1
- Collar tier 3 (+25%): 103.1 * 1.25 = 128.9
- Ídolo Berserker (+100%): 128.9 * 2 = 257.8
- Ventaja elemental (x1.5): 257.8 * 1.5 = 386.7
- Crítico x3.5 (mejora nivel 8): 386.7 * 3.5 = 1,353.45

DAÑO POR CLIC: 1,353
```

### DPS de Sous-chefs

```
DPS TOTAL = Suma de (DPS individual * bonificaciones) de los 5 equipados

DPS INDIVIDUAL =
  dpsBase *
  (1 + reliquiaBonus específica) *
  (1 + reliquiaBonus elemental) *
  (1 + resetAttackSpeedBonus) *
  elementalMultiplier

EJEMPLO:
Chef Sushiman (15 DPS base):
- Reliquia "Emblema del Chef Sushiman" tier 5: +200%
- Reliquia "Tomo del Agua" tier 3: +120%
- 5 reinicios: +10% velocidad
- Atacando enemigo Fuego: x1.5

= 15 * 3.0 * 2.2 * 1.10 * 1.5
= 15 * 10.89
= 163.35 DPS (de un solo sous-chef)

Con 5 sous-chefs similar → ~800 DPS total
```

### Oro Ganado

```
ORO FINAL =
  goldBase *
  (1 + mejoraOro) *
  (1 + skinOro) *
  (1 + resetOro) *
  (1 + joyaOro) *
  idolModifier *
  tierMultiplier

EJEMPLO:
Enemigo Elite (x3 oro) nivel 100:
- Base: 3,300,000 * 0.75 * 3 = 7,425,000
- Mejora "Estrella Michelin" nivel 20: +200%
- Skin con Gold Boost nivel 5: +75%
- 5 reinicios: +15%
- Anillo tier 4: +20%
- Ídolo "Cuchara de Oro": +200%

= 7,425,000 * 3.0 * 1.75 * 1.15 * 1.20 * 3.0
= 7,425,000 * 21.735
= 161,352,375 oro (~161M)

¡Un solo enemigo elite da 161 millones!
```

---

## 🎯 OBJETIVOS Y METAS POR ETAPA

### Early Game (Nivel 1-50)

**Objetivos:**
- Entender mecánicas básicas
- Contratar primeros sous-chefs
- Comprar mejoras iniciales
- Desbloquear primera skin

**Progreso Típico:**
- 10-20 minutos de juego
- 3-5 sous-chefs contratados
- Mejoras nivel 5-10
- 1-2 mundos completados
- 1-2 skins desbloqueadas

**Estrategia:**
- Priorizar mejora "Afilado de Cuchillos" (más daño inmediato)
- Contratar Chef Aprendiz y Chef de Línea
- Abrir Basic Boxes cuando puedas

### Mid Game (Nivel 51-150)

**Objetivos:**
- Optimizar configuración
- Acumular equipamiento
- Prepararse para primer reinicio
- Desbloquear contenido

**Progreso Típico:**
- 1-2 horas de juego
- 6-10 sous-chefs contratados
- Mejoras nivel 15-25
- 5-6 mundos completados
- 3-5 skins desbloqueadas
- 2-3 joyas obtenidas
- 1-2 reliquias obtenidas

**Estrategia:**
- Balancear mejoras de daño y oro
- Equipar sous-chefs con ventaja elemental
- Guardar oro para sous-chefs caros
- Abrir Silver Boxes

### Late Game Primer Ciclo (Nivel 150-200)

**Objetivos:**
- Maximizar poder antes de reiniciar
- Obtener mejor equipamiento
- Llegar al punto óptimo de reinicio

**Progreso Típico:**
- 2-3 horas de juego total
- 10-12 sous-chefs contratados
- Mejoras nivel 25-35
- 6-8 mundos completados
- 5-8 skins desbloqueadas
- 3-5 joyas
- 2-4 reliquias
- 1 ídolo

**Estrategia:**
- Usar ídolo "Cuchara de Oro" para maximizar oro
- Farmear oro para maximizar mejoras
- Obtener todas las reliquias posibles
- **REINICIAR alrededor de nivel 180-200**

### Post-Reinicio (Ciclos 2+)

**Objetivos:**
- Progressión acelerada por bonificaciones
- Alcanzar niveles más altos cada vez
- Optimizar builds endgame

**Progreso Típico:**
- Cada ciclo es más rápido que el anterior
- Llegas más lejos cada vez
- Acumulas más tokens
- Coleccionas todas las skins
- Perfeccionas equipamiento

**Estrategia:**
- Reiniciar cada 150-200 niveles
- Experimentar con diferentes builds
- Optimizar configuraciones de sous-chefs
- Buscar synergias perfectas

### Endgame (Nivel 500+, Múltiples Reinicios)

**Objetivos:**
- Alcanzar niveles extremos
- Completar colección 100%
- Optimización perfecta

**Características:**
- 10+ reinicios acumulados
- Bonificaciones: +50% daño, +30% oro, +20% velocidad
- Todas las skins desbloqueadas y mejoradas
- Equipamiento tier 5 optimizado
- Estrategias avanzadas

**Desafíos:**
- Superar nivel 1000
- Acumular 50+ tokens
- Tener todas las skins nivel 10+
- Configuración perfecta de equipamiento

---

## 🧠 CONSEJOS Y ESTRATEGIAS

### Optimización de Oro

```
1. PRIORIZAR MEJORA "ESTRELLA MICHELIN":
   - Cada nivel da +10% oro permanente
   - Se acumula exponencialmente

2. USAR ÍDOLO "CUCHARA DE ORO":
   - +200% oro
   - La penalización de daño se compensa con sous-chefs

3. EQUIPAR ANILLO CON ORO:
   - Buscar tier alto con bonificación elemental
   - Farmear enemigos del elemento del anillo

4. SKIN CON GOLD BOOST:
   - Equipar y mejorar
   - Combina con todo lo anterior
```

### Optimización de Daño

```
1. BALANCE MEJORAS:
   - Afilado de Cuchillos (daño directo)
   - Corte de Precisión (crítico)
   - Técnica Letal (daño crítico)

2. SKIN CON DAMAGE BOOST:
   - Buscar skin Épica o superior
   - Mejorar al máximo

3. COLLAR CON BONIFICACIÓN ELEMENTAL:
   - Equipar collar tier alto
   - Asegurarse de atacar enemigos del elemento correcto

4. ÍDOLO BERSERKER:
   - Solo si no necesitas tanto oro
   - +100% daño masivo
```

### Optimización de DPS (Sous-chefs)

```
1. RELIQUIAS ESPECÍFICAS:
   - Conseguir reliquia de tu sous-chef más fuerte
   - Potenciar sous-chefs más caros

2. RELIQUIAS ELEMENTALES:
   - Equipar 2 reliquias de diferentes elementos
   - Asegurar cobertura contra todos los enemigos

3. CONFIGURACIÓN DE 5 SLOTS:
   - NO llenar con sous-chefs débiles
   - Mejor: 3 fuertes potenciados que 5 débiles

4. VENTAJA ELEMENTAL:
   - Cambiar configuración según mundo actual
   - Sous-chefs de Agua vs enemigos de Fuego
```

### Cuándo Reiniciar

```
DECISIÓN:
SI estás en nivel 150+:
  calcularOro1hora = estimarOro(1 hora de farming actual)
  calcularOroPostReinicio = estimarOro(1 hora post-reinicio con bonos)
  
  SI calcularOroPostReinicio > calcularOro1hora:
     → Reiniciar AHORA
  SINO:
     → Seguir subiendo niveles

REGLA GENERAL:
- Primer reinicio: ~nivel 150-180
- Reinicios siguientes: +200-300 niveles cada vez
- Cuando sientes que "el progreso es lento" → es momento
```

### Gacha Optimization (Skins)

```
ESTRATEGIA:
1. Al principio: Abrir Basic Boxes (100 oro)
   - Desbloquear variedad

2. Mid game: Alternar Basic y Silver
   - Basic para fragmentos comunes
   - Silver para chance de Épicas+

3. Late game: Solo Silver Boxes
   - Mejor ROI
   - Más chance de rarezas altas

4. Mejorar primero:
   - Skins Épicas/Legendarias/Míticas
   - Habilidades que más uses (Damage > Gold > Crit)
```

---

## 🐛 CONSIDERACIONES TÉCNICAS

### Performance

```
OPTIMIZACIONES:
1. Object pooling para projectiles y partículas
2. Límite de partículas simultáneas
3. Culling de objetos fuera de pantalla
4. Batch rendering de sprites

LÍMITES:
- Máximo 100 partículas en pantalla
- Máximo 20 textos flotantes
- Máximo 10 proyectiles simultáneos
```

### Guardado y Carga

```
PREVENCIÓN DE CORRUPCIÓN:
1. Guardar en archivo temporal primero
2. Verificar integridad
3. Renombrar a archivo principal
4. Mantener backup del guardado anterior

VALIDACIÓN AL CARGAR:
1. Verificar estructura JSON
2. Validar ranges (nivel < 10000, oro < MAX_INT)
3. Validar referencias (skins existen, sous-chefs válidos)
4. Fallback a valores por defecto si corrupción
```

### Compatibilidad

```
DISEÑO RESPONSIVO:
- UI escalable según resolución
- Botones adaptables
- Textos con wrapping
- Layout fluido

PLATAFORMAS:
- Desarrollado para Android (LibGDX)
- Potencialmente portable a:
  - Desktop (Windows, Mac, Linux)
  - iOS
  - HTML5/Web
```

---

## 📝 RESUMEN EJECUTIVO

**Knife Clicker** es un clicker incremental complejo con:

✅ **7 Pantallas** (Menu, Game, Shop, Upgrades, Skins, Equipment, Reset)

✅ **6 Sistemas de Progresión** (Niveles, Sous-chefs, Mejoras, Skins, Equipamiento, Prestigio)

✅ **3 Recursos Principales** (Oro, Tokens, Fragmentos)

✅ **3 Tipos de Equipamiento** (Joyas, Reliquias, Ídolos)

✅ **Sistema Elemental** (Agua, Fuego, Tierra + subtipos)

✅ **Sistema de Combate Rico** (Precisión, Críticos, DPS, Elementales)

✅ **Loop Adictivo** (Atacar → Oro → Mejorar → Más Fuerte → Reiniciar → Repetir)

✅ **Progresión Infinita** (Siempre puedes reiniciar y volverte más fuerte)

---

## 🔮 FUTURAS EXPANSIONES (Planificadas)

### Sistema de Eventos

- Eventos temporales con recompensas especiales
- Enemigos especiales con drops únicos
- Desafíos diarios
- Misiones semanales

### Más Contenido

- Nuevos ídolos con mecánicas únicas
- Más skins (objetivo: 30 skins)
- Nuevos sous-chefs (especialistas raros)
- Artefactos legendarios

### Sistemas Sociales

- Tablas de clasificación globales
- Compartir builds
- Desafíos entre jugadores

### Monetización (Opcional)

- Cajas premium con mejores odds
- Skins exclusivas cosméticas
- Boosters temporales (x2 oro por 1 hora)
- Quitar anuncios

---

**FIN DEL DOCUMENTO**

*Knife Clicker - Versión 2.0.0 "Culinary Chaos Update"*  
*Fecha: Marzo 2026*
