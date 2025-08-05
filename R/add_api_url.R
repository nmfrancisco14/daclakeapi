#' Get the API URL by name
#' @param name The name of the API (e.g. "wholesale_prices")
#' @return The API URL
#' @export
get_api_url <- function(name) {
  if (!name %in% names(.api_url_registry)) {
    stop(paste("Unknown API name:", name))
  }
  .api_url_registry[[name]]
}



#' Add or override an API endpoint
#'
#' @param name A unique name for the API (e.g. "my_custom_data")
#' @param url The API endpoint URL
#'
#' @return NULL (modifies internal registry)
#' @export
add_api_url <- function(name, url) {
  if (!is.character(name) || !is.character(url)) {
    stop("Both `name` and `url` must be character strings.")
  }
  .api_url_registry[[name]] <<- url  # use global assignment
  invisible(NULL)
}



#' List available API names
#' @export
list_api_endpoints <- function() {
  names(.api_url_registry)
}

#' Reset API registry to defaults
#' @export
reset_api_urls <- function() {
  .api_url_registry <<- .default_api_urls
  invisible(NULL)
}
