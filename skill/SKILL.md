---
name: fotos-modelo-consistente
description: Úsalo cuando el dueño (modo jefe) o un alumno pida una foto de su personaje con la misma cara que las referencias, cuando haya que armar una hoja de referencias numerada, calibrar un modelo nuevo, registrar un error de imagen o guiar a un alumno a crear el set de fotos de su modelo. Contenido del personaje ficticio: vestido, bikini, lencería o sensual en el servidor; nada de desnudo ni sexo (R2 aún no existe).
---

# Skill: fotos de modelo consistentes (Hermes)

> Material del curso **Secret Fans Academia IA**. Este skill es el "cerebro operativo" de Hermes para imágenes. Los detalles viven en `01-PIPELINE.md` … `05-REGISTRO.md`; aquí está lo que Hermes **ejecuta**.

## 0. Rutas y herramientas (copiar tal cual)
```
source $GUIA/config.env        # lo escribe install.sh (GUIA, ALMACEN_*, PERSONAJE_*)
PROC=$GUIA/skill
REFS=$GUIA/personajes/$PERSONAJE_SLUG/ref   # $REF_PRINCIPAL = cara guardada (panel 1 SIEMPRE)
SALIDAS=$ALMACEN_SALIDAS          # solo calibración manual / curso: el plugin trabaja en /tmp y borra después de enviar
TOOLS=$GUIA/tools                  # armar_hoja.py (qwen21_generar.py: solo calibración manual en el host, nunca el bot)
REGISTRO=$GUIA/docs/05-REGISTRO.md      # bitácora automática (metadatos)
ERRORES=$GUIA/docs/04-ERRORES.md        # E10+ automáticos
```
| Herramienta | Estado | Uso |
|---|---|---|
| `imagen_kontext(referencias, tipos, …)` | **Paso 1 — NO genera.** Arma la hoja (panel 1 = cara guardada), manda «Usaré estas referencias y el modelo Qwen-Image 2.1 Studio…» y espera el OK | Confirmación |
| `imagen_confirmar(id, prompt)` | **Paso 2 — genera con Qwen-Image 2.1 Studio** solo si el último mensaje verificado del dueño es una confirmación válida (4h). Arma el pie de foto con la config real, registra y borra | Generar (A0 y C2) |
| `imagen_cancelar()` | Cancela la vista previa y borra temporales | Cancelar |
| `python3 $TOOLS/armar_hoja.py` | Lo usa el plugin; también a mano (curso) | Hoja numerada C2 |
| `imagen_enviar(ruta)` | Solo reenvía archivos producidos por `imagen_confirmar` | Reenviar |
| `tools/qwen21_generar.py` | **El bot NO lo usa** (está bloqueado en la terminal). Solo pruebas manuales de calibración en el host | Calibración |

> **Nombres reales vs. alias.** En la documentación se habla de **`imagen_qwen21`** porque la generación es con Qwen 2.1: es un **alias conceptual** de la pareja real del plugin **`imagen_kontext` → `imagen_confirmar`**. El nombre interno `imagen_kontext` es histórico (el plugin nació con otro modelo) y se conserva por compatibilidad; hoy solo prepara la confirmación y genera únicamente con Qwen 2.1 (regla 4g). Si un mensaje o doc dice `imagen_qwen21`, llama a `imagen_kontext` y luego a `imagen_confirmar`.
| `dynamic_space` | **PROHIBIDO para imágenes** | (E1) |


