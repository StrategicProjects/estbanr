# Account (verbete) dictionary and column layout.

#' ESTBAN column layout and account dictionary
#'
#' `estban_columns()` lists the columns of the monthly file for a level, in
#' file order, with their `snake_case` names. `estban_verbetes()` restricts
#' the list to the balance-sheet accounts (`VERBETE_*`), parsing the
#' three-digit 'COSIF' codes out of the column name. Some columns combine
#' several accounts (for instance `VERBETE_141 + VERBETE_142`); those have
#' more than one code in `codes` and `n_codes > 1`.
#'
#' The dictionary is built from the January 2024 files (see
#' `data-raw/verbetes.R` in the source repository) and covers both levels,
#' which share the same accounts.
#'
#' @param level `"agencia"` (default) or `"municipio"`.
#'
#' @return A tibble. `estban_columns()` has `position`, `column` (original
#'   name), `name` (clean name) and `kind` (`"id"` or `"verbete"`).
#'   `estban_verbetes()` has `column`, `name`, `codes` (character, codes
#'   separated by `;`), `code` (first code, integer), `n_codes`, `side`
#'   (`"ativo"` for codes below 400, `"passivo"` otherwise) and
#'   `description`.
#' @export
#'
#' @examples
#' estban_columns()[1:8, ]
#' v <- estban_verbetes()
#' v[v$code %in% c(160, 420, 432), c("name", "codes", "side")]
#' # Combined columns
#' v[v$n_codes > 1, c("codes", "n_codes")]
estban_columns <- function(level = c("agencia", "municipio")) {
  level <- .level(level[[1]])
  cols  <- .estban_layout[[level]]
  tibble::tibble(
    position = seq_along(cols),
    column   = cols,
    name     = estban_clean_names(cols),
    kind     = ifelse(grepl("^VERBETE_", cols), "verbete", "id")
  )
}

#' @rdname estban_columns
#' @export
estban_verbetes <- function(level = c("agencia", "municipio")) {
  cols <- estban_columns(level)
  cols <- cols[cols$kind == "verbete", ]
  codes <- regmatches(cols$column, gregexpr("VERBETE_([0-9]{3})", cols$column))
  codes <- lapply(codes, function(x) sub("VERBETE_", "", x))
  first <- vapply(codes, function(x) as.integer(x[[1]]), integer(1))
  desc  <- vapply(cols$column, function(x) {
    # description of the first account in the column, title-cased
    d <- sub("^VERBETE_[0-9]{3}_", "", strsplit(x, " \\+ ", fixed = FALSE)[[1]][[1]])
    d <- gsub("_", " ", d)
    tolower(d)
  }, character(1), USE.NAMES = FALSE)
  tibble::tibble(
    column      = cols$column,
    name        = cols$name,
    codes       = vapply(codes, paste, character(1), collapse = ";"),
    code        = first,
    n_codes     = lengths(codes),
    side        = ifelse(first < 400L, "ativo", "passivo"),
    description = desc
  )
}
