# CHANGELOG

- 2026-10-31: prueba carro HD (8 intentos: 4 Kontext, 2 Qwen-Image-Edit 2509/2511 fallidos por error del Space, 2 Qwen-Image 2.1 Studio). Nueva técnica por defecto: Qwen-Image 2.1 Studio con ref-1 (02-TECNICAS A0, 03-PROMPTS). Kontext queda como alternativa para re-vestir fotos existentes.
- 2026-10-31: técnica C2 hoja de referencias numerada (cara/ropa/lugar en 3 paneles) probada con Qwen 2.1: 3 hojas + 1 referencia sola. C2 gana cuando el lugar o la prenda deben ser exactos (02-TECNICAS C2, 03-PROMPTS).
- 2026-10-31: C2 con 2 personas (Sergio + Valeria en bar, Qwen 2.1, seeds 42/123): buen parecido de ambos; lecciones de tamaño de cara, zoom-out y referencia de cuerpo completo en 02-TECNICAS C2.
- 2026-10-31: SKILL-HERMES-FOTOS.md (orquestación, flujo con confirmación, calibración, C2, errores, guía del alumno, reglas). tools/armar_hoja.py (probado) y tools/qwen21_generar.py (reintentos, código 3 = cuota). Pipeline con Paso 4b y Qwen 2.1 por defecto; ampliados todos los .md con ejemplos, checklists y solución de problemas.
- 2026-10-31 20:50 · E11 añadido (vía prohibida + cuota sin verificar)
