#!/usr/bin/env python3
"""Regla 4r (C24): juez de cuerpo con tope en ambos sentidos.
vb = veredicto de la base (recorte de los paneles de cuerpo completo de la hoja del personaje),
vs = veredicto de la salida. Cada uno: {"busto","cadera","cintura","complexion","caras_repetidas","manos_bien"}.
Las medidas reales del personaje viven SOLO en personajes/<nombre>/perfil.json (privado, fuera del repo)."""
ESCALA = ["small", "medium", "large", "very large"]

def comparar_cuerpo(vb, vs, tope_mas=1, tope_menos=0):
    """C18: tope en AMBOS sentidos para busto y cadera (ESCALA): salida < base - tope_menos (menor) o > base + tope_mas
    (exagerado) → motivo. Cadera «not visible» se omite. Cintura ±1. Complexión igual a la base."""
    mot = []; i = lambda v, k: ESCALA.index(v.get(k)) if v.get(k) in ESCALA else -1
    for k in ("busto", "cadera"):
        if k == "cadera" and (vs.get(k) == "not visible" or vb.get(k) == "not visible"): continue
        b, o = i(vb, k), i(vs, k)
        if b < 0: continue  # base sin dato: no se puede comparar
        if o < b - tope_menos: mot.append(f"juez cuerpo: {k} {vs.get(k)} menor que la base {vb.get(k)}")
        elif o > b + tope_mas: mot.append(f"juez cuerpo: {k} {vs.get(k)} exagerado frente a la base {vb.get(k)} (tope +{tope_mas})")
    if i(vb, "cintura") >= 0 and abs(i(vs, "cintura") - i(vb, "cintura")) > 1: mot.append(f"juez cuerpo: cintura {vs.get('cintura')} vs base {vb.get('cintura')}")
    if vb.get("complexion") and vs.get("complexion") != vb.get("complexion"): mot.append(f"juez cuerpo: complexión {vs.get('complexion')} vs base {vb.get('complexion')}")
    if vs.get("caras_repetidas") is not False: mot.append("juez: caras repetidas")
    if vs.get("manos_bien") is not True: mot.append("juez: manos mal")
    return mot
if __name__ == "__main__":
    import json, sys
    vb, vs = json.loads(sys.argv[1]), json.loads(sys.argv[2])
    m = comparar_cuerpo(vb, vs)
    print(json.dumps({"ok": not m, "motivos": m}, ensure_ascii=False))
