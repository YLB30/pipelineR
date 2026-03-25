test_that("split_batch divise correctement les tickers", {
  tickers <- c("AAPL", "MSFT", "GOOG", "AMZN", "TSLA")
  batches <- split_batch(tickers, size = 2)

  expect_length(batches, 3) # 5 tickers / 2 = 3 lots
  expect_equal(length(batches[[1]]), 2)
  expect_equal(length(batches[[3]]), 1)
})
