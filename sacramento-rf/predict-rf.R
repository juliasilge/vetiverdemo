library(tidyverse)
library(vetiver)

endpoint <- vetiver_endpoint("https://colorado.rstudio.com/rsc/sac_rf_api/predict")
endpoint

new_sac <- Sacramento %>%
    slice_sample(n = 20) %>%
    select(type, sqft, beds, baths)

predict(endpoint, new_sac)
