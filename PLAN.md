# 11._arena_survival — Plan del módulo (capstone de una sesión)

> **Estado: IMPLEMENTADO.** El proyecto está construido y verificado (ver `README.md`).
> Decisión final: **una sesión densa, los cuatro ejercicios en clase**.
> Desviaciones respecto al plan original, por robustez/claridad:
> - El shader del enemigo es uno solo, `disolver.gdshader` (combina disolver + flash);
>   el de pantalla es `pantalla_fx.gdshader` (combina gris de pausa + viñeta de daño).
> - El juego ✅ corre completo; los 🔨 son tres huecos (barra, gris de pausa, spawn),
>   y los 🎓 son escenas aparte en `exercises/` (el juego sirve de respuesta de referencia).
> Proyecto Godot 4.6 independiente (como `8._swarms`, `9._ui`, `10._shaders`).

## La idea del módulo

Una sola sesión que **integra** los tres pilares de los módulos anteriores en un juego
jugable, no en demos sueltas. El reto es difícil a propósito: es el último ensayo antes
del proyecto final (2do parcial), y aquí cada concepto es *carga estructural* — si lo
sacas, el juego se rompe.

El vehículo es una **arena de supervivencia por oleadas** (top-down): el caballero está
en una arena cerrada, los esqueletos entran por oleadas, sobrevives y sumas puntaje.

Por qué ese vehículo: hace que los tres pilares **se necesiten entre sí**.

- **Sprites + animación** — el caballero (idle/run/attack/hurt/death) y el esqueleto
  (walk/attack/death) son el sustrato del juego.
- **UI** — el HUD (vida, puntaje, oleada) se actualiza **por señales**, no por
  polling; menú de pausa; pantalla de game over. Reusa el esqueleto
  menú→juego→game-over del módulo 9 (`05`→`07`→`08`) **a propósito**.
- **Shaders** — cada shader tiene una razón de juego: *hit flash* al recibir daño
  (uniform empujado desde GDScript, módulo 10 S2), *disolver* al morir un enemigo,
  *desaturar la pantalla* en pausa y *viñeta* con vida baja (`hint_screen_texture`,
  módulo 10 S3).
- **GameManager** — la máquina de estados que es la *columna* de todo lo anterior.

El grafo de dependencias es real: el HUD escucha la misma señal `vida_cambiada` que
dispara el hit flash; la pausa voltea a la vez `get_tree().paused` y el shader de
desaturado. Esa es la lección: estos sistemas se hablan, y se hablan **desacoplados**
a través del GameManager.

## La columna: `GameManager` (autoload / singleton)

Única fuente de verdad. Todo lo demás **se suscribe**; nada cruza directo a otro sistema.

```
enum Estado { MENU, JUGANDO, PAUSA, GAME_OVER }   # (+ OLEADA_LIMPIA en el ejercicio 4)

# señales
signal estado_cambiado(nuevo: Estado)
signal puntaje_cambiado(puntaje: int)
signal oleada_cambiada(oleada: int)
signal vida_cambiada(vida: int, vida_max: int)

# estado
var estado: Estado
var puntaje: int
var oleada: int

# API
func iniciar_juego()
func pausar() / reanudar()
func game_over()
func sumar_puntaje(n: int)
func aplicar_dano(n: int)
```

- El **HUD** se suscribe a `puntaje_cambiado / oleada_cambiada / vida_cambiada`.
- El **controlador de shaders de pantalla** se suscribe a `estado_cambiado` (pausa → gris)
  y a `vida_cambiada` (vida baja → viñeta).
- El **jugador** llama a `GameManager.aplicar_dano()` y nunca toca al HUD ni al shader.

## Decisión de arte (reusar arte de módulos)

Pareja **coherente en pixel-art de 32 px** sacada de `7._godot/animations_demo/assets/texture/`:

