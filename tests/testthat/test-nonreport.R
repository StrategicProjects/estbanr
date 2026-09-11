three_months <- function() {
  f  <- system.file("extdata", "202401_ESTBAN_AG_sample.CSV", package = "estbanr")
  m1 <- estban_read(f, uf = "PE")
  verb <- grep("^verbete_", names(m1))
  m2 <- m1; m2$ref <- 202402L; m2[, verb] <- m2[, verb] * 1.05
  m3 <- m1; m3$ref <- 202403L; m3[, verb] <- m3[, verb] * 1.10
  list(m1 = m1, m2 = m2, m3 = m3, verb = verb)
}

test_that("estban_flag_nonreport flags only institution-months zeroed everywhere", {
  d <- three_months()
  m2 <- d$m2
  m2[m2$cnpj == "60746948", d$verb] <- 0                     # Bradesco vanishes in Feb
  x <- estban_flag_nonreport(rbind(d$m1, m2, d$m3))
  expect_true(all(x$nonreport[x$cnpj == "60746948" & x$ref == 202402L]))
  expect_false(any(x$nonreport[x$cnpj == "60746948" & x$ref != 202402L]))
  expect_false(any(x$nonreport[x$cnpj != "60746948"]))

  # One dormant branch (zero in one city only) is NOT a non-report
  y <- d$m1
  y[y$cnpj == "60746948" & y$municipio == "GARANHUNS", d$verb] <- 0
  expect_false(any(estban_flag_nonreport(y)$nonreport))
})

test_that("estban_impute_nonreport interpolates interior gaps and leaves edges NA", {
  d <- three_months()
  m2 <- d$m2
  m2[m2$cnpj == "60746948", d$verb] <- 0
  x <- rbind(d$m1, m2, d$m3)

  expect_message(imp <- estban_impute_nonreport(x), "1 institution-month")
  b <- imp[imp$cnpj == "60746948" & imp$municipio == "CARUARU", ]
  v <- "verbete_160_operacoes_de_credito"
  expect_equal(nrow(b), 3)
  # February = midpoint of January and March (linear interpolation)
  expect_equal(b[[v]][b$ref == 202402L], (b[[v]][b$ref == 202401L] + b[[v]][b$ref == 202403L]) / 2)
  expect_equal(b$imputed[b$ref == 202402L], 45L)
  expect_equal(b$imputed[b$ref != 202402L], c(0L, 0L))
  # Other banks untouched, and branches collapsed to one row per bank-city
  cx <- imp[imp$cnpj == "00360305" & imp$municipio == "CARUARU" & imp$ref == 202401L, ]
  expect_equal(nrow(cx), 1)
  expect_equal(cx[[v]], sum(d$m1[[v]][d$m1$cnpj == "00360305" & d$m1$municipio == "CARUARU"]))

  # Gap at the edge (last month) is not extrapolated
  m3 <- d$m3
  m3[m3$cnpj == "60746948", d$verb] <- 0
  imp2 <- suppressMessages(estban_impute_nonreport(rbind(d$m1, d$m2, m3)))
  b2 <- imp2[imp2$cnpj == "60746948" & imp2$municipio == "CARUARU", ]
  expect_true(is.na(b2[[v]][b2$ref == 202403L]))
  expect_equal(b2$imputed, c(0L, 0L, 0L))
})

test_that("estban_by_municipality sums and the imputation keeps the series smooth", {
  d <- three_months()
  m2 <- d$m2
  m2[m2$cnpj == "60746948", d$verb] <- 0
  x <- rbind(d$m1, m2, d$m3)
  v <- "verbete_160_operacoes_de_credito"

  raw <- estban_by_municipality(x, impute = FALSE)
  imp <- suppressMessages(estban_by_municipality(x, impute = TRUE))
  expect_equal(nrow(raw), 6)      # 2 cities x 3 months
  expect_equal(names(raw)[1:4], c("uf", "municipio", "codmun_ibge", "ref"))
  car_raw <- raw[[v]][raw$municipio == "CARUARU"]
  car_imp <- imp[[v]][imp$municipio == "CARUARU"]
  # Without imputation February is short by the missing bank; with it,
  # February sits between January and March
  expect_lt(car_raw[[2]], car_imp[[2]])
  expect_equal(car_raw[[1]], car_imp[[1]])
  expect_gt(car_imp[[2]], car_imp[[1]])
  expect_lt(car_imp[[2]], car_imp[[3]])

  lng <- estban_by_municipality(d$m1, impute = FALSE, long = TRUE)
  expect_equal(names(lng), c("uf", "municipio", "codmun_ibge", "ref", "verbete", "value"))
  expect_equal(nrow(lng), 2 * 45)
  expect_equal(lng$value[lng$municipio == "CARUARU" & lng$verbete == v],
               raw[[v]][raw$municipio == "CARUARU" & raw$ref == 202401L])
})

test_that("non-ESTBAN input is rejected with guidance", {
  expect_error(estban_flag_nonreport(data.frame(a = 1)), "estban_read")
  expect_error(estban_by_municipality(tibble::tibble(cnpj = "1", ref = 1L)), "verbete")
})
