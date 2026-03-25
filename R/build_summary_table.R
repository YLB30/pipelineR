#' Create an empty log tibble for batch processing summary.
#'
#' @description Initialise un tibble vide pour logger le traitement des batches de tickers
#' (statut, erreurs, timestamps). Idéal pour tidyquant et API calls.
#' @return Un tibble vide avec colonnes: batch_id, tickers, n_tickers, status, error_msg, start_time, end_time.
#' @examples
#' log_table <- build_summary_table()
#' log_table
#'
#' # Ajout d'une entrée exemple
#' log_table <- rbind(log_table, tibble(
#'   batch_id = 1,
#'   tickers = "AAPL,MSFT",
#'   n_tickers = 2,
#'   status = "success",
#'   error_msg = NA_character_,
#'   start_time = Sys.time() - 60,
#'   end_time = Sys.time()
#' ))
#' @export
build_summary_table <- function() {
  tibble::tibble(
    execution_ts  = lubridate::now(),
    status        = character(),
    rows_inserted = integer(),
    error_msg     = character()
  )
}
