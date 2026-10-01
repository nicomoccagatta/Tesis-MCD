"""Genera explorador_grafo.html incrustando las salidas de grafo_bipartito.py de ambos clientes.

La página queda autocontenida (abre con doble clic, sin servidor).

Uso: analisis/.venv/bin/python analisis/visualizaciones/armar_explorador.py
"""

import json
from pathlib import Path

AQUI = Path(__file__).resolve().parent
SALIDAS = AQUI.parent / "salidas"
CAMPOS = ("grupos_framework", "matriz_completa", "libreria_total_sitios_completo", "nodos", "stacks", "proyeccion")

datos = {}
for cliente in ("mobile", "desktop"):
    completo = json.loads((SALIDAS / f"grafo_bipartito_{cliente}.json").read_text())
    datos[cliente] = {campo: completo[campo] for campo in CAMPOS}

plantilla = (AQUI / "explorador_grafo.template.html").read_text()
(AQUI / "explorador_grafo.html").write_text(
    plantilla.replace("__DATOS__", json.dumps(datos, ensure_ascii=False, separators=(",", ":")))
)
