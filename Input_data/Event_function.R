# Initial states ----
initial_leaf_weight <- 0.1
initial_stem_weight <- 0.1
initial_root_weight <- 0.1
initial_storage_weight <- 0
initial_LAI <- 0.1

# Define the event function
eventfun <- function(t, y, parms) {
  with(as.list(c(y, parms)), {
    
    # Reset state variables to their initial values
    y["WLV"] <- initial_leaf_weight
    y["WST"] <- initial_stem_weight  # Initial stem weight
    y["WRT"] <- initial_root_weight  # Initial root weight
    y["WSO"] <- initial_storage_weight  # Initial storage organ weight
    y["LAI"] <- initial_LAI # Initial Leaf Area Index (LAI)
    #y["TSUM"] <- 0
    #y["DVS"] <- crop$DVSI  # Reset DVS stage to initial value
    
    # Return the updated state vector
    return(y)
  })
}