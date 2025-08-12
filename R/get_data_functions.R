#' Get API data by name
#' @param name One of the known API names like "wholesale_prices"
#' @param key API key. Default reads from the lakeAPIkey environment variable.
#' @return Data frame from API
#'
#'
get_api_data <- function(name, key = Sys.getenv("lakeAPIkey"),type= "small") {

  url <- get_api_url(name)

  if (type =="large") {
    data_api2(url,key)
  } else {
  data_api(url, key)
  }
}
