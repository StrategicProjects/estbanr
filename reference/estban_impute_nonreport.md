# Impute non-reported institution-months

Treats every institution-month flagged by
[`estban_flag_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_flag_nonreport.md)
as missing and fills **interior** gaps by linear interpolation along the
monthly series of each (institution, municipality, account). Gaps at the
start or end of a series are left as `NA` (no extrapolation), so a bank
that stopped reporting last month stays missing until the file is
revised, instead of being invented.

## Usage

``` r
estban_impute_nonreport(df)
```

## Arguments

- df:

  A tibble from
  [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
  or
  [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
  covering several months (interpolation needs neighbours). The
  `nonreport` column is computed when absent.

## Value

A tibble with one row per `cnpj`, `codmun_ibge` and `ref`, the
identification columns, the account columns (imputed where possible) and
an integer column `imputed` with the number of accounts filled in that
row. A message reports how many institution-months were treated.

## Details

Rows are first summed to one row per institution and municipality
(branches of the same bank in the same city are added), because that is
the level at which the interpolation is meaningful and stable.

## Examples

``` r
# Three months of a two-bank, one-city extract, with bank B zeroed in the
# middle month. See vignette("nonreport-imputation") for the full story.
f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
m1 <- estban_read(f, uf = "PE")
m2 <- m1; m2$ref <- 202402L
m3 <- m1; m3$ref <- 202403L
verb <- grep("^verbete_", names(m1))
m2[m2$cnpj == "60746948", verb] <- 0          # Bradesco "vanishes" in February
m3[, verb] <- m3[, verb] * 1.10               # and everything grows 10% by March
x <- rbind(m1, m2, m3)
imp <- estban_impute_nonreport(x)
#> ℹ 1 institution-month flagged as non-report; interpolating interior gaps.
imp[imp$cnpj == "60746948" & imp$municipio == "CARUARU",
    c("ref", "verbete_160_operacoes_de_credito", "imputed")]
#> # A tibble: 3 × 3
#>      ref verbete_160_operacoes_de_credito imputed
#>    <int>                            <dbl>   <int>
#> 1 202401                        23110341        0
#> 2 202402                        24265858.      45
#> 3 202403                        25421375.       0
```
