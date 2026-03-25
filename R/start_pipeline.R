#' Title
#' Exécuteur principal du pipeline de données boursières S&P 500
#'
#' @description
#' Cette fonction orchestre l'ensemble du flux ETL (Extract, Transform, Load) :
#' 1. Se connecte à la base de données PostgreSQL via les variables d'environnement.
#' 2. Récupère la liste des tickers S&P 500 depuis la table \code{sp500.info}.
#' 3. Télécharge les données historiques OHLCV via l'API Yahoo Finance (tidyquant).
#' 4. Nettoie et formate les données au format long.
#' 5. Insère les nouvelles données dans \code{student_yves.data_sp500} (gestion anti-doublons).
#' 6. Enregistre les métriques d'exécution (durée, statut, lignes) dans \code{student_yves.pipeline_logs}.
#'
#' @param days_back Entier. Nombre de jours d'historique à récupérer à partir d'aujourd'hui. Par défaut : 5.
#' @param pipeline_name Chaîne de caractères. Nom du pipeline utilisé pour le logging. Par défaut : "PipelineR_Daily".
#'
#' @return Cette fonction ne retourne rien de manière explicite (\code{invisible(NULL)}).
#' Elle produit des messages dans la console et met à jour la base de données.
#'
#' @details
#' Assurez-vous que les variables d'environnement suivantes sont définies dans votre fichier \code{.Renviron} :
#' \code{DB_NAME}, \code{DB_HOST}, \code{DB_USER}, \code{DB_PASS}, \code{DB_PORT}.
#'
#' @examples
#' \dontrun{
#' # Lancement du pipeline pour les 10 derniers jours
#' start_pipeline(days_back = 10)
#' }
#'
#' @import DBI
#' @importFrom lubridate now today
#' @importFrom glue glue
#' @export
#'
#' @examples
start_pipeline <- function(days_back = 5) {
  con <- connect_db()
  on.exit(DBI::dbDisconnect(con))

  t_start <- lubridate::now()

  tryCatch({
    # 1. Extraction
    symbols <- fetch_symbols(con)
    raw_data <- yahoo_query_data(symbols, from = as.character(Sys.Date() - days_back))

    # 2. Transformation & Chargement
    clean_data <- format_data(raw_data)
    n_rows <- insert_new_data(clean_data, con)

    # 3. Log Succès
    final_log <- log_summary("PipelineR", "Full_Run", "SUCCESS", t_start,
                             message = glue::glue("Inserted {n_rows} rows"))
    push_summary_table(con, final_log)

    message(glue::glue("Pipeline terminé avec succès ({n_rows} lignes)."))

  }, error = function(e) {
    # Log Erreur
    err_log <- log_summary("PipelineR", "Full_Run", "ERROR", t_start, message = e$message)
    push_summary_table(con, err_log)
    stop("Pipeline échoué : ", e$message)
  })
}
