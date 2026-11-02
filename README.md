# Hermes AI Influencer · Uncensored Consistent Face

**La misma cara en cada foto. Un bot de Telegram que chatea, vende y aprende solo.** Skill sin censura (NSFW) para Hermes y Grok Bot: crea tu personaje de IA, conecta su bot y genera fotos consistentes con Qwen-Image 2.1.

- 🎯 **Cara consistente:** hoja de referencias numerada (panel 1 = cara guardada), conteo de caras y anti-collage con reintentos.
- 💬 **Bot listo para vender:** chat con fans, modo jefe para el dueño, precios y confirmación antes de generar.
- 🧠 **Autoaprendizaje canónico:** Hermes registra errores y aciertos y los propone en `PROPUESTAS.md`; Grok Bot revisa y decide qué se sube.
- 🔞 **NSFW, con precisión:** hoy el servidor genera vestido, bikini, lencería y sensual del personaje ficticio adulto. El contenido explícito irá a almacenamiento privado Cloudflare R2, **que todavía no está construido**. Nunca contenido explícito con la cara de una persona real.
- 🧩 **Una carpeta y un bot por personaje**, instalador con respaldo y `--dry-run`, docs en ES/EN y pruebas (`tests/verificar.sh`).

**Secret Fans Academia IA** · Skill para que un bot de Telegram (Hermes u otro) maneje un personaje de IA: chatear con fans, recibir órdenes del dueño y generar **fotos con la misma cara** que las referencias. Ejemplo incluido: **Valeria**, personaje ficticio adulto (26 años, pelirroja). Todo el contenido del repo es no explícito.

