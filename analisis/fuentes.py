"""Rutas de entrada y salida compartidas por los scripts de análisis, por cliente del crawl."""

import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SALIDAS = RAIZ / "analisis/salidas"
CATEGORIAS = RAIZ / "bigquery/httparchive_wappalyzer_technologies/001-categorias-e-implies-por-tecnologia.parquet"

PANELES = {
    "mobile": RAIZ / "bigquery/cross_source/003-panel-piloto-sitio-tecnologia-top10k-2025.parquet",
    "desktop": RAIZ / "bigquery/cross_source/004-panel-piloto-sitio-tecnologia-top10k-2025-desktop.parquet",
}


def cliente_desde_argv():
    """Cliente pedido por línea de comandos (mobile por defecto)."""
    cliente = sys.argv[1] if len(sys.argv) > 1 else "mobile"
    if cliente not in PANELES:
        sys.exit(f"Cliente desconocido: {cliente}. Opciones: {', '.join(PANELES)}")
    return cliente
