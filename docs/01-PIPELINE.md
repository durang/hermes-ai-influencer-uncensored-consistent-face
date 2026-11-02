# 01 — Pipeline (v5.3): llamada directa al Space

Hermes llama al Space `iccanobif/qwen21-nano-banana`. No manda referencias numeradas por Telegram, ni una por una ni en una hoja. El modelo no recibe hojas ni collages.

Regla: **no se avanza si la compuerta no da ✅.** El juez de visión corre antes de entregar. Reintentos internos con otra semilla, **máximo 5**. El cliente solo recibe la foto final.

---
## Paso 1 — Entender la petición
- Lee la petición y extrae: escena, ropa, si hay segunda persona, cuántas fotos pide.
- Clasifica: `sin-imagen` | `una-base` | `pareja` | `prenda-o-estilo` | `fuera-de-alcance`.

**Compuerta 1:** ✅ escena y ropa definidas, o una pregunta al dueño. ❌ Falta un dato → pregunta una vez.

## Paso 2 — Elegir el endpoint
| Caso | Endpoint | Imágenes, en una sola llamada |
|---|---|---|
| No hay imágenes | `/generate` | ninguna |
| Hay 1 a 3 imágenes | `/edit_multi` | img1 = base aprobada; img2 = una foto de la 2.ª persona, o vacía; img3 = prenda o estilo, o vacía |

El único modelo es ese Space (regla 4g). Usa /generate cuando no hay imágenes. La vía sigue siendo `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`).

**Prohibido:** hojas numeradas, fotos numeradas una por una, `dynamic_space`, el navegador, scripts por terminal y cualquier otro modelo.
**Compuerta 2:** ✅ endpoint e imágenes anotados. Máximo 3 imágenes.

## Paso 3 — Juntar las imágenes
- img1, si hace falta, es la base aprobada de `personajes/<nombre>/ref/` (`REF_PRINCIPAL`). Nunca una prenda.
- img2 es una sola foto de la segunda persona. Si no hay segunda persona, no se manda.
- img3 es la prenda o el estilo. Si no hay, no se manda.
- Sin cara guardada y con imágenes pedidas: no se genera. Pide la base primero.
- Sin ninguna imagen: el paso 5 usa `/generate`.

**Compuerta 3:** ✅ las rutas existen, o no hay imágenes y el endpoint es `/generate`.

## Paso 4 — Armar el prompt
- Plantilla en `03-PROMPTS.md`. Una sola foto continua: «single continuous photograph, one camera, one background, exactly N people».
- 40 pasos, true_cfg 4. La luz y la integración las hace el modelo con el prompt. No se pegan caras ni se retoca por código.
- No nombres paneles ni números: las imágenes ya van en su puesto.

**Compuerta 4:** ✅ prompt listo.

## Paso 4b — Confirmar con el dueño
`imagen_kontext` no genera y no adjunta una hoja. El mensaje dice el endpoint y qué archivo va en img1, img2 e img3. **Sin una confirmación válida (4h) no se genera.**
**Compuerta 4b:** ✅ el dueño confirmó. ❌ pidió un cambio → vuelve al paso 3 o 4.

## Paso 5 — Una sola llamada
`imagen_confirmar(id, prompt)` llama al Space:
- 1 a 3 imágenes → `/edit_multi` una vez, con las tres ranuras en esa llamada (las que falten van vacías).
- 0 imágenes → `/generate`.

**Compuerta 5:** ✅ el Space devolvió un archivo. ❌ error exacto al registro; no se cambia de modelo.

## Paso 6 — Juez de visión, antes de entregar
Hermes mira la salida antes de enviar (C14, E30): relleno plano, proporción distinta de 3:4, costuras rectas, la misma identidad repetida, o un número de personas distinto de N. Si no pasa, reintenta **dentro**, con otra semilla, hasta 5 veces en total. Esas pruebas no se mandan.

**Compuerta 6:** ✅ una salida pasó y, solo entonces, se puede decir «caras OK». ❌ las 5 fallaron → no se manda foto. Al cliente: «No salió bien la foto. No te mando una a medias.» El motivo queda en el registro.

## Paso 7 — Entregar solo la foto final
- El cliente ve únicamente la foto que pasó el juez.
- No se reenvían URLs temporales. `imagen_enviar` solo reenvía lo que ya produjo `imagen_confirmar`.
- Hermes no repite el mensaje del plugin (4m).

**Compuerta 7:** ✅ el cliente tiene la foto final, o el mensaje neutral si ninguna pasó.

## Paso 8 — Registrar
- Una línea en `05-REGISTRO.md`: endpoint, imágenes usadas, semillas de los intentos internos, si pasó el juez.

**Compuerta 8:** ✅ línea escrita.

---
## Ejemplo
1. Petición: Valeria con la camisa que mandó el dueño, en un café.
2. Hay imágenes → `/edit_multi`. img1 = base aprobada de Valeria. img2 vacía. img3 = la camisa.
3. `imagen_kontext` confirma en texto y espera el OK.
4. `imagen_confirmar` hace una sola llamada. El juez descarta la primera semilla y acepta la segunda.
5. El cliente recibe solo esa segunda foto.

## Checklist
- [ ] Endpoint correcto (`/generate` solo si no hay imágenes)
- [ ] Como mucho 3 imágenes, en una sola llamada, en el orden img1 / img2 / img3
- [ ] Nada de hoja ni de fotos numeradas una por una
- [ ] Confirmación válida del dueño
- [ ] Juez de visión, máximo 5 semillas
- [ ] El cliente solo vio la foto final
- [ ] Quedó registrado

## Solución de problemas
| Síntoma | Causa probable | Haz |
|---|---|---|
| `ERROR SIN CARA` | falta la base aprobada | pedir la foto de cara; no generar |
| Cuota ZeroGPU | la cuenta que llama agotó su cuota | mostrar el error exacto y esperar el reinicio; no cambiar de Space (4g) |
| Space caído | error del Space | mostrar el error exacto; no ofrecer otro modelo |
| Salen dos escenas o números | el prompt no pidió una sola foto | otra semilla, con la frase de una sola foto continua |
