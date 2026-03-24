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
  # Requête SQL parameterisée avec glue_sql
  sql <- glue::glue_sql("
    INSERT INTO pipeline_logs
    (pipeline_name, step_name, status, timestamp, message, duration)
    VALUES ({pipeline_name}, {step_name*}, {status*}, {timestamp*},
            {message*}, {duration*})
  ", .con = con)

  # Exécution pour chaque ligne (ou utiliser dbAppendTable pour lots)
  n_rows <- nrow(log_data)
  rows_affected <- 0
  for (i in 1:n_rows) {
    rows_affected <- rows_affected + DBI::dbExecute(con, sql,
                                                    list(
                                                      pipeline_name = log_data$pipeline_name[i],
                                                      step_name = log_data$step_name[i],
                                                      status = log_data$status[i],
                                                      timestamp = log_data$timestamp[i],
                                                      message = log_data$message[i],
                                                      duration = log_data$duration[i]
                                                    )
    )
  }
  invisible(rows_affected)
}
