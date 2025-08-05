#' Summarize the most recent dates from API data
#'
#' This function extracts the most recent date from each dataset
#' in a named list of data frames, such as from `get_all_api_data()`.
#'
#' @param all_data A named list of data frames.
#' @param date_col The name of the date column. Defaults to `"updated_at"`.
#'
#' @return A data frame with the latest date per API source.
#' @export
summarize_latest_dates <- function(all_data, date_col = "updated_at") {
  purrr::map_df(names(all_data), function(name) {
    df <- all_data[[name]]

    if (is.null(df)) {
      latest <- NA
    } else if (!(date_col %in% names(df))) {
      latest <- NA
    } else {
      # Try parsing to Date
      latest <- suppressWarnings(
        max(as.Date(df[[date_col]]), na.rm = TRUE)
      )
    }

    tibble::tibble(source = name, latest_date = latest)
  })
}
