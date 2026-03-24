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
insert_new_data <- function(new_data, con, unique_cols = c("symbol", "date")) {
  con <- connect_db()
  on.exit(dbDisconnect(con), add = TRUE)

  if (!is.data.frame(new_data) || nrow(new_data) == 0) {
    return(invisible(0))
  }

  # Vérifier les colonnes requises
  missing_cols <- setdiff(unique_cols, colnames(new_data))
  if (length(missing_cols) > 0) {
    stop("Colonnes manquantes dans new_data: {glue_collapse(missing_cols, sep = ', ')}",
         call. = FALSE)
  }

  # Étape 1: Identifier les doublons existants
  where_clause <- glue_collapse(
    map_chr(unique_cols, ~ glue("{.x} = ?{.x}")),
    sep = " AND "
  )
  placeholders <- map_chr(unique_cols, ~ glue("?{.x}"))

  existing_query <- glue_sql("
    SELECT {glue_collapse(unique_cols, sep = ', ')}
    FROM data.sp500
    WHERE {where_clause}
  ", .con = con)

  existing_keys <- new_data %>%
    distinct(!!!syms(unique_cols)) %>%
    dbSendQuery(con, existing_query, .bind = .) %>%
    dbFetch() %>%
    as_tibble()

  # Étape 2: Filtrer les nouvelles (non-doublons)
  new_to_insert <- anti_join(new_data, existing_keys, by = unique_cols)

  if (nrow(new_to_insert) == 0) {
    message("Aucune nouvelle donnée à insérer (toutes doublons).")
    return(invisible(0))
  }

  # Étape 3: Insérer avec sqlAppendTableMore (append sécurisé)
  cols_str <- glue_collapse(colnames(new_to_insert), sep = ", ")
  placeholders_str <- glue_collapse(rep("?", ncol(new_to_insert)), sep = ", ")
  values_str <- glue_collapse(
    map(1:nrow(new_to_insert), ~ glue_collapse(map_chr(colnames(new_to_insert), ~ glue("{new_data[.y, .x][[.y]]}"), .y = .x), sep = ", ")),
    sep = "), ("
  )

  insert_query <- glue_sql("
    INSERT INTO data.sp500 ({cols_str})
    VALUES ({placeholders_str})
  ", .con = con)

  result <- dbSendStatement(con, insert_query, bind.params = as.list(new_to_insert))
  n_inserted <- dbGetRowsAffected(result)
  dbClearResult(result)

  message("{n_inserted} lignes insérées dans data_sp500.")
  invisible(n_inserted)
}
