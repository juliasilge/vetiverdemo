## https://colorado.rstudio.com/rsc/sac_rf_api/

library(tidymodels)
data(Sacramento)

rf_spec <- rand_forest(mode = "regression")
rf_form <- price ~ type + sqft + beds + baths

rf_fit <-
    workflow(rf_form, rf_spec) %>%
    fit(Sacramento)

library(vetiver)
v <- vetiver_model(rf_fit, "julia.silge/sacramento-rf")
v

library(pins)
model_board <- board_rsconnect()
model_board %>% vetiver_pin_write(v)

vetiver_deploy_rsconnect(
    model_board,
    "julia.silge/sacramento-rf",
    predict_args = list(debug = TRUE),
    appId = 10355,
    account = "julia.silge",
    server = "colorado.posit.co"
)

