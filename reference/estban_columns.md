# ESTBAN column layout and account dictionary

`estban_columns()` lists the columns of the monthly file for a level, in
file order, with their `snake_case` names. `estban_verbetes()` restricts
the list to the balance-sheet accounts (`VERBETE_*`), parsing the
three-digit 'COSIF' codes out of the column name. Some columns combine
several accounts (for instance `VERBETE_141 + VERBETE_142`); those have
more than one code in `codes` and `n_codes > 1`.

## Usage

``` r
estban_columns(level = c("agencia", "municipio"))

estban_verbetes(level = c("agencia", "municipio"))
```

## Arguments

- level:

  `"agencia"` (default) or `"municipio"`.

## Value

A tibble. `estban_columns()` has `position`, `column` (original name),
`name` (clean name) and `kind` (`"id"` or `"verbete"`).
`estban_verbetes()` has `column`, `name`, `codes` (character, codes
separated by `;`), `code` (first code, integer), `n_codes`, `side`
(`"ativo"` for codes below 400, `"passivo"` otherwise) and
`description`.

## Details

The dictionary is built from the January 2024 files (see
`data-raw/verbetes.R` in the source repository) and covers both levels,
which share the same accounts.

## Examples

``` r
estban_columns()[1:8, ]
#> # A tibble: 8 × 4
#>   position column                       name                         kind   
#>      <int> <chr>                        <chr>                        <chr>  
#> 1        1 #DATA_BASE                   data_base                    id     
#> 2        2 UF                           uf                           id     
#> 3        3 CODMUN                       codmun                       id     
#> 4        4 MUNICIPIO                    municipio                    id     
#> 5        5 CNPJ                         cnpj                         id     
#> 6        6 NOME_INSTITUICAO             nome_instituicao             id     
#> 7        7 AGENCIA                      agencia                      id     
#> 8        8 VERBETE_110_DISPONIBILIDADES verbete_110_disponibilidades verbete
v <- estban_verbetes()
v[v$code %in% c(160, 420, 432), c("name", "codes", "side")]
#> # A tibble: 3 × 3
#>   name                              codes side   
#>   <chr>                             <chr> <chr>  
#> 1 verbete_160_operacoes_de_credito  160   ativo  
#> 2 verbete_420_depositos_de_poupanca 420   passivo
#> 3 verbete_432_depositos_a_prazo     432   passivo
# Combined columns
v[v$n_codes > 1, c("codes", "n_codes")]
#> # A tibble: 0 × 2
#> # ℹ 2 variables: codes <chr>, n_codes <int>
```
