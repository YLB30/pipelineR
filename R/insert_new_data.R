library(DBI)
library(glue)
library(dplyr)

#' Insert new data into data_sp500, avoiding duplicates.
#'
#' @param new_data Un tibble/data.frame avec les colonnes symbol, date (PK supposée), et autres colonnes.
#' @param con La fonction retournant la connexion DB (ex: get_db_connection()).
#' @param unique_cols Colonnes pour identifier les doublons (défaut: c("symbol", "date")).
#' @return Le nombre de lignes insérées (invisibles).
#' @examples
#' # new_data <- tibble(symbol = "AAPL", date = Sys.Date(), close = 150)
#' # insert_new_data(new_data, get_db_connection)
#' @export
insert_new_data <- function(new_data, con, schema = "student_yves") {

  # 1. Validations de base (Inspiré de ta version)
  if (!is.data.frame(new_data) || nrow(new_data) == 0) {
    message("Aucune donnée à insérer.")
    return(invisible(0))
  }

  required_cols <- c("symbol", "date", "open", "high", "low", "close", "volume")
  missing_cols <- setdiff(required_cols, colnames(new_data))

  if (length(missing_cols) > 0) {
    stop(glue::glue("Colonnes manquantes : {paste(missing_cols, collapse = ', ')}"))
  }

  # 2. Utilisation de la table temporaire (Ma version pour la performance)
  temp_table <- paste0("temp_insert_", sample(1000:9999, 1))

  tryCatch({
    # Upload rapide des données vers PostgreSQL
    DBI::dbWriteTable(con, temp_table, new_data, temporary = TRUE, overwrite = TRUE)

    # 3. Requête UPSERT (Le moteur SQL gère lui-même les doublons)
    query <- glue::glue("
      INSERT INTO {schema}.data_sp500 ({paste(required_cols, collapse = ', ')})
      SELECT {paste(required_cols, collapse = ', ')}
      FROM {temp_table}
      ON CONFLICT (symbol, date) DO NOTHING;
    ")

    n_inserted <- DBI::dbExecute(con, query)

    # Nettoyage
    DBI::dbRemoveTable(con, temp_table)

    message(glue::glue("{n_inserted} lignes insérées dans {schema}.data_sp500."))
    return(invisible(n_inserted))

  }, error = function(e) {
    if (DBI::dbExistsTable(con, temp_table)) DBI::dbRemoveTable(con, temp_table)
    stop(glue::glue("Erreur lors de l'insertion : {e$message}"))
  })
}
