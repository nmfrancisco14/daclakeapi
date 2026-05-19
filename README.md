# daclakeapi

`daclakeapi` is an R package for accessing rice-related datasets from the DAC Data Lake API.
It provides a built-in registry of API endpoints and helper functions to:

- fetch a single dataset by name
- fetch all (or selected) datasets in one call
- filter API requests
- manage and refresh the endpoint registry
- open dataset portal pages from the registry

## Installation

```r
install.packages("devtools")
devtools::install_github("nmfrancisco14/daclakeapi")
```

## Setup

Set your API key in `.Renviron`:

```r
usethis::edit_r_environ()
```

Add:

```text
lakeAPIkey=your_api_key_here
```

Then restart R.

## Quick start

```r
library(daclakeapi)

# View registry
registry <- get_api_registry()

# List dataset names
endpoints <- list_api_endpoints()

# Get one dataset
retail_prices <- get_api_data("Retail Prices")

# Get one dataset with filters
filtered_data <- get_api_data(
  "Retail Prices",
  filters = list(
    list(column = "year", operator = "=", value = "2024")
  )
)

# Get all datasets (or pass a subset of names)
all_results <- get_all_api_data()

# Split successful and failed requests
successful <- Filter(is.data.frame, all_results)
failed <- Filter(is.character, all_results)
```

## Main functions

- `get_api_registry()`: return the current endpoint registry
- `list_api_endpoints()`: list all dataset names in the registry
- `get_api_url(name)`: get the API URL for a dataset name
- `get_api_data(name, ...)`: fetch one dataset by name
- `get_all_api_data(...)`: fetch all or selected datasets
- `add_api_url(...)`: add or override a registry entry
- `reset_api_urls()`: reset registry to package defaults
- `update_registry()`: refresh registry from the source Google Sheet
- `view_site(name)`: open a dataset portal page from `site_link`
- `summarize_latest_dates(data)`: summarize latest available dates

## Notes

- `get_all_api_data()` returns a named list.
- Successful requests are returned as data frames.
- Failed requests are returned as error-message strings, so one failed endpoint does not stop the whole run.

## License

MIT
