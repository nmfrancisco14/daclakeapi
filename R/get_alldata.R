#' Get all built-in API data
#'
#' This function retrieves data from all registered default API endpoints.
#' You can extend this by adding more with `add_api_url()`.
#'
#' @param key API key. Default reads from the lakeAPIkey environment variable.
#' @param list.names list of names of dataframe to get from API. run `list_api_endpoints()` to list all possible API 
#'
#' @return A named list of data frames.
#' @export
get_all_api_data <- function(key = Sys.getenv("lakeAPIkey"), list.names = names(.api_url_registry)) {
  # Get all current API names in the registry
  api_names <- list.names

  # Retrieve data from each endpoint
  data_list <- purrr::map(api_names, ~ get_api_data(.x, key = key, 
                                                    type = dplyr::if_else(.x %in% c("urea_use_sem","pay_prism_mon"),"large","small")))

  # Name the list with the API names
  names(data_list) <- api_names

  return(data_list)
}
