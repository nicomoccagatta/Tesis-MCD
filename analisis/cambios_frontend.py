"""Cambios de tecnología frontend sitio por sitio, mes a mes, en la cohorte fija top 10k de 2025.

Entrada: panel largo del cliente pedido (ver analisis/fuentes.py), una fila por sitio x mes x
         tecnología detectada, con versión mayor y p75 de LCP/INP/CLS del mismo dispositivo.

Estado de un sitio-mes = conjunto de tecnologías frontend detectadas (lista TECNOLOGIAS_FRONTEND)
con su versión mayor cuando Wappalyzer la detecta. Un sitio-mes sin filas en el panel no tiene
tecnologías registradas (dato faltante); un sitio-mes con filas pero sin ninguna tecnología de la
lista queda con el estado vacío ("sin tecnología frontend detectada").

Cambio = diferencia entre dos meses observados consecutivos del mismo sitio (los meses sin datos
se saltean): entra o sale una tecnología de la lista, o una tecnología presente en ambos meses
cambia de versión mayor (solo si la versión se detecta en los dos meses). No se exige
persistencia: es el registro crudo, previo a la regla de 3 meses de panel_piloto_scd2.py.

Salida: analisis/salidas/cambios_frontend_<cliente>.json con todos los sitios que tienen al menos
un cambio, sus 12 estados mensuales y sus métricas.

Uso: analisis/.venv/bin/python analisis/cambios_frontend.py [mobile|desktop]
"""

import json

import duckdb

from frontend import FAMILIAS, TECNOLOGIAS_FRONTEND
from fuentes import COHORTE_ENERO, PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
SALIDA = SALIDAS / f"cambios_frontend_{CLIENTE}.json"
MESES = [f"2025-{m:02d}-01" for m in range(1, 13)]

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANELES[CLIENTE]}'")
con.execute("CREATE TABLE lista AS SELECT * FROM (VALUES "
            + ", ".join(f"('{t}')" for t in TECNOLOGIAS_FRONTEND) + ") AS l(technology)")

# Un registro por sitio-mes observado: rank, métricas y tecnologías frontend con versión.
filas = con.execute("""
SELECT
  origin,
  strftime(date, '%Y-%m-%d') AS mes,
  ANY_VALUE(rank) AS rank,
  ANY_VALUE(p75_lcp) AS lcp,
  ANY_VALUE(p75_inp) AS inp,
  ANY_VALUE(p75_cls) AS cls,
  list_sort(list([technology, version_mayor::VARCHAR]) FILTER (WHERE technology IN (SELECT technology FROM lista)))
    AS frontend
FROM largo
GROUP BY origin, date
ORDER BY origin, date
""").fetchall()

rank_enero = dict(con.execute(f"SELECT origin, rank FROM '{COHORTE_ENERO}'").fetchall())

sitios = {}
for origin, mes, rank, lcp, inp, cls, frontend in filas:
    estado = tuple((t, int(v) if v is not None else None) for t, v in (frontend or []))
    sitios.setdefault(origin, {})[mes] = (rank, lcp, inp, cls, estado)


def cambio(antes, despues):
    """Tecnologías que entran, salen o cambian de versión mayor entre dos estados."""
    va, vd = dict(antes), dict(despues)
    entran = sorted(set(vd) - set(va))
    salen = sorted(set(va) - set(vd))
    version = sorted(t for t in set(va) & set(vd)
                     if va[t] is not None and vd[t] is not None and va[t] != vd[t])
    return entran, salen, version


estados, indice_estado = [], {}
salida_sitios = []
resumen = {"sitios_cohorte": len(sitios), "sitios_con_cambio": 0, "sitios_con_cambio_de_tecnologia": 0,
           "sitios_solo_cambio_de_version": 0, "cambios": 0, "cambios_de_tecnologia": 0,
           "cambios_solo_de_version": 0}
for origin, por_mes in sitios.items():
    observados = [m for m in MESES if m in por_mes]
    cambios = []
    for previo, actual in zip(observados, observados[1:]):
        entran, salen, version = cambio(por_mes[previo][4], por_mes[actual][4])
        if entran or salen or version:
            cambios.append({"mes": MESES.index(actual), "entran": entran, "salen": salen, "version": version})
    if not cambios:
        continue
    de_tecnologia = sum(1 for c in cambios if c["entran"] or c["salen"])
    resumen["sitios_con_cambio"] += 1
    resumen["cambios"] += len(cambios)
    resumen["cambios_de_tecnologia"] += de_tecnologia
    resumen["cambios_solo_de_version"] += len(cambios) - de_tecnologia
    if de_tecnologia:
        resumen["sitios_con_cambio_de_tecnologia"] += 1
    else:
        resumen["sitios_solo_cambio_de_version"] += 1

    meses = []
    for m in MESES:
        if m not in por_mes:
            meses.append(None)
            continue
        rank, lcp, inp, cls, estado = por_mes[m]
        if estado not in indice_estado:
            indice_estado[estado] = len(estados)
            estados.append([[t, v] for t, v in estado])
        meses.append([indice_estado[estado], lcp, inp, None if cls is None else round(cls, 2)])
    salida_sitios.append({"origin": origin, "rank_enero": rank_enero.get(origin), "meses": meses, "cambios": cambios})

resumen["sitio_mes_sin_datos_en_sitios_con_cambio"] = sum(
    m is None for s in salida_sitios for m in s["meses"])
SALIDA.write_text(json.dumps({
    "cliente": CLIENTE,
    "meses": [m[:7] for m in MESES],
    "familias": FAMILIAS,
    "tecnologias": TECNOLOGIAS_FRONTEND,
    "resumen": resumen,
    "estados": estados,
    "sitios": salida_sitios,
}, ensure_ascii=False, separators=(",", ":")))
print(json.dumps(resumen, ensure_ascii=False, indent=1))
