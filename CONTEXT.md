# Contexto del proyecto de tesis

Repo de la tesis de la Maestría en Ciencia de Datos (ITBA) de Nicolás Moccagatta (Leg. 106396). Director: **Ariel Olaf Salgado Corrado**. Co-Director: **Carlos Sarraute**.

## Tema

Estimar el efecto causal de las migraciones de tecnología frontend (por ejemplo, jQuery a React, o el abandono de WordPress) sobre la experiencia de usuario real, medida con Core Web Vitals (LCP, INP, CLS). Cada migración detectada en los crawls mensuales de HTTP Archive se trata como un cuasi-experimento natural, con un diseño de diferencias en diferencias robusto a tratamiento escalonado sobre un panel construido a partir de HTTP Archive (tecnología detectada) y CrUX (experiencia real de usuario), ambos en BigQuery.

**Contexto:** Core Web Vitals son las métricas que Google usa para estandarizar la "velocidad percibida" de un sitio, recolectadas de navegadores Chrome reales y publicadas mensualmente en CrUX (Chrome User Experience Report). HTTP Archive rastrea mensualmente millones de sitios y detecta, vía Wappalyzer, qué tecnología frontend usa cada uno. La industria migra constantemente de tecnología prometiendo mejoras de performance, pero rara vez lo valida con evidencia rigurosa: se apoya en casos de éxito puntuales, benchmarks de laboratorio o comparaciones de sitios distintos en un mismo momento (que confunden tecnología con otros factores).

## Estado de la cuestión (el gap)

- **Evidencia industrial** (Core Web Vitals Technology Report y Web Almanac, ambos de HTTP Archive): transversal y correlacional — compara sitios distintos en un corte del tiempo, sin seguimiento longitudinal ni control de confounders.
- **Literatura académica sobre frameworks**: benchmarks de laboratorio a pequeña escala sobre aplicaciones de prueba (Tong, Jikson & Gunawan 2023), o síntesis narrativa sin datos propios (Tulsyan et al. 2024).
- **Uso descriptivo de CrUX a escala** (Sengupta et al. 2023): caracteriza la experiencia de navegación por dispositivo/país, pero no estudia tecnología ni migraciones.
- **Revisión sistemática** (Ghattas, Odeh & Mora 2025, PRISMA sobre 7 bases de datos — IEEE Xplore, Google Scholar, Scopus, SpringerLink, ResearchGate, ACM Digital Library y DOAJ —, 2010-2024): embudo completo **6.657 registros identificados → 1.651 sin duplicados/no-inglés → 780 cribados por título/resumen → 120 con texto completo evaluado → 34 elegibles → 30 estudios de alta calidad incluidos** tras control de calidad (umbral &ge;4,5/9). Ninguno de esos 30 estima el efecto de decisiones tecnológicas concretas sobre experiencia de usuarios reales.
- **El vacío:** ningún trabajo combina seguimiento longitudinal de los mismos sitios + experiencia de usuario real (no de laboratorio) + diseño con lectura causal.
- **Chequeo adicional propio, reverificado el 22/09/2026**: no es una búsqueda sistemática (un puñado de queries en un buscador web genérico no tiene el rigor ni la cobertura de un review PRISMA sobre bases académicas — no reportar esto como si fuera comparable a los números de Ghattas et al.). Es un chequeo puntual dirigido específicamente a nuestra combinación de criterios (causal + panel/longitudinal + Core Web Vitals/CrUX + migración de tecnología/framework). Único trabajo adyacente identificado: "Symmetry-Aware Causal-Inference-Driven Web Performance Modeling" (*Symmetry*, dic. 2025, DOI `10.3390/sym17122058`) — descartado porque hace *causal discovery* sobre la estructura DOM de una página individual para diagnóstico puntual, no inferencia causal de panel entre sitios en el tiempo.
- Todas las citas del documento escrito se verificaron contra el abstract/metadata real (no solo el título) antes de usarse.

## Hipótesis y objetivos

- **H1 (principal):** migraciones desde tecnologías con alta carga de JS bloqueante hacia frameworks modernos (ej. jQuery→React) mejoran LCP e INP frente a un grupo de control emparejado.
- **H2:** el efecto es heterogéneo — mayor desde tecnologías legacy, varía según tráfico del sitio.
- **H3:** el estimador clásico TWFE sobreestima el efecto frente al estimador robusto de Callaway y Sant'Anna.
- **Objetivo general:** estimar el efecto causal de las migraciones frontend sobre Core Web Vitals mediante inferencia causal para datos de panel con tratamiento escalonado.

