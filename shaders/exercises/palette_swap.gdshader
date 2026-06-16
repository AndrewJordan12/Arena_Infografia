shader_type canvas_item;

// === EJERCICIO 1 — INTERCAMBIO DE PALETA (🎓) ============================
// Reto: un esqueleto "élite" con su propia paleta de color, escribiendo un
// shader desde cero. Hoy sale MAGENTA = falta tu código.
//
// Idea: NO inventamos colores por pixel; tomamos la LUMINANCIA del pixel
// (qué tan claro es) y la usamos para mezclar entre un color de SOMBRA y uno
// de BRILLO. Así el dibujo conserva su forma pero cambia de paleta.
//
// Predicción (antes de tocar): si solo multiplicaras el color por rojo
// (COLOR.rgb *= vec3(1,0,0)), ¿por qué se vería mal? (pista: las zonas
// oscuras se vuelven negras, pierdes el volumen).
//
//   · Pista 1 (qué): saca la luminancia del color original y úsala como
//     factor de mezcla entre color_sombra y color_brillo.
//   · Pista 2 (con qué): lum = dot(rgb, vec3(0.299,0.587,0.114));  mix(a,b,lum).
//   · Pista 3 (casi-la-línea):
//       float lum = dot(original.rgb, vec3(0.299, 0.587, 0.114));
//       vec3 elite = mix(color_sombra.rgb, color_brillo.rgb, lum);
//       COLOR = vec4(elite, original.a);
//
// Reto extra: que el alpha original mande (no pintes los pixeles transparentes
// — ya está resuelto usando original.a). Y prueba otra paleta en el inspector.
// Solución en _solutions/palette_swap_solved.gdshader
// ==========================================================================

uniform vec4 color_sombra : source_color = vec4(0.25, 0.0, 0.05, 1.0);
uniform vec4 color_brillo : source_color = vec4(1.0, 0.85, 0.2, 1.0);

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	// TODO (tu código): recolorea según la luminancia. Mientras tanto: magenta.
	COLOR = vec4(1.0, 0.0, 1.0, original.a);
}
