library(vetiver)
library(pins)
board <- board_connect()
pin_example_kc_housing_model(board, "julia.silge/seattle_rf")
## vanity URL is /seattle-housing-pin/

vetiver_deploy_rsconnect(board, "julia.silge/seattle_rf")
