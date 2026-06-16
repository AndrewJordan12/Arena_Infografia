extends CanvasLayer

# === HUD — ESCUCHA AL GameManager Y MUESTRA =============================
# El HUD no calcula nada: se suscribe a las señales de GameManager y refresca
# sus etiquetas. La barra de vida se conecta SOLA (barra_vida.gd); el HUD ni
# la toca. Cada widget escucha lo que le importa.
# ==========================================================================

@onready var puntaje_label: Label = $Margen/Fila/Puntaje
@onready var oleada_label: Label = $Margen/Fila/Oleada


func _ready() -> void:
	GameManager.puntaje_cambiado.connect(_on_puntaje_cambiado)
	GameManager.oleada_cambiada.connect(_on_oleada_cambiada)
	# Estado inicial (por si ya hubo cambios antes de entrar a la escena).
	_on_puntaje_cambiado(GameManager.puntaje)
	_on_oleada_cambiada(GameManager.oleada)


func _on_puntaje_cambiado(puntaje: int) -> void:
	puntaje_label.text = "Puntaje: %d" % puntaje


func _on_oleada_cambiada(oleada: int) -> void:
	oleada_label.text = "Oleada: %d" % oleada
