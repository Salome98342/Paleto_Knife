# Documentación: Sistema de Gacha, Economía y Mundo (Paleto Knife)

Este documento recopila toda la arquitectura, mecánicas y lógicas implementadas para el sistema de Gacha (Mercado Negro), la economía dual, la progresión del mundo y el manejo de entidades (Chefs y Cuchillos) en el juego.

---

## 1. Economía y Progresión del Mundo (Roguelite)

El juego opera bajo un ciclo de partidas (runs) con mecánicas idle/roguelite. La economía se divide en dos divisas principales gestionadas por el `EconomyController`:

*   **Monedas (Coins):** Moneda blanda o común.
    *   **Obtención:** Se farmean pasiva y activamente al derrotar enemigos comunes durante las oleadas.
    *   **Uso:** Mejoras de estadísticas base (Daño, Cadencia de Fuego) y progresión de nivel general.
*   **Gemas (Gems/Diamantes):** Moneda fuerte o premium.
    *   **Obtención:** Recompensas de **Jefes (Bosses)**, compleción de oleadas difíciles (Drops del mundo), logros de sesión, o (en el futuro) microtransacciones.
    *   **Uso:** Divisa exclusiva para abrir cofres en el Mercado Negro.
*   **Ciclo de Sesión (Runs):** 
    *   Cada vez que el jugador pierde toda su vida (`playerHp == 0`) o reinicia, la Oleada (`currentWave`) vuelve a 1.
    *   Los recursos guardados globalmente se conservan, pero las estadísticas de la "sesión actual" (`sessionCoins`, `sessionGems`) se reinician.

---

## 2. Sistema Gacha: Mercado Negro (`GachaStoreView`)

La tienda principal está estructurada en múltiples secciones para ofrecer variedad de invocaciones, ofertas y microtransacciones.

### Sección de Ofertas y Fichas (Diarias / Rotativas)
Ubicadas al inicio de la tienda:
*   **Ofertas Especiales:** Paquetes promocionales por tiempo limitado.
*   **Fichas de Chefs Aleatorias:** Opciones directas para comprar fragmentos (tokens) o personajes aleatorios específicos utilizando Monedas o Gemas, sirviendo como atajo para completar mejoras.

### Cofres de Chefs (Personajes)
Enfocados en desbloquear nuevos héroes jugables.
*   **Cofre Común de Chef (Gris):** 
    *   **Costo:** 100 Gemas (1x) / 900 Gemas (10x). Alta probabilidad de Chefs Comunes.
*   **Cofre Raro de Chef (Azul):** 
    *   **Costo:** 300 Gemas (1x) / 2700 Gemas (10x). Mejor probabilidad base para Chefs Raros.
*   **Cofre Épico de Chef (Morado):** 
    *   **Costo:** 800 Gemas (1x) / 7000 Gemas (10x). Garantiza o aumenta la probabilidad de Épicos y Legendarios.

### Cofres de Cuchillos (Armamento)
Enfocados en desbloquear armas que modifican ataques o estadísticas.
*   **Cofre Común de Cuchillo:** Invocaciones de armamento básico.
*   **Cofre Raro de Cuchillo:** Armas con rareza e impacto medio.
*   **Cofre Épico de Cuchillo:** Alta probabilidad de conseguir armamento Legendario o con modificadores potentes.

### Mecánica de Tiradas
*   El usuario puede comprar **1x** (invocación simple) o **10x** (invocación múltiple con descuento).
*   Al comprar, se descuentan las Gemas del `EconomyController` y se llama a `rollGacha(isChef, amount)`, indicando si el cofre pertenece a Chefs o a Cuchillos.

### Tienda Premium (Monedero)
Ubicada al final del Mercado Negro, orientada a microtransacciones e intercambio:
*   **Comprar Monedas:** Permite cambiar Gemas (moneda premium) por Monedas (moneda blanda) para acelerar mejoras base de la run.
*   **Comprar Gemas (Dinero Real):** Paquetes de microtransacciones IAP (In-App Purchases) para obtener Gemas recargando con dinero real.

---

