# hermes-skill-fotos-consistentes

Skill reutilizable para que un bot (Hermes u otro) genere **fotos con la misma cara** que las referencias de un personaje, con hoja numerada C2, confirmación antes de generar, calibración de modelos y registro de errores. Solo SFW en este repo.

## Estructura
- `skill/SKILL.md` — instrucciones genéricas que el bot ejecuta (incluye reglas duras v2).
- `skill/personaje/` — `plantilla.md`, `personaje.env.example` y el ejemplo `ejemplo-valeria.md`. Para otro bot, copia la plantilla.
- `tools/armar_hoja.py` — hoja numerada (`--lugar` en panel propio, `--recibidas N` para no perder imágenes).
- `tools/qwen21_generar.py` — genera con Qwen-Image 2.1 Studio vía API (HF_TOKEN). 40 pasos por defecto.
- `docs/` — pipeline, técnicas, prompts, errores, registro, changelog.
- `install.sh` — instala y escribe `config.env` con la política de almacenamiento.

## Reglas clave
1. Cuenta las imágenes recibidas; nunca descartes una en silencio.
2. Cada persona lleva la ropa de su referencia salvo que se pida otra; el prompt la describe.
3. El lugar va en su propio panel.
4. Nunca `dynamic_space` ni navegador; muestra el error exacto de la API antes de decir que se acabó la cuota.
5. Pasos: 40 por defecto; más = más detalle y más lento, casi sin mejora arriba de 40 (máx. ~50).

## Almacenamiento según entorno
| Entorno | Detección | Contenido adulto |
|---|---|---|
| Servidor/VPS (p. ej. Cerebro Central en Contabo) | marcador `CEREBRO_CENTRAL` / `/etc/cerebro-central`, o proveedor/VM detectado | **R2 privado de Cloudflare** (los términos del proveedor prohíben alojarlo) |
| Tu computadora | lo demás | local |

Forzar: `MODO_ENTORNO=servidor|local ./install.sh DESTINO`.

## Instalar en Hermes
```bash
git clone git@github.com:<usuario>/hermes-skill-fotos-consistentes.git
cd hermes-skill-fotos-consistentes
./install.sh /opt/data/guia-imagen          # dentro del contenedor (o docker cp y luego ejecutar)
cp /opt/data/guia-imagen/.env.example /opt/data/guia-imagen/.env   # poner HF_TOKEN
pip install gradio_client pillow
```
Las referencias van en `/opt/data/guia-imagen/referencias/` (no se suben al repo). Reinstalar no pisa `04-ERRORES.md` ni `05-REGISTRO.md`.

## Seguridad
Sin secretos en el repo: usa `.env` (ignorado por git). Solo personajes adultos originales o personas reales con consentimiento.
