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

setwd("~/Macbook/Studium/Master/Biogeochem_Modeling")

# Load in crop data
source("crop_data.R")
# Import the weather data ----
source("DVS_calculation.R")
# Import the biomass model function
source("Biomass_function.R")


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
           LAI = initial_LAI)
           #DVS = crop$DVSI,
           #TSUM = 0

any(is.na(DVS_weather))
which(is.na(DVS_weather))
# Remove NAs from the weather dataset
DVS_weather <- DVS_weather[complete.cases(DVS_weather), ]

# Import the function to find sowing dates
#source("Input_data/Sowing_dates_function.R") 

# Import the event function
source("Event_function.R")

# Define the root function
rootfun <- function(t, state, parms) {
  with(as.list(state), {
    # Access DVS_stage from parms
    current_DVS <- parms$DVS_stage[t]
    current_DVS - 2  # Root is found when DVS = 2
  })
}

# Run the model for each location ----
# Loop the ode function through each coordinate
for (i in 1:length(Unique_ID)) {
  weather_subset <- DVS_weather[DVS_weather$ID == Unique_ID[i],]
  
  # Find unique seasons (Season_ID) for the current coordinate
  season_IDs <- unique(weather_subset$Season_ID)

  
  # Loop the ode function through each growing season
  for (sowing_year in season_IDs) {
    
    # Select the rows in the sowing_year
    weather_subset_filtered <- weather_subset[weather_subset$Season_ID == sowing_year, ]
    
    # Define the timestep
    timestep <- 1 # Each day
    # Define the number of time steps
    num_steps <- nrow(weather_subset_filtered) # Number of observed days
    # Define the time points for the ODE solver
    times <- seq(1, num_steps, by = timestep) 
  
    # Run the ODE solver with events
    out <- ode(y = state, times = times, func = crop_growth, parms = crop,
               events = list(func = eventfun, time = times), rootfun = rootfun)
    
    # Convert output to a data frame
    out_df <- as.data.frame(out)
    
    # Save the output
    write.csv(out_df, paste0("Output/biomass_production_", Unique_ID[i], "_", sowing_year, ".csv"), row.names = FALSE)
  }
}

# Import the csvs as data frames
biomass_files <- list.files(path = "Output", pattern = "biomass_production_", full.names = TRUE)
biomass_data <- lapply(biomass_files, read.csv)

# Extract final WSO (storage organ biomass) for each file
yield_data <- data.frame(
  File = basename(biomass_files),
  Unique_ID = NA,
  Season_ID = NA,
  Final_WSO_kg_ha = NA
)

for (i in seq_along(biomass_data)) {
  df <- biomass_data[[i]]
  
  # Extract final WSO
  final_WSO <- sum(df$WSO)  # kg/ha
  
  # Extract pixel and season info from filename
  file_parts <- unlist(strsplit(gsub("biomass_production_|\\.csv", "", yield_data$File[i]), "_"))
  
  # Safe-parse Longitude, Latitude, Season_ID
  yield_data$Longitude[i] <- as.numeric(file_parts[1])
  yield_data$Latitude[i] <- as.numeric(file_parts[2])
  yield_data$Season_ID[i] <- file_parts[3]
  yield_data$Final_WSO_kg_ha[i] <- final_WSO
}

# Split the Unique_ID column into Longitude and Latitude
library(tidyr)
yield_data <- yield_data %>%
  separate(Unique_ID, into = c("Longitude", "Latitude"), sep = "_", convert = TRUE)

str(yield_data)

test <- biomass_data[[2]]

# Create a map for each coordinates showing the final WSO
str(yield_data)

only_2023 <- yield_data %>% filter(Season_ID == "2023")
write.csv(only_2023, "WSO_2023.csv", row.names = FALSE)



summary(only_2023$Final_WSO_kg_ha)

#With Europes Borders

install.packages("rnaturalearth", type = "binary")
install.packages("rnaturalearthdata", type = "binary")

library(rnaturalearth)
library(rnaturalearthdata)


countries <- ne_countries(scale = "medium", returnclass = "sf")

# Liste der EU-Staaten + Schweiz
eu_countries <- c(
  "Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia",
  "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia",
  "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania",
  "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey"
)

# Länder filtern
europe_selected <- countries %>% 
  filter(admin %in% eu_countries)

Biomass_Europe_plot <-ggplot() +
  geom_sf(data = europe_selected, fill = NA, color = "black", size = 0.5) +  # Ländergrenzen
  geom_point(data = only_2023, aes(x = Longitude, y = Latitude, color = Final_WSO_kg_ha), size = 2) +
  scale_color_gradient(low = "chocolate", high = "darkgreen") +
  labs(title = "Biomass 2023", 
       x = "Longitude",
       y = "Latitude",
       color = "WSO [kg/ha]") +
  coord_sf(xlim = c(-20, 45), ylim = c(20, 65), expand = FALSE) +
  theme_minimal()

png("Biomass_Europe_plot.png", width = 630, height = 470)



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
                                "Storage weight" = "orange",
                                "Yield" = "salmon")) +
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
