# Normalise ESTBAN column names to snake_case

Lower case, accents stripped, every run of non-alphanumeric characters
collapsed to a single underscore. Combined columns such as
`"VERBETE_141_... + VERBETE_142_..."` become one long name, so nothing
is lost and
[`estban_verbetes()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
can map the name back to its account codes.

## Usage

``` r
estban_clean_names(x)
```

## Arguments

- x:

  Character vector of column names.

## Value

Character vector.

## Examples

``` r
estban_clean_names(c("#DATA_BASE", "VERBETE_160_OPERACOES_DE_CREDITO",
                     "VERBETE_174_PROV_P/_OPER_CREDITOS"))
#> [1] "data_base"                        "verbete_160_operacoes_de_credito"
#> [3] "verbete_174_prov_p_oper_creditos"
```
