-- Fecha: 2026-10-14
-- Propósito: verificar que BigQuery poda bloques con una condición OR sobre columnas de clustering
--            (rank, page) antes de correr 009, que usa esa forma. Dos páginas de dic-2025 móvil, cada
--            una con su rank: id.soccerway.com (rank 500000) y adventofcode.com (rank 100000). Con poda,
--            factura unos pocos bloques; sin poda, las dos franjas de rank completas (acotadas por el
--            filtro rank IN de primer nivel).
-- Filtro de partición: date = '2025-12-01' + client = 'mobile' + is_root_page + rank IN (100000, 500000)
-- Tablas: httparchive.crawl.pages

SELECT
  date,
  client,
  page,
  rank,
  JSON_VALUE(custom_metrics.other, '$.aurora.react_version')    AS aurora_react,
  JSON_VALUE(custom_metrics.other, '$.aurora.next_version')     AS aurora_next,
  JSON_VALUE(custom_metrics.other, '$.aurora.nuxt_version')     AS aurora_nuxt,
  JSON_VALUE(custom_metrics.other, '$.aurora.nuxt_vue_version') AS aurora_nuxt_vue,
  JSON_VALUE(custom_metrics.other, '$.aurora.ng_version')       AS aurora_angular,
  JSON_VALUE(custom_metrics.other, '$.aurora.svelte_version')   AS aurora_svelte,
  ARRAY_LENGTH(technologies)                                    AS n_tecnologias_wappalyzer
FROM `httparchive.crawl.pages`
WHERE date = '2025-12-01'
  AND client = 'mobile'
  AND is_root_page
  AND rank IN (100000, 500000)
  AND (
    (rank = 100000 AND page = 'https://adventofcode.com/')
    OR (rank = 500000 AND page = 'https://id.soccerway.com/')
  )
