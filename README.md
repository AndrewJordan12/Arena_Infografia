# 11._arena_survival — Capstone: sprites + UI + shaders sobre un GameManager

Proyecto Godot 4.6. **Módulo 11**, una sesión densa que **integra** los tres pilares
anteriores en un juego jugable, no en demos sueltas:

- **Sprites + animación** (módulos 4/7): el caballero y el esqueleto, con FSM en código.
- **UI** (módulo 9): menú → juego → game over, HUD por señales, pausa, tema.
- **Shaders** (módulo 10): hit flash, disolver, desaturar en pausa, viñeta de daño.

**La idea del módulo:** un juego de **arena por oleadas** (top-down). El vehículo obliga
a que los pilares se NECESITEN entre sí, y todos cuelgan de una columna: el
**GameManager**, un autoload que es la única fuente de verdad. Un solo evento —recibir
daño— se reparte (*fan-out*) a la barra de vida, al flash del sprite y a la viñeta de
pantalla, pero **desacoplado** por señales: el jugador no conoce al HUD ni al shader,
solo avisa a la columna. Ése es el corazón del capstone, el ensayo del 2do parcial.

## Cómo correr

Abre la carpeta en Godot 4.6. El juego arranca en `scenes/00_menu.tscn` (F5). Cada
escena de ejercicio se corre sola con F6.

| Escena | Tier | Qué muestra |
|---|---|---|
| `scenes/00_menu.tscn` | ✅ demo | Menú (`Control` + tema); Jugar → `GameManager.iniciar_juego()`. |
| `scenes/01_arena.tscn` | ✅ + 🔨 | El juego: jugador, esqueletos, HUD, pausa, shaders de pantalla. |
| `scenes/02_game_over.tscn` | ✅ demo | Puntaje final + reintentar; lee el puntaje de la columna. |
| `exercises/01_elite.tscn` | 🎓 ej. 1 | **Shader de paleta**: esqueleto "élite". Magenta = falta tu código. |
| `exercises/02_acople.tscn` | 🎓 ej. 2 | **Fan-out**: un golpe → barra + flash + viñeta. Conecta los oyentes. |
| `exercises/03_fsm.tscn` | 🎓 ej. 3 | **FSM de animación**: el ataque se TRABA — arréglalo (sin AnimationTree). |
| `exercises/04_oleadas.tscn` | 🎓 ej. 4 | **GameManager**: agrega el estado `OLEADA_LIMPIA` (intermedio). |

> Teclas: WASD/flechas (mover), Espacio o clic (atacar), Esc (pausa).

## Los tres niveles del proyecto

- **✅ Demos completos** — el juego corre de punta a punta: el caballero se mueve y anima,
  los esqueletos persiguen y mueren disolviéndose, el hit flash funciona, Esc pausa.
- **🔨 Placeholders del docente (`# TODO (en vivo)`)** — corren sin error pero les falta
  *la* línea que se escribe en vivo (mismo patrón de los módulos 9 y 10):
  - `ui/barra_vida.gd`: mover la barra al cambiar la vida (una línea).
  - `scripts/controlador_pantalla.gd`: desaturar la pantalla al pausar (uniform `gris`).
  - `scripts/spawner.gd`: instanciar el enemigo y meterlo en la arena (las oleadas).
  Hasta completarlas: la barra no se mueve, la pausa no se pone gris y no aparecen más
  esqueletos (pero los ya colocados a mano sí funcionan: el juego se muestra igual).
- **🎓 Ejercicios (`exercises/`)** — uno por eje de dificultad, cada uno con **estado roto
  visible**, escalera de pistas (qué → con qué → casi-la-línea) y una **predicción**.
  Soluciones en `_solutions/` (gitignored: no se reparte).

## Los cuatro ejercicios

1. **Autoría de shaders** (`shaders/exercises/palette_swap.gdshader`) — recolorear al
   esqueleto élite por luminancia, desde cero. Roto = magenta.
2. **Acople de sistemas** (`scripts/exercises/acople_dano.gd`) — un `vida_cambiada` debe
   mover la barra, flashear el sprite y subir la viñeta, todo por el bus de señales.
3. **FSM de animación** (`scripts/exercises/player_fsm.gd`) — el ataque se congela: dos
   defectos (no bloquea durante el ataque; nadie lo cierra al terminar). Se arregla con
   `animation_finished`, **no** con `AnimationTree` ni method tracks (el bug que se traba).
4. **GameManager** (`scripts/exercises/game_manager_oleadas.gd`) — agregar el estado
   intermedio `OLEADA_LIMPIA` con cuenta regresiva, y que la pausa funcione desde
   cualquier estado.

## La columna: `GameManager` (autoload)

`autoload/game_manager.gd` — máquina de estados `MENU / JUGANDO / PAUSA / GAME_OVER` y
única fuente de verdad de vida, puntaje y oleada. Emite `estado_cambiado`,
`puntaje_cambiado`, `oleada_cambiada`, `vida_cambiada`. Todo lo demás se SUSCRIBE; nadie
cruza directo a otro sistema. El daño entra por `aplicar_dano()` y se reparte solo.

## Lo que se reusa (no se reinventa)

- **UI** del módulo 9: `change_scene_to_file`, pausa con `process_mode`, HUD por señales, tema.
- **Shaders** del módulo 10: hit flash (`set_shader_parameter` + tween), disolver
  (ruido + `discard`), desaturar/viñeta de pantalla (`hint_screen_texture`).
- **Sprites**: `AnimatedSprite2D` + `SpriteFrames` recortando las hojas `knight2` (jugador)
  y `enemy` (esqueleto) del módulo de animaciones — cada hoja a su propio ancho.

## Estructura

```
11._arena_survival/
├── project.godot              # autoload GameManager, tema, mapa de entrada
├── autoload/game_manager.gd
├── actors/                    # player + enemy (.tscn/.gd) + *_frames.tres
├── ui/                        # hud, barra_vida (🔨), pausa, tema.tres
├── shaders/                   # hit_flash, disolver, pantalla_fx + exercises/palette_swap (🎓)
├── scripts/                   # spawner (🔨), controlador_pantalla (🔨), golpe_area + exercises/ (🎓)
├── scenes/                    # 00_menu, 01_arena, 02_game_over
├── exercises/                 # 01_elite, 02_acople, 03_fsm, 04_oleadas (🎓)
├── assets/                    # knight2/ + enemy/ (hojas pixel-art)
└── _solutions/                # soluciones de 🔨 y 🎓 (gitignored)
```

## Verificación

Probado en Godot 4.6 (headless + render): importa sin errores; las 7 escenas cargan; el
daño por contacto baja la vida y dispara el flash; un golpe letal lleva al esqueleto a
`death` → disolver → `queue_free`; Esc pausa y (al completar el 🔨) desatura.
