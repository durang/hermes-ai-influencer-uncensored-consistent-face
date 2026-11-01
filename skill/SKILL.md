---
name: fotos-modelo-consistente
description: Úsalo cuando el dueño (modo jefe) o un alumno pida una foto de su personaje con la misma cara que las referencias, cuando haya que armar una hoja de referencias numerada, calibrar un modelo nuevo, registrar un error de imagen o guiar a un alumno a crear el set de fotos de su modelo. Solo contenido SFW con ropa.
---

# Skill: fotos de modelo consistentes (Hermes)

> Material del curso **Secret Fans Academia IA**. Este skill es el "cerebro operativo" de Hermes para imágenes. Los detalles viven en `01-PIPELINE.md` … `05-REGISTRO.md`; aquí está lo que Hermes **ejecuta**.

## 0. Rutas y herramientas (copiar tal cual)
```
source $GUIA/config.env        # lo escribe install.sh (GUIA, ALMACEN_*, PERSONAJE_*)
PROC=$GUIA/skill
REFS=$GUIA/personajes/$PERSONAJE_SLUG/ref   # $REF_PRINCIPAL = cara guardada (panel 1 SIEMPRE)
SALIDAS=$ALMACEN_SALIDAS          # AAAAMMDD-HHMM-escena-intento.png
TOOLS=$GUIA/tools                  # armar_hoja.py, qwen21_generar.py
REGISTRO=$GUIA/docs/05-REGISTRO.md      # bitácora automática (metadatos)
ERRORES=$GUIA/docs/04-ERRORES.md        # E10+ automáticos
```
| Herramienta | Estado | Uso |
|---|---|---|
| `imagen_qwen21` (plugin) / `python3 $TOOLS/qwen21_generar.py` | Principal. Si el plugin aún no existe, usa el script | Generar (A0 y C2) |
| `imagen_kontext(ref, prompt, guidance=2.5, steps=28, seed=42)` | Respaldo instalado | Re-vestir una foto existente / si Qwen falla |
| `python3 $TOOLS/armar_hoja.py` | Listo | Hoja numerada C2 |
| `imagen_enviar(ruta_local)` | Instalado | Mandar a Telegram (siempre archivo local) |
| `dynamic_space` | **PROHIBIDO para imágenes** | (E1) |


## 0b. Reglas duras (v3 — bar 31-oct + E27–E31 del 1-nov-2026)
**Antes de generar**
1. **Confirma referencias + modelo y espera el OK.** Manda «Usaré estas referencias y el modelo X» con la hoja adjunta. Sin OK explícito del dueño no se genera nada.
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
9. **FLUX Kontext solo como respaldo y solo para 1 persona** (recibe una sola imagen). Con 2+ personas el respaldo es Qwen con otra seed. Usarlo requiere OK del dueño.
10. **«Caras OK» solo si se verificó** con el detector. Si no hubo verificación, di «no verificado».
11. **Una sola imagen de salida**: un archivo, sin duplicar ni apilar.

**Herramientas y errores**
12. **Solo la herramienta Qwen 2.1** (`imagen_qwen21` / `qwen21_generar.py`, 40 pasos). Nunca `dynamic_space` ni el navegador. Antes de hablar de cuota, revisa el **error exacto** de la API (en el log/05-REGISTRO) y confirma que se usó HF_TOKEN.
13. **Al cliente nunca le hables de token, GPU, API, cuota ni nombres de modelos** (E29). Mensaje neutral: «Tuve un problema al generar la foto, lo intento de nuevo en un momento.» El error exacto va solo al registro y, si lo pide, al dueño en modo jefe.

**Almacenamiento**
14. Respeta `ALMACEN_ADULTO` de `config.env`:
    - **Servidor (Contabo / Cerebro Central):** en el disco del servidor solo bikini, lencería o sensual sin desnudo.
    - **Desnudo / contenido sexual:** va a **Cloudflare R2 privado** — **TODO: aún no construido**; mientras no exista, no se genera ni se guarda en el servidor.
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
- SI el dueño manda **1 foto** → ENTONCES técnica A0 con esa foto como referencia.
- SI manda **2–6 fotos** → ENTONCES hoja C2 en ese orden (panel 1 = la primera).
- SI no manda foto → ENTONCES A0 con `$REFS/$REF_PRINCIPAL`.
- SI pide un lugar real o una prenda exacta → ENTONCES C2 (persona + prenda + lugar).
- SI pide solo cambiar ropa de una foto existente del personaje → ENTONCES `imagen_kontext`.
- SI la petición no es SFW en el canal de jefe sin modo explícito acordado, o usa a una persona real sin consentimiento → ENTONCES no generes y explica por qué.

