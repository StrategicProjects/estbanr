# Flag institution-months that were not reported

An institution can be present in an ESTBAN file with every account equal
to zero in every branch and municipality of the extract. That is not a
zero balance sheet: it is a **non-report** (the bank's return did not
make it into that month's file). A documented case is Banco Santander in
January to March 2025, zeroed in the whole country. Summing such rows
into a municipal total makes credit and deposits collapse for three
months and then jump back, which any time-series model reads as a real
shock.

## Usage

``` r
estban_flag_nonreport(df)
```

## Arguments

- df:

  A tibble from
  [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
  or
  [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
  with clean names.

## Value

`df` with an extra logical column `nonreport`.

## Details

`estban_flag_nonreport()` adds a logical column `nonreport` that is
`TRUE` for every row of an institution-month whose accounts sum to zero
across the whole table. Run it on the largest extract you have (ideally
a state or the country), because the test is "zero everywhere in the
data", and a single municipality can legitimately have a dormant branch.

## Examples

``` r
f <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
x <- estban_read(f)
x <- estban_flag_nonreport(x)
table(x$nonreport)
#> 
#> FALSE 
#>    51 

# A synthetic non-report: zero every account of one bank in one month
y <- x
bank <- y$cnpj == y$cnpj[[1]]
y[bank, grep("^verbete_", names(y))] <- 0
table(estban_flag_nonreport(y)$nonreport, y$cnpj == y$cnpj[[1]])
#>        
#>         FALSE TRUE
#>   FALSE    39    0
#>   TRUE      0   12
```
