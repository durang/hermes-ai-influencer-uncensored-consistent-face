# 03 — Prompts (no explícitos)

**Política única de contenido:** en el servidor (Contabo / Cerebro Central) solo vestido, bikini, lencería y sensual **del personaje ficticio**. Desnudo y sexo van a Cloudflare R2 privado, que **todavía no existe**: mientras no exista, no se generan.

Las imágenes no se describen como paneles numerados. img1, img2 e img3 ya van en la llamada. El prompt dice qué conservar y qué cambiar.

## Sin imágenes (`/generate`)
```
Exactly 1 person. Single continuous photograph, one camera, one background. She is {escena}, wearing {ropa}. {luz}, unedited iPhone 12 photo, visible pores and freckles, sharp detail.
```

## Con imágenes (`/edit_multi`)
img1 es la base aprobada. Si hay segunda persona, es img2. Si hay prenda o estilo, es img3.
```
Exactly 1 person. Single continuous photograph, one camera, one background. Keep the face from the approved base exactly the same, wearing the garment from the third image. {escena}. {luz}, unedited iPhone 12 photo, visible pores and freckles, sharp detail.
```
Dos personas:
```
Exactly 2 people, each appears only once. Single continuous photograph, one camera, one background. The approved character keeps the face from the first image. The second person keeps the face from the second image. {posición}. {luz}, realistic skin, sharp detail.
```

## Errores típicos de prompt
| Mal | Bien |
|---|---|
| "taking a selfie holding a phone" | "iPhone 12 front-camera photo" |
| "make her prettier / younger" | "keep her face exactly the same" |
| ropa genérica para 2 personas | la ropa de cada persona, dicha en el prompt |
| "panel 1", "panel 2", números de una hoja | no hace falta: el puesto ya es img1, img2 o img3 |

## Cierre
`Single continuous photograph, one camera, one background, exactly N people. No diptych, no split screen, no collage, no text.`

## Por qué funcionan
- "Keep her face exactly the same" va **primero**: el modelo prioriza el inicio.
- No nombrar el teléfono: si lo nombras, lo dibuja (E8).
- Describir luz natural + "unedited iPhone" reduce la piel plástica.
- Una sola foto continua evita el díptico. La luz se cambia en el prompt, no con un retoque.
