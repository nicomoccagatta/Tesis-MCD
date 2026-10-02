#!/usr/bin/env bash
# Corre una query de esta carpeta con dry-run + tope de bytes + export a Parquet + ledger de cuota.
# Uso: ./run_query.sh <tabla>/<NNN-nombre-descriptivo>
# Ejemplo: ./run_query.sh httparchive_crawl_pages/001-panel-root-pages-growth-2020-2026
set -euo pipefail

PROJECT="tesis-506222"
MAX_BYTES_BILLED="${MAX_BYTES_BILLED:-107374182400}"  # 100 GB por default

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="${1:?Uso: run_query.sh <tabla>/<NNN-nombre-descriptivo>}"
SQL_FILE="$DIR/$NAME.sql"
CSV_FILE="$DIR/$NAME.csv"
PARQUET_FILE="$DIR/$NAME.parquet"
LEDGER="$DIR/usage-log.csv"

if [[ ! -f "$SQL_FILE" ]]; then
  echo "No existe $SQL_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$PARQUET_FILE")"

command -v duckdb >/dev/null || { echo "Falta duckdb (brew install duckdb)" >&2; exit 1; }

echo "== Dry-run: estimando costo de $NAME.sql =="
DRY_JSON=$(bq query --project_id="$PROJECT" --use_legacy_sql=false --dry_run --format=json < "$SQL_FILE")
BYTES=$(python3 -c "import json,sys; print(json.load(sys.stdin)['statistics']['query']['totalBytesProcessed'])" <<< "$DRY_JSON")
GB=$(python3 -c "print(round($BYTES/1e9, 4))")
echo "Bytes a procesar según el dry-run: $BYTES  (~${GB} GB)"
echo "(El dry-run no descuenta el clustering: lo facturado puede ser bastante menor. El ledger registra lo facturado.)"

if [[ "$BYTES" -eq 0 ]]; then
  echo "Aviso: 0 bytes procesados según el dry-run. Puede ser una query trivial o (más probable) que falte el filtro de partición sobre 'date' y esté usando cache/metadata. Revisar antes de confirmar." >&2
fi

read -r -p "¿Ejecutar la query? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Cancelado."
  exit 0
fi

echo "== Ejecutando y exportando a CSV =="
JOB_ID="tesis_$(date +%Y%m%d_%H%M%S)_$$"
bq query \
  --project_id="$PROJECT" \
  --job_id="$JOB_ID" \
  --use_legacy_sql=false \
  --format=csv \
  --max_rows=50000000 \
  --maximum_bytes_billed="$MAX_BYTES_BILLED" \
  < "$SQL_FILE" > "$CSV_FILE"

echo "== Convirtiendo a Parquet con DuckDB =="
duckdb -c "COPY (SELECT * FROM read_csv_auto('$CSV_FILE')) TO '$PARQUET_FILE' (FORMAT PARQUET);"
rm -f "$CSV_FILE"

echo "== Registrando uso en usage-log.csv =="
BILLED=$(bq show --project_id="$PROJECT" --format=json -j "$JOB_ID" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['statistics']['query']['totalBytesBilled'])")
GB_BILLED=$(python3 -c "print(round($BILLED/1e9, 4))")
echo "Bytes facturados por el job $JOB_ID: $BILLED  (~${GB_BILLED} GB)"
DATE="$(date +%Y-%m-%d)"
if [[ ! -f "$LEDGER" ]]; then
  echo "date,project,script,gb_dry_run,gb_billed,job_id" > "$LEDGER"
fi
echo "$DATE,$PROJECT,$NAME,$GB,$GB_BILLED,$JOB_ID" >> "$LEDGER"

echo "Listo: $PARQUET_FILE"

python3 - "$LEDGER" "$DATE" <<'PYEOF'
import csv, sys
ledger, date = sys.argv[1], sys.argv[2]
month = date[:7]
total = 0.0
with open(ledger) as f:
    for row in csv.DictReader(f):
        if row["date"].startswith(month) and row["project"] == "tesis-506222":
            total += float(row["gb_billed"])
print(f"Acumulado facturado {month} en tesis-506222: {total:.2f} GB de 1024 GB (free tier)")
PYEOF
