# ref/ — fotos de cara de Valeria

Aquí van las fotos de referencia **en la instalación** (`/opt/data/guia-imagen/personajes/valeria/ref/` o tu computadora). **No se suben al repo** (`.gitignore` ignora las imágenes de esta carpeta).

## Qué fotos poner
| Archivo | Qué debe tener |
|---|---|
| `ref-1-*.png` | **Base aprobada = img1** (4b). Frontal, bien iluminada, cabeza completa con pelo y hombros, mirando a la lente, sin lentes ni manos en la cara, fondo simple. PNG a tamaño completo |
| `ref-2…ref-6` | La misma cara en 3/4, perfil, otra luz (día o noche) y otra expresión (sonrisa) |
| `ref-7…ref-12` | Escenas cotidianas **con ropa** (café, carro, gym, calle) para variedad |
| Hoja de personaje / collage | Solo para comparar rasgos; **nunca** como entrada |

## Nombres que espera la ficha de Valeria
`ref-1-calle.png` (base aprobada, img1) · `ref-2-gym.png` · `ref-3-cafe.png` · `ref-4-hoja-personaje.png` y `ref-5-hoja-personaje-b.png` (solo comparar, nunca como entrada) · `ref-6-cafe-sueter.png` · `ref-7-gym-selfie.png` · `ref-8-cafe-lentes.png` · `ref-9-gym-iphone.png` · `ref-10-collage-10-selfies.png` (solo comparar, nunca como entrada) · `ref-11-carro.png` · `ref-12-cena-vino.png` (base para escenas de noche). Las fotos las tiene el dueño; este repo no las incluye.

## Reglas
- Personaje **ficticio y adulto** (creado con IA) o persona real **con consentimiento escrito**.
- Sin desnudos; evita fotos de cuerpo completo con pose sugerente (el modelo copia la pose y el filtro puede rechazarla).
- `REF_PRINCIPAL` en `personaje.env` debe apuntar a la base aprobada. Si falta y la llamada lleva imágenes, no se genera (`ERROR SIN CARA`).
