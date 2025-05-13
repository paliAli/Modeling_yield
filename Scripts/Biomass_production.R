##%######################################################%##
#                                                          #
####                 Biomass production                 ####
#                                                          #
##%######################################################%##

-----------------------------------------------------------
  # Written by Alena Pavlackova
  # ETH Biogeochemical modeling group project
  
  # The script calculates the biomass production from photosynthesis
  -----------------------------------------------------------

# Required libraries ----
library(deSolve)
library(ggplot2)

# Load in crop data
crop <- source("Input_data/crop_data.R")
# Import the weather data ----
weather <- read.csv("Input_data/DVS_weather.csv")

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

any(is.na(weather))
which(is.na(weather))
# Remove NAs from the weather dataset
weather <- weather[complete.cases(weather), ]

# Define the time step
time_step <- 1 # in days
# Define the number of time steps
num_steps <- nrow(weather) # Number of observed days

times <- seq(1, num_steps, by = time_step) # Time vector


# Define the model ----
crop_growth <- function(t, state, parameters){
  with(as.list(c(state, crop)),{
    # Get current weather values
    day <- floor(t)
    Tmean <- weather$Tmean[day]
    SR <- weather$Solar[day]
    DVS_now <- weather$DVS_stage[day]
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
    
  
    return(list(
      c(dWLV, dWST, dWRT, dWSO, dLAI),
      Rd = Rd,
      RN = RN,
      DVS = DVS_now
    ))
  })
}

# Run the model ----
out <- ode(y = state, times = times, func = crop_growth, parms = crop)

# Convert the output to a data frame
out_df <- as.data.frame(out)

# Plot the results ----
ggplot(out_df, aes(x = time)) +
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
ggplot(out_df, aes(x = time, y = LAI)) +
  geom_line(color = "purple", linewidth = 1.2) +
  labs(title = "Leaf Area Index (LAI) Over Time",
       x = "Time",
       y = "LAI") +
  theme(axis.ticks = element_line(linetype = "blank"),
        axis.text.x = element_text(size = 0)) +
  theme_minimal()

# For later when the coordinates are grouped into countries?
# Define a function to run the model for a single region
run_model_for_region <- function(region_weather) {
  # Define time vector based on the number of days in the region weather data
  num_steps <- nrow(region_weather)
  times <- seq(1, num_steps, by = 1)
  
  # Run the model
  out <- ode(y = state, times = times, func = crop_growth, parms = crop)
  
  # Return the output
  return(out)
}