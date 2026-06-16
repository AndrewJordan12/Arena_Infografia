extends Area2D
class_name GolpeArea

# Área que HACE daño (un golpe). Solo lleva CUÁNTO daño hace; quién lo recibe
# decide qué pasa. La usan tanto el ataque del jugador como el contacto del
# enemigo. Para detectarla, otro nodo consulta sus áreas solapadas y pregunta
# `if area is GolpeArea`.

@export var dano: int = 10
