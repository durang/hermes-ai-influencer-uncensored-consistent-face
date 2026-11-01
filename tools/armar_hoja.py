#!/usr/bin/env python3
"""Arma una hoja de referencias numerada (técnica C2).
Uso:
  python3 armar_hoja.py SALIDA.png ref1.png ref2.png [ref3.png ...] [--ancho 1536] [--alto 768] [--principal 1] [--zoom 1.6]
Reglas: panel --principal (cara) es 1.4x más ancho; cada panel se recorta al centro
(cover) para quitar fondo; número grande en la esquina superior izquierda.
"""
import argparse, sys
from PIL import Image, ImageDraw, ImageFont

def fuente(t):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf"]:
        try: return ImageFont.truetype(p, t)
        except OSError: pass
    return ImageFont.load_default()

def cover(img, w, h, foco_y=0.4):
    r = max(w / img.width, h / img.height)
    img = img.resize((round(img.width * r), round(img.height * r)), Image.LANCZOS)
    x = (img.width - w) // 2
    y = int((img.height - h) * foco_y)
    return img.crop((x, y, x + w, y + h))

def main():
    a = argparse.ArgumentParser()
    a.add_argument("salida"); a.add_argument("refs", nargs="+")
    a.add_argument("--ancho", type=int, default=1536); a.add_argument("--alto", type=int, default=768)
    a.add_argument("--zoom", type=float, default=1.0, help="acerca el panel principal (1.0=sin zoom, 1.5=solo cara)")
    a.add_argument("--lugar", help="foto del lugar: SIEMPRE va en su propio panel (el último)")
    a.add_argument("--recibidas", type=int, help="cuántas imágenes mandó el usuario; si no cuadra, se detiene")
    a.add_argument("--principal", type=int, default=1, help="panel cara (1-based); 0 = todos iguales")
    o = a.parse_args()
    if o.lugar: o.refs.append(o.lugar)
    n = len(o.refs)
    if o.recibidas is not None and o.recibidas != n:
        sys.exit(f"ERROR CONTEO: recibiste {o.recibidas} imágenes pero la hoja tendría {n} paneles. Avisa al usuario cuál falta o sobra y por qué; nunca descartes una en silencio.")
    if not 2 <= n <= 6: sys.exit("ERROR: usa de 2 a 6 referencias")
    pesos = [1.4 if (o.principal and i + 1 == o.principal) else 1.0 for i in range(n)]
    sep = 8
    util = o.ancho - sep * (n - 1)
    anchos = [int(util * p / sum(pesos)) for p in pesos]
    anchos[-1] += util - sum(anchos)
    hoja = Image.new("RGB", (o.ancho, o.alto), "white")
    d = ImageDraw.Draw(hoja); f = fuente(int(o.alto * 0.09)); x = 0
    for i, (ruta, w) in enumerate(zip(o.refs, anchos)):
        img = Image.open(ruta).convert("RGB")
        if o.zoom > 1 and i + 1 == (o.principal or 1):
            cw, ch = int(img.width / o.zoom), int(img.height / o.zoom)
            cx, cy = (img.width - cw) // 2, int((img.height - ch) * 0.25)
            img = img.crop((cx, cy, cx + cw, cy + ch))
        hoja.paste(cover(img, w, o.alto), (x, 0))
        t = str(i + 1); pad = int(o.alto * 0.02)
        bb = d.textbbox((0, 0), t, font=f)
        d.rectangle([x + pad, pad, x + pad + bb[2] + 2 * pad, pad + bb[3] + 2 * pad], fill="black")
        d.text((x + 2 * pad, 2 * pad - bb[1] // 2), t, fill="white", font=f)
        x += w + sep
    hoja.save(o.salida)
    print(f"OK {o.salida} lugar_panel={n if o.lugar else '-'} {hoja.size[0]}x{hoja.size[1]} paneles={n} anchos={anchos}")

if __name__ == "__main__":
    main()
