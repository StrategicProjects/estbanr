# Changelog

## estbanr 0.1.0

Initial release.

- **Download and read.**
  [`estban_url()`](https://strategicprojects.github.io/estbanr/reference/estban_url.md)
  knows the file-name variants the Central Bank has used;
  [`estban_download()`](https://strategicprojects.github.io/estbanr/reference/estban_download.md)
  tries them in order, unzips and keeps an idempotent cache
  ([`estban_cache_dir()`](https://strategicprojects.github.io/estbanr/reference/estban_cache_dir.md):
  argument, then `ESTBANR_CACHE_DIR`, then option, then
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html));
  [`estban_read()`](https://strategicprojects.github.io/estbanr/reference/estban_read.md)
  parses the Latin-1, `;`-separated files into typed tibbles with
  `snake_case` names and an optional state filter;
  [`estban_fetch()`](https://strategicprojects.github.io/estbanr/reference/estban_fetch.md)
  does it for a range of months.
- **Layout and dictionary.**
  [`estban_columns()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
  and
  [`estban_verbetes()`](https://strategicprojects.github.io/estbanr/reference/estban_columns.md)
  describe the columns of both file families (`agencia`, `municipio`)
  and parse the COSIF account codes, including the combined columns.
- **Non-reports.**
  [`estban_flag_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_flag_nonreport.md)
  detects institution-months published with every account at zero;
  [`estban_impute_nonreport()`](https://strategicprojects.github.io/estbanr/reference/estban_impute_nonreport.md)
  interpolates interior gaps per institution, municipality and account
  without extrapolating;
  [`estban_by_municipality()`](https://strategicprojects.github.io/estbanr/reference/estban_by_municipality.md)
  aggregates to the municipality in wide or long form, imputing by
  default.
- A small real extract (four municipalities of PE and PB, January 2024)
  ships in `inst/extdata/` so examples, tests and vignettes run offline.
