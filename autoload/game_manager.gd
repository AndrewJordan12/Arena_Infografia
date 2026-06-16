extends Node

# === GameManager — LA COLUMNA DEL JUEGO (autoload / singleton) ============
# Es la ÚNICA fuente de verdad: en qué estado está el juego, cuánta vida y
# puntaje hay, qué oleada va. Todo lo demás (HUD, shaders, spawner) se
# SUSCRIBE a sus señales y reacciona. Nadie llama directo a nadie más.
#
# La idea grande del módulo: un solo evento (recibir daño) se reparte —
# "fan-out"— a varios sistemas a la vez, pero DESACOPLADOS por el bus de
# señales. El jugador no conoce al HUD ni al shader: solo avisa acá.
#
# Está registrado como autoload (project.godot → [autoload]), así que existe
# una sola instancia accesible desde cualquier escena como `GameManager`.
# ==========================================================================

enum Estado { MENU, JUGANDO, PAUSA, GAME_OVER }

# Las señales que escuchan los demás sistemas.
signal estado_cambiado(nuevo: Estado)
signal puntaje_cambiado(puntaje: int)
signal oleada_cambiada(oleada: int)
signal vida_cambiada(vida: int, vida_max: int)

const ESCENA_MENU := "res://scenes/00_menu.tscn"
const ESCENA_ARENA := "res://scenes/01_arena.tscn"
const ESCENA_GAME_OVER := "res://scenes/02_game_over.tscn"

const VIDA_MAXIMA := 100

var estado: Estado = Estado.MENU
var puntaje: int = 0
var oleada: int = 0
var vida: int = VIDA_MAXIMA


# --- arranque de partida -------------------------------------------------
func iniciar_juego() -> void:
	# Despausar SIEMPRE antes de cambiar de escena: "paused" es del árbol, no
	# de la escena; si no, la arena nacería congelada.
	get_tree().paused = false
	puntaje = 0
	oleada = 0
	vida = VIDA_MAXIMA
	_set_estado(Estado.JUGANDO)
	get_tree().change_scene_to_file(ESCENA_ARENA)


# --- daño al jugador: el evento que se reparte a todos -------------------
func aplicar_dano(cantidad: int) -> void:
	if estado != Estado.JUGANDO:
		return
	vida = clampi(vida - cantidad, 0, VIDA_MAXIMA)
	# Un solo emit; lo escuchan la barra del HUD, el flash del jugador y la
	# viñeta de pantalla — cada uno por su cuenta.
	vida_cambiada.emit(vida, VIDA_MAXIMA)
	if vida == 0:
		game_over()


func sumar_puntaje(cantidad: int) -> void:
	puntaje += cantidad
	puntaje_cambiado.emit(puntaje)


func siguiente_oleada() -> void:
	oleada += 1
	oleada_cambiada.emit(oleada)


# --- pausa ---------------------------------------------------------------
func pausar() -> void:
	if estado != Estado.JUGANDO:
		return
	get_tree().paused = true
	_set_estado(Estado.PAUSA)


func reanudar() -> void:
	if estado != Estado.PAUSA:
		return
	get_tree().paused = false
	_set_estado(Estado.JUGANDO)


func game_over() -> void:
	get_tree().paused = false
	_set_estado(Estado.GAME_OVER)
	get_tree().change_scene_to_file(ESCENA_GAME_OVER)


func volver_al_menu() -> void:
	get_tree().paused = false
	_set_estado(Estado.MENU)
	get_tree().change_scene_to_file(ESCENA_MENU)


# Único lugar donde se cambia de estado: cambia y AVISA.
func _set_estado(nuevo: Estado) -> void:
	estado = nuevo
	estado_cambiado.emit(nuevo)
