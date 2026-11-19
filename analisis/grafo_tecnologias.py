"""Tecnologías asociadas a cada framework principal, cohorte fija top 10k, diciembre 2025.

Framework principal del sitio = framework_principal() de frontend.py, con Wappalyzer + presencia de
aurora (React, Next.js, Nuxt.js, Angular, Svelte). Nodos: todas las tecnologías de Wappalyzer con
MIN_SITIOS sitios o más, salvo las que definen un framework principal.

Asociación tecnología–framework: lift = P(tecnología | framework) / P(tecnología). Se conserva con
lift >= MIN_LIFT y MIN_COOCURRENCIA sitios. Se descarta cuando Wappalyzer infiere (regla implies,
directa o encadenada) la tecnología a partir del framework o el framework a partir de la tecnología
(ej. Next.js -> Node.js y Webpack): esa coocurrencia es mecánica.

LCP: p75 de CrUX del mes. Por nodo, mediana de los sitios con la tecnología menos la de todos los
sitios del mes. Por asociación, mediana de los sitios del framework con la tecnología menos la de
los sitios del framework sin ella. Descriptivo, sin control.

Salida: analisis/salidas/grafo_tecnologias_<cliente>.json

Uso: analisis/.venv/bin/python analisis/grafo_tecnologias.py [mobile|desktop]
"""

import json
import math
from statistics import median

import duckdb
import networkx as nx

from frontend import AURORA_CAMPOS, GRUPOS_PRINCIPAL, SIN_FRAMEWORK, framework_principal
from fuentes import AURORA_2025, CATEGORIAS, PANELES, SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
MES = "2025-12-01"
MIN_SITIOS = 30
MIN_COOCURRENCIA = 15
MIN_LIFT = 2.0
SEMILLA = 7

# Tipo de tecnología según la primera categoría de Wappalyzer que aparece en este orden.
TIPOS = {
    "Librerías JS y UI": ["JavaScript libraries", "UI frameworks", "JavaScript frameworks", "JavaScript graphics",
                          "Font scripts", "Video players", "Maps", "Widgets", "Comment systems", "Form builders"],
    "Publicidad y marketing": ["Advertising", "Retargeting", "Affiliate programs", "Marketing automation",
                               "Personalisation", "A/B Testing", "Segmentation", "Customer data platform",
                               "CRM", "Email", "Surveys", "Live chat"],
    "Analytics y tags": ["Analytics", "RUM", "Tag managers", "Browser fingerprinting"],
    "CMS y ecommerce": ["CMS", "Ecommerce", "WordPress plugins", "WordPress themes", "Page builders", "Blogs",
                        "Payment processors", "Static site generator", "Web frameworks", "Documentation",
                        "Digital asset management", "Search engines"],
    "Infraestructura": ["CDN", "Caching", "Performance", "Reverse proxies", "Load balancers", "Web servers",
                        "PaaS", "IaaS", "Hosting", "Hosting panels", "Security", "Cookie compliance",
                        "Authentication", "Programming languages", "Databases", "Operating systems",
                        "Development", "Issue trackers", "Webmail", "SEO"],
}
OTRO_TIPO = "Otros"

con = duckdb.connect()
con.execute(f"CREATE VIEW largo AS SELECT * FROM '{PANELES[CLIENTE]}'")
fuentes = ", ".join(f"'{p}'" for p in AURORA_2025)

sitios = {}
for origin, tecnologia, lcp in con.execute(f"""
SELECT RTRIM(origin, '/'), technology, p75_lcp FROM largo WHERE date = DATE '{MES}'
""").fetchall():
    s = sitios.setdefault(origin, {"techs": set(), "lcp": None})
    s["techs"].add(tecnologia)
    s["lcp"] = s["lcp"] if s["lcp"] is not None else lcp

campos = list(AURORA_CAMPOS.values())
for fila in con.execute(f"""
SELECT RTRIM(page, '/'), {", ".join(campos)} FROM read_parquet([{fuentes}])
WHERE client = '{CLIENTE}' AND date = DATE '{MES}'
""").fetchall():
    if fila[0] in sitios:
        sitios[fila[0]]["techs"] |= {t for t, v in zip(AURORA_CAMPOS, fila[1:]) if v}

categorias, implica = {}, {}
for t, c, i in con.execute(f"SELECT technology, categorias, implies FROM '{CATEGORIAS}'").fetchall():
    categorias[t] = [x.strip() for x in (c or "").split(";") if x.strip()]
    implica[t] = set(i.split("; ")) if i else set()


