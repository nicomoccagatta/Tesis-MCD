"""Panel piloto top 10k 2025: dimensión SCD-2 de tecnología y eventos de migración.

Entrada: panel largo del cliente pedido (ver analisis/fuentes.py), una fila por
         sitio x mes x tecnología detectada, para la cohorte fija de enero 2025.
         Un mes sin filas para un sitio es una visita fallida o vacía (dato faltante).
Salidas: analisis/salidas/panel_piloto_scd2_<cliente>.json (números para el deck) y
         analisis/salidas/eventos_persistentes_<cliente>.parquet.

Uso: analisis/.venv/bin/python analisis/panel_piloto_scd2.py [mobile|desktop]
"""

import json

import duckdb

from fuentes import PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
PANEL = PANELES[CLIENTE]
SALIDA = SALIDAS / f"panel_piloto_scd2_{CLIENTE}.json"
EVENTOS = SALIDAS / f"eventos_persistentes_{CLIENTE}.parquet"

TECNOLOGIAS = ["jQuery", "React", "Vue.js", "Angular", "Next.js", "WordPress"]
PERSISTENCIA_MESES = 3

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANEL}'")

# Panel origen x mes: una fila por sitio-mes observado, con flags por tecnología.
flags = ",\n".join(
    f"BOOL_OR(technology = '{t}') AS \"{t}\"" for t in TECNOLOGIAS
)
con.execute(f"""
CREATE TABLE panel AS
SELECT
  origin,
  date,
  datediff('month', DATE '2025-01-01', date) AS mes,
  ANY_VALUE(rank) AS rank,
  ANY_VALUE(p75_lcp) AS p75_lcp,
  ANY_VALUE(p75_inp) AS p75_inp,
  ANY_VALUE(p75_cls) AS p75_cls,
  {flags}
FROM largo
GROUP BY origin, date
""")

meses_totales = con.execute("SELECT COUNT(DISTINCT mes) FROM panel").fetchone()[0]

cobertura = con.execute(f"""
WITH por_sitio AS (SELECT origin, COUNT(*) AS meses FROM panel GROUP BY origin)
SELECT
  (SELECT COUNT(*) FROM por_sitio)                                  AS sitios_cohorte,
  (SELECT COUNT(*) FROM por_sitio WHERE meses = {meses_totales})    AS sitios_balanceados,
  (SELECT COUNT(*) FROM por_sitio WHERE meses BETWEEN {meses_totales - 2} AND {meses_totales - 1}) AS sitios_faltan_1_o_2_meses,
  (SELECT COUNT(*) FROM por_sitio WHERE meses < {meses_totales - 2}) AS sitios_faltan_3_o_mas_meses,
  (SELECT ROUND(AVG(n)) FROM (SELECT COUNT(*) AS n FROM panel GROUP BY mes)) AS sitios_por_mes,
  (SELECT ROUND(100 * AVG((p75_lcp IS NOT NULL)::INT), 1) FROM panel) AS pct_sitio_mes_con_lcp,
  (SELECT ROUND(100 * (1 - COUNT(*) / ((SELECT COUNT(*) FROM por_sitio) * {meses_totales})), 1) FROM panel)
                                                                     AS pct_sitio_mes_sin_visita,
  (SELECT ROUND(100 * AVG((rank > 10000)::INT), 1) FROM panel WHERE mes > 0)
                                                                     AS pct_sitio_mes_fuera_top10k
""").fetchone()

# SCD-2: tramos contiguos de presencia de cada tecnología en cada sitio,
# solo sobre sitios observados los 12 meses (sin huecos de observación).
con.execute(f"""
CREATE TABLE balanceado AS
SELECT * FROM panel
WHERE origin IN (SELECT origin FROM panel GROUP BY origin HAVING COUNT(*) = {meses_totales})
""")

unpivot = " UNION ALL ".join(
    f"SELECT origin, mes, '{t}' AS tecnologia, \"{t}\" AS presente FROM balanceado"
    for t in TECNOLOGIAS
)
con.execute(f"""
CREATE TABLE scd2 AS
WITH estados AS ({unpivot}),
cambios AS (
  SELECT *,
    (presente IS DISTINCT FROM LAG(presente) OVER w)::INT AS es_cambio
  FROM estados
  WINDOW w AS (PARTITION BY origin, tecnologia ORDER BY mes)
),
cortes AS (
  SELECT *,
    SUM(es_cambio) OVER (PARTITION BY origin, tecnologia ORDER BY mes
                         ROWS UNBOUNDED PRECEDING) AS tramo
  FROM cambios
)
SELECT origin, tecnologia, presente,
       MIN(mes) AS valid_from, MAX(mes) AS valid_to, COUNT(*) AS duracion
FROM cortes
WHERE presente
GROUP BY origin, tecnologia, presente, tramo
""")

