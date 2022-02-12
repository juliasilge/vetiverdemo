library(tidyverse)
superbowl_ads_raw <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-03-02/youtube.csv')

superbowl_ads <-
    superbowl_ads_raw %>%
    select(funny:animals, like_count) %>%
    na.omit()

library(tidymodels)

rf_spec <- rand_forest(mode = "regression")
rf_form <- like_count ~ .

rf_fit <-
    workflow(rf_form, rf_spec) %>%
    fit(superbowl_ads)

library(vetiver)
v <- vetiver_model(rf_fit, "superbowl_rf")

library(plumber)
pr() %>%
    vetiver_api(v, debug = TRUE) %>%
    pr_run(port = 8088)
