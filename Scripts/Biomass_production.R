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

# Load in crop data
source("Input_data/crop_data.R")
# Import the weather data ----
source("Scripts/DVS_calculation.R")

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

any(is.na(DVS_weather))
which(is.na(DVS_weather))
# Remove NAs from the weather dataset
DVS_weather <- DVS_weather[complete.cases(DVS_weather), ]

# Define the time step
time_step <- 1 # in days
# Define the number of time steps
num_steps <- nrow(DVS_weather) # Number of observed days

times <- seq(1, num_steps, by = time_step) # Time vector


# Define the model ----
crop_growth <- function(t, state, parameters){
  with(as.list(c(state, crop)),{
    # Get current weather values
    day <- floor(t)
    Tmean <- weather_subset$Tmean[day]
    SR <- weather_subset$Solar[day]
    DVS_now <- weather_subset$DVS_stage[day]
    LAI_now <- state["LAI"]
    
    if (any(is.na(c(Tmean, SR, DVS_now, LAI_now)))) {
      stop("NA values in weather data or state vector")
    }
    
    # Calculate required variables 
    # Convert total radiation to PAR
    PAR <- 0.5 * SR  # About 50% of incoming radiation is PAR (Photosynthetically Active Radiation)
    
    # Intercepted PAR using Beer’s Law
    fPAR <- 1 - exp(-k * LAI_now)  # k = light extinction coefficient
    
    # Simplified calculation of photosynthesis
    Rd <- Ce * PAR * fPAR # gross assimilation in kg/ha/day
    
    # Maintenance respiration
    RM_25 <- WLV*RML + WST*RMS + WRT*RMR + WSO*RMO
    RM <- RM_25 * Q10^((Tmean - 25)/10) # maintenance respiration in kg/ha/day
    
    # Net biomass assimilation
    if (RM > Rd) {
      RM <- Rd # The maintenance respiration cannot exceed the gross assimilation
    }
    RN <- Rd - RM # net assimilation in kg/ha/day
    
    print(paste("Rd:", Rd, "RM:", RM, "RN:", RN))
    
    if (is.na(RN)) {
      stop("RN is NA. Check Rd and RM.")
    }
    
    # Partitioning (interpolated from tables based on DVS)
    FL <- approx(FLTB_df$DVS, FLTB_df$Value, xout = DVS_now, rule = 2)$y
    FS <- approx(FSTB_df$DVS, FSTB_df$Value, xout = DVS_now, rule = 2)$y
    FR <- approx(FRTB_df$DVS, FRTB_df$Value, xout = DVS_now, rule = 2)$y
    FO <- approx(FOTB_df$DVS, FOTB_df$Value, xout = DVS_now, rule = 2)$y
    
    # Biomass growth
    dWLV <- RN * FL #* CVL I would use this if I want to calculate carbon content (?)
    dWST <- RN * FS #* CVS
    dWRT <- RN * FR #* CVR
    dWSO <- RN * FO #* CVO
    
    # LAI growth (based on SLA and max relative rate)
    dLAI <- min(RGRLAI * LAI_now, SLA * dWLV) # SLA = specific leaf area in ha/kg
    
    # Stop growth when RN is below a threshold and DVS reaches the end stage
    if (RN < 0.01 & DVS_now == 3) { 
      return(NULL) # Stop simulation
    }
  
    return(list(
      c(dWLV, dWST, dWRT, dWSO, dLAI),
      Rd = Rd,
      RN = RN,
      DVS = DVS_now
    ))
  })
}

source("Input_data/Sowing_dates_function.R") # Import function to find sowing dates

# Run the model for each location ----
# Loop the ode function through each weather subset
for(i in 1:length(Unique_ID)) {
  weather_subset <- DVS_weather[DVS_weather$ID == Unique_ID[i],]
  
  # Define the time step
  time_step <- 1 # in days
  # Define the number of time steps
  num_steps <- nrow(weather_subset) # Number of observed days
  
  times <- seq(1, num_steps, by = time_step) # Time vector
  
  # Run the model
  out <- ode(y = state, times = times, func = crop_growth, parms = crop)
  
  # Convert the output to a data frame
  out_df <- as.data.frame(out)
  
  # Save the output to a CSV file
  write.csv(out_df, paste0("Output/biomass_production_", Unique_ID[i], ".csv"), row.names = FALSE)
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
