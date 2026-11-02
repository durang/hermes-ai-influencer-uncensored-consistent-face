# 04 — Errores conocidos y arreglos

| # | Error | Causa | Arreglo |
|---|---|---|---|
| E1 | Probaba varios modelos y Spaces al azar | Sin tabla de decisión | Paso 2: solo el modelo de la tabla. Nada de `dynamic_space` a prueba y error |
| E2 | No encontraba las referencias | El contenedor no ve `/home/ec2-user` | Usar `/opt/data/guia-imagen/personajes/valeria/ref/` (host: `/srv/hermes-ainfluencer/data/guia-imagen/`) |
| E3 | 404 / sin imagen de entrada con `dynamic_space` | `dynamic_space` no puede mandar la imagen de entrada | Usar el plugin: `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`) |
| E4 | `imagen_enviar` fallaba | Las URLs temporales `*.hf.space` caducan o no se pueden bajar | Descargar el archivo a disco local y enviar la ruta local (Paso 7) |
| E5 | "Quota exceeded" ZeroGPU | Cuota compartida entre Spaces | HF PRO ya está activo (más cuota). Si aun así se agota: mostrar el error exacto, esperar al reset y no cambiar de modelo (4g) |
| E6 | No puede comparar caras | No tiene modelo de visión | Mientras: pedir a Sergio ✅/❌ con la lista del Paso 6. Futuro: añadir modelo de visión |
| E7 | Cara más delgada, ojos azules | otro modelo, o la base demasiado lejos | img1 = base aprobada, otra semilla, máximo 5 (no cambiar de modelo) |
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

## E27 · C11 — Sin cara del cliente se usa la guardada (v5.4)
- **Regla:** el bot es el personaje (4f). Si el cliente no manda cara, img1 es `personajes/<nombre>/ref/cara-1.png`. Lo que manda el cliente se etiqueta `ropa`, `objeto` o `lugar`, nunca como cara.

## E28 · C12 — Una cara por persona; la entrada no es un collage (v5.4)
- **Regla:** una cara por persona. El Space recibe como mucho 3 imágenes sueltas. Si se arma una hoja solo para que la vea el dueño, es cuadrícula 3:4, sin relleno gris y sin estirar, y no se manda al modelo.

## E29 · C13 — El prompt no cierra en una sola foto (v5.4)
- **Regla:** el prompt lleva `Exactly N person(s). Single photo, one scene, no panels, no collage, no split. No panels, no numbers, no text.`
- El aviso al cliente sigue sin nombrar modelos ni cuota (§0b, punto 13).

## E30 · C14 — La salida no pasó la revisión (v5.4)
- **Se rechaza** si hay relleno plano, si la proporción no es 3:4, si hay costuras rectas, si la misma identidad sale 2 veces o más, o si el número de personas no es N.
- Cada rechazo es otra semilla, hasta 5. Si todos fallan, no se manda foto. «caras OK» solo si la revisión lo verificó.

## E31 · C15 — Se ofreció otro modelo (v5.4)
- **Regla:** solo Qwen 2.1, el Space `iccanobif/qwen21-nano-banana`. Sin modelo de respaldo (4g).

## E32 · C16 — «Varias» sin revisión por foto (v5.4)
- **Regla:** «varias fotos» = 3, máximo 4. Cada una pasa su propia revisión.

## E33 · El flujo real no repetía lo que funcionó en el script de prueba (1 nov 2026, C17)
- **Qué pasó:** el script (1 cara + camisa) dio al personaje con la camisa; el flujo real por Telegram con la misma camisa daba collage, 2 personas o una cara ajena.
- **Diferencias:** hoja con 2 caras de la misma persona en vez de 1; prompt del LLM con «several photos», paneles mezclados en la escena, sin identidad y sin cierre; oferta de otro modelo.
- **Regla:** 4l y §8 (C17). Desde v5.3 la entrada no es una hoja: img1 = base aprobada e img3 = prenda, en una sola llamada `/edit_multi`. Juez de visión, máximo 5 semillas. El chat queda bloqueado mientras genera y solo vale una confirmación por vista previa.

## E34 · Vista previa doble: el modelo repetía el mensaje del plugin (1 nov 2026, C18)
- **Qué pasó:** después de la vista previa del plugin, Hermes mandaba otro mensaje con su estilo repitiéndola («Te mandé la vista previa ✅… responde OK»), y al final otro «¡Listo! Te llegaron las 3 fotos…».
- **Regla:** 4m. SOUL: no repetir ni resumir lo que ya mandó el plugin; el resultado de la herramienta trae `ya_enviado_al_usuario: true` y `no_repetir`.

## E35 · No se mandan referencias sueltas ni una hoja (1 nov 2026, C19; retirado el método el 2 nov 2026, v5.3)
- **Qué pasó:** la vista previa llegaba en varios mensajes, o como una composición numerada, antes de la foto final.
- **Causa:** el plugin enviaba las referencias por separado o compuestas, y el modelo las recibía así.
- **Arreglo vigente:** no hay vista previa de referencias. `imagen_confirmar` llama una vez a `/edit_multi` (1 a 3 imágenes) o a `/generate` (ninguna). El juez corre antes de entregar. El cliente solo recibe la foto final.
- **Regla:** 4n.

## E36 · Cuerpo distinto de la hoja: busto menor o exagerado, chaqueta no pedida (2 nov 2026, C24)
Síntoma: con solo la cara como img1, el modelo cambia el cuerpo (busto más chico o exagerado) y a veces agrega una chaqueta.
Causa: la cara no fija el cuerpo y el juez solo revisaba la cara.
Arreglo: regla 4r. Hoja del personaje como img1 con sus medidas (privadas, en `perfil.json`), juez de cuerpo con tope en ambos sentidos contra el recorte de cuerpo de la hoja, línea «no extra clothing unless asked».
