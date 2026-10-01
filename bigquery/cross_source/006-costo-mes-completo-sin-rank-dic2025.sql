-- Fecha: 2026-10-01
-- Propósito: medir el costo facturado real de extraer UN mes del panel completo (todos los
--            root pages, sin filtro de rank), leyendo exactamente las mismas columnas que el
--            panel piloto (cross_source/003): page, rank, technologies.technology,
--            technologies.info y p75 de device_summary. Devuelve solo conteos (el panel
--            completo de un mes son cientos de millones de filas sitio x tecnología): sirve
--            para dimensionar la extracción 2023-2026, no como dato de análisis.
-- Filtro de partición: date = '2025-12-01' en ambas tablas + client = 'mobile' + is_root_page
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.device_summary

WITH tech AS (
  SELECT
    RTRIM(page, '/') AS origin,
    rank,
    t.technology,
    REGEXP_EXTRACT(t.info[SAFE_OFFSET(0)], r'^(\d+)') AS version_mayor
  FROM `httparchive.crawl.pages`, UNNEST(technologies) AS t
  WHERE date = '2025-12-01'
    AND client = 'mobile'
    AND is_root_page
),

crux AS (
  SELECT origin, p75_lcp, p75_inp, p75_cls
  FROM `chrome-ux-report.materialized.device_summary`
  WHERE date = '2025-12-01'
    AND device = 'phone'
)

SELECT
  COUNT(*)                                  AS filas_sitio_tecnologia,
  COUNT(DISTINCT tech.origin)               AS sitios,
  COUNTIF(crux.p75_lcp IS NOT NULL)         AS filas_con_lcp,
  COUNTIF(tech.version_mayor IS NOT NULL)   AS filas_con_version,
  COUNT(DISTINCT tech.technology)           AS tecnologias
FROM tech
LEFT JOIN crux USING (origin)
