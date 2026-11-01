# ref/ — fotos de cara de Valeria

Aquí van las fotos de referencia **en la instalación** (`/opt/data/guia-imagen/personajes/valeria/ref/` o tu computadora). **No se suben al repo** (`.gitignore` ignora las imágenes de esta carpeta).

## Qué fotos poner
| Archivo | Qué debe tener |
|---|---|
| `ref-1-*.png` | **Cara principal = panel 1 de toda foto** (4b). Frontal, bien iluminada, cabeza completa con pelo y hombros, mirando a la lente, sin lentes ni manos en la cara, fondo simple. PNG a tamaño completo |
| `ref-2…ref-6` | La misma cara en 3/4, perfil, otra luz (día o noche) y otra expresión (sonrisa) |
| `ref-7…ref-12` | Escenas cotidianas **con ropa** (café, carro, gym, calle) para variedad |
| Hoja de personaje / collage | Solo para comparar rasgos; **nunca** como entrada |

## Nombres que espera la ficha de Valeria
`ref-1-calle.png` (cara principal) · `ref-2-gym.png` · `ref-3-cafe.png` · `ref-4-hoja-personaje.png` y `ref-5-hoja-personaje-b.png` (solo comparar) · `ref-6-cafe-sueter.png` · `ref-7-gym-selfie.png` · `ref-8-cafe-lentes.png` · `ref-9-gym-iphone.png` · `ref-10-collage-10-selfies.png` (solo comparar) · `ref-11-carro.png` · `ref-12-cena-vino.png` (panel 1 para escenas de noche). Las fotos las tiene el dueño; este repo no las incluye.

## Reglas
- Personaje **ficticio y adulto** (creado con IA) o persona real **con consentimiento escrito**.
- Sin desnudos; evita fotos de cuerpo completo con pose sugerente (el modelo copia la pose y el filtro puede rechazarla).
- `REF_PRINCIPAL` en `personaje.env` debe apuntar a la cara principal. Si falta, `armar_hoja.py` sale con `ERROR SIN CARA` y no se genera.
