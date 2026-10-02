-- Fecha: 2026-10-01
-- Propósito: panel piloto en formato largo sitio x mes x tecnología sobre el top 10k
--            de popularidad, 2025 completo. Cada fila es una arista del grafo bipartito
--            sitio <-> tecnología detectada por Wappalyzer en ese mes (framework con su
--            versión, librerías, analytics, etc.), con el p75 de LCP/INP/CLS del sitio
--            en celular para ese mismo mes. De este único archivo salen localmente:
--            (a) el panel piloto origen x mes (pivoteando a flags por tecnología),
--            (b) la dimensión SCD-2 y los eventos de migración con persistencia >= 3 meses,
--            (c) el grafo bipartito sitio <-> tecnología de cada mes y sus cambios de
--                aristas en cada migración (se van / se quedan / llegan).
--            Las categorías de cada tecnología no se leen acá (duplican el costo del
--            escaneo): salen de httparchive_wappalyzer_technologies/001 y se unen local.
-- Filtro de partición: date BETWEEN '2025-01-01' AND '2025-12-01' en ambas tablas
--            + client = 'mobile' + is_root_page + rank <= 10000 (columnas de clustering)
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.device_summary

WITH tech AS (
  SELECT
    date,
    RTRIM(page, '/') AS origin,
    rank,
    t.technology,
    REGEXP_EXTRACT(t.info[SAFE_OFFSET(0)], r'^(\d+)') AS version_mayor,
    t.info[SAFE_OFFSET(0)]                            AS version
  FROM `httparchive.crawl.pages`, UNNEST(technologies) AS t
  WHERE date BETWEEN '2025-01-01' AND '2025-12-01'
    AND client = 'mobile'
    AND is_root_page
    AND rank <= 10000
),

crux AS (
  SELECT date, origin, p75_lcp, p75_inp, p75_cls
  FROM `chrome-ux-report.materialized.device_summary`
  WHERE date BETWEEN '2025-01-01' AND '2025-12-01'
    AND device = 'phone'
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