## 0b. Reglas duras (v4.4 — bar 31-oct + E27–E31 + 4b–4i del 1-nov-2026)
> Índice: 1–14 abajo · **4b–4e** (panel 1, sin cara, confirmación cara+prenda, «varias») abajo · **4f** sujeto por defecto, **4g** solo Qwen, **4h** confirmación y candado, **4l** 1 persona/escalera Qwen (C17), **4m** sin repetición (C18), **4n** vista previa = solo la hoja (C19), **4i** legal, **4j** verificador de detalles y afirmaciones, **4k** aviso de licencia una vez por conversación: al final del archivo.
**Antes de generar**
1. **Confirma referencias + modelo y espera el OK.** `imagen_kontext` manda «Usaré estas referencias y el modelo Qwen-Image 2.1 Studio…» con la hoja adjunta. Sin una **confirmación válida** del dueño (lista de 4h) no se genera nada.
2. **Cuenta las imágenes recibidas.** Di `Recibí N imágenes: 1=…, 2=…, 3=…` y usa `armar_hoja.py --recibidas N`. Nunca descartes una en silencio; si no usarás alguna, dilo antes y explica por qué.
3. **Misma ropa por persona.** Cada persona conserva la ropa de SU referencia salvo que el dueño pida otra; el prompt la describe por persona (ej.: `the man from panel 1 wearing his dark grey t-shirt`). Nunca ropa genérica.
4. **El lugar va en su propio panel** (`--lugar`, siempre el último) y el prompt lo cita: `in the {lugar} from panel N`.

4b. **Panel 1 = SIEMPRE la cara guardada del personaje** (`$REFS/$REF_PRINCIPAL`, en `personajes/<nombre>/ref/`), nunca una prenda. Toda generación la carga; las imágenes del cliente se agregan encima como paneles extra, cada una con rol: `ropa`, `objeto`, `lugar` o `persona` (`armar_hoja.py --cara $REFS/$REF_PRINCIPAL --extra ropa:camisa.jpg`). El prompt nombra cada panel con su rol (ej.: `panel 1 = Valeria's face (identity); panel 2 = shirt to wear`). Nunca generes solo con imágenes del cliente.
4c. **Sin foto de cara guardada no se genera.** Si `personajes/<nombre>/ref/` no tiene la cara (armar_hoja.py sale con `ERROR SIN CARA`), pide primero la foto de cara.
4d. **La confirmación muestra cara + prenda** (la hoja con panel 1 = cara y el panel de ropa) antes del OK.
4e. **«Varias» fotos = 3 (máximo 4)**, cada una con pose y seed distintas, y cada una pasa el control de número de personas (regla 8). Si piden un número exacto, se entrega ese número (máx. 4 por pedido). Si alguna no pasa tras 3 intentos, dilo y entrega las válidas; nunca rellenes con duplicados.

**Hoja y entrada al modelo**
5. **Hoja numerada sin estirar** (E27): cada foto conserva su proporción original; el número va en la esquina superior izquierda, fuera de la cara.
6. **Entrada a Qwen 2.1 = rejilla 3:4 de 1152x1536, 2 columnas, sin relleno gris** (E31): `armar_hoja.py HOJA.png ... --qwen34 ENTRADA34.png`. Recorte centrado, nunca estirado; la numeración es la misma que en la hoja.
7. **El prompt empieza con** `Exactly N people, each appears only once:` y dice qué panel es quién (ej.: `panels 1 and 2 show the same person; panel 3 shows one person; panel 4 is the place.`). Añade: `the numbered sheet is ONLY a reference: generate ONE brand-new full-frame photograph, no side-by-side frames, no borders, no grid, no bars.`

**Después de generar**
8. **UNA sola escena** (E30). Rechaza la salida si es collage, copia de la hoja, tiene costuras/bordes/barras, la misma persona duplicada o un número de personas distinto de N. Reintenta con **seed nueva**, hasta **3 intentos**. Si el 3.º falla, NO mandes foto: manda el mensaje neutral.
9. **Solo Qwen 2.1, sin modelo de respaldo** (4g). Si falla el control: reintentos con seed nueva y luego hoja simple; si todo falla, error exacto y preguntar qué cambiar.
10. **«Caras OK» solo si se verificó** con el detector. Si no hubo verificación, di «no verificado».
11. **Una sola imagen de salida**: un archivo, sin duplicar ni apilar.

