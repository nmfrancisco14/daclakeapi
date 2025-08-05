#' Get all built-in API data
#'
#' This function retrieves data from all registered default API endpoints.
#' You can extend this by adding more with `add_api_url()`.
#'
#' @param key API key. Default reads from the RICELYTICS_API_KEY environment variable.
#'
#' @return A named list of data frames.
#' @export
get_all_api_data <- function(key = Sys.getenv("lakeAPIkey")) {
  # Get all current API names in the registry
  api_names <- names(.api_url_registry)

  # Retrieve data from each endpoint
  data_list <- purrr::map(api_names, ~ get_api_data(.x, key = key))

  # Name the list with the API names
  names(data_list) <- api_names

  return(data_list)
}
