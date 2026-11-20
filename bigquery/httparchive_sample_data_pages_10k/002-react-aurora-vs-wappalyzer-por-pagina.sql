-- Fecha: 2026-10-13
-- Propósito: validar la custom metric "aurora" de HTTP Archive (react_version por el hook de
--            React DevTools) página por página. Lista las páginas raíz de la muestra de 10k con
--            React según aurora o según Wappalyzer, con la versión que da cada uno y las
--            tecnologías frontend que detecta Wappalyzer, para contrastar cada página contra el
--            sitio real (chequeo automático de react-dom en sus scripts y revisión con React
--            DevTools). Complementa al agregado de 001.
-- Filtro de partición: no aplica (tabla de muestra, ~30 GB en total)
-- Tablas: httparchive.sample_data.pages_10k

WITH paginas AS (
  SELECT
    date,
    client,
    page,
    rank,
    JSON_VALUE(custom_metrics.other, '$.aurora.react_version') AS react_version_aurora,
    (SELECT ANY_VALUE(t.info[SAFE_OFFSET(0)]) FROM UNNEST(technologies) AS t WHERE t.technology = 'React') AS react_version_wappalyzer,
    EXISTS(SELECT 1 FROM UNNEST(technologies) AS t WHERE t.technology = 'React') AS react_wappalyzer,
    (SELECT STRING_AGG(t.technology, ', ' ORDER BY t.technology) FROM UNNEST(technologies) AS t
      WHERE t.technology IN ('React', 'Next.js', 'Next.js App Router', 'Remix', 'React Router', 'Gatsby',
                             'Preact', 'Vue.js', 'Nuxt.js', 'Angular', 'AngularJS', 'Svelte', 'SvelteKit',
                             'Astro', 'Qwik', 'jQuery', 'WordPress')) AS frontend_wappalyzer
  FROM `httparchive.sample_data.pages_10k`
  WHERE is_root_page
)
SELECT *
FROM paginas
WHERE react_version_aurora IS NOT NULL OR react_wappalyzer
ORDER BY client, (react_version_aurora IS NOT NULL) AND NOT react_wappalyzer DESC, rank, page