def cierre(tecnologias):
    """Tecnologías que Wappalyzer infiere, directa o indirectamente, a partir de las dadas."""
    vistas, pendientes = set(), list(tecnologias)
    while pendientes:
        for i in implica.get(pendientes.pop(), set()) - vistas:
            vistas.add(i)
            pendientes.append(i)
    return vistas


inferidas_por = {g: cierre(m) for g, m in GRUPOS_PRINCIPAL.items()}


def tipo(tecnologia):
    for nombre, cats in TIPOS.items():
        if any(c in cats for c in categorias.get(tecnologia, [])):
            return nombre
    return OTRO_TIPO


definen = set().union(*GRUPOS_PRINCIPAL.values())
grupo_de = {o: framework_principal(s["techs"]) for o, s in sitios.items()}
grupos = list(GRUPOS_PRINCIPAL) + [SIN_FRAMEWORK]
por_grupo = {g: {o for o, x in grupo_de.items() if x == g} for g in grupos}
por_tecnologia = {}
for o, s in sitios.items():
    for t in s["techs"] - definen:
        por_tecnologia.setdefault(t, set()).add(o)
por_tecnologia = {t: o for t, o in por_tecnologia.items() if len(o) >= MIN_SITIOS}

N = len(sitios)
lcp = {o: s["lcp"] for o, s in sitios.items() if s["lcp"] is not None}
def mediana(origenes):
    valores = [lcp[o] for o in origenes if o in lcp]
    return round(median(valores)) if valores else None



lcp_todos = mediana(sitios)

aristas, implies_descartados = [], 0
for t, con_t in por_tecnologia.items():
    for g in grupos:
        co = con_t & por_grupo[g]
        if len(co) < MIN_COOCURRENCIA:
            continue
        lift = len(co) * N / (len(con_t) * len(por_grupo[g]))
        if lift < MIN_LIFT:
            continue
        if cierre({t}) & GRUPOS_PRINCIPAL.get(g, set()) or t in inferidas_por.get(g, set()):
            implies_descartados += 1
            continue
        con_lcp, sin_lcp = mediana(co), mediana(por_grupo[g] - con_t)
        aristas.append({
            "tecnologia": t, "framework": g, "sitios": len(co), "lift": round(lift, 2),
            "pct_del_framework": round(100 * len(co) / len(por_grupo[g]), 1),
            "lcp_con_ms": con_lcp, "lcp_sin_ms": sin_lcp,
            "delta_lcp_ms": round(con_lcp - sin_lcp) if con_lcp is not None and sin_lcp is not None else None,
        })
aristas.sort(key=lambda a: (-a["lift"], a["tecnologia"]))

# ΔLCP de cada tecnología del grafo: bruto (todos los sitios con vs. sin) y dentro del framework
# (con vs. sin en cada framework con MIN_ESTRATO sitios de cada lado, promediado con peso = sitios con).
MIN_ESTRATO = 10
estratificado = []
for t in sorted({a["tecnologia"] for a in aristas}):
    con_t = por_tecnologia[t]
    por_framework = []
    for g in grupos:
        con_g, sin_g = con_t & por_grupo[g], por_grupo[g] - con_t
        if len([o for o in con_g if o in lcp]) >= MIN_ESTRATO and len([o for o in sin_g if o in lcp]) >= MIN_ESTRATO:
            por_framework.append({"framework": g, "sitios": len(con_g), "delta_lcp_ms": mediana(con_g) - mediana(sin_g)})
    if not por_framework:
        continue
    peso = sum(f["sitios"] for f in por_framework)
    estratificado.append({
        "tecnologia": t,
        "sitios": len(con_t),
        "delta_bruto_ms": mediana(con_t) - mediana(set(sitios) - con_t),
        "delta_dentro_ms": round(sum(f["delta_lcp_ms"] * f["sitios"] for f in por_framework) / peso),
        "pct_sitios_en_estratos": round(100 * peso / len(con_t)),
        "por_framework": por_framework,
    })

# Layout: frameworks fijos en un anillo. Una tecnología asociada a un solo framework va en anillos
# alrededor de él, del lado de afuera y ordenada por lift; las asociadas a varios quedan entre ellos.
en_red = sorted({a["tecnologia"] for a in aristas})
frameworks_de = {}
for a in aristas:
    frameworks_de.setdefault(a["tecnologia"], []).append(a)
