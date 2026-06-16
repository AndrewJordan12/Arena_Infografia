shader_type canvas_item;

// === HIT FLASH (✅ reusado del módulo 10) =================================
// EL PUENTE juego→shader: GDScript escribe el uniform con
// set_shader_parameter(). Al recibir daño, el script sube intensidad_flash a
// 1.0 y un tween la baja a 0.0. El shader mezcla el color hacia BLANCO según
// esa intensidad — el clásico "recibí daño" de todos los juegos.
// ==========================================================================

uniform float intensidad_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	original.rgb = mix(original.rgb, vec3(1.0), intensidad_flash);
	COLOR = original;
}
