# Network-free tests: .estban_perform() is mocked so no request leaves the
# machine. The zip body is built from the shipped fixture.

fixture_zip <- function() {
  csv <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  inner <- file.path(dir, "202401_ESTBAN_AG.CSV")
  file.copy(csv, inner)
  zip <- file.path(dir, "202401_ESTBAN_AG.csv.zip")
  old <- setwd(dir); on.exit(setwd(old))
  utils::zip(zip, basename(inner), flags = "-q")
  readBin(zip, "raw", file.info(zip)$size)
}

mock_perform <- function(status_by_url) {
  function(req) {
    hit <- status_by_url[[req$url]]
    if (is.null(hit)) stop("unexpected url: ", req$url)
    if (is.function(hit)) hit() else hit
  }
}

resp_raw <- function(body, status = 200L) {
  httr2::response(status_code = status, body = body,
                  headers = list(`content-type` = "application/zip"))
}

test_that("estban_download tries the variants in order and unzips the first hit", {
  body <- fixture_zip()
  urls <- estban_url(202401)
  calls <- character()
  mock <- function(req) {
    calls <<- c(calls, req$url)
    if (req$url == urls[[1]]) return(resp_raw(raw(0), 404L))
    if (req$url == urls[[2]]) return(resp_raw(body))
    stop("should not get here")
  }
  testthat::local_mocked_bindings(.estban_perform = mock, .package = "estbanr")
  dir <- withr::local_tempdir()

  csv <- estban_download(202401, cache_dir = dir, verbose = FALSE)
  expect_equal(basename(csv), "202401_ESTBAN_AG.CSV")
  expect_equal(calls, urls[1:2])
  x <- estban_read(csv, uf = "PB")
  expect_equal(nrow(x), 27)

  # Second call: served from cache, no HTTP at all
  calls <- character()
  csv2 <- estban_download(202401, cache_dir = dir, verbose = FALSE)
  expect_equal(csv2, csv)
  expect_length(calls, 0)

  # force = TRUE downloads again
  csv3 <- estban_download(202401, cache_dir = dir, force = TRUE, verbose = FALSE)
  expect_equal(csv3, csv)
  expect_length(calls, 2)
})

test_that("a month missing under every name returns NULL with a warning", {
  mock <- function(req) resp_raw(raw(0), 404L)
  testthat::local_mocked_bindings(.estban_perform = mock, .package = "estbanr")
  dir <- withr::local_tempdir()
  expect_warning(out <- estban_download(209901, cache_dir = dir, verbose = FALSE), "not found")
  expect_null(out)
})

test_that("server errors are reported, connection errors are actionable", {
  testthat::local_mocked_bindings(
    .estban_perform = function(req) resp_raw(raw(0), 503L), .package = "estbanr")
  expect_error(estban_download(202401, cache_dir = withr::local_tempdir(), verbose = FALSE), "HTTP 503")

  testthat::local_mocked_bindings(
    .estban_perform = function(req) stop("Could not resolve host"), .package = "estbanr")
  expect_error(estban_download(202401, cache_dir = withr::local_tempdir(), verbose = FALSE), "Could not reach")
})

test_that("estban_fetch stacks months and skips the unpublished ones", {
  body <- fixture_zip()
  u1 <- estban_url(202401)[[1]]
  u2 <- estban_url(202402)[[1]]
  mock <- function(req) {
    if (req$url == u1) return(resp_raw(body))
    if (req$url == u2) return(resp_raw(body))
    resp_raw(raw(0), 404L)
  }
  testthat::local_mocked_bindings(.estban_perform = mock, .package = "estbanr")
  dir <- withr::local_tempdir()
  expect_warning(x <- estban_fetch(202401, 202403, uf = "PE", cache_dir = dir, verbose = FALSE), "202403")
  expect_equal(sort(unique(x$ref)), c(202401L, 202402L))
  expect_equal(nrow(x), 48)
})
