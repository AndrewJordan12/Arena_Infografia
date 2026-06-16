extends Control

# === MENÚ PRINCIPAL =======================================================
# Cada botón emite "pressed" hacia arriba; lo recibimos y le pedimos a la
# columna (GameManager) que arranque la partida. GameManager resetea el
# estado y cambia a la escena de la arena.
# ==========================================================================


func _on_jugar_pressed() -> void:
	GameManager.iniciar_juego()


func _on_salir_pressed() -> void:
	get_tree().quit()
