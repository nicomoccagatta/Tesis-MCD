"""Auditoría de la detección de frameworks frontend en el Wappalyzer de HTTP Archive.

Entrada: un clon de https://github.com/HTTPArchive/wappalyzer (el fork que usa el crawl mensual
         de HTTP Archive, según su README), pasado como argumento, y los paneles de la cohorte fija.

Responde tres preguntas:
  1. Qué frameworks del relevamiento State of JS 2025 existen en el catálogo y con qué reglas.
  2. Cuántos sitios de la cohorte top 10k detectan cada tecnología frontend (móvil y escritorio).
  3. Cuándo cambiaron las reglas de esas tecnologías desde dic-2022: historial de la rama
     principal del fork (--first-parent), comparando cada versión del archivo con la anterior.
     La fecha es la del commit que entra a la rama principal; no está verificado que el crawl de
     cada mes use la versión vigente en ese momento.
Además sigue a los sitios detectados como Remix en enero 2025 hasta diciembre.

Salida: analisis/salidas/auditoria_wappalyzer_frontend.json

Uso: analisis/.venv/bin/python analisis/auditoria_wappalyzer.py <ruta-al-clon-de-HTTPArchive/wappalyzer>
"""

import json
import subprocess
import sys
from pathlib import Path

import duckdb

from frontend import TECNOLOGIAS_FRONTEND
from fuentes import PANELES, SALIDAS

if len(sys.argv) != 2:
    sys.exit(__doc__)
CLON = Path(sys.argv[1])
SALIDA = SALIDAS / "auditoria_wappalyzer_frontend.json"
DESDE = "2022-12-01"
TIPOS_DE_REGLA = ("js", "dom", "scriptSrc", "html", "meta", "headers", "cookies", "css", "url",
                  "text", "xhr", "scripts", "robots", "probe", "dns")
CAMPOS_SIN_DETECCION = {"description", "icon", "website", "oss", "saas", "pricing", "cpe"}

# State of JS 2025 (2025.stateofjs.com, secciones front-end frameworks y meta-frameworks):
# nombre en la encuesta -> nombre en Wappalyzer (None = no existe en el catálogo).
STATE_OF_JS_2025 = [
    ("React", "Front-end frameworks", "React"), ("Vue.js", "Front-end frameworks", "Vue.js"),
    ("Angular", "Front-end frameworks", "Angular"), ("Preact", "Front-end frameworks", "Preact"),
    ("Svelte", "Front-end frameworks", "Svelte"), ("Alpine.js", "Front-end frameworks", "Alpine.js"),
    ("Lit", "Front-end frameworks", "lit-html"), ("Solid", "Front-end frameworks", "SolidJS"),
    ("Qwik", "Front-end frameworks", "Qwik"), ("Stencil", "Front-end frameworks", "Stencil"),
    ("HTMX", "Front-end frameworks", "Htmx"), ("Astro", "Front-end frameworks (otros)", "Astro"),
    ("Ember", "Front-end frameworks (otros)", "Ember.js"),
    ("Ripple", "Front-end frameworks (otros)", None),
    ("TanStack Start", "Front-end frameworks (otros)", "TanStack Start"),
    ("Elm", "Front-end frameworks (otros)", "Elm"), ("Nuxt", "Front-end frameworks (otros)", "Nuxt.js"),
    ("Remix", "Front-end frameworks (otros)", "Remix"), ("Next.js", "Front-end frameworks (otros)", "Next.js"),
    ("Aurelia", "Front-end frameworks (otros)", "Aurelia"), ("jQuery", "Front-end frameworks (otros)", "jQuery"),
    ("Gatsby", "Meta-frameworks", "Gatsby"), ("SvelteKit", "Meta-frameworks", "SvelteKit"),
    ("Docusaurus", "Meta-frameworks", "Docusaurus"), ("SolidStart", "Meta-frameworks", "SolidStart"),
    ("Deno Fresh", "Meta-frameworks", "Fresh"), ("Analog", "Meta-frameworks", None),
    ("Quasar", "Meta-frameworks", "Quasar"), ("TanStack Router", "Meta-frameworks (otros)", None),
    ("React Router", "Meta-frameworks (otros)", "React Router"), ("Meteor", "Meta-frameworks (otros)", "Meteor"),
    ("Vike", "Meta-frameworks (otros)", None), ("Expo", "Meta-frameworks (otros)", None),
    ("inertiajs", "Meta-frameworks (otros)", "Inertia.js"), ("Eleventy", "Meta-frameworks (otros)", "Eleventy"),
    ("Redwood SDK", "Meta-frameworks (otros)", None),
]
NOTAS = {
    "Ripple": "El catálogo tiene una tecnología llamada Ripple, pero es otro producto "
              "(frontend de Single Digital Presence, sobre Nuxt y Vue).",
    "Redwood SDK": "El catálogo tiene RedwoodJS (regla: div#redwood-app); no está verificado si detecta Redwood SDK.",
}


def git(*args):
    return subprocess.run(["git", "-C", str(CLON), *args], capture_output=True, text=True, check=True).stdout


def leer_json(commit, archivo):
    """Contenido de un archivo de tecnologías en un commit; None si no existe o no es JSON válido."""
    resultado = subprocess.run(["git", "-C", str(CLON), "show", f"{commit}:src/technologies/{archivo}"],
                               capture_output=True, text=True)
    if resultado.returncode != 0:
        return None
    try:
        return json.loads(resultado.stdout)
    except json.JSONDecodeError:
        return None


