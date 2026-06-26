# ---------------------------------------------------------------------------
# Registry setter — works in locked installed namespaces
# ---------------------------------------------------------------------------

#' Assign a new value to data_registry in the package namespace
#' @keywords internal
.set_registry <- function(value) {
  ns <- getNamespace("daclakeapi")
  unlockBinding("data_registry", ns)
  assign("data_registry", value, envir = ns)
  lockBinding("data_registry", ns)
  invisible(value)
}

# ---------------------------------------------------------------------------
# camelCase converter
# ---------------------------------------------------------------------------

#' Convert a string to lowerCamelCase
#'
#' Strips all non-alphanumeric characters (treating them as word separators),
#' collapses whitespace, then joins words with the first word fully lowercase
#' and each subsequent word title-cased.
#'
#' @param x Character vector.
#' @return Character vector of camelCase strings.
#' @keywords internal
.to_camel_case <- function(x) {
  vapply(x, function(nm) {
    if (is.na(nm)) return(NA_character_)
    nm <- gsub("[^[:alnum:] ]", " ", nm)
    nm <- gsub("\\s+", " ", trimws(nm))
    words <- strsplit(nm, " ")[[1L]]
    words <- words[nzchar(words)]
    if (length(words) == 0L) return(NA_character_)
    words[1L] <- tolower(words[1L])
    if (length(words) > 1L) {
      words[-1L] <- paste0(
        toupper(substr(words[-1L], 1L, 1L)),
        tolower(substr(words[-1L], 2L, nchar(words[-1L])))
      )
    }
    paste(words, collapse = "")
  }, character(1L), USE.NAMES = FALSE)
}

# ---------------------------------------------------------------------------
# Label map  (raw Google Sheet name -> short human-readable display label)
# ---------------------------------------------------------------------------

.DATASET_LABEL_MAP <- c(
  "Rice Output vs per Capita by Reg (NRP_FNRI)"                                                      = "Rice Output vs Per Capita",
  "Double Dry & Special Project (NIA)"                                                                = "Double Dry Special Project",
  "Fy 2025 Performance (FOS_OSIRIS)"                                                                  = "FY2025 Performance",
  "RCEF seed distribution reports 2025 WS-2026 DS"                                                    = "RCEF Seed Distribution 2025",
  "Dry Season AR Jan - June (FOS)"                                                                    = "DS Accomplishment Report",
  "Rice Planting AR 2025 (FOS)"                                                                       = "Rice Planting AR",
  "Rice Standing Crops (FOS)"                                                                         = "Rice Standing Crops",
  "Wet Season  AR (FOS)"                                                                              = "WS Accomplishment Report",
  "DA Damages report"                                                                                 = "DA Damages",
  "Rice Movement (Local & Imported) Distribution (NFA)"                                               = "Rice Movement NFA",
  "Average Farmgate Prices (NFA)"                                                                     = "Farmgate Prices NFA",
  "Palay Price Monitoring (FOS)"                                                                      = "Palay Price Monitoring",
  "Average Retail Prices (AMAS)"                                                                      = "Retail Prices AMAS",
  "International Rice Prices (FTI)"                                                                   = "Intl Rice Prices FTI",
  "Machine Inventory by brgy (BAFE)"                                                                  = "Machine Inventory BAFE",
  "Agri Machineries and Infrastructure by brgy (BAFE)"                                                = "Agri Machineries BAFE",
  "Data Submission for Rice Command Center by brgy (BAFE)"                                            = "Rice Command Center BAFE",
  "Polished Machine Inventory Report of PAFMECHD (PhilMech)"                                         = "Machine Inventory PAFMECHD",
  "Polished Machine Inventory Report of RAFMES excluding RCEF (PhilMech)"                             = "Machine Inventory RAFMES",
  "Rice Farmers\u2019 Loan Data (ACPC)"                                                               = "Farmers Loan ACPC",
  "Rice Farmers\u2019 Loan Data Detailed (ACPC)"                                                      = "Farmers Loan Detailed ACPC",
  "Rice Farmers??? Loan Data (ACPC)"                                                                   = "Farmers Loan ACPC",
  "Rice Farmers??? Loan Data Detailed (ACPC)"                                                          = "Farmers Loan Detailed ACPC",
  "Rice Program AR from 2020-2025 (FOS)"                                                             = "Rice Program AR 2020 2025",
  "Status of Irrigation Development by 2023 (NIA)"                                                   = "Irrigation Development 2023",
  "GAA Combined extracted by Analytics"                                                              = "GAA Combined Convergence",
  "Growth Stages for analytics"                                                                       = "Growth Stages Convergence",
  "PAY PRISM data"                                                                                    = "PAY PRISM Convergence",
  "RIce Imports by Station and Country 2024-2026"                                                     = "Rice Imports By Station",
  "Monthly Fuel Price from 1990-2026 latest"                                                          = "Monthly Fuel Price",
  "VRA data"                                                                                          = "VRA",
  "Corn demand data"                                                                                  = "Corn Demand",
  "Corn production time series"                                                                       = "Corn Production",
  "Corn SUA time series"                                                                              = "Corn SUA",
  "Per capita restructured data"                                                                      = "Per Capita",
  "CnR Data"                                                                                          = "CnR",
  "Bantay Palay Data"                                                                                 = "Bantay Palay",
  "Fertilizer imports"                                                                                = "Fertilizer Imports",
  "cropping_intensity_restructured_mun_long"                                                          = "Cropping Intensity Mun",
  "nutrients_restructured_mun_long(rcef)"                                                             = "RCEF Nutrients Mun",
  "convergence_droughtSRA_updatedtable"                                                               = "Drought SRA",
  "vra_flood_restructured_longformat(muni_to_nat_level)"                                              = "VRA Flood Mun Nat",
  "PAY PSA data Quarter, Sem,Annual (1970-2026)"                                                      = "PAY PSA",
  "Relative Oceanic Ni\u00f1o Index (RONI): The three month running average of the relative Ni\u00f1o 3.4 index" = "RONI",
  "Relative Oceanic Ni??o Index (RONI): The three month running average of the relative Ni??o 3.4 index"          = "RONI",
  "Price Monitoring Of Liquid Fuels NCR (weekly- 2021 up to latest data)"                            = "Fuel Prices NCR Weekly",
  "GAA Allocation From NRP"                                                                           = "GAA Allocation NRP"
)

