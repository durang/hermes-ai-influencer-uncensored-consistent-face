#!/usr/bin/env python3
"""Comprueba el orden de la llamada (v5.3). No arma hojas ni numera fotos.

/edit_multi es una sola llamada, con 1 a 3 imágenes:
  img1 = base aprobada (obligatoria si hay imágenes)
  img2 = una foto de la segunda persona (opcional)
  img3 = prenda o estilo (opcional)
Sin imágenes, el endpoint es /generate y este script no hace falta.

Uso:
  python3 armar_hoja.py --img1 BASE.png [--img2 PERSONA.png] [--img3 PRENDA.png]
"""
import argparse, os, sys

def existe(ruta, puesto):
    if not os.path.isfile(ruta):
        sys.exit(f"ERROR: no existe {puesto}: {ruta}")
    return ruta

def main():
    a = argparse.ArgumentParser(description="Orden img1/img2/img3 para /edit_multi. No crea imágenes.")
    a.add_argument("--img1", help="base aprobada del personaje")
    a.add_argument("--img2", help="una foto de la segunda persona")
    a.add_argument("--img3", help="prenda o estilo")
    a.add_argument("legado", nargs="*", help=argparse.SUPPRESS)
    o, desconocidos = a.parse_known_args()
    if o.legado or desconocidos or any(x.startswith("--qwen34") or x.startswith("--cara") or x.startswith("--zoom") for x in desconocidos):
        sys.exit("ERROR: las hojas numeradas se retiraron en v5.3. "
                 "Usa --img1 BASE [--img2 PERSONA] [--img3 PRENDA]. "
                 "No se numera ni se manda una hoja al modelo.")
    if not o.img1:
        sys.exit("ERROR SIN CARA: falta la base aprobada (img1). No generes: pide primero esa foto.")
    existe(o.img1, "img1")
    n = 1
    if o.img2:
        existe(o.img2, "img2"); n += 1
    if o.img3:
        existe(o.img3, "img3"); n += 1
    if n > 3:
        sys.exit("ERROR: máximo 3 imágenes en una sola llamada")
    print(f"OK edit_multi n={n} img1={o.img1} img2={o.img2 or '-'} img3={o.img3 or '-'}")
    print("ENDPOINT: /edit_multi (una sola llamada). Sin imágenes usar /generate.")

if __name__ == "__main__":
    main()
