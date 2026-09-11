# Non-report detection, imputation and municipal aggregation.

#' Flag institution-months that were not reported
#'
#' An institution can be present in an ESTBAN file with every account equal
#' to zero in every branch and municipality of the extract. That is not a
#' zero balance sheet: it is a **non-report** (the bank's return did not
#' make it into that month's file). A documented case is Banco Santander in
#' January to March 2025, zeroed in the whole country. Summing such rows
#' into a municipal total makes credit and deposits collapse for three
#' months and then jump back, which any time-series model reads as a real
#' shock.
#'
#' `estban_flag_nonreport()` adds a logical column `nonreport` that is
#' `TRUE` for every row of an institution-month whose accounts sum to zero
#' across the whole table. Run it on the largest extract you have (ideally a
#' state or the country), because the test is "zero everywhere in the
#' data", and a single municipality can legitimately have a dormant branch.
#'
#' @param df A tibble from [estban_read()] or [estban_fetch()] with clean
#'   names.
#'
#' @return `df` with an extra logical column `nonreport`.
#' @export
#'
#' @examples
#' f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
#' x <- estban_read(f)
#' x <- estban_flag_nonreport(x)
#' table(x$nonreport)
#'
#' # A synthetic non-report: zero every account of one bank in one month
#' y <- x
#' bank <- y$cnpj == y$cnpj[[1]]
#' y[bank, grep("^verbete_", names(y))] <- 0
#' table(estban_flag_nonreport(y)$nonreport, y$cnpj == y$cnpj[[1]])
estban_flag_nonreport <- function(df) {
  .check_estban(df)
  verb <- .verbete_cols(df)
  tot  <- rowSums(abs(as.matrix(df[verb])), na.rm = TRUE)
  key  <- paste(df$cnpj, df$ref)
  tot_by_key <- tapply(tot, key, sum)
  df$nonreport <- unname(tot_by_key[key] == 0)
  df
}

#' Impute non-reported institution-months
#'
#' Treats every institution-month flagged by [estban_flag_nonreport()] as
#' missing and fills **interior** gaps by linear interpolation along the
#' monthly series of each (institution, municipality, account). Gaps at
#' the start or end of a series are left as `NA` (no extrapolation), so a
#' bank that stopped reporting last month stays missing until the file is
#' revised, instead of being invented.
#'
#' Rows are first summed to one row per institution and municipality
#' (branches of the same bank in the same city are added), because that is
#' the level at which the interpolation is meaningful and stable.
#'
#' @param df A tibble from [estban_read()] or [estban_fetch()] covering
#'   several months (interpolation needs neighbours). The `nonreport`
#'   column is computed when absent.
#'
#' @return A tibble with one row per `cnpj`, `codmun_ibge` and `ref`, the
#'   identification columns, the account columns (imputed where possible)
#'   and an integer column `imputed` with the number of accounts filled in
#'   that row. A message reports how many institution-months were treated.
#' @export
#'
#' @examples
#' # Three months of a two-bank, one-city extract, with bank B zeroed in the
#' # middle month. See vignette("nonreport-imputation") for the full story.
#' f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
#' m1 <- estban_read(f, uf = "PE")
#' m2 <- m1; m2$ref <- 202402L
#' m3 <- m1; m3$ref <- 202403L
#' verb <- grep("^verbete_", names(m1))
#' m2[m2$cnpj == "60746948", verb] <- 0          # Bradesco "vanishes" in February
#' m3[, verb] <- m3[, verb] * 1.10               # and everything grows 10% by March
#' x <- rbind(m1, m2, m3)
#' imp <- estban_impute_nonreport(x)
#' imp[imp$cnpj == "60746948" & imp$municipio == "CARUARU",
#'     c("ref", "verbete_160_operacoes_de_credito", "imputed")]
estban_impute_nonreport <- function(df) {
  .check_estban(df, need = c("cnpj", "ref", "codmun_ibge"))
  if (!"nonreport" %in% names(df)) df <- estban_flag_nonreport(df)
  verb <- .verbete_cols(df)

  n_nr <- length(unique(paste(df$cnpj, df$ref)[df$nonreport]))
  if (n_nr > 0) {
    cli::cli_alert_info("{n_nr} institution-month{?s} flagged as non-report; interpolating interior gaps.")
  }

  # NA-ify the non-reports, then collapse branches to institution x municipality.
  for (v in verb) df[[v]][df$nonreport] <- NA_real_
  id_cols <- intersect(c("uf", "codmun", "municipio", "nome_instituicao"), names(df))
  agg <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c("cnpj", "codmun_ibge", "ref")))) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(id_cols), dplyr::first),
      dplyr::across(dplyr::all_of(verb), ~ if (all(is.na(.x))) NA_real_ else sum(.x, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    dplyr::mutate(.idx = (ref %/% 100L) * 12L + (ref %% 100L)) |>
    dplyr::arrange(cnpj, codmun_ibge, .idx)

  was_na <- is.na(as.matrix(agg[verb]))
  agg <- agg |>
    dplyr::group_by(cnpj, codmun_ibge) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(verb), ~ .interp_interior(.idx, .x))) |>
    dplyr::ungroup()
  now_ok <- !is.na(as.matrix(agg[verb]))
  agg$imputed <- as.integer(rowSums(was_na & now_ok))
  agg$.idx <- NULL

  agg[, c("ref", "cnpj", "codmun_ibge", id_cols, verb, "imputed")]
}

