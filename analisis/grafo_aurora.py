"""Proyección sitio ↔ tecnología de diciembre 2025, con la versión que mide aurora.

Misma red que grafo_bipartito.py (lift ≥ 2), pero el nodo de React, Next.js, Vue.js,
Angular, Nuxt.js y Svelte usa la versión mayor de aurora. React entra también cuando solo
aurora lo ve. jQuery sigue con la versión de Wappalyzer.

Un par que Wappalyzer marca como implies se descarta cuando alguno de los dos nodos no
tiene versión (Next.js implica React: esa coocurrencia es mecánica). Si los dos tienen
versión mayor, el par se conserva: Next.js 14 con React 18 no es el mismo hecho que
Next.js 15 con React 19.

Salida: analisis/salidas/grafo_aurora_<cliente>.json

Uso: analisis/.venv/bin/python analisis/grafo_aurora.py [mobile|desktop]
"""

import json
import re

import duckdb
import networkx as nx
from networkx.algorithms import bipartite

from frontend import AURORA_CAMPOS, AURORA_VERSION_VUE, REACT_DOM_MAYORES
from fuentes import AURORA_2025, CATEGORIAS, PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
MES = "2025-12-01"
CATEGORIAS_LIBRERIA = ("JavaScript libraries", "UI frameworks")
CATEGORIA_FRAMEWORK = "JavaScript frameworks"
CON_VERSION = ("jQuery", "React", "Vue.js", "Angular", "Next.js", "Nuxt.js", "Svelte")
MIN_SITIOS_NODO = 30
MIN_COOCURRENCIA = 20
MIN_LIFT = 2.0
SEMILLA = 7

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANELES[CLIENTE]}'")
con.execute(f"CREATE VIEW cat AS SELECT * FROM '{CATEGORIAS}'")
fuentes = ", ".join(f"'{p}'" for p in AURORA_2025)


def mayor(version):
    hallado = re.match(r"^(\d+)", version or "")
    return int(hallado.group(1)) if hallado else None


def nombre(tecnologia, version):
    if tecnologia in CON_VERSION:
        return f"{tecnologia}@{version if version is not None else '?'}"
    return tecnologia


filas = con.execute(f"""
SELECT RTRIM(origin, '/') AS origin, technology, version_mayor, p75_lcp
FROM largo WHERE date = DATE '{MES}'
""").fetchall()
por_sitio = {}
for origin, tecnologia, version, lcp in filas:
    sitio = por_sitio.setdefault(origin, {"techs": {}, "lcp": lcp})
    sitio["techs"][tecnologia] = int(version) if version is not None else None
    if sitio["lcp"] is None:
        sitio["lcp"] = lcp

campos = list(AURORA_CAMPOS.values()) + [AURORA_VERSION_VUE]
aurora = {}
for fila in con.execute(f"""
SELECT RTRIM(page, '/') AS origin, {", ".join(campos)}
FROM read_parquet([{fuentes}])
WHERE client = '{CLIENTE}' AND date = DATE '{MES}'
""").fetchall():
    aurora[fila[0]] = dict(zip(campos, fila[1:]))

categorias = {
    t: c or ""
    for t, c in con.execute("SELECT technology, categorias FROM cat").fetchall()
}
implica = {
    t: set(i.split("; ")) if i else set()
    for t, i in con.execute("SELECT technology, implies FROM cat").fetchall()
}


def es_framework_o_libreria(tecnologia):
    c = categorias.get(tecnologia, "")
    if tecnologia in AURORA_CAMPOS:
        return True
    return (CATEGORIA_FRAMEWORK in c or CATEGORIAS_LIBRERIA[0] in c or CATEGORIAS_LIBRERIA[1] in c)


def aplicar(techs, datos):
    """Versión y presencia de los frameworks que mide aurora. El resto queda como Wappalyzer."""
    if not datos:
        return techs
    for tecnologia, campo in AURORA_CAMPOS.items():
        valor = datos.get(campo)
        if not valor:
            continue
        v = mayor(valor)
        if tecnologia == "React" and v not in REACT_DOM_MAYORES:
            v = None
        if tecnologia not in techs:
            techs[tecnologia] = v
        elif v is not None and techs[tecnologia] != v and (techs[tecnologia] is None or tecnologia == "React"):
            techs[tecnologia] = v
    vue = mayor(datos.get(AURORA_VERSION_VUE))
    if "Vue.js" in techs and techs["Vue.js"] is None and vue is not None:
        techs["Vue.js"] = vue
    return techs


def aristas_de(usar_aurora):
    salidas = []
    for origin, sitio in por_sitio.items():
        techs = dict(sitio["techs"])
        if usar_aurora:
            aplicar(techs, aurora.get(origin))
        for tecnologia, version in techs.items():
            if es_framework_o_libreria(tecnologia):
                salidas.append((origin, nombre(tecnologia, version), tecnologia, sitio["lcp"]))
    return salidas


