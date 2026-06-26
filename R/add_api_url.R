#' Get API registry as a data frame
#'
#' Returns the current API registry as a tibble with columns:
#' \describe{
#'   \item{`dataset`}{lowerCamelCase API key used in [get_api_data()].}
#'   \item{`label`}{Human-readable display name for the dataset.}
#'   \item{`type`}{Sheet source: `"Convergence"`, `"Analytics and Rltx"`, or `"Old API list"`.}
#'   \item{`category`}{Sub-theme (Convergence) or category (Analytics and Rltx).}
#'   \item{`api_link`}{API endpoint URL.}
#'   \item{`site_link`}{Data Lake Portal URL.}
#' }
#'
#' @return A tibble of all registered API endpoints.
#' @export
get_api_registry <- function() {
  data_registry
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
    row <- data_registry[name, ]
    if (nrow(row) == 0) stop("Row index out of range: ", name)
  } else {
    # accepts dataset key OR short_endpoint
    row <- .resolve_registry_row(name)
  }
  row$api_link[[1]]
}


#' Add or override an API entry in the registry
#'
#' Adds a new row to the mutable API registry, or replaces an existing entry
#' with the same `dataset` name if one exists.
#'
#' @param dataset Character. lowerCamelCase key used to call [get_api_data()].
#'   If omitted, auto-generated from `label` via camelCase conversion.
#' @param api_link Character. The API endpoint URL.
#' @param label Character. Human-readable display name. Defaults to `dataset`.
#' @param type Character. Sheet source label (default `"Custom"`).
#' @param category Character. Category or sub-theme label (default `NA`).
#' @param site_link Character. Data Lake Portal URL (default `NA`).
#'
#' @return `NULL` invisibly. Modifies the internal registry.
#' @export
add_api_url <- function(dataset, api_link, label = dataset, type = "Custom",
                        category = NA_character_, site_link = NA_character_) {
  if (!is.character(dataset) || !is.character(api_link)) {
    stop("`dataset` and `api_link` must be character strings.")
  }

  short_endpoint = if(stringr::str_detect(api_link, "/dynamic/")) {
    stringr::str_extract(api_link, "(?<=dynamic/).*")
  } else {
    stringr::str_extract(api_link, "(?<=api/).*")
  }
    

  new_row <- tibble::tibble(
    dataset   = dataset,
    label     = label,
    type      = type,
    category  = category,
    api_link  = api_link,
    site_link = site_link,
    short_endpoint = short_endpoint
  )

  # Replace existing row with same dataset name, or append
  existing <- which(!is.na(data_registry$dataset) &
                      data_registry$dataset == dataset)
  if (length(existing) > 0) {
    updated <- data_registry
    updated[existing[1], ] <- new_row
    .set_registry(updated)
    message("Updated existing entry: ", dataset)
  } else {
    .set_registry(dplyr::bind_rows(data_registry, new_row))
    message("Added new entry: ", dataset)
  }
  invisible(NULL)
}


#' List all dataset names in the registry
#'
#' @return A character vector of dataset names (may include `NA` entries).
#' @export
list_api_endpoints <- function(type = "dataset") {

  if (type =="dataset") {
  data_registry$dataset
  } else if (type == "short_endpoint") {
    data_registry$short_endpoint
  } else {
    stop("Invalid type: ", type, ". Use 'dataset' or 'short_endpoint'.")
  }
}


#' Reset API registry to the built-in defaults
#'
#' Discards any custom entries added with `add_api_url()` and restores the
#' original registry bundled with the package.
#'
#' @return `NULL` invisibly.
#' @export
reset_api_urls <- function() {
  .set_registry(data_registry)
  message("API registry reset to defaults (", nrow(data_registry), " entries).")
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
  # accepts dataset key OR short_endpoint
  row <- .resolve_registry_row(name)

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
#' @param gsheet_url Character. The Google Sheet URL to fetch the registry from.
#'   Defaults to the built-in URL (`.GSHEET_URL`).
#'
#' @return `NULL` invisibly. The internal registry is updated in-place.
#' @export
update_registry <- function(gsheet_url = GSHEET_URL) {
  if (!requireNamespace("googlesheets4", quietly = TRUE))
    stop("Install googlesheets4: install.packages('googlesheets4')")

  googlesheets4::gs4_deauth()
  id <- googlesheets4::as_sheets_id(gsheet_url)

  read_sheet_safe <- function(sheet, type_val) {
    tryCatch({
      df <- googlesheets4::read_sheet(id, sheet = sheet, col_types = "c")
      df <- df[!is.na(df[["API Link"]]) & nchar(trimws(df[["API Link"]])) > 0, ]

      # Case-insensitive column lookup with NULL-safe fallback
      .col <- function(data, ...) {
        candidates <- c(...)
        col_names_lower <- tolower(names(data))
        for (nm in tolower(candidates)) {
          idx <- match(nm, col_names_lower)
          if (!is.na(idx)) return(trimws(as.character(data[[idx]])))
        }
        rep(NA_character_, nrow(data))   # column not found → all NA
      }

      cat_col <- if (type_val == "Convergence") c("subtheme", "sub-theme", "sub theme") else c("categories")

      tibble::tibble(
        dataset  = .col(df, "shortname"),
        label     = .col(df, "title of dataset"),
        type      = type_val,
        category  = .col(df, cat_col),
        api_link  = .col(df, "api link"),
        site_link = .col(df, "data lake portal link")
      )
    }, error = function(e) {
      warning("Could not read sheet '", sheet, "': ", conditionMessage(e))
      NULL
    })
  }

  fresh <- dplyr::bind_rows(
    read_sheet_safe("Convergence",       "Convergence"),
    read_sheet_safe("Analytics & Rltx","Analytics and Rltx")
  )

  if (is.null(fresh) || nrow(fresh) == 0) {
    message("Registry update aborted: no data retrieved.")
    return(invisible(data_registry))
  }

  # --- Key stability: reuse existing keys matched by api_link ---
  existing_keys <- data_registry |>
    dplyr::select(api_link, dataset) |>
    dplyr::distinct()

  # fresh <- fresh |>
  #   dplyr::left_join(existing_keys, by = "api_link") |>
  #   dplyr::mutate(
  #     dataset = dplyr::case_when(
  #       # 1. preserved from existing registry (matched by api_link)
  #       !is.na(dataset) ~ dataset,
  #       # 2. override map (label-based fallback for known renames)
  #       label %in% names(.DATASET_KEY_OVERRIDES) ~ unname(.DATASET_KEY_OVERRIDES[label]),
  #       # 3. derive programmatically for brand-new entries
  #       TRUE ~ .to_camel_case(label)
  #     )
  #   )

  # Append the Old API list from the default registry (always stable)
  old_entries <- data_registry |>
    dplyr::filter(type == "Old API list") 

  updated <- dplyr::bind_rows(fresh, old_entries) |> 
    dplyr::mutate(
      short_endpoint =basename(api_link)
    )

  # Deduplicate keys — tag duplicates with a numeric suffix

  message("Detected ", sum(duplicated(updated$dataset))," dataset keys: ",
  paste(updated$dataset[duplicated(updated$dataset)], collapse = ", "))

  message("Deduplicating dataset keys by appending numeric suffixes for duplicates.")

  updated <- updated |>
    dplyr::group_by(dataset) |>
    dplyr::mutate(
      dataset = if (dplyr::n() > 1)
        paste0(dataset, dplyr::row_number())
      else
        dataset
    ) |>
    dplyr::ungroup()

  .set_registry(updated)

  message("Registry updated: ", nrow(data_registry), " endpoints loaded.")

  invisible(data_registry)
}
