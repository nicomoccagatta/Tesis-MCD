-- Fecha: 2026-08-23
-- Propósito: serie semestral de root pages únicas en el panel (2020-2026), para
--            reproducir con un artefacto real el hallazgo de crecimiento/estabilidad
--            del panel ya documentado en la memoria del proyecto.
-- Filtro de partición: date IN (14 fechas semestrales puntuales)
-- Tablas: httparchive.crawl.pages

SELECT
  date,
  APPROX_COUNT_DISTINCT(page) AS root_pages
FROM `httparchive.crawl.pages`
WHERE date IN (
  '2020-01-01', '2020-07-01',
  '2021-01-01', '2021-07-01',
  '2022-01-01', '2022-07-01',
  '2023-01-01', '2023-07-01',
  '2024-01-01', '2024-07-01',
  '2025-01-01', '2025-07-01',
  '2026-01-01', '2026-07-01'
)
AND is_root_page = TRUE
GROUP BY date
ORDER BY date
