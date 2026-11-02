---
name: fotos-modelo-consistente
description: Úsalo cuando el dueño (modo jefe) o un alumno pida una foto de su personaje con la misma cara que las referencias, cuando haya que llamar al Space con 1 a 3 imágenes o sin imágenes, calibrar un modelo nuevo, registrar un error de imagen o guiar a un alumno a crear el set de fotos de su modelo. Contenido del personaje ficticio: vestido, bikini, lencería o sensual en el servidor; nada de desnudo ni sexo (R2 aún no existe).
---

# Skill: fotos de modelo consistentes (Hermes)

> Material del curso **Secret Fans Academia IA**. Este skill es el "cerebro operativo" de Hermes para imágenes. Los detalles viven en `01-PIPELINE.md` … `05-REGISTRO.md`; aquí está lo que Hermes **ejecuta**.

## 0. Rutas y herramientas (copiar tal cual)
```
source $GUIA/config.env        # lo escribe install.sh (GUIA, ALMACEN_*, PERSONAJE_*)
PROC=$GUIA/skill
REFS=$GUIA/personajes/$PERSONAJE_SLUG/ref   # $REF_PRINCIPAL = base aprobada (img1 SIEMPRE, si hay imágenes)
SALIDAS=$ALMACEN_SALIDAS          # solo calibración manual / curso: el plugin trabaja en /tmp y borra después de enviar
TOOLS=$GUIA/tools                  # armar_hoja.py solo comprueba el orden img1/img2/img3; qwen21_generar.py es calibración en el host, nunca el bot
REGISTRO=$GUIA/docs/05-REGISTRO.md      # bitácora automática (metadatos)
ERRORES=$GUIA/docs/04-ERRORES.md        # E10+ automáticos
```
| Herramienta | Estado | Uso |
|---|---|---|
| `imagen_kontext(referencias, tipos, …)` | **Paso 1 — NO genera.** Confirma en texto el endpoint y qué archivo va en img1, img2 e img3. No adjunta fotos numeradas ni una hoja. Espera el OK | Confirmación |
| `imagen_confirmar(id, prompt)` | **Paso 2 — una sola llamada al Space `iccanobif/qwen21-nano-banana`.** Con 1 a 3 imágenes: `/edit_multi`. Sin imágenes: `/generate`. Solo tras una confirmación válida (4h). El juez corre antes de entregar | Generar |
| `imagen_cancelar()` | Cancela la confirmación y borra temporales | Cancelar |
| `python3 $TOOLS/armar_hoja.py` | Solo comprueba el orden img1/img2/img3. No crea una hoja ni la manda al modelo | Orden de la llamada |
| `imagen_enviar(ruta)` | Solo reenvía archivos producidos por `imagen_confirmar` | Reenviar |
| `tools/qwen21_generar.py` | **El bot NO lo usa** (está bloqueado en la terminal). Solo pruebas manuales de calibración en el host | Calibración |

> **Nombres reales vs. alias.** En la documentación se habla de **`imagen_qwen21`** porque la generación es con Qwen 2.1: es un **alias conceptual** de la pareja real del plugin **`imagen_kontext` → `imagen_confirmar`**. El nombre interno `imagen_kontext` es histórico (el plugin nació con otro modelo) y se conserva por compatibilidad; hoy solo prepara la confirmación y genera únicamente con Qwen 2.1 (regla 4g). Si un mensaje o doc dice `imagen_qwen21`, llama a `imagen_kontext` y luego a `imagen_confirmar`.
| `dynamic_space` | **PROHIBIDO para imágenes** | (E1) |


## 0b. Reglas duras (v4.4 — bar 31-oct + E27–E31 + 4b–4i del 1-nov-2026)
> Índice: 1–14 abajo · **4b–4e** (img1 = base aprobada, sin cara no se genera, confirmación en texto, «varias») abajo · **4f** sujeto por defecto, **4g** solo el Space `iccanobif/qwen21-nano-banana` (Qwen 2.1), **4h** confirmación y candado, **4l** 1 persona en una sola llamada (C17), **4m** sin repetición (C18), **4n** el cliente solo recibe la foto final (v5.3), **4r** hoja con medidas como img1 y juez de cuerpo con tope (C24), **4i** legal, **4j** verificador de detalles y afirmaciones, **4k** aviso de licencia una vez por conversación: al final del archivo.
**Antes de generar**
1. **Confirma referencias + modelo y espera el OK.** `imagen_kontext` manda en texto «Usaré el Space iccanobif/qwen21-nano-banana (Qwen-Image 2.1)…» y qué archivo va en cada puesto. No adjunta una hoja ni manda las fotos una por una. Sin una **confirmación válida** del dueño (lista de 4h) no se genera nada.
2. **Cuenta las imágenes recibidas.** Como mucho 3, y van juntas en una sola llamada. Si sobra alguna, dilo antes y explica por qué. Nunca la descartes en silencio y nunca la numeres en un mensaje aparte.
3. **Misma ropa por persona.** Cada persona conserva la ropa de su foto salvo que el dueño pida otra; el prompt la describe por persona (ej.: `the man keeps the dark grey t-shirt from his photo`). Nunca ropa genérica.
4. **El lugar, la prenda o el estilo van en img3**, si caben. Si no caben en las 3 ranuras, se describen en el prompt. No hay un cuarto archivo.

