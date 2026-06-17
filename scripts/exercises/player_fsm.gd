extends CharacterBody2D

# === EJERCICIO 3 — EL ATAQUE SE TRABA (🎓) ===============================
# Estado roto: pulsa ATACAR (Espacio) y el caballero se QUEDA CONGELADO en la
# pose de ataque para siempre — y encima puede seguir deslizándose. Ése es el
# bug clásico de combate. Tu trabajo: que el ataque TERMINE y vuelva a idle,
# SIN AnimationTree y SIN method tracks — solo código + la señal
# animation_finished de un AnimatedSprite2D normal.
#
# Predicción (antes de tocar): ¿por qué se traba? El clip "attack" NO hace loop
# (mira player_frames.tres). Entonces, ¿quién debería devolverlo a idle cuando
# termina? Y de paso: si el clip SÍ hiciera loop, ¿animation_finished llegaría
# a dispararse alguna vez? (no — los clips con loop nunca terminan).
#
# Hay DOS cosas rotas:
#   · Pista 1 (qué): durante ATTACK no debería moverse ni cambiar de animación.
#     Falta SALIR TEMPRANO de _physics_process cuando estado == ATTACK.
#   · Pista 2 (qué): cuando el clip de ataque termina, ALGO tiene que volver a
#     IDLE. Hoy _on_animation_finished está vacío.
#
#   · Pista 3 (casi-las-líneas):
#       # arriba de _physics_process:
#       if estado == Estado.ATTACK:
#           velocity = Vector2.ZERO
#           move_and_slide()
#           return
#       # en _on_animation_finished:
#       if estado == Estado.ATTACK:
#           estado = Estado.IDLE
#           sprite.play("idle")
#
# Reto extra: agrega HURT (interrumpe el ataque) y DEATH (terminal). Mira cómo
# lo hace actors/player.gd. Solución en _solutions/player_fsm_solved.gd
# ==========================================================================

enum Estado { IDLE, RUN, ATTACK }

const VELOCIDAD := 130.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var estado: Estado = Estado.IDLE


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("idle")


func _physics_process(_delta: float) -> void:
	# TODO (Pista 1): salir temprano si estamos en ATTACK (quedarse quieto).

	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * VELOCIDAD

	if Input.is_action_just_pressed("atacar"):
		_entrar_ataque()
		return
	elif estado != Estado.ATTACK and dir != Vector2.ZERO:
		_cambiar_a(Estado.RUN, "run")
	elif estado != Estado.ATTACK:
		_cambiar_a(Estado.IDLE, "idle")

	if dir.x != 0.0:
		sprite.flip_h = dir.x < 0.0

	move_and_slide()


func _entrar_ataque() -> void:
	estado = Estado.ATTACK
	sprite.play("attack")


func _on_animation_finished() -> void:
	# TODO (Pista 2): si veníamos de ATTACK, volver a IDLE.
	pass


func _cambiar_a(nuevo: Estado, anim: String) -> void:
	if estado == nuevo:
		return
	estado = nuevo
	sprite.play(anim)
