"""Grafo bipartito sitio <-> tecnología (frameworks y librerías de cliente), top 10k, dic-2025.

Entradas:
  bigquery/cross_source/003-panel-piloto-sitio-tecnologia-top10k-2025.parquet
  bigquery/httparchive_wappalyzer_technologies/001-categorias-e-implies-por-tecnologia.parquet
  analisis/salidas/eventos_persistentes.parquet (de panel_piloto_scd2.py)
Salida:
  analisis/salidas/grafo_bipartito.json (datos de las figuras del deck)

Descriptivo: ninguna diferencia de LCP de este script es una estimación causal.

Uso: analisis/.venv/bin/python analisis/grafo_bipartito.py
"""

import json
from pathlib import Path

import duckdb
import networkx as nx
from networkx.algorithms import bipartite

RAIZ = Path(__file__).resolve().parent.parent
PANEL = RAIZ / "bigquery/cross_source/003-panel-piloto-sitio-tecnologia-top10k-2025.parquet"
CATEGORIAS = RAIZ / "bigquery/httparchive_wappalyzer_technologies/001-categorias-e-implies-por-tecnologia.parquet"
EVENTOS = RAIZ / "analisis/salidas/eventos_persistentes.parquet"
SALIDA = RAIZ / "analisis/salidas/grafo_bipartito.json"

MES = "2025-12-01"
CATEGORIAS_LIBRERIA = ("JavaScript libraries", "UI frameworks")
CATEGORIA_FRAMEWORK = "JavaScript frameworks"
FRAMEWORKS_CON_VERSION = ("jQuery", "React", "Vue.js", "Angular", "Next.js")
MIN_SITIOS_NODO = 30
MIN_COOCURRENCIA = 20
MIN_LIFT = 2.0
SEMILLA = 7

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANEL}'")
con.execute(f"CREATE VIEW cat AS SELECT * FROM '{CATEGORIAS}'")

# Aristas del bipartito del mes: sitio <-> framework o librería de cliente.
# Los frameworks con versión detectable entran como "Framework@mayor"; sin versión, "Framework@?".
aristas = con.execute(f"""
SELECT
  l.origin,
  l.technology,
  CASE
    WHEN l.technology IN {FRAMEWORKS_CON_VERSION}
      THEN l.technology || '@' || COALESCE(l.version_mayor::VARCHAR, '?')
    ELSE l.technology
  END AS nodo,
  CASE WHEN c.categorias LIKE '%{CATEGORIA_FRAMEWORK}%' THEN 'framework' ELSE 'libreria' END AS tipo,
  l.p75_lcp
FROM largo AS l
JOIN cat AS c USING (technology)
WHERE l.date = DATE '{MES}'
  AND (c.categorias LIKE '%{CATEGORIA_FRAMEWORK}%'
       OR c.categorias LIKE '%{CATEGORIAS_LIBRERIA[0]}%'
       OR c.categorias LIKE '%{CATEGORIAS_LIBRERIA[1]}%')
ORDER BY l.origin, nodo
""").df()

sitios_mes = con.execute(
    f"SELECT COUNT(DISTINCT origin) FROM largo WHERE date = DATE '{MES}'"
).fetchone()[0]
lcp_sitio = con.execute(
    f"SELECT origin, ANY_VALUE(p75_lcp) AS lcp FROM largo WHERE date = DATE '{MES}' GROUP BY origin"
).df().set_index("origin")["lcp"]

# Nodos con soporte mínimo, para que la proyección no quede dominada por ruido.
soporte = aristas.groupby("nodo")["origin"].nunique()
nodos_validos = soporte[soporte >= MIN_SITIOS_NODO].index
aristas_todas = aristas
aristas = aristas[aristas["nodo"].isin(nodos_validos)]
tipo_nodo = aristas.drop_duplicates("nodo").set_index("nodo")["tipo"].to_dict()

B = nx.Graph()
sitios = aristas["origin"].unique()
B.add_nodes_from(sitios, bipartite=0)
B.add_nodes_from(nodos_validos, bipartite=1)
B.add_edges_from(aristas[["origin", "nodo"]].itertuples(index=False, name=None))

