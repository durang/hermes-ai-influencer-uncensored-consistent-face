# 03 — Prompts (no explícitos)

**Política única de contenido:** en el servidor (Contabo / Cerebro Central) solo vestido, bikini, lencería y sensual **del personaje ficticio**. Desnudo y sexo van a Cloudflare R2 privado, que **todavía no existe**: mientras no exista, no se generan.

## Técnica por defecto: Qwen-Image 2.1 Studio (prompt simple)
Referencia: `ref-1-calle.png`, modo `Edit an image`, 40 steps, `Portrait · 3:4`, seed 42.
```
Keep her face exactly the same. She is {escena}, wearing {ropa}. {luz}, unedited iPhone 12 photo, visible pores and freckles, sharp detail.
```
**Carro (ganadora 31-oct)**
> Keep her face exactly the same. She is sitting in the driver's seat of a parked car taking a casual front-camera selfie, wearing a cream knit sweater, seatbelt on. Soft natural daylight through the windshield, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

## Más ejemplos A0 (misma plantilla Qwen)
**Café**
> Keep her face exactly the same. She is sitting in a cozy coffee shop with a latte on the wooden table, wearing a beige knit sweater. Natural window light, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

**Gym (ropa deportiva normal)**
> Keep her face exactly the same. She is in a bright gym with dumbbell racks behind her, wearing a black zip-up training jacket and leggings, hair tied loosely. Natural overhead light, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

**Calle**
> Keep her face exactly the same. She is on a city sidewalk with shop windows behind her, wearing a green trench coat and a scarf. Natural afternoon light, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

**Cena**
> Keep her face exactly the same. She is seated at a restaurant table with candles, wearing an elegant long-sleeve black dress. Warm ambient light, unedited iPhone 12 photo, visible pores and freckles, sharp detail.

## Errores típicos de prompt
| Mal | Bien |
|---|---|
| "taking a selfie holding a phone" | "iPhone 12 front-camera photo" |
| "make her prettier / younger" | "keep her face exactly the same" |
| ropa genérica para 2 personas | la ropa de cada persona, por panel |

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
