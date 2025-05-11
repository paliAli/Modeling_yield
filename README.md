# Modeling_yield
Biogeochemical modelling course group project

# Goal of the project
Simulate (potential) crop yield of winter wheat 
*Possible options*
- simulate the crop yield for one year over Europe
- create a time series
- simulate crop yield in the future under different climate scenarios

## Structure of the repository
Input_data: contains the data on climate, soil, sowing datesW
Scripts: contain the model functions
Output: Contains the yield predictions, visualized as a map

  # Winter wheat distribution
From the WOFOST website:
Split the model spatial domain into small spatial units where the model inputs (weather, crop, soil, management) can be assumed constant.
In Europe, WOFOST is typically applied at spatial units of 10x10 km for which scaling errors are negligible.

  # Climate parameters

  # Yield prediction model
WOFOST model was used as a base. WOFOST is a dynamic simulation model that uses daily weather data, and crop, soil and management parameters to simulate crop growth and development.
It was originally developed for European conditions by Wagenigen university and is transparent and simple to modify. /n
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
  
   For modeling yield under different climate change scenarios:
   - root_depth_max – Deep rooting helps tolerate drought
   - SMFCF, SMW, SM0 – Soil water holding capacity (can go in soil list)
   - CRAIRC – Critical air content to avoid anaerobic conditions
  
https://edepot.wur.nl/308997 /n
https://github.com/ajwdewit/WOFOST_crop_parameters/blob/master/wheat.yaml

2. **weather - data frame with weather data**
   Must contain:
   - date
   - day of the year (doy)
   - solar radiation [kJ m-2 day-1]
   - minimum temperature [degrees C]
   - maximum temperature [degrees C]
   - vapor pressure [kPa]
   - wind speed [ms-1]
   - precipitation [mm day-1]
3. **soil - soil parameters**
4. **control - model start, latitude, elevation**

The model has 8 state variables:
1. EAF: weight of living leaves [kg ha-1]
2. STEM: weight of stems [kg ha-1]
3. GRAIN: weight of grains [kg ha-1]
4. ROOT: weight of roots [kg ha-1]
5. DEATHLEAF: weight of dead leaves [kg ha-1]
6. LAI: leaf area index [ha ha-1]
7. TSUM: cumulative temperature unit [°C day]
8. DVS: the crop development stage [unitless] 

TSUM is calculated by interpolating Tavg = (Tmin + Tmax)/2

### Development stage calculation
DVS = 0 → Emergence /n
DVS = 1 → Anthesis (after reaching TSUM1) /n
DVS = 2 → Maturity (after reaching TSUM1 + TSUM2)