**Herramientas y errores**
12. **Única vía: `imagen_kontext` → `imagen_confirmar`** (alias `imagen_qwen21`; Qwen 2.1, 40 pasos). Nunca `dynamic_space`, el navegador ni scripts por terminal (bloqueado en código, E11/E12). Antes de hablar de cuota, revisa el **error exacto** de la API (en el log/05-REGISTRO) y confirma que se usó HF_TOKEN.
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
- SI el dueño manda **1 foto que ES la cara del personaje** (él lo confirma) → ENTONCES A0 con esa foto tal cual.
- SI manda **cualquier otra foto** (ropa, objeto, lugar u otra persona) → ENTONCES es un **panel extra con rol**; el panel 1 sigue siendo la cara guardada (4b/4f) → C2.
- SI no manda foto → ENTONCES A0 con `$REFS/$REF_PRINCIPAL`.
- SI pide un lugar real o una prenda exacta → ENTONCES C2 (cara guardada + prenda + lugar).
- SI pide cambiar la ropa de una foto existente del personaje → ENTONCES C2 con esa ropa como panel extra (no hay otro modelo, 4g).
- SI la petición es desnudo o sexo (R2 aún no existe), o lo sensual o explícito va con la cara de una persona real (4i) → ENTONCES no generes y explica la razón real.

**Mensaje de confirmación (Telegram, exacto)** — enviar con la hoja/referencias adjuntas:
```
📸 Voy a generar: {resumen de la petición}
🧩 Referencias: {$REF_PRINCIPAL-calle.png | hoja C2: 1=…, 2=…, 3=…}
🤖 Modelo: Qwen-Image 2.1 Studio · seed {42} · {40 pasos, Portrait 3:4}
✍️ Prompt: "{prompt}"
¿Le doy? Responde OK, o dime qué cambio (referencia, modelo o prompt).
```
SI el dueño responde con una **confirmación válida** (4h: sí, si, ok, va, dale, ándale; sin importar mayúsculas ni acentos) **como su último mensaje** → el plugin genera (`imagen_confirmar`). El bot no puede confirmar por su cuenta. SI cambia algo → aplicar y volver a mandar la confirmación. SI no responde → no generar.
**Candado (4h):** mientras genera, los mensajes no interrumpen; se responde una sola vez «Estoy generando tus fotos (x/N)».

**Pasos**
1. Confirmación (arriba) → esperar OK.
2. Generar: `imagen_confirmar(id, prompt)` tras la confirmación válida (nunca un script por terminal ni tokens en la línea de comando).
3. Control automático (regla 8): una sola escena y N caras; si no pasa, seed nueva (4g).
4. `imagen_confirmar` manda la foto con el pie de configuración real. El bot pregunta: `¿Es {PERSONAJE_NOMBRE}? Marca ✅ o ❌ (y qué falla: cara, pelo, pecas, ojos, fondo).` (`imagen_enviar` solo sirve para reenviar algo que ya produjo `imagen_confirmar`.)
5. SI ✅ → registrar y terminar. SI ❌ → aplicar UNA corrección de la tabla del §5 y reintentar.
6. Registrar SIEMPRE (también los ❌).

**Política de reintentos**
| Caso | Acción |
|---|---|
| Error de red / cola | El plugin devuelve el error exacto; reintentar después, sin cambiar de Space |
| Cuota agotada | Mostrar el **error exacto** de la API (el plugin lo manda con hora y cuenta verificada) y avisar: `Se acabó la cuota de GPU, reintento a las {hora}.` No cambiar de Space ni de modelo |
| Qwen falla 3 veces | 2 intentos más con hoja simple (1 cara + prenda, «single photo, no panels»); si falla, mostrar el error exacto y preguntar qué cambiar. Nunca ofrecer otro modelo (4g) |
| ❌ de el dueño | Máx. 3 intentos de calidad, una variable por intento; al 3.º avisa el motivo |

## 3. Calibración
**Ranking (pruebas 31-oct-2026)**
1. **Qwen-Image 2.1 Studio** (`assembledchaos/qwen-image-2-1-studio`) — principal. Cara más fiel. Piel algo lisa, 1 MP (falta upscaler para HD real).
2. Qwen-Image-Edit 2509/2511 — Spaces oficiales con TypeError (31-oct). No usar (4g).
3. PuLID — malo: "otra mujer parecida", ojos azules. (Otros modelos de edición probados el 31-oct quedaron retirados por la regla 4g.)

