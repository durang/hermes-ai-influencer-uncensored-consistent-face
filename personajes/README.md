# Personajes — índice

Una carpeta y **un bot de Telegram propio por personaje**. Así no se mezclan chats, memoria ni fotos.

| Slug | Nombre | Bot de Telegram | Estado | Carpeta |
|---|---|---|---|---|
| `valeria` | Valeria | `@{bot_de_valeria}` (lo pone el dueño; el token solo en `.env` como `TELEGRAM_TOKEN_VALERIA`) | Ficha pública lista · `ref/` vacía (las fotos no viven en el repo) | [`valeria/`](valeria/) |
| `{slug}` | {Nombre} | `@{bot}` (`TELEGRAM_TOKEN_{SLUG}` en `.env`) | — | copiar [`_plantilla/`](_plantilla/) |

## Qué lleva cada carpeta
| Archivo | Para qué |
|---|---|
| `PERSONAJE.md` | Ficha: identidad, apariencia (checklist de parecido), referencias, bot de Telegram |
| `SOUL.md` | Voz y personalidad en **modo cliente** (chat con fans) |
| `PRECIOS.md` | Catálogo y reglas de venta (descuentos solo con OK del dueño) |
| `REGLAS.md` | Reglas del personaje: edad, divulgación de IA, política de contenido, regla legal 4i, privacidad |
| `personaje.env.example` | Variables del personaje (nombre, slug, cara principal, usuario del bot). **Sin tokens ni IDs** |
| `ref/README.md` | Qué fotos de cara poner en `ref/`. Las fotos **no se suben al repo** |

## Crear un personaje nuevo
1. `cp -r personajes/_plantilla personajes/<slug>` (slug en minúsculas, sin acentos).
2. La entrevista inicial (README principal) llena `PERSONAJE.md`, `SOUL.md`, `PRECIOS.md` y `REGLAS.md`.
3. Crea su bot con @BotFather y pon el token **solo** en `.env` como `TELEGRAM_TOKEN_<SLUG>`. El ID de Telegram del dueño va en `.env` como `DUENO_TELEGRAM_ID`.
4. Pon las fotos de cara en `ref/` siguiendo `ref/README.md` (en la instalación, no en git).
5. Agrega una fila a la tabla de arriba.

**Nunca en el repo:** tokens, IDs de Telegram, fotos reales ni datos de fans.
