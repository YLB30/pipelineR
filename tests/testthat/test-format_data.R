test_that("format_data nettoie correctement les colonnes", {
  # Simulation de données brutes tidyquant
  raw <- tibble::tibble(
    symbol = "AAPL",
    date = as.Date("2023-01-01"),
    open = 150, high = 155, low = 149, close = 152,
    volume = 1000, adjusted = 151 # Colonne en trop
  )

  clean <- format_data(raw)

  expect_equal(ncol(clean), 7) # On attend 7 colonnes
  expect_false("adjusted" %in% colnames(clean))
  expect_s3_class(clean$date, "Date")
})
