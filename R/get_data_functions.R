#' Get API data by name
#' @param name One of the known API names like "wholesale_prices"
#' @param key API key. Default reads from the lakeAPIkey environment variable.
#' @return Data frame from API
#'
#'
get_api_data <- function(name, key = Sys.getenv("lakeAPIkey")) {

  url <- get_api_url(name)

  if (name == "urea_use_sem") {
    data_api_ureasem(key)
  } else {
  data_api(url, key)
  }
}
