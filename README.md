# Efecto causal de las migraciones de tecnología frontend sobre la experiencia de usuario real

Tesis de la Maestría en Ciencia de Datos del ITBA.

Alumno: Moccagatta, Nicolás (Leg. 106396). Director: Ariel Olaf Salgado Corrado. Co-Director: Carlos Sarraute.

Estima el efecto de las migraciones de tecnología frontend sobre Core Web Vitals (LCP, INP y CLS). El panel junta HTTP Archive, que detecta la tecnología de cada sitio, y Chrome UX Report, que publica la experiencia de usuarios reales de Chrome. Las dos fuentes están en BigQuery. El diseño es de diferencias en diferencias, robusto a tratamiento escalonado.

La [bitácora](https://nicomoccagatta.github.io/Tesis-MCD/) es el registro del trabajo, entrega por entrega. `index.html` abre `bitacora/bitacora.html`.

## Contenido

- `bitacora/`: bitácora (entregas del 22/08/2026 al 20/11/2026).
- `TP Latex/Project/`: propuesta escrita (`main.tex`).
- `Presentaciones/`: presentaciones del taller hasta el 02/10/2026.
- `analisis/`: análisis local sobre los Parquet (Python y DuckDB). Dependencias en `analisis/requirements.txt`.
- `bigquery/`: cada extracción queda como un `.sql` y su `.parquet`, con el costo en `bigquery/usage-log.csv`.

## Datos

Las queries leen datasets públicos de BigQuery: `httparchive.crawl.pages` y `chrome-ux-report`. Los resultados ya extraídos están en el repositorio. Volver a correr una query pide un proyecto de Google Cloud con acceso a esos datasets (`bigquery/run_query.sh`).

## Licencia

Copyright (c) 2026 Nicolás Moccagatta. Todos los derechos reservados (ver `LICENSE`).

El repositorio es público para que se pueda leer. No autoriza a copiarlo, publicarlo ni distribuirlo.

Los datos de HTTP Archive y de Chrome UX Report se usan según las condiciones de cada fuente. El catálogo de detección es el fork público [HTTPArchive/wappalyzer](https://github.com/HTTPArchive/wappalyzer).