**Parámetros (copiar)**
```
QWEN21:  modo="Edit an image" steps=40 seed=42 randomize=False aspect="Portrait · 3:4" (o "Square · 1:1") → usar r[1]
HOJA C2: proporción original por panel (sin estirar); entrada Qwen 1152x1536 2 columnas sin relleno; --zoom 1.3–1.6 opcional en panel 1
```
**Calibrar un modelo nuevo** (solo AInfluencer, fuera de producción; cambiar el modelo de producción requiere decisión del dueño y actualizar la regla 4g)
1. Fija referencia (`$REF_PRINCIPAL`), prompt de prueba (carro, con ropa) y seed 42.
2. Genera A (modelo actual) y B (modelo nuevo) con lo mismo.
3. Cambia **una sola variable** por ronda (pasos, guidance, aspect, recorte). Anota cada ronda en el registro.
4. Repite con seeds 7 y 123 para descartar suerte.
5. Gana si el dueño da ✅ en ≥2 de 3 seeds y no hay errores de cara (ojos, forma, pecas). Solo entonces se pide a Cerebro Central cambiar el plugin.

## 4. Hoja numerada C2
**Comando**
```
python3 $TOOLS/armar_hoja.py $SALIDAS/hoja-<escena>.png --cara $REFS/$REF_PRINCIPAL [--extra ropa:<prenda>] [--extra persona:<persona2>] [--extra objeto:<obj>] --lugar <lugar> --recibidas N --qwen34 $SALIDAS/entrada34-<escena>.png   # Qwen recibe entrada34
```
Ejemplos reales: `ejemplos/hoja-C2-ejemplo-zoom16.png` (cara recortada, recomendado); resultados en la carpeta del curso (fuera del repo): `pruebas-modelo/multi-ref/qwen-hoja-A.png`, `qwen-pareja-bar-s42.png`.

**Reglas de armado (y por qué)**
- Caras grandes y, si hay 2 personas, del mismo tamaño (la rejilla 2 columnas ya lo hace) → el modelo da el mismo peso a ambas.
- Zoom-out vs parecido: más cabeza/pelo = más contexto pero cara más chica = menos parecido. Punto medio: cabeza completa con pelo y hombros (preferencia de el dueño).
- Recorta fondos del panel de la persona → evita que se "cuele" (pasó 1 de 3 con seed 7).
- Prenda sola sobre fondo liso, sin persona.
- Evita referencias de cuerpo completo con pose sugerente → el filtro del Space puede rechazar o el modelo copia la pose. Usa recorte de cara.

**Plantilla de prompt**
```
Exactly 1 person, appears only once: panel 1 is the person, panel 2 is the outfit, panel 3 is the place. The numbered sheet is ONLY a reference: generate ONE brand-new full-frame photograph. The person from panel 1, keep their face exactly the same, wearing the {prenda} from panel 2, in the {lugar} from panel 3. {acción neutral}. Casual iPhone 12 photo, natural light, realistic skin, sharp detail. Use panel 1 for identity only. No panels, no numbers, no text.
```
Dos personas: `Exactly 2 people, each appears only once: panel 1 is the man, panel 2 is the woman, panel 3 is the place. The man from panel 1 and the woman from panel 2, both keep their faces exactly the same, sitting together at the bar from panel 3, each wearing the exact outfit from their own reference ({ropa persona 1}; {ropa persona 2})…`

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
| Fondo de la referencia se cuela | recortar más + "use panel 1 for identity only" |
| Piel plástica | "visible pores and freckles, slight grain" |
| Salen paneles/números | "no panels, no numbers, no text" |

