#' Insert logs into pipeline_logs table.
#'
#' @param con Une connexion DBI (ex: DBI::dbConnect()).
#' @param log_data Un data.frame avec colonnes: pipeline_name, step_name, status, timestamp, message, duration (optionnel).
#' @return Le nombre de lignes affectées (invisible).
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' DBI::dbWriteTable(con, "pipeline_logs", data.frame(
#'   pipeline_name = "test", step_name = "load", status = "success",
#'   timestamp = Sys.time(), message = "Data loaded", duration = 1.2
#' ))
#' log_df <- data.frame(
#'   pipeline_name = "test_pipeline", step_name = "process",
#'   status = "completed", timestamp = Sys.time(), message = "OK"
#' )
#' push_summary_table(con, log_df)
#' DBI::dbDisconnect(con)
#'
#' @export
push_summary_table <- function(con, log_data) {
  if (nrow(log_data) == 0) return(invisible(0))

  DBI::dbWriteTable(
    con,
    DBI::Id(schema = "student_yves", table = "pipeline_logs"),
    log_data,
    append = TRUE,
    row.names = FALSE
  )
}

