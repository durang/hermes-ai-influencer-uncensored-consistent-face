# 04 — Errores conocidos y arreglos

| # | Error | Causa | Arreglo |
|---|---|---|---|
| E1 | Probaba varios modelos y Spaces al azar | Sin tabla de decisión | Paso 2: solo el modelo de la tabla. Nada de `dynamic_space` a prueba y error |
| E2 | No encontraba las referencias | El contenedor no ve `/home/ec2-user` | Usar `/opt/data/guia-imagen/personajes/valeria/ref/` (host: `/srv/hermes-ainfluencer/data/guia-imagen/`) |
| E3 | 404 / sin imagen de entrada con `dynamic_space` | `dynamic_space` no puede mandar la imagen de entrada | Usar el plugin: `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`) |
| E4 | `imagen_enviar` fallaba | Las URLs temporales `*.hf.space` caducan o no se pueden bajar | Descargar el archivo a disco local y enviar la ruta local (Paso 7) |
| E5 | "Quota exceeded" ZeroGPU | Cuota compartida entre Spaces | HF PRO ya está activo (más cuota). Si aun así se agota: mostrar el error exacto, esperar al reset y no cambiar de modelo (4g) |
| E6 | No puede comparar caras | No tiene modelo de visión | Mientras: pedir a Sergio ✅/❌ con la lista del Paso 6. Futuro: añadir modelo de visión |
| E7 | Cara más delgada, ojos azules | PuLID / panel de cara chico | A0 con ref-1 y la cara grande en el panel 1 (no cambiar de modelo) |
| E8 | Aparece un teléfono o mira abajo | Prompt describe el selfie | Quitar "phone"; añadir "looks straight into the lens" |
| E9 | "maybe not safe" | Filtro propio del Space | PRO no lo quita; revisar el prompt (palabras) o cambiar proveedor |

## Errores aprendidos con C2 (31-oct)
| # | Síntoma | Causa | Regla |
|---|---|---|---|
| E7b | Fondo del restaurante en la foto final | panel 1 con mucho fondo | `--zoom 1.5` + "use panel 1 for identity only" |
| E7c | La cara de Sergio se parece menos | panel muy alejado | cabeza + pelo + hombros, no más lejos |
| E7d | Riesgo de filtro o pose copiada | referencia de cuerpo completo con pose sugerente | usar recorte de cara |

## Cómo entran los nuevos (E10+)
El código de Hermes agrega una fila automáticamente: `| E{n} | síntoma | causa (si se sabe) | pendiente |`. La rutina nocturna completa la causa y la regla, y anota el cambio en `CHANGELOG.md`.

## E11 · Hermes usó dynamic_space/navegador y reportó cuota agotada sin verificar (31 oct 2026, 20:39–20:45)
- **Qué pasó:** después del reinicio, Hermes siguió con `dynamic_space` (la referencia no se subió, salió otra cara), propuso usar su Chromium headless y luego dijo «se agotó la cuota ZeroGPU» cuando HF marcaba 26.8/40 min y $2 de saldo.
- **Regla:** la única vía para generar es `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`; Qwen 2.1 con handle_file + HF_TOKEN de iccanobif). Solo Qwen 2.1 (4g). `tools/qwen21_generar.py` es solo calibración manual en el host. `dynamic_space` y el navegador están PROHIBIDOS para imagen.
- **Antes de decir "sin cuota":** mostrar el error exacto de la API y revisar https://huggingface.co/settings/billing. Nunca proponer pagar ni cambiar de proveedor sin ese dato.
