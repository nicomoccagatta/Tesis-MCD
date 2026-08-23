# Contexto del proyecto de tesis

Repo de la tesis de la Maestría en Ciencia de Datos (ITBA) de Nicolás Moccagatta (Leg. 106396). Director: **Ariel Olaf Salgado Corrado**. Co-Director: **Carlos Sarraute**.

## Tema

Estimar el efecto causal de las migraciones de tecnología frontend (por ejemplo, jQuery a React, o el abandono de WordPress) sobre la experiencia de usuario real, medida con Core Web Vitals (LCP, INP, CLS). Cada migración detectada en los crawls mensuales de HTTP Archive se trata como un cuasi-experimento natural, con un diseño de diferencias en diferencias robusto a tratamiento escalonado sobre un panel construido a partir de HTTP Archive (tecnología detectada) y CrUX (experiencia real de usuario), ambos en BigQuery.

**Contexto:** Core Web Vitals son las métricas que Google usa para estandarizar la "velocidad percibida" de un sitio, recolectadas de navegadores Chrome reales y publicadas mensualmente en CrUX (Chrome User Experience Report). HTTP Archive rastrea mensualmente millones de sitios y detecta, vía Wappalyzer, qué tecnología frontend usa cada uno. La industria migra constantemente de tecnología prometiendo mejoras de performance, pero rara vez lo valida con evidencia rigurosa: se apoya en casos de éxito puntuales, benchmarks de laboratorio o comparaciones de sitios distintos en un mismo momento (que confunden tecnología con otros factores).

## Estado de la cuestión (el gap)

- **Evidencia industrial** (Core Web Vitals Technology Report y Web Almanac, ambos de HTTP Archive): transversal y correlacional — compara sitios distintos en un corte del tiempo, sin seguimiento longitudinal ni control de confounders.
- **Literatura académica sobre frameworks**: benchmarks de laboratorio a pequeña escala sobre aplicaciones de prueba (Tong, Jikson & Gunawan 2023), o síntesis narrativa sin datos propios (Tulsyan et al. 2024).
- **Uso descriptivo de CrUX a escala** (Sengupta et al. 2023): caracteriza la experiencia de navegación por dispositivo/país, pero no estudia tecnología ni migraciones.
- **Revisión sistemática** (Ghattas, Odeh & Mora 2025, 6.657 estudios 2010-2024): confirma que no existen estudios que estimen el efecto de decisiones tecnológicas concretas sobre experiencia de usuarios reales.
- **El vacío:** ningún trabajo combina seguimiento longitudinal de los mismos sitios + experiencia de usuario real (no de laboratorio) + diseño con lectura causal.
- **Precedente de legitimidad de los datasets:** Ruth, Kumar, Wang, Valenta & Durumeric (2022, ACM IMC) validan a CrUX como el ranking de sitios más preciso entre los evaluados. Beugin, Barford & McDaniel (2026, arXiv) combinan HTTP Archive + CrUX en un diseño longitudinal de 7 años para caracterizar adopción/abandono de APIs web — el precedente estructural más parecido, aunque su objetivo es descriptivo (adopción), no estimar efecto causal sobre una métrica de resultado.
- **Búsqueda de literatura re-verificada el 23/08/2026** (fresca, no solo la inicial): el gap sigue abierto. Único paper cercano por palabras clave, descartado explícitamente: "Symmetry-Aware Causal-Inference-Driven Web Performance Modeling" (Symmetry/MDPI, dic. 2025) — es *causal discovery* sobre features internas de una página para diagnóstico de una sola página, no inferencia causal de panel sobre migraciones.
- Todas las citas del documento escrito se verificaron contra el abstract/metadata real (no solo el título) antes de usarse.

## Hipótesis y objetivos

