shader_type canvas_item;

// === EFECTOS DE PANTALLA (✅ reusado del módulo 10) =======================
// Un ColorRect que cubre la pantalla y LEE el frame ya dibujado
// (hint_screen_texture). Combina dos efectos manejados por uniforms que
// GameManager dispara por señales:
//   · gris → desatura todo al PAUSAR (estado PAUSA).
//   · dano → viñeta ROJA que crece cuando la vida está baja (vida_cambiada).
// Misma idea de la sesión 3: el "sprite" ahora es el juego entero.
// ==========================================================================

uniform sampler2D pantalla : hint_screen_texture, repeat_disable, filter_nearest;
uniform float gris : hint_range(0.0, 1.0) = 0.0;
uniform float dano : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 color = texture(pantalla, SCREEN_UV).rgb;

	// Pausa: desaturar por luminancia.
	float lum = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(lum), gris);

	// Vida baja: viñeta roja en los bordes (distancia al centro + smoothstep).
	float dist = length(SCREEN_UV - vec2(0.5));
	float vineta = smoothstep(0.30, 0.80, dist) * dano;
	color = mix(color, vec3(0.5, 0.0, 0.0), vineta);

	COLOR = vec4(color, 1.0);
}
