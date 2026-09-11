test_that("estban_clean_names normalizes accents, case and separators", {
  x <- c("#DATA_BASE", "VERBETE_174_PROV_P/_OPER_CREDITOS",
         "VERBETE_141_CORRESPONDENTES_NO_EXTERIOR + VERBETE_142_CORRESPONDENTES_NO_PAIS",
         "MUNICÍPIO")
  expect_equal(
    estban_clean_names(x),
    c("data_base", "verbete_174_prov_p_oper_creditos",
      "verbete_141_correspondentes_no_exterior_verbete_142_correspondentes_no_pais",
      "municipio")
  )
})

test_that("reference months are validated and sequenced", {
  expect_equal(estbanr:::.ref_int(202401), 202401L)
  expect_equal(estbanr:::.ref_int("202412"), 202412L)
  expect_equal(estbanr:::.ref_int(as.Date("2024-03-15")), 202403L)
  expect_error(estbanr:::.ref_int(202413), "AAAAMM")
  expect_error(estbanr:::.ref_int("jan/2024"), "AAAAMM")
  expect_equal(estbanr:::.ref_seq(202311, 202402), c(202311L, 202312L, 202401L, 202402L))
  expect_error(estbanr:::.ref_seq(202402, 202401), "earlier")
})

test_that("cache dir resolution follows argument > env > option > tempdir", {
  withr::local_envvar(ESTBANR_CACHE_DIR = "")
  withr::local_options(estbanr.cache_dir = NULL)
  # Compare with forward slashes on both sides: on Windows dirname() returns
  # "/" while normalizePath() returns "\\" for the same path.
  expect_equal(normalizePath(dirname(estban_cache_dir()), winslash = "/"),
               normalizePath(tempdir(), winslash = "/"))

  withr::local_options(estbanr.cache_dir = file.path(tempdir(), "opt-cache"))
  expect_true(endsWith(estban_cache_dir(create = FALSE), "opt-cache"))

  withr::local_envvar(ESTBANR_CACHE_DIR = file.path(tempdir(), "env-cache"))
  expect_true(endsWith(estban_cache_dir(create = FALSE), "env-cache"))

  expect_true(endsWith(estban_cache_dir(file.path(tempdir(), "arg-cache"), create = FALSE), "arg-cache"))
})

test_that("estban_url builds the known name variants in order", {
  u <- estban_url(202401)
  expect_length(u, 3)
  expect_match(u[[1]], "agencia/202401_ESTBAN_AG\\.csv\\.zip$")
  expect_match(u[[2]], "agencia/202401_ESTBAN_AG\\.ZIP$")
  expect_match(u[[3]], "agencia/202401_ESTBAN_AG\\.csv$")
  m <- estban_url("202401", level = "municipio")
  expect_match(m[[1]], "municipio/202401_ESTBAN\\.csv\\.zip$")
  expect_error(estban_url(202401, level = "banco"))
})
