"""Rutas de entrada y salida compartidas por los scripts de análisis, por cliente del crawl."""

import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SALIDAS = RAIZ / "analisis/salidas"
CATEGORIAS = RAIZ / "bigquery/httparchive_wappalyzer_technologies/001-categorias-e-implies-por-tecnologia.parquet"

# Cohorte fija: root pages con rank <= 10000 en enero 2025, seguidos los 12 meses de 2025
# sin volver a filtrar por rank (cross_source/003 y 004 filtraban mes a mes y quedan como registro).
PANELES = {
    "mobile": RAIZ / "bigquery/cross_source/007-panel-cohorte-top10k-ene2025-2025.parquet",
    "desktop": RAIZ / "bigquery/cross_source/008-panel-cohorte-top10k-ene2025-2025-desktop.parquet",
}
# Custom metric "aurora" de HTTP Archive para las páginas de la cohorte con rank <= 50000, ambos clientes:
# dic-2025 (006) y ene-nov 2025 (007).
AURORA_2025 = [
    RAIZ / "bigquery/httparchive_crawl_pages/006-aurora-cohorte-top10k-dic2025.parquet",
    RAIZ / "bigquery/httparchive_crawl_pages/007-aurora-cohorte-top10k-ene-nov2025.parquet",
]
# Lista de la cohorte con su rank de enero 2025 (crawl móvil), incluidos los sitios sin tecnologías ese mes.
COHORTE_ENERO = RAIZ / "bigquery/httparchive_crawl_pages/004-root-pages-top10k-conteo-tecnologias-ene2025.parquet"


def cliente_desde_argv():
    """Cliente pedido por línea de comandos (mobile por defecto)."""
    cliente = sys.argv[1] if len(sys.argv) > 1 else "mobile"
    if cliente not in PANELES:
        sys.exit(f"Cliente desconocido: {cliente}. Opciones: {', '.join(PANELES)}")
    return cliente
