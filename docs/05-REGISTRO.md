# 05 — Registro (bitácora)

Archivo sugerido: `/opt/data/guia-imagen/registro-imagen.md`. Una línea por intento.

## Formato
```
fecha_hora (UTC-7) | petición | tipo | técnica | modelo | ref | seed | guidance/pasos | intento | archivo | QC (cara/pelo/pecas/ojos/iPhone) | enviado | nota
```

## Ejemplos
```
2026-10-31 19:10 | café con suéter | escena nueva | A0 | Qwen 2.1 | ref-1-calle | 42 | 40 | 1 | qwen-cafe-01.png | ❌ mira abajo, aparece un teléfono | no | quitar "holding a phone"
2026-10-31 19:14 | café con suéter | escena nueva | A0 | Qwen 2.1 | ref-1-calle | 42 | 40 | 2 | qwen-cafe-02.png | ✅✅✅✅✅ | sí (ok:true) | "iPhone 12 front-camera photo"
```

## Para el curso
El registro muestra **qué cambió entre un intento fallido y uno bueno**. Es la evidencia para enseñar el método.

## Registro automático
El plugin escribe una línea por intento (solo metadatos, nunca imagen ni datos de fans). Campos nuevos: `confirmado_por_sergio (sí/no)`, `codigo_salida (0/2/3)`.
```
2026-10-31 20:10 | catedral vestido negro | C2 | C2 | Qwen 2.1 | hoja-3-paneles-v2 | 42 | 40 | 1 | qwen-hoja-A.png | ✅ | sí | —
2026-10-31 20:12 | catedral vestido negro | C2 | C2 | Qwen 2.1 | hoja-3-paneles-v2 | 7 | 40 | 2 | qwen-hoja-C.png | ❌ fondo restaurante | no | recortar panel 1
```
