"""Actualiza los datos incrustados en bitacora.html con los resultados versionados del repo.

Lee las salidas de analisis/salidas/, los .parquet de bigquery/ (vía DuckDB), el encabezado de
cada .sql, bigquery/usage-log.csv y bitacora/changelog.md. Reemplaza la línea `const DATOS = ...;`
y la lista de "Trabajo desde la entrega anterior" de cada entrega. La página queda autocontenida
(abre con doble clic, sin servidor). El resto del texto se edita a mano en el HTML.

Antes de correrlo, regenerar las salidas que cambien:
  analisis/.venv/bin/python analisis/cambios_frontend.py mobile   (y desktop)
  analisis/.venv/bin/python analisis/auditoria_wappalyzer.py <clon de HTTPArchive/wappalyzer>

Uso: analisis/.venv/bin/python bitacora/armar_bitacora.py
"""

import csv
import json
import re
from pathlib import Path

import duckdb

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parent
BQ = RAIZ / "bigquery"
SALIDAS = RAIZ / "analisis/salidas"
PAGINA = AQUI / "bitacora.html"
CLIENTES = ("mobile", "desktop")

con = duckdb.connect()


def parquet(ruta):
    """Filas de un .parquet de bigquery/ como lista de diccionarios."""
    cursor = con.execute(f"SELECT * FROM '{BQ / ruta}.parquet'")
    columnas = [c[0] for c in cursor.description]
    return [{c: (v.isoformat() if hasattr(v, "isoformat") else v) for c, v in zip(columnas, fila)}
            for fila in cursor.fetchall()]


def salida(nombre):
    return json.loads((SALIDAS / nombre).read_text())


def encabezado_sql(ruta):
    """Campos del encabezado de comentarios de un .sql (Fecha, Propósito, Filtro, Tablas)."""
    campos, actual = {}, None
    for linea in ruta.read_text().splitlines():
        if not linea.startswith("--"):
            break
        m = re.match(r"--\s*(Fecha|Propósito|Filtro de partición|Tablas):\s*(.*)", linea)
        if m:
            actual = m.group(1)
            campos[actual] = m.group(2).strip()
        elif actual:
            campos[actual] += " " + linea[2:].strip()
    return campos


# Registro de extracciones: cada .sql versionado con sus corridas en el ledger.
corridas = {}
with open(BQ / "usage-log.csv", newline="") as f:
    for fila in csv.DictReader(f):
        corridas.setdefault(fila["script"], []).append({
            "fecha": fila["date"], "gb_dry_run": float(fila["gb_dry_run"]),
            "gb_facturado": float(fila["gb_billed"]), "job": fila["job_id"]})
extracciones = []
for sql in sorted(BQ.glob("*/*.sql")):
    nombre = f"{sql.parent.name}/{sql.stem}"
    cabecera = encabezado_sql(sql)
    extracciones.append({
        "nombre": nombre,
        "fecha": cabecera.get("Fecha"),
        "proposito": cabecera.get("Propósito"),
        "tablas": cabecera.get("Tablas"),
        "corridas": corridas.get(nombre, []),
    })
cuota_por_mes = {}
for lista in corridas.values():
    for c in lista:
        cuota_por_mes[c["fecha"][:7]] = round(cuota_por_mes.get(c["fecha"][:7], 0) + c["gb_facturado"], 2)

grafo = {}
for cliente in CLIENTES:
    g = salida(f"grafo_bipartito_{cliente}.json")
    proyeccion = {k: v for k, v in g["proyeccion"].items() if k != "aristas"}
    # Red proyectada del componente conexo principal: los nodos con coordenadas de grafo_bipartito.py.
    en_red = {n: v for n, v in g["nodos"].items() if v["xy"]}
    red = {
        "nodos": [{"id": n, "sitios": v["sitios"], "comunidad": v["comunidad"], "xy": v["xy"]} for n, v in en_red.items()],
        "aristas": [a for a in g["proyeccion"]["aristas"] if a["u"] in en_red and a["v"] in en_red],
    }
    grafo[cliente] = {
        "mes": g["mes"], "sitios_mes": g["sitios_mes"], "bipartito": g["bipartito"], "proyeccion": proyeccion,
        "grupos_framework": [{k: v for k, v in grupo.items() if k != "librerias_top"} for grupo in g["grupos_framework"]],
        "cobertura_version": g["cobertura_version"], "versiones": g["versiones"],
        "matriz_grupo_libreria": g["matriz_grupo_libreria"],
        "matriz_version_libreria": g["matriz_version_libreria"],
        "librerias_top": [{"libreria": k, "sitios": v} for k, v in g["libreria_total_sitios"].items()],
        "recableado_jquery_react": g["recableado_jquery_react"],
        "red": red,
        "stacks": [{"id": s["id"], "tecnologias": s["tecnologias"][:8], "sitios_asignados": s["sitios_asignados"],
                    "lcp_mediana_ms": s["lcp_mediana_ms"]} for s in g["stacks"]],
    }

