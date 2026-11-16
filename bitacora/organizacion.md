# Organización de cada entrega

Reglas de cómo se arma cada entrega en `bitacora/bitacora.html`, de ahora en más. Al editar la bitácora, seguir este archivo. Si el usuario define una regla nueva, agregarla acá en el momento.

## Cabecera fija

Este bloque se mantiene igual en todas las entregas. No cambiar textos, orden ni estilos.

Arriba, la portada (una sola, visible en cada página):

- Eyebrow: `Maestría en Ciencia de Datos · ITBA · Bitácora de tesis`
- Título: `Efecto causal de las migraciones de tecnología frontend sobre la experiencia de usuario real`
- Bajada del panel longitudinal (HTTP Archive + Chrome UX Report, diferencias en diferencias).
- `Alumno: Moccagatta, Nicolás · Leg. 106396` · `Director: Ariel Olaf Salgado Corrado` · `Co-Director: Carlos Sarraute`

Debajo, la fila de la entrega y su título:

```html
<section id="entrega-N" class="entrega" data-titulo="Entrega N" data-fecha="YYYY-MM-DD" data-estado="En curso">
  <div class="entrega-cab"></div>
  <h2>Título de la entrega</h2>
  <div class="sec-meta">Formato de entrega: esta bitácora</div>
```

`entrega-cab` lo completa el script: número, fecha (`XX/XX` si `data-fecha` está vacío) y el badge. No armar esa fila a mano.

Después de la cabecera, el trabajo del período va en un `<details class="trabajo">` cerrado. El título es el `<summary>`: "Trabajo desde la entrega anterior" (en la entrega 1, "Trabajo previo a la entrega").

Los ítems salen de `bitacora/changelog.md`. Cada avance se anota ahí, en la entrega que corresponde, con su fecha. `armar_bitacora.py` copia esa lista al HTML. No se redacta en el HTML ni se reconstruye de memoria.

## Badge

- Mientras se arma la entrega y el día de la presentación, el badge dice **En curso** (`data-estado="En curso"`).
- **Presentada** solo cuando el usuario avisa que ya presentó. Ahí se pone `data-estado="Presentada"`.
- No pasar el badge a Presentada el día de la reunión ni antes del aviso.

## Índice

Cada entrega del índice lateral se pliega. Al abrir esa entrega se muestran sus subsecciones. El control no cambia de página.

## Lo que se mostró

Si la entrega se dio con un deck de `Presentaciones/`, el cuerpo reproduce esas diapositivas: las mismas tablas, las mismas cifras y los mismos gráficos. No se agregan cortes, columnas ni secciones que no se hayan mostrado. Una cifra corregida después se muestra vigente, con una nota de lo presentado y de cuándo se corrigió. "Trabajo desde la entrega anterior" sigue siendo el registro del período.

## Un PR por entrega

- Cada entrega tiene su propio PR. No mezclar dos entregas en el mismo PR.
- El PR no se mergea desde acá. Con el badge en Presentada, el usuario mergea.
