#' Helper function to call API and return a data frame
#'
#' Low-level function that calls a single API endpoint and returns the parsed
#' result. Supports optional server-side filtering and two response formats.
#'
#' @param url Character. API endpoint URL. When `filters` are provided and the
#'   URL contains `"/dynamic/"`, the segment is automatically replaced with
#'   `"/search3condition/"` to enable server-side filtering. If the URL already
#'   uses `"search3condition"`, it is left unchanged.
#' @param key Character. API key.
#' @param filters Optional list of up to **3** filter conditions used to
#'   subset the API results server-side. Each condition is a named list with
#'   three fields:
#'   \describe{
#'     \item{`column`}{Character. The name of the column/variable to filter on.}
#'     \item{`operator`}{Character. The comparison operator (`"="`, `"!="`,
#'       `">"`, `">="`, `"<"`, `"<="`, `"in"`). Use `"in"` to match any of
#'       multiple values (see `value` below).}
#'     \item{`value`}{The value to compare against. For `operator = "in"`,
#'       supply a character or numeric vector, e.g.
#'       `value = c("a", "b", "c")`. For all other operators a scalar is
#'       expected.}
#'   }
#'   Filters are combined with a logical AND. Maximum 3 filters supported.
#'   Pass `NULL` (default) to return all records without filtering.
#'
#'   Examples:
#'   ```r
#'   # Scalar filter
#'   filters = list(
#'     list(column = "percap_type", operator = "=",  value = "FIES"),
#'     list(column = "year",        operator = "=",  value = 2025)
#'   )
#'
#'   # "in" filter – multiple values
#'   filters = list(
#'     list(column = "percap_type", operator = "in", value = c("FIES", "MFIES")),
#'     list(column = "year",        operator = "=",  value = 2025)
#'   )
#'   ```
#' @param structure Character. Response format. Use `"json"` (default) to parse
#'   from JSON, or `"csv"` to read delimited text. **Note:** if `filters` are
#'   provided and `structure = "csv"`, `structure` is automatically forced to
#'   `"json"` because filtering requires the JSON endpoint.
#' @param mute_onSuccess Logical. Suppress console messages on success.
#'   Default `TRUE`.
#'
#' @return A data frame of the parsed API result, or `NULL` on failure.
data_api <- function(url, key, filters = NULL, structure = "json",
                     mute_onSuccess = TRUE) {

  # Task 7: force json when filters are provided with csv
  if (!is.null(filters) && structure == "csv") {
    message(
      "[daclakeapi] Filters detected with structure = 'csv'. ",
      "Forcing structure = 'json' to enable server-side filtering."
    )
    structure <- "json"
  }

  # Task 4: swap /dynamic/ -> /search3condition/ when filters are present
  if (!is.null(filters) && grepl("/dynamic/", url, fixed = TRUE)) {
    url <- sub("/dynamic/", "/search3condition/", url, fixed = TRUE)
    message("[daclakeapi] URL updated for filtering: ", url)
  }

  if (structure == "json") {
    query_params <- list(key = key, structure = structure)

    if (!is.null(filters)) {
      if (is.character(filters)) {
        filters_list <- jsonlite::fromJSON(filters)
      } else {
        filters_list <- filters
      }
      for (i in seq_along(filters_list)) {
        query_params[[paste0("filters[", i - 1, "][column]")]]   <- filters_list[[i]]$column
        query_params[[paste0("filters[", i - 1, "][operator]")]] <- filters_list[[i]]$operator
        val <- filters_list[[i]]$value
        if (length(val) > 1) {
          # Expand multiple values into indexed params: filters[i][value][0], [1], ...
          for (j in seq_along(val)) {
            query_params[[paste0("filters[", i - 1, "][value][", j - 1, "]")]] <- val[[j]]
          }
        } else {
          query_params[[paste0("filters[", i - 1, "][value]")]] <- val
        }
      }
    }

    response <- httr::GET(url, query = query_params)

    if (httr::status_code(response) == 200) {
      if (!mute_onSuccess) message("Request was successful!")
      data     <- httr::content(response, "text", encoding = "UTF-8")
      json_data <- jsonlite::fromJSON(data, flatten = TRUE)
      data_df  <- as.data.frame(json_data)
      if (!mute_onSuccess) print(head(data_df))
    } else {
      message("Request failed with status: ", httr::status_code(response))
      message(httr::content(response, "text", encoding = "UTF-8"))
      data_df <- NULL
    }

    return(data_df)

  } else {
    # structure == "csv"
    response <- httr::GET(url, query = list(key = key, structure = structure))
    data     <- httr::content(response, "text", encoding = "UTF-8")
    readr::read_delim(data, delim = ",", escape_double = FALSE, trim_ws = TRUE)
  }
}

