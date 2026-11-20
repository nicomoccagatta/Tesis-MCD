"""Valida la reproducción local de aurora (analisis/aurora_local) contra la aurora oficial de HTTP Archive.

Entrada: analisis/salidas/validacion_aurora_en_vivo.json (los sitios elegidos al azar de la muestra de
         10k de HTTP Archive, sep-2026, con la versión de React según la aurora oficial).
Corre aurora_local.cjs sobre esos sitios en vivo y compara la versión que registra React con la de
la aurora oficial. La muestra oficial es de sep-2026 y la corrida local es de hoy: una versión distinta
puede ser una actualización del sitio.

Salida: analisis/salidas/validacion_aurora_local.json

Uso: analisis/.venv/bin/python analisis/validar_aurora_local.py
"""

import json
import subprocess
import tempfile
from datetime import date

from fuentes import RAIZ, SALIDAS

ENTRADA = SALIDAS / "validacion_aurora_en_vivo.json"
SALIDA = SALIDAS / "validacion_aurora_local.json"
SCRIPT = RAIZ / "analisis/aurora_local/aurora_local.cjs"

sitios = json.loads(ENTRADA.read_text())["sitios"]
with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
    f.write("\n".join(s["page"] for s in sitios))
salida = subprocess.run(["node", str(SCRIPT), f.name], capture_output=True, text=True, check=True).stdout
locales = {r["url"]: r for r in map(json.loads, salida.splitlines())}


def comparar(oficial, local):
    if local is None:
        return "local_sin_react"
    if oficial is None:
        return "oficial_sin_react"
    if local == oficial:
        return "exacta"
    return "misma_mayor" if local.split(".")[0] == oficial.split(".")[0] else "distinta"


resultados, resumen = [], {}
for s in sitios:
    local = locales.get(s["page"], {})
    fila = {"page": s["page"], "grupo": s["grupo"], "react_version_aurora_oficial": s["react_version_aurora"],
            "react_version_aurora_local": local.get("react_version"), "error_local": local.get("error"),
            "comparacion": "error_local" if local.get("error") else comparar(s["react_version_aurora"], local.get("react_version"))}
    resultados.append(fila)
    g = resumen.setdefault(s["grupo"], {"sitios": 0})
    g["sitios"] += 1
    g[fila["comparacion"]] = g.get(fila["comparacion"], 0) + 1

SALIDA.write_text(json.dumps({"fecha_corrida_local": date.today().isoformat(),
                              "oficial": "sample_data.pages_10k sep-2026, móvil", "resumen": resumen,
                              "sitios": resultados}, ensure_ascii=False, indent=1))
print(json.dumps(resumen, ensure_ascii=False, indent=1))
