#!/usr/bin/env python3
"""Calibración manual en el host. El bot no lo usa y esto no entrega al cliente.

Space por defecto: iccanobif/qwen21-nano-banana (variable QWEN21_SPACE).
- 1 a 3 imágenes: una sola llamada a /edit_multi.
  img1 = base aprobada, img2 = una foto de la 2.ª persona, img3 = prenda o estilo.
- Sin imágenes: /generate.
Reintentos internos, máximo 3, cada uno con otra semilla.
El juez de visión lo hace Hermes antes de entregar; este script no manda a Telegram.

Requiere la variable de entorno HF_TOKEN. No la escribas en la línea de comando.
"""
import argparse, os, shutil, sys, time
from gradio_client import Client, handle_file

SPACE = os.environ.get("QWEN21_SPACE", "iccanobif/qwen21-nano-banana")

def archivo(ruta):
    return handle_file(ruta) if ruta else None

def main():
    a = argparse.ArgumentParser()
    a.add_argument("prompt")
    a.add_argument("salida")
    a.add_argument("--img1")
    a.add_argument("--img2")
    a.add_argument("--img3")
    a.add_argument("--modo", default="edit")
    a.add_argument("--seed", type=int, default=42)
    a.add_argument("--steps", type=int, default=40)
    a.add_argument("--aspect", default="Portrait · 3:4")
    o = a.parse_args()
    if not os.environ.get("HF_TOKEN"):
        sys.exit("ERROR: falta la variable de entorno HF_TOKEN")
    if o.steps > 50:
        sys.exit("ERROR: máximo ~50 pasos")
    imgs = [o.img1, o.img2, o.img3]
    presentes = [r for r in imgs if r]
    if len(presentes) > 3:
        sys.exit("ERROR: máximo 3 imágenes")
    if presentes and not o.img1:
        sys.exit("ERROR SIN CARA: con imágenes, img1 (base aprobada) es obligatoria")
    for r in presentes:
        if not os.path.isfile(r) or os.path.getsize(r) < 50_000:
            sys.exit(f"ERROR E2: no existe o pesa <50 KB: {r}")
    endpoint = "/generate" if not presentes else "/edit_multi"
    for intento in range(1, 4):
        semilla = o.seed + intento - 1
        try:
            c = Client(SPACE, token=os.environ["HF_TOKEN"])
            if endpoint == "/generate":
                r = c.predict(o.prompt, o.aspect, o.steps, semilla, False, api_name="/generate")
            else:
                r = c.predict(o.modo, o.prompt, archivo(o.img1), archivo(o.img2), archivo(o.img3),
                              o.aspect, o.steps, semilla, False, api_name="/edit_multi")
            src = r[1] if isinstance(r, (list, tuple)) else r
            src = src.get("path", src) if isinstance(src, dict) else src
            shutil.copy(src, o.salida)
            kb = os.path.getsize(o.salida) // 1024
            if kb < 200:
                raise RuntimeError(f"salida muy chica ({kb} KB)")
            print(f"OK {o.salida} {kb} KB endpoint={endpoint} seed={semilla} steps={o.steps} intento={intento}")
            print("NO ENVIAR: falta el juez de visión de Hermes. El cliente solo recibe la foto final.")
            return 0
        except Exception as e:
            m = str(e)
            if "quota" in m.lower() or "exceeded" in m.lower():
                print(f"CUOTA (error exacto de la API): {type(e).__name__}: {m}")
                return 3
            print(f"intento {intento} seed={semilla} falló: {type(e).__name__}: {m[:300]}")
            if intento < 3:
                time.sleep(20 * intento)
    print("ERROR: 3 intentos internos fallidos. No se entrega foto al cliente.")
    return 2

if __name__ == "__main__":
    sys.exit(main())
