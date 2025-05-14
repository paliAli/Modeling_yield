##%######################################################%##
#                                                          #
####                  Provide Weather                   ####
#                                                          #
##%######################################################%##

-----------------------------------------------------------
  # ETH Biogeochemical modeling group project
  
  # The script provides daily weather data
  -----------------------------------------------------------

# Load the required libraries ----
install.packages("nasapower")
library(nasapower)
library(dplyr)
library(lubridate)

# Define the main variables ----
# Define the longtitude and latitude of europa （i dont know how to get the lonlat from gps?）
latitudes <- seq(35, 72, by = 1) # Just to check - need to change later
longitudes <- seq(-30, 50, by = 1) 

# Define a sowing date and a harvest date
startDate <- "2024-01-01"
endDate <- "2025-01-01"
dates <- c(startDate, endDate)

# Download the data from NASA POWER ----
Variables <- c("ALLSKY_SFC_SW_DWN", "PRECTOTCORR", "RH2M", "T2MDEW", "T2M_MAX", "T2M_MIN", "WS2M")
VarName <- c("Solar", "ppt", "RH", "Tdew", "Tmax", "Tmin", "windspeed")

# Download the data from NASA POWER
Europe_weather_data <- data.frame()

for (lat in latitudes) {
  for (lon in longitudes) {
    data <- nasapower::get_power(
      community = "ag",
      lonlat = c(lon, lat),
      pars = Variables,
      dates = dates, 
      temporal_api = "daily"
    )
    
    # Rename columns using VarName
    names(data)[names(data) %in% Variables] <- VarName
    
    Europe_weather_data <- rbind(Europe_weather_data, data)
  }
}

# Edit the data frame ----
summary(Europe_weather_data)
class(Europe_weather_data$YYYYMMDD)
# Rename YYYYMMDD to date
colnames(Europe_weather_data)[colnames(Europe_weather_data) == "YYYYMMDD"] <- "Date"

# Calculate average temperature 
Europe_weather_data <- Europe_weather_data %>%
  mutate(
    Tmean = (Tmax + Tmin) / 2
  )

#save the data
write.csv(Europe_weather_data, "~/Github/Modeling_yield/Europe_weather_data.csv", row.names = FALSE)

# Create a data frame for each pixel (lon and lat pair)
