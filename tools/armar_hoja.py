#!/usr/bin/env python3
"""Hoja de referencias numerada (técnica C2) — v3 (E27/E30/E31).

Dos salidas:
  1) Hoja de confirmación (la ve el dueño): cada foto en su panel con su PROPORCIÓN
     ORIGINAL (contain, nunca se estira), centrada sobre gris neutro.
  2) --qwen34 SALIDA34.png: entrada para Qwen 2.1 = rejilla 3:4 de 1152x1536 en
     2 columnas, recorte centrado SIN estirar y SIN relleno gris. Si el número de
     paneles es impar, el último ocupa todo el ancho de su fila. Misma numeración.

Uso:
  python3 armar_hoja.py HOJA.png ref1.png [ref2.png ...] [--lugar lugar.jpg]
         [--recibidas N] [--qwen34 ENTRADA34.png]
Imprime el mapa de paneles y verificación de proporción (error ≤1 %).
"""
import argparse, math, sys
from PIL import Image, ImageDraw, ImageFont

GRIS = (128, 128, 128)

def fuente(t):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf"]:
        try: return ImageFont.truetype(p, t)
        except OSError: pass
    return ImageFont.load_default()

def contain(img, w, h):
    r = min(w / img.width, h / img.height)
    return img.resize((max(1, round(img.width * r)), max(1, round(img.height * r))), Image.LANCZOS)

def cover(img, w, h, foco_y=0.35):
    r = max(w / img.width, h / img.height)  # mismo factor en x e y: no estira
    img = img.resize((max(w, round(img.width * r)), max(h, round(img.height * r))), Image.LANCZOS)
    x = (img.width - w) // 2; y = int((img.height - h) * foco_y)
    return img.crop((x, y, x + w, y + h))

def numero(d, x, y, t, alto):
    f = fuente(max(18, int(alto * 0.08))); pad = max(4, int(alto * 0.02))
    bb = d.textbbox((0, 0), t, font=f)
    d.rectangle([x + pad, y + pad, x + 3 * pad + bb[2], y + 3 * pad + bb[3]], fill="black")
    d.text((x + 2 * pad, y + 2 * pad - bb[1] // 2), t, fill="white", font=f)

def hoja_confirmacion(imgs, salida, alto=768, sep=8):
    # ancho de cada panel = proporción original de la foto a la altura dada
    anchos = [round(alto * im.width / im.height) for im in imgs]
    W = sum(anchos) + sep * (len(imgs) - 1)
    hoja = Image.new("RGB", (W, alto), GRIS); d = ImageDraw.Draw(hoja); x = 0; info = []
    for i, (im, w) in enumerate(zip(imgs, anchos)):
        p = contain(im, w, alto); hoja.paste(p, (x + (w - p.width) // 2, (alto - p.height) // 2))
        err = abs(p.width / p.height - im.width / im.height) / (im.width / im.height) * 100
        info.append(f"{i+1}:{err:.2f}%"); numero(d, x, 0, str(i + 1), alto); x += w + sep
    hoja.save(salida); return hoja.size, info

def entrada_qwen34(imgs, salida, W=1152, H=1536):
    n = len(imgs); filas = math.ceil(n / 2); hs = [H // filas] * filas; hs[-1] += H - sum(hs)
    lienzo = Image.new("RGB", (W, H)); d = ImageDraw.Draw(lienzo); k = 0; y = 0
    for f, h in enumerate(hs):
        cols = 1 if (k == n - 1) else 2
        ws = [W // cols] * cols; ws[-1] += W - sum(ws); x = 0
        for w in ws:
            lienzo.paste(cover(imgs[k], w, h), (x, y)); numero(d, x, y, str(k + 1), h); x += w; k += 1
        y += h
    lienzo.save(salida); return lienzo.size

def main():
    a = argparse.ArgumentParser()
    a.add_argument("salida"); a.add_argument("refs", nargs="+")
    a.add_argument("--lugar", help="foto del lugar: SIEMPRE en su propio panel (el último)")
    a.add_argument("--recibidas", type=int, help="imágenes que mandó el usuario; si no cuadra, se detiene")
    a.add_argument("--alto", type=int, default=768)
    a.add_argument("--qwen34", help="ruta de la entrada 3:4 1152x1536 para Qwen 2.1")
    a.add_argument("--zoom", type=float, default=1.0, help="recorta el panel 1 hacia la cara (mantiene proporción; 1.0 = sin zoom)")
    a.add_argument("--principal", type=int, default=0, help="(obsoleto v2, se ignora: los paneles ya no se ensanchan)")
    o = a.parse_args()
    refs = list(o.refs) + ([o.lugar] if o.lugar else [])
    n = len(refs)
    if o.recibidas is not None and o.recibidas != n:
        sys.exit(f"ERROR CONTEO: recibiste {o.recibidas} imágenes pero la hoja tendría {n} paneles. "
                 "Avisa al usuario cuál falta o sobra y por qué; nunca descartes una en silencio.")
    if not 1 <= n <= 6: sys.exit("ERROR: usa de 1 a 6 referencias")
    imgs = [Image.open(r).convert("RGB") for r in refs]
    if o.zoom > 1:  # mismo factor en ancho y alto: no deforma
        im = imgs[0]; cw, ch = int(im.width / o.zoom), int(im.height / o.zoom)
        cx, cy = (im.width - cw) // 2, int((im.height - ch) * 0.25); imgs[0] = im.crop((cx, cy, cx + cw, cy + ch))
    size, info = hoja_confirmacion(imgs, o.salida, o.alto)
    print(f"OK hoja {o.salida} {size[0]}x{size[1]} paneles={n} lugar_panel={n if o.lugar else '-'} error_proporcion={' '.join(info)}")
    for i, r in enumerate(refs): print(f"  panel {i+1} = {r}")
    if o.qwen34:
        s = entrada_qwen34(imgs, o.qwen34); print(f"OK qwen34 {o.qwen34} {s[0]}x{s[1]} (2 columnas, sin relleno, sin estirar)")

if __name__ == "__main__":
    main()