def extraccion_panel(corridas):
    """Filas, tecnologías y GB facturados de la extracción que alimenta el panel y el grafo."""
    archivos = {
        "mobile": "cross_source/007-panel-cohorte-top10k-ene2025-2025",
        "desktop": "cross_source/008-panel-cohorte-top10k-ene2025-2025-desktop",
    }
    salida = {}
    for cliente, nombre in archivos.items():
        filas, techs, por = con.execute(
            "SELECT COUNT(*), COUNT(DISTINCT technology), "
            "COUNT(*) * 1.0 / COUNT(DISTINCT origin || date) "
            f"FROM '{BQ / nombre}.parquet'").fetchone()
        salida[cliente] = {
            "filas": filas, "tecnologias": techs, "por_sitio_mes": round(por, 1),
            "gb_facturado": round(corridas[nombre][-1]["gb_facturado"], 1),
        }
    return salida


datos = {
    "semaforo_jul2026": parquet("chrome-ux-report_materialized_metrics_summary/001-lcp-inp-cls-semaforo-jul2026")[0],
    "unicidad_origin_jul2026": parquet("chrome-ux-report_materialized_metrics_summary/002-verificar-unicidad-origin-jul2026")[0],
    "crecimiento_root_pages": parquet("httparchive_crawl_pages/001-panel-root-pages-growth-2020-2026"),
    "cobertura_cruce": parquet("cross_source/002-cobertura-cruce-httparchive-crux-2018-2026"),
    "did_exploratorio": parquet("cross_source/001-migraciones-y-did-dos-periodos-jun2025-jun2026"),
    "ejemplos_wayback": parquet("httparchive_crawl_pages/002-ejemplos-migracion-jquery-react-top10k-2025-2026"),
    "cobertura_top10k": {"ene2025": parquet("cross_source/009-cobertura-top10k-crux-vs-crawl-ene2025")[0],
                         "dic2025": parquet("cross_source/005-cobertura-top10k-crux-vs-crawl-dic2025")[0]},
    "costo_mes_completo_dic2025": parquet("cross_source/006-costo-mes-completo-sin-rank-dic2025")[0],
    "panel_piloto": {c: salida(f"panel_piloto_scd2_{c}.json") for c in CLIENTES},
    "panel_extraccion": extraccion_panel(corridas),
    "grafo": grafo,
    "cambios_frontend": {c: salida(f"cambios_frontend_{c}.json") for c in CLIENTES},
    "cambios_frontend_aurora": {c: salida(f"cambios_frontend_{c}_aurora.json") for c in CLIENTES},
    "auditoria_wappalyzer": salida("auditoria_wappalyzer_frontend.json"),
    "react_muestra_10k": parquet("httparchive_sample_data_pages_10k/001-react-aurora-vs-wappalyzer"),
    "validacion_aurora_en_vivo": salida("validacion_aurora_en_vivo.json"),
    "validacion_aurora_local": salida("validacion_aurora_local.json"),
    "extracciones": extracciones,
    "cuota_por_mes_gb": cuota_por_mes,
}

def html_de(texto):
    """Escapa el texto y pasa lo que está entre backticks a <code>."""
    partes = re.split(r"`([^`]+)`", texto)
    salida = []
    for i, parte in enumerate(partes):
        seguro = parte.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        salida.append(f"<code>{seguro}</code>" if i % 2 else seguro)
    return "".join(salida)


def aplicar_changelog(html):
    """Reemplaza la lista de trabajo de cada entrega por los ítems de changelog.md."""
    items = {}
    entrega = None
    for linea in (AQUI / "changelog.md").read_text().splitlines():
        marca = re.match(r"^## Entrega (\d+)\s*$", linea)
        if marca:
            entrega = int(marca.group(1))
            items[entrega] = []
            continue
        item = re.match(r"^- \*\*(.+?)\*\*\s*(.*)$", linea)
        if item and entrega is not None:
            items[entrega].append((item.group(1).strip(), item.group(2).strip()))
    if not items:
        raise SystemExit("changelog.md no tiene entregas")
    for n, lista in items.items():
        filas = "\n".join(f"        <li><b>{html_de(rotulo)}</b> {html_de(texto)}</li>" for rotulo, texto in lista)
        html, reemplazos = re.subn(
            rf'(<section id="entrega-{n}"[\s\S]*?<details class="trabajo">\s*<summary>[^<]*</summary>\s*)<ul>[\s\S]*?</ul>',
            rf"\1<ul>\n{filas}\n        </ul>",
            html, count=1)
        if reemplazos != 1:
            raise SystemExit(f"No se encontró la lista de trabajo de la entrega {n}")
    return html


linea = "const DATOS = " + json.dumps(datos, ensure_ascii=False, separators=(",", ":")) + ";"
html, n = re.subn(r"^const DATOS = .*;$", lambda _: linea, PAGINA.read_text(), count=1, flags=re.M)
if n != 1:
    raise SystemExit(f"No se encontró la línea `const DATOS = ...;` en {PAGINA}")
html = aplicar_changelog(html)
PAGINA.write_text(html)
print(f"{PAGINA.relative_to(RAIZ)}: {len(linea) / 1e6:.1f} MB de datos incrustados")
