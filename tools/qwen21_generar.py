#!/usr/bin/env python3
"""Genera con Qwen-Image 2.1 Studio (técnica A0 / C2) vía API (gradio_client + HF_TOKEN) y guarda el PNG local.
Uso: HF_TOKEN=... python3 qwen21_generar.py REF_O_HOJA.png "PROMPT" SALIDA.png [--seed 42] [--aspect "Portrait · 3:4"] [--steps 40]
Pasos: 40 por defecto. Más pasos = más detalle pero más lento; arriba de 40 casi no se nota (máx. del Space ~50).
Prohibido: dynamic_space y navegador. Si hay error de cuota se imprime el ERROR EXACTO de la API (sale con código 3).
"""
import argparse, os, shutil, sys, time
from gradio_client import Client, handle_file
SPACE = os.environ.get("QWEN21_SPACE", "assembledchaos/qwen-image-2-1-studio")
a = argparse.ArgumentParser()
a.add_argument("ref"); a.add_argument("prompt"); a.add_argument("salida")
a.add_argument("--seed", type=int, default=42); a.add_argument("--steps", type=int, default=40)
a.add_argument("--aspect", default="Portrait · 3:4")
o = a.parse_args()
if not os.environ.get("HF_TOKEN"): sys.exit("ERROR: falta HF_TOKEN (sin token HF te trata como anónimo y la cuota es mucho menor)")
if o.steps > 50: sys.exit("ERROR: máximo ~50 pasos")
if o.steps > 40: print(f"AVISO: {o.steps} pasos tardará más y casi no mejora sobre 40")
if not os.path.isfile(o.ref) or os.path.getsize(o.ref) < 50_000: sys.exit("ERROR E2: referencia no existe o pesa <50 KB")
for intento, espera in enumerate([20, 40, 80], 1):
    try:
        c = Client(SPACE, token=os.environ["HF_TOKEN"])
        r = c.predict(o.prompt, "Edit an image", handle_file(o.ref), o.aspect, o.steps, o.seed, False, api_name="/generate")
        src = r[1] if isinstance(r, (list, tuple)) else r
        src = src.get("path", src) if isinstance(src, dict) else src
        shutil.copy(src, o.salida)   # nunca reenviar URL hf.space
        kb = os.path.getsize(o.salida) // 1024
        if kb < 200: raise RuntimeError(f"salida muy chica ({kb} KB)")
        print(f"OK {o.salida} {kb} KB seed={o.seed} steps={o.steps} intento={intento}"); sys.exit(0)
    except Exception as e:
        m = str(e)
        if "quota" in m.lower() or "exceeded" in m.lower():
            print(f"CUOTA (error exacto de la API, muéstralo tal cual al usuario): {type(e).__name__}: {m}"); sys.exit(3)
        print(f"intento {intento} falló: {type(e).__name__}: {m[:300]}"); time.sleep(espera)
print("ERROR: 3 intentos fallidos"); sys.exit(2)
