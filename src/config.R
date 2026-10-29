# ============================================================
# config.R — Configuración y helpers del pipeline
# ============================================================
# Centraliza:
#   - Ruta raíz del proyecto
#   - Lectura de variables de entorno (inyectadas por run_pipeline.R)
#   - Validación de entradas
#   - Creación de directorios de salida
#   - Carga de librerías del orquestador
#
# Este archivo NO contiene lógica de análisis; esa vive en los
# tres Rmd de Code/ (01, 02, 03).
# ============================================================

`%||%` = function(a, b) if (is.null(a)) b else a

# --- Ruta raíz del proyecto ---------------------------------
project_root = function() {
  root = Sys.getenv("PIPELINE_ROOT", unset = "")
  if (nzchar(root)) return(normalizePath(root))
  rprojroot::find_root(rprojroot::is_rstudio_project | rprojroot::is_git_root)
}

# --- Ruta de entrada desde variable de entorno --------------
input_path = function(env_var, default) {
  p = Sys.getenv(env_var, unset = "")
  if (nzchar(p)) normalizePath(p, mustWork = FALSE) else default
}

# --- Validación de archivos ---------------------------------
assert_file = function(path, label) {
  if (!file.exists(path)) {
    stop(sprintf("[%s] El archivo no existe: %s", label, path), call. = FALSE)
  }
  invisible(path)
}

# --- Creación de directorios --------------------------------
ensure_dirs = function(paths) {
  for (p in paths) {
    if (!dir.exists(p)) dir.create(p, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(NULL)
}

# --- Carga de librerías del orquestador ---------------------
load_pipeline_libs = function() {
  needed = c("rmarkdown", "knitr", "rprojroot")
  missing = needed[!sapply(needed, requireNamespace, quietly = TRUE)]
  if (length(missing)) {
    message("Instalando librerías del orquestador: ",
            paste(missing, collapse = ", "))
    install.packages(missing)
  }
  for (p in needed) {
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
  
  # Si Pandoc no está en el PATH, buscar la versión de RStudio
  if (!rmarkdown::pandoc_available()) {
    rstudio_pandoc_paths = c(
      "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools",
      "C:/Program Files/RStudio/bin/pandoc",
      file.path(Sys.getenv("LOCALAPPDATA"), "Programs/RStudio/resources/app/bin/quarto/bin/tools")
    )
    for (path in rstudio_pandoc_paths) {
      if (dir.exists(path)) {
        Sys.setenv(RSTUDIO_PANDOC = path)
        break
      }
    }
  }
  
  if (!rmarkdown::pandoc_available()) {
    stop("Pandoc no está disponible. Instálalo o agrégalo al PATH del sistema.", call. = FALSE)
  }
  
  invisible(NULL)
}
