## https://colorado.rstudio.com/rsc/netflix-descriptions/

library(tidymodels)
library(textrecipes)
library(themis)

url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-20/netflix_titles.csv"

netflix_types <- readr::read_csv(url) %>%
    select(type, description)

set.seed(123)
netflix_split <- netflix_types %>%
    select(type, description) %>%
    initial_split(strata = type)

netflix_train <- training(netflix_split)
netflix_test <- testing(netflix_split)

netflix_rec <- recipe(type ~ description, data = netflix_train) %>%
    step_tokenize(description) %>%
    step_tokenfilter(description, max_tokens = 1e3) %>%
    step_tfidf(description) %>%
    step_normalize(all_numeric_predictors()) %>%
    step_smote(type)

svm_spec <- svm_linear() %>%
    set_mode("classification") %>%
    set_engine("LiblineaR")

netflix_fit <-
    workflow(netflix_rec, svm_spec) %>%
    fit(netflix_train)

library(vetiver)
v <- vetiver_model(netflix_fit, "netflix_descriptions")
v

## run aws configure sso

library(paws)
library(glue)
library(pins)
identifier <- glue::glue("vetiver-", ids::adjective_animal(style = "kebab"))
identifier <- as.character(identifier)
svc <- s3()
svc$create_bucket(
    Bucket = identifier,
    CreateBucketConfiguration = list(LocationConstraint = "us-east-2")
)

model_board <- board_s3(bucket = identifier)
vetiver_pin_write(model_board, v)

library(plumber)
pr() %>%
    vetiver_api(v, debug = TRUE) %>%
    pr_run(port = 8088)

vetiver_write_plumber(model_board, "netflix_descriptions", debug = TRUE)
vetiver_write_docker(v)

## Building Docker takes a while because installs all packages:
## docker build -t netflix-descriptions .
## docker run --rm -p 8787:8787 netflix-descriptions

