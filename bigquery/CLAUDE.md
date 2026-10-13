# Convención de esta carpeta

Acá vive el trabajo de extracción de datos de la tesis (HTTP Archive + CrUX vía
BigQuery). El objetivo es que cada query quede versionada junto con su
resultado, y que el uso de cuota gratuita de BigQuery quede trackeado para no
pagar nunca por accidente.

## Proyecto

- **Proyecto GCP:** `tesis-506222` (cuenta `nmoccagatta@itba.edu.ar`, modo
  Sandbox, **sin billing vinculado**).
- Confirmado 2026-08-23: las tablas de destino que se crean en este proyecto
  **expiran a los 60 días** (es el comportamiento default de Sandbox). No es un
  problema: la tabla de BigQuery es descartable, el archivo `.parquet` local es
  la fuente de verdad persistente.
- Confirmado 2026-08-23: **Cloud Storage no está disponible** en este proyecto
  (crear un bucket requiere billing habilitado, aunque BigQuery sí tenga su
  free tier propio). Por eso el flujo NO usa `bq extract` a GCS — la
  exportación es directa: `bq query` a CSV, después convertido a Parquet
  localmente con DuckDB. Si en algún momento se linkea billing y aparece la
  necesidad de mover volúmenes grandes, ese flujo (destination table → `bq
  extract` a GCS → `gcloud storage cp`) es la alternativa, pero no debería
  hacer falta: toda query de esta carpeta debe llegar ya agregada/chica.

## Convención de nombres

Cada tabla consultada tiene su propia subcarpeta, nombrada igual que la tabla
de BigQuery (`proyecto_publico.dataset.tabla`) **pero reemplazando los puntos
por guiones bajos** (`proyecto_publico_dataset_tabla`). Dentro de esa
subcarpeta, cada extracción es un par de archivos con el mismo nombre base,
numerado secuencialmente con 3 dígitos **por subcarpeta** (cada tabla arranca
su propia numeración en 001):

```
httparchive_crawl_pages/
  001-panel-root-pages-growth-2020-2026.sql
  001-panel-root-pages-growth-2020-2026.parquet
  002-tech-panel-jquery-react-2020-2022.sql
  002-tech-panel-jquery-react-2020-2022.parquet
chrome-ux-report_materialized_metrics_summary/
  001-crux-lcp-semaforo-jun2026.sql
  001-crux-lcp-semaforo-jun2026.parquet
cross_source/
  001-migraciones-y-did-dos-periodos-jun2025-jun2026.sql
  001-migraciones-y-did-dos-periodos-jun2025-jun2026.parquet
```

**Por qué sin puntos:** una carpeta llamada `httparchive.crawl.pages` termina
en `.pages`, y macOS/Finder trata cualquier carpeta que termina en `.pages`
(o `.app`, `.key`, `.numbers`, etc.) como un paquete de una app específica en
vez de como una carpeta navegable — rompe la exploración normal en Finder.
Los guiones bajos evitan el problema por completo. Dentro del `.sql`, la
tabla real de BigQuery sigue escribiéndose con puntos (es la sintaxis válida
de BigQuery); el reemplazo es solo para el nombre de la carpeta en disco.

Si una query cruza más de una tabla (por ejemplo, panel + CrUX), va en
`cross_source/`, con su propia numeración secuencial independiente de las
demás subcarpetas, y todas las tablas involucradas se mencionan en el header
de comentario.

El número es puramente secuencial dentro de su tabla (orden en que se corrió),
no codifica nada más. El nombre descriptivo sí debe ser específico (qué
panel/rango/par de tecnología).

Cada `.sql` empieza con un header de comentario:

```sql
-- Fecha: 2026-08-23
-- Propósito: panel mensual de tecnología detectada, jQuery vs React, 2020-2022
-- Filtro de partición: date BETWEEN '2020-01-01' AND '2022-12-31'
-- Tablas: httparchive.crawl.pages, chrome-ux-report.materialized.metrics_summary
```

## Regla dura: nunca pegarle a `crawl.pages` sin filtro de partición

