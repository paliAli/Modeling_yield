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
library(ggplot2)
library(dplyr)

# Prepare the data ----
# Set working directory 
setwd("~/GitHub/Modeling_yield")
# Load in crop data
crop <- source("Input_data/crop_data.R")

# Define crop TSUM thresholds ----
TSUM_stages <- c(crop$value[["TSUMEM"]],crop$value[["TSUMEM"]] + crop$value[["TSUM1"]], crop$value[["TSUMEM"]] + crop$value[["TSUM1"]] + crop$value[["TSUM2"]]) # Cumulative TSUM values
DVS_stages <- c(0, 1, 2) # Corresponding development stages

# Import the weather data
weather <- read.csv("Input_data/Europe_weather_data_test.csv")
weather <- weather[weather$YEAR == "2024",]

?cumsum
?approx

# Compute TSUM and DVS for each location
DVS <- weather %>%
  group_by(LON, LAT) %>%
  arrange(Date) %>%
  mutate(
    TSUM = cumsum(Tmean), # calculate cumulative sum of temperatures
    DVS_stage = approx(x = TSUM_stages, y = DVS_stages, xout = TSUM, rule = 2)$y # Interpolate DVS
  ) %>%
  ungroup()

# Visualize the development stages 
ggplot(data = DVS, aes(x = DOY, y = DVS_stage, color = paste(LON, LAT))) +
  geom_line() +
  labs(title = "Development Stages (DVS) Over Time",
       x = "DOY",
       y = "Development Stage (DVS)") +
  theme_minimal() +
  theme(legend.position = "none") # Remove legend for clarity

