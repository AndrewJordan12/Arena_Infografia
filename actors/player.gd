extends CharacterBody2D

# === JUGADOR — FSM DE ANIMACIÓN EN CÓDIGO (✅ demo / clave del módulo) =====
# La lección dura del módulo: el ataque/golpe/muerte se cierran EN CÓDIGO con
# la señal `animation_finished` de un AnimatedSprite2D normal. NO usamos
# AnimationTree ni method tracks al final del clip — eso se TRABA (es el bug
# que el ejercicio 3 te hace arreglar). Acá no hay árbol de animación.
#
# Dos reglas que hacen la FSM a prueba de trabas:
#   1) Los estados con LOOP (idle/run) se eligen cada frame en _physics_process.
#   2) Los estados BLOQUEADOS (attack/hurt/death) se entran UNA vez y solo
#      salen desde `_on_animation_finished()`. Mientras estén activos, se sale
#      temprano de _physics_process (sin movimiento, sin re-`play()`).
#
# El daño: el jugador NO toca el HUD ni el shader. Solo avisa a GameManager
# con `aplicar_dano()`. Quien quiera reaccionar (barra, flash, viñeta) se
# suscribe a la señal `vida_cambiada`. Eso es el "fan-out" desacoplado.
# ==========================================================================

enum Estado { IDLE, RUN, ATTACK, HURT, DEATH }

const VELOCIDAD := 130.0
const DANO_ATAQUE := 25
const FRAMES_ATAQUE_ACTIVOS := [1, 2]   # frames del clip "attack" donde la espada golpea
const INVULNERABLE := 0.6                # segundos sin recibir daño tras un golpe

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var golpe: GolpeArea = $Golpe                 # nuestro ataque (hace daño)
@onready var golpe_forma: CollisionShape2D = $Golpe/CollisionShape2D
@onready var recibe: Area2D = $Recibe                  # detecta el contacto enemigo

var estado: Estado = Estado.IDLE
var mirando_x := 1.0                                   # 1 derecha, -1 izquierda
var cooldown_golpe := 0.0
var golpeados := []                                    # enemigos ya golpeados en ESTE ataque


func _ready() -> void:
	add_to_group("jugador")                            # para que los enemigos nos encuentren
	golpe.dano = DANO_ATAQUE
	golpe_forma.disabled = true                        # la espada solo pega durante el ataque
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	# El flash es un SUSCRIPTOR más de vida_cambiada: el jugador reacciona a su
	# propio daño por el bus, igual que el HUD y la viñeta. (Fan-out.)
	GameManager.vida_cambiada.connect(_on_vida_cambiada)
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	# El daño por contacto se chequea SIEMPRE (incluso atacando): un enemigo
	# encima nos pega aunque estemos en pleno swing.
	cooldown_golpe = maxf(0.0, cooldown_golpe - delta)
	_chequear_contacto()

	# Estados BLOQUEADOS: ni movimiento ni cambio de animación desde acá.
	if estado in [Estado.ATTACK, Estado.HURT, Estado.DEATH]:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * VELOCIDAD

	if Input.is_action_just_pressed("atacar"):
		_entrar_ataque()
	elif dir != Vector2.ZERO:
		_cambiar_a(Estado.RUN, "run")
	else:
		_cambiar_a(Estado.IDLE, "idle")

	if dir.x != 0.0:
		mirando_x = signf(dir.x)
		sprite.flip_h = mirando_x < 0.0
		# El flip_h voltea SOLO la imagen: hay que mover la espada a mano.
		golpe.position.x = absf(golpe.position.x) * mirando_x

	move_and_slide()


func _entrar_ataque() -> void:
	estado = Estado.ATTACK
	golpeados.clear()
	sprite.play("attack")            # clip de UNA pasada (loop = off)


func _morir() -> void:
	estado = Estado.DEATH
	golpe_forma.disabled = true
	recibe.monitoring = false
	sprite.play("death")             # one-shot; queda en el último frame


# --- daño recibido por contacto ------------------------------------------
func _chequear_contacto() -> void:
	if estado == Estado.DEATH or cooldown_golpe > 0.0:
		return
	for area in recibe.get_overlapping_areas():
		if area is GolpeArea:
			_recibir_golpe(area.dano)
			return


func _recibir_golpe(dano: int) -> void:
	cooldown_golpe = INVULNERABLE
	# Solo AVISA. No toca HUD ni shader: eso lo hacen los suscriptores.
	GameManager.aplicar_dano(dano)
	if GameManager.vida <= 0:
		_morir()
	elif estado != Estado.DEATH:
		estado = Estado.HURT
		golpe_forma.disabled = true
		sprite.play("hurt")          # hurt INTERRUMPE ataque/movimiento


# --- la espada solo pega en los frames activos del ataque ----------------
func _on_frame_changed() -> void:
	if estado != Estado.ATTACK:
		return
	golpe_forma.disabled = sprite.frame not in FRAMES_ATAQUE_ACTIVOS
	if not golpe_forma.disabled:
		for area in golpe.get_overlapping_areas():
			var enemigo := area.owner
			if enemigo and enemigo not in golpeados and enemigo.has_method("recibir_golpe"):
				golpeados.append(enemigo)
				enemigo.recibir_golpe(golpe.dano)


# --- ÚNICA salida de los estados bloqueados: el clip terminó -------------
func _on_animation_finished() -> void:
	match estado:
		Estado.ATTACK, Estado.HURT:
			golpe_forma.disabled = true
			estado = Estado.IDLE
			sprite.play("idle")
		Estado.DEATH:
			pass                     # terminal: no hace nada
		_:
			pass                     # idle/run loopean: nunca llegan acá


func _on_vida_cambiada(_vida: int, _vida_max: int) -> void:
	_flash()


# Empuja el uniform del shader hacia 1.0 y un tween lo baja: el clásico
# "recibí daño" (módulo 10, set_shader_parameter + tween).
func _flash() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("intensidad_flash", 1.0)
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/intensidad_flash", 0.0, 0.25)


func _cambiar_a(nuevo: Estado, anim: String) -> void:
	if estado == nuevo:
		return                       # no reiniciar el loop cada frame
	estado = nuevo
	sprite.play(anim)