- **Jugador — `knight2/`** (spritesheets pixel-art). Frame **120×80**.
  - `_Idle` 1200×80 → 10 frames · `_Run` 1200×80 → 10 · `_Attack` 480×80 → 4 ·
    `_Hit` 120×80 → 1 · `_Death` 1200×80 → 10. (Tiene muchas más que no usamos:
    Slide, WallClimb, Dash… son de plataformas.)
- **Enemigo — `enemy/` (esqueleto)** spritesheets, ~32 px de alto. **Dimensiones
  irregulares** (Idle 264×32, Walk 286×33, Attack 774×37, Hit 240×32, Dead 495×32) →
  hay que recortar frames por hoja a mano (no son múltiplos limpios; tarea de build).

> Se descartó el `knight/` hi-res (587×707): se ve roto junto a un esqueleto de 32 px
> sin un escalado agresivo.

## Escenas y niveles (una sola sesión)

A diferencia de los módulos 8–10, esto es **una sesión**, así que la tabla va por
escena/sistema, no por sesión.

| Escena / archivo | Tier | Qué muestra |
|---|---|---|
| `scenes/00_menu.tscn` | ✅ demo | Menú `Control`, botón Jugar → `GameManager.iniciar_juego()` |
| `scenes/01_arena.tscn` | ✅ demo | El corte vertical completo (abajo) |
| `scenes/02_game_over.tscn` | ✅ demo | Puntaje final + Reintentar |
| `Player.tscn` | ✅ demo | FSM de animación (idle/run/attack/hurt/death) + hit flash |
| `Enemy.tscn` | ✅ demo | Esqueleto que persigue, muere con disolver |
| `HUD.tscn` | ✅ demo | Barra de vida + puntaje + oleada, **solo por señales** |
| `Spawner` (en arena) | 🔨 docente | Genera oleadas — se cablea en vivo |
| Acople pausa→gris | 🔨 docente | Esc pausa Y desatura la pantalla — en vivo |
| Flujo game over | 🔨 docente | `estado_cambiado(GAME_OVER)` → cambia de escena |
| `palette_swap.gdshader` | 🎓 ejercicio 1 | Esqueleto "élite" por intercambio de paleta |
| acople de daño | 🎓 ejercicio 2 | Un evento de daño → HUD + flash + viñeta |
| FSM de animación | 🎓 ejercicio 3 | Ataque que no se traba; hurt interrumpe; muerte terminal |
| `OLEADA_LIMPIA` | 🎓 ejercicio 4 | Estado intermedio con cuenta regresiva |

### El corte vertical ✅ (lo que corre tal cual)

El caballero se mueve y anima · un esqueleto lo persigue y muere con disolver · el HUD
muestra vida/puntaje en vivo · el hit flash funciona · Esc pausa y pone gris. Se lee de
arriba a abajo.

## Los tres niveles del proyecto (convención del curso)

- **✅ Demos completos** — el corte vertical de arriba, para proyectar y correr.
- **🔨 Placeholders del docente (`# TODO (en vivo)`)** — corren sin error pero les
  falta *el* cableado transversal, que se escribe en vivo:
  - el spawner de oleadas,
  - el acople pausa→desaturado (toca los tres pilares a la vez),
  - el flujo de game over.
- **🎓 Ejercicios + `_solutions/`** (en `.gitignore`: no se reparte) — uno por eje de
  dificultad (abajo), cada uno con escalera de pistas (qué → con qué → casi-la-línea),
  un **estado roto visible**, y una pregunta-predicción.

## Los cuatro ejercicios difíciles (mapeo a los ejes que pediste)

1. **Autoría de shaders** — escribir `palette_swap.gdshader` desde cero para una variante
   "élite" del esqueleto, más un disolver de color distinto.
   *Estado roto:* el élite arranca en magenta. *Pista en escalera.*

