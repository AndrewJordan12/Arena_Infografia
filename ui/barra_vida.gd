extends ProgressBar

# === BARRA DE VIDA (🔨 se completa EN VIVO) ===============================
# La barra escucha la señal vida_cambiada de GameManager: el modelo avisa, la
# UI reacciona. En _ready ya queda conectada y con el máximo bien puesto. Lo
# que falta es la REACCIÓN —el cuerpo de _on_vida_cambiada—, una sola línea.
# Hasta escribirla: el jugador pierde vida pero la barra no se mueve (se nota).
#
# Es el mismo patrón del módulo 9; acá la fuente es GameManager, no un nodo
# Salud, porque la vida del jugador vive en la columna del juego.
# ==========================================================================


func _ready() -> void:
	max_value = GameManager.VIDA_MAXIMA
	value = GameManager.vida
	GameManager.vida_cambiada.connect(_on_vida_cambiada)


func _on_vida_cambiada(vida: int, _vida_max: int) -> void:
	# TODO (en vivo): que la barra refleje la vida. Es un ProgressBar; su nivel
	# se controla con la propiedad "value". Una sola línea:
	#   value = vida
	pass
