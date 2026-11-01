#!/usr/bin/env bash
# Pruebas del repo (sin red, sin tocar /opt/data): bash tests/verificar.sh
set -uo pipefail
R="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
PASS=0; FAIL=0
ok() { if eval "$2"; then echo "PASS $1"; PASS=$((PASS+1)); else echo "FAIL $1"; FAIL=$((FAIL+1)); fi; }
huella() { (cd "$1" 2>/dev/null && find . -type f -print0 | sort -z | xargs -0 sha256sum 2>/dev/null) | sha256sum | cut -d' ' -f1; }

# ---------- install.sh ----------
ok "I0 install.sh: sintaxis bash" "bash -n '$R/install.sh'"
D="$T/guia"
MODO_ENTORNO=servidor bash "$R/install.sh" --dry-run "$D" > "$T/dry1.txt" 2>&1
ok "I1 --dry-run en destino nuevo: no crea nada" "[ ! -e '$D' ] && grep -q 'DRY-RUN: no se modificó nada' '$T/dry1.txt'"
MODO_ENTORNO=servidor bash "$R/install.sh" "$D" > "$T/inst1.txt" 2>&1
ok "I2 instalación nueva: skill, tools, docs, personajes y config.env (servidor → r2-privado)" \
   "[ -f '$D/skill/SKILL.md' ] && [ -f '$D/tools/armar_hoja.py' ] && [ -f '$D/docs/01-PIPELINE.md' ] && [ -d '$D/personajes/valeria' ] && grep -q 'ALMACEN_ADULTO=r2-privado' '$D/config.env' && ! [ -d '$D/respaldos' ]"
echo "regla local de prueba" >> "$D/skill/SKILL.md"; echo "| E99 | vivo |" >> "$D/docs/04-ERRORES.md"; echo "mi personaje" > "$D/personajes/valeria/PERSONAJE.md"
H0="$(huella "$D")"
MODO_ENTORNO=servidor bash "$R/install.sh" --dry-run "$D" > "$T/dry2.txt" 2>&1
ok "I3 --dry-run sobre una instalación existente: no modifica nada y anuncia el respaldo" "[ '$(huella "$D")' = '$H0' ] && grep -q '\[dry-run\] cp -a' '$T/dry2.txt'"
MODO_ENTORNO=servidor bash "$R/install.sh" "$D" > "$T/inst2.txt" 2>&1
RES="$(ls -d "$D"/respaldos/*/ 2>/dev/null | head -1)"
ok "I4 reinstalación: respaldo con fecha (AAAAMMDD-HHMMSS) que guarda el SKILL modificado y config.env" \
   "[ -n '$RES' ] && basename '$RES' | grep -qE '^[0-9]{8}-[0-9]{6}$' && grep -q 'regla local de prueba' '${RES}skill/SKILL.md' && [ -f '${RES}config.env' ]"
ok "I5 04-ERRORES/05-REGISTRO y personajes/ no se pisan" "grep -q 'E99 | vivo' '$D/docs/04-ERRORES.md' && grep -q 'mi personaje' '$D/personajes/valeria/PERSONAJE.md'"
ok "I6 local → ALMACEN_ADULTO=local" "MODO_ENTORNO=local bash '$R/install.sh' '$T/local' >/dev/null 2>&1 && grep -q 'ALMACEN_ADULTO=local' '$T/local/config.env'"

# ---------- documentación ----------
ok "D1 README y docs sin FLUX/Kontext (solo el nombre interno imagen_kontext)" \
   "! grep -n -i 'flux\|kontext' '$R/README.md' '$R'/docs/*.md | grep -v -i 'imagen_kontext' | grep -q ."
ok "D2 imagen_qwen21 solo como alias (no aparece como herramienta ni con el script)" \
   "! grep -rn 'imagen_qwen21' '$R/skill' '$R/docs' '$R/README.md' | grep -v -i 'alias' | grep -v CHANGELOG | grep -q ."
ok "D3 nadie manda correr qwen21_generar.py con HF_TOKEN en la línea de comando" "! grep -rn 'HF_TOKEN=\$HF_TOKEN' '$R/skill' '$R/docs' '$R/README.md' | grep -q ."
ok "D4 SKILL: herramientas reales imagen_kontext → imagen_confirmar y reglas 4g, 4h y 4i" \
   "grep -q 'imagen_confirmar(id, prompt)' '$R/skill/SKILL.md' && grep -q 'Regla 4g' '$R/skill/SKILL.md' && grep -q 'Regla 4h' '$R/skill/SKILL.md' && grep -q 'Regla 4i' '$R/skill/SKILL.md'"
ok "D5 «1 foto tal cual» solo si ES la cara del personaje" "grep -q '1 foto que ES la cara del personaje' '$R/skill/SKILL.md' && ! grep -q 'manda \*\*1 foto\*\* → ENTONCES técnica A0' '$R/skill/SKILL.md'"
ok "D6 política única (servidor: personaje ficticio; desnudo/sexo a R2 que aún no existe) en SKILL y README" \
   "grep -q 'solo del personaje ficticio' '$R/README.md' && grep -q 'todavía no existe' '$R/skill/SKILL.md' && ! grep -qi 'solo SFW, con ropa' '$R/skill/SKILL.md'"
ok "D7 README: pendientes legales antes de R2 (HF, Space, licencia Qwen)" \
   "grep -q 'Pendientes antes de construir R2' '$R/README.md' && grep -q 'Qwen RESEARCH LICENSE' '$R/README.md' && grep -q 'Uncensored' '$R/README.md'"

# ---------- herramienta de hoja ----------
if python3 -c "import PIL" 2>/dev/null; then
  python3 - "$T" <<'PY'
import sys
from PIL import Image
t = sys.argv[1]
Image.new("RGB", (900, 1200), (200, 160, 140)).save(f"{t}/cara.png")
Image.new("RGB", (1200, 800), (40, 60, 90)).save(f"{t}/lugar.png")
PY
  python3 "$R/tools/armar_hoja.py" "$T/hoja.png" --cara "$T/cara.png" --lugar "$T/lugar.png" --recibidas 1 --qwen34 "$T/e34.png" > "$T/hoja.txt" 2>&1
  ok "H1 armar_hoja: hoja + entrada 3:4 1152x1536" "grep -q 'OK qwen34' '$T/hoja.txt' && python3 -c \"from PIL import Image; import sys; sys.exit(0 if Image.open('$T/e34.png').size==(1152,1536) else 1)\""
  python3 "$R/tools/armar_hoja.py" "$T/x.png" --lugar "$T/lugar.png" > "$T/sincara.txt" 2>&1
  ok "H2 armar_hoja: sin cara → ERROR SIN CARA (no genera)" "grep -q 'ERROR SIN CARA' '$T/sincara.txt'"
else
  echo "SKIP H1/H2 (falta Pillow)"
fi

echo; echo "$PASS PASS · $FAIL FAIL"
[ "$FAIL" = 0 ]
