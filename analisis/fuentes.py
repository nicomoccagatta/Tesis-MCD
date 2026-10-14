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
# Custom metric "aurora" de HTTP Archive de todas las visitas a las páginas de la cohorte en 2025: 006
# (dic-2025) y 007 (ene-nov 2025) traen las páginas de la cohorte móvil con rank <= 50000 en ambos clientes;
# 009 completa los sitio-mes del panel con rank > 50000 y los sitios de la cohorte de escritorio que no
# están en la lista móvil; 011, las visitas restantes con la lista de Wappalyzer vacía (halladas con 010).
AURORA_2025 = [
    RAIZ / "bigquery/httparchive_crawl_pages/006-aurora-cohorte-top10k-dic2025.parquet",
    RAIZ / "bigquery/httparchive_crawl_pages/007-aurora-cohorte-top10k-ene-nov2025.parquet",
    RAIZ / "bigquery/httparchive_crawl_pages/009-aurora-cohorte-top10k-2025-huecos.parquet",
    RAIZ / "bigquery/httparchive_crawl_pages/011-aurora-cohorte-top10k-2025-visitas-sin-wappalyzer.parquet",
]
# p75 de LCP/INP/CLS de CrUX para los orígenes de los dos paneles, 12 meses de 2025, phone y desktop.
CRUX_2025 = RAIZ / "bigquery/chrome-ux-report_materialized_device_summary/001-cwv-cohorte-top10k-2025.parquet"
# Lista de la cohorte con su rank de enero 2025 (crawl móvil), incluidos los sitios sin tecnologías ese mes.
COHORTE_ENERO = RAIZ / "bigquery/httparchive_crawl_pages/004-root-pages-top10k-conteo-tecnologias-ene2025.parquet"


def cliente_desde_argv():
    """Cliente pedido por línea de comandos (mobile por defecto)."""
    cliente = sys.argv[1] if len(sys.argv) > 1 else "mobile"
    if cliente not in PANELES:
        sys.exit(f"Cliente desconocido: {cliente}. Opciones: {', '.join(PANELES)}")
    return cliente
