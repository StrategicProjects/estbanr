# Read an ESTBAN CSV file

Reads a monthly ESTBAN file as published by the Central Bank: two title
lines to skip, `;` as separator, `Latin-1` encoding, one row per bank
branch (`level = "agencia"`) or per institution and municipality
(`level = "municipio"`). Account columns (`VERBETE_*`) are returned as
doubles in Brazilian reais; codes are kept as character to preserve
leading zeros.

## Usage

``` r
estban_read(path, uf = NULL, clean_names = TRUE, ref = NULL)
```

## Arguments

- path:

  Path to a CSV downloaded with
  [`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md)
  (or any file with the same layout).

- uf:

  Optional character vector of two-letter state codes to keep (e.g.
  `"PE"` or `c("PE", "PB")`). `NULL` keeps every state.

- clean_names:

  Logical. Convert column names to `snake_case` with
  [`estban_clean_names()`](https://strategicprojects.github.io/estbanr/reference/estban_clean_names.md)
  (default `TRUE`). With `FALSE` the original upper-case names are kept,
  including the leading `#` of `#DATA_BASE`.

- ref:

  Optional reference month to record in the `ref` column. When `NULL` it
  is taken from the `DATA_BASE` column of the file.

## Value

A tibble with a leading integer column `ref` (`AAAAMM`), the
identification columns and one numeric column per account.

## Examples

``` r
# A small real extract shipped with the package (PE and PB, January 2024)
f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
x <- estban_read(f)
x[, 1:8]
#> # A tibble: 51 × 8
#>       ref data_base uf    codmun municipio      cnpj    nome_instituicao agencia
#>     <int> <chr>     <chr> <chr>  <chr>          <chr>   <chr>            <chr>  
#>  1 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  2 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  3 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  4 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  5 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  6 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  7 202401 202401    PB    5366   CAMPINA GRANDE 000000… BCO DO BRASIL S… 000000…
#>  8 202401 202401    PB    5366   CAMPINA GRANDE 003603… CAIXA ECONOMICA… 003603…
#>  9 202401 202401    PB    5366   CAMPINA GRANDE 003603… CAIXA ECONOMICA… 003603…
#> 10 202401 202401    PB    5366   CAMPINA GRANDE 003603… CAIXA ECONOMICA… 003603…
#> # ℹ 41 more rows

# Keep one state and the original column names
pe <- estban_read(f, uf = "PE", clean_names = FALSE)
names(pe)[1:10]
#>  [1] "ref"                          "#DATA_BASE"                  
#>  [3] "UF"                           "CODMUN"                      
#>  [5] "MUNICIPIO"                    "CNPJ"                        
#>  [7] "NOME_INSTITUICAO"             "AGENCIA"                     
#>  [9] "VERBETE_110_DISPONIBILIDADES" "VERBETE_111_CAIXA"           
```
