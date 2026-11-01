#!/usr/bin/env python3
"""Hoja de referencias numerada (técnica C2) — v3 (E27/E30/E31).

Dos salidas:
  1) Hoja de confirmación (la ve el dueño): cada foto en su panel con su PROPORCIÓN
     ORIGINAL (contain, nunca se estira), centrada sobre gris neutro.
  2) --qwen34 SALIDA34.png: entrada para Qwen 2.1 = rejilla 3:4 de 1152x1536 en
     2 columnas, recorte centrado SIN estirar y SIN relleno gris. Si el número de
     paneles es impar, el último ocupa todo el ancho de su fila. Misma numeración.

Uso (v4):
  python3 armar_hoja.py HOJA.png --cara personajes/<nombre>/ref/ref-1-*.png \
         [--extra ropa:camisa.jpg] [--extra objeto:x.jpg] [--extra persona:y.jpg] \
         [--extra lugar:bar.jpg | --lugar bar.jpg] [--recibidas N] [--qwen34 ENTRADA34.png]
  Panel 1 = SIEMPRE la cara guardada del personaje (nunca una prenda).
  Las imágenes del cliente son paneles extra con rol: ropa, objeto, lugar, persona.
  El lugar siempre va al final. --recibidas cuenta solo las imágenes del cliente.
Imprime el mapa de paneles y verificación de proporción (error ≤1 %).
"""
import argparse, math, os, sys
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

ROLES = {"cara": "cara", "ropa": "ropa", "objeto": "objeto", "lugar": "lugar", "persona": "persona"}
PROMPT_ROL = {"cara": "the character's face (identity)", "ropa": "{} to wear", "objeto": "object to include",
              "lugar": "the place", "persona": "another person, appears once"}

def numero(d, x, y, t, alto):
    f = fuente(max(18, int(alto * 0.08))); pad = max(4, int(alto * 0.02))
    bb = d.textbbox((0, 0), t, font=f)
    d.rectangle([x + pad, y + pad, x + 3 * pad + bb[2], y + 3 * pad + bb[3]], fill="black")
    d.text((x + 2 * pad, y + 2 * pad - bb[1] // 2), t, fill="white", font=f)

def hoja_confirmacion(imgs, salida, alto=768, sep=8, etiquetas=None):
    # ancho de cada panel = proporción original de la foto a la altura dada
    anchos = [round(alto * im.width / im.height) for im in imgs]
    W = sum(anchos) + sep * (len(imgs) - 1)
    hoja = Image.new("RGB", (W, alto), GRIS); d = ImageDraw.Draw(hoja); x = 0; info = []
    for i, (im, w) in enumerate(zip(imgs, anchos)):
        p = contain(im, w, alto); hoja.paste(p, (x + (w - p.width) // 2, (alto - p.height) // 2))
        err = abs(p.width / p.height - im.width / im.height) / (im.width / im.height) * 100
        info.append(f"{i+1}:{err:.2f}%"); numero(d, x, 0, f"{i+1} {etiquetas[i]}" if etiquetas else str(i + 1), alto); x += w + sep
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
    a.add_argument("salida"); a.add_argument("refs", nargs="*", help="(legado) refs sin rol = persona")
    a.add_argument("--cara", help="cara guardada del personaje: personajes/<nombre>/ref/... (OBLIGATORIA)")
    a.add_argument("--extra", action="append", default=[], help="ROL:RUTA, rol = ropa|objeto|lugar|persona (repetible)")
    a.add_argument("--lugar", help="atajo de --extra lugar:RUTA")
    a.add_argument("--recibidas", type=int, help="imágenes que mandó el cliente; si no cuadra, se detiene")
    a.add_argument("--alto", type=int, default=768)
    a.add_argument("--qwen34", help="ruta de la entrada 3:4 1152x1536 para Qwen 2.1")
    a.add_argument("--zoom", type=float, default=1.0, help="recorta el panel 1 hacia la cara (sin deformar)")
    a.add_argument("--principal", type=int, default=0, help="(obsoleto, se ignora)")
    o = a.parse_args()
    if not o.cara or not os.path.isfile(o.cara):
        sys.exit("ERROR SIN CARA: no hay foto de cara guardada del personaje (personajes/<nombre>/ref/). "
                 "No generes: pide primero la foto de cara.")
    extras = [("persona", r) for r in o.refs]
    for e in o.extra:
        rol, _, ruta = e.partition(":")
        if rol not in ROLES or rol == "cara" or not ruta: sys.exit(f"ERROR ROL: '{e}' debe ser ropa|objeto|lugar|persona:RUTA")
        extras.append((rol, ruta))
    if o.lugar: extras.append(("lugar", o.lugar))
    extras = [x for x in extras if x[0] != "lugar"] + [x for x in extras if x[0] == "lugar"]
    if o.recibidas is not None and o.recibidas != len(extras):
        sys.exit(f"ERROR CONTEO: el cliente mandó {o.recibidas} imágenes pero hay {len(extras)} paneles extra. "
                 "Avisa cuál falta o sobra y por qué; nunca descartes una en silencio.")
    paneles = [("cara", o.cara)] + extras
    if len(paneles) > 6: sys.exit("ERROR: máximo 6 paneles (cara + 5)")
    imgs = [Image.open(r).convert("RGB") for _, r in paneles]
    if o.zoom > 1:
        im = imgs[0]; cw, ch = int(im.width / o.zoom), int(im.height / o.zoom)
        cx, cy = (im.width - cw) // 2, int((im.height - ch) * 0.25); imgs[0] = im.crop((cx, cy, cx + cw, cy + ch))
    roles = [r for r, _ in paneles]
    size, info = hoja_confirmacion(imgs, o.salida, o.alto, etiquetas=roles)
    print(f"OK hoja {o.salida} {size[0]}x{size[1]} paneles={len(paneles)} error_proporcion={' '.join(info)}")
    for i, (r, ruta) in enumerate(paneles): print(f"  panel {i+1} = {r}: {ruta}")
    mapa = "; ".join(f"panel {i+1} = " + PROMPT_ROL[r].format("garment") for i, (r, _) in enumerate(paneles))
    print(f"PROMPT_PANELES: {mapa}")
    if o.qwen34:
        s = entrada_qwen34(imgs, o.qwen34); print(f"OK qwen34 {o.qwen34} {s[0]}x{s[1]} (2 columnas, sin relleno, sin estirar)")

if __name__ == "__main__":
    main()
