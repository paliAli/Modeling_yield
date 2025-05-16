# Function to find the sowing date for a weather subset
find_sowing_date <- function(weather_data) {
  # Ensure the Date column is in Date format
  weather_data <- weather_data %>%
    mutate(Date = as.Date(Date))  # Ensure Date is in Date format
  
  # Define the target sowing date for each year (October 1)
  weather_data <- weather_data %>%
    mutate(Target_Sowing_Date = as.Date(paste0(YEAR, "-10-01")))
  
  # Find the closest available date to the target sowing date for each year
  sowing_dates <- weather_data %>%
    group_by(YEAR) %>%
    summarise(Sowing_Date = Date[which.min(abs(Date - Target_Sowing_Date))], .groups = "drop")
  
  return(sowing_dates$Sowing_Date)
}
