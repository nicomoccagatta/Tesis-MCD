"""Actualiza los datos incrustados en bitacora.html con los resultados versionados del repo.

Lee las salidas de analisis/salidas/, los .parquet de bigquery/ (vía DuckDB), el encabezado de
cada .sql y bigquery/usage-log.csv, y reemplaza la línea `const DATOS = ...;` del HTML. La página
queda autocontenida (abre con doble clic, sin servidor). El texto de cada sección se edita a mano
en el HTML; las cifras de tablas y gráficos salen de acá.

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
    grafo[cliente] = {
        "mes": g["mes"], "sitios_mes": g["sitios_mes"], "bipartito": g["bipartito"], "proyeccion": proyeccion,
        "grupos_framework": [{k: v for k, v in grupo.items() if k != "librerias_top"} for grupo in g["grupos_framework"]],
        "cobertura_version": g["cobertura_version"], "versiones": g["versiones"],
        "recableado_jquery_react": g["recableado_jquery_react"],
        "stacks": [{"tecnologias": s["tecnologias"][:8], "sitios_asignados": s["sitios_asignados"],
                    "lcp_mediana_ms": s["lcp_mediana_ms"]} for s in g["stacks"]],
    }

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
    "grafo": grafo,
    "cambios_frontend": {c: salida(f"cambios_frontend_{c}.json") for c in CLIENTES},
    "auditoria_wappalyzer": salida("auditoria_wappalyzer_frontend.json"),
    "react_muestra_10k": parquet("httparchive_sample_data_pages_10k/001-react-aurora-vs-wappalyzer"),
    "validacion_aurora_en_vivo": salida("validacion_aurora_en_vivo.json"),
    "validacion_aurora_local": salida("validacion_aurora_local.json"),
    "extracciones": extracciones,
    "cuota_por_mes_gb": cuota_por_mes,
}

linea = "const DATOS = " + json.dumps(datos, ensure_ascii=False, separators=(",", ":")) + ";"
html, n = re.subn(r"^const DATOS = .*;$", lambda _: linea, PAGINA.read_text(), count=1, flags=re.M)
if n != 1:
    raise SystemExit(f"No se encontró la línea `const DATOS = ...;` en {PAGINA}")
PAGINA.write_text(html)
print(f"{PAGINA.relative_to(RAIZ)}: {len(linea) / 1e6:.1f} MB de datos incrustados")
