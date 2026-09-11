# Aggregate ESTBAN to the municipality

Sums every account over the institutions (and branches) of each
municipality and month. With `impute = TRUE` (the default) non-reported
institution-months are interpolated first with
[`estban_impute_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_impute_nonreport.md),
so the municipal series does not collapse when a bank is missing from a
file.

## Usage

``` r
estban_by_municipality(df, impute = TRUE, long = FALSE)
```

## Arguments

- df:

  A tibble from
  [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
  or
  [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
  covering several months (interpolation needs neighbours). The
  `nonreport` column is computed when absent.

- impute:

  Logical. Interpolate non-reports before summing (default `TRUE`). With
  `FALSE` the raw rows are summed as published.

- long:

  Logical. Return one row per municipality, month and account
  (`verbete`, `value`) instead of one column per account (default
  `FALSE`).

## Value

A tibble keyed by `uf`, `codmun_ibge`, `municipio` and `ref`. In wide
form the account columns follow; in long form the columns `verbete`
(clean column name) and `value` follow.

## Examples

``` r
f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
x <- estban_read(f)
m <- estban_by_municipality(x, impute = FALSE)
m[, c("uf", "municipio", "ref", "verbete_160_operacoes_de_credito",
      "verbete_420_depositos_de_poupanca")]
#> # A tibble: 4 × 5
#>   uf    municipio         ref verbete_160_operacoes_de_…¹ verbete_420_deposito…²
#>   <chr> <chr>           <int>                       <dbl>                  <dbl>
#> 1 PB    CAMPINA GRANDE 202401                  4837276064             1969997618
#> 2 PB    PATOS          202401                  1027864769              498697617
#> 3 PE    CARUARU        202401                  3368237459             1330643618
#> 4 PE    GARANHUNS      202401                  1357380448              660955066
#> # ℹ abbreviated names: ¹​verbete_160_operacoes_de_credito,
#> #   ²​verbete_420_depositos_de_poupanca

head(estban_by_municipality(x, impute = FALSE, long = TRUE))
#> # A tibble: 6 × 6
#>   uf    municipio      codmun_ibge    ref verbete                          value
#>   <chr> <chr>                <int>  <int> <chr>                            <dbl>
#> 1 PB    CAMPINA GRANDE     2504009 202401 verbete_110_disponibilidades    5.11e7
#> 2 PB    CAMPINA GRANDE     2504009 202401 verbete_111_caixa               5.10e7
#> 3 PB    CAMPINA GRANDE     2504009 202401 verbete_112_depositos_bancarios 4.74e4
#> 4 PB    CAMPINA GRANDE     2504009 202401 verbete_113_bacen_reserv_banc_… 0     
#> 5 PB    CAMPINA GRANDE     2504009 202401 verbete_120_aplic_interfinanc_… 0     
#> 6 PB    CAMPINA GRANDE     2504009 202401 verbete_130_tit_e_val_mob_e_in… 7.44e6
```