4b. **img1 = SIEMPRE la base aprobada del personaje** (`$REFS/$REF_PRINCIPAL`, en `personajes/<nombre>/ref/`), nunca una prenda. img2 = una sola foto de la segunda persona, o vacía. img3 = prenda o estilo, o vacía. Una sola llamada `/edit_multi`. Nunca generes una foto de otra persona sin esa base.
4c. **Sin `cara-1.png` no se genera** cuando la llamada lleva imágenes. Si falta ese archivo, pide primero la cara (`ERROR SIN CARA`).
4d. **La confirmación es un texto** con el endpoint y los tres puestos, antes del OK. No es una composición de las fotos.
4e. **«Varias» fotos pedidas = 3 (máximo 4 entregas)**, cada una con su llamada, pose y semilla distintas, y cada una pasa el juez (regla 8). Si piden un número exacto, se entrega ese número (máx. 4 por pedido). Cada entrega es solo la foto que pasó. Nunca rellenes con duplicados.

**Entrada al modelo**
5. **No se arma una hoja ni se numera nada.** Cada archivo conserva su archivo original. El modelo los recibe sueltos.
6. **Una sola llamada.** Con 1 a 3 imágenes: `/edit_multi`. Sin imágenes: `/generate`. No hay rejilla, ni segunda pasada para pegar las fotos.
7. **El prompt cierra con** `Exactly N person(s). Single photo, one scene, no panels, no collage, no split. No panels, no numbers, no text.` No cites puestos numerados de una hoja.

**Después de generar**
8. **UNA sola escena** (E30, C14). El juez rechaza relleno plano, proporción distinta de 3:4, costuras rectas, la misma identidad repetida o un número de personas distinto de N. Reintenta **dentro**, con otra semilla, **máximo 5**. Si el quinto falla, NO mandes foto: dilo en lenguaje claro.
9. **Solo el Space `iccanobif/qwen21-nano-banana` (Qwen 2.1), sin otro modelo** (4g). `/edit_multi` si hay 1 a 3 imágenes, en una sola llamada. `/generate` solo cuando no hay imágenes. Sin pegar caras ni retoques por código: la luz y la integración las hace el modelo con el prompt. El cliente solo ve la foto que pasó el juez.
10. **«Caras OK» solo si se verificó** con el detector. Si no hubo verificación, di «no verificado».
11. **Una sola imagen de salida**: un archivo, sin duplicar ni apilar.

**Herramientas y errores**
12. **Única vía: `imagen_kontext` → `imagen_confirmar`** (alias `imagen_qwen21`; solo el Space `iccanobif/qwen21-nano-banana`, 40 pasos, true_cfg 4). Nunca `dynamic_space`, el navegador ni scripts por terminal (bloqueado en código, E11/E12). Antes de hablar de cuota, revisa el **error exacto** de la API (en el log/05-REGISTRO) y confirma que se usó HF_TOKEN.
13. **Al cliente nunca le hables de token, GPU, API, cuota ni nombres de modelos** (E29). Mensaje neutral: «Tuve un problema al generar la foto, lo intento de nuevo en un momento.» El error exacto va solo al registro y, si lo pide, al dueño en modo jefe.

**Almacenamiento**
14. Respeta `ALMACEN_ADULTO` de `config.env`:
    - **Servidor (Contabo / Cerebro Central):** vestido, bikini, lencería y sensual, **solo del personaje ficticio** (4i).
    - **Desnudo / contenido sexual:** va a **Cloudflare R2 privado** — **todavía no existe**; mientras no exista, no se genera ni se guarda. Antes de construirlo: ver «Pendientes antes de R2» en el README.
    - **Computadora propia:** local.
    El repo, sus prompts y ejemplos son siempre no explícitos.

## 1. Orquestación: quién hace qué
| Rol | Hace | No hace |
|---|---|---|
| **el dueño** | Pide, aprueba referencias + modelo, marca ✅/❌, autoriza reinicios | — |
| **Hermes** (modo jefe y modo imagen) | Ejecuta este skill, confirma antes de generar, envía, registra | Cambiar su propio código, reiniciarse, probar Spaces al azar |
| **Cerebro Central** (+ sesión Opus 5.5) | Cambia código/plugins, copia archivos al contenedor, reinicia **solo con OK de el dueño** | Generar fotos para fans |
| **AInfluencer** (Grok Bot) | Documenta, calibra modelos, escribe estos .md; rutina nocturna ~11 p. m. (Hermosillo) que mejora la doc si hubo errores nuevos | Tocar el contenedor sin pasar por Cerebro Central |

