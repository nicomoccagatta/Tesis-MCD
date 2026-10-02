"""Actualiza los datos incrustados en explorador_grafo.html con las salidas de grafo_bipartito.py.

Reemplaza la línea `const DATOS = ...;` del HTML con los datos de ambos clientes. La página
queda autocontenida (abre con doble clic, sin servidor).

Uso: analisis/.venv/bin/python analisis/visualizaciones/armar_explorador.py
"""

import json
import re
from pathlib import Path

AQUI = Path(__file__).resolve().parent
SALIDAS = AQUI.parent / "salidas"
PAGINA = AQUI / "explorador_grafo.html"
CAMPOS = ("grupos_framework", "matriz_completa", "libreria_total_sitios_completo", "nodos", "stacks", "proyeccion")

datos = {}
for cliente in ("mobile", "desktop"):
    completo = json.loads((SALIDAS / f"grafo_bipartito_{cliente}.json").read_text())
    datos[cliente] = {campo: completo[campo] for campo in CAMPOS}

linea = "const DATOS = " + json.dumps(datos, ensure_ascii=False, separators=(",", ":")) + ";"
html, n = re.subn(r"^const DATOS = .*;$", lambda _: linea, PAGINA.read_text(), count=1, flags=re.M)
if n != 1:
    raise SystemExit(f"No se encontró la línea `const DATOS = ...;` en {PAGINA}")
PAGINA.write_text(html)