Detalle completo (objetivos específicos, justificación extendida) en `TP Latex/Project/main.tex`.

## Datos y viabilidad

Fuentes 100% públicas, accedidas vía BigQuery: `httparchive.crawl.pages` (tecnología detectada por origen/mes) y `chrome-ux-report.materialized.metrics_summary` (p75 de LCP/INP/CLS por origen/mes). Unidad de análisis: el origen web (dominio), sin datos personales.

**Precedente de legitimidad de los datasets:** Ruth, Kumar, Wang, Valenta & Durumeric (2022, ACM IMC) evalúan la exactitud de distintos *rankings de popularidad* de sitios web (Alexa, Tranco, Cisco Umbrella, CrUX) contra tráfico real de Cloudflare, y concluyen que el ranking derivado de CrUX es el más preciso — esto valida la representatividad del panel de tráfico real detrás de CrUX (y por eso respalda usarlo como dataset de investigación), **no** mide directamente la precisión de los valores de LCP/INP/CLS que sí usamos como variable de resultado. Beugin, Barford & McDaniel (2026, arXiv) combinan HTTP Archive + CrUX en un diseño longitudinal de 7 años para caracterizar adopción/abandono de APIs web — el precedente estructural más parecido, aunque su objetivo es descriptivo (adopción), no estimar efecto causal sobre una métrica de resultado.

Viabilidad verificada con queries reales en BigQuery:
- **18.059.068** origins en CrUX y **16.268.243** root pages en HTTP Archive, ambos para **julio 2026** (mismo mes en las dos fuentes, para que sean comparables).
- Semáforos de calidad, julio 2026 (Good / Needs Improvement / Poor, sobre el % de origins con dato):
  - LCP (97,3% cobertura): 70,8% / 19,8% / 9,4%.
  - INP (70,1% cobertura, menor porque requiere interacciones del usuario): 88,4% / 9,5% / 2,0%.
  - CLS (99,4% cobertura): 87,2% / 6,5% / 6,3%.
- Volumen de migraciones entre los cortes **junio 2025** y **junio 2026** (páginas raíz, crawl móvil, presentes en ambos meses): **62.457** jQuery→React, **65.407** abandonos de WordPress, **9.059** React→Next.js. Versionado en `bigquery/cross_source/001-migraciones-y-did-dos-periodos-jun2025-jun2026`. Las cifras viejas de WordPress (116.864) y Next.js (10.047), usadas antes en la presentación, no reprodujeron con esta definición y quedaron reemplazadas; la de jQuery→React sí reprodujo exacta.
- **DiD exploratorio de dos períodos** (mismo query, jun25 vs jun26, control = los que se quedaron en la tecnología de origen): jQuery→React **+41 ms** LCP y **+41 ms** INP (el grupo migrado queda *peor* que su control), abandono de WordPress **−671 ms** LCP / +12 ms INP, React→Next.js **−34 ms** LCP / 0 INP. En los tres pares los tratados arrancan 200-300 ms peor que los controles, o sea que hay reversión a la media sin emparejar. **No confirma H1** y así está escrito en el documento: es el argumento concreto de por qué hacen falta matching y Callaway-Sant'Anna.
- El panel no crece monótonamente: dos rampas de expansión (2018-2019 y 2022-2023) y luego estabilidad con estacionalidad enero/julio desde 2023 — la ventana 2023-2026 es la más estable para un panel balanceado.
- **Relevamiento de cobertura del cruce entre fuentes** (18 fechas semestrales, ene-2018 a jul-2026, versionado en `bigquery/cross_source/002-cobertura-cruce-httparchive-crux-2018-2026`): confirma con números duros lo que el punto anterior mostraba solo con el crecimiento del panel. Antes de 2019 el cruce es casi inutilizable (ene-2018: solo 27,6% de los root pages de HTTP Archive tiene dato en CrUX, y solo 4,4% de los origins de CrUX aparece en HTTP Archive). 2019-2022 es una zona de transición ruidosa (cobertura HA→CrUX entre 65% y 91%, CrUX→HA entre 60% y 77%, sin tendencia estable). Desde **2023-01 la cobertura se estabiliza**: 87-92% de los root pages de HTTP Archive tiene dato de CrUX ese mismo mes, y 76-84% de los origins de CrUX aparece en HTTP Archive — el número que faltaba para justificar la ventana 2023-2026 con el propio cruce, no solo con el tamaño de cada fuente por separado.
- Costo de extracción: ~13 GB de escaneo por mes consultado; panel completo de 8 años ≈ 1,2 TB (una sola vez), viable dentro de la cuota gratuita mensual de BigQuery repartiéndolo en un par de meses.
- Proyecto de trabajo: `tesis-506222` (GCP, Sandbox, sin billing). Ver `bigquery/CLAUDE.md` para límites conocidos (tablas expiran a 60 días, sin Cloud Storage) y la convención de extracción.

