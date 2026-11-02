# 06 — Monetización de Spaces de Hugging Face

Caso: el Space `iccanobif/qwen21-nano-banana` (cuenta Pro, ZeroGPU, privado) y el repo `durang/qwen21-nano-banana-space`. Revisado el 2 nov 2026 contra las páginas oficiales citadas abajo. **No es asesoría legal.** Este documento no cambia ningún nombre: el Space y el repo se quedan como están.

## Respuesta corta

Hugging Face no le paga al dueño cuando otros usan su Space. No hay reparto de ingresos. Con ZeroGPU, cada persona gasta **su** cuota. La cuota del dueño baja solo cuando **él** llama al Space con **su** token (la interfaz autenticada como él, o una API con ese token). La licencia Qwen Research no permite cobrar ni vender con este modelo sin una licencia comercial aparte.

## 1. Hugging Face no reparte ingresos

Revisadas el 2 nov 2026, estas páginas no describen pagos a creadores, reparto de ingresos, propinas ni una tienda de Spaces:

- [Spaces Overview](https://huggingface.co/docs/hub/spaces-overview)
- [Using GPU Spaces](https://huggingface.co/docs/hub/spaces-gpus) (facturación y Community GPU Grants)
- [Spaces ZeroGPU](https://huggingface.co/docs/hub/spaces-zerogpu)
- [Manage your Space](https://huggingface.co/docs/huggingface_hub/guides/manage-spaces) (cuota ZeroGPU)
- [Spaces Launch](https://huggingface.co/spaces/launch)

El dinero que sí documentan va **del dueño hacia Hugging Face**: plan de pago, hardware por hora y créditos prepagados. La conclusión de «no hay monetización nativa» es por ausencia en esa documentación, no porque Hugging Face publique una frase que lo niegue.

Lo que la página de lanzamiento ofrece al creador no es dinero. Dice: «Build your portfolio. Showcase your work to the community, build unique applications, and make new connections with other AI builders.» ([Spaces Launch](https://huggingface.co/spaces/launch)).

Lo único gratuito hacia el creador son las **Community GPU Grants**: hardware donado si el Space les parece interesante. Se piden desde Settings del Space. Es hardware, no un pago. Fuente: [Community GPU Grants](https://huggingface.co/docs/hub/spaces-gpus#community-gpu-grants) y el mismo aviso en [Spaces Overview](https://huggingface.co/docs/hub/spaces-overview).

## 2. Quién gasta la cuota ZeroGPU

Fuentes: [Usage Tiers](https://huggingface.co/docs/hub/spaces-zerogpu#usage-tiers) y [Track your ZeroGPU quota](https://huggingface.co/docs/huggingface_hub/guides/manage-spaces).

La frase oficial: «Each time you use a ZeroGPU Space (from the UI or through its API), some GPU time is deducted from **your personal quota**». La cuota es de la cuenta que usa el Space, no un fondo del Space.

Cuota diaria incluida, según la tabla de Usage Tiers. Se reinicia 24 horas después del primer uso de GPU:

| Cuenta | Cuota diaria | Prioridad de cola |
|---|---|---|
| Sin autenticar | 2 minutos | baja |
| Gratis | 5 minutos | media |
| Pro | 40 minutos (ampliable) | máxima |
| Miembro de una organización Team | 40 minutos (ampliable) | máxima |
| Miembro de una organización Enterprise | 60 minutos (ampliable) | máxima |

- Quien entra sin cuenta gasta esos 2 minutos de la fila «Unauthenticated», no los 40 del dueño.
- Una llamada por API con el token de otra persona se descuenta de la cuota de esa persona.
- El dueño, usándolo desde la interfaz con su sesión o por API con su token, gasta sus 40 minutos Pro.
- Pro, Team y Enterprise pueden seguir después del cupo con créditos prepagados, a **1 USD por 10 minutos**. El texto oficial: «any additional GPU usage is automatically billed against your credit balance». Sin créditos, el límite es la cuota incluida hasta el reinicio.
- `xlarge` cuesta el doble de cuota que `large` (el tamaño por defecto). Fuente: [GPU size selection](https://huggingface.co/docs/hub/spaces-zerogpu).
- Una cuenta Pro puede alojar hasta 10 Spaces ZeroGPU. Una cuenta personal gratis, en regla (correo verificado y más de 30 días), puede alojar hasta 2. Fuente: [Hosting Limitations](https://huggingface.co/docs/hub/spaces-zerogpu).

**¿Gastan otros la cuota Pro del dueño?** No, leído ese texto: cada uso descuenta la cuota personal de quien usa. La excepción práctica es la misma frase: si una web o un bot llama al Space con **el token del dueño**, esas llamadas son uso suyo y salen de **su** cuota y, si se pasa, de sus créditos.

## 3. Privado, protegido y público

Fuente: [Space visibility](https://huggingface.co/docs/hub/spaces-overview).

| Visibilidad | Quién ve el código | Quién usa la app |
|---|---|---|
| Privado | Dueño y colaboradores | Solo ellos. Para los demás la URL responde 404 y el Space no sale en la búsqueda |
| Protegido (plan Pro, Team o Enterprise) | Dueño y colaboradores | La app se puede abrir por la URL de embed o un dominio propio; el código no se clona |
| Público | Cualquiera | Cualquiera, y cualquiera puede clonarlo |

Hoy `iccanobif/qwen21-nano-banana` está privado: no hay uso ajeno ni visibilidad. Si se hace público, cada visitante gasta su propia cuota (sección 2). También queda a la vista el código. El modelo es una cuantización «Uncensored» de terceros, sin filtro propio: publicarlo con generación de adultos choca con la [política de contenido de Hugging Face](https://huggingface.co/content-policy) y no conviene con fotos de personas reales (regla 4i).

## 4. Cómo se podría cobrar fuera de Hugging Face

Nada de esto existe dentro de Spaces. Y la sección 6 lo frena: **con esta licencia, hoy no se puede cobrar** por las fotos de este modelo.

1. **Web propia y pagos propios** (Stripe u otro) que llamen al Space por API con el token del dueño. Entonces **todo** ese uso sale de sus 40 minutos al día y después de sus créditos (1 USD / 10 minutos). ZeroGPU no escala ese esquema.
2. **Hardware dedicado de pago.** Se cobra por minuto encendido «regardless of whether the Space is used», solo en estado Starting o Running ([Billing](https://huggingface.co/docs/hub/spaces-gpus#billing)). Precios por hora en esa tabla (2 nov 2026): T4 small 0,40 USD, L4 0,80 USD, A10G small 1,00 USD, L40S 1,80 USD, A100 large 2,50 USD, RTX PRO 6000 2,75 USD. Cada réplica se cobra aparte. Con «sleep time» no se cobra mientras duerme. Un L40S dejado encendido 24/7 sale a 1,80 × 24 × 30 ≈ 1.300 USD al mes; esa cuenta es aritmética sobre el precio por hora, no una cifra publicada por Hugging Face.
3. **Que cada quien pague su cuota:** login de Hugging Face en el Space, o límites en la web propia. Así el uso no sale del token del dueño.
4. **Embudo:** el Space como demostración y el cobro en otro servicio. Sigue valiendo la sección 6 para cualquier cosa hecha con estas fotos.

## 5. Beneficios que no son dinero

Likes, aparecer en listados de la comunidad, portafolio, reputación, seguidores, contactos y la posibilidad de una Community GPU Grant. Fuente: [Spaces Launch](https://huggingface.co/spaces/launch).

## 6. Licencia Qwen Research

El Space usa [abenzerps/Qwen-Image-2.1-Uncensored-GGUF](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF) (`license_name: qwen-research`, `base_model: Qwen/Qwen-Image-2.1`). Es un modelo derivado y queda bajo la licencia del base.

Texto de la [Qwen RESEARCH LICENSE AGREEMENT](https://huggingface.co/Qwen/Qwen-Image-2.1/blob/main/LICENSE) (20 sep 2026). «We» es Hangzhou Tongyi Laboratory Technology Co., Ltd.:

- 1.i: «"Non-Commercial" shall mean for research or evaluation purposes only.»
- 2.a: licencia «FOR NON-COMMERCIAL PURPOSES ONLY» para usar, reproducir, distribuir, copiar, crear obras derivadas y modificar los Materials.
- 2.b: «You shall not use the Materials for any commercial purpose without obtaining a separate commercial license from us.» La solicitud va a `model-business@notice.qwencloud.com`.
- 3.c: en las copias que se distribuyan, un archivo «Notice» con «Qwen is licensed under the Qwen RESEARCH LICENSE AGREEMENT, Copyright (c) 2026 Hangzhou Tongyi Laboratory Technology Co., Ltd. All Rights Reserved.»
- 4.b: si las salidas entrenan o mejoran un modelo que se distribuye, hay que mostrar «Built with Qwen» o «Improved using Qwen».

**Conclusión:** sin esa licencia comercial no se puede cobrar ni usar estas fotos para vender, incluido monetizar a la influencer, el curso, Fanvue o las redes. Solo investigación o evaluación. Lo decide el dueño con su abogado. Esto no es asesoría legal.

## 7. Nombres: cláusula 4.c y «Nano Banana»

Cláusula 4.c, cita literal: «You shall not use "Qwen" as the primary name or identifier of any derivative works or products; reasonable descriptive use (e.g., "fine-tuned from Qwen Image") is permitted.»

El identificador del Space (`qwen21-nano-banana`) y el del repo (`qwen21-nano-banana-space`) llevan «qwen» en el nombre. Puede chocar con 4.c si ese identificador es el nombre principal del producto. La propia cláusula permite un uso descriptivo, del estilo «built on Qwen Image 2.1».

Aparte, **«Nano Banana» es el nombre que Google le da a la generación de imágenes de Gemini.** La documentación oficial abre así: «Nano Banana is the name for Gemini's native image generation capabilities.» Fuente: [Nano Banana image generation](https://ai.google.dev/gemini-api/docs/image-generation). Usar esas palabras como nombre de producto puede chocar con esa marca. En esta skill, «reglas tipo Nano Banana» describe un modo de trabajo (pocas imágenes, un cambio por paso), no es el nombre del producto.

**No se renombra.** Este documento no cambia `iccanobif/qwen21-nano-banana` ni `durang/qwen21-nano-banana-space`. Si algún día se cambian, lo decide el dueño con su abogado; no lo hace la skill ni un push automático.