# Cada framework ocupa en el anillo un arco proporcional a sus tecnologías propias.
propias_n = {g: 12 + sum(1 for l in frameworks_de.values() if len(l) == 1 and l[0]["framework"] == g) for g in grupos}
angulo, acumulado = {}, 0
for g in grupos:
    angulo[g] = -math.pi / 2 + 2 * math.pi * (acumulado + propias_n[g] / 2) / sum(propias_n.values())
    acumulado += propias_n[g]
anclas = {g: (math.cos(a), math.sin(a)) for g, a in angulo.items()}
posiciones = {}
ABANICO, SEPARACION, RADIO_0, PASO = math.radians(220), 0.085, 0.19, 0.085
for g in grupos:
    propias = sorted((t for t, l in frameworks_de.items() if len(l) == 1 and l[0]["framework"] == g),
                     key=lambda t: (-frameworks_de[t][0]["lift"], t))
    anillo, i = 0, 0
    while i < len(propias):
        r = RADIO_0 + anillo * PASO
        capacidad = max(1, int(ABANICO * r / SEPARACION))
        tanda = propias[i:i + capacidad]
        for j, t in enumerate(tanda):
            a = angulo[g] + (ABANICO * ((j + .5) / len(tanda) - .5) if len(tanda) > 1 else 0)
            posiciones[t] = (anclas[g][0] + r * math.cos(a), anclas[g][1] + r * math.sin(a))
        i += capacidad
        anillo += 1
compartidas = [t for t, l in frameworks_de.items() if len(l) > 1]
G = nx.Graph()
G.add_nodes_from(list(anclas) + list(posiciones) + compartidas)
G.add_weighted_edges_from((a["tecnologia"], a["framework"], math.log(a["lift"]))
                          for t in compartidas for a in frameworks_de[t])
inicial = {**anclas, **posiciones}
for t in compartidas:
    peso = sum(math.log(a["lift"]) for a in frameworks_de[t])
    inicial[t] = tuple(sum(anclas[a["framework"]][k] * math.log(a["lift"]) for a in frameworks_de[t]) / peso * .8
                       for k in (0, 1))
posiciones = nx.spring_layout(G, pos=inicial, fixed=list(anclas) + list(posiciones), weight="weight",
                              k=0.08, iterations=60, seed=SEMILLA)

salida = {
    "cliente": CLIENTE,
    "mes": MES,
    "sitios": N,
    "lcp_mediana_ms": lcp_todos,
    "parametros": {"min_sitios": MIN_SITIOS, "min_coocurrencia": MIN_COOCURRENCIA, "min_lift": MIN_LIFT},
    "tipos": list(TIPOS) + [OTRO_TIPO],
    "frameworks": [{"id": g, "sitios": len(por_grupo[g]), "lcp_mediana_ms": mediana(por_grupo[g]),
                    "xy": [round(c, 4) for c in anclas[g]]} for g in grupos],
    "tecnologias_con_min_sitios": len(por_tecnologia),
    "tecnologias_sin_asociacion": len(por_tecnologia) - len(en_red),
    "asociaciones_descartadas_por_implies": implies_descartados,
    "tecnologias": [{
        "id": t, "tipo": tipo(t), "sitios": len(por_tecnologia[t]),
        "lcp_mediana_ms": mediana(por_tecnologia[t]),
        "delta_lcp_ms": round(mediana(por_tecnologia[t]) - lcp_todos) if mediana(por_tecnologia[t]) is not None else None,
        "xy": [round(float(c), 4) for c in posiciones[t]],
    } for t in en_red],
    "aristas": aristas,
    "min_estrato": MIN_ESTRATO,
    "estratificado": estratificado,
}
(SALIDAS / f"grafo_tecnologias_{CLIENTE}.json").write_text(json.dumps(salida, ensure_ascii=False, indent=1))
print(f"{CLIENTE}: {N} sitios, {len(por_tecnologia)} tecnologías con >= {MIN_SITIOS} sitios, "
      f"{len(en_red)} con alguna asociación, {len(aristas)} asociaciones ({implies_descartados} implies descartadas)")
for f in salida["frameworks"]:
    n = sum(1 for a in aristas if a["framework"] == f["id"])
    print(f"  {f['id']:18s} {f['sitios']:5d} sitios  LCP {f['lcp_mediana_ms']}  {n} tecnologías asociadas")