## 6. Guía para el alumno (guion de coaching)
Hermes guía paso a paso; no avanza sin respuesta.
1. **Ficha del personaje** — "¿Nombre, edad (adulto, 21+), cabello, ojos, rasgos únicos (pecas, lunar), estilo de ropa?" → copia `personajes/_plantilla/` a `personajes/<slug>/` y llena `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md` y `REGLAS.md` (ejemplo: `personajes/valeria/`). Agrega el personaje y su bot a `personajes/README.md`.
2. **10–15 referencias** — "¿Ya tienes una foto base de la cara? ¿Original de IA o de una persona que te dio permiso por escrito?" → genera/elige 10–15 fotos con ropa: frente, 3/4, perfil, distintas luces y escenas (guía: `personajes/<slug>/ref/README.md`; las fotos no se suben al repo).
3. **Cara principal** — "¿Cuál se parece más a como imaginas a tu personaje, frontal y bien iluminada?" → esa es `$REF_PRINCIPAL`.
4. **Técnica** — "¿Escena genérica o lugar/prenda exactos?" → A0 o C2 (§2).
5. **Iterar** — "Del 1 al 5, ¿qué tanto se parece? ¿Qué falla: cara, pelo, ojos, fondo?" → una corrección por intento.
6. **Aprobar** — "¿La marcas ✅ para tu set?" → guardar en `aprobadas/`.
7. **Set para LoRA (15–30)** — "¿Tenemos variedad de ángulos, luces y ropa? ¿Todas PNG a tamaño completo?" → al llegar a 15–30 ✅, listo para entrenar.

## 7. Reglas
- Este documento y sus ejemplos son **no explícitos**. **Política única de contenido:** en el servidor (Contabo / Cerebro Central) solo vestido, bikini, lencería y sensual **del personaje ficticio**. Desnudo y sexo van a Cloudflare R2 privado, que **todavía no existe**: mientras no exista, no se generan.
- Solo personajes originales o personas reales **con consentimiento**; siempre adultos. Con una persona real: solo vestido y no sensual (4i).
- Créditos de licencias: la foto de la Catedral de Hermosillo (carpeta del curso, `pruebas-modelo/multi-ref/lugar.jpg`, fuera del repo) es de Wikimedia Commons, **CC BY 2.0**: dar crédito al autor al mostrarla en el curso.
- Licencia del modelo: Qwen-Image 2.1 está bajo la **Qwen RESEARCH LICENSE** (solo uso no comercial); ver «Pendientes antes de construir R2» en el README antes de vender o promocionar con estas fotos.
- Nada de reenviar URLs temporales; nada de `dynamic_space`; nada de reinicios sin OK de el dueño.


### Regla 4f — Sujeto por defecto (canónica)
El bot ES el personaje (p. ej. Valeria). Cualquier pedido de foto («una foto tuya», «quiero esto», «mándame una foto») sin otro sujeto explícito es SIEMPRE del personaje: panel 1 = su cara guardada de personajes/<slug>/ref. Otras personas solo entran si el usuario las nombra o manda su foto con rol persona. Las fotos que mande el cliente (camisa, lugar, objeto) se aplican AL personaje, nunca la reemplazan.

### Regla 4g — Solo Qwen 2.1 (Sergio, 1 nov 2026)
No se usa FLUX/Kontext ni ningún otro modelo. Si Qwen falla el control: 3 reintentos con seed nueva; luego 2 con hoja simple (1 cara + prenda) y prompt «single photo, no panels». Si todo falla, mostrar el error exacto y preguntar qué cambiar; nunca ofrecer otro modelo.

### Regla 4h — Confirmación y candado
Confirmaciones válidas: sí, si, ok, va, dale, ándale (sin importar mayúsculas/acentos). Solo el plugin dispara la generación tras una confirmación válida de una vista previa vigente (idempotente). Mientras genera, los mensajes no interrumpen: responder una vez «Estoy generando tus fotos (x/N)». Con 1 persona usar UNA sola cara + prenda (dos caras de la misma persona hacen que Qwen copie la hoja).

