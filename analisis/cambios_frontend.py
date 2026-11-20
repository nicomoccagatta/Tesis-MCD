"""Cambios de tecnología frontend sitio por sitio, mes a mes, en la cohorte fija top 10k de 2025.

Entrada: panel largo del cliente pedido (ver analisis/fuentes.py), una fila por sitio x mes x
         tecnología detectada con su versión mayor; la custom metric "aurora" de HTTP Archive de todas las
         visitas a las páginas de la cohorte en 2025 (fuentes.AURORA_2025); y el p75 de LCP/INP/CLS de CrUX
         del mismo dispositivo para los 12 meses (fuentes.CRUX_2025).

Tecnologías y métricas son independientes: un mes muestra las métricas de CrUX aunque HTTP Archive no
haya registrado tecnologías, y las tecnologías aunque CrUX no tenga métricas. Un mes sin tecnologías
es una visita con la lista de Wappalyzer vacía o un mes sin visita de HTTP Archive (sin_visita): toda
visita a una página de la cohorte en 2025 tiene su fila de aurora (verificado con
httparchive_crawl_pages/010 para los meses sin filas en el panel).

Estado de un sitio-mes = conjunto de tecnologías frontend detectadas (lista TECNOLOGIAS_FRONTEND)
con su versión mayor cuando se conoce. Un sitio-mes sin filas en el panel no tiene tecnologías
registradas (dato faltante); un sitio-mes con filas pero sin ninguna tecnología de la lista queda con
el estado vacío ("sin tecnología frontend detectada").

Cada sitio-mes tiene dos estados, uno por fuente:
- Wappalyzer: las tecnologías del panel.
- Wappalyzer + aurora: un framework que mide aurora (React, Next.js, Nuxt, Angular, Svelte) está
  presente si lo detecta Wappalyzer o aurora, y su versión es la de aurora cuando Wappalyzer no la tiene
  (para React, siempre la de aurora si es de react-dom); la versión de Vue.js se completa con la que usa
  Nuxt. Cada tecnología queda marcada con su fuente: 0 = Wappalyzer, 1 = presencia por aurora,
  2 = versión por aurora. Los meses sin filas en el panel donde aurora sí registró algo se informan
  aparte (solo_aurora) y no entran al cálculo de cambios.

Cambio = diferencia entre dos meses observados consecutivos del mismo sitio (los meses sin datos
se saltean): entra o sale una tecnología de la lista, o una tecnología presente en ambos meses
cambia de versión mayor (solo si la versión se conoce en los dos meses). No se exige persistencia:
es el registro crudo, previo a la regla de 3 meses de panel_piloto_scd2.py.

Salida: analisis/salidas/cambios_frontend_<cliente>.json (Wappalyzer) y
cambios_frontend_<cliente>_aurora.json (Wappalyzer + aurora). Las dos listan los mismos sitios, en el
mismo orden: los que tienen al menos un cambio en alguna de las dos fuentes, con sus 12 meses
([estado o null si no hay tecnologías, lcp, inp, cls]) y los cambios de esa fuente (vacío si solo
cambia en la otra).

Uso: analisis/.venv/bin/python analisis/cambios_frontend.py [mobile|desktop]
"""

import json
import re

import duckdb

from frontend import AURORA_CAMPOS, AURORA_VERSION_VUE, FAMILIAS, REACT_DOM_MAYORES, TECNOLOGIAS_FRONTEND
from fuentes import AURORA_2025, COHORTE_ENERO, CRUX_2025, PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
SALIDA = {"wappalyzer": SALIDAS / f"cambios_frontend_{CLIENTE}.json",
          "wappalyzer+aurora": SALIDAS / f"cambios_frontend_{CLIENTE}_aurora.json"}
MESES = [f"2025-{m:02d}-01" for m in range(1, 13)]
DISPOSITIVO_CRUX = {"mobile": "phone", "desktop": "desktop"}[CLIENTE]
WAPPALYZER, PRESENCIA_AURORA, VERSION_AURORA = 0, 1, 2

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANELES[CLIENTE]}'")
con.execute("CREATE TABLE lista AS SELECT * FROM (VALUES "
            + ", ".join(f"('{t}')" for t in TECNOLOGIAS_FRONTEND) + ") AS l(technology)")

