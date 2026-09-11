#' @keywords internal
"_PACKAGE"

#' @importFrom rlang %||% .data
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr bind_rows
NULL

# Column names used inside dplyr pipelines (avoid R CMD check NOTEs).
utils::globalVariables(c(
  "cnpj", "codmun_ibge", "municipio", "nome_instituicao", "nonreport",
  "ref", "uf", "verbete", "value", ".tot", ".idx"
))
