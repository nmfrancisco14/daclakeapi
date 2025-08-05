# 📦 daclakeapi: A Lightweight Helper to Access API Endpoints

`daclakeapi` is a simple R package that provides access to various rice-related  datasets from DAC Data Lake via API, including wholesale, retail, farmgate prices, exchange rates, and FOB prices. Users can retrieve data by endpoint or in bulk, extend the API registry with their own endpoints, and summarize recent update dates for each dataset.

## 🔧 Installation

You can install the development version of this package directly from GitHub:

```r
# Install devtools if not already installed
install.packages("devtools")

# Install this package from GitHub
devtools::install_github("nmfrancisco14/daclakeapi")