# Un registro por sitio-mes observado: tecnologías frontend con versión.
filas = con.execute("""
SELECT
  origin,
  strftime(date, '%Y-%m-%d') AS mes,
  list_sort(list([technology, version_mayor::VARCHAR]) FILTER (WHERE technology IN (SELECT technology FROM lista)))
    AS frontend
FROM largo
GROUP BY origin, date
ORDER BY origin, date
""").fetchall()

rank_enero = dict(con.execute(f"SELECT origin, rank FROM '{COHORTE_ENERO}'").fetchall())
metricas = {(o, m): (lcp, inp, None if cls is None else round(cls, 2)) for o, m, lcp, inp, cls in con.execute(f"""
    SELECT origin, strftime(date, '%Y-%m-%d'), p75_lcp, p75_inp, p75_cls
    FROM '{CRUX_2025}' WHERE device = '{DISPOSITIVO_CRUX}'""").fetchall()}

campos_aurora = list(AURORA_CAMPOS.values()) + [AURORA_VERSION_VUE]
fuentes_aurora = ", ".join(f"'{p}'" for p in AURORA_2025)
aurora = {}
for fila in con.execute(f"""
    SELECT RTRIM(page, '/') AS origin, strftime(date, '%Y-%m-%d') AS mes, {", ".join(campos_aurora)}
    FROM read_parquet([{fuentes_aurora}]) WHERE client = '{CLIENTE}'""").fetchall():
    aurora[(fila[0], fila[1])] = dict(zip(campos_aurora, fila[2:]))


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


# Sitio-mes observados: el estado de cada fuente.
sitios, solo_aurora, sin_aurora = {}, {}, []
for origin, mes, frontend in filas:
    estado = tuple((t, int(v) if v is not None else None, WAPPALYZER) for t, v in (frontend or []))
    if (origin, mes) not in aurora:
        sin_aurora.append((origin, mes))
        continue
    sitios.setdefault(origin, {})[mes] = {"wappalyzer": estado,
                                          "wappalyzer+aurora": combinar(estado, aurora[(origin, mes)])}
if sin_aurora:
    raise SystemExit(f"{len(sin_aurora)} sitio-mes observados sin fila de aurora, ej. {sin_aurora[:3]}")
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


def cambios_del_sitio(por_mes, fuente):
    observados = [m for m in MESES if m in por_mes]
    cambios = []
    for previo, actual in zip(observados, observados[1:]):
        entran, salen, version = cambio(por_mes[previo][fuente], por_mes[actual][fuente])
        if entran or salen or version:
            cambios.append({"mes": MESES.index(actual), "entran": entran, "salen": salen, "version": version})
    return cambios


cambios_por_sitio = {o: {f: cambios_del_sitio(por_mes, f) for f in SALIDA} for o, por_mes in sitios.items()}
listados = [o for o in sitios if any(cambios_por_sitio[o].values())]


def version_react(origin, mes):
    return {t: v for t, v, _ in sitios[origin][mes]["wappalyzer+aurora"]}["React"]


def efecto_de_aurora():
    """Qué cambia en el panel al sumar aurora: eventos "sale React" y cambios de versión mayor de React."""
    sale = {f: {(o, c["mes"]) for o in listados for c in cambios_por_sitio[o][f] if "React" in c["salen"]}
            for f in SALIDA}
    transiciones, idas_y_vueltas = {}, 0
    for o in listados:
        observados = [m for m in MESES if m in sitios[o]]
        pares = []
        for c in cambios_por_sitio[o]["wappalyzer+aurora"]:
            if "React" in c["version"]:
                actual = MESES[c["mes"]]
                previo = observados[observados.index(actual) - 1]
                pares.append((version_react(o, previo), version_react(o, actual)))
        for antes, despues in pares:
            transiciones[f"{antes}→{despues}"] = transiciones.get(f"{antes}→{despues}", 0) + 1
        idas_y_vueltas += sum(1 for a, b in zip(pares, pares[1:]) if a == b[::-1])
    return {
        "sale_react": {"wappalyzer": len(sale["wappalyzer"]), "aurora": len(sale["wappalyzer+aurora"]),
                       "corregidas": len(sale["wappalyzer"] - sale["wappalyzer+aurora"]),
                       "solo_aurora": len(sale["wappalyzer+aurora"] - sale["wappalyzer"])},
        "version_react": {"wappalyzer": sum("React" in c["version"] for o in listados
                                            for c in cambios_por_sitio[o]["wappalyzer"]),
                          "aurora": sum(transiciones.values()), "idas_y_vueltas": idas_y_vueltas,
                          "transiciones": dict(sorted(transiciones.items(), key=lambda kv: -kv[1]))},
        "sitios_solo_cambian_con_wappalyzer": sum(1 for o in listados if not cambios_por_sitio[o]["wappalyzer+aurora"]),
    }


