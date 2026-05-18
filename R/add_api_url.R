#' Get API registry as a data frame
#'
#' Returns the current API registry as a tibble with columns:
#' \describe{
#'   \item{`dataset`}{Title of the dataset.}
#'   \item{`type`}{Sheet source: `"Convergence"` or `"Analytics and Rltx"`.}
#'   \item{`category`}{Sub-theme (Convergence) or category (Analytics and Rltx).}
#'   \item{`api_link`}{API endpoint URL.}
#'   \item{`site_link`}{Data Lake Portal URL.}
#' }
#'
#' @return A tibble of all registered API endpoints.
#' @export
get_api_registry <- function() {
  .api_registry
}


#' Get the API URL for a dataset by exact dataset name or row index
#'
#' @param name Character. The exact dataset name as listed in the registry
#'   (see `get_api_registry()`), or an integer row index.
#'
#' @return A single character string with the API URL.
#' @export
get_api_url <- function(name) {
  if (is.numeric(name)) {
    row <- .api_registry[name, ]
  } else {
    row <- .api_registry[!is.na(.api_registry$dataset) &
                           .api_registry$dataset == name, ]
  }
  if (nrow(row) == 0) {
    stop(paste("No API entry found for:", name))
  }
  row$api_link[[1]]
}


#' Add or override an API entry in the registry
#'
#' Adds a new row to the mutable API registry, or replaces an existing entry
#' with the same `dataset` name if one exists.
#'
#' @param dataset Character. Title of the dataset.
#' @param api_link Character. The API endpoint URL.
#' @param type Character. Sheet source label (default `"Custom"`).
#' @param category Character. Category or sub-theme label (default `NA`).
#' @param site_link Character. Data Lake Portal URL (default `NA`).
#'
#' @return `NULL` invisibly. Modifies the internal registry.
#' @export
add_api_url <- function(dataset, api_link, type = "Custom",
                        category = NA_character_, site_link = NA_character_) {
  if (!is.character(dataset) || !is.character(api_link)) {
    stop("`dataset` and `api_link` must be character strings.")
  }

  new_row <- tibble::tibble(
    dataset   = dataset,
    type      = type,
    category  = category,
    api_link  = api_link,
    site_link = site_link
  )

  # Replace existing row with same dataset name, or append
  existing <- which(!is.na(.api_registry$dataset) &
                      .api_registry$dataset == dataset)
  if (length(existing) > 0) {
    .api_registry[existing[1], ] <<- new_row
    message("Updated existing entry: ", dataset)
  } else {
    .api_registry <<- dplyr::bind_rows(.api_registry, new_row)
    message("Added new entry: ", dataset)
  }
  invisible(NULL)
}


#' List all dataset names in the registry
#'
#' @return A character vector of dataset names (may include `NA` entries).
#' @export
list_api_endpoints <- function() {
  .api_registry$dataset
}


#' Reset API registry to the built-in defaults
#'
#' Discards any custom entries added with `add_api_url()` and restores the
#' original registry bundled with the package.
#'
#' @return `NULL` invisibly.
#' @export
reset_api_urls <- function() {
  .api_registry <<- .default_api_registry
  message("API registry reset to defaults (", nrow(.api_registry), " entries).")
  invisible(NULL)
}


#' Open the Data Lake Portal page for a dataset in the browser or viewer
#'
#' Looks up the `site_link` for a dataset by name and opens it in the system's
#' default browser (non-interactive) or the RStudio / Positron viewer pane
#' (interactive session).
#'
#' @param name Character. The exact dataset name as listed in the registry
#'   (see [get_api_registry()]). Case-sensitive.
#' @param browser Logical. If `TRUE`, always open in the system browser even in
#'   interactive sessions. Default `FALSE`.
#'
#' @return `NULL` invisibly.
#' @export
view_site <- function(name, browser = FALSE) {
  row <- .api_registry[!is.na(.api_registry$dataset) &
                         .api_registry$dataset == name, ]

  if (nrow(row) == 0) {
    stop("No registry entry found for: ", name)
  }

  url <- row$site_link[[1]]

  if (is.na(url) || !nzchar(url)) {
    stop("No site_link available for: ", name)
  }

  if (!browser && interactive() && requireNamespace("utils", quietly = TRUE)) {
    utils::browseURL(url)
  } else {
    utils::browseURL(url)
  }

  message("[daclakeapi] Opening: ", url)
  invisible(NULL)
}


#' Update the API registry by re-fetching the source Google Sheet
#'
#' Downloads fresh data from the package's built-in Google Sheet URL
#' (`\link{.GSHEET_URL}`) and replaces the mutable registry. Requires the
#' \pkg{googlesheets4} package and network access.
#'
#' @param quiet Logical. If `TRUE`, suppress status messages. Default `FALSE`.
#'
#' @return `NULL` invisibly. The internal registry is updated in-place.
#' @export
update_registry <- function(quiet = FALSE) {
  if (!requireNamespace("googlesheets4", quietly = TRUE)) {
    stop("Package 'googlesheets4' is required. Install it with: install.packages('googlesheets4')")
  }

  if (!quiet) message("Fetching registry from Google Sheet: ", .GSHEET_URL)

  googlesheets4::gs4_deauth()

  conv <- googlesheets4::read_sheet(.GSHEET_ID, sheet = "Convergence")
  anal <- googlesheets4::read_sheet(.GSHEET_ID, sheet = "Analytics and Rltx")

  conv_df <- conv |>
    dplyr::filter(!is.na(`API Link`)) |>
    dplyr::transmute(
      dataset   = `Title of Dataset`,
      type      = "Convergence",
      category  = `Sub-theme`,
      api_link  = `API Link`,
      site_link = `Data Lake Portal Link`
    )

  anal_df <- anal |>
    dplyr::filter(!is.na(`API Link`)) |>
    dplyr::transmute(
      dataset   = `Title of Dataset`,
      type      = "Analytics and Rltx",
      category  = Categories,
      api_link  = `API Link`,
      site_link = `Data Lake Portal Link`
    )

  .api_registry <<- dplyr::bind_rows(conv_df, anal_df)

  if (!quiet) {
    message("Registry updated: ", nrow(.api_registry), " entries loaded.")
  }
  invisible(NULL)
}