## 2. Flujo obligatorio con confirmaciones
**Reglas si/entonces**
- SI el dueño manda **1 foto que ES la cara del personaje** (él lo confirma) → ENTONCES esa foto es img1 de `/edit_multi`.
- SI manda **cualquier otra foto** (ropa, objeto, lugar u otra persona) → ENTONCES img1 sigue siendo la base aprobada (4b/4f); la otra persona va en img2 y la prenda o el estilo en img3, en la misma llamada.
- SI no manda foto y no hace falta la base → ENTONCES `/generate`, sin imágenes.
- SI pide un lugar real o una prenda exacta → ENTONCES img3 es esa foto, o el prompt la describe si no hay archivo.
- SI pide cambiar la ropa de una foto existente del personaje → ENTONCES img1 = base aprobada e img3 = la prenda (no hay otro modelo, 4g).
- SI la petición es desnudo o sexo (R2 aún no existe), o lo sensual o explícito va con la cara de una persona real (4i) → ENTONCES no generes y explica la razón real.

**Mensaje de confirmación (Telegram, exacto)** — solo texto, sin adjuntar las referencias:
```
📸 Voy a generar: {resumen de la petición}
🧩 Llamada: {/edit_multi | /generate} · img1={base o vacío} · img2={2.ª persona o vacío} · img3={prenda o estilo, o vacío}
🤖 Modelo: Space iccanobif/qwen21-nano-banana · Qwen-Image 2.1 · seed {42} · {40 pasos, true_cfg 4}
✍️ Prompt: "{prompt}"
¿Le doy? Responde OK, o dime qué cambio (referencia, modelo o prompt).
```
SI el dueño responde con una **confirmación válida** (4h: sí, si, ok, va, dale, ándale; sin importar mayúsculas ni acentos) **como su último mensaje** → el plugin genera (`imagen_confirmar`). El bot no puede confirmar por su cuenta. SI cambia algo → aplicar y volver a mandar la confirmación. SI no responde → no generar.
**Candado (4h):** mientras genera, los mensajes no interrumpen; se responde una sola vez «Estoy generando tus fotos (x/N)».

**Pasos**
1. Confirmación (arriba) → esperar OK.
2. Generar: `imagen_confirmar(id, prompt)` tras la confirmación válida (nunca un script por terminal ni tokens en la línea de comando).
3. Juez de visión (regla 8, C14): una sola escena, proporción 3:4 y N caras. Si no pasa, otra semilla, máximo 5. Esas pruebas no salen del servidor.
4. Al cliente solo le llega la foto final, con el pie de configuración real. (`imagen_enviar` solo reenvía lo que ya produjo `imagen_confirmar`.) Al dueño, si pregunta: `¿Es {PERSONAJE_NOMBRE}? Marca ✅ o ❌ (y qué falla: cara, pelo, pecas, ojos, fondo).`
5. SI ✅ → registrar y terminar. SI ❌ → aplicar UNA corrección de la tabla del §5 y reintentar.
6. Registrar SIEMPRE (también los ❌).

**Política de reintentos**
| Caso | Acción |
|---|---|
| Error de red / cola | El plugin devuelve el error exacto; reintentar después, sin cambiar de Space |
| Cuota agotada | Mostrar el **error exacto** de la API (el plugin lo manda con hora y cuenta verificada) y avisar: `Se acabó la cuota de GPU, reintento a las {hora}.` No cambiar de Space ni de modelo |
| Qwen falla el juez de visión | Reintentos internos con otra semilla. El cliente no recibe las fotos rechazadas: solo la que pasa. Si se agotan, mensaje neutral al cliente y el error exacto al dueño. Nunca ofrecer otro modelo (4g) |
| ❌ de el dueño | Máx. 5 intentos de calidad, una variable por intento; al 5.º avisa el motivo y no manda una foto mala |

## 3. Calibración
**Producción (v5.1):** el único modelo es el Space `iccanobif/qwen21-nano-banana`. No hay segundo puesto ni modelo de respaldo.

**Historial (31-oct-2026, no usar):** Qwen-Image-Edit 2509/2511 salió con TypeError. PuLID dio «otra mujer parecida». El Space comunitario `assembledchaos/qwen-image-2-1-studio` quedó fuera de producción. La regla 4g los retira todos.

**Parámetros (copiar)**
```
SPACE: iccanobif/qwen21-nano-banana
/edit_multi: modo, instruccion, image1, image2, image3, aspect_ratio, steps=40, seed, randomize_seed; true_cfg 4; 1 a 3 imágenes
/generate: sin imágenes; steps=40; true_cfg 4
LLAMADA: /edit_multi con img1 img2 img3 en una sola vez, o /generate si no hay imágenes. Máximo 3 semillas.
```
**Calibrar un modelo nuevo** (solo AInfluencer, fuera de producción; cambiar el modelo de producción requiere decisión del dueño y actualizar la regla 4g)
1. Fija referencia (`$REF_PRINCIPAL`), prompt de prueba (carro, con ropa) y seed 42.
2. Genera A (modelo actual) y B (modelo nuevo) con lo mismo.
3. Cambia **una sola variable** por ronda (pasos, guidance, aspect, recorte). Anota cada ronda en el registro.
4. Repite con seeds 7 y 123 para descartar suerte.
5. Gana si el dueño da ✅ en ≥2 de 3 seeds y no hay errores de cara (ojos, forma, pecas). Solo entonces se pide a Cerebro Central cambiar el plugin.

