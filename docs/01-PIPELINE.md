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
| escena nueva (default) | A0. Qwen 2.1 Studio | Qwen-Image 2.1 Studio | `imagen_qwen21` o `python3 /opt/data/guia-imagen/procedimiento-imagen/tools/qwen21_generar.py` |
| re-vestir foto existente | A. Edición Kontext | FLUX.1 Kontext [dev] | `imagen_kontext` (respaldo) |
| pose-nueva (leve) | B. Pose nueva | Kontext dev con prompt de pose | `imagen_kontext` |
| lugar/prenda exactos o varias fotos | C2. Hoja numerada | Qwen 2.1 Studio | `tools/armar_hoja.py` + `qwen21_generar.py` |
| cualquiera, cuando exista | D. LoRA Valeria | LoRA propia | (futuro) |

**Prohibido:** probar Spaces al azar con `dynamic_space`. Solo el modelo de la tabla.
**Compuerta 2:** ✅ técnica + modelo + herramienta anotados. ❌ La herramienta no existe → avisa, no improvises.

## Paso 3 — Cargar la referencia y confirmar que existe
- Ruta por defecto: `/opt/data/guia-imagen/referencias/ref-1-calle.png`.
- Verifica: el archivo existe y pesa > 100 KB (`ls -l`).

**Compuerta 3:** ✅ "Referencia cargada: ref-1-calle.png (X KB)". ❌ No existe → 04-ERRORES §E2.

## Paso 4 — Armar el prompt con la plantilla
- Usa la plantilla de `03-PROMPTS.md`: bloque de identidad + ropa + escena + cámara + luz.
- Parámetros Kontext: guidance **2.5**, pasos **28**, seed **42** (fija para comparar).

**Compuerta 4:** ✅ los 5 bloques presentes y la frase "keep her face … exactly identical". ❌ Falta un bloque → complétalo.

## Paso 4b — Confirmar con Sergio (obligatorio)
Manda el mensaje exacto de `SKILL-HERMES-FOTOS.md` §2 (referencias + modelo + prompt) con la hoja/referencia adjunta. **Sin OK no se genera.**
**Compuerta 4b:** ✅ Sergio respondió OK. ❌ pidió cambio → vuelve al Paso 3/4.

## Paso 5 — Generar y confirmar el archivo de salida
- Llama a `imagen_kontext(ref, prompt, guidance=2.5, steps=28, seed=42)`.
- Guarda en `/opt/data/salidas/AAAAMMDD-HHMM-escena-intento.png`.

**Compuerta 5:** ✅ archivo existe, > 200 KB, ~880x1168. ❌ Error / cuota agotada → 04-ERRORES §E1, §E5.

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
3. `python3 tools/armar_hoja.py /opt/data/salidas/hoja-catedral.png referencias/ref-12-cena-vino.png vestido-negro.png lugar.jpg --zoom 1.5`
4. Prompt C2 de `03-PROMPTS.md`. 4b. Confirmación → OK.
5. `qwen21_generar.py hoja-catedral.png "<prompt>" salidas/20261031-2010-catedral-1.png --seed 42`
6. Sergio ✅ (seed 42). Seed 7 coló el restaurante → regla "recortar panel 1".
7. `imagen_enviar` → ok:true. 8. Línea en el registro.
Evidencia: `../pruebas-modelo/multi-ref/qwen-hoja-A.png` (✅), `qwen-hoja-C.png`.

## Checklist rápido
- [ ] Tipo y técnica decididos con la tabla  - [ ] Referencia existe (>50 KB)
- [ ] Confirmación enviada y OK recibido      - [ ] Salida >200 KB guardada en local
- [ ] ✅/❌ de Sergio                            - [ ] Enviada con ruta local  - [ ] Registrada

## Solución de problemas
| Síntoma | Causa probable | Haz |
|---|---|---|
| `ERROR E2` del script | ruta mal / archivo vacío | `ls -l /opt/data/guia-imagen/referencias/` |
| Código de salida 3 | cuota ZeroGPU | avisar hora de reintento (E5) |
| Código 2 | Space caído | preguntar si usar Kontext |
| Imagen con paneles/números | prompt sin cierre | añadir "No panels, no numbers, no text" |
