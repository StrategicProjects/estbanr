# Internal utilities for estbanr. Not exported.

# -- Cache directory -----------------------------------------------------------

#' Resolve the estbanr cache directory
#'
#' The directory where downloaded ESTBAN files are kept. Resolution order:
#'
#' 1. the `cache_dir` argument;
#' 2. the `ESTBANR_CACHE_DIR` environment variable;
#' 3. the `estbanr.cache_dir` R option;
#' 4. a session-scoped folder under [base::tempdir()] (the default, so the
#'    package never writes outside the temporary directory unless you opt
#'    in).
#'
#' Set one of the persistent options (2 or 3) to keep files across sessions
#' and avoid re-downloading months you already have.
#'
#' @param cache_dir Optional directory path. When `NULL`, the resolution
#'   order above applies.
#' @param create Logical. Create the directory when it does not exist
#'   (default `TRUE`).
#'
#' @return A normalized directory path (character scalar).
#' @export
#'
#' @examples
#' estban_cache_dir()
#'
#' # Persistent cache for the current session only:
#' old <- options(estbanr.cache_dir = file.path(tempdir(), "estban-cache"))
#' estban_cache_dir()
#' options(old)
estban_cache_dir <- function(cache_dir = NULL, create = TRUE) {
  dir <- cache_dir %||%
    .nz(Sys.getenv("ESTBANR_CACHE_DIR")) %||%
    getOption("estbanr.cache_dir") %||%
    file.path(tempdir(), "estbanr-cache")
  dir <- path.expand(dir)
  if (create && !dir.exists(dir)) dir.create(dir, recursive = TRUE)
  normalizePath(dir, mustWork = FALSE)
}

#' NULL for empty strings (used by the cache-dir resolution)
#' @noRd
.nz <- function(x) if (is.null(x) || !nzchar(x)) NULL else x

# -- Reference month (AAAAMM) helpers -----------------------------------------

#' Validate and normalize a reference month to an integer AAAAMM
#' @noRd
.ref_int <- function(ref, arg = "ref") {
  if (inherits(ref, "Date")) ref <- format(ref, "%Y%m")
  ref <- suppressWarnings(as.integer(ref))
  ok <- !is.na(ref) & ref >= 198801L & (ref %% 100L) >= 1L & (ref %% 100L) <= 12L
  if (!all(ok)) {
    cli::cli_abort(
      "{.arg {arg}} must be a reference month in {.code AAAAMM} form (e.g. {.val 202401})."
    )
  }
  ref
}

#' Sequence of AAAAMM between two reference months (inclusive)
#' @noRd
.ref_seq <- function(start, end) {
  start <- .ref_int(start, "start")
  end   <- .ref_int(end, "end")
  if (end < start) cli::cli_abort("{.arg end} must not be earlier than {.arg start}.")
  d0 <- as.Date(sprintf("%d-%02d-01", start %/% 100L, start %% 100L))
  d1 <- as.Date(sprintf("%d-%02d-01", end %/% 100L, end %% 100L))
  as.integer(format(seq(d0, d1, by = "month"), "%Y%m"))
}

#' Level argument (file family) -> normalized value
#' @noRd
.level <- function(level) {
  rlang::arg_match0(level, c("agencia", "municipio"))
}

# -- Column names --------------------------------------------------------------

#' Normalize ESTBAN column names to snake_case
#'
#' Lower case, accents stripped, every run of non-alphanumeric characters
#' collapsed to a single underscore. Combined columns such as
#' `"VERBETE_141_... + VERBETE_142_..."` become one long name, so nothing is
#' lost and [estban_verbetes()] can map the name back to its account codes.
#'
#' @param x Character vector of column names.
#' @return Character vector.
#' @export
#'
#' @examples
#' estban_clean_names(c("#DATA_BASE", "VERBETE_160_OPERACOES_DE_CREDITO",
#'                      "VERBETE_174_PROV_P/_OPER_CREDITOS"))
estban_clean_names <- function(x) {
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x
}

#' Names of the account (verbete) columns in a data frame
#' @noRd
.verbete_cols <- function(df) {
  grep("^verbete_", names(df), value = TRUE, ignore.case = TRUE)
}

#' Abort unless `df` looks like an ESTBAN table read by this package
#' @noRd
.check_estban <- function(df, need = c("cnpj", "ref")) {
  miss <- setdiff(need, names(df))
  if (length(miss) > 0 || length(.verbete_cols(df)) == 0) {
    cli::cli_abort(c(
      "{.arg df} does not look like an ESTBAN table read with {.fn estban_read}.",
      "i" = "Expected columns {.val {need}} and at least one {.code verbete_*} column
             (use {.code clean_names = TRUE})."
    ))
  }
  invisible(TRUE)
}
