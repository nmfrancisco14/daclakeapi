# Default API URL map

.default_api_urls <- list(
  pay_psa = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/kpi_pay",
  pay_prism = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/kpi_pay_prism",
  wholesale_prices = "https://ricelytics.philrice.gov.ph/data_lake/api/wholesale_prices",
  fao_fob_prices = "https://ricelytics.philrice.gov.ph/data_lake/api/fob_prices",
  exrates = "https://ricelytics.philrice.gov.ph/data_lake/api/exchange_rate",
  retail_prices= "https://ricelytics.philrice.gov.ph/data_lake/api/retail_prices",
  farmgate_prices= "https://ricelytics.philrice.gov.ph/data_lake/api/farmgate_prices",
  vfa_fob_prices = "https://ricelytics.philrice.gov.ph/data_lake/api/fob_prices_vfa",
  beginning_stocks = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_beg_stocks",
  corn_price = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_corn_farmgate",
  cropestab = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_crop_estab",
  ending_stocks = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_end_stock",
  gdp = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_gdp",
  oil_price = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_oil_price",
  popn = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_ph_population",
  rice_area = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_riceArea_irrigated",
  rice_consum= "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_riceConsumption",
  seed_class = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_seedClass",
  soil_type = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_soilType",
  temp = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_temperature",
  urea_price = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_ureaPrices",
  urea_use = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_ureaUse",
  urea_use_sem = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_ureaUseSemestral",
  us_cpi = "https://ricelytics.philrice.gov.ph/data_lake/api/dynamic/analyticsapi_us_cpi"
)


# Mutable copy of the API registry
.api_url_registry <- .default_api_urls