# ---------------------------------------------------------------------------
# Key overrides  (label or raw name -> explicit camelCase key)
# Applied AFTER auto camelCase to: (a) assign "Old" suffix to legacy endpoints
# that would clash with newer analytics keys, (b) fix edge-case auto results.
# ---------------------------------------------------------------------------

.DATASET_KEY_OVERRIDES <- c(
  # ---- retain old API names ------------------
  "pay_psa"          = "pay_psa",
  "pay_prism"        = "pay_prism",
  "wholesale_prices" = "wholesale_prices",
  "retail_prices"    = "retail_prices",
  "farmgate_prices"  = "farmgate_prices",
  "gdp"              = "gdp",
  "oil_price"        = "oil_price",
  "seed_class"       = "seed_class",
  "soil_type"        = "soil_type",
  "urea_use"         = "urea_use",
  "us_cpi"           = "us_cpi",
  "imports"          = "imports",
  "exrates"          = "exrates",
  "beginning_stocks" = "beginning_stocks",
  "ending_stocks"    = "ending_stocks",
  "corn_price"       = "corn_price",
  "cropestab"        = "cropestab",
  "urea_price"       = "urea_price",
  "vfa_fob_prices"   = "vfa_fob_prices",
  "fao_fob_prices"   = "fao_fob_prices",
  "popn"             = "popn",
  "rice_area"        = "rice_area",
  "rice_consum"      = "rice_consum",
  "totalstocks"      = "totalstocks",
  # ---- Disambiguation: duplicates resolved via .key_src tag in registry.R -
  "Pay Prism KPI"    = "payPrismKpi",
  "Seed Class RB"    = "seedClassRb"
)

# ---------------------------------------------------------------------------
# Public helpers
# ---------------------------------------------------------------------------

#' Resolve a raw Google Sheet name to a short human-readable display label.
#' Names not present in .DATASET_LABEL_MAP are returned unchanged.
#' @keywords internal
.get_dataset_label <- function(x) {
  idx <- match(x, names(.DATASET_LABEL_MAP))
  out <- x
  has <- !is.na(idx)
  out[has] <- .DATASET_LABEL_MAP[idx[has]]
  out
}

#' Convert a display label to a unique lowerCamelCase API key.
#' Applies explicit overrides from .DATASET_KEY_OVERRIDES first, then
#' falls back to automatic camelCase conversion via .to_camel_case().
#' @keywords internal
.get_dataset_key <- function(x) {
  keys <- .to_camel_case(x)
  idx  <- match(x, names(.DATASET_KEY_OVERRIDES))
  has  <- !is.na(idx)
  keys[has] <- .DATASET_KEY_OVERRIDES[idx[has]]
  keys
}

#' Normalize dataset names using the built-in label map (legacy alias).
#' @keywords internal
.normalize_dataset_names <- function(x) .get_dataset_label(x)

# ---------------------------------------------------------------------------
# Registry row resolver — accepts dataset key OR short_endpoint
# ---------------------------------------------------------------------------

#' Resolve a registry row by dataset key or short_endpoint
#'
#' Looks up `name` first against `dataset` (camelCase key), then against
#' `short_endpoint` (e.g. `"convergence_sua"`). Returns the first matching
#' row as a one-row tibble, or stops with an informative error.
#'
#' @param name Character. A dataset key or short_endpoint string.
#' @return A one-row tibble from `data_registry`.
#' @keywords internal
.resolve_registry_row <- function(name) {
  # 1. try dataset key (primary)
  row <- data_registry[!is.na(data_registry$dataset) &
                         data_registry$dataset == name, ]
  if (nrow(row) > 0) return(row[1L, ])

  # 2. try short_endpoint (secondary)
  if (!is.null(data_registry$short_endpoint)) {
    row <- data_registry[!is.na(data_registry$short_endpoint) &
                           data_registry$short_endpoint == name, ]
    if (nrow(row) > 0) return(row[1L, ])
  }

  stop(
    "No API entry found for: ", name, "\n",
    "  Tip: use get_api_registry() or list_api_endpoints() to browse valid names."
  )
}