# Proyección sobre tecnologías: peso = coocurrencia; se conservan pares con lift alto.
proy = bipartite.weighted_projected_graph(B, list(nodos_validos))
n_total = len(sitios)
# Nodos y aristas se agregan en orden fijo: Louvain y el layout dependen del orden de
# inserción, y el de los sets de Python cambia entre corridas.
pares_lift = []
for u, v, d in proy.edges(data=True):
    u, v = sorted((u, v))
    co = d["weight"]
    lift = co * n_total / (soporte[u] * soporte[v])
    if co >= MIN_COOCURRENCIA and lift >= MIN_LIFT:
        pares_lift.append((u, v, {"coocurrencia": co, "lift": round(lift, 2)}))
red = nx.Graph()
red.add_nodes_from(sorted({n for u, v, _ in pares_lift for n in (u, v)}))
red.add_edges_from(sorted(pares_lift, key=lambda e: (e[0], e[1])))

comunidades = nx.community.louvain_communities(red, weight="lift", seed=SEMILLA)
comunidad_de = {n: i for i, c in enumerate(comunidades) for n in c}

# Cada sitio se asigna al stack (comunidad) donde tiene más tecnologías.
sitio_comunidad = (
    aristas.assign(comunidad=aristas["nodo"].map(comunidad_de))
    .dropna(subset=["comunidad"])
    .groupby(["origin", "comunidad"]).size()
    .reset_index(name="n")
    .sort_values(["origin", "n"], ascending=[True, False])
    .drop_duplicates("origin")
    .set_index("origin")["comunidad"]
)

stacks = []
for i, miembros in enumerate(comunidades):
    sitios_stack = sitio_comunidad[sitio_comunidad == i].index
    lcp = lcp_sitio.reindex(sitios_stack).dropna()
    stacks.append({
        "id": i,
        "tecnologias": sorted(miembros, key=lambda n: -soporte[n]),
        "sitios_asignados": int(len(sitios_stack)),
        "lcp_mediana_ms": int(lcp.median()) if len(lcp) else None,
    })
stacks.sort(key=lambda s: -s["sitios_asignados"])

# Grupos de sitios por framework principal (lado izquierdo de la figura de dos columnas).
presentes = aristas_todas.groupby("origin")["technology"].agg(set)


def grupo(techs):
    if "Next.js" in techs:
        return "Next.js"
    if "Nuxt.js" in techs:
        return "Nuxt.js"
    if "React" in techs:
        return "React (sin Next.js)"
    if "Vue.js" in techs:
        return "Vue.js (sin Nuxt)"
    if "Angular" in techs:
        return "Angular"
    if "jQuery" in techs:
        return "Solo jQuery"
    return "Otros"


grupo_sitio = presentes.map(grupo)
librerias = aristas[aristas["tipo"] == "libreria"]
total_por_lib = librerias.groupby("nodo")["origin"].nunique()

grupos = []
for g, sitios_g in grupo_sitio.groupby(grupo_sitio):
    origenes = sitios_g.index
    lcp = lcp_sitio.reindex(origenes).dropna()
    libs_g = librerias[librerias["origin"].isin(origenes)].groupby("nodo")["origin"].nunique()
    top = (
        libs_g[libs_g >= 10]
        .to_frame("sitios")
        .assign(lift=lambda df: df["sitios"] * n_total / (len(origenes) * total_por_lib[df.index]))
        .sort_values("sitios", ascending=False)
        .head(8)
    )
    grupos.append({
        "grupo": g,
        "sitios": int(len(origenes)),
        "lcp_mediana_ms": int(lcp.median()),
        "librerias_top": [
            {"libreria": n, "sitios": int(r.sitios), "lift": round(float(r.lift), 2)}
            for n, r in top.iterrows()
        ],
    })
grupos.sort(key=lambda g: -g["sitios"])

