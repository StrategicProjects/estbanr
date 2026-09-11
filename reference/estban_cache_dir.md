# Resolve the estbanr cache directory

The directory where downloaded ESTBAN files are kept. Resolution order:

## Usage

``` r
estban_cache_dir(cache_dir = NULL, create = TRUE)
```

## Arguments

- cache_dir:

  Optional directory path. When `NULL`, the resolution order above
  applies.

- create:

  Logical. Create the directory when it does not exist (default `TRUE`).

## Value

A normalised directory path (character scalar).

## Details

1.  the `cache_dir` argument;

2.  the `ESTBANR_CACHE_DIR` environment variable;

3.  the `estbanr.cache_dir` R option;

4.  a session-scoped folder under
    [`base::tempdir()`](https://rdrr.io/r/base/tempfile.html) (the
    default, so the package never writes outside the temporary directory
    unless you opt in).

Set one of the persistent options (2 or 3) to keep files across sessions
and avoid re-downloading months you already have.

## Examples

``` r
estban_cache_dir()
#> [1] "/tmp/Rtmp0jb7u7/estbanr-cache"

# Persistent cache for the current session only:
old <- options(estbanr.cache_dir = file.path(tempdir(), "estban-cache"))
estban_cache_dir()
#> [1] "/tmp/Rtmp0jb7u7/estban-cache"
options(old)
```
