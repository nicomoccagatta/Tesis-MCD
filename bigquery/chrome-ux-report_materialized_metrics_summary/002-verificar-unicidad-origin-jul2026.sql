-- Fecha: 2026-08-23
-- Propósito: verificar que cada fila de metrics_summary es un origin distinto
--            para una fecha dada (sin duplicados por dispositivo/página), antes
--            de confiar en COUNT(*) como "cantidad de origins".
-- Filtro de partición: date = '2026-07-01'
-- Tablas: chrome-ux-report.materialized.metrics_summary
-- Resultado: total_rows = distinct_origins = 18.059.068 (sin duplicados).

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT origin) AS distinct_origins
FROM `chrome-ux-report.materialized.metrics_summary`
WHERE date = '2026-07-01'