## 3. Entidades y Rarezas (`GachaEntity`)

Tanto los Chefs (personajes) como los Cuchillos (armas) utilizan la misma clase modelo subyacente: `GachaEntity`. Esto unifica la lógica de la tienda y el inventario.

### Atributos Base
*   **`id`, `name`, `lore`:** Identificación e historia de la carta.
*   **`rarity`:** Define el color, el stat base y el peso en el algoritmo de Gacha.
*   **`isChef`:** Booleano para separar lógicamente si el drop es un personaje jugador o un arma visual/mecánica.
*   **Combate:** `baseDamage`, `baseFireRate`, `strongAgainst` (Ventajas tácticas), `weakAgainst` (Desventajas).
*   **Progresión:** `level`, `tokens` (fragmentos obtenidos de duplicados).

### Rarezas Disponibles
1.  **Común (Common):** Color Gris. 
2.  **Raro (Rare):** Color Azul.
3.  **Épico (Epic):** Color Morado.
4.  **Legendario (Legendary):** Color Dorado.

---

## 4. Sistema de Duplicados: Tokens 

Para evitar la frustración de obtener un personaje que ya se tiene bloqueado ("Bad Luck Protection"), el juego utiliza un **Sistema de Fragmentos (Tokens)**.

*   Si el algoritmo genera un `RollResult` de una entidad que no posees: `isNew = true` (Se desbloquea permanentemente).
*   Si sale una entidad que **ya posees**: `isNew = false`. Se convierte automáticamente en Tokens para esa entidad en específico.
    *   Duplicado **Común** = +1 Token
    *   Duplicado **Raro** = +5 Tokens
    *   Duplicado **Épico** = +20 Tokens
    *   Duplicado **Legendario** = +50 Tokens

**Uso de los Tokens:** Podrán ser usados en la pantalla de Equipamiento para subir de rango/estrellas a la entidad (ej: Subir Pato Lucas de Rango 1 a Rango 2 mejora su ataque de forma permanente).

---

## 5. Vistas de Interfaz (Pixel Art / Retro UI)

El flujo de interfaces fue adaptado cuidadosamente para que el diseño retro / pixel-art no sufriera modificaciones estéticas, inyectándole la lógica robusta por debajo:

### `gacha_store_view.dart` (La Tienda)
*   Renderiza las cajas estilo panel con bordes de Neon de 4px (`RetroStyle.box`).
*   Verifica saldo; si hay suficientes gemas, invoca el modal de revelación.

### `gacha_reveal_overlay.dart` (La Animación de Drop)
*   Al abrirse un cofre, bloquea la pantalla con fondo oscuro (`Colors.black87`).
*   **Secuencia de Animación (`flutter_animate`):**
    1. Cae la caja de inventario (Efecto rebote).
    2. La caja tiembla frenéticamente (Shake).
    3. Explosión blanca de silueta.
    4. Revelación del color de la carta, estadísticas reales del objeto (ATK, SPD), y un sello que dice "NEW!" o "¡DUPLICADO! +X TOKENS".
*   Soporta colas de resultados en tiros de 10x: El botón inferior dice "SIGUIENTE" hasta revelar todas las 10 cartas, y luego cambia a "¡EQUIPAR!".

### `chefs_view.dart` (El Inventario)
*   Pinta un `GridView` donde se listan dinámicamente las entidades guardadas en el `ChefController`.
*   Usa opacidad o filtros en negro/silueta para entidades aún no descubiertas (`!isUnlocked`).
*   Muestra medidores de progreso para saber cuántos Tokens faltan para la próxima mejora.

---
**Resumen del Flujo de Juego Final:**
1. Juegas oleadas -> Aparece Jefe -> Suelta **Gemas**.
2. Vas a **Mercado Negro** -> Gastas Gemas en **Cofres**.
3. El sistema tira el **Algoritmo RNG** -> Drop de Entidad.
4. ¿Ya lo tienes? -> Te da **Tokens**. ¿No lo tienes? -> Lo **desbloquea**.
5. Lo revisas en el **Inventario (Chefs View)** -> Lo equipas o lo mejoras.