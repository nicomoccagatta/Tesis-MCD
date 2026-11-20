-- Fecha: 2026-11-18
-- Propósito: qué claves traen las columnas de custom_metrics con posibles señales de framework o
--            tecnología frontend (cms, javascript, markup, css_variables, other) y en cuántas
--            páginas raíz aparece cada una, por cliente. Hasta 3 niveles de profundidad. Para
--            elegir qué campos extraer sobre la cohorte en crawl.pages.
-- Filtro de partición: no aplica (tabla de muestra, un mes)
-- Tablas: httparchive.sample_data.pages_10k

WITH paginas AS (
  SELECT client, custom_metrics AS cm
  FROM `httparchive.sample_data.pages_10k`
  WHERE is_root_page
),
claves AS (
  SELECT client, 'cms' AS columna, k AS clave FROM paginas, UNNEST(JSON_KEYS(cm.cms, 3)) AS k
  UNION ALL
  SELECT client, 'javascript', k FROM paginas, UNNEST(JSON_KEYS(cm.javascript, 3)) AS k
  UNION ALL
  SELECT client, 'markup', k FROM paginas, UNNEST(JSON_KEYS(cm.markup, 3)) AS k
  UNION ALL
  SELECT client, 'css_variables', k FROM paginas, UNNEST(JSON_KEYS(cm.css_variables, 1)) AS k
  UNION ALL
  SELECT client, 'other', k FROM paginas, UNNEST(JSON_KEYS(cm.other, 3)) AS k
)
SELECT
  columna,
  clave,
  COUNTIF(client = 'mobile')  AS paginas_mobile,
  COUNTIF(client = 'desktop') AS paginas_desktop,
  (SELECT COUNTIF(client = 'mobile')  FROM paginas) AS total_mobile,
  (SELECT COUNTIF(client = 'desktop') FROM paginas) AS total_desktop
FROM claves
GROUP BY columna, clave
ORDER BY columna, clave
