"""Migraciones entre frameworks frontend en la cohorte fija top 10k de 2025, para el grafo de la bitácora.

Entrada: analisis/salidas/cambios_frontend_<cliente>_aurora.json (Wappalyzer + aurora), que lista los
sitios con algún cambio de tecnología frontend y el estado de cada mes.

Framework principal de un sitio-mes = el primero de GRUPOS presente en su estado. Las tecnologías que
implican un framework cuentan como ese framework (ej. Remix y Gatsby como React); jQuery solo es el
principal si no hay otro framework, y WordPress no es un framework (un sitio WordPress sin framework
queda en "Sin framework").

Migración sostenida = el framework principal cambia de A a B entre dos meses observados consecutivos,
con A en los 3 meses observados anteriores y B en los 3 desde el cambio. Los meses sin tecnologías
registradas se saltean. ΔLCP = mediana del p75 de LCP en los 3 meses desde el cambio menos la de los
3 anteriores (descriptivo, sin grupo de control).

Salida: analisis/salidas/migraciones_frontend_<cliente>.json

Uso: analisis/.venv/bin/python analisis/migraciones_frontend.py [mobile|desktop]
"""

import json
from collections import defaultdict
from statistics import median

from fuentes import SALIDAS, cliente_desde_argv

CLIENTE = cliente_desde_argv()
LADO = 3

GRUPOS = {
    "Next.js": {"Next.js", "Next.js App Router", "Next.js Page Router SSG", "Next.js Page Router SSR"},
    "React": {"React", "Remix", "React Router", "Gatsby", "Hydrogen", "Docusaurus", "RedwoodJS"},
    "Nuxt": {"Nuxt.js"},
    "Vue": {"Vue.js", "Gridsome", "VitePress"},
    "Angular": {"Angular", "AngularJS"},
    "Svelte": {"Svelte", "SvelteKit", "Sapper"},
    "Otros frameworks": {"Astro", "Qwik", "Preact", "lit-html", "lit-element", "Alpine.js", "Htmx", "Ember.js",
                         "Backbone.js", "Stimulus", "Inertia.js", "Quasar", "Meteor", "Stencil", "Aurelia",
                         "Knockout.js", "Polymer", "SolidJS", "SolidStart", "TanStack Start", "Fresh", "Elm",
                         "Eleventy"},
    "jQuery": {"jQuery"},
}
SIN_FRAMEWORK = "Sin framework"

datos = json.loads((SALIDAS / f"cambios_frontend_{CLIENTE}_aurora.json").read_text())
estados = datos["estados"]


def principal(indice):
    tecnologias = {t[0] for t in estados[indice]}
    return next((g for g, miembros in GRUPOS.items() if tecnologias & miembros), SIN_FRAMEWORK)


aristas = defaultdict(lambda: {"sitios": [], "delta_lcp": []})
for sitio in datos["sitios"]:
    observados = [(principal(m[0]), m[1]) for m in sitio["meses"] if m[0] is not None]
    for i in range(LADO, len(observados) - LADO + 1):
        antes, despues = observados[i - LADO:i], observados[i:i + LADO]
        a, b = {g for g, _ in antes}, {g for g, _ in despues}
        if len(a) == 1 and len(b) == 1 and a != b:
            arista = aristas[(a.pop(), b.pop())]
            arista["sitios"].append(sitio["origin"])
            lcp_antes = [v for _, v in antes if v is not None]
            lcp_despues = [v for _, v in despues if v is not None]
            if lcp_antes and lcp_despues:
                arista["delta_lcp"].append(median(lcp_despues) - median(lcp_antes))

salida = {
    "cliente": CLIENTE,
    "meses_por_lado": LADO,
    "grupos": list(GRUPOS) + [SIN_FRAMEWORK],
    "migraciones": sorted((
        {"desde": a, "hacia": b, "sitios": len(v["sitios"]),
         "delta_lcp_mediana_ms": round(median(v["delta_lcp"])) if v["delta_lcp"] else None,
         "ejemplos": sorted(v["sitios"])[:5]}
        for (a, b), v in aristas.items()), key=lambda m: -m["sitios"]),
}
salida["migraciones_sostenidas"] = sum(m["sitios"] for m in salida["migraciones"])
(SALIDAS / f"migraciones_frontend_{CLIENTE}.json").write_text(json.dumps(salida, ensure_ascii=False, indent=1))
print(f"{CLIENTE}: {salida['migraciones_sostenidas']} migraciones sostenidas en {len(salida['migraciones'])} pares")
for m in salida["migraciones"]:
    print(f"  {m['sitios']:4d}  {m['desde']} → {m['hacia']}  ΔLCP {m['delta_lcp_mediana_ms']} ms")