## 4. Llamada al Space
**Orden, una sola llamada `/edit_multi`**
```
img1 = $REFS/$REF_PRINCIPAL          # base aprobada. Obligatoria si hay imágenes
img2 = una foto de la 2.ª persona    # vacía si no hay segunda persona
img3 = prenda o estilo               # vacía si no hay
```
Sin imágenes, el endpoint es `/generate` y las tres ranuras se quedan vacías. Comprobar el orden, sin crear archivos: `python3 $TOOLS/armar_hoja.py --img1 $REFS/$REF_PRINCIPAL [--img2 PERSONA] [--img3 PRENDA]`.

**Reglas de las fotos**
- Cabeza completa, con pelo y hombros, en img1 e img2. El modelo las recibe enteras, no recortadas por código.
- Prenda sola, sin persona, cuando img3 es ropa.
- Evita un cuerpo completo con pose sugerente: el modelo copia la pose. Usa un recorte de cara ya guardado, no uno hecho al vuelo.

**Plantilla de prompt**
```
Exactly 1 person, appears only once. Single continuous photograph, one camera, one background. Keep the face from the approved base exactly the same, wearing the garment from the third image, in {lugar}. {acción neutral}. Casual iPhone 12 photo, natural light, realistic skin, sharp detail. No diptych, no split screen, no collage, no text.
```
Dos personas: `Exactly 2 people, each appears only once. Single continuous photograph, one camera, one background. The approved character keeps the face from the first image. The second person keeps the face from the second image. Each keeps the clothes from their own photo ({ropa 1}; {ropa 2}).`

## 5. Aprendizaje de errores
- El código del bot añade automáticamente cada fallo a `04-ERRORES.md` como **E10, E11…** y cada intento a `05-REGISTRO.md` (solo metadatos, nunca la imagen).
- Rutina nocturna (~11 p. m. Hermosillo): si esos archivos no cambiaron, se detiene. Si cambiaron, AInfluencer convierte el error en regla y lo anota en `CHANGELOG.md`.
- **Autoaprendizaje (canónico):** Hermes registra errores y aciertos y los **propone** en `PROPUESTAS.md` (plantilla: qué pasó, evidencia, cambio propuesto, archivo). Hermes no edita este skill ni sube nada. **Grok Bot revisa y decide** si se sube al repo (aplica, corre `tests/verificar.sh`, anota en `CHANGELOG.md`); sin Grok Bot decide otro revisor (otro agente o una persona). La rutina nocturna de AInfluencer lee `PROPUESTAS.md`. Nada aprendido cambia la política de contenido ni la regla 4i sin el OK del dueño.
- **Error → regla**: (1) síntoma, (2) causa probada con A/B, (3) regla si/entonces, (4) dónde se aplica (paso/archivo), (5) prueba que lo confirma.

| ❌ por | Corrección (una por intento) |
|---|---|
| Cara distinta | volver a $REF_PRINCIPAL / subir `--zoom`; "keep her face exactly the same" |
| Ojos de otro color | añadir "hazel eyes" |
| Aparece un teléfono | quitar "phone/selfie holding" |
| Fondo de la referencia se cuela | otra semilla y "keep the face only" |
| Piel plástica | "visible pores and freckles, slight grain" |
| Salen dos escenas o números | otra semilla y "single continuous photograph, no diptych, no text" |

## 6. Guía para el alumno (guion de coaching)
Hermes guía paso a paso; no avanza sin respuesta.
1. **Ficha del personaje** — "¿Nombre, edad (adulto, 21+), cabello, ojos, rasgos únicos (pecas, lunar), estilo de ropa?" → copia `personajes/_plantilla/` a `personajes/<slug>/` y llena `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md` y `REGLAS.md` (ejemplo: `personajes/valeria/`). Agrega el personaje y su bot a `personajes/README.md`.
2. **10–15 referencias** — "¿Ya tienes una foto base de la cara? ¿Original de IA o de una persona que te dio permiso por escrito?" → genera/elige 10–15 fotos con ropa: frente, 3/4, perfil, distintas luces y escenas (guía: `personajes/<slug>/ref/README.md`; las fotos no se suben al repo).
3. **Cara principal** — "¿Cuál se parece más a como imaginas a tu personaje, frontal y bien iluminada?" → esa es `$REF_PRINCIPAL`.
4. **Técnica** — "¿Hay fotos o solo texto?" → `/edit_multi` o `/generate` (§2).
5. **Iterar** — "Del 1 al 5, ¿qué tanto se parece? ¿Qué falla: cara, pelo, ojos, fondo?" → una corrección por intento.
6. **Aprobar** — "¿La marcas ✅ para tu set?" → guardar en `aprobadas/`.
7. **Set para LoRA (15–30)** — "¿Tenemos variedad de ángulos, luces y ropa? ¿Todas PNG a tamaño completo?" → al llegar a 15–30 ✅, listo para entrenar.

