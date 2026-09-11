# Download one ESTBAN month

Downloads the monthly file for `ref`, trying each name variant from
[`estban_url()`](https://strategicprojects.github.io/estbanr/reference/estban_url.md),
unzips it when needed and returns the path to the CSV in the cache
directory. Months already in the cache are not downloaded again unless
`force = TRUE`.

## Usage

``` r
estban_download(
  ref,
  level = c("agencia", "municipio"),
  cache_dir = NULL,
  force = FALSE,
  timeout = 300,
  verbose = TRUE
)
```

## Arguments

- ref:

  Reference month as `AAAAMM` (integer, character or `Date`).

- level:

  `"agencia"` (one row per bank branch, the default) or `"municipio"`
  (one row per institution and municipality).

- cache_dir:

  Directory for downloaded files. See
  [`estban_cache_dir()`](https://strategicprojects.github.io/estbanr/reference/estban_cache_dir.md)
  for the resolution order; the default is a session folder under
  [`base::tempdir()`](https://rdrr.io/r/base/tempfile.html).

- force:

  Logical. Re-download even when the CSV is already cached.

- timeout:

  Seconds allowed for one download (default 300).

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

The path to the cached CSV (invisibly `NULL` when the month is not
published under any of the known names, with a warning).

## Examples

``` r
# \donttest{
# Needs network access to www.bcb.gov.br (about 2 MB); skipped when offline.
csv <- tryCatch(estban_download(202401, verbose = FALSE),
                error = function(e) NULL)
if (!is.null(csv)) {
  pe <- estban_read(csv, uf = "PE")
  nrow(pe)
}
#> [1] 464
# }
```
