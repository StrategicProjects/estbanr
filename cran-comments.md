## Resubmission

This is a resubmission of the first release, addressing the CRAN review of
2026-09-22:

* The `Title` was shortened to 61 characters.
* Single quotes in `Title` and `Description` are now used only around
  package, software and API names; they were removed from acronyms
  (ESTBAN, COSIF, CSV) and from proper names (Banco Central do Brasil,
  Latin-1).
* Every acronym in the `Description` is now spelled out: ESTBAN, COSIF and
  CSV.

Version is 0.1.1 because a download fix (a CSV served under a `.zip` name
by the Central Bank) landed between the two submissions; see `NEWS.md`.

## Submission summary

`estbanr 0.1.1` — first release.

The package downloads, reads and tidies the ESTBAN files (monthly banking
statistics by municipality) published by the Brazilian Central Bank, and
provides tools to detect and impute institution-months that were published
with every account equal to zero (non-reports).

## Test environments

* local macOS (arm64), R 4.6.0 — `R CMD check --as-cran`
* GitHub Actions `R-CMD-check` workflow (macOS, Windows, Ubuntu; R devel,
  release and oldrel-1)

## R CMD check results

```
0 errors | 0 warnings | 0 notes
```

(Locally a single NOTE may appear — "Skipping checking HTML validation:
'tidy' doesn't look like recent enough HTML Tidy" — which reflects the
`tidy` binary on the test machine, not the package.)

## Network access in tests and examples

The package is a client for files on `www.bcb.gov.br`.

* Tests under `tests/testthat/` are network-free: the single function that
  performs an HTTP request (`.estban_perform()`) is mocked with
  `testthat::local_mocked_bindings()`, and the zip payloads are built
  from the fixture shipped in `inst/extdata/`.
* Examples that need the network are wrapped in `\donttest{}` and in
  `tryCatch()`, so they never fail the check when the host is unreachable.
  All other examples run on the shipped fixture in well under 5 seconds.
* Vignettes evaluate only offline code (the fixture); download calls are
  shown with `eval = FALSE`.

## Writing to the file system

Downloads go to a session folder under `tempdir()` unless the user opts in
to a persistent cache through the `cache_dir` argument, the
`ESTBANR_CACHE_DIR` environment variable or the `estbanr.cache_dir` option.
The package never writes to the user's home directory by default.

## Text encoding

The Central Bank publishes the files in ISO-8859-1. They are read with
`readr::locale(encoding = "latin1")` and returned as UTF-8 strings. The
package source contains no non-ASCII characters in R code
(`tools::showNonASCIIfile()` is clean); the fixture in `inst/extdata/` is
Latin-1 by design, since it reproduces the published layout.
