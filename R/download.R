# Download layer: URL candidates, HTTP fetch with retry, cache, unzip.

.ESTBAN_BASE <- "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/"

#' Candidate download URLs for one ESTBAN month
#'
#' The Central Bank has changed the file naming over the years, so for a
#' given month more than one name may exist. The candidates are tried in
#' order by [estban_download()]; the first that answers `200` wins.
#'
#' @param ref Reference month as `AAAAMM` (integer, character or `Date`).
#' @param level `"agencia"` (one row per bank branch, the default) or
#'   `"municipio"` (one row per institution and municipality).
#'
#' @return A character vector of URLs, most likely first.
#' @export
#'
#' @examples
#' estban_url(202401)
#' estban_url("202401", level = "municipio")
estban_url <- function(ref, level = c("agencia", "municipio")) {
  ref   <- .ref_int(ref)
  level <- .level(level[[1]])
  names <- if (level == "agencia") {
    paste0(ref, c("_ESTBAN_AG.csv.zip", "_ESTBAN_AG.ZIP", "_ESTBAN_AG.csv"))
  } else {
    paste0(ref, c("_ESTBAN.csv.zip", "_ESTBAN.ZIP", "_ESTBAN.csv"))
  }
  paste0(.ESTBAN_BASE, level, "/", names)
}

#' Name of the cached CSV for a month
#' @noRd
.csv_name <- function(ref, level) {
  if (level == "agencia") sprintf("%d_ESTBAN_AG.CSV", ref) else sprintf("%d_ESTBAN.CSV", ref)
}

#' Perform one HTTP request. Isolated so tests can mock it.
#' @noRd
.estban_perform <- function(req) {
  httr2::req_perform(req)
}

#' Fetch one URL to a raw vector; NULL on 404/403, error on other failures
#' @noRd
.fetch_raw <- function(url, timeout = 300) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("estbanr (https://github.com/StrategicProjects/estbanr)") |>
    httr2::req_timeout(timeout) |>
    httr2::req_retry(max_tries = 3, backoff = function(i) 2 * i) |>
    httr2::req_error(is_error = function(resp) FALSE)
  resp <- tryCatch(.estban_perform(req), error = function(e) e)
  if (inherits(resp, "error")) {
    cli::cli_abort(c(
      "Could not reach {.url {url}}.",
      "x" = conditionMessage(resp),
      "i" = "Check your connection; the Central Bank site is sometimes slow."
    ))
  }
  status <- httr2::resp_status(resp)
  if (status %in% c(403L, 404L)) return(NULL)
  if (status >= 400L) {
    cli::cli_abort("HTTP {status} from {.url {url}}.")
  }
  httr2::resp_body_raw(resp)
}

#' Download one ESTBAN month
#'
#' Downloads the monthly file for `ref`, trying each name variant from
#' [estban_url()], unzips it when needed and returns the path to the CSV in
#' the cache directory. Months already in the cache are not downloaded
#' again unless `force = TRUE`.
#'
#' @inheritParams estban_url
#' @param cache_dir Directory for downloaded files. See [estban_cache_dir()]
#'   for the resolution order; the default is a session folder under
#'   [base::tempdir()].
#' @param force Logical. Re-download even when the CSV is already cached.
#' @param timeout Seconds allowed for one download (default 300).
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return The path to the cached CSV (invisibly `NULL` when the month is
#'   not published under any of the known names, with a warning).
#' @export
#'
#' @examples
#' \donttest{
#' # Needs network access to www.bcb.gov.br (about 2 MB); skipped when offline.
#' csv <- tryCatch(estban_download(202401, verbose = FALSE),
#'                 error = function(e) NULL)
#' if (!is.null(csv)) {
#'   pe <- estban_read(csv, uf = "PE")
#'   nrow(pe)
#' }
#' }
estban_download <- function(ref,
                            level = c("agencia", "municipio"),
                            cache_dir = NULL,
                            force = FALSE,
                            timeout = 300,
                            verbose = TRUE) {
  ref   <- .ref_int(ref)
  level <- .level(level[[1]])
  dir   <- estban_cache_dir(cache_dir)
  dest  <- file.path(dir, .csv_name(ref, level))

  if (file.exists(dest) && !isTRUE(force)) {
    if (verbose) cli::cli_alert_info("ESTBAN {ref} ({level}): using cached {.file {basename(dest)}}.")
    return(dest)
  }

  for (url in estban_url(ref, level)) {
    body <- .fetch_raw(url, timeout = timeout)
    if (is.null(body)) next
    if (verbose) cli::cli_alert_success("ESTBAN {ref} ({level}): downloaded {basename(url)} ({.estban_fmt_bytes(length(body))}).")
    if (grepl("\\.zip$", url, ignore.case = TRUE)) {
      zip <- tempfile(fileext = ".zip")
      on.exit(unlink(zip), add = TRUE)
      writeBin(body, zip)
      inner <- tryCatch(utils::unzip(zip, list = TRUE)$Name, error = function(e) NULL)
      if (is.null(inner) || length(inner) == 0) {
        cli::cli_warn("ESTBAN {ref}: {basename(url)} is not a readable zip; trying the next name.")
        next
      }
      exdir <- tempfile("estban-unzip-")
      utils::unzip(zip, files = inner[[1]], exdir = exdir)
      file.copy(file.path(exdir, inner[[1]]), dest, overwrite = TRUE)
      unlink(exdir, recursive = TRUE)
    } else {
      writeBin(body, dest)
    }
    return(dest)
  }

  cli::cli_warn("ESTBAN {ref} ({level}): not found under any known file name; probably not published yet.")
  invisible(NULL)
}

#' Human-readable byte sizes
#' @noRd
.estban_fmt_bytes <- function(n) {
  units <- c("B", "KB", "MB", "GB")
  i <- 1L
  while (n >= 1024 && i < length(units)) { n <- n / 1024; i <- i + 1L }
  paste0(format(round(n, 1), nsmall = if (i > 1) 1 else 0), " ", units[[i]])
}
