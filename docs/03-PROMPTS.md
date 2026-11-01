# 03 — Prompts (solo SFW, con ropa)

## Técnica por defecto: Qwen-Image 2.1 Studio (prompt simple)
Referencia: `ref-1-calle.png`, modo `Edit an image`, 40 steps, `Portrait · 3:4`, seed 42.
```
Keep her face exactly the same. She is {escena}, wearing {ropa}. {luz}, unedited iPhone 12 photo, visible pores and freckles, sharp detail.
```
**Carro (ganadora 31-oct)**
> Keep her face exactly the same. She is sitting in the driver's seat of a parked car taking a casual front-camera selfie, wearing a cream knit sweater, seatbelt on. Soft natural daylight through the windshield, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

## Plantilla Kontext (5 bloques)
```
[IDENTIDAD] Change only the background and clothing, keep her face, expression, hazel eyes, freckles, lips and copper curly hair exactly identical, same camera angle and framing.
[ROPA]      She now wears {ropa}.
[ESCENA]    {escena}.
[CÁMARA]    iPhone 12 front-camera photo, she looks straight into the lens.
[LUZ]       Natural {luz} light, slight grain, realistic skin texture.
```
Reglas: no mencionar el teléfono; un cambio a la vez; guidance ≤ 3.

## Ejemplos
**Café**
> Change only the background and clothing, keep her face, expression, hazel eyes, freckles, lips and copper curly hair exactly identical, same camera angle and framing. She now wears a beige knit sweater. She is sitting in a cozy coffee shop with a latte on the wooden table. iPhone 12 front-camera photo, she looks straight into the lens. Natural window light, slight grain, realistic skin texture.

**Carro**
> …(identidad)… She now wears a denim jacket over a white t-shirt. She is in the driver's seat of a parked car, seatbelt on, trees visible through the window. iPhone 12 front-camera photo, she looks straight into the lens. Natural daylight, slight grain, realistic skin texture.

**Gym (ropa deportiva normal)**
> …(identidad)… She now wears a black zip-up training jacket and leggings, hair tied loosely. She is in a bright gym with dumbbells racks behind her. iPhone 12 front-camera photo, she looks straight into the lens. Natural overhead gym light, slight grain, realistic skin texture.

**Calle**
> …(identidad)… She now wears a green trench coat and a scarf. She is on a city sidewalk with shop windows behind her. iPhone 12 front-camera photo, she looks straight into the lens. Natural afternoon light, slight grain, realistic skin texture.

**Cena**
> …(identidad)… She now wears an elegant long-sleeve black dress. She is seated at a restaurant table with candles and a plate of pasta. iPhone 12 front-camera photo, she looks straight into the lens. Warm ambient restaurant light, slight grain, realistic skin texture.

## Errores típicos de prompt
| Mal | Bien |
|---|---|
| "taking a selfie holding a phone" | "iPhone 12 front-camera photo" |
| "change the scene" | "change only the background and clothing" |
| guidance 4+ | guidance 2.5 |

## Ejemplo C2 – hoja de referencias numerada (ganador: seed 42 / 123)
> Create a new single photo: the woman from panel 1, keep her face and makeup exactly the same, wearing the black dress from panel 2, standing in front of the cathedral in panel 3 at golden hour. Casual front-camera iPhone 12 selfie, natural light, realistic skin, sharp detail. No panels, no numbers, no text.

Siempre cerrar con "no panels, no numbers, no text". Si el fondo del panel 1 se cuela, decir "use panel 1 for identity only" y recortar más.

## Bloques para copiar
**Cierre C2 (siempre):** `Use panel 1 for identity only. No panels, no numbers, no text.`
**Dos personas (C2, paneles iguales):**
> Create a new single photo: the man from panel 1 and the woman from panel 2, both keep their faces exactly the same, sitting together at the cocktail bar from panel 3, smart casual clothes, smiling at the camera. Casual iPhone 12 photo, warm natural bar light, realistic skin, sharp detail. No panels, no numbers, no text.
Resultado: `../pruebas-modelo/multi-ref/qwen-pareja-bar-s42.png`.

## Por qué funcionan
- "Keep her face exactly the same" va **primero**: el modelo prioriza el inicio.
- No nombrar el teléfono: si lo nombras, lo dibuja (E8).
- Describir luz natural + "unedited iPhone" reduce la piel plástica.
