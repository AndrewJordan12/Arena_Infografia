extends CanvasLayer

# === MENÚ DE PAUSA ========================================================
# Este nodo tiene process_mode = "Siempre" (ALWAYS) en el inspector, así que
# su código corre AUNQUE el árbol esté pausado: por eso puede escuchar Esc y
# responder a sus botones con el juego congelado.
#
# No pausa por su cuenta: le pide a GameManager (la columna) que cambie de
# estado, y se muestra/oculta reaccionando a estado_cambiado. Así la pausa, el
# HUD y el shader de gris quedan sincronizados por el MISMO evento.
# ==========================================================================


func _ready() -> void:
	visible = false
	GameManager.estado_cambiado.connect(_on_estado_cambiado)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pausa"):
		return
	if GameManager.estado == GameManager.Estado.JUGANDO:
		GameManager.pausar()
	elif GameManager.estado == GameManager.Estado.PAUSA:
		GameManager.reanudar()


func _on_estado_cambiado(nuevo: GameManager.Estado) -> void:
	visible = nuevo == GameManager.Estado.PAUSA


func _on_continuar_pressed() -> void:
	GameManager.reanudar()


func _on_menu_pressed() -> void:
	GameManager.volver_al_menu()