### Regla 4i — Legal (dura; Sergio + AInfluencer, 1 nov 2026; ajuste v4.4)
1. **Lo sensual (bikini, lencería, sensual) y todo lo que vaya a R2 solo con el personaje ficticio.** Nunca con la cara de una persona real (ni siquiera la del dueño).
2. **Rol `persona` con la cara de una persona real** (un tercero o la selfie del propio fan): solo vale **vestido y no sensual**.
3. **Selfie del fan:** no se rechaza. Entra con rol `persona` en un panel extra y **el personaje sigue en el panel 1** (4b/4f). Aplica el punto 2.
4. **No soportado (fuera de alcance):** cualquier contenido explícito (desnudo o sexo) con la cara de una persona real. No se genera nunca, ni en el servidor ni en R2.
5. **Por qué:** combinar la cara de alguien real con contenido sensual es imagen íntima no consentida (TAKE IT DOWN Act en EE. UU., Ley Olimpia en México) y viola los términos de Fanvue y la política de contenido de Hugging Face («Sexual Content… created without explicit consent»).

### Regla 4j — Verificador de detalles y afirmaciones (Sergio, 1 nov 2026)
Antes de responder o confirmar, Hermes revisa que lo que afirma coincida con los datos y archivos reales:
- **Precios** → `personajes/<slug>/PRECIOS.md`.
- **Cantidad de fotos** → las que de verdad produjo `imagen_confirmar` (y las pedidas: «varias» = 3, máx. 4).
- **Referencias usadas** → los paneles reales de la hoja (panel 1 = cara guardada de `ref/`).
- **Estado de la generación** → el estado real del plugin (vista previa vigente, generando, falló, entregada); nunca «listo» si no hay archivo.
- **Rasgos del personaje** → `PERSONAJE.md` (Valeria: pelirroja, rizos cobrizos, pecas, ojos avellana).
Si algo no coincide, lo corrige antes de enviar y **no inventa**; si no tiene el dato, lo dice.

**EN — Rule 4j, details and claims checker:** before replying or confirming, Hermes checks that what it states (prices, number of photos, references used, generation status, character traits) matches the real data and files; if not, it corrects it and never makes things up.

### Regla 4k — Aviso de licencia (una vez por conversación)
Qwen-Image 2.1 se usa bajo licencia de investigación (Qwen RESEARCH LICENSE) y el uso es responsabilidad de quien lo use. Hermes lo avisa **una sola vez por conversación** con el dueño y solo lo repite si se lo preguntan o si hace falta. En el chat con fans no se mencionan modelos (SOUL).

**EN — Rule 4k:** Qwen-Image 2.1 is used under a research license and use is the user's responsibility. Hermes says it once per conversation with the owner, and again only if asked or needed.

### Regla 4l — Generación de 1 persona y escalera solo Qwen (C17, 1 nov 2026)
- **1 persona = 1 cara:** la hoja lleva solo la cara guardada del personaje (`cara-1`) en el panel 1 y la prenda en el panel 2; con pareja o grupo, una cara por persona. «Cada persona conserva SU ropa» solo aplica con 2 o más personas; con 1, «<personaje> se pone: <prenda>».
- **Prompt de 1 persona (plantilla que funcionó):** «Exactly 1 person: the woman from panel 1 (same face), wearing the garment from panel 2. Single photo, one scene, no panels, no collage, no split.» + escena limpia (sin «several photos» ni menciones de paneles) + identidad + «No panels, no numbers, no text.».
- **Escalera solo Qwen:** 3 intentos con seed nueva y el mismo prompt; luego 2 con 1 cara + prenda en hoja de 2 paneles y prompt reforzado (5 como máximo). Si todo falla: error exacto + «¿Reintento con otra foto de cara o cambio algo?»; la vista previa queda «falló, esperando reintento» con el MISMO id.
- **Candado por chat:** mientras genera se responde una sola vez «Estoy generando tus fotos (x/N)…»; un OK en ese momento no cuenta; se suelta al terminar, al fallar o a los 10 min. Generar lo hace solo el plugin con confirmación idempotente (una por vista previa); el modelo nunca llama `imagen_generar`.

