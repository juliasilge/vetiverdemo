library(tidyverse)
library(vetiver)

endpoint <- vetiver_endpoint("https://colorado.rstudio.com/rsc/sac_rf_api/predict")
endpoint

data(Sacramento, package = "modeldata")
new_sac <- Sacramento %>%
    slice_sample(n = 20) %>%
    select(type, sqft, beds, baths)

apiKey <- Sys.getenv("CONNECT_API_KEY")
predict(endpoint, new_sac, httr::add_headers(Authorization = paste("Key", apiKey)))
