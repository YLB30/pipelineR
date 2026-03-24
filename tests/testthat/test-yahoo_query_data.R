library(testthat)
library(tidyquant)  # Pour les structures de données attendues
library(purrr)

test_that("yahoo_query_data retourne un tibble tidyquant valide", {
  # Mock split_batch: retourne 2 batches pour 3 tickers
  local_mock(
    split_batch = function(tickers, batch_size) {
      list(batch1 = tickers[1:2], batch2 = tickers[3])
    },
    # Mock tq_get: retourne des données mock réalistes
    `tidyquant::tq_get` = function(x, ...) {
      batch_name <- x[[1]]  # Premier ticker comme nom batch
      tibble(
        symbol = rep(x, each = 2),
        date = as.Date(c("2026-03-01", "2026-03-02")),
        open = c(100, 101),
        high = c(102, 103),
        low = c(99, 100),
        close = c(101, 102),
        volume = c(1e6, 1.1e6),
        adjusted = c(101, 102)
      )
    }
  )

  # Données de test
  tickers <- c("AAPL", "MSFT", "GOOGL")
  from <- "2026-03-01"
  to <- "2026-03-10"

  result <- yahoo_query_data(tickers, from, to, batch_size = 2)

  # Tests sur la structure
  expect_s3_class(result, "tbl_df")
  expect_s3_class(result, "tbl")
  expect_equal(nrow(result), 6)  # 3 tickers x 2 dates
  expect_equal(ncol(result), 7)
  expect_equal(unique(result$symbol), tickers)
  expect_true(all(result$date >= as.Date(from) & result$date <= as.Date(to)))
})

test_that("yahoo_query_data gère les lots correctement", {
  local_mock(
    split_batch = function(tickers, batch_size) {
      if (length(tickers) <= batch_size) {
        list(all = tickers)
      } else {
        list(batch1 = tickers[1:batch_size], batch2 = tickers[(batch_size+1):length(tickers)])
      }
    },
    `tidyquant::tq_get` = function(x, ...) tibble(symbol = x[[1]], date = Sys.Date(), close = 100)
  )

  result <- yahoo_query_data(c("AAPL", "MSFT"), from = "2026-01-01", batch_size = 1)
  expect_equal(nrow(result), 2)
  expect_equal(unique(result$symbol), c("AAPL", "MSFT"))
})

test_that("yahoo_query_data propage les erreurs tidyquant", {
  local_mock(
    `tidyquant::tq_get` = function(x, ...) stop("API error: ticker invalide")
  )

  expect_error(yahoo_query_data("INVALID", "2026-01-01"), "API error")
})

test_that("yahoo_query_data lève erreur si packages manquants", {
  local_mock(
    requireNamespace = function(pkg, ...) FALSE
  )

  expect_error(yahoo_query_data("AAPL", "2026-01-01"), "Installez tidyquant")
})

test_that("yahoo_query_data gère zéro ticker", {
  local_mock(
    split_batch = function(...) list()
  )

  expect_equal(yahoo_query_data(character(0), "2026-01-01"), tibble())
})

test_that("yahoo_query_data passe ... à tq_get", {
  mock_args <- list()
  local_mock(
    `tidyquant::tq_get` = function(x, ...) {
      mock_args <<- list(...)
      tibble(symbol = x[[1]])
    }
  )

  yahoo_query_data("AAPL", "2026-01-01", freq = "daily")
  expect_true("freq" %in% names(mock_args))
})
