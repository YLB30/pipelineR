#' Fetch S&P 500 stock symbols
#'
#' Retrieves all stock symbols from the S&P 500 constituents table.
#'
#' @return A data frame with one column:
#' \describe{
#'   \item{symbol}{Stock ticker symbol (e.g., "AAPL", "MSFT")}
#' }
#'
#' @details
#' Connects to the database using \code{connect_db()}, queries the
#' \code{sp500.info} table, and automatically disconnects using
#' \code{on.exit()}. Optimized for fast retrieval of symbols only.
#'
#' @examples
#' \dontrun{
#' # Fetch all S&P 500 symbols
#' symbols <- fetch_symbols()
#'
#' # View first few symbols
#' head(symbols$symbol)
#'
#' # Count total symbols
#' nrow(symbols)
#' }
#'
#' @export
fetch_symbols <- function() {
  con <- connect_db()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbGetQuery(con, "SELECT symbol FROM sp500.info;")
}

