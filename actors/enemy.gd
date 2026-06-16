extends CharacterBody2D

# === ENEMIGO (esqueleto) — MISMA FSM EN CÓDIGO QUE EL JUGADOR =============
# Estados WALK → ATTACK → HURT → DEATH, sin AnimationTree: las transiciones
# de los clips de UNA pasada (attack/hurt/death) se cierran con
# `animation_finished`. Persigue al jugador (grupo "jugador").
#
# Daño: el esqueleto pega por CONTACTO (su área Golpe siempre está activa; el
# jugador la detecta solo). Recibe daño cuando el área Golpe del jugador toca
# su área Recibe durante el ataque.
#
# Al morir: suma puntaje, reproduce "death" y se DISUELVE con el shader antes
# de borrarse. El material es local a la escena (cada esqueleto, el suyo).
# ==========================================================================

enum Estado { WALK, ATTACK, HURT, DEATH }

const VELOCIDAD := 55.0
const ACEL := 320.0
const RANGO_ATAQUE := 24.0
const VIDA_MAXIMA := 50
const PUNTOS_AL_MORIR := 10

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var golpe: GolpeArea = $Golpe          # contacto que daña al jugador
@onready var recibe: Area2D = $Recibe           # detecta el ataque del jugador

var estado: Estado = Estado.WALK
var vida: int = VIDA_MAXIMA
var objetivo: Node2D = null


func _ready() -> void:
	objetivo = get_tree().get_first_node_in_group("jugador")
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("walk")


func _physics_process(delta: float) -> void:
	# Estados BLOQUEADOS: frenan y esperan a que el clip termine.
	if estado in [Estado.ATTACK, Estado.HURT, Estado.DEATH]:
		velocity = velocity.move_toward(Vector2.ZERO, ACEL * delta)
		move_and_slide()
		return

	if not is_instance_valid(objetivo):
		velocity = velocity.move_toward(Vector2.ZERO, ACEL * delta)
		move_and_slide()
		return

	var dir := global_position.direction_to(objetivo.global_position)
	sprite.flip_h = dir.x < 0.0
	if global_position.distance_to(objetivo.global_position) <= RANGO_ATAQUE:
		_entrar_ataque()
	else:
		velocity = velocity.move_toward(dir * VELOCIDAD, ACEL * delta)
	move_and_slide()


func _entrar_ataque() -> void:
	estado = Estado.ATTACK
	velocity = Vector2.ZERO
	sprite.play("attack")           # one-shot; el contacto daña por su cuenta


# Lo llama el jugador cuando su espada nos alcanza (ver player._on_frame_changed).
func recibir_golpe(dano: int) -> void:
	if estado == Estado.DEATH:
		return
	vida -= dano
	_flash()
	if vida <= 0:
		_morir()
	else:
		estado = Estado.HURT
		sprite.play("hurt")          # hurt interrumpe lo que estuviera haciendo


func _morir() -> void:
	estado = Estado.DEATH
	# Deja de dañar y de poder ser golpeado (set_deferred: estamos en señal física).
	golpe.set_deferred("monitorable", false)
	recibe.set_deferred("monitorable", false)
	GameManager.sumar_puntaje(PUNTOS_AL_MORIR)
	sprite.play("death")


func _on_animation_finished() -> void:
	match estado:
		Estado.ATTACK, Estado.HURT:
			estado = Estado.WALK
			sprite.play("walk")
		Estado.DEATH:
			_disolver()              # terminó "death": ahora se disuelve y se borra
		_:
			pass                     # walk loopea: no llega acá


func _disolver() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		queue_free()
		return
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/progreso", 1.0, 0.7)
	tween.tween_callback(queue_free)


func _flash() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("intensidad_flash", 1.0)
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/intensidad_flash", 0.0, 0.2)
