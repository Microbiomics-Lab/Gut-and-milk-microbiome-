# Pipeline de Análisis de Microbioma

Orquestador que replica el análisis completo (limpieza → descriptivo →
modelos) a partir de **3 archivos de entrada**: metadata, taxonomía y
tabla de abundancia.

## Estructura

```
src/
├── run_pipeline.R   # Orquestador (pide las 3 rutas y renderiza)
├── config.R         # Helpers: rutas, validación, librerías
└── README.md        # Este archivo
```

La lógica de análisis vive en `Code/` (los 3 Rmd). El pipeline solo
coordina: inyecta las rutas, renderiza en orden y guarda todo.

## Uso

Desde la **raíz del proyecto**:

```bash
Rscript src/run_pipeline.R \
    --metadata Data/Metadata.csv \
    --taxonomy Data/raw/taxonomy-gg2.qza \
    --table    Data/raw/table-final-clean.qza
```

Si omites alguna ruta, se pedirá de forma interactiva en la terminal.

### Opciones

| Opción               | Descripción                                                    | Default                            |
| --------------------- | --------------------------------------------------------------- | ---------------------------------- |
| `--metadata <ruta>` | Metadata (CSV, separador `;`)                                 | `Data/Metadata.csv`              |
| `--taxonomy <ruta>` | Taxonomía QIIME2 (`.qza`)                                    | `Data/raw/taxonomy-gg2.qza`      |
| `--table <ruta>`    | Tabla de abundancia QIIME2 (`.qza`)                           | `Data/raw/table-final-clean.qza` |
| `--steps <lista>`   | Pasos a ejecutar: `all`, `01`, `02`, `03`, `01,02,03` | `all`                            |
| `--output <ruta>`   | Directorio de salida                                            | `outputs`                        |
| `--help`            | Muestra la ayuda                                                | —                                 |

### Ejemplos

Ejecutar solo la limpieza (paso 01):

```bash
Rscript src/run_pipeline.R --steps 01
```

Ejecutar descriptivo y modelos con datos propios:

```bash
Rscript src/run_pipeline.R \
    --metadata /ruta/a/mi_metadata.csv \
    --taxonomy /ruta/a/taxonomy.qza \
    --table    /ruta/a/table.qza \
    --steps 02,03 \
    --output outputs_mio
```

## Salida

Todo se guarda en `outputs/` (o el directorio indicado con `--output`):

```
outputs/
├── 01_data_cleaning/
│   ├── 01_Data_Cleaning.docx   # Reporte Word
│   └── figures/                # Figuras PNG
├── 02_descriptive/
│   ├── 02_Descriptive.docx
│   └── figures/
└── 03_models/
    ├── 03_Models.docx
    └── figures/
```

Además, el paso 01 genera los objetos intermedios (RDS) en
`Data/processed/`, que consumen los pasos 02 y 03.

## Notas

- **Orden de ejecución**: 01 -> 02 -> 03. El 02 y 03 dependen de los RDS
  que genera el 01. Si ejecutas solo `02` o `03`, asegúrate de que
  `Data/processed/` ya tenga los objetos.
- **Librerías**: cada Rmd carga sus propias librerías con `pacman`. El
  orquestador solo necesita `rmarkdown` y `knitr`.
- **Maaslin2**: el paso 03 lee resultados pre-calculados desde
  `Code/resultados_maaslin_heces/` y `Code/resultados_maaslin_leches/`.