2. **Acople de sistemas** — un evento de daño hace *fan-out*: la misma señal
   `vida_cambiada` debe (a) mover la barra del HUD, (b) disparar el hit flash, (c) con
   vida baja prender la viñeta de pantalla — todo **desacoplado** vía GameManager (el
   jugador no conoce ni al HUD ni al shader).
   *Predicción:* ¿qué pasa si dos esqueletos golpean en el mismo frame?

3. **FSM de animación** — ataque que **termina** antes de volver a idle, hurt que
   interrumpe, muerte terminal — temporizado **en código** con la señal
   `animation_finished`, **no** con method tracks del AnimationTree (el bug de trabado
   que ya pisamos: las method keys al final del clip lo encajan).
   *Estado roto:* se entrega una versión donde el ataque se traba.

4. **GameManager** — agregar un estado `OLEADA_LIMPIA` intermedio con cuenta regresiva,
   y que la pausa funcione **desde cualquier estado** con shaders/HUD reaccionando bien.
   *Predicción:* transiciones ilegales (¿pausar en GAME_OVER?).

## Árbol de archivos propuesto

```
11._arena_survival/
├── project.godot
├── README.md                    # (versión final de este plan, para el alumno)
├── PLAN.md                       # este documento
├── autoload/
│   └── game_manager.gd
├── scenes/
│   ├── 00_menu.tscn
│   ├── 01_arena.tscn
│   └── 02_game_over.tscn
├── actors/
│   ├── player.tscn / player.gd
│   └── enemy.tscn / enemy.gd
├── ui/
│   ├── hud.tscn / hud.gd
│   └── theme.tres
├── shaders/
│   ├── hit_flash.gdshader
│   ├── dissolve.gdshader
│   ├── screen_desaturate.gdshader
│   ├── vignette.gdshader
│   └── exercises/
│       └── palette_swap.gdshader     # 🎓 estado roto (magenta)
├── scripts/
│   └── exercises/                    # versiones 🎓 con TODO
├── assets/                            # knight2 + skeleton importados
└── _solutions/                        # .gitignore
```

## Orden de build sugerido

1. `project.godot` + autoload `GameManager` (la columna primero).
2. Importar arte: `SpriteFrames` del caballero (frames 120×80) y recorte del esqueleto.
3. `Player.tscn` + FSM de animación ✅ (la versión que funciona).
4. `Enemy.tscn` + persecución simple + disolver.
5. `HUD.tscn` por señales + shaders de sprite (hit flash).
6. Escenas menú/arena/game-over + shaders de pantalla (pausa/viñeta).
7. Degradar a los tres niveles: marcar `# TODO (en vivo)` y tallar los 🎓 ejercicios + `_solutions/`.
8. `README.md` final + decks/guías al estilo de los módulos 8–10.

## Decisiones de diseño (cerradas)

- **Movimiento del jugador:** top-down de **8 direcciones**. `CharacterBody2D` +
  `move_and_slide` contra las paredes de la arena. Sin físicas de empuje — el foco queda
  en animación/shaders/UI.
- **Combate (en ambos sentidos):**
  - *Tú atacas:* hitbox cuerpo a cuerpo (`Area2D`) **activa solo durante los frames de
    Attack** del caballero — enseña el timing de la hitbox contra el clip de animación.
  - *Ellos dañan:* el esqueleto hace daño **por contacto** (su propia `Area2D`).
- **Alcance de la entrega:** paquete de módulo **completo**, igual que 8–10 — proyecto
  Godot + `README.md` + diapositivas (decks) + guía del docente + diagramas.

## Entregables (paquete completo, estilo módulos 8–10)

- Proyecto Godot `11._arena_survival/` con los tres niveles (✅ / 🔨 / 🎓 + `_solutions/`).
- `README.md` para el alumno (versión final de este plan).
- **Decks** (diapositivas) de la sesión.
- **Guía del docente** (qué se escribe en vivo, los gotchas, las respuestas a las predicciones).
- **Diagramas** (la columna GameManager + el fan-out de señales).
```