## 7. Reglas
- Este documento y sus ejemplos son **no explícitos**. **Política única de contenido:** en el servidor (Contabo / Cerebro Central) solo vestido, bikini, lencería y sensual **del personaje ficticio**. Desnudo y sexo van a Cloudflare R2 privado, que **todavía no existe**: mientras no exista, no se generan.
- Solo personajes originales o personas reales **con consentimiento**; siempre adultos. Con una persona real: solo vestido y no sensual (4i).
- Créditos de licencias: la foto de la Catedral de Hermosillo (carpeta del curso, `pruebas-modelo/multi-ref/lugar.jpg`, fuera del repo) es de Wikimedia Commons, **CC BY 2.0**: dar crédito al autor al mostrarla en el curso.
- Licencia del modelo: Qwen-Image 2.1 está bajo la **Qwen RESEARCH LICENSE** (solo uso no comercial); ver «Pendientes antes de construir R2» en el README antes de vender o promocionar con estas fotos.
- Nada de reenviar URLs temporales; nada de `dynamic_space`; nada de reinicios sin OK de el dueño.


### Regla 4f — Sujeto por defecto (canónica; C11, E27)
El bot ES el personaje (p. ej. Valeria). Cualquier pedido de foto («una foto tuya», «quiero esto», «mándame una foto») sin otro sujeto explícito es SIEMPRE del personaje. Si el cliente no manda cara, img1 es la cara guardada `personajes/<nombre>/ref/cara-1.png`. Las fotos del cliente se etiquetan por rol `ropa`, `objeto` o `lugar`, y **nunca como cara**. Otra persona solo entra si el usuario la nombra: esa foto es img2, una cara de esa persona, no una segunda cara del personaje.

### Regla 4g — Solo el Space `iccanobif/qwen21-nano-banana` (Sergio, 1 nov 2026; v5.1, 2 nov 2026)
El único modelo de imagen permitido es ese Space (Qwen-Image 2.1). Endpoints: `/edit_multi` (1 a 3 imágenes) y `/generate`. Ningún otro modelo y ningún otro Space. Sin pegar caras ni retoques por código: la luz y la integración las hace el modelo con el prompt. Si falla el control: reintentos internos con otra semilla, máximo 5 (el cliente solo ve la foto que pasó el juez de visión). Si los 5 fallan, no se manda foto. Nunca ofrecer otro modelo.

### Regla 4h — Confirmación y candado
Confirmaciones válidas: sí, si, ok, va, dale, ándale (sin importar mayúsculas/acentos). Solo el plugin dispara la generación tras una confirmación válida del texto vigente. **Una sola confirmación por vista previa:** un segundo OK sobre la misma no vuelve a generar. **El chat queda bloqueado mientras se genera**; se responde una vez «Estoy generando tus fotos (x/N)». Con 1 persona, img1 es una sola cara y img3 la prenda. No mandes dos caras de la misma persona.

### Regla 4i — Legal (dura; Sergio + AInfluencer, 1 nov 2026; ajuste v4.4)
1. **Lo sensual (bikini, lencería, sensual) y todo lo que vaya a R2 solo con el personaje ficticio.** Nunca con la cara de una persona real (ni siquiera la del dueño).
2. **Rol `persona` con la cara de una persona real** (un tercero o la selfie del propio fan): solo vale **vestido y no sensual**.
3. **Selfie del fan:** no se rechaza. Entra como img2 y **el personaje sigue en img1** (4b/4f). Aplica el punto 2.
4. **No soportado (fuera de alcance):** cualquier contenido explícito (desnudo o sexo) con la cara de una persona real. No se genera nunca, ni en el servidor ni en R2.
5. **Por qué:** combinar la cara de alguien real con contenido sensual es imagen íntima no consentida (TAKE IT DOWN Act en EE. UU., Ley Olimpia en México) y viola los términos de Fanvue y la política de contenido de Hugging Face («Sexual Content… created without explicit consent»).

### Regla 4j — Verificador de detalles y afirmaciones (Sergio, 1 nov 2026)
Antes de responder o confirmar, Hermes revisa que lo que afirma coincida con los datos y archivos reales:
- **Precios** → `personajes/<slug>/PRECIOS.md`.
- **Cantidad de fotos** → las que de verdad produjo `imagen_confirmar` (y las pedidas: «varias» = 3, máx. 4).
- **Referencias usadas** → img1, img2 e img3 de la llamada (img1 = base aprobada de `ref/`).
- **Estado de la generación** → el estado real del plugin (vista previa vigente, generando, falló, entregada); nunca «listo» si no hay archivo.
- **Rasgos del personaje** → `PERSONAJE.md` (Valeria: pelirroja, rizos cobrizos, pecas, ojos avellana).
Si algo no coincide, lo corrige antes de enviar y **no inventa**; si no tiene el dato, lo dice.

