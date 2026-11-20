-- Fecha: 2026-10-13
-- Propósito: con la muestra de 10k páginas de HTTP Archive (tabla chica, que el Sandbox puede
--            leer), verificar dónde guarda HTTP Archive la custom metric "aurora" y medir cuántas
--            páginas tienen React según aurora (react_version, obtenida con el hook de React
--            DevTools: funciona con createRoot/hydrateRoot de React 18 y 19) pero no según
--            Wappalyzer, por versión mayor de React y cliente. En crawl.pages esa columna estima
--            ~2 TB por mes y el Sandbox rechaza la consulta.
-- Filtro de partición: no aplica (tabla de muestra, ~30 GB en total)
-- Tablas: httparchive.sample_data.pages_10k

WITH paginas AS (
  SELECT
    date,
    client,
    is_root_page,
    JSON_VALUE(custom_metrics.other, '$.aurora.react_version') AS react_aurora,
    EXISTS(SELECT 1 FROM UNNEST(technologies) AS t WHERE t.technology = 'React') AS react_wappalyzer,
    EXISTS(SELECT 1 FROM UNNEST(technologies) AS t WHERE t.technology IN ('Next.js', 'Remix', 'Gatsby', 'React Router')) AS framework_react_wappalyzer
  FROM `httparchive.sample_data.pages_10k`
)
SELECT
  date,
  client,
  is_root_page,
  REGEXP_EXTRACT(react_aurora, r'^(\d+)') AS react_mayor_aurora,
  react_wappalyzer,
  framework_react_wappalyzer,
  COUNT(*) AS paginas
FROM paginas
GROUP BY ALL
ORDER BY date, client, is_root_page, react_mayor_aurora, react_wappalyzer, framework_react_wappalyzer
