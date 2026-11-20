"""Validación de la custom metric "aurora" de HTTP Archive contra los sitios en vivo.

Entrada: bigquery/httparchive_sample_data_pages_10k/002 (páginas raíz de la muestra de 10k, sep-2026,
         con React según aurora y/o según Wappalyzer).

Para una muestra al azar de cada grupo (cliente móvil):
  A. aurora detecta React y Wappalyzer no
  B. ambos detectan React
  C. Wappalyzer detecta React y aurora no
se descarga la portada y sus scripts (externos e inline) y se busca la firma con la que react-dom se
registra en el hook de DevTools: version:"x.y.z" ... rendererPackageName:"react-dom". Si no aparece la
versión pero sí marcas propias de react-dom ("Minified React error", "__reactFiber$"), se cuenta como
React sin versión. No encontrar React no prueba que no esté: puede cargarse en un chunk que se pide más
tarde, así que esos casos son "no concluyente".

Salida: analisis/salidas/validacion_aurora_en_vivo.json (resultado por sitio y resumen por grupo, con la
fecha de la descarga: los sitios cambian con el tiempo).

Uso: analisis/.venv/bin/python analisis/validar_aurora_en_vivo.py [sitios_por_grupo]
"""

import json
import random
import re
import sys
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import date

import duckdb

from fuentes import RAIZ, SALIDAS

MUESTRA = RAIZ / "bigquery/httparchive_sample_data_pages_10k/002-react-aurora-vs-wappalyzer-por-pagina.parquet"
SALIDA = SALIDAS / "validacion_aurora_en_vivo.json"
POR_GRUPO = int(sys.argv[1]) if len(sys.argv) > 1 else 40
SEMILLA = 20261013
UA = ("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) "
      "Chrome/126.0.0.0 Mobile Safari/537.36")
MAX_SCRIPTS = 40
MAX_BYTES = 12_000_000

FIRMA_VERSION = re.compile(r'version:"(\d+\.\d+\.\d+[^"]*)"[^{}]{0,120}?rendererPackageName:"react-dom"')
MARCAS_REACT = ("Minified React error", "__reactFiber$", "__reactContainer$", "react.dev/errors/",
                "reactjs.org/docs/error-decoder")
SCRIPT_SRC = re.compile(r'<script\b[^>]*\bsrc=["\']([^"\']+)["\']', re.I)
PRELOAD = re.compile(r'<link\b[^>]*\brel=["\'](?:modulepreload|preload)["\'][^>]*\bhref=["\']([^"\']+\.m?js[^"\']*)["\']', re.I)
INLINE = re.compile(r'<script\b(?![^>]*\bsrc=)[^>]*>(.*?)</script>', re.I | re.S)


def bajar(url):
    pedido = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    with urllib.request.urlopen(pedido, timeout=25) as r:
        return r.geturl(), r.read(MAX_BYTES).decode("utf-8", errors="replace")


def revisar(fila):
    page = fila["page"]
    resultado = {"page": page, "grupo": fila["grupo"], "react_version_aurora": fila["react_version_aurora"],
                 "react_version_wappalyzer": fila["react_version_wappalyzer"], "rank": fila["rank"]}
    try:
        final, html = bajar(page)
    except Exception as e:  # noqa: BLE001 - se registra el motivo y el sitio queda no concluyente
        return {**resultado, "estado": "error", "detalle": f"{type(e).__name__}: {e}"[:160]}
    textos = [html] + INLINE.findall(html)
    urls = list(dict.fromkeys(urllib.parse.urljoin(final, u) for u in SCRIPT_SRC.findall(html) + PRELOAD.findall(html)))
    bajados = 0
    for u in urls[:MAX_SCRIPTS]:
        try:
            textos.append(bajar(u)[1])
            bajados += 1
        except Exception:  # noqa: BLE001 - un script que no baja no invalida el resto
            continue
    versiones = sorted({v for t in textos for v in FIRMA_VERSION.findall(t)})
    marcas = sorted({m for t in textos for m in MARCAS_REACT if m in t})
    estado = "react_con_version" if versiones else "react_sin_version" if marcas else "no_encontrado"
    return {**resultado, "estado": estado, "versiones_react_dom": versiones, "marcas": marcas,
            "scripts_listados": len(urls), "scripts_bajados": bajados, "url_final": final}


def coincide(r):
    """Compara la versión de react-dom encontrada con la de aurora (exacta o misma versión mayor)."""
    a = r["react_version_aurora"]
    if not a or r["estado"] != "react_con_version":
        return None
    if a in r["versiones_react_dom"]:
        return "exacta"
    return "misma_mayor" if any(v.split(".")[0] == a.split(".")[0] for v in r["versiones_react_dom"]) else "distinta"


cursor = duckdb.connect().execute(f"""
SELECT page, rank, react_version_aurora, react_version_wappalyzer,
       CASE WHEN react_version_aurora IS NOT NULL AND NOT react_wappalyzer THEN 'A_aurora_si_wappalyzer_no'
            WHEN react_version_aurora IS NOT NULL AND react_wappalyzer THEN 'B_ambos'
            ELSE 'C_wappalyzer_si_aurora_no' END AS grupo
FROM '{MUESTRA}' WHERE client = 'mobile' ORDER BY page
""")
filas = [dict(zip([c[0] for c in cursor.description], f)) for f in cursor.fetchall()]

azar = random.Random(SEMILLA)
elegidas = []
for grupo in sorted({f["grupo"] for f in filas}):
    del_grupo = [f for f in filas if f["grupo"] == grupo]
    elegidas += azar.sample(del_grupo, min(POR_GRUPO, len(del_grupo)))

with ThreadPoolExecutor(max_workers=8) as pool:
    resultados = list(pool.map(revisar, elegidas))
for r in resultados:
    r["coincide_con_aurora"] = coincide(r)

resumen = {}
for r in resultados:
    g = resumen.setdefault(r["grupo"], {"sitios": 0})
    g["sitios"] += 1
    g[r["estado"]] = g.get(r["estado"], 0) + 1
    if r["coincide_con_aurora"]:
        g["version_" + r["coincide_con_aurora"]] = g.get("version_" + r["coincide_con_aurora"], 0) + 1

SALIDA.write_text(json.dumps({"fecha_descarga": date.today().isoformat(), "muestra": "sample_data.pages_10k sep-2026, móvil",
                              "sitios_por_grupo": POR_GRUPO, "semilla": SEMILLA, "resumen": resumen,
                              "sitios": resultados}, ensure_ascii=False, indent=1))
print(json.dumps(resumen, ensure_ascii=False, indent=1))
