# 🎨 Guía Visual del Nuevo Formulario de Login

## Estructura Visual del Formulario

```
┌────────────────────────────────────┐
│                                    │
│         ┌──────────────┐           │  ← Fondo decorativo con patrón
│         │              │           │
│         │  [🍽️ LOGO]   │           │  ← Logo del juego (120x120)
│         │              │           │
│         └──────────────┘           │
│                                    │
│      PALETO KNIFE                  │  ← Título principal (retro)
│      INICIAR SESIÓN                │  ← Subtítulo
│                                    │
│  ╔════════════════════════════════╗│  ← Tarjeta de formulario
│  ║ EMAIL                          ║│
│  ║ ┌──────────────────────────────┐║
│  ║ │ ✉️ ejemplo@email.com        │║  ← Campo con borde NES
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ CONTRASEÑA                      ║
│  ║ ┌──────────────────────────────┐║
│  ║ │ 🔒 ••••••••  👁️             │║  ← Mostrar/ocultar contraseña
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ ╔══════════════════════════════╗║  ← Botón principal
│  ║ ║        JUGAR                 ║║
│  ║ ╚══════════════════════════════╝║
│  ╚════════════════════════════════╝│
│                                    │
│  ┌──────────────────────────────┐  │  ← Toggle para registro
│  │ ¿NUEVA CUENTA? CREAR        │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │  ← Botón de invitado
│  │  JUGAR COMO INVITADO        │  │
│  └──────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘
```

## Modo Registro

```
┌────────────────────────────────────┐
│                                    │
│         ┌──────────────┐           │
│         │              │           │
│         │  [🍽️ LOGO]   │           │
│         │              │           │
│         └──────────────┘           │
│                                    │
│      PALETO KNIFE                  │
│      CREAR CUENTA                  │  ← Cambio de título
│                                    │
│  ╔════════════════════════════════╗│
│  ║ EMAIL                          ║│
│  ║ ┌──────────────────────────────┐║
│  ║ │ ✉️ ejemplo@email.com        │║
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ USUARIO                         ║  ← Nuevo campo
│  ║ ┌──────────────────────────────┐║
│  ║ │ 👤 MiNombreDeUsuario        │║
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ CONTRASEÑA                      ║
│  ║ ┌──────────────────────────────┐║
│  ║ │ 🔒 ••••••••  👁️             │║
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ CONFIRMAR                       ║  ← Nuevo campo
│  ║ ┌──────────────────────────────┐║
│  ║ │ 🔒 ••••••••  👁️             │║
│  ║ └──────────────────────────────┘║
│  ║                                 ║
│  ║ ╔══════════════════════════════╗║  ← Texto del botón cambia
│  ║ ║     CREAR CUENTA             ║║
│  ║ ╚══════════════════════════════╝║
│  ╚════════════════════════════════╝│
│                                    │
│  ┌──────────────────────────────┐  │
│  │ ¿TIENES CUENTA? INICIA SESIÓN│  │  ← Texto toggle cambia
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  JUGAR COMO INVITADO        │  │
│  └──────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘
```

## Paleta de Colores

### Colores Base (NES Style)
```
┌─────────────────────────────────────────────┐
│ Fondo Principal        #0D0D0D (Negro)      │
│ Panel de Formulario    #1A1209 (Marrón)     │
│ Alternativo Panel      #0F1A0D (Marrón Alt) │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Borde Superior/Izq     #E8C97A (Dorado)     │
│ Borde Inferior/Der     #3D2B05 (Marrón Osc)│
│ Borde Medio            #8B6914 (Dorado Osc)│
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Texto Principal        #F5E6C8 (Crema)      │
│ Texto Secundario       #9E8A6A (Marrón)     │
│ Acentos                #FFB800 (Dorado)     │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Botón Primario         #D4380D (Rojo)       │
│ Botón Primario (Lt)    #FF6B3D (Rojo Claro)│
│ Botón Secundario       #2A4A2A (Verde)      │
│ Botón Neutral          #2D2D2D (Gris)      │
└─────────────────────────────────────────────┘
```

## Estados del Formulario

### 1️⃣ Cargando
```
┌──────────────────────────────────────┐
│ ╔═════════════════════════════════╗  │
│ ║                                 ║  │
│ ║          ⟳ CARGANDO...          ║  ← Spinner de carga
│ ║                                 ║  │
│ ╚═════════════════════════════════╝  │
└──────────────────────────────────────┘
```

### 2️⃣ Error
```
SnackBar Rojo: "Email inválido"          ← SnackBar flotante
SnackBar Rojo: "Contraseña incorrecta"
SnackBar Rojo: "Este email ya existe"
```

### 3️⃣ Éxito
```
SnackBar Verde: "¡Bienvenido NombreUsuario!"  ← SnackBar flotante
                ↓ (300ms)
        → Navega a WelcomeScreen
```

## Transiciones

### Entrada del Formulario
```
Inicio: Posición Y +30% (abajo)
Fin:    Posición Y 0% (normal)
Duración: 800ms
Curva: EaseOut
```

### Toggle Login ↔ Registro
```
Animación suave + Limpia los campos
- Los campos se limpian al cambiar
- Los textos del formulario cambian
- La animación de entrada se repite
```

## Validaciones en Tiempo Real

### Email
```
✓ No está vacío
✓ Formato válido: usuario@dominio.com
✗ Rechaza: "email" o "email@" o "@dominio.com"
```

### Contraseña
```
✓ Mínimo 6 caracteres
✓ Puede contener cualquier carácter
✗ Campos vacíos
```

### Usuario (solo registro)
```
✓ No está vacío
✓ Las contraseñas coinciden
✗ Contraseñas diferentes
```

## Interacciones

### Campo de Texto
```
Normal:    Borde NES, fondo oscuro
Activo:    Mismo borde, cursor visible
Deshabilitado: Color gris atenuado
```

### Botones
```
Normal:    Borde NES, color vibrante
Presionado: Efecto "hundido" (borde invertido)
Cargando:  Deshabilitado, muestra spinner
```

### Toggle Mostrar/Ocultar Contraseña
```
Ojo Cerrado 👁️‍🗨️  → Presionar → Ojo Abierto 👁️
Contraseña oculta   → Muestra asteriscos
Contraseña visible  → Muestra caracteres reales
```

## Accesibilidad

- Todos los campos tienen labels en mayúsculas retro
- Íconos representativos (correo, usuario, candado)
- Mensajes de error claros en español
- Alto contraste de colores
- Fuentes legibles (Press Start 2P para títulos, Roboto Mono para inputs)

## Animaciones de Feedback

```
✓ Entrada: Slide + Fade (suave)
✓ Botón presionado: Cambio de bordes
✓ Cargando: Spinner rotativo
✓ Error: SnackBar desliza desde abajo
✓ Éxito: SnackBar desliza desde abajo (verde)
```

---

**Diseñado para**: Paleto Knife - Retro 8-bit Clicker Game
**Estilo**: NES/Retro Gaming
**Fuentes**: Press Start 2P (retro), Roboto Mono (inputs)