# Matriz completa grupo x librería para la figura de dos columnas: las librerías más
# frecuentes, sin las versiones de jQuery (definen el propio grupo "Solo jQuery").
LIBRERIAS_FIGURA = 12
libs_figura = (
    total_por_lib[~total_por_lib.index.str.startswith("jQuery@")]
    .sort_values(ascending=False).head(LIBRERIAS_FIGURA).index
)
matriz = (
    librerias[librerias["nodo"].isin(libs_figura)]
    .assign(grupo=lambda df: df["origin"].map(grupo_sitio))
    .groupby(["grupo", "nodo"])["origin"].nunique()
)
sitios_por_grupo = grupo_sitio.value_counts()
matriz_grupo_libreria = [
    {
        "grupo": g,
        "libreria": lib,
        "sitios": int(n),
        "lift": round(float(n * n_total / (sitios_por_grupo[g] * total_por_lib[lib])), 2),
    }
    for (g, lib), n in matriz.items()
]

# Coordenadas de la red proyectada (para dibujarla como SVG en el deck), solo sobre el
# componente conexo principal: un componente aislado estira el layout y aplasta al resto.
principal = red.subgraph(max(nx.connected_components(red), key=len))
posiciones = nx.kamada_kawai_layout(principal, weight=None)

# Cobertura de versión por framework en el mes.
version = con.execute(f"""
SELECT technology,
       COUNT(DISTINCT origin) AS sitios,
       ROUND(100 * AVG((version_mayor IS NOT NULL)::INT), 1) AS pct_con_version
FROM largo
WHERE date = DATE '{MES}' AND technology IN {FRAMEWORKS_CON_VERSION}
GROUP BY technology ORDER BY sitios DESC
""").fetchall()

versiones = con.execute(f"""
SELECT technology || '@' || version_mayor::VARCHAR AS nodo, COUNT(DISTINCT origin) AS sitios,
       MEDIAN(p75_lcp)::INT AS lcp_mediana_ms
FROM largo
WHERE date = DATE '{MES}' AND technology IN {FRAMEWORKS_CON_VERSION} AND version_mayor IS NOT NULL
GROUP BY ALL HAVING COUNT(DISTINCT origin) >= {MIN_SITIOS_NODO}
ORDER BY nodo, sitios DESC
""").fetchall()

# Recableado de aristas en las migraciones persistentes: se van / se quedan / llegan.
# "antes" = librerías presentes los 3 meses previos al cambio; "después" = los 3 meses desde el cambio.
# Las que llegan se separan en: framework nuevo (React, sus meta-frameworks y lo que estos
# implican), ecosistema React (librerías que según Wappalyzer requieren React, o con lift >= 2
# entre los sitios que ya usaban React en dic-2025) y propias del sitio.
lift_react = {}
sitios_react = set(aristas.loc[aristas["technology"] == "React", "origin"])
for lib, total in total_por_lib.items():
    co = librerias[(librerias["nodo"] == lib) & librerias["origin"].isin(sitios_react)]["origin"].nunique()
    lift_react[lib] = co * n_total / (len(sitios_react) * total) if sitios_react else 0

meta_frameworks_react = set(con.execute("""
SELECT technology FROM cat
WHERE list_contains(string_split(implies, '; '), 'React')
  AND (categorias LIKE '%Web frameworks%' OR categorias LIKE '%Static site generator%')
""").df()["technology"])
framework_react = {"React"} | meta_frameworks_react | set(con.execute(f"""
SELECT technology FROM cat
WHERE list_has_any(string_split(implies, '; '), {sorted(meta_frameworks_react)})
""").df()["technology"])
ecosistema_react = set(con.execute("""
SELECT technology FROM cat WHERE list_contains(string_split(implies, '; '), 'React')
""").df()["technology"]) - framework_react

