# 02 — Técnicas (v5.3)

El modelo es solo el Space `iccanobif/qwen21-nano-banana`. Las imágenes no se numeran ni se pegan en una hoja: entran sueltas, en una sola llamada.

## Sin imágenes — `/generate`
- **Cuándo:** el dueño no manda fotos y basta la base que el prompt describe, o se pide una escena solo con texto.
- **Llamada:** `/generate`. Nada en img1, img2 ni img3.
- **Parámetros:** 40 pasos, true_cfg 4, semilla fija para comparar y otra en cada reintento.

## Con 1 a 3 imágenes — `/edit_multi`
Una sola llamada. Orden fijo:

| Puesto | Qué es | Vacío cuando |
|---|---|---|
| img1 | Base aprobada del personaje | Nunca, si hay imágenes. No es una prenda |
| img2 | Una foto de la segunda persona | No hay segunda persona |
| img3 | Prenda o estilo | No hay prenda ni estilo que copiar |

- **Pareja:** img1 = personaje aprobado, img2 = esa única foto de la otra persona, img3 = prenda o estilo si hace falta. Pasos A/B/C siguen siendo un cambio por paso, cada uno con su llamada.
- **Solo ropa o estilo:** img1 = base aprobada, img3 = la prenda o el estilo. img2 vacía.
- **Una sola foto de la cara del personaje:** va en img1. No se manda tal cual al cliente; el Space genera a partir de ella.

## Pose nueva
- Misma llamada, un solo cambio de pose en el prompt («turns her head slightly», «sitting at a table»).
- Si la cara se pierde, se reintenta con otra semilla (máximo 3) sin describir otra persona.

## LoRA de Valeria (futuro)
- Un modelo entrenado con 15–30 fotos, cuando exista. Hoy no se usa. La producción sigue siendo este Space.

## No usar
- Otro modelo o otro Space (regla 4g).
- Hoja numerada, collage, o fotos enviadas una por una y numeradas, como entrada del modelo.
- `dynamic_space`, el navegador y scripts por terminal para generar. `tools/qwen21_generar.py` es solo calibración en el host.

## Árbol
- SI no hay imágenes → `/generate`.
- SI hay de 1 a 3 imágenes → `/edit_multi` una vez, en el orden de arriba.
- SI faltaría una cuarta imagen → no se mete. Se dice cuál sobra y por qué.
- SI el juez falla → otra semilla, máximo 3. El cliente no ve las que fallan.
