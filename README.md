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

# List dataset names or short endpoints
dataset_names <- list_api_endpoints( type = "dataset") #dataset names
short_endpoints <- list_api_endpoints(type = "short_endpoint") #short endpoints

# Get one dataset either by name or short endpoint
Imports <- get_api_data("importsNrp") #using dataset name
Imports <- get_api_data("analyticsapi_imports_nrp") #using short endpoint

# Get one dataset with filters
filtered_costret <- get_api_data(
  "cnr",
  filters = list(
    list(column = "year", operator = "=", value = "2025"),
    list(column = "psgc_code", operator = "=", value = "PHL"),
    list(column ="season", operator = "in", value = c("Dry","Wet")) #selecting multiple values
  )
)

# For large datasets,fetch as CSV
psa_pay<- get_api_data("psaPayData", structure = "csv")

# Get all datasets (or pass a subset of names) . SLOW AND MAY TAKE A WHILE!
all_results <- get_all_api_data()

# Split successful and failed requests
successful <- Filter(is.data.frame, all_results)
failed <- Filter(is.character, all_results)
```

## Main functions

- `get_api_registry()`: return the current endpoint registry
- `list_api_endpoints()`: list all dataset names and short endpoints in the registry
- `get_api_url(name)`: get the API URL for a dataset name /endpoint
- `get_api_data(name, ...)`: fetch one dataset by name/endpoint
- `get_all_api_data(...)`: fetch all or selected datasets
- `add_api_url(...)`: add or override a registry entry
- `reset_api_urls()`: reset registry to package defaults
- `update_registry()`: refresh registry from the source Google Sheet
- `view_site(name)`: open a dataset portal page from `site_link`
- `search_registry()`: search the registry by keyword
- `summarize_latest_dates(data)`: summarize latest available dates

## Notes

- `get_all_api_data()` returns a named list.
- Successful requests are returned as data frames.
- Failed requests are returned as error-message strings, so one failed endpoint does not stop the whole run.
- All old endpoint names from previous versions are still supported, so existing `get_api_data()` calls should continue to work.

- However, `get_all_api_data()` now attempts to load all 214 datasets (not just the previous 24). This can be much slower and memory-intensive, especially for large datasets.


## API error codes

When a request fails, the API returns an HTTP status code. The table below summarises the most common ones and what they mean in this context. For more info, ask **master Dexter**.

| Status code | Meaning | Typical cause | What to do |
|---|---|---|---|
| `400 Bad Request` | Malformed request | Invalid filter syntax, unrecognised column name, or bad `operator` value | Check your `filters` list — column names and operators must exactly match the API schema. ~ It's you, not me |
| `401 Unauthorized` | Missing or invalid API key | `lakeAPIkey` env var not set, or the key has expired | Run `usethis::edit_r_environ()`, confirm `lakeAPIkey=...` is present, and restart R |
| `403 Forbidden` | Key valid but access denied | Your key does not have permission for this endpoint | Contact **Master Dexter** |
| `404 Not Found` | Endpoint URL not found | The `api_link` in the registry is outdated or the dataset was moved | URL is invalid or was changed, feedback to Me. |
| `429 Too many Requests` | Too many data requests | Server Issue | Chillax, akala nila bot ka. Wait a few minutes then try again. |
| `503 Service Unavailable` | Server overloaded or down | High traffic or scheduled maintenance | Mag health hour na muna, then try again later |

### Handling errors in code

`get_api_data()` will stop with an R error on non-200 responses.  
`get_all_api_data()` catches these per-dataset and returns the error message string instead of a data frame, so one bad endpoint does not abort the whole batch:

```r
results <- get_all_api_data()

successful <- Filter(is.data.frame, results)   # data frames only
failed     <- Filter(is.character, results)    # error strings only

# Inspect which endpoints failed and why
failed
```

## License

MIT
