shader_type canvas_item;

// === DISOLVER + FLASH del enemigo (✅ reusado del módulo 10) ==============
// Un mismo material le da al esqueleto sus dos efectos de combate:
//   · intensidad_flash → mezcla hacia BLANCO al recibir un golpe (hit flash).
//   · progreso         → lo DISUELVE al morir: cada pixel se "quema" cuando
//                        su valor de ruido cae por debajo de progreso (discard),
//                        con un borde de fuego justo antes.
// El script empuja ambos uniforms con set_shader_parameter() + tween.
//
// OJO (gotcha del módulo 10): el material es un Resource COMPARTIDO. Si todos
// los esqueletos usan el mismo .tres, disolver a uno los disuelve a TODOS.
// Por eso en enemy.tscn el material está marcado resource_local_to_scene:
// cada esqueleto recibe su propia copia.
// ==========================================================================

uniform sampler2D ruido_tex;
uniform float progreso : hint_range(0.0, 1.0) = 0.0;
uniform float intensidad_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float ruido = texture(ruido_tex, UV).r;

	// Quemar el pixel si su ruido quedó por debajo del progreso.
	if (ruido < progreso) {
		discard;
	}

	// Hit flash: mezcla hacia blanco.
	original.rgb = mix(original.rgb, vec3(1.0), intensidad_flash);
	COLOR = original;

	// Borde de fuego: la franja justo por encima del umbral, solo al disolver.
	if (progreso > 0.0 && ruido < progreso + 0.06) {
		COLOR.rgb = vec3(1.0, 0.5, 0.1);
	}
}
