# Getting started with estbanr

## What ESTBAN is

**ESTBAN** (*Estatística Bancária Mensal por Município*) is the monthly
balance-sheet statistic that the Brazilian Central Bank publishes for
every bank branch in the country, aggregated from the accounting
document 4500. Each row carries the balances of about 45 accounts
(*verbetes*) of the COSIF chart of accounts, such as credit operations
(160), financing (162), rural credit (163), savings deposits (420) and
time deposits (432), for one branch (`agencia` files) or one institution
in one municipality (`municipio` files).

Because it is monthly, municipal and goes back to 1988, ESTBAN is the
only public source of credit and deposits at the municipal level in
Brazil. It is also a large, awkward download: one national CSV per
month, `;`-separated, Latin-1 encoded, with two title lines and file
names that changed over the years.

`estbanr` takes care of the mechanics:

| Step | Function |
|:---|:---|
| Find the right file name for a month | [`estban_url()`](https://strategicprojects.github.io/estbanr/reference/estban_url.md) |
| Download with an idempotent cache | [`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md) |
| Read the CSV into a typed tibble, optionally one state | [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md) |
| Download and read a range of months | [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md) |
| Understand the columns | [`estban_columns()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md), [`estban_verbetes()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md) |
| Detect and fix non-reported institution-months | [`estban_flag_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_flag_nonreport.md), [`estban_impute_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_impute_nonreport.md) |
| Aggregate to the municipality | [`estban_by_municipality()`](https://strategicprojects.github.io/estbanr/reference/estban_by_municipality.md) |

## Installation

``` r

# From CRAN (when available):
install.packages("estbanr")

# Development version:
# remotes::install_github("StrategicProjects/estbanr")
```

## Reading a file

The package ships a small real extract (Pernambuco and Paraíba, four
municipalities, January 2024) so you can try everything offline.

``` r

library(estbanr)

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
```

Column names are converted to `snake_case` and the accounts come back as
numbers in Brazilian reais:

``` r

x[1:3, c("municipio", "nome_instituicao", "verbete_160_operacoes_de_credito",
         "verbete_420_depositos_de_poupanca")]
#> # A tibble: 3 × 4
#>   municipio      nome_instituicao  verbete_160_operacoe…¹ verbete_420_deposito…²
#>   <chr>          <chr>                              <dbl>                  <dbl>
#> 1 CAMPINA GRANDE BCO DO BRASIL S.…              210615406               16223520
#> 2 CAMPINA GRANDE BCO DO BRASIL S.…              263710588              211436774
#> 3 CAMPINA GRANDE BCO DO BRASIL S.…              137724527               82406957
#> # ℹ abbreviated names: ¹​verbete_160_operacoes_de_credito,
#> #   ²​verbete_420_depositos_de_poupanca
```

Keep one state with `uf`, or the original upper-case names with
`clean_names = FALSE`:

``` r

pe <- estban_read(f, uf = "PE")
table(pe$municipio)
#> 
#>   CARUARU GARANHUNS 
#>        16         8
```

## The accounts

[`estban_verbetes()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
maps every account column to its COSIF code. Some columns combine
several accounts; those have `n_codes > 1`.

``` r

v <- estban_verbetes()
v[v$code %in% c(160, 162, 163, 420, 432), c("name", "codes", "side")]
#> # A tibble: 5 × 3
#>   name                                       codes side   
#>   <chr>                                      <chr> <chr>  
#> 1 verbete_160_operacoes_de_credito           160   ativo  
#> 2 verbete_162_financiamentos                 162   ativo  
#> 3 verbete_163_fin_rurais_agricul_cust_invest 163   ativo  
#> 4 verbete_420_depositos_de_poupanca          420   passivo
#> 5 verbete_432_depositos_a_prazo              432   passivo
v[v$n_codes > 1, c("codes", "n_codes")]
#> # A tibble: 0 × 2
#> # ℹ 2 variables: codes <chr>, n_codes <int>
```

## Downloading real months

[`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md)
fetches one month and returns the path of the cached CSV;
[`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
does that for a range and stacks the result. Files land in a session
folder under [`tempdir()`](https://rdrr.io/r/base/tempfile.html) unless
you set a persistent cache (see
[`?estban_cache_dir`](https://strategicprojects.github.io/estbanr/reference/estban_cache_dir.md)):

``` r

options(estbanr.cache_dir = "~/data/estban")   # persistent across sessions

x <- estban_fetch(202301, 202312, uf = "PE")
table(x$ref)
```

Each national file is about 2 MB compressed; a full year of a single
state takes a minute or two on a normal connection.

## From branches to municipalities

Most analyses want one row per municipality and month.
[`estban_by_municipality()`](https://strategicprojects.github.io/estbanr/reference/estban_by_municipality.md)
sums the accounts over the institutions and branches of each
municipality, after treating non-reported institution-months (see the
vignette *Non-reports and imputation*):

``` r

m <- estban_by_municipality(x, impute = FALSE)
m[, c("uf", "municipio", "ref", "verbete_160_operacoes_de_credito")]
#> # A tibble: 4 × 4
#>   uf    municipio         ref verbete_160_operacoes_de_credito
#>   <chr> <chr>           <int>                            <dbl>
#> 1 PB    CAMPINA GRANDE 202401                       4837276064
#> 2 PB    PATOS          202401                       1027864769
#> 3 PE    CARUARU        202401                       3368237459
#> 4 PE    GARANHUNS      202401                       1357380448
```

The long form is convenient for plotting and joins:

``` r

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
