# Reglas de este repo

Instrucciones de comportamiento para trabajar en este repo. Para el contenido y estado del proyecto (tema, datos, deadlines), ver `CONTEXT.md` — no duplicar eso acá, solo reglas de cómo operar.

## Tono

Repo visible para el director y el co-director. Todo el contenido debe leerse como una descripción directa y profesional del proyecto — sin lenguaje persuasivo, sin comparaciones de alternativas de trabajo, sin meta-comentarios sobre el propio contenido del repo.

## Presentación

La presentación de cátedra vive en `Presentaciones/02-presentacion_plan_de_trabajo.html` (+ `.pdf`). Es un deck HTML/CSS propio (estética dark data-science, Manrope + JetBrains Mono, acento cian) — **no es Beamer/LaTeX**, no reintroducir ese enfoque salvo pedido explícito. Para actualizarla: editar el `.html` directamente y regenerar el PDF con Chrome headless:

```
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu \
  --no-pdf-header-footer --print-to-pdf="Presentaciones/02-presentacion_plan_de_trabajo.pdf" \
  --virtual-time-budget=8000 "file://$(pwd)/Presentaciones/02-presentacion_plan_de_trabajo.html"
```

(El `.html` trae su propio `@media print { @page{ size: 13.333in 7.5in; } }` para que cada slide salga como una página completa.)

## Documento escrito (propuesta formal)

Vive en `TP Latex/Project/main.tex`. Se compila con `pdflatex` + `bibtex` (dos pasadas de `pdflatex` después del `bibtex`), nunca a mano ni con otra herramienta. Limpiar los archivos auxiliares (`.aux .bbl .blg .log .out .toc .fls .fdb_latexmk`) después de compilar, no commitearlos.

## BigQuery

Usar siempre `bigquery/run_query.sh` para extracciones de datos de la tesis (nunca `bq query` a mano), y seguir la convención completa de `bigquery/CLAUDE.md` (subcarpeta por tabla consultada, con **guiones bajos en vez de puntos** en el nombre de carpeta — una carpeta terminada en `.pages`, `.app`, `.key`, etc. rompe Finder en macOS). Excepción: una verificación puntual de un solo valor (ej. chequear si hay filas duplicadas) puede correrse con `bq query` directo si es más simple — pero igual queda versionada como `.sql`+`.parquet` en su subcarpeta y anotada a mano en `usage-log.csv`, nunca sin registro. Antes de correr cualquier query (por `run_query.sh` o a mano), mostrar el costo del dry-run y esperar confirmación explícita del usuario — nunca auto-confirmar.

## Datos de carátula

Alumno: Moccagatta, Nicolás (Leg. 106396). Director: **Ariel Olaf Salgado Corrado**. Co-Director: **Carlos Sarraute**. Estos dos nombres completos van siempre juntos, en cualquier carátula o cierre (presentación y documento escrito).

## Mantenimiento de `CONTEXT.md`

Cuando cambie algo estructural del proyecto (deadlines, estado del tema, estructura de carpetas), actualizar `CONTEXT.md`. Mantenerlo conciso: hechos del proyecto tal como está hoy.