# Tramos que no tocan los bordes de la ventana y duran 1 mes: aparición-desaparición
# puntual de la tecnología, consistente con ruido de detección de Wappalyzer.
ruido = con.execute(f"""
SELECT tecnologia,
       COUNT(*)                                                      AS tramos,
       COUNTIF(duracion = 1 AND valid_from > 0 AND valid_to < {meses_totales - 1}) AS tramos_de_un_mes_internos
FROM scd2
GROUP BY tecnologia
ORDER BY tramos DESC
""").fetchall()


con.execute(
    "CREATE TABLE eventos_persistentes (par VARCHAR, origin VARCHAR, mes_evento INTEGER)"
)


def eventos(nombre, antes, despues):
    """Cuenta sitios con un cambio de estado antes->después en meses consecutivos del panel
    balanceado: crudo (un mes antes / un mes después) y persistente (>= 3 meses de cada lado).
    Un cambio persistente solo puede empezar entre el mes k y el mes (meses - k); los crudos
    fuera de ese rango no se pueden verificar, así que el descarte atribuible a la regla de
    persistencia se mide solo sobre los crudos verificables.
    Los persistentes quedan guardados en eventos_persistentes con su mes de cambio."""
    k = PERSISTENCIA_MESES
    con.execute(f"""
    CREATE OR REPLACE TABLE ventanas AS
    WITH estado AS (
      SELECT origin, mes,
             ({antes})   AS es_antes,
             ({despues}) AS es_despues
      FROM balanceado
    ),
    calculo AS (
      SELECT origin, mes,
        LAG(es_antes) OVER w AS antes_1,
        es_despues AS despues_1,
        BOOL_AND(es_antes)   OVER (w ROWS BETWEEN {k} PRECEDING AND 1 PRECEDING) AS antes_k,
        COUNT(*)             OVER (w ROWS BETWEEN {k} PRECEDING AND 1 PRECEDING) AS n_antes,
        BOOL_AND(es_despues) OVER (w ROWS BETWEEN CURRENT ROW AND {k - 1} FOLLOWING) AS despues_k,
        COUNT(*)             OVER (w ROWS BETWEEN CURRENT ROW AND {k - 1} FOLLOWING) AS n_despues
      FROM estado
      WINDOW w AS (PARTITION BY origin ORDER BY mes)
    )
    SELECT * FROM calculo
    """)
    persistente = f"antes_k AND n_antes = {k} AND despues_k AND n_despues = {k}"
    con.execute(f"""
    INSERT INTO eventos_persistentes
    SELECT '{nombre}', origin, MIN(mes) FROM ventanas WHERE {persistente} GROUP BY origin
    """)
    return con.execute(f"""
    SELECT
      '{nombre}' AS par,
      COUNT(DISTINCT origin) FILTER (WHERE antes_1 AND despues_1) AS sitios_cambio_crudo,
      COUNT(DISTINCT origin) FILTER (
        WHERE antes_1 AND despues_1 AND mes BETWEEN {k} AND {meses_totales - k}
      ) AS sitios_cambio_crudo_verificable,
      COUNT(DISTINCT origin) FILTER (WHERE {persistente}) AS sitios_cambio_persistente
    FROM ventanas
    """).fetchone()


pares = [
    eventos("jQuery→React",
            '"jQuery" AND NOT "React"', '"React" AND NOT "jQuery"'),
    eventos("jQuery→React (conservando jQuery)",
            '"jQuery" AND NOT "React"', '"React" AND "jQuery"'),
    eventos("React→Next.js",
            '"React" AND NOT "Next.js"', '"Next.js"'),
    eventos("Abandono de WordPress",
            '"WordPress"', 'NOT "WordPress"'),
]

resultado = {
    "cliente": CLIENTE,
    "meses": meses_totales,
    "sitios_cohorte": cobertura[0],
    "sitios_balanceados": cobertura[1],
    "sitios_faltan_1_o_2_meses": cobertura[2],
    "sitios_faltan_3_o_mas_meses": cobertura[3],
    "sitios_por_mes": cobertura[4],
    "pct_sitio_mes_con_lcp": cobertura[5],
    "pct_sitio_mes_sin_visita": cobertura[6],
    "pct_sitio_mes_fuera_top10k_feb_dic": cobertura[7],
    "scd2_tramos": [
        {"tecnologia": t, "tramos": n, "tramos_un_mes_internos": r} for t, n, r in ruido
    ],
    "eventos": [
        {
            "par": p,
            "sitios_crudo": c,
            "sitios_crudo_verificable": v,
            "sitios_persistente_3m": s,
            "pct_descartado_verificable": round(100 * (1 - s / v)) if v else None,
        }
        for p, c, v, s in pares
    ],
}

SALIDA.parent.mkdir(parents=True, exist_ok=True)
con.execute(f"COPY (SELECT * FROM eventos_persistentes ORDER BY par, origin) TO '{EVENTOS}' (FORMAT PARQUET)")
SALIDA.write_text(json.dumps(resultado, ensure_ascii=False, indent=2))
print(json.dumps(resultado, ensure_ascii=False, indent=2))
