library(tidymodels)
library(recipes)
library(agua)
library(h2o)
library(vetiver)
library(pins)

h2o.init()

data(concrete)
set.seed(4595)
concrete_split <- initial_split(concrete, strata = compressive_strength)
concrete_train <- training(concrete_split)
concrete_test <- testing(concrete_split)

auto_spec <-
    auto_ml() |>
    set_engine("h2o", max_runtime_secs = 120, seed = 1) |>
    set_mode("regression")

normalized_rec <-
    recipe(compressive_strength ~ ., data = concrete_train) |>
    step_normalize(all_predictors())

auto_wflow <-
    workflow() |>
    add_model(auto_spec) |>
    add_recipe(normalized_rec)

auto_fit <- fit(auto_wflow, data = concrete_train)
v <- vetiver_model(auto_fit, "julia.silge/concrete_h2o")
v

model_board <- board_connect()
model_board |> vetiver_pin_write(v)
