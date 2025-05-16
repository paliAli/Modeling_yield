##%######################################################%##
#                                                          #
####           Obtain Development stage (DVS)           ####
#                                                          #
##%######################################################%##

#-----------------------------------------------------------
  # Written by Alena Pavlackova
  # ETH Biogeochemical modeling group project
  
  # The script prepares the weather data
#-----------------------------------------------------------

# Required libraries -----
library(ggplot2)
library(dplyr)

# Prepare the data ----
# Set working directory 
setwd("~/GitHub/Modeling_yield")
# Load in crop data
source("Input_data/crop_data.R")

# Import the weather data
weather <- read.csv("Input_data/Europe_weather_data.csv")

# Calculate average temperature 
weather <- weather %>%
  mutate(
    Tmean = (Tmax + Tmin) / 2
  )

# Define crop TSUM thresholds ----
TSUM_stages <- c(crop$TSUMEM,crop$TSUMEM + crop$TSUM1, crop$TSUMEM + crop$TSUM1 + crop$TSUM2) # Cumulative TSUM values
DVS_stages <- c(0, 1, 2) # Corresponding development stages

# Create a identifier column for the weather
weather$ID <- paste0(weather$LON, "_", weather$LAT)

Unique_ID <- unique(weather$ID)




# Import the event_function
source("Input_data/Event_function.R")
# Import the sowing date function
source("Input_data/Sowing_dates_function.R")

# Compute TSUM and DVS for each location
#DVS_weather <- weather %>%
#  group_by(LON, LAT) %>%
#  arrange(Date) %>%
#  mutate(
#    TSUM = cumsum(Tmean), # calculate cumulative sum of temperatures
#    DVS_stage = approx(x = TSUM_stages, y = DVS_stages, xout = TSUM, rule = 2)$y # Interpolate DVS
#  ) %>%
#  ungroup()

#write.csv(DVS_weather, "Input_data/DVS_weather.csv", row.names = FALSE)

# Convert DVS_weather$Date to Date format
#DVS_weather$Date <- as.Date(DVS_weather$Date, format = "%Y-%m-%d")

# Visualize the development stages 
#ggplot(data = DVS_weather, aes(x = DOY, y = DVS_stage, color = paste(LON, LAT))) +
#  geom_line() +
#  labs(title = "Development Stages (DVS) Over Time",
#       x = "DOY",
#       y = "Development Stage (DVS)") +
#  theme_minimal() +
#  theme(legend.position = "none") # Remove legend for clarity


# weather_subset <- DVS_weather[DVS_weather$ID == Unique_ID[1],]
