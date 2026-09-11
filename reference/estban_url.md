# Candidate download URLs for one ESTBAN month

The Central Bank has changed the file naming over the years, so for a
given month more than one name may exist. The candidates are tried in
order by
[`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md);
the first that answers `200` wins.

## Usage

``` r
estban_url(ref, level = c("agencia", "municipio"))
```

## Arguments

- ref:

  Reference month as `AAAAMM` (integer, character or `Date`).

- level:

  `"agencia"` (one row per bank branch, the default) or `"municipio"`
  (one row per institution and municipality).

## Value

A character vector of URLs, most likely first.

## Examples

``` r
estban_url(202401)
#> [1] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/agencia/202401_ESTBAN_AG.csv.zip"
#> [2] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/agencia/202401_ESTBAN_AG.ZIP"    
#> [3] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/agencia/202401_ESTBAN_AG.csv"    
estban_url("202401", level = "municipio")
#> [1] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/municipio/202401_ESTBAN.csv.zip"
#> [2] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/municipio/202401_ESTBAN.ZIP"    
#> [3] "https://www.bcb.gov.br/content/estatisticas/estatistica_bancaria_estban/municipio/202401_ESTBAN.csv"    
```
