---
name: bitacora
description: >
  Arma y actualiza cada entrega de la bitácora de tesis en bitacora/bitacora.html
  según bitacora/organizacion.md. Usar cuando el usuario dice /bitacora, pide una
  entrega, la bitácora, el badge En curso o Presentada, o el PR de una entrega.
---

# Bitácora

1. Leer `bitacora/organizacion.md` y seguirlo. Si el usuario define cómo se muestra una entrega, agregar esa regla a ese archivo en el mismo cambio.
2. Editar `bitacora/bitacora.html`. No crear decks en `Presentaciones/`.
3. El badge queda **En curso** el día de la presentación. **Presentada** solo cuando el usuario avisa que ya presentó.
4. Un PR por entrega. No mergear: lo mergea el usuario después del badge Presentada.
5. "Trabajo desde la entrega anterior" es un `<details class="trabajo">` cerrado en cada entrega. En la entrega 1 el título es "Trabajo previo a la entrega". Los ítems se agregan en `bitacora/changelog.md` y se copian al HTML con `armar_bitacora.py`. No se escriben en el HTML ni se arman de memoria.
6. Si la entrega se dio con un deck, el cuerpo reproduce esas diapositivas y nada más. Una cifra corregida después lleva la nota de lo presentado y de cuándo se corrigió.
