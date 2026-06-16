extends Node2D

# === EJERCICIO 2 — ACOPLE POR SEÑALES / FAN-OUT (🎓) =====================
# Un SOLO evento de daño debe disparar TRES reacciones a la vez, pero
# desacopladas: la barra baja, el sprite hace flash y la viñeta roja sube.
# Hoy: pulsas ATACAR (Espacio) y NO pasa nada — falta conectar los oyentes.
#
# La clave del módulo: el productor del evento (acá, este nodo) NO llama a la
# barra ni al shader. Solo EMITE `vida_cambiada`. Cada reacción se SUSCRIBE.
# Así, agregar una cuarta reacción no toca el productor.
#
# Predicción (antes de tocar): si dos golpes llegan en el MISMO frame, ¿la
# barra "salta" dos veces o una? ¿Y el flash? (pista: cada emit dispara a
# TODOS los oyentes; dos emits = dos rondas de reacciones).
#
#   · Pista 1 (qué): en _ready, suscribe los tres métodos a la señal.
#   · Pista 2 (con qué): senal.connect(metodo) — una vez por oyente.
#   · Pista 3 (casi-la-línea):
#       vida_cambiada.connect(_actualizar_barra)
#       vida_cambiada.connect(_flash)
#       vida_cambiada.connect(_vineta)
#
# Reto extra: agrega un cuarto oyente (un Label que muestre la vida) SIN tocar
# _unhandled_input. Si lo logras sin tocar al productor, entendiste el patrón.
# Solución en _solutions/acople_dano_solved.gd
# ==========================================================================

signal vida_cambiada(vida: int, vida_max: int)

const VIDA_MAXIMA := 100
const UMBRAL_VIDA_BAJA := 0.4

var vida := VIDA_MAXIMA

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var barra: ProgressBar = $UI/Barra
@onready var fx: ColorRect = $Pantalla/FX


func _ready() -> void:
	barra.max_value = VIDA_MAXIMA
	barra.value = vida
	# TODO (tu código): conecta los TRES oyentes a la señal vida_cambiada.
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("atacar") and vida > 0:
		vida = maxi(0, vida - 15)
		vida_cambiada.emit(vida, VIDA_MAXIMA)   # UN solo emit, varias reacciones


# --- los tres oyentes (ya escritos; solo falta suscribirlos) -------------
func _actualizar_barra(v: int, _m: int) -> void:
	barra.value = v


func _flash(_v: int, _m: int) -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("intensidad_flash", 1.0)
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/intensidad_flash", 0.0, 0.25)


func _vineta(v: int, m: int) -> void:
	var frac := float(v) / float(m)
	var dano := clampf((UMBRAL_VIDA_BAJA - frac) / UMBRAL_VIDA_BAJA, 0.0, 1.0)
	(fx.material as ShaderMaterial).set_shader_parameter("dano", dano)
