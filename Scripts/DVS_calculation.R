##%######################################################%##
#                                                          #
####           Obtain Development stage (DVS)           ####
#                                                          #
##%######################################################%##

-----------------------------------------------------------
  # Written by Alena Pavlackova
  # ETH Biogeochemical modeling group project
  
  # The script calculates the total temperature sum
  # and changes the DVS accordingly
-----------------------------------------------------------

# Required libraries -----


# Prepare the data ----
# Set working directory 
setwd("~/GitHub/Modeling_yield")
# Load in crop data
crop <- source("Input_data/crop_data.R")
# Load in weather dara
weather <- 

# Define crop TSUM thresholds ----
TSUM_stages <- c(crop$value[["TSUMEM"]],crop$value[["TSUMEM"]] + crop$value[["TSUM1"]], crop$value[["TSUMEM"]] + crop$value[["TSUM1"]] + crop$value[["TSUM2"]]) # Cumulative TSUM values
DSV_stages <- c(0, 1, 2) # Corresponding development stages

?approx
