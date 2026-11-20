-- Fecha: 2026-10-14
-- Propósito: aurora de las 79 visitas que encontró httparchive_crawl_pages/010 en los sitio-mes de la
--            cohorte 2025 sin filas en el panel ni aurora (visitas con la lista de Wappalyzer vacía). Mismas
--            columnas que 006, 007 y 009; cada visita con su mes, cliente y rank.
-- Filtro de partición: date BETWEEN '2025-01-01' AND '2025-12-01' + is_root_page + 51 condiciones por
--            mes, cliente y rank con su lista literal de páginas, unidas por OR (rank y page son columnas
--            de clustering, el dry-run no lo refleja)
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
WHERE date BETWEEN '2025-01-01' AND '2025-12-01'
  AND is_root_page
  AND (
    (date = '2025-02-01' AND client = 'mobile' AND rank = 500000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-03-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 100000 AND page IN ('https://anitaku.bz/'))
    OR (date = '2025-04-01' AND client = 'desktop' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 100000 AND page IN ('https://anitaku.bz/'))
    OR (date = '2025-04-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-05-01' AND client = 'desktop' AND rank = 10000000 AND page IN ('https://asd.quest/', 'https://m.gameshop4u.com/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 5000000 AND page IN ('https://download.vidshare.site/', 'https://movies.downloadmv.site/'))
    OR (date = '2025-05-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://m.gameshop4u.com/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 1000000 AND page IN ('https://asd.quest/', 'https://blaze.com/'))
    OR (date = '2025-06-01' AND client = 'desktop' AND rank = 5000000 AND page IN ('https://www.maxlifeinsurance.com/'))
    OR (date = '2025-06-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 500000 AND page IN ('https://footballforge.com/'))
    OR (date = '2025-07-01' AND client = 'desktop' AND rank = 10000000 AND page IN ('https://pelotalibre.org/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 100000 AND page IN ('https://www.ixxx1.com/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 500000 AND page IN ('https://footballforge.com/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/', 'https://www.51cg1.com/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://movies.downloadmv.site/', 'https://pelotalibre.org/'))
    OR (date = '2025-07-01' AND client = 'mobile' AND rank = 50000000 AND page IN ('https://findnovel.docsachhay.net/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 500000 AND page IN ('https://celebrityjest.com/', 'https://forexpipinsight.com/', 'https://voguefashionvibe.com/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 10000000 AND page IN ('https://ak.ptailadsol.net/'))
    OR (date = '2025-08-01' AND client = 'desktop' AND rank = 50000000 AND page IN ('https://www.tatadigital.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 100000 AND page IN ('https://www.getsurrey.co.uk/', 'https://www.resultados-futbol.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 500000 AND page IN ('https://celebrityjest.com/', 'https://forexpipinsight.com/', 'https://galleryxh.life/', 'https://voguefashionvibe.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 5000000 AND page IN ('https://librecruitmentbirbhum.in/', 'https://m.jpost.com/', 'https://movies.downloadmv.site/'))
    OR (date = '2025-08-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://ak.ptailadsol.net/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-09-01' AND client = 'desktop' AND rank = 50000000 AND page IN ('https://anoboy.icu/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 100000 AND page IN ('https://www.getsurrey.co.uk/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 5000000 AND page IN ('https://anchorit.live/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://librecruitmentbirbhum.in/'))
    OR (date = '2025-09-01' AND client = 'mobile' AND rank = 50000000 AND page IN ('https://anoboy.icu/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 500000 AND page IN ('https://azmip.com/'))
    OR (date = '2025-10-01' AND client = 'desktop' AND rank = 50000000 AND page IN ('https://toonstream.co/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 500000 AND page IN ('https://azmip.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://blaze.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://www.ballzaa.com/'))
    OR (date = '2025-10-01' AND client = 'mobile' AND rank = 50000000 AND page IN ('https://m.jpost.com/', 'https://toonstream.co/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 1000000 AND page IN ('https://azmip.com/', 'https://blaze.com/'))
    OR (date = '2025-11-01' AND client = 'desktop' AND rank = 50000000 AND page IN ('https://1xlite-4262965.top/', 'https://dizigom1.co/', 'https://toonstream.co/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://azmip.com/', 'https://blaze.com/'))
    OR (date = '2025-11-01' AND client = 'mobile' AND rank = 50000000 AND page IN ('https://1xlite-4262965.top/', 'https://1xlite-581089.top/', 'https://dizigom1.co/', 'https://thaushiwhoalsou.com/', 'https://toonstream.co/', 'https://topushh.com/'))
    OR (date = '2025-12-01' AND client = 'desktop' AND rank = 5000000 AND page IN ('https://www.dizimom.plus/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 100000 AND page IN ('https://portal2.passportindia.gov.in/', 'https://www.themirror.com/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 1000000 AND page IN ('https://winbuzz.games/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 5000000 AND page IN ('https://blaze.com/', 'https://www.dizimom.plus/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 10000000 AND page IN ('https://anchorit.live/', 'https://betphoenix.site/'))
    OR (date = '2025-12-01' AND client = 'mobile' AND rank = 50000000 AND page IN ('https://bewhoopoalso.com/', 'https://kairustaubu.com/', 'https://kouwhuthoay.com/'))
  )
