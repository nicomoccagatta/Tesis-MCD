-- Fecha: 2026-10-02 (réplica de httparchive_crawl_pages/003 para enero 2025, el mes de la cohorte)
-- Propósito: verificar por qué el crawl móvil de ene-2025 tiene 7.725 root pages con
--            rank <= 10000 y el panel piloto (cross_source/003) solo 7.540 sitios ese mes.
--            Lista cada root page con su cantidad de tecnologías detectadas (el panel
--            descarta las páginas sin ninguna, por el UNNEST) y cuántas filas comparten el
--            mismo origin normalizado (el panel agrupa por RTRIM(page, '/')).
-- Filtro de partición: date = '2025-01-01' + client = 'mobile' + is_root_page + rank <= 10000
-- Tablas: httparchive.crawl.pages

SELECT
  page,
  RTRIM(page, '/')                                        AS origin,
  rank,
  ARRAY_LENGTH(technologies)                              AS n_tecnologias,
  COUNT(*) OVER (PARTITION BY RTRIM(page, '/'))           AS filas_mismo_origin
FROM `httparchive.crawl.pages`
WHERE date = '2025-01-01'
  AND client = 'mobile'
  AND is_root_page
  AND rank <= 10000
ORDER BY n_tecnologias, origin
