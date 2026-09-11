# Builds R/sysdata.rda with the column layout of both ESTBAN levels.
#
# The two header lines were taken from the January 2024 files
# (202401_ESTBAN_AG.CSV and 202401_ESTBAN.CSV), downloaded from
# https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/
# and saved as header_agencia.txt / header_municipio.txt (Latin-1, third
# line of each file). Re-run this script when the Central Bank changes the
# layout.

read_header <- function(path) {
  h <- readLines(path, n = 1L, encoding = "latin1", warn = FALSE)
  h <- iconv(h, from = "latin1", to = "UTF-8")
  cols <- strsplit(h, ";", fixed = TRUE)[[1]]
  cols <- trimws(gsub("\t", " ", cols))
  cols[nzchar(cols)]
}

.estban_layout <- list(
  agencia   = read_header("data-raw/header_agencia.txt"),
  municipio = read_header("data-raw/header_municipio.txt")
)
stopifnot(length(.estban_layout$agencia) == 53L, length(.estban_layout$municipio) == 54L)

usethis::use_data(.estban_layout, internal = TRUE, overwrite = TRUE)
