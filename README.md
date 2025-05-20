# Modeling_yield
Biogeochemical modelling course group project

# Goal of the project
Simulate (potential) crop yield of winter wheat 
*Possible options*
- simulate the crop yield for one year over Europe
- create a time series
- simulate crop yield in the future under different climate scenarios

## To-do:
- [x] Obtain the weather data from NASA 
- [x] Create rasters of Europe 
- [x] Create the basic crop model
- [] Create a basic soil model
- [] Combine the crop and soil model
- [x] Map growth of winter wheat in Europe

## Structure of the repository
Input_data: 
- crop_data.R - contains the crop parameters
- LowerResolution.R - script to obtain the coordinates
- weather_data_2223.R - script to obtain the weather data

Scripts: 
- Biomass_function.R - function of the crop model that calculates changes in biomass and LAI
- Biomass_production.R - script that runs the model and creates a dataframe with the final biomass per growing season
- DVS_calculation.R - script that calculates developmental stages of ww as a function of mean temperature
- Event_function.R - function to reset the biomass at the end of each growing season 

Output: Contains the yield predictions, visualized as a map

  # Winter wheat distribution
From the WOFOST website:
Split the model spatial domain into small spatial units where the model inputs (weather, crop, soil, management) can be assumed constant.
In Europe, WOFOST is typically applied at spatial units of 10x10 km for which scaling errors are negligible.

  # Climate parameters

  # Yield prediction model
WOFOST model was used as a base. WOFOST is a dynamic simulation model that uses daily weather data, and crop, soil and management parameters to simulate crop growth and development.
It was originally developed for European conditions by Wagenigen university and is transparent and simple to modify.


https://www.wur.nl/en/Research-Results/Research-Institutes/Environmental-Research/Facilities-Tools/Software-models-and-databases/WOFOST.htm

## Model arguments
1. **crop - list of crop parameters**
   Must contain:
   - TSUMEM - Temperature sum from sowing to emergence
   - TSUM1 – Temperature sum from emergence to anthesis
   - TSUM2 – Temperature sum from anthesis to maturity
   - Tbase – Base temperature for development
   - DVSI - Initial development stage (0)
   - DVSEND - Development stage at harvest (= 2.0 at maturity)
   - SLA – Specific Leaf Area
   - FLTB, FSTB, FRTB, FOTB – Biomass partitioning tables 
   - CVO – Conversion efficiency of biomass
   -  RML - relative maintenance respiration rate of leaves ['d-1']
   -  RMO - relative maintenance respiration rate of storage organs ['d-1']
   -  RMR - relative maintenance respiration rate of roots ['d-1']
   -  RMS - relative maintenance respiration rate of stems ['d-1']
   -  RGRLAI - maximum relative increase in LAI ['d-1']
   -  Q10 - relative increase in respiration rate per 10 degrees Celsius temperature increase

  
https://edepot.wur.nl/308997


https://github.com/ajwdewit/WOFOST_crop_parameters/blob/master/wheat.yaml

2. **weather - data frame with weather data**
   Must contain:
   - date
   - day of the year (doy)
   - solar radiation [kJ m-2 day-1] (Solar)
   - minimum temperature [degrees C] (Tmin)
   - maximum temperature [degrees C] (Tmax)
   - vapor pressure [kPa] - used dew temperature instead (Tdew) **Is that ok?**
   - wind speed [ms-1] (windspeed)
   - precipitation [mm day-1] (ppt)
3. **soil - soil parameters**
4. **control - model start, latitude, elevation**

The model has 5 state variables:
1. WLV: weight of living leaves [kg ha-1]
2. WST: weight of stems [kg ha-1]
3. WSO: weight of grains [kg ha-1]
4. WRT: weight of roots [kg ha-1]
6. LAI: leaf area index [ha ha-1]