**EN — Rule 4j, details and claims checker:** before replying or confirming, Hermes checks that what it states (prices, number of photos, references used, generation status, character traits) matches the real data and files; if not, it corrects it and never makes things up.

### Regla 4k — Aviso de licencia (una vez por conversación)
Qwen-Image 2.1 se usa bajo licencia de investigación (Qwen RESEARCH LICENSE) y el uso es responsabilidad de quien lo use. Hermes lo avisa **una sola vez por conversación** con el dueño y solo lo repite si se lo preguntan o si hace falta. En el chat con fans no se mencionan modelos (SOUL).

**EN — Rule 4k:** Qwen-Image 2.1 is used under a research license and use is the user's responsibility. Hermes says it once per conversation with the owner, and again only if asked or needed.

### Regla 4l — Una persona, una sola llamada (C17, 1 nov 2026; v5.3)
- **1 persona = img1 + img3:** img1 es la base aprobada y img3 es la prenda. img2 va vacía. Con pareja, img2 es una sola foto de la otra persona. «Cada persona conserva SU ropa» solo aplica con 2 o más personas; con 1, «<personaje> se pone: <prenda>».
- **Prompt de 1 persona:** «Exactly 1 person. Single continuous photograph, one camera, one background. Keep the face from the approved base, wearing the garment from the third image. No diptych, no collage, no text.»
- **Reintentos:** el juez corre antes de entregar. Otra semilla, máximo 5, el mismo prompt. Si los 5 fallan: no se manda foto y el aviso es en lenguaje claro. No hay un segundo método con una hoja.
- **Candado por chat:** mientras genera se responde una sola vez «Estoy generando tus fotos (x/N)…»; un OK en ese momento no cuenta; se suelta al terminar, al fallar o a los 10 min. Generar lo hace solo el plugin con confirmación idempotente; el modelo nunca llama `imagen_generar`.

**EN — Rule 4l:** one person = approved base (img1) plus garment (img3) in one `/edit_multi` call; vision judge and at most 5 seeds; the client only gets the final photo; per-chat lock; only the plugin generates.

### Regla 4m — Solo la vista previa del plugin, sin repetición del modelo (C18, 1 nov 2026)
Cuando `imagen_kontext` (preparar) o `imagen_confirmar` (generar) ya mandó su mensaje al usuario (la vista previa o las fotos), Hermes **no lo repite ni lo resume** con su estilo (nada de «Te mandé la vista previa ✅…» ni «¡Listo! Te llegaron las fotos…»): responde vacío o con a lo sumo una frase corta de personaje, sin datos técnicos. El resultado de la herramienta trae `ya_enviado_al_usuario: true` y `no_repetir` para recordárselo.

**EN — Rule 4m:** once the plugin has sent its preview or the photos, Hermes does not repeat or summarize them; it replies empty or with at most one short in-character line, no technical details. Tool results carry `ya_enviado_al_usuario: true`.

### Regla 4n — El cliente solo recibe la foto final (v5.3)
No se mandan referencias numeradas, ni una por una por Telegram ni juntas en una hoja. `imagen_kontext` confirma en texto. `imagen_confirmar` hace una sola llamada: `/edit_multi` con 1 a 3 imágenes, o `/generate` cuando no hay imágenes. El juez de visión corre antes de entregar, con como mucho 5 semillas. Al cliente le llega solo la foto que pasó.

**EN — Rule 4n:** do not send numbered references, one by one or as a sheet. One Space call. The vision judge runs first, at most 5 seeds. The client only receives the final photo.

### Regla 4r — Hoja con medidas como img1 y juez de cuerpo con tope (C24, v5.5)
Si el personaje tiene `personajes/<nombre>/perfil.json` (privado, fuera del repo), cuando img1 sería su cara guardada (`ref/cara-1.png`) se usa en su lugar su hoja de personaje (`perfil.hoja`) y el prompt lleva su texto de medidas (`perfil.prompt_hoja`) más «no reproduzcas paneles, etiquetas ni colores de la hoja». Si img1 es una foto ya aprobada, no se cambia.
El juez de cuerpo compara cada salida con el recorte de cuerpo completo de la hoja (`perfil.cuerpo_base`; el nombre lleva «hoja»): busto y cadera con tope en **ambos** sentidos sobre la escala small/medium/large/very large (menor que la base = `ok:false`; más de `tope_mas`, por defecto +1, = `ok:false`); la cadera se omite si no se ve; cintura ±1; complexión igual a la base.
El prompt siempre lleva: «Do not add a jacket, coat or any extra clothing or layers unless the request asks for them.» (salvo que el pedido lo pida).
Las medidas reales nunca van en código genérico ni en este repo: solo en `perfil.json` del personaje. Sin `perfil.json` el flujo es el de v5.4.
**EN — Rule 4r:** if a private per-character `perfil.json` exists, its character sheet replaces the saved face as img1 and its measurement text goes in the prompt; a body judge with a two-sided cap (smaller or exaggerated bust/hip = reject) compares every output with the sheet's full-body crop. Never add extra clothing unless asked. Measurements live only in the private profile.