## Metodología (resumen)

(a) Construcción del panel con tecnología como dimensión de cambio lento (SCD tipo 2). (b) Detección de eventos de migración exigiendo persistencia ≥3 meses + validación manual muestral contra Wayback Machine. (c) Grupo de control emparejado por propensity score + verificación de tendencias paralelas. (d) Estimación con el estimador de Callaway y Sant'Anna (robusto a tratamiento escalonado, evita el sesgo de Goodman-Bacon), errores clusterizados por origen, corrección Benjamini-Hochberg. (e) Heterogeneidad de efectos con causal forests (Wager y Athey). Detalle completo en `TP Latex/Project/main.tex`, sección Solución propuesta.

## Estructura del repo

- `TP Latex/Project/`: propuesta escrita (`main.tex`/`main.pdf`).
- `TP Latex/Template/`: plantilla ITBA original de referencia, sin tocar.
- `Presentaciones/`: presentaciones dadas en el taller, numeradas. `02-presentacion_plan_de_trabajo.{html,pdf}` es la actual (deck HTML propio estilo dark data-science, exportado a PDF vía Chrome headless — no es Beamer/LaTeX). Para editarla, tocar el `.html` y regenerar el PDF (`--print-to-pdf`, `@page{size:13.333in 7.5in}`).
- `bigquery/`: pipeline de extracción de datos de la tesis, versionado (ver `bigquery/CLAUDE.md`): subcarpeta por tabla consultada (o `cross_source/` cuando la query cruza ambas fuentes), pares `NNN-nombre.sql`+`.parquet`, script `run_query.sh` con dry-run/tope de bytes/export a Parquet vía DuckDB, `usage-log.csv` para trackear la cuota gratuita de 1TB/mes.
- `.claude/skills/`: skills de Claude Code versionados en este repo porque son específicos de esta tesis (se activan solos según el pedido, no hace falta invocarlos a mano):
  - `r-econometrics/` y `python-panel-data/`: estimadores de panel/DiD escalonado — Callaway-Sant'Anna, Sun-Abraham — con código de referencia en R y Python.
  - `academic-paper-writer/`: estructura de paper empírico de economía (introducción, literatura, identificación, resultados, robustez, discusión, respuesta a referato) para `TP Latex/Project/main.tex`.
  - `latex-tables/`: tablas de LaTeX generadas desde código (`esttab`, `modelsummary`, `pyfixest.etable`) para las tablas de DiD/balance de matching del documento escrito.
  - `latex/`: LaTeX general (documento/snippet) para figuras TikZ y tipografía de `main.tex`. Su modo Beamer **no aplica** — la presentación de cátedra es HTML/CSS propio, no Beamer (ver más abajo).

## Estado actual y próximos hitos

- **Viernes 28/8/2026:** entrega de la presentación de cátedra (10 min).
- **Viernes 4/9/2026:** entregada la versión final del documento escrito, ya alineada al template actualizado por la cátedra (encabezado `ITBA -- Proyecto de Tesis`, carátula con campo `PROFESORES`, cronograma con fechas concretas, sin `\section{Referencias-Bibliografía}` manual). El documento tiene ahora 3 figuras (semáforo CWV, evolución del panel, esquema del diseño) y 2 tablas (variables operativas, DiD exploratorio).
- Ejecución real de la tesis ya en marcha: primera extracción validada end-to-end en `bigquery/httparchive_crawl_pages/001-panel-root-pages-growth-2020-2026`.
