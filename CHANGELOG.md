# CHANGELOG
Formato: versión · fecha · cambios. Lo más reciente arriba. Desde v4.5 vive en la raíz del repo (antes `docs/CHANGELOG.md`).

## v4.5 · 2026-11-01
- Revisión completa con checklist (flujo, nombres reales, solo Qwen, candado, confirmaciones, 4b–4i, almacenamiento, instalador, ES/EN, clase, sugerencias del sitio) y cierre de huecos:
  - **SKILL:** índice de reglas en §0b; confirmación válida y candado de 4h en el flujo; el control y el envío los hace `imagen_confirmar`; la tabla de reintentos ya no menciona el script; ranking renumerado; calibración solo fuera de producción; rutas de §6 a `personajes/<slug>/`; nota de la licencia de Qwen.
  - **README:** «Qué incluye» completo; entrevista con `REGLAS.md`; el modo imagen lo opera el dueño; 3 sesiones con dry-run, licencias, 4g/4h/4i; secciones de licencia y seguridad.
  - **EN:** instalación con dry-run y respaldo; política única; herramientas reales; sugerencias del sitio; licencia.
- `personajes/README.md` (índice de personajes y su bot). Cada personaje con `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `REGLAS.md`, `personaje.env.example` (bot propio, sin tokens ni IDs) y `ref/README.md` (qué fotos de cara poner; las fotos no se suben).
- Valeria como primer personaje, solo con la ficha pública. Plantilla actualizada. `.gitignore` ignora las fotos de `ref/`.
- `LICENSE` (MIT) y `CHANGELOG.md` en la raíz. `tests/verificar.sh` ampliado.

## Historial anterior
- 2026-10-31: prueba carro HD (8 intentos: 4 con el modelo de edición anterior, 2 Qwen-Image-Edit 2509/2511 fallidos por error del Space, 2 Qwen-Image 2.1 Studio). Nueva técnica por defecto: Qwen-Image 2.1 Studio con ref-1 (02-TECNICAS A0, 03-PROMPTS). El modelo de edición anterior quedó como alternativa (retirado en v4.2, regla 4g).
- 2026-10-31: técnica C2 hoja de referencias numerada (cara/ropa/lugar en 3 paneles) probada con Qwen 2.1: 3 hojas + 1 referencia sola. C2 gana cuando el lugar o la prenda deben ser exactos (02-TECNICAS C2, 03-PROMPTS).
- 2026-10-31: C2 con 2 personas (Sergio + Valeria en bar, Qwen 2.1, seeds 42/123): buen parecido de ambos; lecciones de tamaño de cara, zoom-out y referencia de cuerpo completo en 02-TECNICAS C2.
- 2026-10-31: SKILL-HERMES-FOTOS.md (orquestación, flujo con confirmación, calibración, C2, errores, guía del alumno, reglas). tools/armar_hoja.py (probado) y tools/qwen21_generar.py (reintentos, código 3 = cuota). Pipeline con Paso 4b y Qwen 2.1 por defecto; ampliados todos los .md con ejemplos, checklists y solución de problemas.
- 2026-10-31 20:50 · E11 añadido (vía prohibida + cuota sin verificar)
- 2026-11-01: v3. SKILL §0b con E27–E31 (hoja sin estirar, entrada Qwen 3:4 1152x1536 2 columnas sin relleno, «Exactly N people», una sola escena con 3 intentos, respaldo solo 1 persona (retirado en v4.2), «caras OK» verificado, mensaje neutral), cara propia siempre + refs del cliente encima, N fotos pedidas = N entregadas. armar_hoja.py v3 (--qwen34). Carpeta personajes/ (plantilla + Valeria). README ES/EN con entrevista, modos, clase en 3 sesiones y uso con Grok Bot.
- 2026-11-01: v4. Panel 1 = cara guardada (personajes/<nombre>/ref/), extras con rol (--extra ROL:RUTA), sin cara no se genera, confirmación cara + prenda, «varias» = 3 (máx. 4). referencias/ → ref/.
- 2026-11-01: v4.2 (Sergio). Reglas 4g (solo Qwen 2.1, sin otro modelo) y 4h (confirmaciones válidas, candado, 1 cara con 1 persona).
- 2026-11-01: v4.3. Nombres reales del plugin (`imagen_kontext` → `imagen_confirmar`, alias `imagen_qwen21`); «1 foto tal cual» solo si ES la cara del personaje; política única (servidor: vestido/bikini/lencería/sensual del personaje ficticio; desnudo/sexo a R2, que aún no existe); regla legal 4i; sin menciones de otros modelos en README/docs; `install.sh` con respaldo fechado y `--dry-run`; pendientes legales antes de R2 en el README; `tests/verificar.sh`.
- 2026-11-01: v4.4 (Sergio). La selfie del fan ya no se rechaza: entra con rol `persona` en un panel extra y el personaje sigue en el panel 1; con caras reales, solo vestido y no sensual. Contenido explícito con la cara de una persona real: no soportado. Términos y Condiciones del sitio, solo como sugerencia no canónica en el README.
