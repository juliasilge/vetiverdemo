library(vetiver)
data(bivariate, package = "modeldata")

endpoint <- vetiver_endpoint("http://127.0.0.1:8088/predict")
endpoint

predict(endpoint, bivariate_test)
