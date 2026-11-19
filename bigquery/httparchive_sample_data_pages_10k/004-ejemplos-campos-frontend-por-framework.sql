-- Fecha: 2026-11-18
-- Propósito: contenido de los campos de custom_metrics propuestos como señal de framework o
--            tecnología frontend (cms.wordpress, javascript.bundler, javascript.document.scripts,
--            javascript.sourceMaps, javascript.script_tags, other.almanac.scripts, other.initiators,
--            markup.classes, markup.ids, css_variables) en 3 páginas raíz móviles por grupo según
--            Wappalyzer o aurora (React sin Next.js, Next.js, Vue sin Nuxt, Nuxt, Angular, Svelte,
--            jQuery sin framework, WordPress), las de mejor rank. Cada campo truncado a 3000
--            caracteres. Para ver el formato antes de extraer sobre la cohorte.
-- Filtro de partición: no aplica (tabla de muestra, un mes)
-- Tablas: httparchive.sample_data.pages_10k

WITH base AS (
  SELECT
    page,
    rank,
    custom_metrics AS cm,
    ARRAY(SELECT t.technology FROM UNNEST(technologies) AS t) AS techs
  FROM `httparchive.sample_data.pages_10k`
  WHERE is_root_page AND client = 'mobile'
),
grupos AS (
  SELECT *,
    CASE
      WHEN 'Next.js' IN UNNEST(techs) OR JSON_VALUE(cm.other, '$.aurora.next_version') IS NOT NULL THEN 'Next.js'
      WHEN 'Nuxt.js' IN UNNEST(techs) OR JSON_VALUE(cm.other, '$.aurora.nuxt_version') IS NOT NULL THEN 'Nuxt'
      WHEN 'Angular' IN UNNEST(techs) OR JSON_VALUE(cm.other, '$.aurora.ng_version') IS NOT NULL THEN 'Angular'
      WHEN 'Svelte' IN UNNEST(techs) OR JSON_VALUE(cm.other, '$.aurora.svelte_version') IS NOT NULL THEN 'Svelte'
      WHEN 'React' IN UNNEST(techs) OR JSON_VALUE(cm.other, '$.aurora.react_version') IS NOT NULL THEN 'React'
      WHEN 'Vue.js' IN UNNEST(techs) THEN 'Vue'
      WHEN 'WordPress' IN UNNEST(techs) THEN 'WordPress'
      WHEN 'jQuery' IN UNNEST(techs) THEN 'jQuery'
    END AS grupo
  FROM base
)
SELECT
  grupo,
  page,
  rank,
  ARRAY_TO_STRING(techs, ', ')                                                  AS wappalyzer,
  TO_JSON_STRING(JSON_QUERY(cm.other, '$.aurora'))                              AS aurora,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.cms, '$.wordpress')), 1, 3000)            AS cms_wordpress,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.javascript, '$.bundler')), 1, 3000)       AS js_bundler,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.javascript, '$.document')), 1, 3000)      AS js_document,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.javascript, '$.sourceMaps')), 1, 3000)    AS js_source_maps,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.javascript, '$.script_tags')), 1, 3000)   AS js_script_tags,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.other, '$.almanac.scripts')), 1, 3000)    AS almanac_scripts,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.other, '$.initiators')), 1, 3000)         AS initiators,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.markup, '$.classes')), 1, 3000)           AS markup_classes,
  SUBSTR(TO_JSON_STRING(JSON_QUERY(cm.markup, '$.ids')), 1, 3000)               AS markup_ids,
  SUBSTR(TO_JSON_STRING(cm.css_variables), 1, 3000)                             AS css_variables
FROM grupos
WHERE grupo IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY rank, page) <= 3
ORDER BY grupo, rank, page
