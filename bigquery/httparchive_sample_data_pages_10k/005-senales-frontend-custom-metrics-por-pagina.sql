-- Fecha: 2026-11-18
-- Propósito: por página raíz y cliente, las señales de framework o tecnología frontend que traen
--            los campos de custom_metrics con contenido (vistos en 003/004), junto con lo que
--            detectan Wappalyzer y aurora, para medir qué agrega cada señal:
--            javascript.bundler, extensiones de javascript.sourceMaps.ext, marcadores en los
--            <script> del HTML (other.almanac.scripts.nodes) y en las URLs pedidas
--            (other.initiators), prefijos de variables CSS (css_variables), tema y scripts de
--            WordPress (cms.wordpress) y feature_flags de aurora. markup.classes, markup.ids,
--            javascript.document y javascript.script_tags solo traen conteos y no entran.
-- Filtro de partición: no aplica (tabla de muestra, un mes)
-- Tablas: httparchive.sample_data.pages_10k

WITH base AS (
  SELECT
    client,
    page,
    rank,
    ARRAY(SELECT t.technology FROM UNNEST(technologies) AS t ORDER BY t.technology) AS wappalyzer,
    JSON_QUERY(custom_metrics.other, '$.aurora') AS aurora,
    JSON_VALUE_ARRAY(custom_metrics.javascript, '$.bundler') AS bundler,
    JSON_KEYS(JSON_QUERY(custom_metrics.javascript, '$.sourceMaps.ext'), 1) AS sourcemap_ext,
    SAFE_CAST(JSON_VALUE(custom_metrics.javascript, '$.sourceMaps.count') AS INT64) AS sourcemap_count,
    TO_JSON_STRING(JSON_QUERY(custom_metrics.other, '$.almanac.scripts.nodes')) AS scripts_html,
    TO_JSON_STRING(JSON_QUERY(custom_metrics.other, '$.initiators')) AS urls_pedidas,
    TO_JSON_STRING(custom_metrics.css_variables) AS css_vars,
    JSON_VALUE(custom_metrics.cms, '$.wordpress.theme.theme') AS wp_tema,
    ARRAY_LENGTH(JSON_QUERY_ARRAY(custom_metrics.cms, '$.wordpress.scripts')) AS wp_scripts,
    custom_metrics.javascript IS NOT NULL AS hay_javascript,
    custom_metrics.css_variables IS NOT NULL AS hay_css_variables,
    JSON_QUERY(custom_metrics.other, '$.initiators') IS NOT NULL AS hay_initiators
  FROM `httparchive.sample_data.pages_10k`
  WHERE is_root_page
)
SELECT
  client,
  page,
  rank,
  ARRAY_TO_STRING(wappalyzer, '|') AS wappalyzer,
  JSON_VALUE(aurora, '$.react_version')  AS aurora_react,
  JSON_VALUE(aurora, '$.next_version')   AS aurora_next,
  JSON_VALUE(aurora, '$.nuxt_version')   AS aurora_nuxt,
  JSON_VALUE(aurora, '$.nuxt_vue_version') AS aurora_nuxt_vue,
  JSON_VALUE(aurora, '$.ng_version')     AS aurora_angular,
  JSON_VALUE(aurora, '$.svelte_version') AS aurora_svelte,
  ARRAY_TO_STRING(JSON_VALUE_ARRAY(aurora, '$.feature_flags'), '|') AS aurora_feature_flags,
  hay_javascript,
  hay_css_variables,
  hay_initiators,
  ARRAY_TO_STRING(bundler, '|') AS bundler,
  ARRAY_TO_STRING(sourcemap_ext, '|') AS sourcemap_ext,
  sourcemap_count,
  wp_tema,
  wp_scripts,
  -- Marcadores en los <script> del HTML y en las URLs pedidas (rutas de build típicas de cada framework)
  REGEXP_CONTAINS(scripts_html, r'/_next/')                      AS html_next,
  REGEXP_CONTAINS(scripts_html, r'__NEXT_DATA__')                AS html_next_data,
  REGEXP_CONTAINS(scripts_html, r'turbopack')                    AS html_turbopack,
  REGEXP_CONTAINS(scripts_html, r'/_nuxt/|data-nuxt|__NUXT')     AS html_nuxt,
  REGEXP_CONTAINS(scripts_html, r'/_app/immutable/|sveltekit')   AS html_sveltekit,
  REGEXP_CONTAINS(scripts_html, r'/_astro/|astro-island')        AS html_astro,
  REGEXP_CONTAINS(scripts_html, r'(?i)/@vite/|vite')             AS html_vite,
  REGEXP_CONTAINS(scripts_html, r'(?i)jquery')                   AS html_jquery,
  REGEXP_CONTAINS(scripts_html, r'(?i)react')                    AS html_react,
  REGEXP_CONTAINS(scripts_html, r'(?i)vue')                      AS html_vue,
  REGEXP_CONTAINS(scripts_html, r'(?i)angular|zone\.js|polyfills\.[a-z0-9]+\.js') AS html_angular,
  REGEXP_CONTAINS(scripts_html, r'/wp-content/|/wp-includes/')   AS html_wordpress,
  REGEXP_CONTAINS(scripts_html, r'"type":"module"')              AS html_type_module,
  REGEXP_CONTAINS(urls_pedidas, r'/_next/')                      AS url_next,
  REGEXP_CONTAINS(urls_pedidas, r'turbopack')                    AS url_turbopack,
  REGEXP_CONTAINS(urls_pedidas, r'/_nuxt/')                      AS url_nuxt,
  REGEXP_CONTAINS(urls_pedidas, r'/_app/immutable/')             AS url_sveltekit,
  REGEXP_CONTAINS(urls_pedidas, r'/_astro/')                     AS url_astro,
  REGEXP_CONTAINS(urls_pedidas, r'(?i)jquery')                   AS url_jquery,
  REGEXP_CONTAINS(urls_pedidas, r'(?i)react')                    AS url_react,
  REGEXP_CONTAINS(urls_pedidas, r'(?i)vue')                      AS url_vue,
  REGEXP_CONTAINS(urls_pedidas, r'/wp-content/|/wp-includes/')   AS url_wordpress,
  REGEXP_CONTAINS(urls_pedidas, r'(?i)bootstrap')                AS url_bootstrap,
  REGEXP_CONTAINS(urls_pedidas, r'(?i)tailwind')                 AS url_tailwind,
  -- Prefijos de variables CSS de frameworks de estilos y de WordPress
  REGEXP_CONTAINS(css_vars, r'--tw-')                            AS css_tailwind,
  REGEXP_CONTAINS(css_vars, r'--bs-')                            AS css_bootstrap,
  REGEXP_CONTAINS(css_vars, r'--wp--')                           AS css_wordpress,
  REGEXP_CONTAINS(css_vars, r'--mui-|--Mui')                     AS css_mui,
  REGEXP_CONTAINS(css_vars, r'--chakra-')                        AS css_chakra,
  REGEXP_CONTAINS(css_vars, r'--mantine-')                       AS css_mantine,
  REGEXP_CONTAINS(css_vars, r'--el-')                            AS css_element_ui,
  REGEXP_CONTAINS(css_vars, r'--v-|--vuetify')                   AS css_vuetify,
  REGEXP_CONTAINS(css_vars, r'--ion-')                           AS css_ionic
FROM base
ORDER BY client, page
