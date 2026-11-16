# Changelog

Un ítem por avance, con su fecha. "Trabajo desde la entrega anterior" sale de acá: se agrega el ítem en la entrega que corresponde y después se corre `analisis/.venv/bin/python bitacora/armar_bitacora.py`. No se redacta esa lista en el HTML. En la página el orden es cronológico descendente: lo aplica `armar_bitacora.py`, aunque acá queden anotados en otro orden.

## Entrega 5

- **15/11/2026.** Proyección del grafo de diciembre 2025 rearmada con la versión de aurora (`analisis/grafo_aurora.py`): el nodo es framework@versión, y un par implies se conserva cuando las dos versiones están medidas.
- **13/10/2026.** Auditoría de la detección de frameworks frontend en Wappalyzer: SvelteKit y Remix se detectan; no aparecían en los análisis por los filtros del panel (6 tecnologías fijas) y del grafo (≥30 sitios por nodo, filtro por categoría).
- **13/10/2026.** Lista de 45 tecnologías frontend en 7 familias (por la relación `implies` de Wappalyzer). Cuenta como cambio la entrada o salida de una tecnología y el cambio de versión mayor.
- **13/10/2026.** Vista de cambios sitio por sitio en 2025, sin regla de persistencia: 1.900 sitios en móvil y 1.677 en escritorio. Filtros por tecnologías presentes y por cambios sostenidos, y orden por la variación de LCP, INP o CLS alrededor de cada cambio para encontrar ejemplos.
- **13/10/2026.** Detección de React: netflix.com pierde React en octubre de 2025 por pasar de `render` a `hydrateRoot` (React 18), que la regla de Wappalyzer no reconoce; 54 cambios sostenidos "sale React" en móvil quedan sin validar.
- **13/10/2026.** Wappalyzer no detecta React en el 28,6% de las páginas con React según la custom metric aurora de HTTP Archive (muestra de 10k); aurora validada contra los sitios en vivo, netflix.com e id.soccerway.com.
- **13/10/2026.** Facturación habilitada en `tesis-506222`: aurora para la cohorte en los 12 meses de 2025 (3,4 GB facturados por mes) e incorporada al panel de cambios, con selector Wappalyzer / Wappalyzer + aurora.
- **13/10/2026.** El formato de entrega pasa de presentaciones a esta bitácora.
- **14/10/2026.** aurora completada para los mismos sitio-mes que el panel: faltaban los meses con rank > 50.000 (3.634 sitio-mes, ej. id.soccerway.com de julio a diciembre) y 176 sitios de la cohorte de escritorio que no estaban en la lista móvil (`httparchive_crawl_pages/009`, 92,4 GB facturados). El panel lista los mismos sitios con las dos fuentes.
- **14/10/2026.** Tecnologías y métricas pasan a ser independientes en el panel: el p75 de LCP, INP y CLS sale de CrUX para los 12 meses (`chrome-ux-report_materialized_device_summary/001`), así que un mes sin tecnologías muestra igual sus métricas (en móvil, 6.287 de los 9.843 sitio-mes sin tecnologías las tienen). De esos 9.843, HTTP Archive no visitó el sitio en 8.279 (ej. www.primark.com en octubre) y en el resto la visita tiene la lista de Wappalyzer vacía; las 79 visitas de ese tipo sin aurora la tienen ahora (`httparchive_crawl_pages/010` y `011`).

## Entrega 4

- **01/10/2026.** Primera extracción sitio × mes × tecnología del top 10k de 2025, móvil y escritorio, filtrando el rank mes a mes (`cross_source/003`, `004`): solo el 26% de los sitios quedaba los 12 meses. Reemplazada al día siguiente por la cohorte fija.
- **01/10/2026.** Grafo bipartito sitio ↔ tecnología, proyección sobre tecnologías y explorador interactivo.
- **01/10/2026.** Revisión de cifras: el dry-run no descuenta el clustering de `crawl.pages` y sobreestima lo facturado; desde entonces el ledger registra lo facturado por job. Costo real de un mes completo: 6,1 GB (`cross_source/006`).
- **02/10/2026.** Cohorte fija: root pages con rank ≤ 10.000 en enero 2025, seguidas los 12 meses de 2025 sin volver a filtrar por rank (`cross_source/007` móvil, `008` escritorio). Un sitio-mes sin tecnologías registradas se trata como dato faltante, no como abandono.
- **02/10/2026.** Clasificación de las tecnologías detectadas por sus reglas de detección (`httparchive_wappalyzer_technologies/002`).

## Entrega 3

- **04/09/2026.** Versión final del documento escrito, alineada al template actualizado por la cátedra: cronograma con fechas, 3 figuras y 2 tablas. Incluye el DiD exploratorio de dos períodos (`cross_source/001`).
- **22/09/2026.** Relevamiento semestral de cobertura entre HTTP Archive y CrUX (`cross_source/002`).
- **22/09/2026.** Chequeo dirigido de la literatura sobre la combinación exacta del trabajo; cifras del embudo PRISMA de Ghattas et al. (2025) corregidas contra la fuente.
- **23/09/2026.** El resultado por dispositivo se toma de `device_summary` (`metrics_summary` agrega todos los dispositivos).
- **24/09/2026.** Validación de migraciones jQuery→React contra Wayback Machine.
- **Tareas de la reunión:** empezar la construcción del panel; investigar las librerías asociadas a cada versión de framework y evaluar un grafo bipartito (respondidas en la entrega 4).

## Entrega 2

- **23/08/2026.** Proyecto `tesis-506222` en modo Sandbox (tablas de destino expiran a 60 días; sin Cloud Storage). Script `run_query.sh`: dry-run, tope de bytes facturados, exportación a Parquet y ledger de cuota.
- **23/08/2026.** Primeras extracciones versionadas: crecimiento del panel 2020–2026, semáforo de Core Web Vitals de julio 2026 (mismo mes en ambas fuentes) y verificación de unicidad de origin en `metrics_summary`.

## Entrega 1

- **14/08/2026.** Chequeo de viabilidad en BigQuery: cobertura de LCP/CLS/INP en CrUX y conteo inicial de migraciones jun-2025 → jun-2026.
- **21/08/2026.** Escala de `httparchive.crawl.pages` (metadata) y serie de crecimiento del panel.
