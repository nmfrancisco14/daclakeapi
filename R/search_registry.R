#' Search the API registry by keyword
#'
#' Searches all columns of the registry for one or more keywords and returns
#' the top matching rows. Matching is case-insensitive and partial.
#'
#' @param keywords Character. One or more keywords to search for. Multiple
#'   keywords are treated as AND conditions (all must match somewhere in the row).
#' @param n Integer. Maximum number of results to return. Default `5`. Set to `all` to return all matches.
#'
#' @return A tibble of matching registry rows, up to `n` rows.
#' @export
#'
#' @examples
#' search_registry("inflation")
#' search_registry("price convergence", n = 10)
#' search_registry(c("price", "retail"))
search_registry <- function(keywords, n = 5) {
  if (!is.character(keywords) || length(keywords) == 0)
    stop("`keywords` must be a non-empty character vector.")

  n <- if (n!="all") as.integer(n) else n
  reg <- .api_registry

  # Collapse all columns into one searchable string per row (lowercase)
  row_text <- apply(reg, 1, function(row) {
    paste(tolower(as.character(row)), collapse = " ")
  })

  # Split multi-word single string into individual tokens
  tokens <- unique(trimws(unlist(strsplit(tolower(keywords), "\\s+"))))
  tokens <- tokens[nzchar(tokens)]

  # AND logic: all tokens must appear somewhere in the row
  matches <- Reduce("&", lapply(tokens, function(tok) grepl(tok, row_text, fixed = TRUE)))

  result <- reg[matches, ]

  if (nrow(result) == 0) {
    message("No matches found for: ", paste(keywords, collapse = ", "))
    return(invisible(tibble::tibble()))
  }

  result <- if(n!="all") utils::head(result, n) else result
  message(nrow(result), " match(es) found for: ", paste(keywords, collapse = ", "))
  result
}