def comparar_frameworks():
    """Por framework, sitio-mes con presencia y con versión según cada fuente, sobre toda la cohorte."""
    marcos = list(AURORA_CAMPOS) + ["Vue.js"]
    comparacion = {"sitio_mes_observados": sum(len(p) for p in sitios.values()),
                   "visitas_sin_wappalyzer_con_aurora": sum(len(v) for v in solo_aurora.values()),
                   "frameworks": {t: {"wappalyzer": 0, "wappalyzer_con_version": 0, "combinado": 0,
                                      "combinado_con_version": 0, "solo_aurora": 0} for t in marcos}}
    for por_mes in sitios.values():
        for registro in por_mes.values():
            w = {t: v for t, v, _ in registro["wappalyzer"]}
            c = {t: (v, f) for t, v, f in registro["wappalyzer+aurora"]}
            for t in marcos:
                r = comparacion["frameworks"][t]
                r["wappalyzer"] += t in w
                r["wappalyzer_con_version"] += w.get(t) is not None
                r["combinado"] += t in c
                r["combinado_con_version"] += t in c and c[t][0] is not None
                r["solo_aurora"] += t in c and c[t][1] == PRESENCIA_AURORA
    return comparacion


for fuente, salida in SALIDA.items():
    con_aurora = fuente == "wappalyzer+aurora"
    estados, indice_estado, salida_sitios = [], {}, []
    resumen = {"sitios_cohorte": len(sitios), "sitios_listados": len(listados), "sitios_con_cambio": 0,
               "sitios_con_cambio_de_tecnologia": 0, "sitios_solo_cambio_de_version": 0, "cambios": 0,
               "cambios_de_tecnologia": 0, "cambios_solo_de_version": 0, "cambios_sale_react": 0}
    for origin in listados:
        por_mes, cambios = sitios[origin], cambios_por_sitio[origin][fuente]
        if cambios:
            de_tecnologia = sum(1 for c in cambios if c["entran"] or c["salen"])
            resumen["sitios_con_cambio"] += 1
            resumen["cambios"] += len(cambios)
            resumen["cambios_de_tecnologia"] += de_tecnologia
            resumen["cambios_solo_de_version"] += len(cambios) - de_tecnologia
            resumen["cambios_sale_react"] += sum("React" in c["salen"] for c in cambios)
            resumen["sitios_con_cambio_de_tecnologia" if de_tecnologia else "sitios_solo_cambio_de_version"] += 1
        meses = []
        for m in MESES:
            ie = None
            if m in por_mes:
                estado = por_mes[m][fuente]
                if estado not in indice_estado:
                    indice_estado[estado] = len(estados)
                    estados.append([[t, v, f] for t, v, f in estado])
                ie = indice_estado[estado]
            meses.append([ie, *metricas.get((origin, m), (None, None, None))])
        sin_visita = [i for i, m in enumerate(MESES) if m not in por_mes and (origin, m) not in aurora]
        sitio = {"origin": origin, "rank_enero": rank_enero.get(origin), "meses": meses, "cambios": cambios,
                 "sin_visita": sin_visita}
        if con_aurora and origin in solo_aurora:
            sitio["solo_aurora"] = solo_aurora[origin]
        salida_sitios.append(sitio)
    sin_tecnologias = [m for s in salida_sitios for m in s["meses"] if m[0] is None]
    resumen["sitio_mes_sin_tecnologias_en_sitios_listados"] = len(sin_tecnologias)
    resumen["sitio_mes_sin_tecnologias_con_metricas"] = sum(m[1] is not None for m in sin_tecnologias)
    comparacion = comparar_frameworks() if con_aurora else None
    efecto = efecto_de_aurora() if con_aurora else None
    salida.write_text(json.dumps({
        "cliente": CLIENTE,
        "fuente": fuente,
        "meses": [m[:7] for m in MESES],
        "familias": FAMILIAS,
        "tecnologias": TECNOLOGIAS_FRONTEND,
        "resumen": resumen,
        "comparacion": comparacion,
        "efecto": efecto,
        "estados": estados,
        "sitios": salida_sitios,
    }, ensure_ascii=False, separators=(",", ":")))
    print(fuente, json.dumps({"resumen": resumen, "comparacion": comparacion, "efecto": efecto},
                             ensure_ascii=False, indent=1))
