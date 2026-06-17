extends ColorRect

# === CONTROLADOR DE PANTALLA (🔨 una parte se completa EN VIVO) ===========
# Maneja el shader de pantalla (pantalla_fx) reaccionando a DOS señales de
# GameManager — el "fan-out" en acción:
#   · estado_cambiado → al PAUSAR, desatura todo (uniform "gris").  ← 🔨 en vivo
#   · vida_cambiada   → con vida baja, sube la viñeta roja ("dano"). ← ya funciona
#
# No conoce al jugador ni a la pausa: solo escucha el bus y repinta. Eso es lo
# bueno del desacople: el efecto de pantalla es un suscriptor más.
# ==========================================================================

const UMBRAL_VIDA_BAJA := 0.4   # bajo el 40% de vida empieza la viñeta

@onready var mat: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	GameManager.estado_cambiado.connect(_on_estado_cambiado)
	GameManager.vida_cambiada.connect(_on_vida_cambiada)


func _on_estado_cambiado(_nuevo: GameManager.Estado) -> void:
	var gris := 1.0 if _nuevo == GameManager.Estado.PAUSA else 0.0
	mat.set_shader_parameter("gris", gris)


func _on_vida_cambiada(vida: int, vida_max: int) -> void:
	# La viñeta crece a medida que la vida cae por debajo del umbral.
	var frac := float(vida) / float(vida_max)
	var dano := clampf((UMBRAL_VIDA_BAJA - frac) / UMBRAL_VIDA_BAJA, 0.0, 1.0)
	mat.set_shader_parameter("dano", dano)
