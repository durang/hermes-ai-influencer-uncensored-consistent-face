# hermes-skill-fotos-consistentes

**Secret Fans Academia IA** · Skill para que un bot de Telegram (Hermes u otro) maneje un personaje de IA: chatear con fans, recibir órdenes del dueño y generar **fotos con la misma cara** que las referencias. Ejemplo incluido: **Valeria**, personaje ficticio adulto (26 años, pelirroja). Todo el contenido del repo es no explícito.

> English version below · [English](#english)

## Qué incluye
| Ruta | Para qué |
|---|---|
| `skill/SKILL.md` | Lo que el bot ejecuta: reglas duras §0b, flujo con confirmación, hoja C2, errores |
| `personajes/_plantilla/` | Salida de la entrevista: `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `personaje.env.example`, `ref/` |
| `personajes/valeria/` | Ejemplo completo con Valeria |
| `tools/armar_hoja.py` | Hoja numerada (proporción original) + entrada Qwen 3:4 1152x1536 en 2 columnas sin relleno (`--qwen34`), `--lugar`, `--recibidas N` |
| `tools/qwen21_generar.py` | Genera con Qwen-Image 2.1 (API, HF_TOKEN, 40 pasos) |
| `docs/` | Pipeline, técnicas, prompts, errores (E1–E31), registro, changelog |
| `install.sh` | Instala y detecta el entorno |

## Instalar
```bash
git clone git@github.com:<usuario>/hermes-skill-fotos-consistentes.git
cd hermes-skill-fotos-consistentes
./install.sh /opt/data/guia-imagen       # en el contenedor del bot
cp /opt/data/guia-imagen/.env.example /opt/data/guia-imagen/.env   # pon HF_TOKEN y TELEGRAM_TOKEN_<NOMBRE> (nunca en git)
pip install gradio_client pillow
```
`install.sh` detecta el entorno y escribe `config.env`:
| Entorno | Detección | `ALMACEN_ADULTO` |
|---|---|---|
| Servidor / VPS (Cerebro Central en Contabo) | `CEREBRO_CENTRAL=1`, `/etc/cerebro-central` o proveedor/VM | `r2-privado` |
| Tu computadora | lo demás | `local` |

Forzar: `MODO_ENTORNO=servidor|local ./install.sh DESTINO`.
**Política del servidor:** en el disco solo bikini, lencería o sensual sin desnudo. Desnudo/sexual va a Cloudflare R2 privado — **TODO: la subida a R2 aún no está construida**; mientras tanto no se genera en el servidor.

## Entrevista inicial (crear un personaje)
El bot pregunta al dueño, en orden, y llena `personajes/<nombre>/`:
1. Nombre, edad (21+), origen e historia corta → `PERSONAJE.md`
2. Apariencia (cabello, ojos, rasgos únicos, estilo) → `PERSONAJE.md`
3. Personalidad, tono, emojis, idiomas → `SOUL.md`
4. Catálogo y precios → `PRECIOS.md`
5. Fotos de referencia (cara frontal primero) → `ref/`
6. Bot de Telegram del personaje (creado con @BotFather; token solo en `.env`)

## Una carpeta y un bot por personaje
```
personajes/
  valeria/   PERSONAJE.md SOUL.md PRECIOS.md personaje.env.example ref/
  <otro>/    …
```
Cada personaje tiene **su propio bot de Telegram** (`TELEGRAM_TOKEN_VALERIA`, `TELEGRAM_TOKEN_<OTRO>`), así sus chats, memoria y fotos no se mezclan.

## Los tres modos
| Modo | Quién | Qué hace |
|---|---|---|
| **Modo cliente (chat)** | Fans | Conversa con la voz de `SOUL.md`, vende según `PRECIOS.md`, nunca habla de token/GPU/API/modelos |
| **Modo jefe** | Dueño (su ID de Telegram) | Da órdenes: cambiar precios, aprobar fotos, ver errores, pedir reportes |
| **Modo imagen** | Dueño o pedido aprobado | Sigue `skill/SKILL.md`: confirma refs + modelo, espera OK, genera, valida, entrega |

## Reglas clave de fotos (resumen de SKILL §0b)
1. Confirma «Usaré estas referencias y el modelo X» y espera OK.
2. **Panel 1 = siempre la cara guardada** de `personajes/<nombre>/ref/`, nunca una prenda. Las fotos del cliente son paneles extra con rol (`ropa`, `objeto`, `lugar`, `persona`) y el prompt dice p. ej. «panel 2 = shirt to wear». Sin foto de cara guardada no se genera: se pide primero. La confirmación muestra cara + prenda.
3. Cuenta las fotos recibidas; nunca descartes una en silencio. El lugar va en su propio panel.
4. Misma ropa por persona salvo que se indique otra.
5. Hoja sin estirar; Qwen recibe rejilla 3:4 1152x1536, 2 columnas, sin relleno gris.
6. El prompt empieza con `Exactly N people, each appears only once` y dice qué panel es quién.
7. Una sola escena: se rechaza collage, copia de la hoja, persona duplicada o conteo distinto; hasta 3 intentos con seed nueva.
8. «Varias» fotos = 3 (máx. 4) con poses y seeds distintas; cada una pasa el control de número de personas.
9. FLUX Kontext solo de respaldo y solo con 1 persona. «Caras OK» solo si se verificó.
10. Solo la herramienta Qwen 2.1; nunca `dynamic_space` ni navegador; revisa el error exacto antes de hablar de cuota.

## Ejemplo con Valeria
```bash
R=personajes/valeria/ref
python3 tools/armar_hoja.py salidas/hoja-cafe.png --cara $R/ref-1-calle.png \
  --extra ropa:camisa-cliente.jpg --extra lugar:cafe.jpg --recibidas 2 --qwen34 salidas/entrada34-cafe.png
```
Confirmación: «Recibí 2 imágenes: 1=camisa, 2=café. Usaré la cara de Valeria (panel 1), la camisa (panel 2), el café (panel 3) y el modelo Qwen 2.1. ¿OK?»
Prompt: `Exactly 1 person, appears only once: panel 1 = Valeria's face (identity); panel 2 = shirt to wear; panel 3 = the place. The numbered sheet is ONLY a reference: generate ONE brand-new full-frame photograph…`

## Clase en 3 sesiones
- **Sesión 1 — Preparación, permisos e instalación:** cuentas (Hugging Face, Telegram/@BotFather, servidor o PC), tokens en `.env`, `install.sh`, cómo se detecta el entorno y la política de almacenamiento.
- **Sesión 2 — Entrevista del personaje y modos:** correr la entrevista, llenar `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, probar modo cliente, modo jefe y modo imagen.
- **Sesión 3 — Fotos consistentes y un bot por personaje:** referencias, hoja numerada, confirmación, validación (una escena, conteo), registro de errores; conectar el bot de Telegram del personaje.

## Usarlo con Grok Bot
Grok Bot puede: hacer la entrevista contigo y escribir la carpeta del personaje; armar y revisar hojas con `armar_hoja.py`; documentar errores nuevos en `docs/04-ERRORES.md` y correr la revisión nocturna. Los cambios en el servidor (contenedor, plugins, reinicios) los hace el bot del servidor (Cerebro Central) **solo con el OK del dueño**. Pídele, por ejemplo: «Crea el personaje Ana con la plantilla» o «Revisa por qué la última foto salió como collage».

## Seguridad
Sin secretos en el repo (`.env` está en `.gitignore`). Solo personajes adultos ficticios o personas reales con consentimiento escrito.

---
<a id="english"></a>
# English

**Secret Fans Academia IA** · A skill for a Telegram bot (Hermes or any other) that runs an AI character: chats with fans, takes orders from the owner, and generates **photos with the same face** as the references. Example: **Valeria**, a fictional adult character (26, redhead). Everything in the repo is non-explicit.

**Install:** clone, run `./install.sh DEST`, copy `.env.example` to `.env` (HF_TOKEN, TELEGRAM_TOKEN_<NAME>), `pip install gradio_client pillow`. The installer detects the environment: on a server/VPS (`CEREBRO_CENTRAL=1`, marker file, or cloud VM) `ALMACEN_ADULTO=r2-privado`; on your own computer `local`. Server disk holds only bikini/lingerie/sensual content; nude/sexual content goes to private Cloudflare R2 (**TODO: not built yet**).

**Initial interview:** the bot asks the owner for name, age (21+), backstory, appearance, personality, prices, reference photos and the character's Telegram bot, and fills `personajes/<name>/` (`PERSONAJE.md`, `SOUL.md`, `PRECIOS.md`, `ref/`). **One folder and one Telegram bot per character.**

**Three modes:**
- **Client mode (chat):** talks to fans in the `SOUL.md` voice, sells from `PRECIOS.md`, never mentions tokens/GPU/API/models.
- **Boss mode:** the owner's Telegram ID gives orders (prices, approvals, errors, reports).
- **Image mode:** follows `skill/SKILL.md`: confirm references + model, wait for OK, generate, validate, deliver.

**Photo rules:** panel 1 is always the character's saved face from `personajes/<name>/ref/` (never a garment); client images are extra panels with a role (ropa/objeto/lugar/persona) named in the prompt ("panel 2 = shirt to wear"); no saved face = ask for it before generating; preview shows face + garment; "several" = 3 (max 4) with distinct poses and seeds; count received photos; keep each person's outfit; place in its own panel; no stretching; Qwen gets a 3:4 1152x1536 2-column grid with no gray padding; prompt starts with `Exactly N people, each appears only once`; one single scene, reject collages/duplicates/wrong count, up to 3 attempts with a new seed; deliver as many photos as requested, each validated; FLUX Kontext only as backup for 1 person; say "faces OK" only if verified; Qwen 2.1 tool only, check the exact API error before claiming quota.

**3-session class:** (1) setup, permissions, installation; (2) character interview + modes; (3) consistent-photo workflow + one Telegram bot per character.

**Using it with Grok Bot:** Grok Bot runs the interview, writes the character folder, builds/reviews sheets, logs errors and runs the nightly review; server changes go through the server bot (Cerebro Central) with the owner's OK.
