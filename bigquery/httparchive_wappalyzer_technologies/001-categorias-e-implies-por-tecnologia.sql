-- Fecha: 2026-10-01
-- Propósito: tabla de referencia de Wappalyzer con las categorías y las relaciones
--            "implies" de cada tecnología (ej. Next.js implica React), para unir
--            localmente con el panel cross_source/003 sin leer la subcolumna
--            technologies.categories de crawl.pages (que duplica el costo del escaneo).
-- Filtro de partición: no aplica (tabla chica sin particionar, ~1 MB)
-- Tablas: httparchive.wappalyzer.technologies

SELECT
  name AS technology,
  ARRAY_TO_STRING(categories, '; ') AS categorias,
  ARRAY_TO_STRING(implies, '; ')    AS implies
FROM `httparchive.wappalyzer.technologies`
ORDER BY technology