`httparchive.crawl.pages` está particionada por `date` (mensual). Cualquier
query sin `WHERE date = ...` o `WHERE date BETWEEN ...` escanea TODO el
histórico (petabytes) y agota la cuota gratuita en un segundo. El script
`run_query.sh` hace dry-run antes de correr nada, pero la responsabilidad real
es siempre escribir la query con el filtro puesto.

## Regla dura: agregar adentro de BigQuery, nunca traer filas crudas

Nunca hacer `SELECT *` sobre `crawl.pages` para bajar localmente. La query
tiene que devolver ya el resultado final (panel agregado por
origen/mes/tecnología, o lo que corresponda) — lo que se baja local son
millones de filas resumidas, no los crawls crudos.

## Cómo correr una query

```bash
./bigquery/run_query.sh httparchive_crawl_pages/001-nombre-descriptivo
```

El script:
1. Busca `httparchive_crawl_pages/001-nombre-descriptivo.sql` dentro de esta carpeta.
2. Hace **dry-run** y muestra cuántos GB estima escanear. **El dry-run no descuenta el
   clustering** (`crawl.pages` está clusterizada por `client`, `is_root_page`, `rank`, `page`):
   con filtros sobre esas columnas lo facturado puede ser mucho menor (ej. el panel piloto top 10k
   de 2025 estimó 234,9 GB y facturó 19,8 GB). Sirve como cota superior, no como costo.
3. Pide confirmación antes de ejecutar de verdad.
4. Corre la query con un tope duro de bytes facturados
   (`MAX_BYTES_BILLED`, default 100 GB — se puede subir con
   `MAX_BYTES_BILLED=500000000000 ./bigquery/run_query.sh nombre` si hace falta
   una extracción más grande, pero pensalo dos veces).
5. Exporta el resultado a `001-nombre-descriptivo.parquet` (vía CSV
   intermedio + DuckDB, que se borra al terminar).
6. Corre la query con un `job_id` explícito y anota en `usage-log.csv` la fecha, el
   script, el estimado del dry-run (`gb_dry_run`), lo **facturado por el job**
   (`gb_billed`, leído de `bq show -j`) y el `job_id`. Muestra el acumulado facturado del
   mes contra el free tier de 1024 GB.

No correr `bq query` a mano para esto — usar siempre el script, así el ledger
queda completo y nadie se olvida del dry-run o del tope de bytes.

## Límites verificados del Sandbox con tablas clusterizadas

Verificado el 13/10/2026 con `custom_metrics.other` de `crawl.pages` (~2 TB por mes según el
dry-run): tanto `MAX_BYTES_BILLED` como la cuota gratuita del Sandbox se comparan contra la
**estimación del dry-run**, que no descuenta el clustering, antes de ejecutar. Si la estimación
supera el tope, la query falla con "Query exceeded limit for bytes billed"; si supera la cuota
restante del mes, falla con "Quota exceeded: Your project exceeded quota for free query bytes
scanned". En ambos casos no se factura nada, pero no hay forma de leer desde el Sandbox una
columna cuya partición mensual estima más que la cuota, por más filtros de clustering que tenga
la query. Para probar sobre esas columnas está `httparchive.sample_data.pages_10k` (un mes,
~30 GB en total).

## Cómo consultar los `.parquet` ya bajados (sin límites, local)

```bash
duckdb -c "SELECT * FROM 'httparchive_crawl_pages/001-nombre-descriptivo.parquet' LIMIT 20;"

# combinar todos los parquet de una tabla con glob:
duckdb -c "SELECT * FROM 'bigquery/httparchive_crawl_pages/*.parquet' WHERE tecnologia = 'React' LIMIT 20;"

# combinar TODO lo bajado, de cualquier tabla:
duckdb -c "SELECT * FROM 'bigquery/**/*.parquet' LIMIT 20;"
```

## Ledger de cuota

`usage-log.csv` es el historial de todo lo corrido (fecha, proyecto, script,
GB estimados por el dry-run, GB facturados, job). La cuota se mide con `gb_billed`:
antes de lanzar una extracción grande, sumar esa columna del mes en curso y
compararla contra 1024 GB (el free tier mensual). El script ya lo hace
automáticamente al final de cada corrida. Las filas anteriores al 01/10/2026 se
completaron con `totalBytesBilled` de la metadata de cada job.
