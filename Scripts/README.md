# Development stage calculation
The R script DVS_calculation.R simulates the development stages of winter wheat based on temperature.

DVS = 0 → Emergence


DVS = 1 → Anthesis (after reaching TSUM1)


DVS = 2 → Maturity (after reaching TSUM1 + TSUM2)

- Tavg accumulates each day to get TSUM
- DVS was interpolated from known (TSUM, DVS) pairs using approx()

Crop and weather data were imported
Function approx() inside a for loop was used to interpolate development stage of winter wheat depending on the total sum of temperatures

### Biomass growth calculation
Calculated the growth of stem, leaves, roots, and storage organs as well as LAI.
- based on solar radiation and photosynthesis acitivity

The R script Biomass_produdction.R simulates daily dry matter production and allocation in a crop using deSolve::ode().

# Model Components
Gross assimilation (Rd): Calculated from intercepted solar radiation (PAR), adjusted by canopy light interception using Beer’s Law.

Maintenance respiration (RM): Computed based on organ-specific respiration rates and a Q₁₀ temperature response.

Net assimilation (RN): The usable biomass after subtracting maintenance respiration from gross assimilation.

Biomass partitioning: Net assimilation is partitioned into leaves, stems, roots, and storage organs based on the current development stage (DVS).

Leaf Area Index (LAI): Grows based on assimilated leaf biomass and specific leaf area (SLA), with a constraint on the maximum relative growth rate.

## ODE Simulation
The crop_growth() function defines a system of five state variables:

- WLV – biomass in leaves (kg/ha)
- WST – biomass in stems
- WRT – biomass in roots
- WSO – biomass in storage organs
- LAI – leaf area index

The model is run over time using deSolve::ode(), with weather data (temperature, radiation, DVS) driving the daily rate calculations.

## Notes
Biomass partitioning coefficients are interpolated from DVS-dependent tables.

A check prevents maintenance respiration from exceeding total assimilation.

CVL, CVO, etc., are commented out but can be used if modeling carbon content instead of dry matter.

The model prints assimilation values each day for debugging.

## Output
The result is stored in out_df, a data.frame containing the time series of state variables and key daily outputs like Rd, RN, and DVS.
