fixture <- function(level = "agencia") {
  system.file("extdata",
              if (level == "agencia") "202401_ESTBAN_AG_sample.CSV" else "202401_ESTBAN_sample.CSV",
              package = "estbanr")
}

test_that("estban_read parses the branch-level layout", {
  x <- estban_read(fixture())
  expect_s3_class(x, "tbl_df")
  expect_equal(names(x)[1:8],
               c("ref", "data_base", "uf", "codmun", "municipio", "cnpj",
                 "nome_instituicao", "agencia"))
  expect_equal(names(x)[[ncol(x)]], "codmun_ibge")
  expect_true(all(x$ref == 202401L))
  expect_type(x$verbete_160_operacoes_de_credito, "double")
  expect_type(x$codmun_ibge, "integer")
  expect_type(x$cnpj, "character")
  expect_false(any(startsWith(x$agencia, "'")))
  expect_setequal(unique(x$uf), c("PE", "PB"))
  expect_equal(nrow(x), 51)
  # Latin-1 accents survive the read
  expect_true(any(grepl("ITAÚ", x$nome_instituicao)))
})

test_that("estban_read filters by uf and keeps original names on request", {
  pe <- estban_read(fixture(), uf = "pe")
  expect_true(all(pe$uf == "PE"))
  expect_equal(nrow(pe), 24)

  raw <- estban_read(fixture(), clean_names = FALSE)
  expect_equal(names(raw)[1:3], c("ref", "#DATA_BASE", "UF"))
  expect_true("CODMUN_IBGE" %in% names(raw))
})

test_that("estban_read parses the municipality-level layout", {
  m <- estban_read(fixture("municipio"))
  expect_true(all(c("agen_esperadas", "agen_processadas") %in% names(m)))
  expect_type(m$agen_esperadas, "integer")
  expect_equal(nrow(m), 24)
  expect_equal(length(estbanr:::.verbete_cols(m)), 45)
})

test_that("estban_read rejects files without the layout", {
  f <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("title", "date", "a;b;c", "1;2;3"), f)
  expect_error(estban_read(f), "layout")
  expect_error(estban_read(file.path(tempdir(), "nope.csv")), "not found")
})

test_that("an explicit ref overrides the file's DATA_BASE", {
  x <- estban_read(fixture(), ref = 202402)
  expect_true(all(x$ref == 202402L))
})

test_that("the dictionary matches the fixture columns", {
  x <- estban_read(fixture())
  v <- estban_verbetes()
  expect_equal(nrow(v), 45)
  expect_setequal(v$name, estbanr:::.verbete_cols(x))
  expect_true(all(v$code[v$side == "ativo"] < 400))
  expect_equal(v$codes[v$code == 141], "141;142")
  expect_true(all(v$n_codes >= 1))
  cols <- estban_columns("municipio")
  expect_equal(nrow(cols), 54)
  expect_equal(sum(cols$kind == "verbete"), 45)
})
