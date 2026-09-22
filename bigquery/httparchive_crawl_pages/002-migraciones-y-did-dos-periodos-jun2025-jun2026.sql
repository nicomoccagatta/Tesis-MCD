-- Fecha: 2026-09-04
-- Propósito: (a) reproducir y dejar versionado el volumen de eventos de migración
--            entre jun-2025 y jun-2026 para los tres pares de interés, y (b) calcular
--            un diferencias-en-diferencias exploratorio de DOS períodos sobre el p75
--            de LCP e INP, comparando cada grupo migrado contra el grupo que se quedó
--            en la tecnología de origen.
--            ADVERTENCIA METODOLÓGICA: esto NO es el diseño de la tesis. Compara dos
--            cortes anuales, define la migración como un cambio de estado entre esos
--            dos cortes (sin exigir persistencia ≥3 meses), no empareja el control por
--            covariables previas y no puede verificar tendencias paralelas. Sirve como
--            chequeo de viabilidad y de orden de magnitud, no como estimación causal.
-- Filtro de partición: date IN ('2025-06-01','2026-06-01') en ambas tablas
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.metrics_summary

WITH tech AS (
  SELECT
    date,
    RTRIM(page, '/') AS origin,
    LOGICAL_OR(t.technology = 'jQuery')    AS jquery,
    LOGICAL_OR(t.technology = 'React')     AS react,
    LOGICAL_OR(t.technology = 'WordPress') AS wordpress,
    LOGICAL_OR(t.technology = 'Next.js')   AS nextjs
  FROM `httparchive.crawl.pages`, UNNEST(technologies) AS t
  WHERE date IN ('2025-06-01', '2026-06-01')
    AND client = 'mobile'
    AND is_root_page
  GROUP BY date, origin
),

pre  AS (SELECT * FROM tech WHERE date = '2025-06-01'),
post AS (SELECT * FROM tech WHERE date = '2026-06-01'),

-- Un origen queda asignado a lo sumo a un grupo. Los grupos "_control" son los que
-- siguen exactamente en la tecnología de origen un año después.
grupos AS (
  SELECT
    pre.origin,
    CASE
      WHEN pre.jquery AND NOT pre.react AND post.react AND NOT post.jquery
        THEN 'jquery_a_react'
      WHEN pre.jquery AND NOT pre.react AND post.jquery AND NOT post.react
        THEN 'jquery_control'
      WHEN pre.wordpress AND NOT post.wordpress
        THEN 'abandono_wordpress'
      WHEN pre.wordpress AND post.wordpress
        THEN 'wordpress_control'
      WHEN pre.react AND NOT pre.nextjs AND post.nextjs
        THEN 'react_a_nextjs'
      WHEN pre.react AND NOT pre.nextjs AND post.react AND NOT post.nextjs
        THEN 'react_control'
    END AS grupo
  FROM pre
  JOIN post USING (origin)
),

crux_pre AS (
  SELECT origin, p75_lcp, p75_inp
  FROM `chrome-ux-report.materialized.metrics_summary`
  WHERE date = '2025-06-01'
),
crux_post AS (
  SELECT origin, p75_lcp, p75_inp
  FROM `chrome-ux-report.materialized.metrics_summary`
  WHERE date = '2026-06-01'
),

panel AS (
  SELECT
    g.grupo,
    g.origin,
    crux_pre.p75_lcp                     AS lcp_pre,
    crux_pre.p75_inp                     AS inp_pre,
    crux_post.p75_lcp - crux_pre.p75_lcp AS delta_lcp,
    crux_post.p75_inp - crux_pre.p75_inp AS delta_inp
  FROM grupos AS g
  LEFT JOIN crux_pre  USING (origin)
  LEFT JOIN crux_post USING (origin)
  WHERE g.grupo IS NOT NULL
)

SELECT
  grupo,
  COUNT(*)                                               AS n_origins_http_archive,
  COUNTIF(delta_lcp IS NOT NULL)                         AS n_con_lcp_ambos_meses,
  APPROX_QUANTILES(lcp_pre, 100)[OFFSET(50)]             AS lcp_pre_mediana_ms,
  ROUND(AVG(delta_lcp), 1)                               AS delta_lcp_media_ms,
  APPROX_QUANTILES(delta_lcp, 100)[OFFSET(50)]           AS delta_lcp_mediana_ms,
  COUNTIF(delta_inp IS NOT NULL)                         AS n_con_inp_ambos_meses,
  APPROX_QUANTILES(inp_pre, 100)[OFFSET(50)]             AS inp_pre_mediana_ms,
  ROUND(AVG(delta_inp), 1)                               AS delta_inp_media_ms,
  APPROX_QUANTILES(delta_inp, 100)[OFFSET(50)]           AS delta_inp_mediana_ms
FROM panel
GROUP BY grupo
ORDER BY grupo