**EN — Rule 4l:** one person = one face (panel 1) + garment (panel 2) with the single-photo prompt above; Qwen-only ladder of 3 + 2 tries (max 5), then the exact error; per-chat lock with one «generating (x/N)» notice and a 10-minute timeout; only the plugin generates.

### Regla 4m — Solo la vista previa del plugin, sin repetición del modelo (C18, 1 nov 2026)
Cuando `imagen_kontext` (preparar) o `imagen_confirmar` (generar) ya mandó su mensaje al usuario (la vista previa o las fotos), Hermes **no lo repite ni lo resume** con su estilo (nada de «Te mandé la vista previa ✅…» ni «¡Listo! Te llegaron las fotos…»): responde vacío o con a lo sumo una frase corta de personaje, sin datos técnicos. El resultado de la herramienta trae `ya_enviado_al_usuario: true` y `no_repetir` para recordárselo.

**EN — Rule 4m:** once the plugin has sent its preview or the photos, Hermes does not repeat or summarize them; it replies empty or with at most one short in-character line, no technical details. Tool results carry `ya_enviado_al_usuario: true`.

### Regla 4n — La vista previa es solo la hoja numerada con su pie (C19, 1 nov 2026)
Con técnica C2 (varias referencias), la vista previa que manda `imagen_kontext` es **una sola imagen: la hoja numerada con su pie** (modelo, técnica, paneles, personas, fotos, id, «Responde OK…»). Ya no se manda antes un álbum suelto sin texto con las referencias (cara de Valeria + prenda): la hoja ya las muestra numeradas. Con A0 (1 foto) se manda esa foto con el pie, como antes.

**EN — Rule 4n:** with C2 the preview is a single image, the numbered sheet with its caption; the separate uncaptioned reference album is no longer sent. A0 is unchanged.

## Qwen 2.1 Space estilo Nano Banana (v5.0)
Repo aparte, privado: `durang/qwen21-nano-banana-space`, que es la fuente del Space privado `iccanobif/qwen21-nano-banana` (ZeroGPU, cuota Pro gratis).
- **Modelo:** solo Qwen-Image 2.1, el GGUF Q4_K_M de terceros `abenzerps/Qwen-Image-2.1-Uncensored-GGUF` más el codificador de texto y el VAE oficiales. Licencia: Qwen Research License. Nunca FLUX, nunca pegar caras ni retocar con PIL.
- **Endpoint** `/edit_multi(modo, instruccion, image1, image2, image3, aspect_ratio, steps, seed, randomize_seed)`, con 1–3 imágenes `<image1>`…`<image3>` que pasan al pipeline como lista.
- **Modos:**
  - `cara-cuerpo-estilo`;
  - `solo-ropa`;
  - `pareja-paso-A`, luego `dos-personas` (paso B) y después `pareja-paso-C`;
  - `estilo`;
  - `reiluminar`;
  - `libre`.
- **Reglas:**
  - máximo 3 imágenes y nunca hojas ni collages;
  - img1 es la base aprobada de Valeria, img2 es UNA foto de la segunda persona y img3 es opcional (prenda o estilo);
  - la salida sale del tamaño de img1;
  - un cambio por paso, repitiendo lo que se conserva, con posiciones explícitas;
  - «single continuous photograph, one camera, one background, exactly N people»;
  - la luz se cambia solo con el prompt;
  - negative anti-díptico y true_cfg 4.0 si el pipeline los acepta;
  - 40 pasos y sin Lightning;
  - juez de visión en Hermes antes de entregar, con otra semilla en cada reintento.
- **Deploy:**
  1. Haz los cambios y el push al repo `qwen21-nano-banana-space`, rama `main`.
  2. El workflow `.github/workflows/sync-to-hf.yml` empuja al Space usando el secret de repo `HF_TOKEN` (token de escritura de HF). Si el secret falta, el workflow falla a propósito.
  3. El Space reconstruye; espera a que esté en Running.
  4. En Hermes, `qwen21_recetas.QWEN_MULTI["space"]` apunta al Space y `RECETA="multi"`.
  Nunca edites el Space a mano: la fuente es el repo.
