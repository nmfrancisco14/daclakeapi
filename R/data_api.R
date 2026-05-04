#' Helper function to call API and return data frame
#'
#' @param url API endpoint
#' @param key API key
#' @param filters Optional list of up to **3** filter conditions used to
#'   subset the API results server-side. Each condition is a named list with
#'   three fields:
#'   \describe{
#'     \item{`column`}{Character. The name of the column/variable to filter on.}
#'     \item{`operator`}{Character. The comparison operator to apply. Common
#'       values include `"="` (equals), `"!="` (not equals), `">"`, `">="`,
#'       `"<"`, and `"<="`.}
#'     \item{`value`}{The value to compare against. Can be a character string
#'       or numeric depending on the column type.}
#'   }
#'   Filters are combined with a logical AND. A maximum of 3 filters is
#'   supported. Pass `NULL` (default) to return all records without filtering.
#'
#'   Example:
#'   ```r
#'   filters = list(
#'     list(column = "percap_type", operator = "=", value = "FIES"),
#'     list(column = "year",        operator = "=", value = 2025)
#'   )
#'   ```
#' @param structure Character string specifying the response format. Use
#'   `"json"` (default) to return a data frame parsed from JSON, or `"csv"`
#'   to return a data frame read from delimited text.
#' @param mute_onSuccess Logical to suppress messages on a successful request.
#'   Defaults to `TRUE`.
#'
#' @return A data frame of the parsed API result, or `NULL` if the request
#'   fails.

data_api <- function(url, key, filters = NULL, structure = 'json', mute_onSuccess = TRUE) {

  if (structure == 'json') {
  # Build the query parameters
  query_params <- list(key = key, structure = structure)

  # Add filters to query if provided
  if (!is.null(filters)) {
    # Ensure filters is a list (not a JSON string)
    if (is.character(filters)) {
      filters_list <- jsonlite::fromJSON(filters)
    } else if (is.list(filters)) {
      filters_list <- filters
    }
    # Add each filter as a separate 'filters[]' parameter
    for (i in seq_along(filters_list)) {
      # Remove jsonlite::toJSON() here - just pass the list directly
      query_params[[paste0("filters[", i - 1, "][column]")]] <- filters_list[[
        i
      ]]$column
      query_params[[paste0("filters[", i - 1, "][operator]")]] <- filters_list[[
        i
      ]]$operator
      query_params[[paste0("filters[", i - 1, "][value]")]] <- filters_list[[
        i
      ]]$value
    }
  }

  # Send GET request with key and filters as query parameters
  response <- httr::GET(
    url,
    query = query_params
  )

  if (httr::status_code(response) == 200) {
    if (!mute_onSuccess) {
      print("Request was successful!")
    }

    data <- httr::content(response, "text", encoding = "UTF-8")

    # print(data)

    json_data <- jsonlite::fromJSON(data, flatten = TRUE)
    data_df <- as.data.frame(json_data)

    if (!mute_onSuccess) {
      print(head(data_df))
    }
  } else {
    print(paste("Request failed with status:", httr::status_code(response)))
    print(httr::content(response, "text", encoding = "UTF-8"))
    data_df <- NULL # Prevent returning undefined object
  }

  return(data_df)
} else {
      response <- httr::GET(
    url,
    query = list(
      key = key,
      structure = structure
    )
  )
  
  data <- httr::content(response, "text", encoding = "UTF-8")
  
  readr::read_delim(data, delim = ",", escape_double = FALSE, trim_ws = TRUE)
  }
}

