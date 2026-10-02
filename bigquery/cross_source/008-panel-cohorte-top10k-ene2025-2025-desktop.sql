-- Fecha: 2026-10-02
-- Propósito: réplica en escritorio de cross_source/007. Panel piloto con cohorte fija. Se toman los root pages del crawl de escritorio con
--            rank <= 10000 en ENERO 2025 y se los sigue los 12 meses de 2025 sin volver a
--            filtrar por rank (reemplaza el filtro mes a mes de cross_source/003, que hacía
--            entrar y salir sitios según su popularidad). Mismo formato largo que 003:
--            sitio x mes x tecnología, con versión y p75 de LCP/INP/CLS de CrUX desktop.
--            Un mes sin filas para un sitio = visita fallida o vacía (dato faltante).
-- Filtro de partición: date BETWEEN '2025-01-01' AND '2025-12-01' en ambas tablas
--            + client = 'desktop' + is_root_page; cohorte con rank <= 10000 en 2025-01-01
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.device_summary

WITH cohorte AS (
  SELECT DISTINCT RTRIM(page, '/') AS origin
  FROM `httparchive.crawl.pages`
  WHERE date = '2025-01-01'
    AND client = 'desktop'
    AND is_root_page
    AND rank <= 10000
),

tech AS (
  SELECT
    p.date,
    RTRIM(p.page, '/') AS origin,
    p.rank,
    t.technology,
    REGEXP_EXTRACT(t.info[SAFE_OFFSET(0)], r'^(\d+)') AS version_mayor,
    t.info[SAFE_OFFSET(0)]                            AS version
  FROM `httparchive.crawl.pages` AS p, UNNEST(p.technologies) AS t
  WHERE p.date BETWEEN '2025-01-01' AND '2025-12-01'
    AND p.client = 'desktop'
    AND p.is_root_page
    AND RTRIM(p.page, '/') IN (SELECT origin FROM cohorte)
),

crux AS (
  SELECT date, origin, p75_lcp, p75_inp, p75_cls
  FROM `chrome-ux-report.materialized.device_summary`
  WHERE date BETWEEN '2025-01-01' AND '2025-12-01'
    AND device = 'desktop'
)

SELECT
  tech.date,
  tech.origin,
  tech.rank,
  tech.technology,
  tech.version_mayor,
  tech.version,
  crux.p75_lcp,
  crux.p75_inp,
  crux.p75_cls
FROM tech
LEFT JOIN crux USING (date, origin)
ORDER BY tech.origin, tech.date, tech.technology
