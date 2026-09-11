# Reading layer: Latin-1 CSV -> typed tibble.

#' Read an ESTBAN CSV file
#'
#' Reads a monthly ESTBAN file as published by the Central Bank: two title
#' lines to skip, `;` as separator, `Latin-1` encoding, one row per bank
#' branch (`level = "agencia"`) or per institution and municipality
#' (`level = "municipio"`). Account columns (`VERBETE_*`) are returned as
#' doubles in Brazilian reais; codes are kept as character to preserve
#' leading zeros.
#'
#' @param path Path to a CSV downloaded with [estban_download()] (or any
#'   file with the same layout).
#' @param uf Optional character vector of two-letter state codes to keep
#'   (e.g. `"PE"` or `c("PE", "PB")`). `NULL` keeps every state.
#' @param clean_names Logical. Convert column names to `snake_case` with
#'   [estban_clean_names()] (default `TRUE`). With `FALSE` the original
#'   upper-case names are kept, including the leading `#` of `#DATA_BASE`.
#' @param ref Optional reference month to record in the `ref` column. When
#'   `NULL` it is taken from the `DATA_BASE` column of the file.
#'
#' @return A tibble with a leading integer column `ref` (`AAAAMM`), the
#'   identification columns and one numeric column per account.
#' @export
#'
#' @examples
#' # A small real extract shipped with the package (PE and PB, January 2024)
#' f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
#' x <- estban_read(f)
#' x[, 1:8]
#'
#' # Keep one state and the original column names
#' pe <- estban_read(f, uf = "PE", clean_names = FALSE)
#' names(pe)[1:10]
estban_read <- function(path, uf = NULL, clean_names = TRUE, ref = NULL) {
  if (!file.exists(path)) cli::cli_abort("File not found: {.path {path}}.")

  raw <- readr::read_delim(
    path,
    delim = ";",
    skip = 2,
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(encoding = "latin1", decimal_mark = ",", grouping_mark = "."),
    trim_ws = TRUE,
    progress = FALSE,
    show_col_types = FALSE,
    name_repair = "minimal"
  )
  # Drop the empty trailing column created by a final ';' on data lines.
  raw <- raw[, nzchar(names(raw)), drop = FALSE]
  if (nrow(raw) == 0) return(.empty_estban(raw, clean_names))

  orig <- names(raw)
  nm   <- estban_clean_names(orig)
  names(raw) <- nm

  if (!"data_base" %in% nm || !"uf" %in% nm) {
    cli::cli_abort(c(
      "{.path {basename(path)}} does not have the ESTBAN layout.",
      "i" = "Expected columns {.code #DATA_BASE} and {.code UF} on the third line."
    ))
  }

  if (!is.null(uf)) {
    uf <- toupper(uf)
    raw <- raw[toupper(raw$uf) %in% uf, , drop = FALSE]
  }

  verb <- .verbete_cols(raw)
  for (v in verb) {
    raw[[v]] <- suppressWarnings(readr::parse_double(
      raw[[v]], locale = readr::locale(decimal_mark = ",", grouping_mark = ".")
    ))
  }
  for (v in intersect(c("codmun_ibge", "agen_esperadas", "agen_processadas"), nm)) {
    raw[[v]] <- suppressWarnings(as.integer(raw[[v]]))
  }
  if ("agencia" %in% nm) raw$agencia <- sub("^'", "", raw$agencia)

  ref <- if (is.null(ref)) suppressWarnings(as.integer(raw$data_base)) else rep(.ref_int(ref), nrow(raw))
  out <- tibble::as_tibble(raw)
  out <- tibble::add_column(out, ref = ref, .before = 1L)

  if (!isTRUE(clean_names)) {
    names(out) <- c("ref", orig)
  }
  out
}

#' Empty tibble with the right columns
#' @noRd
.empty_estban <- function(raw, clean_names) {
  nm <- if (isTRUE(clean_names)) estban_clean_names(names(raw)) else names(raw)
  out <- tibble::as_tibble(stats::setNames(rep(list(character()), length(nm)), nm))
  tibble::add_column(out, ref = integer(), .before = 1L)
}

#' Download and read a range of months
#'
#' Convenience wrapper around [estban_download()] and [estban_read()] for a
#' range of reference months. Months that are not published are skipped
#' with a warning, so the result may cover fewer months than requested;
#' check `unique(result$ref)`.
#'
#' @param start,end Reference months as `AAAAMM`; `end` defaults to `start`.
#' @inheritParams estban_download
#' @inheritParams estban_read
#'
#' @return A tibble with all requested months stacked (see [estban_read()]).
#' @export
#'
#' @examples
#' \donttest{
#' # Needs network access; about 2 MB per month.
#' x <- tryCatch(estban_fetch(202401, 202403, uf = "PE", verbose = FALSE),
#'               error = function(e) NULL)
#' if (!is.null(x)) table(x$ref)
#' }
estban_fetch <- function(start,
                         end = start,
                         uf = NULL,
                         level = c("agencia", "municipio"),
                         cache_dir = NULL,
                         clean_names = TRUE,
                         force = FALSE,
                         verbose = TRUE) {
  level <- .level(level[[1]])
  refs  <- .ref_seq(start, end)
  parts <- lapply(refs, function(r) {
    csv <- estban_download(r, level = level, cache_dir = cache_dir,
                           force = force, verbose = verbose)
    if (is.null(csv)) return(NULL)
    estban_read(csv, uf = uf, clean_names = clean_names, ref = r)
  })
  parts <- parts[!vapply(parts, is.null, logical(1))]
  if (length(parts) == 0) {
    cli::cli_warn("No ESTBAN month could be fetched for {min(refs)}..{max(refs)}.")
    return(invisible(NULL))
  }
  dplyr::bind_rows(parts)
}
