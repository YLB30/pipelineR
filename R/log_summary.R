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
log_summary <- function(batch_num, status, details = "", tickers = "") {
  timestamp <- Sys.time()
  log_entry <- tibble(
    timestamp = timestamp,
    batch_num = batch_num,
    status = status,
    details = details,
    tickers = paste(tickers, collapse = ", ")
  )

  # Log console avec couleur simulée via message
  status_msg <- ifelse(status == "OK", "✅ OK", "❌ ERROR")
  msg <- sprintf("[%s] Batch %d %s - %s | Tickers: %s",
                 format(timestamp, "%H:%M:%S"),
                 batch_num, status_msg, details, paste(tickers[1:min(3, length(tickers))], collapse = ", "))
  message(msg)

  # Ajoute au log global (singleton pattern simple)
  if (!exists("log_df", envir = .GlobalEnv)) {
    assign("log_df", log_entry, envir = .GlobalEnv)
  } else {
    assign("log_df", bind_rows(get("log_df", envir = .GlobalEnv), log_entry), envir = .GlobalEnv)
  }

  invisible(log_df)
}

# Fonction utilitaire pour afficher/reset le log final
log_print <- function() {
  if (exists("log_df", envir = .GlobalEnv)) {
    print(get("log_df", envir = .GlobalEnv))
    cat(sprintf("\nRésumé: %d OK, %d ERROR\n",
                sum(get("log_df", envir = .GlobalEnv)$status == "OK"),
                sum(get("log_df", envir = .GlobalEnv)$status == "ERROR")))
  } else {
    cat("Aucun log.\n")
  }
}

log_reset <- function() {
  if (exists("log_df", envir = .GlobalEnv)) rm("log_df", envir = .GlobalEnv)
}

