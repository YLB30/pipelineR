test_that("connect_db échoue proprement sans variables d'env", {
  # On vide temporairement les variables d'env pour le test
  withr::with_envvar(c(DB_NAME = ""), {
    expect_error(connect_db())
  })
})
