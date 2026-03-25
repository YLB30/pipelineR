test_that("insert_new_data gère les données vides", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:") # Base temporaire pour le test
  on.exit(DBI::dbDisconnect(con))

  empty_df <- tibble::tibble()
  result <- insert_new_data(empty_df, con)

  expect_equal(result, 0)
})
