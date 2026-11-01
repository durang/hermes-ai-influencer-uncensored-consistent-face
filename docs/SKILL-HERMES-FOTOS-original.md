---
name: fotos-modelo-consistente
description: Úsalo cuando Sergio (modo jefe) o un alumno pida una foto de Valeria o de su propio personaje con la misma cara que las referencias, cuando haya que armar una hoja de referencias numerada, calibrar un modelo nuevo, registrar un error de imagen o guiar a un alumno a crear el set de fotos de su modelo. Solo contenido SFW con ropa.
---

# Skill: fotos de modelo consistentes (Hermes)

> Material del curso **Secret Fans Academia IA**. Este skill es el "cerebro operativo" de Hermes para imágenes. Los detalles viven en `01-PIPELINE.md` … `05-REGISTRO.md`; aquí está lo que Hermes **ejecuta**.

## 0. Rutas y herramientas (copiar tal cual)
```
GUIA=/opt/data/guia-imagen
PROC=$GUIA/procedimiento-imagen
REFS=$GUIA/referencias            # ref-1-calle.png = cara principal
SALIDAS=/opt/data/salidas          # AAAAMMDD-HHMM-escena-intento.png
TOOLS=$PROC/tools                  # armar_hoja.py, qwen21_generar.py
REGISTRO=$PROC/05-REGISTRO.md      # bitácora automática (metadatos)
ERRORES=$PROC/04-ERRORES.md        # E10+ automáticos
```
| Herramienta | Estado | Uso |
|---|---|---|
| `imagen_qwen21` (plugin) / `python3 $TOOLS/qwen21_generar.py` | Principal. Si el plugin aún no existe, usa el script | Generar (A0 y C2) |
| `imagen_kontext(ref, prompt, guidance=2.5, steps=28, seed=42)` | Respaldo instalado | Re-vestir una foto existente / si Qwen falla |
| `python3 $TOOLS/armar_hoja.py` | Listo | Hoja numerada C2 |
| `imagen_enviar(ruta_local)` | Instalado | Mandar a Telegram (siempre archivo local) |
| `dynamic_space` | **PROHIBIDO para imágenes** | (E1) |

## 1. Orquestación: quién hace qué
| Rol | Hace | No hace |
|---|---|---|
| **Sergio** | Pide, aprueba referencias + modelo, marca ✅/❌, autoriza reinicios | — |
| **Hermes** (modo jefe y modo imagen) | Ejecuta este skill, confirma antes de generar, envía, registra | Cambiar su propio código, reiniciarse, probar Spaces al azar |
| **Cerebro Central** (+ sesión Opus 5.5) | Cambia código/plugins, copia archivos al contenedor, reinicia **solo con OK de Sergio** | Generar fotos para fans |
| **AInfluencer** (Grok Bot) | Documenta, calibra modelos, escribe estos .md; rutina nocturna ~11 p. m. (Hermosillo) que mejora la doc si hubo errores nuevos | Tocar el contenedor sin pasar por Cerebro Central |

## 2. Flujo obligatorio con confirmaciones
**Reglas si/entonces**
- SI Sergio manda **1 foto** → ENTONCES técnica A0 con esa foto como referencia.
- SI manda **2–6 fotos** → ENTONCES hoja C2 en ese orden (panel 1 = la primera).
- SI no manda foto → ENTONCES A0 con `$REFS/ref-1-calle.png`.
- SI pide un lugar real o una prenda exacta → ENTONCES C2 (persona + prenda + lugar).
- SI pide solo cambiar ropa de una foto existente de Valeria → ENTONCES `imagen_kontext`.
- SI la petición no es SFW en el canal de jefe sin modo explícito acordado, o usa a una persona real sin consentimiento → ENTONCES no generes y explica por qué.

**Mensaje de confirmación (Telegram, exacto)** — enviar con la hoja/referencias adjuntas:
```
📸 Voy a generar: {resumen de la petición}
🧩 Referencias: {ref-1-calle.png | hoja C2: 1=…, 2=…, 3=…}
🤖 Modelo: {Qwen-Image 2.1 Studio | Kontext dev} · seed {42} · {40 pasos, Portrait 3:4}
✍️ Prompt: "{prompt}"
¿Le doy? Responde OK, o dime qué cambio (referencia, modelo o prompt).
```
SI Sergio responde OK/sí/dale → generar. SI cambia algo → aplicar y volver a mandar la confirmación. SI no responde → no generar.

**Pasos**
1. Confirmación (arriba) → esperar OK.
2. Generar: `HF_TOKEN=$HF_TOKEN python3 $TOOLS/qwen21_generar.py <ref|hoja> "<prompt>" $SALIDAS/<nombre>.png`
3. QC automático: archivo existe, >200 KB, ~864×1152.
4. Enviar con `imagen_enviar` y el texto: `¿Es Valeria? Marca ✅ o ❌ (y qué falla: cara, pelo, pecas, ojos, fondo).`
5. SI ✅ → registrar y terminar. SI ❌ → aplicar UNA corrección de la tabla del §5 y reintentar.
6. Registrar SIEMPRE (también los ❌).

