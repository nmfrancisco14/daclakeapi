#' Helper function to call API and return data frame SPECIFICALLY FOR UREA SEM DATA
#'
#' @param url API endpoint
#' @param key API key
#' @param mute_onSuccess Logical to suppress messages
#'
#' @return Data frame of parsed API result
#'

data_api_ureasem <- function(key, mute_onSuccess = TRUE) {

  response <- httr::GET(
    "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_ureaUseSemestral",
    httr::add_headers("Content-Type" = "application/json"),
    query = list(key = key)
  )


  if (httr::status_code(response) == 200) {
    if (!mute_onSuccess) {
      print("Request was successful!")
    }

    data <- httr::content(response, "text", encoding = "UTF-8")


    df <- read_csv(I(data))


    if (!mute_onSuccess) {
      print(head(df))
    }
  } else {
    print(paste("Request failed with status:", httr::status_code(response)))
    print(httr::content(response, "text", encoding = "UTF-8"))
    df <- NULL  # Prevent returning undefined object
  }

  return(df)

}
