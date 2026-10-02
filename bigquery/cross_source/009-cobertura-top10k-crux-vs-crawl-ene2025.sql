-- Fecha: 2026-10-02 (réplica de cross_source/005 para enero 2025, el mes de la cohorte del panel)
-- Propósito: explicar por qué el panel piloto "top 10k" tiene ~7.500 sitios por mes y no
--            10.000. Compara los origins del tramo rank <= 10000 de CrUX con los root pages
--            del mismo tramo en el crawl móvil de HTTP Archive, para ene-2025, y clasifica
--            los origins de CrUX que faltan: (a) están en el crawl pero con otro rank,
--            (b) están en el crawl solo como página no raíz, (c) no aparecen en el crawl.
-- Filtro de partición: date = '2025-01-01' en ambas tablas + client = 'mobile'
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.device_summary

WITH crux AS (
  SELECT DISTINCT origin
  FROM `chrome-ux-report.materialized.device_summary`
  WHERE date = '2025-01-01'
    AND rank <= 10000
),

crawl AS (
  SELECT
    RTRIM(root_page, '/') AS origin,
    is_root_page,
    rank
  FROM `httparchive.crawl.pages`
  WHERE date = '2025-01-01'
    AND client = 'mobile'
),

crawl_por_origen AS (
  SELECT
    origin,
    LOGICAL_OR(is_root_page)                      AS es_raiz,
    LOGICAL_OR(is_root_page AND rank <= 10000)    AS raiz_top10k
  FROM crawl
  GROUP BY origin
)

SELECT
  (SELECT COUNT(*) FROM crux)                                          AS crux_origins_top10k,
  (SELECT COUNT(*) FROM crawl WHERE is_root_page AND rank <= 10000)    AS crawl_root_pages_top10k,
  COUNTIF(c.raiz_top10k)                                               AS crux_en_crawl_top10k,
  COUNTIF(c.es_raiz AND NOT c.raiz_top10k)                             AS crux_en_crawl_otro_rank,
  COUNTIF(c.origin IS NOT NULL AND NOT c.es_raiz)                      AS crux_en_crawl_solo_no_raiz,
  COUNTIF(c.origin IS NULL)                                            AS crux_sin_crawl
FROM crux AS x
LEFT JOIN crawl_por_origen AS c USING (origin)
