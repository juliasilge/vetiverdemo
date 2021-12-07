library(tidymodels)
data(Sacramento)

rf_spec <- rand_forest(mode = "regression")
rf_form <- price ~ type + sqft + beds + baths

rf_fit <-
    workflow(rf_form, rf_spec) %>%
    fit(Sacramento)

library(vetiver)
v <- vetiver_model(rf_fit, "sacramento_rf")
v

library(pins)
model_board <- board_rsconnect()
model_board %>% vetiver_pin_write(v)

vetiver_deploy_rsconnect(
    model_board,
    "julia.silge/sacramento_rf",
    predict_args = list(debug = TRUE),
    account = "julia.silge"
)

