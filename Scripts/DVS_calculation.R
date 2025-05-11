##%######################################################%##
#                                                          #
####           Obtain Development stage (DVS)           ####
#                                                          #
##%######################################################%##

?approx
# Load in crop data
crop <- source("~/GitHub/Modeling_yield/Input_data/crop_data.R")

# Define crop TSUM thresholds ----
TSUM_stages <- c(crop$value[["TSUMEM"]],crop$value[["TSUMEM"]] + crop$value[["TSUM1"]], crop$value[["TSUMEM"]] + crop$value[["TSUM1"]] + crop$value[["TSUM2"]]) # Cumulative TSUM values
DSV_stages <- c(0, 1, 2) # Corresponding development stages

