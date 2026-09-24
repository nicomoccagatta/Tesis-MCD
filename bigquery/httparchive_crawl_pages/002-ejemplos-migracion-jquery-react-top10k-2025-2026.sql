-- Fecha: 2026-09-24
-- Propósito: encontrar orígenes concretos que migraron de jQuery a React entre 2025
--            y 2026, para validarlos a mano contra Wayback Machine y Wappalyzer.
--            Se exige persistencia en ambos lados (dos crawls antes con jQuery sin
--            React, dos crawls después con React sin jQuery) y se limita al top 10k
--            de popularidad, donde Wayback Machine tiene capturas frecuentes.
-- Filtro de partición: date IN ('2025-03-01','2025-06-01','2026-03-01','2026-06-01')
--            + client = 'mobile' + is_root_page + rank <= 10000 (columnas de clustering)
-- Tablas: httparchive.crawl.pages

WITH tech AS (
  SELECT
    date,
    RTRIM(page, '/') AS origin,
    ANY_VALUE(rank) AS rank,
    LOGICAL_OR(t.technology = 'jQuery') AS jquery,
    LOGICAL_OR(t.technology = 'React')  AS react,
    STRING_AGG(
      DISTINCT IF('JavaScript frameworks' IN UNNEST(t.categories)
                  OR 'JavaScript libraries' IN UNNEST(t.categories), t.technology, NULL),
      ', ' ORDER BY IF('JavaScript frameworks' IN UNNEST(t.categories)
                       OR 'JavaScript libraries' IN UNNEST(t.categories), t.technology, NULL)
    ) AS js_detectado
  FROM `httparchive.crawl.pages`, UNNEST(technologies) AS t
  WHERE date IN ('2025-03-01', '2025-06-01', '2026-03-01', '2026-06-01')
    AND client = 'mobile'
    AND is_root_page
    AND rank <= 10000
  GROUP BY date, origin
),

por_origen AS (
  SELECT
    origin,
    MIN(rank) AS rank,
    COUNTIF(date IN ('2025-03-01', '2025-06-01') AND jquery AND NOT react) AS meses_pre_jquery,
    COUNTIF(date IN ('2026-03-01', '2026-06-01') AND react AND NOT jquery) AS meses_post_react,
    ANY_VALUE(IF(date = '2025-06-01', js_detectado, NULL)) AS js_jun2025,
    ANY_VALUE(IF(date = '2026-06-01', js_detectado, NULL)) AS js_jun2026
  FROM tech
  GROUP BY origin
)

SELECT
  origin,
  rank,
  js_jun2025,
  js_jun2026,
  CONCAT('https://web.archive.org/web/20250601000000*/', origin) AS wayback_antes,
  CONCAT('https://web.archive.org/web/20260601000000*/', origin) AS wayback_despues
FROM por_origen
WHERE meses_pre_jquery = 2
  AND meses_post_react = 2
ORDER BY rank, origin
