-- Fecha: 2026-08-23
-- Propósito: semáforo de calidad (Good/Needs Improvement/Poor) de LCP, INP y CLS
--            para un único mes (jul 2026), reemplazando el semáforo solo-LCP de
--            jun 2026 usado antes en la presentación, para tener un mes consistente
--            con el resto de las cifras del dataset (HTTP Archive ya usa jul 2026).
-- Umbrales oficiales de Google: LCP <=2500ms / <=4000ms; INP <=200ms / <=500ms;
--            CLS <=0.10 / <=0.25 (p75_cls ya viene en la escala decimal cruda).
-- Filtro de partición: date = '2026-07-01'
-- Tablas: chrome-ux-report.materialized.metrics_summary

SELECT
  COUNT(*) AS total_origins,

  COUNTIF(p75_lcp IS NOT NULL) AS lcp_con_dato,
  COUNTIF(p75_lcp <= 2500) AS lcp_good,
  COUNTIF(p75_lcp > 2500 AND p75_lcp <= 4000) AS lcp_needs_improvement,
  COUNTIF(p75_lcp > 4000) AS lcp_poor,

  COUNTIF(p75_inp IS NOT NULL) AS inp_con_dato,
  COUNTIF(p75_inp <= 200) AS inp_good,
  COUNTIF(p75_inp > 200 AND p75_inp <= 500) AS inp_needs_improvement,
  COUNTIF(p75_inp > 500) AS inp_poor,

  COUNTIF(p75_cls IS NOT NULL) AS cls_con_dato,
  COUNTIF(p75_cls <= 0.10) AS cls_good,
  COUNTIF(p75_cls > 0.10 AND p75_cls <= 0.25) AS cls_needs_improvement,
  COUNTIF(p75_cls > 0.25) AS cls_poor
FROM `chrome-ux-report.materialized.metrics_summary`
WHERE date = '2026-07-01'