## 8. Mejoras C11–C17 (E27–E33)
Genéricas. Valen para cualquier personaje. Nada de esto manda un collage al Space: la entrada sigue siendo hasta 3 imágenes sueltas (`/edit_multi`) o ninguna (`/generate`).

**C11 · E27 — El bot es el personaje (4f).** Si el cliente no manda cara, img1 es `personajes/<nombre>/ref/cara-1.png`. Las fotos que él manda se etiquetan `ropa`, `objeto` o `lugar`, y nunca como cara.

**C12 · E28 — Una cara por persona.** img1 es una sola cara del personaje. img2, si existe, es una sola cara de la otra persona. Si se arma una hoja de referencia para que la vea el dueño, es una cuadrícula 3:4, sin relleno gris y sin estirar. Esa hoja no entra al modelo. El Space recibe las fotos sueltas, nunca un collage.

**C13 · E29 — Plantilla de prompt.** Cerrar así, con N igual al número de personas:
`Exactly N person(s). Single photo, one scene, no panels, no collage, no split. No panels, no numbers, no text.`

**C14 · E30 — Revisión antes de enviar.** Se rechaza la salida si tiene relleno plano, si la proporción no es 3:4, si hay costuras rectas, si la misma identidad sale 2 veces o más, o si el número de personas no es N. Cada rechazo es un reintento interno con otra semilla, hasta 5. Si los 5 fallan, no se manda foto y se dice en lenguaje claro: «No salió bien la foto. No te mando una a medias.» El motivo (relleno, proporción, costura, cara repetida o conteo) va al registro y, si pregunta, al dueño. Solo se dice «caras OK» cuando esta revisión lo verificó de verdad.

**C15 · E31 — Solo Qwen 2.1.** El único modelo es el Space `iccanobif/qwen21-nano-banana`. No hay modelo de respaldo.

**C16 · E32 — «Varias fotos».** Son 3, máximo 4. Cada una tiene su propia revisión (su propio ciclo de hasta 5 semillas).

**C17 · E33 — Candado y una confirmación.** El chat queda bloqueado mientras se genera. Se acepta una sola confirmación por vista previa.

## Modelo de imagen obligatorio (v5.1)
El único modelo de imagen de esta skill es el Space de Hugging Face `iccanobif/qwen21-nano-banana`. No hay otro modelo ni otro Space de producción.
- **Pesos:** Qwen-Image 2.1, el GGUF Q4_K_M de terceros `abenzerps/Qwen-Image-2.1-Uncensored-GGUF`, más el codificador de texto y el VAE oficiales. Licencia: Qwen Research License.
- **Endpoints, los dos en ese Space:**
  - `/edit_multi(modo, instruccion, image1, image2, image3, aspect_ratio, steps, seed, randomize_seed)` con 1 a 3 imágenes, en una sola llamada. img1 = base aprobada, img2 = una foto de la 2.ª persona, img3 = prenda o estilo. Las que falten van vacías.
  - `/generate` solo cuando no hay imágenes.
- **Prohibido:** cualquier otro modelo, pegar caras, componer o retocar por código (incluido PIL). La luz y la integración de las personas las hace el modelo con el prompt.
- **Llamada:** solo `imagen_kontext` → `imagen_confirmar`. `qwen21_recetas.QWEN_MULTI["space"]` = `iccanobif/qwen21-nano-banana` y `RECETA="multi"`.

## Proyecto: reglas, flujo y deploy (v5.1)
**Modos:** `cara-cuerpo-estilo`; `solo-ropa`; `pareja-paso-A`, luego `dos-personas` (paso B) y después `pareja-paso-C`; `estilo`; `reiluminar`; `libre`.

**Reglas tipo Nano Banana**
- Máximo 3 imágenes, en una sola llamada. Nunca hojas, collages, ni fotos numeradas una por una por Telegram: img1, img2 e img3 son archivos sueltos.
- img1 = el personaje aprobado (la base que ya pasó el ✅; en el ejemplo, Valeria). img2 = una sola foto de la segunda persona. img3 = opcional (prenda o estilo).
- La salida sale del tamaño de img1.
- Pareja en tres pasos, un cambio por paso, repitiendo lo que se conserva y con posiciones explícitas: A (`pareja-paso-A`), B (`dos-personas`), C (`pareja-paso-C`).
- El prompt lleva una frase de una sola foto continua: «single continuous photograph, one camera, one background, exactly N people».
- Negative anti-díptico (nada de díptico, pantalla partida, lado a lado ni collage).
- 40 pasos y true_cfg 4. Sin Lightning.
- Juez de visión en Hermes antes de entregar. Cada reintento es interno, con otra semilla, máximo 5. El cliente solo ve la foto final. Si ninguno pasa, no se manda foto y el aviso es en lenguaje claro.