def archivo_de(tecnologia):
    inicial = tecnologia[0].lower()
    return f"{inicial if inicial.isalpha() else '_'}.json"


# 1. Catálogo vigente (HEAD del clon).
head = git("log", "-1", "--format=%H %ad", "--date=short").split()
categorias = {int(k): v["name"] for k, v in json.loads(git("show", "HEAD:src/categories.json")).items()}
catalogo = {}
for archivo in sorted({archivo_de(t) for t in TECNOLOGIAS_FRONTEND} | {archivo_de(w) for _, _, w in STATE_OF_JS_2025 if w}):
    catalogo.update(leer_json("HEAD", archivo) or {})

# 2. Sitios de la cohorte por tecnología y cliente.
con = duckdb.connect()
conteos = {}
for cliente, panel in PANELES.items():
    for tecnologia, algun_mes, diciembre in con.execute(f"""
        SELECT technology, COUNT(DISTINCT origin), COUNT(DISTINCT origin) FILTER (WHERE date = '2025-12-01')
        FROM '{panel}' GROUP BY technology""").fetchall():
        conteos.setdefault(tecnologia, {})[cliente] = {"algun_mes_2025": algun_mes, "dic_2025": diciembre}

seguidas = sorted(set(TECNOLOGIAS_FRONTEND) | {w for _, _, w in STATE_OF_JS_2025 if w})
tecnologias = []
for t in seguidas:
    regla = catalogo.get(t)
    tecnologias.append({
        "tecnologia": t,
        "en_catalogo": regla is not None,
        "en_lista_frontend": t in TECNOLOGIAS_FRONTEND,
        "familia": TECNOLOGIAS_FRONTEND.get(t),
        "categorias": [categorias.get(c, str(c)) for c in regla.get("cats", [])] if regla else [],
        "implies": ([regla["implies"]] if isinstance(regla.get("implies"), str) else regla.get("implies", [])) if regla else [],
        "tipos_de_regla": [k for k in TIPOS_DE_REGLA if regla and k in regla],
        "sitios": conteos.get(t, {}),
    })

# 3. Historial de cambios de reglas en la rama principal desde DESDE.
cambios = []
for archivo in sorted({archivo_de(t) for t in seguidas}):
    commits = [l.split() for l in git("log", "--first-parent", "--reverse", "--format=%H %ad", "--date=short",
                                      f"--since={DESDE}", "--", f"src/technologies/{archivo}").splitlines() if l]
    if not commits:
        continue
    previo = leer_json(git("rev-parse", f"{commits[0][0]}^").strip(), archivo) or {}
    for commit, fecha in commits:
        actual = leer_json(commit, archivo)
        if actual is None:
            continue
        for t in seguidas:
            if archivo_de(t) != archivo or previo.get(t) == actual.get(t):
                continue
            antes, despues = previo.get(t), actual.get(t)
            if antes is None or despues is None:
                tipo, campos = ("agregada", sorted(k for k in despues if k not in CAMPOS_SIN_DETECCION)) if antes is None else ("eliminada", [])
            else:
                tipo = "cambia"
                campos = sorted(k for k in set(antes) | set(despues)
                                if k not in CAMPOS_SIN_DETECCION and antes.get(k) != despues.get(k))
                if not campos:
                    continue
            cambios.append({"fecha": fecha, "commit": commit[:9], "tecnologia": t, "tipo": tipo, "campos": campos,
                            "mensaje": git("log", "-1", "--format=%s", commit).strip()})
        previo = actual
cambios.sort(key=lambda c: (c["fecha"], c["tecnologia"]))

# Sitios detectados como Remix en enero 2025, seguidos hasta diciembre (móvil).
remix = con.execute(f"""
WITH p AS (SELECT * FROM '{PANELES['mobile']}'),
     enero AS (SELECT DISTINCT origin FROM p WHERE date = '2025-01-01' AND technology = 'Remix')
SELECT e.origin,
       BOOL_OR(p.technology = 'Remix' AND p.date = '2025-12-01') AS remix_dic,
       MAX(p.version) FILTER (WHERE p.technology = 'React Router' AND p.date = '2025-01-01') AS react_router_ene,
       MAX(p.version) FILTER (WHERE p.technology = 'React Router' AND p.date = '2025-12-01') AS react_router_dic,
       BOOL_OR(p.date = '2025-12-01') AS observado_dic
FROM enero e LEFT JOIN p USING (origin)
GROUP BY e.origin ORDER BY remix_dic, e.origin""").fetchall()

SALIDA.write_text(json.dumps({
    "catalogo_commit": head[0][:9],
    "catalogo_fecha": head[1],
    "historial_desde": DESDE,
    "state_of_js_2025": [{"nombre": n, "seccion": s, "wappalyzer": w, "nota": NOTAS.get(n)}
                         for n, s, w in STATE_OF_JS_2025],
    "tecnologias": tecnologias,
    "cambios_de_reglas": cambios,
    "remix_enero_a_diciembre_mobile": [
        {"origin": o, "remix_dic": r, "react_router_ene": a, "react_router_dic": d, "observado_dic": obs}
        for o, r, a, d, obs in remix],
}, ensure_ascii=False, indent=1))
print(f"{len(tecnologias)} tecnologías, {len(cambios)} cambios de reglas desde {DESDE} -> {SALIDA}")
