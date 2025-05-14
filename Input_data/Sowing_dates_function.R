# Function to find the sowing date for a weather subset
find_sowing_date <- function(weather_data) {
  # Extract the unique years in the weather data
  unique_years <- unique(weather_data$YEAR)
  
  # Initialize an empty vector to store sowing dates
  sowing_dates <- c()
  
  # Loop through each year to find the closest date to September 30
  for (year in unique_years) {
    # Define the target sowing date (first of October)
    target_date <- as.Date(paste0(year, "-10-01"))
    
    # Find the closest available date in the weather data
    available_dates <- weather_data$Date
    closest_date <- available_dates[which.min(abs(available_dates - target_date))]
    
    # Store the closest sowing date
    sowing_dates <- c(sowing_dates, closest_date)
  }
  
  return(sowing_dates)
}