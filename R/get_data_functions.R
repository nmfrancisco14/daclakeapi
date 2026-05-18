#' Get API data by dataset name
#'
#' Fetches data from a single registered API endpoint, identified by its
#' dataset name. Prints dataset metadata (title, category, API link) to the
#' console before fetching.
#'
#' @param name Character. The exact dataset name as listed in the registry.
#'   Use `get_api_registry()` or `list_api_endpoints()` to browse available
#'   names.
#' @param key Character. API key. Defaults to the `lakeAPIkey` environment
#'   variable.
#' @param type Character. Fetch mode: `"small"` (default) uses [data_api()]
#'   with JSON/CSV support and optional filtering; `"large"` uses [data_api2()]
#'   which is optimised for large datasets returned as CSV.
#' @param filters Optional list of filter conditions passed to [data_api()].
#'   Ignored when `type = "large"`. See [data_api()] for format details.
#' @param structure Character. Response format passed to [data_api()]: `"json"`
#'   (default) or `"csv"`. Ignored when `type = "large"`. Automatically forced
#'   to `"json"` if filters are provided.
#'
#' @return A data frame returned by the API, or `NULL` on failure.
#' @export
get_api_data <- function(name, key = Sys.getenv("lakeAPIkey"),
                         type = "small", filters = NULL,
                         structure = "json") {

  # Look up the registry row for metadata
  row <- .api_registry[!is.na(.api_registry$dataset) &
                         .api_registry$dataset == name, ]
  if (nrow(row) == 0) {
    stop("No API entry found for: ", name)
  }

  url <- row$api_link[[1]]

  # Print dataset info (Task 6)
  message(
    "[daclakeapi] Fetching dataset  : ", row$dataset[[1]], "\n",
    "             Category         : ", ifelse(is.na(row$category[[1]]), "N/A", row$category[[1]]), "\n",
    "             API Link         : ", url
  )

  if (type == "large") {
    data_api2(url, key)
  } else {
    data_api(url, key, filters = filters, structure = structure)
  }
}
