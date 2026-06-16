extends Node

# === EJERCICIO 4 — UN ESTADO NUEVO EN LA MÁQUINA (🎓) ====================
# La columna del juego es una máquina de estados. Acá hay una versión chica:
# JUGANDO ↔ PAUSA. Falta un estado INTERMEDIO entre oleadas: OLEADA_LIMPIA,
# con una cuenta regresiva antes de soltar la siguiente.
#
# Hoy (roto): cuando se "limpia" la oleada, arranca la siguiente DE GOLPE, sin
# respiro. Y la pausa solo está pensada desde JUGANDO.
#
# Predicción (antes de tocar): si pausas DURANTE la cuenta regresiva y luego
# despausas, ¿a qué estado deberías volver? Con el toggle de abajo, ¿qué pasa?
# (vuelve a JUGANDO y te comes el intermedio: por eso hace falta recordar el
# estado anterior).
#
#   · Pista 1 (qué): agrega OLEADA_LIMPIA al enum. En _oleada_limpiada entra a
#     ese estado con cuenta = 3.0 en vez de empezar la oleada directo.
#   · Pista 2 (qué): en _process, while OLEADA_LIMPIA, descuenta y al llegar a
#     0 recién _empezar_oleada().
#   · Pista 3 (qué): la pausa debe funcionar desde CUALQUIER estado: guarda el
#     estado anterior antes de pausar y restáuralo al despausar (no asumas
#     JUGANDO). Ver _solutions/game_manager_oleadas_solved.gd
# ==========================================================================

enum Estado { JUGANDO, PAUSA }   # TODO: falta OLEADA_LIMPIA

var estado: Estado = Estado.JUGANDO
var oleada := 0
var cuenta := 0.0

@onready var label: Label = $UI/Estado


func _ready() -> void:
	_empezar_oleada()


func _empezar_oleada() -> void:
	oleada += 1
	estado = Estado.JUGANDO
	cuenta = 4.0    # la oleada "dura" 4 s simulados (como si pelearas)
	_refrescar()


func _process(delta: float) -> void:
	if estado == Estado.JUGANDO:
		cuenta -= delta
		if cuenta <= 0.0:
			_oleada_limpiada()
	_refrescar()


func _oleada_limpiada() -> void:
	# TODO: en vez de empezar de inmediato, entra a OLEADA_LIMPIA con cuenta 3.0.
	_empezar_oleada()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pausa"):
		return
	# TODO: que la pausa funcione desde CUALQUIER estado (recuerda el anterior).
	if estado == Estado.PAUSA:
		estado = Estado.JUGANDO
	else:
		estado = Estado.PAUSA
	_refrescar()


func _refrescar() -> void:
	match estado:
		Estado.JUGANDO:
			label.text = "Oleada %d — sobrevive  (%0.1f)" % [oleada, maxf(cuenta, 0.0)]
		Estado.PAUSA:
			label.text = "PAUSA"