- **H1 (principal):** migraciones desde tecnologías con alta carga de JS bloqueante hacia frameworks modernos (ej. jQuery→React) mejoran LCP e INP frente a un grupo de control emparejado.
- **H2:** el efecto es heterogéneo — mayor desde tecnologías legacy, varía según tráfico del sitio.
- **H3:** el estimador clásico TWFE sobreestima el efecto frente al estimador robusto de Callaway y Sant'Anna.
- **Objetivo general:** estimar el efecto causal de las migraciones frontend sobre Core Web Vitals mediante inferencia causal para datos de panel con tratamiento escalonado.

Detalle completo (objetivos específicos, justificación extendida) en `TP Latex/Project/main.tex`.

## Datos y viabilidad

Fuentes 100% públicas, accedidas vía BigQuery: `httparchive.crawl.pages` (tecnología detectada por origen/mes) y `chrome-ux-report.materialized.metrics_summary` (p75 de LCP/INP/CLS por origen/mes). Unidad de análisis: el origen web (dominio), sin datos personales.

Viabilidad verificada con queries reales en BigQuery:
- **18.210.344** origins en CrUX (jun 2026, 97,4% con p75 LCP); **16.268.243** root pages en HTTP Archive (jul 2026).
- Semáforo de calidad LCP (jun 2026): 70,2% Good, 20,0% Needs Improvement, 9,7% Poor.
- Volumen de migraciones en un año: 62.457 jQuery→React, 116.864 abandonos de WordPress, 10.047 React→Next.js.
- El panel no crece monótonamente: dos rampas de expansión (2018-2019 y 2022-2023) y luego estabilidad con estacionalidad enero/julio desde 2023 — la ventana 2023-2026 es la más estable para un panel balanceado.
- Costo de extracción: ~13 GB de escaneo por mes consultado; panel completo de 8 años ≈ 1,2 TB (una sola vez), viable dentro de la cuota gratuita mensual de BigQuery repartiéndolo en un par de meses.
- Proyecto de trabajo: `tesis-506222` (GCP, Sandbox, sin billing). Ver `bigquery/CLAUDE.md` para límites conocidos (tablas expiran a 60 días, sin Cloud Storage) y la convención de extracción.

## Metodología (resumen)

(a) Construcción del panel con tecnología como dimensión de cambio lento (SCD tipo 2). (b) Detección de eventos de migración exigiendo persistencia ≥3 meses + validación manual muestral contra Wayback Machine. (c) Grupo de control emparejado por propensity score + verificación de tendencias paralelas. (d) Estimación con el estimador de Callaway y Sant'Anna (robusto a tratamiento escalonado, evita el sesgo de Goodman-Bacon), errores clusterizados por origen, corrección Benjamini-Hochberg. (e) Heterogeneidad de efectos con causal forests (Wager y Athey). Detalle completo en `TP Latex/Project/main.tex`, sección Solución propuesta.

## Estructura del repo

- `TP Latex/Project/`: propuesta escrita (`main.tex`/`main.pdf`).
- `TP Latex/Template/`: plantilla ITBA original de referencia, sin tocar.
- `Presentaciones/`: presentaciones dadas en el taller, numeradas. `02-presentacion_plan_de_trabajo.{html,pdf}` es la actual (deck HTML propio estilo dark data-science, exportado a PDF vía Chrome headless — no es Beamer/LaTeX). Para editarla, tocar el `.html` y regenerar el PDF (`--print-to-pdf`, `@page{size:13.333in 7.5in}`).
- `bigquery/`: pipeline de extracción de datos de la tesis, versionado (ver `bigquery/CLAUDE.md`): subcarpeta por tabla consultada, pares `NNN-nombre.sql`+`.parquet`, script `run_query.sh` con dry-run/tope de bytes/export a Parquet vía DuckDB, `usage-log.csv` para trackear la cuota gratuita de 1TB/mes.

## Estado actual y próximos hitos

- **Viernes 28/8/2026:** entrega de la presentación de cátedra (10 min).
- **Viernes 4/9/2026:** entrega de la versión final del documento escrito.
- Ejecución real de la tesis ya en marcha: primera extracción validada end-to-end en `bigquery/httparchive_crawl_pages/001-panel-root-pages-growth-2020-2026`.
