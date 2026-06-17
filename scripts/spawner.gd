extends Node2D

# === SPAWNER DE OLEADAS (🔨 la línea clave se completa EN VIVO) ===========
# Cada oleada suelta más esqueletos, de a uno cada cierto intervalo, en un
# borde de la arena. Cuando no queda ninguno vivo, arranca la oleada siguiente
# (y avisa a GameManager para que el HUD muestre el número).
#
# La línea que falta es la que CREA el enemigo y lo mete en la arena. Hasta
# escribirla no aparece ninguno (pero el esqueleto ya colocado a mano en la
# escena sí funciona: por eso el resto del juego se puede mostrar igual).
# ==========================================================================

@export var escena_enemigo: PackedScene
@export var intervalo := 1.4
@export var base_por_oleada := 4

const CENTRO := Vector2(320, 180)
const RADIO_APARICION := 210.0

var _por_aparecer := 0
var _vivos := 0
var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_aparecer)
	_iniciar_oleada()


func _iniciar_oleada() -> void:
	GameManager.siguiente_oleada()
	_por_aparecer = base_por_oleada + GameManager.oleada * 2
	_timer.start(intervalo)


func _aparecer() -> void:
	if _por_aparecer <= 0:
		_timer.stop()
		return
	if escena_enemigo == null:
		return
	_por_aparecer -= 1
	var e := escena_enemigo.instantiate()
	e.global_position = _punto_borde()
	add_child(e)
	e.tree_exited.connect(_on_enemigo_fuera)
	_vivos += 1


func _on_enemigo_fuera() -> void:
	_vivos -= 1
	if _vivos <= 0 and _por_aparecer <= 0:
		_iniciar_oleada()


# Un punto al azar en el borde de la arena (sobre un círculo alrededor del centro).
func _punto_borde() -> Vector2:
	var ang := randf() * TAU
	return CENTRO + Vector2(cos(ang), sin(ang)) * RADIO_APARICION
