# 01 — Pipeline: 8 pasos con compuertas

Regla: **no se avanza si la compuerta no da ✅.** Máximo de reintentos de calidad: **N = 3**.

---
## Paso 1 — Entender la petición y clasificarla
- Lee la petición y extrae: escena, ropa, pose, cuántas fotos.
- Clasifica: `cambio-escena-ropa` | `pose-nueva` | `multi-referencia` | `fuera-de-alcance`.

**Compuerta 1:** ✅ escena + ropa + tipo definidos. ❌ Falta un dato → pregunta a Sergio *una* vez.
> Ejemplo: "Valeria en un café con suéter" → `cambio-escena-ropa`, escena=café, ropa=suéter beige.

## Paso 2 — Elegir técnica y modelo
| Tipo | Técnica (02-TECNICAS) | Modelo | Herramienta |
|---|---|---|---|
| escena nueva (default) | A0. Qwen 2.1 Studio | Qwen-Image 2.1 Studio | `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`) |
| pose nueva (leve) | B. Pose nueva | Qwen-Image 2.1 Studio con instrucción de pose | `imagen_kontext` → `imagen_confirmar` |
| lugar/prenda exactos, ropa nueva o varias fotos | C2. Hoja numerada | Qwen-Image 2.1 Studio | `imagen_kontext` (arma la hoja con `tools/armar_hoja.py`) → `imagen_confirmar` |
| cualquiera, cuando exista | D. LoRA Valeria | LoRA propia | (futuro) |

**Prohibido:** `dynamic_space`, el navegador, scripts por terminal y cualquier modelo que no sea Qwen 2.1 (4g).
**Compuerta 2:** ✅ técnica + modelo + herramienta anotados. ❌ La herramienta no existe → avisa, no improvises.

## Paso 3 — Cargar la referencia y confirmar que existe
- Ruta por defecto: `/opt/data/guia-imagen/personajes/<nombre>/ref/ref-1-calle.png`.
- Verifica: el archivo existe y pesa > 100 KB (`ls -l`).

**Compuerta 3:** ✅ "Referencia cargada: ref-1-calle.png (X KB)". ❌ No existe → 04-ERRORES §E2.

## Paso 4 — Armar el prompt con la plantilla
- Usa la plantilla de `03-PROMPTS.md` (A0: «Keep her face exactly the same…»; C2: «Exactly N people…» + cada panel por número).
- Parámetros Qwen 2.1: Edit an image, **Portrait · 3:4**, **40** pasos, seed **42** (fija para comparar).

**Compuerta 4:** ✅ prompt según la técnica (en C2, cada panel nombrado). ❌ → complétalo.

## Paso 4b — Confirmar con Sergio (obligatorio)
Manda el mensaje exacto de `SKILL-HERMES-FOTOS.md` §2 (referencias + modelo + prompt) con la hoja/referencia adjunta. **Sin OK no se genera.**
**Compuerta 4b:** ✅ Sergio respondió OK. ❌ pidió cambio → vuelve al Paso 3/4.

## Paso 5 — Generar y confirmar el archivo de salida
- Tras la confirmación válida, `imagen_confirmar(id, prompt)` genera con Qwen 2.1 (la salida vive en `/tmp`, se envía y se borra).

**Compuerta 5:** ✅ `ok:true`, ~864x1152. ❌ Error → el error exacto ya le llegó al dueño (§E5 si es cuota); preguntar qué cambiar, sin cambiar de modelo.

## Paso 6 — Control de calidad contra las referencias
Revisa la lista (con modelo de visión cuando exista; mientras, se pide confirmación a Sergio):

| Punto | Debe ser |
|---|---|
| Cara | Misma forma (no más delgada), mismos labios y nariz que ref-1 |
| Cabello | Rizos cobrizos, no lacio ni rubio |
| Pecas | Visibles en nariz y mejillas |
| Ojos | Avellana (no azul/gris) |
| Look iPhone | Luz natural, grano leve, sin piel plástica, mira a la lente |

Si falla, cambia **una sola cosa** por intento:
| Falla | Qué cambiar |
|---|---|
| Cara distinta / pose cambiada | Añade "same camera angle and framing"; quita verbos de acción |
| Mira hacia abajo | Añade "she looks straight into the lens" |
| Piel saturada / plástica | Baja guidance a 2.0; añade "realistic skin texture, slight grain" |
| Aparece un teléfono | Quita toda mención de "phone/selfie holding" |
| Ojos de otro color | Añade "hazel eyes" y vuelve a ref-1 como entrada |

**Compuerta 6:** ✅ los 5 puntos OK. ❌ y intento < 3 → vuelve al Paso 4. ❌ al 3.er intento → avisa a Sergio con el motivo.

## Paso 7 — Descargar local y enviar
- **Nunca** reenvíes URLs `*.hf.space` (son temporales y caducan). Descarga primero el archivo al disco.
- Envía el archivo local con `imagen_enviar(ruta_local)`.

**Compuerta 7:** ✅ la API responde `ok:true` / message_id. ❌ → 04-ERRORES §E4.

## Paso 8 — Registrar
- Añade una línea en el registro con el formato de `05-REGISTRO.md`.

**Compuerta 8:** ✅ línea escrita. Fin.

---
## Ejemplo completo (real, 31-oct)
1. Petición: "Valeria con vestido negro frente a la catedral de Hermosillo".
2. Tipo: lugar exacto → C2.
3. `imagen_kontext(referencias=["foto-1", "foto-2"], tipos=["ropa", "lugar"])` → el plugin arma la hoja (panel 1 = cara de `personajes/valeria/ref/`, 2 = vestido, 3 = catedral) y manda «Usaré estas referencias y el modelo Qwen-Image 2.1 Studio…».
4. Prompt C2 de `03-PROMPTS.md`. 4b. Sergio responde «ok» (verificado por el sistema).
5. `imagen_confirmar(id, "<prompt>")` → Qwen 2.1, seed 42; el pie de foto sale de la config real.
6. Sergio ✅ (seed 42). Seed 7 coló el restaurante → regla "recortar panel 1".
7. La foto ya llegó (imagen_confirmar la manda y la borra). 8. La fila en 05-REGISTRO es automática.
Evidencia: `../pruebas-modelo/multi-ref/qwen-hoja-A.png` (✅), `qwen-hoja-C.png`.

## Checklist rápido
- [ ] Tipo y técnica decididos con la tabla  - [ ] Referencia existe (>50 KB)
- [ ] Confirmación enviada y OK recibido      - [ ] Salida >200 KB guardada en local
- [ ] ✅/❌ de Sergio                            - [ ] Enviada con ruta local  - [ ] Registrada

## Solución de problemas
| Síntoma | Causa probable | Haz |
|---|---|---|
| `ERROR SIN CARA` / referencia no encontrada | falta la cara guardada | `ls -l /opt/data/guia-imagen/personajes/<nombre>/ref/` y pedir la foto de cara |
| Código de salida 3 | cuota ZeroGPU | avisar hora de reintento (E5) |
| Space caído | error del Space | mostrar el error exacto y preguntar qué cambiar; no ofrecer otro modelo (4g) |
| Imagen con paneles/números | prompt sin cierre | añadir "No panels, no numbers, no text" |
