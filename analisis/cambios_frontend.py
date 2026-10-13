"""Cambios de tecnología frontend sitio por sitio, mes a mes, en la cohorte fija top 10k de 2025.

Entrada: panel largo del cliente pedido (ver analisis/fuentes.py), una fila por sitio x mes x
         tecnología detectada, con versión mayor y p75 de LCP/INP/CLS del mismo dispositivo.
         Con --aurora, además la custom metric "aurora" de HTTP Archive (fuentes.AURORA_2025).

Estado de un sitio-mes = conjunto de tecnologías frontend detectadas (lista TECNOLOGIAS_FRONTEND)
con su versión mayor cuando se conoce. Un sitio-mes sin filas en el panel no tiene tecnologías
registradas (dato faltante); un sitio-mes con filas pero sin ninguna tecnología de la lista queda con
el estado vacío ("sin tecnología frontend detectada").

Con --aurora, el estado de cada sitio-mes con dato de aurora combina las dos fuentes: un framework que
mide aurora (React, Next.js, Nuxt, Angular, Svelte) está presente si lo detecta Wappalyzer o aurora, y su
versión es la de aurora cuando Wappalyzer no la tiene (para React, siempre la de aurora si es de
react-dom); la versión de Vue.js se completa con la que usa Nuxt. Cada tecnología queda marcada con su
fuente: 0 = Wappalyzer, 1 = presencia por aurora, 2 = versión por aurora. aurora solo cubre las páginas
con rank <= 50000 de cada mes: entre dos meses donde alguno no tiene aurora, el cambio se calcula solo
con Wappalyzer, para no confundir un cambio de fuente con un cambio de tecnología. Los meses sin filas en
el panel donde aurora sí registró algo se informan aparte (solo_aurora) y no entran al cálculo de cambios.

Cambio = diferencia entre dos meses observados consecutivos del mismo sitio (los meses sin datos
se saltean): entra o sale una tecnología de la lista, o una tecnología presente en ambos meses
cambia de versión mayor (solo si la versión se conoce en los dos meses). No se exige persistencia:
es el registro crudo, previo a la regla de 3 meses de panel_piloto_scd2.py.

Salida: analisis/salidas/cambios_frontend_<cliente>.json (o cambios_frontend_<cliente>_aurora.json)
con todos los sitios que tienen al menos un cambio, sus 12 estados mensuales y sus métricas.

Uso: analisis/.venv/bin/python analisis/cambios_frontend.py [mobile|desktop] [--aurora]
"""

import json
import re
import sys

import duckdb

from frontend import AURORA_CAMPOS, AURORA_VERSION_VUE, FAMILIAS, REACT_DOM_MAYORES, TECNOLOGIAS_FRONTEND
from fuentes import AURORA_2025, COHORTE_ENERO, PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
CON_AURORA = "--aurora" in sys.argv
SALIDA = SALIDAS / f"cambios_frontend_{CLIENTE}{'_aurora' if CON_AURORA else ''}.json"
MESES = [f"2025-{m:02d}-01" for m in range(1, 13)]
WAPPALYZER, PRESENCIA_AURORA, VERSION_AURORA = 0, 1, 2

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

aurora = {}
if CON_AURORA:
    campos = list(AURORA_CAMPOS.values()) + [AURORA_VERSION_VUE]
    fuentes_aurora = ", ".join(f"'{p}'" for p in AURORA_2025)
    for fila in con.execute(f"""
        SELECT RTRIM(page, '/') AS origin, strftime(date, '%Y-%m-%d') AS mes, {", ".join(campos)}
        FROM read_parquet([{fuentes_aurora}]) WHERE client = '{CLIENTE}'""").fetchall():
        aurora[(fila[0], fila[1])] = dict(zip(campos, fila[2:]))


def mayor(version):
    m = re.match(r"^(\d+)", version or "")
    return int(m.group(1)) if m else None


def combinar(estado, datos_aurora):
    """Estado con las tecnologías de Wappalyzer completadas por aurora, cada una marcada con su fuente."""
    d = {t: [v, f] for t, v, f in estado}
    for tecnologia, campo in AURORA_CAMPOS.items():
        valor = datos_aurora.get(campo)
        if not valor:
            continue
        v = mayor(valor)
        if tecnologia == "React" and v not in REACT_DOM_MAYORES:
            v = None  # otro renderer: React presente, versión de react-dom desconocida
        if tecnologia not in d:
            d[tecnologia] = [v, PRESENCIA_AURORA]
        elif v is not None and d[tecnologia][0] != v and (d[tecnologia][0] is None or tecnologia == "React"):
            d[tecnologia] = [v, VERSION_AURORA]
    vue = mayor(datos_aurora.get(AURORA_VERSION_VUE))
    if "Vue.js" in d and d["Vue.js"][0] is None and vue is not None:
        d["Vue.js"] = [vue, VERSION_AURORA]
    return tuple(sorted((t, v, f) for t, (v, f) in d.items()))


sitios, solo_aurora = {}, {}
for origin, mes, rank, lcp, inp, cls, frontend in filas:
    estado = tuple((t, int(v) if v is not None else None, WAPPALYZER) for t, v in (frontend or []))
    cubierto = (origin, mes) in aurora
    combinado = combinar(estado, aurora[(origin, mes)]) if cubierto else estado
    sitios.setdefault(origin, {})[mes] = (rank, lcp, inp, cls, estado, combinado, cubierto)