#' Linear interpolation of interior NAs (no extrapolation at the edges)
#' @noRd
.interp_interior <- function(idx, y) {
  ok <- is.finite(y)
  if (sum(ok) < 2L) return(y)
  yi <- stats::approx(idx[ok], y[ok], xout = idx, rule = 1)$y
  ifelse(ok, y, yi)
}

#' Aggregate ESTBAN to the municipality
#'
#' Sums every account over the institutions (and branches) of each
#' municipality and month. With `impute = TRUE` (the default) non-reported
#' institution-months are interpolated first with
#' [estban_impute_nonreport()], so the municipal series does not collapse
#' when a bank is missing from a file.
#'
#' @inheritParams estban_impute_nonreport
#' @param impute Logical. Interpolate non-reports before summing (default
#'   `TRUE`). With `FALSE` the raw rows are summed as published.
#' @param long Logical. Return one row per municipality, month and account
#'   (`verbete`, `value`) instead of one column per account (default
#'   `FALSE`).
#'
#' @return A tibble keyed by `uf`, `codmun_ibge`, `municipio` and `ref`.
#'   In wide form the account columns follow; in long form the columns
#'   `verbete` (clean column name) and `value` follow.
#' @export
#'
#' @examples
#' f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
#' x <- estban_read(f)
#' m <- estban_by_municipality(x, impute = FALSE)
#' m[, c("uf", "municipio", "ref", "verbete_160_operacoes_de_credito",
#'       "verbete_420_depositos_de_poupanca")]
#'
#' head(estban_by_municipality(x, impute = FALSE, long = TRUE))
estban_by_municipality <- function(df, impute = TRUE, long = FALSE) {
  .check_estban(df, need = c("cnpj", "ref", "codmun_ibge"))
  if (isTRUE(impute)) df <- estban_impute_nonreport(df)
  verb <- .verbete_cols(df)
  id_cols <- intersect(c("uf", "municipio"), names(df))
  out <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c("codmun_ibge", "ref")))) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(id_cols), dplyr::first),
      dplyr::across(dplyr::all_of(verb), ~ sum(.x, na.rm = TRUE)),
      .groups = "drop"
    )
  out <- out[, c(id_cols, "codmun_ibge", "ref", verb)]
  if (!isTRUE(long)) return(out)
  keys <- out[, c(id_cols, "codmun_ibge", "ref")]
  parts <- lapply(verb, function(v) {
    k <- keys
    k$verbete <- v
    k$value <- out[[v]]
    k
  })
  dplyr::bind_rows(parts) |> dplyr::arrange(codmun_ibge, ref, verbete)
}
