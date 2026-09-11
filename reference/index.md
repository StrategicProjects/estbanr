# Package index

## Download and read

From the Central Bank site to a typed tibble.

- [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
  : Download and read a range of months
- [`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md)
  : Download one ESTBAN month
- [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
  : Read an ESTBAN CSV file
- [`estban_url()`](https://strategicprojects.github.io/estbanr/reference/estban_url.md)
  : Candidate download URLs for one ESTBAN month

## Layout and accounts

Column layout of the files and the COSIF account dictionary.

- [`estban_columns()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
  [`estban_verbetes()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
  : ESTBAN column layout and account dictionary
- [`estban_clean_names()`](https://strategicprojects.github.io/estbanr/reference/estban_clean_names.md)
  : Normalize ESTBAN column names to snake_case

## Non-reports and aggregation

Detect institution-months that were not reported, impute them, and
aggregate to municipalities.

- [`estban_flag_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_flag_nonreport.md)
  : Flag institution-months that were not reported
- [`estban_impute_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_impute_nonreport.md)
  : Impute non-reported institution-months
- [`estban_by_municipality()`](https://strategicprojects.github.io/estbanr/reference/estban_by_municipality.md)
  : Aggregate ESTBAN to the municipality

## Cache

- [`estban_cache_dir()`](https://strategicprojects.github.io/estbanr/reference/estban_cache_dir.md)
  : Resolve the estbanr cache directory

## Package

- [`estbanr`](https://strategicprojects.github.io/estbanr/reference/estbanr-package.md)
  [`estbanr-package`](https://strategicprojects.github.io/estbanr/reference/estbanr-package.md)
  : estbanr: Access 'ESTBAN' Monthly Banking Statistics by Municipality
  from the Brazilian Central Bank
