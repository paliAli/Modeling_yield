##%######################################################%##
#                                                          #
####           Obtain Development stage (DVS)           ####
#                                                          #
##%######################################################%##

#-----------------------------------------------------------
  # Written by Alena Pavlackova
  # ETH Biogeochemical modeling group project
  
  # The script prepares the weather data
  # and calculates the development stages based on cumulative temperature
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

weather$Date <- as.Date(weather$Date, format = "%Y-%m-%d")

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

# Add a growing season identifier based on sowing dates
DVS_weather <- weather %>%
  group_by(ID) %>%
  arrange(Date) %>%
  mutate(
    # Assign Season_ID
    Season_ID = sapply(Date, function(date) {
      # Obtain year from Date
      year <- as.numeric(format(date, "%Y"))
      # Obtain month from Date
      month <- as.numeric(format(date, "%m"))
      # Obtain day from Date
      day <- as.numeric(format(date, "%d"))
      # Check if there are valid sowing date
      if (month >= 10) {
        return(year)
          } else{
            return(year - 1)
          }})) %>%
  ungroup()


unique(DVS_weather$Season_ID) # Check the unique season IDs

# Compute TSUM and DVS for each location per growing season
DVS_weather <- DVS_weather %>%
  group_by(ID, Season_ID) %>%
  arrange(Date) %>%
  mutate(
    TSUM = cumsum(Tmean), # Calculate cumulative sum of temperatures
    DVS_stage = approx(x = TSUM_stages, y = DVS_stages, xout = TSUM, rule = 2)$y # Interpolate DVS
  ) %>%
  ungroup()

str(DVS_weather)
summary(DVS_weather)

write.csv(DVS_weather, "Input_data/DVS_weather.csv", row.names = FALSE)

# Remove the year 2025
DVS_weather <- DVS_weather %>%
  filter(Season_ID != 2024)

# Visualize the development stages 
ggplot(data = DVS_weather, aes(x = Date, y = DVS_stage, color = ID)) +
 geom_line() +
 labs(title = "Development Stages (DVS) Over Time",
      x = "Date",
      y = "Development Stage (DVS)") +
 scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") + # Show date each 3 months, starting from October
 theme_minimal() +
 theme(legend.position = "none")  + 
  theme(axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(vjust = 0.35, angle = 15),
    plot.title = element_text(size = 15), # Remove legend for clarity
    plot.margin = margin(10, 10, 10, 10))


# weather_subset <- DVS_weather[DVS_weather$ID == Unique_ID[1],]
