# Download and read a range of months

Convenience wrapper around
[`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md)
and
[`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
for a range of reference months. Months that are not published are
skipped with a warning, so the result may cover fewer months than
requested; check `unique(result$ref)`.

## Usage

``` r
estban_fetch(
  start,
  end = start,
  uf = NULL,
  level = c("agencia", "municipio"),
  cache_dir = NULL,
  clean_names = TRUE,
  force = FALSE,
  verbose = TRUE
)
```

## Arguments

- start, end:

  Reference months as `AAAAMM`; `end` defaults to `start`.

- uf:

  Optional character vector of two-letter state codes to keep (e.g.
  `"PE"` or `c("PE", "PB")`). `NULL` keeps every state.

- level:

  `"agencia"` (one row per bank branch, the default) or `"municipio"`
  (one row per institution and municipality).

- cache_dir:

  Directory for downloaded files. See
  [`estban_cache_dir()`](https://strategicprojects.github.io/estbanr/reference/estban_cache_dir.md)
  for the resolution order; the default is a session folder under
  [`base::tempdir()`](https://rdrr.io/r/base/tempfile.html).

- clean_names:

  Logical. Convert column names to `snake_case` with
  [`estban_clean_names()`](https://strategicprojects.github.io/estbanr/reference/estban_clean_names.md)
  (default `TRUE`). With `FALSE` the original upper-case names are kept,
  including the leading `#` of `#DATA_BASE`.

- force:

  Logical. Re-download even when the CSV is already cached.

- verbose:

  Logical. Emit progress messages (default `TRUE`).

## Value

A tibble with all requested months stacked (see
[`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)).

## Examples

``` r
# \donttest{
# Needs network access; about 2 MB per month.
x <- tryCatch(estban_fetch(202401, 202403, uf = "PE", verbose = FALSE),
              error = function(e) NULL)
if (!is.null(x)) table(x$ref)
#> 
#> 202401 202402 202403 
#>    464    463    464 
# }
```
