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

ok "D8 v4.4: la selfie del fan entra como persona (no se rechaza); explícito con cara real = no soportado" \
   "grep -q 'Selfie del fan:\*\* no se rechaza' '$R/skill/SKILL.md' && ! grep -qi 'la vista previa la rechaza' '$R/skill/SKILL.md' '$R/README.md' && grep -q 'No soportado' '$R/skill/SKILL.md' && grep -q 'No soportado' '$R/README.md'"
ok "D9 Términos y Condiciones solo como sugerencia no canónica (no en las reglas)" \
   "grep -q '## Sitio web del personaje (sugerencias)' '$R/README.md' && grep -q 'no canónica' '$R/README.md' && ! sed -n '/^## Reglas clave/,/^## /p' '$R/README.md' | grep -qi 'términos y condiciones'"

# ---------- personajes ----------
for d in "$R"/personajes/*/; do
  n=$(basename "$d")
  ok "P1 personajes/$n: PERSONAJE, SOUL, PRECIOS, REGLAS, personaje.env.example y ref/README.md" \
     "for f in PERSONAJE.md SOUL.md PRECIOS.md REGLAS.md personaje.env.example ref/README.md; do [ -f '$d'\$f ] || exit 1; done"
done
ok "P2 personajes/README.md: índice con Valeria y su bot (sin token)" "grep -q '\`valeria\`' '$R/personajes/README.md' && grep -q 'TELEGRAM_TOKEN_VALERIA' '$R/personajes/README.md'"
ok "P3 sin fotos versionadas en ref/ (solo README/.gitkeep)" "! git -C '$R' ls-files 'personajes/*/ref/*' | grep -vE '/(README\.md|\.gitkeep)$' | grep -q ."
ok "P4 sin tokens ni IDs en personajes/ (bot token, hf_, números de 7+ dígitos)" \
   "! grep -rEn '[0-9]{8,10}:[A-Za-z0-9_-]{30,}|hf_[A-Za-z0-9]{10,}|(^|[^0-9.])[0-9]{7,}([^0-9]|$)' '$R/personajes' | grep -q ."
ok "P5 Valeria = ficha pública: sin rutas internas (/opt/data, Cerebro, Box) en su PERSONAJE.md" "! grep -qiE '/opt/data|cerebro|box y' '$R/personajes/valeria/PERSONAJE.md'"
ok "P6 SOUL/REGLAS: divulgación de IA y confirmación de mayoría de edad" \
   "grep -q 'creado con IA' '$R/personajes/valeria/SOUL.md' && grep -q 'mayor de edad' '$R/personajes/valeria/SOUL.md' && grep -q 'Regla legal 4i' '$R/personajes/valeria/REGLAS.md'"
ok "P7 .gitignore ignora fotos de ref/" "git -C '$R' check-ignore -q personajes/valeria/ref/foto.png && ! git -C '$R' check-ignore -q personajes/valeria/ref/README.md"
ok "P8 install.sh instala REGLAS.md y ref/README.md" "[ -f '$D/personajes/valeria/REGLAS.md' ] && [ -f '$D/personajes/valeria/ref/README.md' ]"

# ---------- licencia, changelog, flujo, ES/EN, clase ----------
ok "L1 LICENSE MIT y CHANGELOG.md en la raíz (ya no en docs/)" "grep -q '^MIT License' '$R/LICENSE' && [ -f '$R/CHANGELOG.md' ] && [ ! -e '$R/docs/CHANGELOG.md' ] && grep -q '## v4.5' '$R/CHANGELOG.md'"
ok "F1 flujo §2: confirmación válida de 4h (incluye ándale) y candado" "grep -q 'ándale' '$R/skill/SKILL.md' && grep -q 'Candado (4h)' '$R/skill/SKILL.md' && ! grep -q 'OK/sí/dale → generar' '$R/skill/SKILL.md'"
ok "F2 flujo §2: el envío lo hace imagen_confirmar; sin 'El script reintenta' ni 'código 3'" "! grep -q 'El script reintenta' '$R/skill/SKILL.md' && ! grep -q 'código 3' '$R/skill/SKILL.md'"
ok "F3 §0b con índice de 4b–4i y §6 con rutas personajes/<slug>/" "grep -q 'Índice: 1–14' '$R/skill/SKILL.md' && ! grep -q 'personaje/plantilla.md' '$R/skill/SKILL.md'"
ok "E1 EN: herramientas reales, sugerencias del sitio, licencia y dry-run" \
   "sed -n '/<a id=\"english\"><\/a>/,\$p' '$R/README.md' > '$T/en.md' && grep -q 'Plugin tools (real names)' '$T/en.md' && grep -q 'Character website (suggestions' '$T/en.md' && grep -q 'MIT' '$T/en.md' && grep -q 'dry-run' '$T/en.md'"
ok "C1 clase en 3 sesiones: dry-run, REGLAS.md, 4g/4h" "sed -n '/^## Clase en 3 sesiones/,/^## /p' '$R/README.md' | grep -q 'dry-run' && sed -n '/^## Clase en 3 sesiones/,/^## /p' '$R/README.md' | grep -q 'REGLAS.md' && sed -n '/^## Clase en 3 sesiones/,/^## /p' '$R/README.md' | grep -q '4h'"

ok "N1 nombre nuevo: título y sin nombre viejo" "grep -q '^# Hermes AI Influencer · Uncensored Consistent Face' '$R/README.md' && ! grep -q 'consistent-sensorial' '$R/README.md' && ! grep -rq 'hermes-skill-fotos-consistentes' '$R/README.md' '$R/docs' '$R/install.sh' '$R/skill'"
ok "V1 Valeria pelirroja, sin morena" "grep -qi 'pelirroja' '$R/personajes/valeria/SOUL.md' && ! grep -rqi 'morena' '$R/personajes/valeria'"
ok "J1 regla 4j en SKILL (índice + sección ES/EN)" "grep -q '4j\*\* verificador' '$R/skill/SKILL.md' && grep -q 'Regla 4j — Verificador de detalles y afirmaciones' '$R/skill/SKILL.md' && grep -q 'details and claims checker' '$R/skill/SKILL.md'"
ok "J2 regla 4j en README ES y EN" "grep -q 'Verificador de detalles y afirmaciones (4j)' '$R/README.md' && grep -q 'Details and claims checker (rule 4j)' '$R/README.md'"
ok "K1 aviso licencia Qwen en README + regla 4k una vez por conversación" "grep -q 'Aviso de licencia del modelo' '$R/README.md' && grep -q 'responsabilidad de quien lo use' '$R/README.md' && grep -q 'una sola vez por conversación' '$R/skill/SKILL.md' && grep -q 'once per conversation' '$R/README.md'"
ok "A1 PROPUESTAS.md con plantilla" "grep -q 'Qué pasó' '$R/PROPUESTAS.md' && grep -q 'Evidencia' '$R/PROPUESTAS.md' && grep -q 'Cambio propuesto' '$R/PROPUESTAS.md' && grep -q 'Archivo' '$R/PROPUESTAS.md'"
ok "A2 autoaprendizaje en README ES/EN y SKILL" "grep -q '^## Autoaprendizaje (flujo canónico)' '$R/README.md' && grep -q 'Self-learning (canonical)' '$R/README.md' && grep -q 'Grok Bot revisa y decide' '$R/skill/SKILL.md' && grep -q 'otro revisor' '$R/skill/SKILL.md' && grep -q 'rutina nocturna de AInfluencer' '$R/skill/SKILL.md'"
ok "A3 NSFW preciso: R2 no construido" "grep -q 'todavía no está construido' '$R/README.md' && grep -q 'not built yet' '$R/README.md'"
ok "C1 regla 4l (C17) y 4m (C18) en SKILL, E33/E34 en 04-ERRORES" "grep -q 'Regla 4l' '$R/skill/SKILL.md' && grep -q 'Regla 4m — Solo la vista previa del plugin' '$R/skill/SKILL.md' && grep -q 'ya_enviado_al_usuario' '$R/skill/SKILL.md' && grep -q '^## E33' '$R/docs/04-ERRORES.md' && grep -q '^## E34' '$R/docs/04-ERRORES.md'"
ok "C2 SOUL de Valeria: no repite la vista previa (4m) + CHANGELOG v4.8" "grep -q 'regla 4m' '$R/personajes/valeria/SOUL.md' && grep -q '^## v4.8' '$R/CHANGELOG.md'"
ok "C3 v5.3 llamada directa al Space, sin hoja como entrada" "grep -q 'Regla 4n — El cliente solo recibe la foto final' '$R/skill/SKILL.md' && grep -q '/generate cuando no hay imágenes' '$R/docs/01-PIPELINE.md' && grep -q '^## E35' '$R/docs/04-ERRORES.md' && grep -q '^## v5.3' '$R/CHANGELOG.md' && ! grep -q 'hoja numerada' '$R/skill/SKILL.md' '$R/docs/01-PIPELINE.md' '$R/docs/02-TECNICAS.md'"
ok "CL2 CHANGELOG v4.7" "grep -q '^## v4.7' '$R/CHANGELOG.md'"
ok "CL1 CHANGELOG v4.6" "grep -q '^## v4.6' '$R/CHANGELOG.md'"

# ---------- orden de la llamada (v5.3) ----------
: > "$T/cara.png"; : > "$T/prenda.png"
python3 "$R/tools/armar_hoja.py" --img1 "$T/cara.png" --img3 "$T/prenda.png" > "$T/orden.txt" 2>&1
ok "H1 armar_hoja: /edit_multi con img1 e img3, sin crear una hoja" "grep -q 'OK edit_multi n=2' '$T/orden.txt' && grep -q 'img1=' '$T/orden.txt' && grep -q 'img3=' '$T/orden.txt' && ! [ -f '$T/hoja.png' ]"
python3 "$R/tools/armar_hoja.py" --img3 "$T/prenda.png" > "$T/sincara.txt" 2>&1
ok "H2 armar_hoja: sin img1 → ERROR SIN CARA (no genera)" "grep -q 'ERROR SIN CARA' '$T/sincara.txt'"
python3 "$R/tools/armar_hoja.py" "$T/hoja.png" --cara "$T/cara.png" --qwen34 "$T/e34.png" > "$T/viejo.txt" 2>&1
ok "H3 el comando viejo de hoja numerada se rechaza" "grep -q 'v5.3' '$T/viejo.txt' && ! [ -f '$T/e34.png' ]"

echo; echo "$PASS PASS · $FAIL FAIL"
[ "$FAIL" = 0 ]
