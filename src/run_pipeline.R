#!/usr/bin/env Rscript
# ============================================================
# run_pipeline.R — Orquestador del análisis de microbioma
# ============================================================
# Uso (terminal, desde la raíz del proyecto):
#
#   Rscript src/run_pipeline.R \
#       --metadata Data/Metadata.csv \
#       --taxonomy Data/raw/taxonomy-gg2.qza \
#       --table    Data/raw/table-final-clean.qza
#
# Si omites alguna ruta, se pedirá de forma interactiva.
#
# Opciones:
#   --metadata <ruta>   Metadata (CSV, separador ';')
#   --taxonomy <ruta>   Taxonomía QIIME2 (.qza)
#   --table    <ruta>   Tabla de abundancia QIIME2 (.qza)
#   --steps    <lista>  Pasos a ejecutar: all | 01 | 02 | 03 | 01,02,03
#   --output   <ruta>   Directorio de salida (default: outputs)
#   --help              Muestra esta ayuda
#
# Salida (en <output>/):
#   01_data_cleaning/  -> reporte Word + figuras PNG + RDS
#   02_descriptive/    -> reporte Word + figuras PNG
#   03_models/         -> reporte Word + figuras PNG
# ============================================================

if (!requireNamespace("rprojroot", quietly = TRUE)) {
  install.packages("rprojroot")
}

# --- Cargar helpers -----------------------------------------
local({
  root = rprojroot::find_root(rprojroot::is_rstudio_project | rprojroot::is_git_root)
  source(file.path(root, "src", "config.R"))
})

to_project_path = function(path, root) {
  if (grepl("^(/|[A-Za-z]:)", path)) {
    normalizePath(path, mustWork = FALSE)
  } else {
    normalizePath(file.path(root, path), mustWork = FALSE)
  }
}

# --- Parseo de argumentos -----------------------------------
parse_args = function() {
  args = commandArgs(trailingOnly = TRUE)
  opts = list(
    metadata = NA, taxonomy = NA, table = NA,
    steps = "all", output = "outputs"
  )
  i = 1
  while (i <= length(args)) {
    a = args[i]
    switch(a,
      "--metadata" = { opts$metadata = args[i + 1]; i = i + 2 },
      "--taxonomy" = { opts$taxonomy = args[i + 1]; i = i + 2 },
      "--table"    = { opts$table    = args[i + 1]; i = i + 2 },
      "--steps"    = { opts$steps    = args[i + 1]; i = i + 2 },
      "--output"   = { opts$output   = args[i + 1]; i = i + 2 },
      "--help"     = ,
      "-h"         = { print_usage(); quit(save = "no", status = 0) },
      { warning(sprintf("Argumento desconocido: %s", a)); i = i + 1 }
    )
  }
  opts
}

print_usage = function() {
  cat(
    "Uso: Rscript src/run_pipeline.R --metadata <ruta> --taxonomy <ruta> --table <ruta>\n",
    "Opciones:\n",
    "  --metadata <ruta>   Metadata (CSV, separador ';')\n",
    "  --taxonomy <ruta>   Taxonomía QIIME2 (.qza)\n",
    "  --table    <ruta>   Tabla de abundancia QIIME2 (.qza)\n",
    "  --steps    <lista>  Pasos: all | 01 | 02 | 03 | 01,02,03 (default: all)\n",
    "  --output   <ruta>   Directorio de salida (default: outputs)\n",
    "  --help              Muestra esta ayuda\n"
  )
}

# --- Rutas por argumento o interactivamente -----------------
resolve_inputs = function(opts, root) {
  ask = function(label, value, default) {
    if (!is.na(value) && nzchar(value)) {
      p = to_project_path(value, root)
    } else {
      cat(sprintf("\n[%s] Ruta (o Enter para %s): ", label, basename(default)))
      line = trimws(readLines(con = "stdin", n = 1, warn = FALSE))
      p = if (nzchar(line)) to_project_path(line, root) else default
    }
    cat(sprintf("  -> %s: %s\n", label, p))
    p
  }

  list(
    metadata = ask("metadata", opts$metadata,
                   file.path(root, "Data", "Metadata.csv")),
    taxonomy = ask("taxonomy", opts$taxonomy,
                   file.path(root, "Data", "raw", "taxonomy-gg2.qza")),
    table    = ask("table",    opts$table,
                   file.path(root, "Data", "raw", "table-final-clean.qza"))
  )
}

# --- Validación ---------------------------------------------
validate_inputs = function(inputs) {
  assert_file(inputs$metadata, "metadata")
  assert_file(inputs$taxonomy, "taxonomy")
  assert_file(inputs$table,    "table")
  invisible(TRUE)
}

# --- Pasos a ejecutar ---------------------------------------
resolve_steps = function(spec) {
  spec = tolower(spec)
  if (spec == "all") return(c("01", "02", "03"))
  steps = unique(strsplit(spec, ",")[[1]])
  steps = trimws(steps)
  bad = setdiff(steps, c("01", "02", "03"))
  if (length(bad)) stop("Pasos inválidos: ", paste(bad, collapse = ", "))
  steps[order(steps)]
}

# --- Render de un Rmd ---------------------------------------
render_step = function(rmd_path, out_dir, inputs, root) {
  fig_dir = file.path(out_dir, "figures")
  ensure_dirs(c(out_dir, fig_dir))

  Sys.setenv(
    PIPELINE_ROOT     = root,
    PIPELINE_OUT      = out_dir,
    PIPELINE_FIGDIR   = fig_dir,
    PIPELINE_METADATA = inputs$metadata,
    PIPELINE_TAXONOMY = inputs$taxonomy,
    PIPELINE_TABLE    = inputs$table
  )

  cat(sprintf("\n=== Renderizando %s ===\n", basename(rmd_path)))
  rmarkdown::render(
    input         = rmd_path,
    output_dir    = out_dir,
    knit_root_dir = root,
    quiet         = FALSE,
    envir         = globalenv()
  )
  cat(sprintf("=== Completado: %s ===\n", basename(rmd_path)))
}

# --- Main ---------------------------------------------------
main = function() {
  load_pipeline_libs()

  root = project_root()
  cat("Pipeline de análisis de microbioma\n")
  cat("Raíz del proyecto:", root, "\n")

  opts   = parse_args()
  inputs = resolve_inputs(opts, root)
  validate_inputs(inputs)

  steps  = resolve_steps(opts$steps)
  out_root = to_project_path(opts$output, root)
  ensure_dirs(out_root)

  code_dir = file.path(root, "notebooks")
  rmd_map = list(
    "01" = file.path(code_dir, "01_Data_Cleaning.Rmd"),
    "02" = file.path(code_dir, "02_Descriptive.Rmd"),
    "03" = file.path(code_dir, "03_Models.Rmd")
  )
  out_map = list(
    "01" = file.path(out_root, "01_data_cleaning"),
    "02" = file.path(out_root, "02_descriptive"),
    "03" = file.path(out_root, "03_models")
  )

  t0 = Sys.time()
  for (s in steps) {
    if (!file.exists(rmd_map[[s]])) {
      stop(sprintf("No existe el Rmd del paso %s: %s", s, rmd_map[[s]]))
    }
    render_step(rmd_map[[s]], out_map[[s]], inputs, root)
  }

  cat(sprintf("\nPipeline completado en %s\n",
              format(Sys.time() - t0, digits = 4)))
  cat("Salida en:", out_root, "\n")
}

main()
