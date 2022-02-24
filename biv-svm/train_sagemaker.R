library(tidymodels)
data(bivariate)

biv_rec <-
    recipe(Class ~ ., data = bivariate_train) %>%
    step_BoxCox(all_predictors())%>%
    step_normalize(all_predictors())

svm_spec <-
    svm_linear(mode = "classification") %>%
    set_engine("LiblineaR")

svm_fit <- workflow() %>%
    add_recipe(biv_rec) %>%
    add_model(svm_spec) %>%
    fit(bivariate_train)

library(vetiver)
v <- vetiver_model(svm_fit, "biv_svm")
v

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

model_board <- board_s3(bucket = identifier, prefix = "pins/")
vetiver_pin_write(model_board, v)

## again!
vetiver_pin_write(model_board, v)

## again!!
vetiver_pin_write(model_board, v)

vetiver_write_plumber(
    model_board,
    "biv_svm",
    type = "class",
    debug = TRUE,
    file = "biv-svm/plumber.R"
)
vetiver_write_docker(v, "biv-svm/plumber.R", "biv-svm/")

container_registry <- ecr()
container_registry$create_repository(repositoryName = identifier)
container_registry$describe_images(repositoryName = identifier)