recableado = con.execute(f"""
WITH ev AS (
  SELECT origin, mes_evento FROM '{EVENTOS}'
  WHERE par IN ('jQuery→React', 'jQuery→React (conservando jQuery)')
),
lib AS (
  SELECT l.origin, datediff('month', DATE '2025-01-01', l.date) AS mes, l.technology
  FROM largo AS l JOIN cat AS c USING (technology)
  WHERE c.categorias LIKE '%{CATEGORIAS_LIBRERIA[0]}%'
     OR c.categorias LIKE '%{CATEGORIAS_LIBRERIA[1]}%'
     OR c.categorias LIKE '%{CATEGORIA_FRAMEWORK}%'
),
antes AS (
  SELECT ev.origin, lib.technology FROM ev JOIN lib
    ON lib.origin = ev.origin AND lib.mes BETWEEN ev.mes_evento - 3 AND ev.mes_evento - 1
  GROUP BY ALL HAVING COUNT(DISTINCT lib.mes) = 3
),
despues AS (
  SELECT ev.origin, lib.technology FROM ev JOIN lib
    ON lib.origin = ev.origin AND lib.mes BETWEEN ev.mes_evento AND ev.mes_evento + 2
  GROUP BY ALL HAVING COUNT(DISTINCT lib.mes) = 3
)
SELECT COALESCE(a.origin, d.origin) AS origin,
       COALESCE(a.technology, d.technology) AS technology,
       CASE WHEN a.origin IS NULL THEN 'llega'
            WHEN d.origin IS NULL THEN 'se_va'
            ELSE 'se_queda' END AS estado
FROM antes AS a FULL OUTER JOIN despues AS d
  ON a.origin = d.origin AND a.technology = d.technology
""").df()


def clase_llegada(tech):
    if tech in framework_react:
        return "llega_framework"
    if tech in ecosistema_react or lift_react.get(tech, 0) >= MIN_LIFT:
        return "llega_ecosistema_react"
    return "llega_propia"


recableado["clase"] = recableado.apply(
    lambda r: clase_llegada(r["technology"]) if r["estado"] == "llega" else r["estado"], axis=1
)
resumen_recableado = {
    "sitios": int(recableado["origin"].nunique()),
    "aristas_por_clase": recableado["clase"].value_counts().to_dict(),
    "ejemplos_por_clase": {
        c: (recableado.loc[recableado["clase"] == c, "technology"].value_counts()
            .sort_index().sort_values(ascending=False, kind="stable").head(6).to_dict())
        for c in sorted(recableado["clase"].unique())
    },
}

resultado = {
    "mes": MES,
    "sitios_mes": int(sitios_mes),
    "bipartito": {
        "sitios_con_framework_o_libreria": int(len(sitios)),
        "nodos_tecnologia": int(len(nodos_validos)),
        "nodos_framework": int(sum(1 for n in nodos_validos if tipo_nodo[n] == "framework")),
        "aristas": int(B.number_of_edges()),
        "grado_medio_sitio": round(B.number_of_edges() / len(sitios), 2),
    },
    "proyeccion": {
        "nodos": red.number_of_nodes(),
        "aristas_lift_alto": red.number_of_edges(),
        "comunidades": len(comunidades),
        "modularidad": round(nx.community.modularity(red, comunidades, weight="lift"), 3),
        "aristas": [
            {"u": u, "v": v, **d} for u, v, d in sorted(
                red.edges(data=True), key=lambda e: -e[2]["coocurrencia"]
            )
        ],
    },
    "nodos": {n: {"sitios": int(soporte[n]), "tipo": tipo_nodo[n],
                  "comunidad": comunidad_de.get(n),
                  "xy": [round(float(c), 4) for c in posiciones[n]] if n in posiciones else None}
              for n in nodos_validos},
    "libreria_total_sitios": {lib: int(total_por_lib[lib]) for lib in libs_figura},
    "matriz_grupo_libreria": matriz_grupo_libreria,
    "stacks": stacks,
    "grupos_framework": grupos,
    "cobertura_version": [
        {"framework": t, "sitios": s, "pct_con_version": p} for t, s, p in version
    ],
    "versiones": [
        {"nodo": n, "sitios": s, "lcp_mediana_ms": l} for n, s, l in versiones
    ],
    "recableado_jquery_react": resumen_recableado,
}

SALIDA.write_text(json.dumps(resultado, ensure_ascii=False, indent=2))
resumen = {k: v for k, v in resultado.items() if k not in ("nodos",)}
resumen["proyeccion"] = {k: v for k, v in resultado["proyeccion"].items() if k != "aristas"}
print(json.dumps(resumen, ensure_ascii=False, indent=2))
