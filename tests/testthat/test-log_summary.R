test_that("log_summary calcule une durée cohérente", {
  t_start <- lubridate::now() - 5 # Simule un départ il y a 5 secondes

  log <- log_summary(
    pipeline_name = "Test",
    step_name = "Unit_Test",
    status = "SUCCESS",
    start_time = t_start
  )

  expect_s3_class(log, "tbl_df")
  expect_gt(log$duration, 4.9) # Doit être proche de 5
  expect_equal(log$status, "SUCCESS")
})