for (origin, mes), datos in aurora.items():
    if origin in sitios and mes not in sitios[origin]:
        estado = combinar((), datos)
        if estado:
            solo_aurora.setdefault(origin, {})[MESES.index(mes)] = [[t, v] for t, v, _ in estado]


def cambio(antes, despues):
    """Tecnologías que entran, salen o cambian de versión mayor entre dos estados."""
    va = {t: v for t, v, _ in antes}
    vd = {t: v for t, v, _ in despues}
    entran = sorted(set(vd) - set(va))
    salen = sorted(set(va) - set(vd))
    version = sorted(t for t in set(va) & set(vd)
                     if va[t] is not None and vd[t] is not None and va[t] != vd[t])
    return entran, salen, version


def estado_para(previo, actual):
    """Estados que se comparan entre dos meses: combinados solo si ambos tienen aurora."""
    if CON_AURORA and previo[6] and actual[6]:
        return previo[5], actual[5]
    return previo[4], actual[4]


estados, indice_estado = [], {}
salida_sitios = []
resumen = {"sitios_cohorte": len(sitios), "sitios_con_cambio": 0, "sitios_con_cambio_de_tecnologia": 0,
           "sitios_solo_cambio_de_version": 0, "cambios": 0, "cambios_de_tecnologia": 0,
           "cambios_solo_de_version": 0, "cambios_sale_react": 0}
for origin, por_mes in sitios.items():
    observados = [m for m in MESES if m in por_mes]
    cambios = []
    for previo, actual in zip(observados, observados[1:]):
        entran, salen, version = cambio(*estado_para(por_mes[previo], por_mes[actual]))
        if entran or salen or version:
            cambios.append({"mes": MESES.index(actual), "entran": entran, "salen": salen, "version": version})
    if not cambios:
        continue
    de_tecnologia = sum(1 for c in cambios if c["entran"] or c["salen"])
    resumen["sitios_con_cambio"] += 1
    resumen["cambios"] += len(cambios)
    resumen["cambios_de_tecnologia"] += de_tecnologia
    resumen["cambios_solo_de_version"] += len(cambios) - de_tecnologia
    resumen["cambios_sale_react"] += sum("React" in c["salen"] for c in cambios)
    if de_tecnologia:
        resumen["sitios_con_cambio_de_tecnologia"] += 1
    else:
        resumen["sitios_solo_cambio_de_version"] += 1

    meses = []
    for m in MESES:
        if m not in por_mes:
            meses.append(None)
            continue
        rank, lcp, inp, cls, estado, combinado, cubierto = por_mes[m]
        mostrado = combinado if CON_AURORA else estado
        if mostrado not in indice_estado:
            indice_estado[mostrado] = len(estados)
            estados.append([[t, v, f] for t, v, f in mostrado])
        fila = [indice_estado[mostrado], lcp, inp, None if cls is None else round(cls, 2)]
        if CON_AURORA:
            fila.append(int(cubierto))
        meses.append(fila)
    sitio = {"origin": origin, "rank_enero": rank_enero.get(origin), "meses": meses, "cambios": cambios}
    if origin in solo_aurora:
        sitio["solo_aurora"] = solo_aurora[origin]
    salida_sitios.append(sitio)

resumen["sitio_mes_sin_datos_en_sitios_con_cambio"] = sum(
    m is None for s in salida_sitios for m in s["meses"])

# Comparación por framework sobre todos los sitio-mes observados de la cohorte (no solo los que cambian).
comparacion = None
if CON_AURORA:
    marcos = list(AURORA_CAMPOS) + ["Vue.js"]
    comparacion = {"sitio_mes_observados": 0, "sitio_mes_con_aurora": 0,
                   "visitas_sin_wappalyzer_con_aurora": sum(len(v) for v in solo_aurora.values()),
                   "frameworks": {t: {"wappalyzer": 0, "wappalyzer_con_version": 0, "combinado": 0,
                                      "combinado_con_version": 0, "solo_aurora": 0} for t in marcos}}
    for por_mes in sitios.values():
        for rank, lcp, inp, cls, estado, combinado, cubierto in por_mes.values():
            comparacion["sitio_mes_observados"] += 1
            comparacion["sitio_mes_con_aurora"] += int(cubierto)
            w = {t: v for t, v, _ in estado}
            c = {t: (v, f) for t, v, f in combinado}
            for t in marcos:
                r = comparacion["frameworks"][t]
                r["wappalyzer"] += t in w
                r["wappalyzer_con_version"] += w.get(t) is not None
                r["combinado"] += t in c
                r["combinado_con_version"] += t in c and c[t][0] is not None
                r["solo_aurora"] += t in c and c[t][1] == PRESENCIA_AURORA

SALIDA.write_text(json.dumps({
    "cliente": CLIENTE,
    "fuente": "wappalyzer+aurora" if CON_AURORA else "wappalyzer",
    "meses": [m[:7] for m in MESES],
    "familias": FAMILIAS,
    "tecnologias": TECNOLOGIAS_FRONTEND,
    "resumen": resumen,
    "comparacion": comparacion,
    "estados": estados,
    "sitios": salida_sitios,
}, ensure_ascii=False, separators=(",", ":")))
print(json.dumps({"resumen": resumen, "comparacion": comparacion}, ensure_ascii=False, indent=1))
