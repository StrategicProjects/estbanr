# estbanr 0.1.0

Initial release.

* **Download and read.** `estban_url()` knows the file-name variants the
  Central Bank has used; `estban_download()` tries them in order, unzips
  and keeps an idempotent cache (`estban_cache_dir()`: argument, then
  `ESTBANR_CACHE_DIR`, then option, then `tempdir()`); `estban_read()`
  parses the Latin-1, `;`-separated files into typed tibbles with
  `snake_case` names and an optional state filter; `estban_fetch()` does
  it for a range of months.
* **Layout and dictionary.** `estban_columns()` and `estban_verbetes()`
  describe the columns of both file families (`agencia`, `municipio`) and
  parse the COSIF account codes, including the combined columns.
* **Non-reports.** `estban_flag_nonreport()` detects institution-months
  published with every account at zero; `estban_impute_nonreport()`
  interpolates interior gaps per institution, municipality and account
  without extrapolating; `estban_by_municipality()` aggregates to the
  municipality in wide or long form, imputing by default.
* A small real extract (four municipalities of PE and PB, January 2024)
  ships in `inst/extdata/` so examples, tests and vignettes run offline.