**Política de reintentos**
| Caso | Acción |
|---|---|
| Error de red / cola | El script reintenta 3 veces (20/40/80 s) |
| Cuota agotada (código 3) | Avisar: `Se acabó la cuota de GPU, reintento a las {hora}.` No cambiar de Space |
| Qwen falla 3 veces | Preguntar: `Qwen no responde. ¿Uso Kontext de respaldo?` |
| ❌ de Sergio | Máx. 3 intentos de calidad, una variable por intento; al 3.º avisa el motivo |

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
HOJA C2: 1536x768, panel cara 1.4x, --zoom 1.3–1.6
```
**Calibrar un modelo nuevo**
1. Fija referencia (`ref-1-calle.png`), prompt de prueba (carro, con ropa) y seed 42.
2. Genera A (modelo actual) y B (modelo nuevo) con lo mismo.
3. Cambia **una sola variable** por ronda (pasos, guidance, aspect, recorte). Anota cada ronda en el registro.
4. Repite con seeds 7 y 123 para descartar suerte.
5. Gana si Sergio da ✅ en ≥2 de 3 seeds y no hay errores de cara (ojos, forma, pecas). Solo entonces se pide a Cerebro Central cambiar el plugin.

## 4. Hoja numerada C2
**Comando**
```
python3 $TOOLS/armar_hoja.py $SALIDAS/hoja-<escena>.png <persona1> [persona2] <prenda> <lugar> --zoom 1.5
# con 2 personas: --principal 0 (paneles iguales)
```
Ejemplos reales: `ejemplos/hoja-C2-ejemplo-zoom16.png` (cara recortada, recomendado); resultados `../pruebas-modelo/multi-ref/qwen-hoja-A.png`, `qwen-pareja-bar-s42.png`.

**Reglas de armado (y por qué)**
- Caras grandes y, si hay 2 personas, del **mismo tamaño** (`--principal 0`) → el modelo da el mismo peso a ambas.
- Zoom-out vs parecido: más cabeza/pelo = más contexto pero cara más chica = menos parecido. Punto medio: cabeza completa con pelo y hombros (preferencia de Sergio).
- Recorta fondos del panel de la persona → evita que se "cuele" (pasó 1 de 3 con seed 7).
- Prenda sola sobre fondo liso, sin persona.
- Evita referencias de cuerpo completo con pose sugerente → el filtro del Space puede rechazar o el modelo copia la pose. Usa recorte de cara.

**Plantilla de prompt**
```
Create a new single photo: the person from panel 1, keep their face exactly the same, wearing the {prenda} from panel 2, in the {lugar} from panel 3. {acción neutral}. Casual iPhone 12 photo, natural light, realistic skin, sharp detail. Use panel 1 for identity only. No panels, no numbers, no text.
```
Dos personas: `the man from panel 1 and the woman from panel 2, both keep their faces exactly the same, sitting together at the bar from panel 3, smart casual clothes…`

## 5. Aprendizaje de errores
- El código del bot añade automáticamente cada fallo a `04-ERRORES.md` como **E10, E11…** y cada intento a `05-REGISTRO.md` (solo metadatos, nunca la imagen).
- Rutina nocturna (~11 p. m. Hermosillo): si esos archivos no cambiaron, se detiene. Si cambiaron, AInfluencer convierte el error en regla y lo anota en `CHANGELOG.md`.
- **Error → regla**: (1) síntoma, (2) causa probada con A/B, (3) regla si/entonces, (4) dónde se aplica (paso/archivo), (5) prueba que lo confirma.

| ❌ por | Corrección (una por intento) |
|---|---|
| Cara distinta | volver a ref-1 / subir `--zoom`; "keep her face exactly the same" |
| Ojos de otro color | añadir "hazel eyes" |
| Aparece un teléfono | quitar "phone/selfie holding" |
| Fondo de la referencia se cuela | recortar más + "use panel 1 for identity only" |
| Piel plástica | "visible pores and freckles, slight grain" |
| Salen paneles/números | "no panels, no numbers, no text" |

## 6. Guía para el alumno (guion de coaching)
Hermes guía paso a paso; no avanza sin respuesta.
1. **Ficha del personaje** — "¿Nombre, edad (adulto, 21+), cabello, ojos, rasgos únicos (pecas, lunar), estilo de ropa?" → crea `CONTEXTO-<nombre>.md` como `CONTEXTO-VALERIA.md`.
2. **10–15 referencias** — "¿Ya tienes una foto base de la cara? ¿Original de IA o de una persona que te dio permiso por escrito?" → genera/elige 10–15 fotos con ropa: frente, 3/4, perfil, distintas luces y escenas.
3. **Cara principal** — "¿Cuál se parece más a como imaginas a tu personaje, frontal y bien iluminada?" → esa es `ref-1`.
4. **Técnica** — "¿Escena genérica o lugar/prenda exactos?" → A0 o C2 (§2).
5. **Iterar** — "Del 1 al 5, ¿qué tanto se parece? ¿Qué falla: cara, pelo, ojos, fondo?" → una corrección por intento.
6. **Aprobar** — "¿La marcas ✅ para tu set?" → guardar en `aprobadas/`.
7. **Set para LoRA (15–30)** — "¿Tenemos variedad de ángulos, luces y ropa? ¿Todas PNG a tamaño completo?" → al llegar a 15–30 ✅, listo para entrenar.

## 7. Reglas
- Este documento y sus ejemplos son **solo SFW, con ropa**.
- Solo personajes originales o personas reales **con consentimiento**; siempre adultos.
- Créditos de licencias: la foto de la Catedral de Hermosillo (`pruebas-modelo/multi-ref/lugar.jpg`) es de Wikimedia Commons, **CC BY 2.0**: dar crédito al autor al mostrarla en el curso.
- Nada de reenviar URLs temporales; nada de `dynamic_space`; nada de reinicios sin OK de Sergio.
