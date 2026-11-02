# 04 — Errores conocidos y arreglos

| # | Error | Causa | Arreglo |
|---|---|---|---|
| E1 | Probaba varios modelos y Spaces al azar | Sin tabla de decisión | Paso 2: solo el modelo de la tabla. Nada de `dynamic_space` a prueba y error |
| E2 | No encontraba las referencias | El contenedor no ve `/home/ec2-user` | Usar `/opt/data/guia-imagen/personajes/valeria/ref/` (host: `/srv/hermes-ainfluencer/data/guia-imagen/`) |
| E3 | 404 / sin imagen de entrada con `dynamic_space` | `dynamic_space` no puede mandar la imagen de entrada | Usar el plugin: `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`) |
| E4 | `imagen_enviar` fallaba | Las URLs temporales `*.hf.space` caducan o no se pueden bajar | Descargar el archivo a disco local y enviar la ruta local (Paso 7) |
| E5 | "Quota exceeded" ZeroGPU | Cuota compartida entre Spaces | HF PRO ya está activo (más cuota). Si aun así se agota: mostrar el error exacto, esperar al reset y no cambiar de modelo (4g) |
| E6 | No puede comparar caras | No tiene modelo de visión | Mientras: pedir a Sergio ✅/❌ con la lista del Paso 6. Futuro: añadir modelo de visión |
| E7 | Cara más delgada, ojos azules | otro modelo, o la base demasiado lejos | img1 = base aprobada, otra semilla, máximo 3 (no cambiar de modelo) |
| E8 | Aparece un teléfono o mira abajo | Prompt describe el selfie | Quitar "phone"; añadir "looks straight into the lens" |
| E9 | "maybe not safe" | Filtro propio del Space | PRO no lo quita; revisar el prompt (palabras) o cambiar proveedor |

## Errores de referencia (31-oct; el arreglo vigente es v5.3)
| # | Síntoma | Causa | Regla |
|---|---|---|---|
| E7b | Fondo de la referencia en la foto final | la base trae demasiado fondo | otra semilla y "keep the face only"; no se recorta a mano ni se arma una hoja |
| E7c | La segunda cara se parece menos | la foto de esa persona es lejana o hay más de una | img2 = una sola foto, cabeza con pelo y hombros |
| E7d | Riesgo de filtro o pose copiada | referencia de cuerpo completo con pose sugerente | usar recorte de cara |

## Cómo entran los nuevos (E10+)
El código de Hermes agrega una fila automáticamente: `| E{n} | síntoma | causa (si se sabe) | pendiente |`. La rutina nocturna completa la causa y la regla, y anota el cambio en `CHANGELOG.md`.

## E11 · Hermes usó dynamic_space/navegador y reportó cuota agotada sin verificar (31 oct 2026, 20:39–20:45)
- **Qué pasó:** después del reinicio, Hermes siguió con `dynamic_space` (la referencia no se subió, salió otra cara), propuso usar su Chromium headless y luego dijo «se agotó la cuota ZeroGPU» cuando HF marcaba 26.8/40 min y $2 de saldo.
- **Regla:** la única vía para generar es `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`; Qwen 2.1 con handle_file + HF_TOKEN de iccanobif). Solo Qwen 2.1 (4g). `tools/qwen21_generar.py` es solo calibración manual en el host. `dynamic_space` y el navegador están PROHIBIDOS para imagen.
- **Antes de decir "sin cuota":** mostrar el error exacto de la API y revisar https://huggingface.co/settings/billing. Nunca proponer pagar ni cambiar de proveedor sin ese dato.

## E33 · El flujo real no repetía lo que funcionó en el script de prueba (1 nov 2026, C17)
- **Qué pasó:** el script (1 cara + camisa) dio al personaje con la camisa; el flujo real por Telegram con la misma camisa daba collage, 2 personas o una cara ajena.
- **Diferencias:** hoja con 2 caras de la misma persona en vez de 1; prompt del LLM con «several photos», paneles mezclados en la escena, sin identidad y sin cierre; oferta de otro modelo.
- **Regla:** 4l. Desde v5.3 la entrada no es una hoja: img1 = base aprobada e img3 = prenda, en una sola llamada `/edit_multi`. Juez de visión y como mucho 3 semillas. Candado por chat y confirmación idempotente.

## E34 · Vista previa doble: el modelo repetía el mensaje del plugin (1 nov 2026, C18)
- **Qué pasó:** después de la vista previa del plugin, Hermes mandaba otro mensaje con su estilo repitiéndola («Te mandé la vista previa ✅… responde OK»), y al final otro «¡Listo! Te llegaron las 3 fotos…».
- **Regla:** 4m. SOUL: no repetir ni resumir lo que ya mandó el plugin; el resultado de la herramienta trae `ya_enviado_al_usuario: true` y `no_repetir`.

## E35 · No se mandan referencias sueltas ni una hoja (1 nov 2026, C19; retirado el método el 2 nov 2026, v5.3)
- **Qué pasó:** la vista previa llegaba en varios mensajes, o como una composición numerada, antes de la foto final.
- **Causa:** el plugin enviaba las referencias por separado o compuestas, y el modelo las recibía así.
- **Arreglo vigente:** no hay vista previa de referencias. `imagen_confirmar` llama una vez a `/edit_multi` (1 a 3 imágenes) o a `/generate` (ninguna). El juez corre antes de entregar. El cliente solo recibe la foto final.
- **Regla:** 4n.
