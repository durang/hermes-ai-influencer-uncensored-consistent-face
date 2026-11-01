#!/usr/bin/env bash
# Instala el skill de fotos consistentes y escribe la política de almacenamiento.
# Uso: ./install.sh [--dry-run] [DESTINO]   (por defecto /opt/data/guia-imagen)
#   --dry-run   muestra todo lo que haría (respaldo, copias, config.env) sin tocar nada.
# Forzar entorno (pruebas): MODO_ENTORNO=servidor|local ./install.sh DESTINO
# Antes de pisar cualquier cosa hace un respaldo con fecha en DESTINO/respaldos/AAAAMMDD-HHMMSS/
# (skill/, tools/, docs/, config.env y cualquier otro archivo que vaya a sobrescribir). No borra nada.
set -euo pipefail
ORIG="$(cd "$(dirname "$0")" && pwd)"
DRY=0; DEST=""
for a in "$@"; do
  case "$a" in
    --dry-run|-n) DRY=1 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    -*) echo "opción desconocida: $a" >&2; exit 1 ;;
    *) DEST="$a" ;;
  esac
done
DEST="${DEST:-/opt/data/guia-imagen}"
FECHA="$(date +%Y%m%d-%H%M%S)"
RESPALDO="$DEST/respaldos/$FECHA"

run() {  # ejecuta o, en --dry-run, solo muestra
  if [ "$DRY" = 1 ]; then printf '[dry-run]'; printf ' %q' "$@"; printf '\n'; else "$@"; fi
}

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

# ---------- 1) Respaldo con fecha de todo lo que se va a sobrescribir ----------
# Destinos que este instalador sobrescribe (personajes/, .env y personaje.env NO se pisan nunca: se copian con -n o solo si faltan).
A_PISAR=()
for d in skill tools; do [ -d "$DEST/$d" ] && [ -n "$(ls -A "$DEST/$d" 2>/dev/null)" ] && A_PISAR+=("$d"); done
for f in "$ORIG"/docs/*.md; do
  b=$(basename "$f")
  if [ -e "$DEST/docs/$b" ] && ! [[ "$b" =~ ^0[45]- ]]; then A_PISAR+=("docs/$b"); fi   # 04/05 (errores/registro) nunca se pisan
done
[ -e "$DEST/config.env" ] && A_PISAR+=("config.env")
if [ "${#A_PISAR[@]}" -gt 0 ]; then
  echo "Respaldo previo en $RESPALDO (${#A_PISAR[@]} elementos)"
  run mkdir -p "$RESPALDO"
  for x in "${A_PISAR[@]}"; do
    run mkdir -p "$RESPALDO/$(dirname "$x")"
    run cp -a "$DEST/$x" "$RESPALDO/$x"
  done
else
  echo "Nada que respaldar (instalación nueva en $DEST)"
fi

# ---------- 2) Copias ----------
run mkdir -p "$DEST"/skill "$DEST"/tools "$DEST"/docs "$DEST"/personajes "$DEST"/salidas
run cp -r "$ORIG"/skill/. "$DEST/skill/"
run cp -rn "$ORIG"/personajes/. "$DEST/personajes/"
for t in "$ORIG"/tools/*.py; do run cp "$t" "$DEST/tools/"; run chmod +x "$DEST/tools/$(basename "$t")"; done
for f in "$ORIG"/docs/*.md; do
  b=$(basename "$f")
  if [ -e "$DEST/docs/$b" ] && [[ "$b" =~ ^0[45]- ]]; then continue; fi   # no pisa errores/registro
  run cp "$f" "$DEST/docs/"
done
[ -e "$DEST/.env" ] || [ -e "$DEST/.env.example" ] || run cp "$ORIG/.env.example" "$DEST/.env.example"
[ -e "$DEST/personaje.env" ] || run cp "$ORIG/personajes/valeria/personaje.env.example" "$DEST/personaje.env"

# ---------- 3) config.env ----------
if [ "$MODO" = servidor ]; then
  ADULTO="r2-privado"; NOTA="Servidor/VPS: solo vestido, bikini, lencería y sensual del personaje ficticio. Desnudo/sexo van a Cloudflare R2 privado (R2_* en .env), que todavía no existe: mientras tanto no se generan."
else
  ADULTO="local"; NOTA="Computadora propia: todo se guarda localmente."
fi
CFG="# Generado por install.sh $(date -Iseconds)
GUIA=$DEST
MODO_ENTORNO=$MODO
ALMACEN_SALIDAS=$DEST/salidas
ALMACEN_ADULTO=$ADULTO
# Servidor: solo vestido/bikini/lenceria/sensual del personaje ficticio. Desnudo/sexual -> R2 privado (TODO: aun no construido; mientras tanto NO se genera)
ALMACEN_ADULTO_RUTA=$([ "$MODO" = servidor ] && echo 'r2://${R2_BUCKET}/privado/' || echo "$DEST/salidas/privado")
# $NOTA
source \"$DEST/personaje.env\" 2>/dev/null || true"
if [ "$DRY" = 1 ]; then
  echo "[dry-run] escribiría $DEST/config.env:"; printf '%s\n' "$CFG" | sed 's/^/[dry-run]   /'
else
  printf '%s\n' "$CFG" > "$DEST/config.env"
fi

[ "$DRY" = 1 ] && echo "DRY-RUN: no se modificó nada en $DEST."
echo "Instalado en $DEST · entorno=$MODO · almacenamiento adulto=$ADULTO"
[ "${#A_PISAR[@]}" -gt 0 ] && echo "Respaldo: $RESPALDO (para volver: cp -a $RESPALDO/. $DEST/)"
echo "$NOTA"
echo "Siguiente: copia .env.example a .env, pon HF_TOKEN y edita personaje.env."
