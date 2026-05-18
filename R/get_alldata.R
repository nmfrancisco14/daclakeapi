#' Get data from all (or a subset of) registered API endpoints
#'
#' Iterates over the API registry and retrieves data from each endpoint.
#' Prints dataset metadata (title, category, API link) for every entry before
#' fetching. Extend the registry with [add_api_url()] or refresh it with
#' [update_registry()].
#'
#' @param key Character. API key. Defaults to the `lakeAPIkey` environment
#'   variable.
#' @param datasets Character vector of dataset names to fetch. Defaults to all
#'   non-`NA` dataset names in the registry. Use [list_api_endpoints()] to
#'   browse available names.
#' @param type Character. Fetch mode applied to every endpoint: `"small"`
#'   (default) uses [data_api()]; `"large"` uses [data_api2()].
#' @param structure Character. Response format passed to [data_api()]: `"csv"`
#'   (default) or `"json"`. Ignored when `type = "large"`.
#'
#' @return A named list where each element is either a data frame (successful
#'   request) or a character string describing the error (failed request).
#'   Names correspond to the `dataset` column of the registry.
#' @export
get_all_api_data <- function(key       = Sys.getenv("lakeAPIkey"),
                             datasets  = .api_registry$dataset[!is.na(.api_registry$dataset)],
                             type      = "small",
                             structure = "csv") {

  data_list <- purrr::map(datasets, function(nm) {
    row <- .api_registry[!is.na(.api_registry$dataset) &
                           .api_registry$dataset == nm, ]

    if (nrow(row) == 0) {
      message("[daclakeapi] Skipping unknown dataset: ", nm)
      return("[daclakeapi] Error: dataset not found in registry")
    }

    url <- row$api_link[[1]]

    message(
      "[daclakeapi] Fetching dataset  : ", row$dataset[[1]], "\n",
      "             Category         : ", ifelse(is.na(row$category[[1]]), "N/A", row$category[[1]]), "\n",
      "             API Link         : ", url
    )

    tryCatch(
      {
        if (type == "large") {
          data_api2(url, key)
        } else {
          data_api(url, key, structure = structure)
        }
      },
      error = function(e) {
        msg <- conditionMessage(e)
        message("[daclakeapi] Request failed for '", nm, "': ", msg)
        paste0("[daclakeapi] Error: ", msg)
      }
    )
  })

  names(data_list) <- datasets
  data_list
}
