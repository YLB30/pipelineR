#' Query Yahoo Finance for OHLCV stock data.
#'
#' @param tickers Vecteur de tickers (ex: c("AAPL", "MSFT")).
#' @param from Date de début (format "YYYY-MM-DD").
#' @param to Date de fin (défaut: aujourd'hui).
#' @param batch_size Taille des lots pour éviter surcharge API (défaut: 50).
#' @param ... Arguments supplémentaires pour tq_get().
#' @return Un tibble avec données OHLCV, une ligne par ticker/date.
#' @examples
#' data <- yahoo_query_data(c("AAPL", "MSFT"), from = "2026-01-01")
#' head(data)
#'
#' @importFrom tidyquant tq_get list_rbind map
#' @importFrom lubridate today
#' @export
yahoo_query_data <- function(tickers, from, to = as.character(lubridate::today()),
                             batch_size = 50, ...) {
  if (!requireNamespace("tidyquant", quietly = TRUE)) {
    stop("Installez tidyquant: install.packages('tidyquant')")
  }
  if (!requireNamespace("purrr", quietly = TRUE)) {
    stop("Installez purrr: install.packages('purrr')")
  }

  # Utilise split_batch pour diviser en lots
  batches <- split_batch(tickers, batch_size)

  # Récupère les données par lot
  prices_list <- purrr::map(batches, function(batch) {
    tidyquant::tq_get(batch,
                      get = "stock.prices",
                      from = from,
                      to = to,
                      ...)
  })

  # Combine en un tibble unique
  tidyquant::list_rbind(prices_list)
}

