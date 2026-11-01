#!/usr/bin/env bash
# Instala el skill de fotos consistentes y escribe la política de almacenamiento.
# Uso: ./install.sh [DESTINO]   (por defecto /opt/data/guia-imagen)
# Forzar entorno (pruebas): MODO_ENTORNO=servidor|local ./install.sh DESTINO
set -euo pipefail
ORIG="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-/opt/data/guia-imagen}"
detectar() {
  [ -n "${MODO_ENTORNO:-}" ] && { echo "$MODO_ENTORNO"; return; }
  # Marcador de Cerebro Central
  if [ -n "${CEREBRO_CENTRAL:-}" ] || [ -e /etc/cerebro-central ] || [ -e "$HOME/.cerebro-central" ] || [ -e /opt/data/.cerebro-central ]; then echo servidor; return; fi
  # VPS / proveedor rentado
  local v=""; v="$(cat /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name 2>/dev/null || true)"
  if echo "$v $(hostname)" | grep -qiE 'contabo|hetzner|digitalocean|linode|akamai|vultr|ovh|amazon|google|microsoft|kvm|qemu|openstack'; then echo servidor; return; fi
  if command -v systemd-detect-virt >/dev/null && systemd-detect-virt -q 2>/dev/null && [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && [ "$(uname)" = Linux ]; then echo servidor; return; fi
  echo local
}
MODO="$(detectar)"
case "$MODO" in servidor|local) ;; *) echo "MODO_ENTORNO inválido: $MODO" >&2; exit 1;; esac
mkdir -p "$DEST"/{skill,tools,docs,personajes,salidas}
cp -r "$ORIG"/skill/. "$DEST/skill/"; mkdir -p "$DEST/personajes"; cp -rn "$ORIG"/personajes/. "$DEST/personajes/"; cp "$ORIG"/tools/*.py "$DEST/tools/"; chmod +x "$DEST"/tools/*.py
for f in "$ORIG"/docs/*.md; do b=$(basename "$f"); [ -e "$DEST/docs/$b" ] && [[ "$b" =~ ^0[45]- ]] || cp "$f" "$DEST/docs/"; done  # no pisa errores/registro
[ -e "$DEST/.env" ] || cp "$ORIG/.env.example" "$DEST/.env.example"
[ -e "$DEST/personaje.env" ] || cp "$ORIG/personajes/valeria/personaje.env.example" "$DEST/personaje.env"
if [ "$MODO" = servidor ]; then
  ADULTO="r2-privado"; NOTA="Servidor/VPS: se puede generar aquí, pero el contenido adulto/explícito NO se guarda en este disco (términos del proveedor). Va a Cloudflare R2 privado (R2_* en .env) y se borra la copia local."
else
  ADULTO="local"; NOTA="Computadora propia: todo se guarda localmente."
fi
cat > "$DEST/config.env" <<CFG
# Generado por install.sh $(date -Iseconds)
GUIA=$DEST
MODO_ENTORNO=$MODO
ALMACEN_SALIDAS=$DEST/salidas
ALMACEN_ADULTO=$ADULTO
# Servidor: en disco solo bikini/lenceria/sensual. Desnudo/sexual -> R2 privado (TODO: subida a R2 aun no construida; mientras tanto NO se genera en servidor)
ALMACEN_ADULTO_RUTA=$([ "$MODO" = servidor ] && echo 'r2://${R2_BUCKET}/privado/' || echo "$DEST/salidas/privado")
# $NOTA
source "$DEST/personaje.env" 2>/dev/null || true
CFG
echo "Instalado en $DEST · entorno=$MODO · almacenamiento adulto=$ADULTO"
echo "$NOTA"
echo "Siguiente: copia .env.example a .env, pon HF_TOKEN y edita personaje.env."
