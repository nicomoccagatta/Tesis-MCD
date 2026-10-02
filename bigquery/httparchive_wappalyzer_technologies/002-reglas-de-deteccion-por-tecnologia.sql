-- Fecha: 2026-10-02
-- Propósito: para cada tecnología de Wappalyzer, cuántas reglas de detección tiene de cada
--            tipo, para separar con un criterio medido (no por el nombre de la categoría) las
--            tecnologías que se detectan por código cargado en la página (scriptSrc, js, xhr)
--            de las que se detectan por infraestructura (headers, dns, cookies, etc.).
--            Insumo para decidir qué entra al grafo bipartito además de las librerías.
-- Filtro de partición: no aplica (tabla chica sin particionar, ~1 MB)
-- Tablas: httparchive.wappalyzer.technologies

SELECT
  name                              AS technology,
  ARRAY_TO_STRING(categories, '; ') AS categorias,
  ARRAY_TO_STRING(implies, '; ')    AS implies,
  ARRAY_LENGTH(scriptSrc)           AS reglas_scriptsrc,
  ARRAY_LENGTH(js)                  AS reglas_js,
  ARRAY_LENGTH(xhr)                 AS reglas_xhr,
  ARRAY_LENGTH(script)              AS reglas_script,
  ARRAY_LENGTH(dom)                 AS reglas_dom,
  ARRAY_LENGTH(html)                AS reglas_html,
  ARRAY_LENGTH(text)                AS reglas_text,
  ARRAY_LENGTH(css)                 AS reglas_css,
  ARRAY_LENGTH(meta)                AS reglas_meta,
  ARRAY_LENGTH(url)                 AS reglas_url,
  ARRAY_LENGTH(headers)             AS reglas_headers,
  ARRAY_LENGTH(cookies)             AS reglas_cookies,
  ARRAY_LENGTH(dns)                 AS reglas_dns,
  ARRAY_LENGTH(robots)              AS reglas_robots,
  ARRAY_LENGTH(probe)               AS reglas_probe
FROM `httparchive.wappalyzer.technologies`
ORDER BY technology
