-- Fecha: 2026-09-22
-- Propósito: relevar la cobertura del cruce entre HTTP Archive (root pages) y
--            CrUX (metrics_summary) a lo largo del histórico común a ambas
--            fuentes desde 2018, con muestreo semestral (ene/jul de cada año).
--            Esto es exactamente lo que el diseño del panel (main.tex, Solución
--            propuesta) exige relevar antes de definir la ventana y la cohorte
--            de orígenes elegibles: qué fracción de orígenes de cada fuente
--            aparece también en la otra, mes a mes.
-- Filtro de partición: date IN (18 fechas semestrales puntuales, ene-2018 a jul-2026)
--            en ambas tablas.
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.metrics_summary
-- Nota: si alguna fecha no tiene partición en alguna de las dos fuentes (crawl
--            faltante o discontinuo), esa fila simplemente da cobertura 0/NULL,
--            no rompe la query.

WITH ha_origins AS (
  SELECT DISTINCT date, RTRIM(page, '/') AS origin
  FROM `httparchive.crawl.pages`
  WHERE date IN (
    '2018-01-01', '2018-07-01',
    '2019-01-01', '2019-07-01',
    '2020-01-01', '2020-07-01',
    '2021-01-01', '2021-07-01',
    '2022-01-01', '2022-07-01',
    '2023-01-01', '2023-07-01',
    '2024-01-01', '2024-07-01',
    '2025-01-01', '2025-07-01',
    '2026-01-01', '2026-07-01'
  )
    AND is_root_page = TRUE
),

crux_origins AS (
  SELECT DISTINCT date, origin
  FROM `chrome-ux-report.materialized.metrics_summary`
  WHERE date IN (
    '2018-01-01', '2018-07-01',
    '2019-01-01', '2019-07-01',
    '2020-01-01', '2020-07-01',
    '2021-01-01', '2021-07-01',
    '2022-01-01', '2022-07-01',
    '2023-01-01', '2023-07-01',
    '2024-01-01', '2024-07-01',
    '2025-01-01', '2025-07-01',
    '2026-01-01', '2026-07-01'
  )
),

joined AS (
  SELECT
    COALESCE(h.date, c.date)     AS date,
    h.origin IS NOT NULL         AS in_ha,
    c.origin IS NOT NULL         AS in_crux
  FROM ha_origins h
  FULL OUTER JOIN crux_origins c
    ON h.date = c.date AND h.origin = c.origin
)

SELECT
  date,
  COUNTIF(in_ha)                AS n_httparchive,
  COUNTIF(in_crux)               AS n_crux,
  COUNTIF(in_ha AND in_crux)     AS n_interseccion,
  ROUND(SAFE_DIVIDE(COUNTIF(in_ha AND in_crux), COUNTIF(in_ha)) * 100, 1)   AS pct_ha_con_crux,
  ROUND(SAFE_DIVIDE(COUNTIF(in_ha AND in_crux), COUNTIF(in_crux)) * 100, 1) AS pct_crux_con_ha
FROM joined
GROUP BY date
ORDER BY date
