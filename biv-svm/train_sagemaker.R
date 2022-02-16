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

bucket <- glue("sagemaker-vetiver-", ids::adjective_animal(style = "kebab"))
svc <- s3()
svc$create_bucket(
    Bucket = bucket,
    CreateBucketConfiguration = list(LocationConstraint = "us-east-2")
)

model_board <- board_s3(bucket = bucket, prefix = "pins/")
vetiver_pin_write(model_board, v)

## again!
vetiver_pin_write(model_board, v)

## again!!
vetiver_pin_write(model_board, v)

library(plumber)
pr() %>%
    vetiver_api(v, type = "class", debug = TRUE) %>%
    pr_run(port = 8088)
