# Define the model ----
crop_growth <- function(t, state, parameters){
  with(as.list(c(state, crop)),{
    # Get current weather values
    day <- floor(t)
    Tmean <- weather_subset_filtered$Tmean[day]
    SR <- weather_subset_filtered$Solar[day]
    DVS_now <- weather_subset_filtered$DVS_stage[day]
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