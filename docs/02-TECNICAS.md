# 02 — Catálogo de técnicas

## A0. Qwen-Image 2.1 Studio (edición con referencia) — **técnica por defecto (desde 2026-10-31)**
- **Qué hace:** toma `ref-1-calle.png` como referencia y genera la escena nueva con la misma cara.
- **Cuándo:** casi siempre (café, carro, calle, gym, cena). Prompt simple y natural.
- **Modelo:** Space `assembledchaos/qwen-image-2-1-studio` (Qwen-Image 2.1 GGUF Q4_K_M), endpoint `/generate`, modo `Edit an image`.
- **Parámetros:** steps 40, seed 42 (randomize False), aspect `Portrait · 3:4` (864×1152) o `Square · 1:1` (1024×1024). ~25 s por imagen.
- **Python:** `Client('assembledchaos/qwen-image-2-1-studio', token=HF_TOKEN).predict(prompt, 'Edit an image', handle_file(ref), 'Portrait · 3:4', 40, 42, False, api_name='/generate')` → usar `r[1]` (PNG original).
- **Prueba carro (31-oct):** la cara más fiel a ref-1 (ojos avellana, labios entreabiertos, pecas, flequillo), luz natural creíble. Ganadora: `pruebas-modelo/carro-hd/qwen21-02-ref1-portrait.png`.

## B. Pose nueva (leve)
- **Qué hace:** A0 (Qwen 2.1) con una instrucción de pose suave ("turns her head slightly", "sitting at a table").
- **Cuándo:** se pide otra postura sin cambiar de persona.
- **Regla:** un solo cambio de pose a la vez; mantener "looks into the lens". Si la cara se pierde, vuelve a A0 sin pose y sube el tamaño de la cara.

## Ropa nueva o re-vestir
- **Cómo:** C2 con la prenda como panel extra (`ropa`) y la cara guardada en el panel 1. No hay otro modelo para "re-vestir" (4g).

## D. LoRA de Valeria (futuro)
- **Qué hace:** un modelo entrenado con 15–30 fotos de Valeria; genera desde texto con su cara.
- **Cuándo:** cuando esté entrenada; será la opción más consistente.
- **Requisito:** fotos a tamaño completo, PNG sin recomprimir.

## No recomendadas
- **PuLID:** genera desde cero; salió "otra persona parecida" con ojos azules.
- **Cualquier modelo que no sea Qwen 2.1:** retirado por la regla 4g (1-nov-2026).
- **Probar Spaces al azar:** gasta cuota y no deja aprendizaje.

## C2. Hoja de referencias numerada
- **Qué hace:** junta varias referencias en UNA hoja numerada (la de confirmación conserva la proporción de cada foto, E27; la entrada a Qwen es 3:4 de 1152x1536, E31) con números grandes en la esquina: 1 = cara (panel más grande), 2 = ropa sola sin persona, 3 = lugar. El prompt nombra cada panel. Sirve con modelos que aceptan una sola imagen (Qwen-Image 2.1 Studio).
- **Cómo:** armar la hoja con PIL (ejemplo: `pruebas-modelo/multi-ref/hoja-3-paneles-v2.png`), "Edit an image", Portrait 3:4, 40 pasos.
- **Resultado 31-oct (4 pruebas):** la cara se mantuvo bien en las 3 con hoja; el vestido negro salió en todas; el lugar (catedral + kiosco de Hermosillo) salió mucho más fiel que describiéndolo en texto. 1 de 3 (seed 7) mezcló el fondo del restaurante del panel 1 → recortar el panel 1 con poco fondo.
- **Veredicto:** usar C2 cuando el lugar o la ropa deben ser EXACTOS (lugar real, prenda concreta). Para escenas genéricas, A0 (una referencia + texto) es igual de buena y más simple. La cara pierde un poco de detalle porque el panel es más chico.
- **Lecciones C2 con 2 personas (31-oct, hoja `hoja-sergio-valeria-bar-v4.png`, seeds 42/123):**
  - Las 2 caras salieron muy parecidas en ambas seeds; ropa y bar del panel 3 respetados. Pero copió las expresiones serias de las referencias e ignoró "smiling" → usar referencias con la expresión deseada o repetir "big natural smile" al inicio del prompt.
  - Las caras deben ir GRANDES y del MISMO tamaño; la persona con panel más chico pierde parecido.
  - Zoom-out (cabeza + hombros con letterbox) da contexto de pelo y cuerpo, pero la cara queda ~1/3 del panel y baja el detalle. Punto medio: cabeza completa ocupando ~60% del panel.
  - Referencia de cuerpo completo o sugerente: el modelo tiende a copiar pose y escote, y algunos filtros pueden rechazarla. Para identidad usar recorte de cara+pelo y describir la ropa en texto.

### C2 — ejecución
```
python3 /opt/data/guia-imagen/procedimiento-imagen/tools/armar_hoja.py SALIDA.png panel1 panel2 panel3 [--lugar L] [--recibidas N] [--qwen34 ENTRADA34.png]
```
- `--zoom 1.3–1.6` acerca solo el panel principal (quita fondo y cuerpo; ver `ejemplos/hoja-C2-ejemplo-zoom16.png`).
- v3: cada panel conserva su proporción (E27) y `--qwen34` arma la entrada 3:4 1152x1536 en 2 columnas sin relleno (E31). `--principal` ya no se usa.
- **Por qué:** el modelo reparte "atención" según el área; cara grande = más parecido.

## Árbol de decisión (si/entonces)
- SI no hay foto nueva y la escena es genérica → **A0**.
- SI hay que cambiar la ropa → **C2** con la prenda como panel extra.
- SI lugar o prenda deben ser exactos, o Sergio manda varias fotos → **C2**.
- SI A0 falla 3 veces por la cara → hoja simple (1 cara grande + prenda) y, si sigue fallando, error exacto y preguntar (4g).
- SI ya existe la LoRA → **D**.