**Flujo, solo Qwen 2.1**
1. `imagen_kontext` arma la confirmación y no genera.
2. Tras una confirmación válida (4h), `imagen_confirmar` llama solo a ese Space: `/edit_multi` con 1 a 3 imágenes en una sola llamada, o `/generate` cuando no hay imágenes.
3. El juez de visión corre antes de enviar. Los fallos no salen del servidor hacia el cliente.
4. Nada de `dynamic_space`, navegador, scripts por terminal ni otro modelo.

**Deploy: primero el repo, después el Space**
El Space no se edita a mano. La fuente es el repo privado `https://github.com/durang/qwen21-nano-banana-space` (si aún no existe, se crea privado antes del primer push).
1. Cambios y push a `main` de ese repo.
2. `.github/workflows/sync-to-hf.yml` empuja al Space `iccanobif/qwen21-nano-banana` con el secret de repositorio `HF_TOKEN` (token de escritura de Hugging Face; solo el nombre, nunca el valor). Si el secret falta, el workflow falla a propósito.
3. El Space se reconstruye. Se espera a que quede en Running.
4. Hermes apunta `qwen21_recetas.QWEN_MULTI["space"]` a ese Space y `RECETA="multi"`.

Así se conectan: el repo es la fuente, la Action es el puente, el Space es el único sitio donde corre el modelo, y Hermes solo lo llama.

## Configuración para principiantes (v5.1)
Sirve para usar el Space en tu cuenta, sin tocar el repo privado del curso. No pegues tokens en el chat, en git ni en capturas. En `.env` y en GitHub solo va el nombre `HF_TOKEN`.

1. **Cuenta y Pro.** Entra a Hugging Face. ZeroGPU gasta la cuota de quien llama. El plan Pro sube esa cuota; sin Pro se agota antes. El hardware del Space es ZeroGPU, no una GPU de pago.
2. **Duplicar el Space.** Abre `https://huggingface.co/spaces/iccanobif/qwen21-nano-banana`. Si es privado y no tienes acceso, pídeselo al dueño: sin acceso no se puede duplicar. En el menú del Space elige **Duplicate this Space**. Dueño: tu usuario. Nombre: el que quieras. Hardware: **ZeroGPU**. Visibilidad: privada, recomendado. Espera a que quede en Running. Tu copia es `tu-usuario/tu-nombre`. La Action del repo del curso solo actualiza `iccanobif/qwen21-nano-banana`; tu copia no recibe esos push salvo que armes tu propio workflow.
3. **Token fine-grained con escritura.** Settings → Access Tokens → Create new token → tipo **Fine-grained**. Incluye ese Space (el duplicado, o el original si tienes acceso) con permiso de **escritura**. Cópialo una sola vez. En la máquina de Hermes va en `.env` como `HF_TOKEN`. En el repo de deploy, el mismo nombre es el secret de GitHub Actions (`Settings → Secrets and variables → Actions`). Un token de solo lectura no sirve para que la Action sincronice el Space.
4. **Decirle a Hermes cuál Space usar.** `qwen21_recetas.QWEN_MULTI["space"]` = `tu-usuario/tu-nombre` (o el Space del curso, si llamas a ese) y `RECETA="multi"`. Reinicia solo con el OK del dueño.

## Monetización del Space (resumen)
El detalle, con las citas y las páginas oficiales, está en `docs/06-MONETIZACION-SPACES.md`. No es asesoría legal. No se renombra el Space ni el repo.
- **Hugging Face no reparte ingresos.** No hay pagos a creadores ni tienda de Spaces. El dinero documentado va del dueño hacia Hugging Face (plan, hardware, créditos). Lo no monetario es visibilidad y, si la conceden, una Community GPU Grant (hardware).
- **Cada usuario gasta su cuota ZeroGPU.** La frase oficial: cada uso, en la interfaz o por API, descuenta la cuota personal de quien usa. Sin cuenta son 2 minutos; gratis, 5; Pro, 40.
- **La cuota del dueño baja solo cuando él llama** con su sesión o con su token. Si una web llama al Space con ese token, todo ese uso sale de su cuota (y luego de sus créditos, 1 USD por 10 minutos).
- **La licencia Qwen Research no permite uso comercial** sin una licencia aparte (`model-business@notice.qwencloud.com`). Cobrar por estas fotos, venderlas o promocionar con ellas queda fuera hasta esa licencia.
- **Nombres.** La cláusula 4.c prohíbe usar «Qwen» como nombre principal del producto; el uso descriptivo sí está permitido. «Nano Banana» es el nombre de Google para las imágenes de Gemini. Los identificadores `iccanobif/qwen21-nano-banana` y `durang/qwen21-nano-banana-space` se quedan como están.

Si el dueño pregunta si el Space le hace ganar dinero, la respuesta es no. No ofrezcas cobrar con este modelo ni propongas renombrar por tu cuenta.