def proyectar(aristas):
    import pandas as pd
    df = pd.DataFrame(aristas, columns=["origin", "nodo", "technology", "lcp"])
    soporte = df.groupby("nodo")["origin"].nunique()
    validos = soporte[soporte >= MIN_SITIOS_NODO].index
    df = df[df["nodo"].isin(validos)]
    sitios = df["origin"].unique()
    B = nx.Graph()
    B.add_nodes_from(sitios, bipartite=0)
    B.add_nodes_from(validos, bipartite=1)
    B.add_edges_from(df[["origin", "nodo"]].itertuples(index=False, name=None))
    tecnologia_de = df.drop_duplicates("nodo").set_index("nodo")["technology"].to_dict()
    proy = bipartite.weighted_projected_graph(B, list(validos))
    n_total = len(sitios)

    def por_implies(u, v):
        tu, tv = tecnologia_de[u], tecnologia_de[v]
        return tv in implica.get(tu, set()) or tu in implica.get(tv, set())

    def con_version(nodo):
        return "@" in nodo and not nodo.endswith("@?")

    pares, descartados = [], 0
    for u, v, d in proy.edges(data=True):
        u, v = sorted((u, v))
        co = d["weight"]
        lift = co * n_total / (soporte[u] * soporte[v])
        if co >= MIN_COOCURRENCIA and lift >= MIN_LIFT:
            if por_implies(u, v) and not (con_version(u) and con_version(v)):
                descartados += 1
                continue
            pares.append((u, v, {"coocurrencia": int(co), "lift": round(float(lift), 2)}))
    red = nx.Graph()
    red.add_nodes_from(sorted({n for u, v, _ in pares for n in (u, v)}))
    red.add_edges_from(sorted(pares, key=lambda e: (e[0], e[1])))
    comunidades = nx.community.louvain_communities(red, weight="lift", seed=SEMILLA)
    comunidad_de = {n: i for i, c in enumerate(comunidades) for n in c}
    por_semilla = {}
    for semilla in range(50):
        k = len(nx.community.louvain_communities(red, weight="lift", seed=semilla))
        por_semilla[str(k)] = por_semilla.get(str(k), 0) + 1
    sitio_comunidad = (
        df.assign(comunidad=df["nodo"].map(comunidad_de))
        .dropna(subset=["comunidad"])
        .groupby(["origin", "comunidad"]).size()
        .reset_index(name="n")
        .sort_values(["origin", "n"], ascending=[True, False])
        .drop_duplicates("origin")
        .set_index("origin")["comunidad"]
    )
    lcp_sitio = df.groupby("origin")["lcp"].first()
    stacks = []
    for i, miembros in enumerate(comunidades):
        asignados = sitio_comunidad[sitio_comunidad == i].index
        lcp = lcp_sitio.reindex(asignados).dropna()
        stacks.append({
            "id": i,
            "tecnologias": sorted(miembros, key=lambda n: -int(soporte[n])),
            "sitios_asignados": int(len(asignados)),
            "lcp_mediana_ms": int(lcp.median()) if len(lcp) else None,
        })
    stacks.sort(key=lambda s: -s["sitios_asignados"])
    principal = red.subgraph(max(nx.connected_components(red), key=len)).copy()
    posiciones = nx.kamada_kawai_layout(principal, weight=None)
    return {
        "soporte": {n: int(soporte[n]) for n in validos},
        "comunidad": comunidad_de,
        "posiciones": {n: [round(float(c), 4) for c in posiciones[n]] for n in principal},
        "aristas": [{"u": u, "v": v, "lift": d["lift"]} for u, v, d in sorted(pares, key=lambda e: (e[0], e[1]))],
        "stacks": stacks,
        "proyeccion": {
            "nodos": red.number_of_nodes(),
            "aristas_lift_alto": red.number_of_edges(),
            "pares_descartados_por_implies": descartados,
            "comunidades": len(comunidades),
            "comunidades_por_semilla": dict(sorted(por_semilla.items())),
            "modularidad": round(nx.community.modularity(red, comunidades, weight="lift"), 3),
            "nodos_componente": principal.number_of_nodes(),
        },
    }


def conteo_versiones(aristas, prefijos):
    from collections import Counter
    c = Counter(nodo for _, nodo, tecnologia, _ in aristas if tecnologia in prefijos)
    return {n: c[n] for n in sorted(c) if c[n] >= MIN_SITIOS_NODO}


base = aristas_de(False)
corregida = aristas_de(True)
red = proyectar(corregida)
prefijos = ("React", "Next.js", "Vue.js", "Angular", "Nuxt.js", "Svelte")
resultado = {
    "cliente": CLIENTE,
    "mes": MES,
    "versiones_wappalyzer": conteo_versiones(base, prefijos),
    "versiones_aurora": conteo_versiones(corregida, prefijos),
    "proyeccion": red["proyeccion"],
    "stacks": [{**s, "tecnologias": s["tecnologias"][:8]} for s in red["stacks"]],
    "red": {
        "nodos": [
            {"id": n, "sitios": red["soporte"][n], "comunidad": red["comunidad"].get(n), "xy": xy}
            for n, xy in red["posiciones"].items()
        ],
        "aristas": [a for a in red["aristas"] if a["u"] in red["posiciones"] and a["v"] in red["posiciones"]],
    },
}
salida = SALIDAS / f"grafo_aurora_{CLIENTE}.json"
salida.write_text(json.dumps(resultado, ensure_ascii=False))
print(CLIENTE, "React wappalyzer", {k: v for k, v in resultado["versiones_wappalyzer"].items() if k.startswith("React")})
print(CLIENTE, "React aurora", {k: v for k, v in resultado["versiones_aurora"].items() if k.startswith("React")})
print(CLIENTE, "stacks", [(s["sitios_asignados"], s["tecnologias"][:4]) for s in resultado["stacks"][:8]])
print(CLIENTE, "proyeccion", resultado["proyeccion"])
