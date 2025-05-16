##%######################################################%##
#                                                          #
####                 Biomass production                 ####
#                                                          #
##%######################################################%##

#-----------------------------------------------------------
  # Written by Alena Pavlackova
  # ETH Biogeochemical modeling group project
  
  # The script calculates the biomass production from photosynthesis
#-----------------------------------------------------------

# Required libraries ----
library(deSolve)
library(ggplot2)

setwd("~/GitHub/Modeling_yield")

# Load in crop data
source("Input_data/crop_data.R")
# Import the weather data ----
source("Scripts/Weather_preparation.R")
# Import the biomass model function
source("Input_data/Biomass_function.R")


# Initial states ----
initial_leaf_weight <- 0.1
initial_stem_weight <- 0.1
initial_root_weight <- 0.1
initial_storage_weight <- 0
initial_LAI <- 0.1

state <- c(WLV = initial_leaf_weight,
           WST = initial_stem_weight,
           WRT = initial_root_weight,
           WSO = initial_storage_weight,
           LAI = initial_LAI,
           DVS = crop$DVSI,
           TSUM = 0) 

# Create parameters list
parameters <- c(crop, list(TSUM_stages = TSUM_stages, DVS_stages = DVS_stages))

any(is.na(weather))
which(is.na(weather))
# Remove NAs from the weather dataset
weather <- weather[complete.cases(weather), ]

# Import the function to find sowing dates
source("Input_data/Sowing_dates_function.R") 
# Import the event function
source("Input_data/Event_function.R")

# Define the root function
rootfun <- function(t, state, parms) {
  with(as.list(state), {
    DVS - 2  # Root is found when DVS = 2
  })
}

# Run the model for each location ----
# Loop the ode function through each weather subset for the growing season
for (i in 1:length(Unique_ID)) {
  weather_subset <- weather[weather$ID == Unique_ID[i],]
  
  # Find sowing dates
  sowing_dates <- find_sowing_date(weather_subset)
  
  for (sowing_date in sowing_dates) {
    weather_subset_filtered <- weather_subset[weather_subset$Date >= sowing_date,]
    
    # Define the timestep
    timestep <- 1 # Each day
    # Define the number of time steps
    num_steps <- nrow(weather_subset_filtered) # Number of observed days
    # Define the time points for the ODE solver
    times <- seq(1, num_steps, by = timestep) 
  
    # Run the ODE solver with events
    out <- ode(y = state, times = times, func = crop_growth, parms = parameters,
               events = list(func = eventfun, time = times), rootfun = rootfun)
    
    # Convert output to a data frame
    out_df <- as.data.frame(out)
    
    # Save the output
    write.csv(out_df, paste0("Output/biomass_production_", Unique_ID[i], "_", sowing_date, ".csv"), row.names = FALSE)
  }
}

# Import the csvs as data frames
biomass_files <- list.files(path = "Output", pattern = "biomass_production_", full.names = TRUE)
biomass_data <- lapply(biomass_files, read.csv)

test <- biomass_data[[1]]

# Plot the results ----
ggplot(test, aes(x = time)) +
  geom_line(aes(y = WLV, color = "Leaf weight"), linewidth = 1.2) +
  geom_line(aes(y = WST, color = "Stem weight"), linewidth = 1.2) +
  geom_line(aes(y = WRT, color = "Root weight"), linewidth = 1.2) +
  geom_line(aes(y = WSO, color = "Storage weight"), linewidth = 1.2) +
  labs(title = "Biomass Production Over Time",
       x = "Time",
       y = "Weight (kg/ha)") +
  scale_color_manual(values = c("Leaf weight" = "green",
                                "Stem weight" = "brown",
                                "Root weight" = "blue",
                                "Storage weight" = "orange")) +
  theme(axis.ticks = element_line(linetype = "blank"),
        axis.text.x = element_text(size = 0)) +
  theme_minimal() 

# Only plot LAI
ggplot(test, aes(x = time, y = LAI)) +
  geom_line(color = "purple", linewidth = 1.2) +
  labs(title = "Leaf Area Index (LAI) Over Time",
       x = "Time",
       y = "LAI") +
  theme(axis.ticks = element_line(linetype = "blank"),
        axis.text.x = element_text(size = 0)) +
  theme_minimal()