> English version below · [English](#english)

## Qué incluye
| Ruta | Para qué |
|---|---|
| `skill/SKILL.md` | Lo que el bot ejecuta: reglas duras §0b, flujo con confirmación, hoja C2, errores |
| `personajes/README.md` | Índice de personajes y su bot de Telegram |
| `personajes/_plantilla/` | Salida de la entrevista: `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `REGLAS.md`, `personaje.env.example`, `ref/README.md` |
| `personajes/valeria/` | Primer personaje: ficha pública de Valeria (sin fotos, tokens ni IDs) |
| `tools/armar_hoja.py` | Hoja numerada (proporción original) + entrada Qwen 3:4 1152x1536 en 2 columnas sin relleno (`--qwen34`), `--lugar`, `--recibidas N` |
| `tools/qwen21_generar.py` | Prueba manual de Qwen-Image 2.1 en el host (calibración). **El bot no lo usa** |
| `docs/` | Pipeline, técnicas, prompts, errores (E1–E31), registro |
| `install.sh` | Instala y detecta el entorno; respalda con fecha antes de pisar y tiene `--dry-run` |
| `tests/verificar.sh` | Pruebas del repo (instalador, docs, personajes, hoja) |
| `PROPUESTAS.md` | Autoaprendizaje: propuestas de Hermes que Grok Bot revisa |
| `CHANGELOG.md` · `LICENSE` | Historial de versiones · Licencia MIT |

## Instalar
```bash
git clone git@github.com:<usuario>/hermes-ai-influencer-uncensored-consistent-face.git
cd hermes-ai-influencer-uncensored-consistent-face
./install.sh --dry-run /opt/data/guia-imagen   # primero: muestra qué haría, sin tocar nada
./install.sh /opt/data/guia-imagen             # respalda en respaldos/AAAAMMDD-HHMMSS/ lo que va a pisar y luego instala
cp /opt/data/guia-imagen/.env.example /opt/data/guia-imagen/.env   # pon HF_TOKEN y TELEGRAM_TOKEN_<NOMBRE> (nunca en git)
pip install gradio_client pillow
```
`install.sh` detecta el entorno y escribe `config.env`:
| Entorno | Detección | `ALMACEN_ADULTO` |
|---|---|---|
| Servidor / VPS (Cerebro Central en Contabo) | `CEREBRO_CENTRAL=1`, `/etc/cerebro-central` o proveedor/VM | `r2-privado` |
| Tu computadora | lo demás | `local` |

Forzar: `MODO_ENTORNO=servidor|local ./install.sh DESTINO`.

**Respaldo y dry-run:** antes de sobrescribir `skill/`, `tools/`, `docs/` (salvo 04-ERRORES y 05-REGISTRO, que nunca se pisan) o `config.env`, el instalador copia lo existente a `DESTINO/respaldos/AAAAMMDD-HHMMSS/` y al final dice cómo volver. `personajes/`, `.env` y `personaje.env` nunca se sobrescriben. Con `--dry-run` solo imprime cada paso.
**Política del servidor:** en el disco solo bikini, lencería o sensual sin desnudo. Desnudo/sexual va a Cloudflare R2 privado — **TODO: la subida a R2 aún no está construida**; mientras tanto no se genera en el servidor.

## Entrevista inicial (crear un personaje)
El bot pregunta al dueño, en orden, y llena `personajes/<nombre>/`:
1. Nombre, edad (21+), origen e historia corta → `PERSONAJE.md`
2. Apariencia (cabello, ojos, rasgos únicos, estilo) → `PERSONAJE.md`
3. Personalidad, tono, emojis, idiomas → `SOUL.md`
4. Catálogo y precios → `PRECIOS.md`
5. Reglas del personaje (edad, divulgación de IA, política de contenido, regla 4i) → `REGLAS.md`
6. Fotos de referencia (cara frontal primero; guía en `ref/README.md`, no se suben al repo) → `ref/`
7. Bot de Telegram del personaje (creado con @BotFather; token solo en `.env`) → fila en `personajes/README.md`

## Una carpeta y un bot por personaje
```
personajes/
  README.md  índice: personaje → bot de Telegram
  _plantilla/
  valeria/   PERSONAJE.md SOUL.md PRECIOS.md REGLAS.md personaje.env.example ref/README.md
  <otro>/    …
```
Cada personaje tiene **su propio bot de Telegram** (`TELEGRAM_TOKEN_VALERIA`, `TELEGRAM_TOKEN_<OTRO>`), así sus chats, memoria y fotos no se mezclan.

## Los tres modos
| Modo | Quién | Qué hace |
|---|---|---|
| **Modo cliente (chat)** | Fans | Conversa con la voz de `SOUL.md`, vende según `PRECIOS.md`, nunca habla de token/GPU/API/modelos |
| **Modo jefe** | Dueño (su ID de Telegram) | Da órdenes: cambiar precios, aprobar fotos, ver errores, pedir reportes |
| **Modo imagen** | Dueño (los pedidos de fans, incluida su selfie, llegan al dueño y él los aprueba) | Sigue `skill/SKILL.md`: confirma refs + modelo, espera la confirmación válida (4h), genera, valida, entrega |

## Reglas clave de fotos (resumen de SKILL §0b)
1. Confirma «Usaré estas referencias y el modelo X» y espera OK.
2. **Panel 1 = siempre la cara guardada** de `personajes/<nombre>/ref/`, nunca una prenda. Las fotos del cliente son paneles extra con rol (`ropa`, `objeto`, `lugar`, `persona`) y el prompt dice p. ej. «panel 2 = shirt to wear». Sin foto de cara guardada no se genera: se pide primero. La confirmación muestra cara + prenda.
3. Cuenta las fotos recibidas; nunca descartes una en silencio. El lugar va en su propio panel.
4. Misma ropa por persona salvo que se indique otra.
5. Hoja sin estirar; Qwen recibe rejilla 3:4 1152x1536, 2 columnas, sin relleno gris.
6. El prompt empieza con `Exactly N people, each appears only once` y dice qué panel es quién.
7. Una sola escena: se rechaza collage, copia de la hoja, persona duplicada o conteo distinto; hasta 3 intentos con seed nueva.
8. «Varias» fotos = 3 (máx. 4) con poses y seeds distintas; cada una pasa el control de número de personas.
9. **Solo Qwen 2.1** (regla 4g), sin modelo de respaldo. «Caras OK» solo si se verificó.
10. Única vía: `imagen_kontext` → `imagen_confirmar` (alias `imagen_qwen21`); nunca `dynamic_space`, navegador ni scripts por terminal; revisa el error exacto antes de hablar de cuota.
11. **«1 foto tal cual» solo cuando esa foto ES la cara del personaje**; cualquier otra foto es un panel extra y el panel 1 es la cara guardada.
12. **Regla legal (4i):** lo sensual (bikini, lencería) y R2 solo con el personaje ficticio. La cara de una persona real (un tercero o la selfie del fan) entra con rol `persona` en un panel extra, con el personaje en el panel 1, y solo vale **vestida y no sensual**. **No soportado:** contenido explícito (desnudo o sexo) con la cara de una persona real.

13. **Verificador de detalles y afirmaciones (4j):** antes de responder o confirmar, Hermes revisa que lo que afirma (precios, cantidad de fotos, referencias usadas, estado de la generación, rasgos del personaje) coincida con los datos y archivos reales; si no coincide, lo corrige y no inventa.
14. **Aviso de licencia (4k):** Qwen-Image 2.1 va bajo licencia de investigación y el uso es responsabilidad de quien lo use; Hermes lo dice una sola vez por conversación y lo repite solo si se lo preguntan o hace falta.

### Herramientas del plugin (nombres reales)
| Herramienta | Qué hace |
|---|---|
| `imagen_kontext` | Paso 1: arma la hoja y manda «Usaré estas referencias y el modelo Qwen-Image 2.1 Studio…». No genera |
| `imagen_confirmar` | Paso 2: genera con Qwen 2.1 solo tras una confirmación válida del dueño (4h) |
| `imagen_cancelar` / `imagen_enviar` | Cancelar / reenviar solo lo que produjo `imagen_confirmar` |

`imagen_qwen21` es un **alias conceptual** usado en la doc (la generación es con Qwen 2.1). El nombre interno `imagen_kontext` es histórico (el plugin nació con otro modelo) y se conserva por compatibilidad: hoy no usa ningún otro modelo.

### Política única de contenido
En el servidor (Contabo / Cerebro Central): **vestido, bikini, lencería y sensual, solo del personaje ficticio**. **Desnudo y sexo van a Cloudflare R2, que todavía no existe**: mientras no exista, no se generan.

## Sitio web del personaje (sugerencias)
> Ayuda **no canónica**: no es una regla del skill y no bloquea nada.

- **Recordatorio:** cuando se arme el sitio de Valeria (o de otro personaje), quien lo haga debe revisar `skill/SKILL.md` y poner una página de **Términos y Condiciones** en la que la responsabilidad del material que envía el fan (por ejemplo, su selfie) sea del fan.
- **El límite se mantiene** aunque haya términos aceptados: nada explícito con la cara de una persona real.

## Pendientes antes de construir R2 (revisión del 1-nov-2026)
> **No frena lo vestido** en lo que toca a las reglas de contenido. **Ojo con la licencia** (punto 3): esa sí afecta cualquier uso comercial, vestido incluido.

1. **Política de contenido de Hugging Face** (https://huggingface.co/content-policy, vigente desde el 10-abr-2025):
   - Prohíbe *"Sexual Content used for harassment, bullying, or created without explicit consent"* y *"Underage nudity or any sexual Content involving minors"*.
   - Pide marcar el contenido adulto como *"Not For All Audiences"* (NFAA).
   - No trata directamente la desnudez adulta ni los deepfakes en Spaces de terceros.
   - Consecuencia: **nada sexual con caras reales** (regla 4i) y nada que sugiera minoría de edad.
2. **El Space `assembledchaos/qwen-image-2-1-studio`** (leído de su README y su `app.py`):
   - Es un Space **comunitario, no oficial**. Corre **`abenzerps/Qwen-Image-2.1-Uncensored-GGUF`** (Q4_K_M), una cuantización "Uncensored" de terceros, y el código **no tiene filtro de seguridad**.
   - No publica términos de uso propios.
   - Usa la cuota diaria ZeroGPU de quien lo llama.
   - Las fotos subidas quedan en el servidor del Space hasta 24 h (caché de Gradio). Ojo con subir caras de personas reales.
   - Puede cambiar o desaparecer sin aviso, así que conviene fijar la revisión o tener un Space propio.
3. **Licencia del modelo: Qwen RESEARCH LICENSE AGREEMENT** (`Qwen/Qwen-Image-2.1`, publicada el 20-sep-2026):
   - Solo permite uso **NO comercial ("research or evaluation purposes only")**. Para uso comercial hay que pedir una licencia aparte a `model-business@notice.qwencloud.com`.
   - Si las salidas se usan para entrenar o mejorar un modelo que se distribuye (por ejemplo, una LoRA de Valeria), hay que mostrar *"Built with Qwen"*.
   - Ley aplicable: China; tribunales de Hangzhou.
   - **Vender o promocionar con estas fotos (Fanvue, redes, el curso) es uso comercial**: hace falta la licencia comercial o cambiar a un modelo con licencia comercial. Esto lo decide Sergio con su abogado.
4. **Antes de construir R2 (desnudo y sexo):** licencia comercial resuelta; un modelo y un proveedor cuyas reglas permitan ese contenido (este Space público no es el lugar); verificación de edad del lado del fan; etiqueta de IA; **cero caras reales** (4i); términos de Cloudflare revisados; revisión legal.

## Ejemplo con Valeria
```bash
R=personajes/valeria/ref
python3 tools/armar_hoja.py salidas/hoja-cafe.png --cara $R/ref-1-calle.png \
  --extra ropa:camisa-cliente.jpg --extra lugar:cafe.jpg --recibidas 2 --qwen34 salidas/entrada34-cafe.png
```
Confirmación: «Recibí 2 imágenes: 1=camisa, 2=café. Usaré la cara de Valeria (panel 1), la camisa (panel 2), el café (panel 3) y el modelo Qwen 2.1. ¿OK?»
Prompt: `Exactly 1 person, appears only once: panel 1 = Valeria's face (identity); panel 2 = shirt to wear; panel 3 = the place. The numbered sheet is ONLY a reference: generate ONE brand-new full-frame photograph…`

## Clase en 3 sesiones
- **Sesión 1 — Preparación, permisos e instalación:** cuentas (Hugging Face, Telegram/@BotFather, servidor o PC); tokens solo en `.env`; `./install.sh --dry-run` y luego `./install.sh` (respaldo con fecha); detección del entorno; **política única de contenido** y licencias (Qwen RESEARCH LICENSE: uso no comercial; ver «Pendientes antes de construir R2»).
- **Sesión 2 — Entrevista del personaje y modos:** copiar `personajes/_plantilla/`; llenar `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md` y `REGLAS.md` (edad, divulgación de IA, regla 4i); agregar el personaje y su bot a `personajes/README.md`; probar modo cliente, modo jefe y modo imagen.
- **Sesión 3 — Fotos consistentes y un bot por personaje:** referencias en `ref/` (según `ref/README.md`); hoja numerada (panel 1 = cara guardada); confirmación válida y candado (4h); solo Qwen 2.1 (4g); validación (una escena, conteo de caras); registro de errores; conectar el bot de Telegram del personaje.

## Autoaprendizaje (flujo canónico)
1. **Hermes registra**: cada error (`docs/04-ERRORES.md`) y cada acierto que valga la pena repetir.
2. **Hermes propone**: añade una entrada a `PROPUESTAS.md` con la plantilla (qué pasó, evidencia, cambio propuesto, archivo). Hermes **no** edita el skill ni sube nada por su cuenta.
3. **Grok Bot revisa y decide** (forma canónica): aprueba → aplica el cambio, corre `tests/verificar.sh`, anota en `CHANGELOG.md` y sube al repo; rechaza o pide más evidencia → lo marca en la entrada. Sin Grok Bot, decide otro revisor (otro agente o una persona).
4. **Rutina nocturna de AInfluencer** (~11 p. m. Hermosillo): lee `PROPUESTAS.md` y los registros; si no hay nada nuevo, se detiene; si hay, revisa con este flujo.
Lo aprendido nunca cambia la política de contenido ni las reglas legales (4i) sin el OK del dueño.

## Usarlo con Grok Bot
Grok Bot puede: hacer la entrevista contigo y escribir la carpeta del personaje; armar y revisar hojas con `armar_hoja.py`; documentar errores nuevos en `docs/04-ERRORES.md` y correr la revisión nocturna. Los cambios en el servidor (contenedor, plugins, reinicios) los hace el bot del servidor (Cerebro Central) **solo con el OK del dueño**. Pídele, por ejemplo: «Crea el personaje Ana con la plantilla» o «Revisa por qué la última foto salió como collage».

## Seguridad
Sin secretos en el repo (`.env` está en `.gitignore`): ni tokens ni IDs de Telegram, ni fotos reales (`personajes/*/ref/` solo guarda su README), ni datos de fans. Solo personajes adultos ficticios o personas reales con consentimiento escrito.

## Aviso de licencia del modelo
> **Qwen-Image 2.1** se usa bajo su **licencia de investigación** (Qwen RESEARCH LICENSE). El uso es **responsabilidad de quien lo use**. Hermes da este aviso **una sola vez por conversación** con el dueño (regla 4k) y solo lo repite si se lo preguntan o si hace falta.

## Licencia
[MIT](LICENSE) para el código y la documentación de este repo. **No cubre** el modelo Qwen-Image 2.1 (Qwen RESEARCH LICENSE, solo uso no comercial) ni fotos de terceros. El nombre y la apariencia de los personajes de ejemplo (Valeria) se incluyen como ficha pública; si el dueño quiere reservarlos como marca, tiene que excluirlos de la MIT antes de publicar el repo.

---
<a id="english"></a>

**Self-learning (canonical):** Hermes logs errors and wins and proposes them in `PROPUESTAS.md` (what happened, evidence, proposed change, file). Grok Bot reviews and decides whether it goes into the repo; without Grok Bot, another reviewer (agent or person) decides. AInfluencer's nightly routine runs this review. **NSFW note:** today the server only generates clothed, bikini, lingerie and sensual images of the fictional adult character; explicit content will go to private Cloudflare R2, not built yet. Never explicit content with a real person's face.
# English

**Secret Fans Academia IA** · A skill for a Telegram bot (Hermes or any other) that runs an AI character: chats with fans, takes orders from the owner, and generates **photos with the same face** as the references. Example: **Valeria**, a fictional adult character (26, redhead). Everything in the repo is non-explicit.

**Install:** clone, run `./install.sh --dry-run DEST` (prints every step, changes nothing) and then `./install.sh DEST`: before overwriting `skill/`, `tools/`, `docs/` (04/05 are never overwritten) or `config.env`, it copies them to `DEST/respaldos/YYYYMMDD-HHMMSS/`. Copy `.env.example` to `.env` (HF_TOKEN, TELEGRAM_TOKEN_<NAME>, DUENO_TELEGRAM_ID), `pip install gradio_client pillow`. The installer detects the environment: on a server/VPS (`CEREBRO_CENTRAL=1`, marker file, or cloud VM) `ALMACEN_ADULTO=r2-privado`; on your own computer `local`. **Single content policy:** on the server, clothed/bikini/lingerie/sensual content of the fictional character only; nudity and sex go to private Cloudflare R2, which does not exist yet (so they are not generated).

**Initial interview:** the bot asks the owner for name, age (21+), backstory, appearance, personality, prices, reference photos and the character's Telegram bot, and fills `personajes/<name>/` (`PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `REGLAS.md`, `personaje.env.example`, `ref/README.md`). **One folder and one Telegram bot per character**, listed in `personajes/README.md`. Valeria is the first one, as a public profile only (no real photos, tokens or IDs).

**Details and claims checker (rule 4j):** before replying or confirming, Hermes checks that what it states (prices, number of photos, references used, generation status, character traits) matches the real data and files; if it does not match, it corrects it and never makes things up.

**Model license notice (rule 4k):** Qwen-Image 2.1 is used under its research license (Qwen RESEARCH LICENSE); use is the responsibility of whoever uses it. Hermes says this once per conversation with the owner and repeats it only if asked or when needed.

**Plugin tools (real names):** `imagen_kontext` (step 1: builds the sheet and sends "I'll use these references and the model Qwen-Image 2.1 Studio…"; does not generate) → `imagen_confirmar` (step 2: generates with Qwen 2.1 only after a valid owner confirmation, rule 4h) · `imagen_cancelar` · `imagen_enviar` (only resends what `imagen_confirmar` produced). `imagen_qwen21` is a conceptual alias used in the docs; the internal name `imagen_kontext` is historical.

**Three modes:**
- **Client mode (chat):** talks to fans in the `SOUL.md` voice, sells from `PRECIOS.md`, never mentions tokens/GPU/API/models.
- **Boss mode:** the owner's Telegram ID gives orders (prices, approvals, errors, reports).
- **Image mode:** follows `skill/SKILL.md`: confirm references + model, wait for OK, generate, validate, deliver.

**Photo rules:** panel 1 is always the character's saved face from `personajes/<name>/ref/` (never a garment); client images are extra panels with a role (ropa/objeto/lugar/persona) named in the prompt ("panel 2 = shirt to wear"); no saved face = ask for it before generating; preview shows face + garment; "several" = 3 (max 4) with distinct poses and seeds; count received photos; keep each person's outfit; place in its own panel; no stretching; Qwen gets a 3:4 1152x1536 2-column grid with no gray padding; prompt starts with `Exactly N people, each appears only once`; one single scene, reject collages/duplicates/wrong count, up to 3 attempts with a new seed; deliver as many photos as requested, each validated; Qwen 2.1 only, no backup model (rule 4g); say "faces OK" only if verified; the only path is `imagen_kontext` → `imagen_confirmar` (doc alias `imagen_qwen21`); check the exact API error before claiming quota. "Use one photo as-is" only when that photo IS the character's face. **Legal rule (4i):** sensual content (bikini, lingerie) and R2 only with the fictional character; a real person's face (a third party or the fan's own selfie) goes in an extra panel with role `persona`, the character stays in panel 1, and it is only allowed clothed and non-sensual; explicit content with a real person's face is not supported. **Content policy:** on the server, clothed/bikini/lingerie/sensual of the fictional character only; nudity and sex go to R2, which does not exist yet.

**Pending before building R2:** Hugging Face content policy forbids sexual content created without explicit consent and any sexual content involving minors; the Space `assembledchaos/qwen-image-2-1-studio` is a community Space running a third-party "Uncensored" GGUF with no safety filter; the model is under the **Qwen RESEARCH LICENSE (non-commercial only)**: commercial use (selling or promoting with these photos) needs a separate license from Qwen. See the Spanish section for details.

**3-session class:** (1) setup, accounts, tokens in `.env`, `install.sh --dry-run` then install (dated backup), single content policy and licenses; (2) character interview with `personajes/_plantilla/` (`PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `REGLAS.md`), add the bot to `personajes/README.md`, try the three modes; (3) consistent photos: `ref/` per `ref/README.md`, numbered sheet with the saved face in panel 1, valid confirmation + lock (4h), Qwen 2.1 only (4g), validation, error log, connect the character's own bot.

**Character website (suggestions, non-canonical):** when the character's site is built, whoever builds it should review the skill and add Terms & Conditions stating that the fan is responsible for the material they send (e.g. their selfie). It does not block anything; the limit stays: nothing explicit with a real person's face.

**Security & license:** no tokens, Telegram IDs, real photos or fan data in the repo. [MIT](LICENSE) for the repo's code and docs; it does not cover the Qwen model (Qwen RESEARCH LICENSE, non-commercial) or third-party photos.

**Using it with Grok Bot:** Grok Bot runs the interview, writes the character folder, builds/reviews sheets, logs errors and runs the nightly review; server changes go through the server bot (Cerebro Central) with the owner's OK.

## Qwen 2.1 Space estilo Nano Banana (v5.0)
Repo aparte, privado: `durang/qwen21-nano-banana-space`, que es la fuente del Space privado `iccanobif/qwen21-nano-banana` (ZeroGPU, cuota Pro gratis).
- **Modelo:** solo Qwen-Image 2.1, el GGUF Q4_K_M de terceros `abenzerps/Qwen-Image-2.1-Uncensored-GGUF` más el codificador de texto y el VAE oficiales. Licencia: Qwen Research License. Nunca FLUX, nunca pegar caras ni retocar con PIL.
- **Endpoint** `/edit_multi(modo, instruccion, image1, image2, image3, aspect_ratio, steps, seed, randomize_seed)`, con 1–3 imágenes `<image1>`…`<image3>` que pasan al pipeline como lista.
- **Modos:**
  - `cara-cuerpo-estilo`;
  - `solo-ropa`;
  - `pareja-paso-A`, luego `dos-personas` (paso B) y después `pareja-paso-C`;
  - `estilo`;
  - `reiluminar`;
  - `libre`.
- **Reglas:**
  - máximo 3 imágenes y nunca hojas ni collages;
  - img1 es la base aprobada de Valeria, img2 es UNA foto de la segunda persona y img3 es opcional (prenda o estilo);
  - la salida sale del tamaño de img1;
  - un cambio por paso, repitiendo lo que se conserva, con posiciones explícitas;
  - «single continuous photograph, one camera, one background, exactly N people»;
  - la luz se cambia solo con el prompt;
  - negative anti-díptico y true_cfg 4.0 si el pipeline los acepta;
  - 40 pasos y sin Lightning;
  - juez de visión en Hermes antes de entregar, con otra semilla en cada reintento.
- **Deploy:**
  1. Haz los cambios y el push al repo `qwen21-nano-banana-space`, rama `main`.
  2. El workflow `.github/workflows/sync-to-hf.yml` empuja al Space usando el secret de repo `HF_TOKEN` (token de escritura de HF). Si el secret falta, el workflow falla a propósito.
  3. El Space reconstruye; espera a que esté en Running.
  4. En Hermes, `qwen21_recetas.QWEN_MULTI["space"]` apunta al Space y `RECETA="multi"`.
  Nunca edites el Space a mano: la fuente es el repo.
