extends Control

# === GAME OVER ============================================================
# Lee el puntaje final de GameManager (la columna lo conservó al cambiar de
# escena) y deja reintentar o volver al menú.
# ==========================================================================

@onready var puntaje_label: Label = $Centro/Panel/Caja/Puntaje


func _ready() -> void:
	puntaje_label.text = "Puntaje final: %d" % GameManager.puntaje


func _on_reintentar_pressed() -> void:
	GameManager.iniciar_juego()


func _on_menu_pressed() -> void:
	GameManager.volver_al_menu()