**Mensaje de confirmación (Telegram, exacto)** — enviar con la hoja/referencias adjuntas:
```
📸 Voy a generar: {resumen de la petición}
🧩 Referencias: {$REF_PRINCIPAL-calle.png | hoja C2: 1=…, 2=…, 3=…}
🤖 Modelo: {Qwen-Image 2.1 Studio | Kontext dev} · seed {42} · {40 pasos, Portrait 3:4}
✍️ Prompt: "{prompt}"
¿Le doy? Responde OK, o dime qué cambio (referencia, modelo o prompt).
```
SI el dueño responde OK/sí/dale → generar. SI cambia algo → aplicar y volver a mandar la confirmación. SI no responde → no generar.

**Pasos**
1. Confirmación (arriba) → esperar OK.
2. Generar: `HF_TOKEN=$HF_TOKEN python3 $TOOLS/qwen21_generar.py <ref|hoja> "<prompt>" $SALIDAS/<nombre>.png`
3. QC automático: archivo existe, >200 KB, ~864×1152.
4. Enviar con `imagen_enviar` y el texto: `¿Es {PERSONAJE_NOMBRE}? Marca ✅ o ❌ (y qué falla: cara, pelo, pecas, ojos, fondo).`
5. SI ✅ → registrar y terminar. SI ❌ → aplicar UNA corrección de la tabla del §5 y reintentar.
6. Registrar SIEMPRE (también los ❌).

**Política de reintentos**
| Caso | Acción |
|---|---|
| Error de red / cola | El script reintenta 3 veces (20/40/80 s) |
| Cuota agotada (código 3) | Mostrar el error exacto de la API y avisar: `Se acabó la cuota de GPU, reintento a las {hora}.` No cambiar de Space |
| Qwen falla 3 veces | Preguntar: `Qwen no responde. ¿Uso Kontext de respaldo?` |
| ❌ de el dueño | Máx. 3 intentos de calidad, una variable por intento; al 3.º avisa el motivo |

## 3. Calibración
**Ranking (pruebas 31-oct-2026)**
1. **Qwen-Image 2.1 Studio** (`assembledchaos/qwen-image-2-1-studio`) — principal. Cara más fiel. Piel algo lisa, 1 MP (falta upscaler para HD real).
2. **FLUX.1 Kontext dev** (`black-forest-labs/FLUX.1-Kontext-Dev`) — respaldo. Excelente para re-vestir una foto existente; guidance >3 cambia la cara.
3. Qwen-Image-Edit 2509/2511 — Spaces oficiales con TypeError (31-oct). No usar hasta re-probar.
4. PuLID-FLUX — malo: "otra mujer parecida", ojos azules.

**Parámetros (copiar)**
```
QWEN21:  modo="Edit an image" steps=40 seed=42 randomize=False aspect="Portrait · 3:4" (o "Square · 1:1") → usar r[1]
KONTEXT: guidance=2.5 steps=28 seed=42   (rango seguro 2.0–2.5)
HOJA C2: proporción original por panel (sin estirar); entrada Qwen 1152x1536 2 columnas sin relleno; --zoom 1.3–1.6 opcional en panel 1
```
**Calibrar un modelo nuevo**
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
Ejemplos reales: `ejemplos/hoja-C2-ejemplo-zoom16.png` (cara recortada, recomendado); resultados `../pruebas-modelo/multi-ref/qwen-hoja-A.png`, `qwen-pareja-bar-s42.png`.

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
1. **Ficha del personaje** — "¿Nombre, edad (adulto, 21+), cabello, ojos, rasgos únicos (pecas, lunar), estilo de ropa?" → crea `personaje/<nombre>.md` desde `personaje/plantilla.md` (ejemplo: `personaje/ejemplo-valeria.md`).
2. **10–15 referencias** — "¿Ya tienes una foto base de la cara? ¿Original de IA o de una persona que te dio permiso por escrito?" → genera/elige 10–15 fotos con ropa: frente, 3/4, perfil, distintas luces y escenas.
3. **Cara principal** — "¿Cuál se parece más a como imaginas a tu personaje, frontal y bien iluminada?" → esa es `$REF_PRINCIPAL`.
4. **Técnica** — "¿Escena genérica o lugar/prenda exactos?" → A0 o C2 (§2).
5. **Iterar** — "Del 1 al 5, ¿qué tanto se parece? ¿Qué falla: cara, pelo, ojos, fondo?" → una corrección por intento.
6. **Aprobar** — "¿La marcas ✅ para tu set?" → guardar en `aprobadas/`.
7. **Set para LoRA (15–30)** — "¿Tenemos variedad de ángulos, luces y ropa? ¿Todas PNG a tamaño completo?" → al llegar a 15–30 ✅, listo para entrenar.

## 7. Reglas
- Este documento y sus ejemplos son **solo SFW, con ropa**.
- Solo personajes originales o personas reales **con consentimiento**; siempre adultos.
- Créditos de licencias: la foto de la Catedral de Hermosillo (`pruebas-modelo/multi-ref/lugar.jpg`) es de Wikimedia Commons, **CC BY 2.0**: dar crédito al autor al mostrarla en el curso.
- Nada de reenviar URLs temporales; nada de `dynamic_space`; nada de reinicios sin OK de el dueño.
