#' Log each batch process (OK or ERROR).
#'
#' @param batch_num Numéro du lot (ex: 1, 2...).
#' @param status Statut: "OK" ou "ERROR".
#' @param details Détails optionnels (ex: nb lignes récupérées ou message d'erreur).
#' @param tickers Les tickers du lot (pour affichage).
#' @return Un tibble avec tous les logs accumulés (invisible).
#' @examples
#' log_summary(1, "OK", "50 lignes", c("AAPL", "MSFT"))
#' log_summary(2, "ERROR", "Rate limit", c("GOOGL"))
#'
#' @export
log_summary <- function(pipeline_name = "PipelineR", step_name, status, start_time, message = NA_character_) {
  duration <- round(as.numeric(difftime(lubridate::now(), start_time, units = "secs")), 2)

  tibble::tibble(
    pipeline_name = pipeline_name,
    step_name     = step_name,
    status        = status,
    timestamp     = lubridate::now(),
    message       = as.character(message),
    duration      = duration
  )
}
