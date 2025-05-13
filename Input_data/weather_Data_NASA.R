####NASA Power Weather Data Set

#loading packages needed
install.packages(c("nasapower", "tidyverse", "sf", "raster"), type = "binary")
install.packages("bit64", type= "binary")

library(nasapower)
library(tidyverse)
library(sf)
library(raster)
library(bit64)

#Define area of Europe
europe_bbox <- list(
  minlat = 35,   # Southern Europe
  maxlat = 70,   # Northern Europe
  minlon = -25,  # Western Europe
  maxlon = 45    # Eastern Europe
)

#define raster resolution
# Approximate 5km resolution at mid-latitudes (~0.045 degrees)
step_deg <- 10/ 111  # 50x50km

r <- raster(europe_bbox, res = step_deg)

#Define parameters and timeframe
parameters <- c("PRECTOTCORR")  # Temp, Precipitation, Solar Radiation

start_date <- "2023-01-01"
end_date <- "2023-12-31"

#Define some points
latitudes <- seq(europe_bbox$minlat, europe_bbox$maxlat, by = step_deg)
longitudes <- seq(europe_bbox$minlon, europe_bbox$maxlon, by = step_deg)

coords <- expand.grid(LAT = latitudes, LON = longitudes)


?get_power
weather_data <- purrr::map2_dfr(
  coords$LON, coords$LAT,
  ~ get_power(
    community = "AG",
    lonlat = c(.x, .y),
    pars = parameters,
    dates = c("2022", "2023"),
    temporal_api = "monthly"
  ) %>% mutate(LON = .x, LAT = .y)
)

#plot precipitation
weather_data %>%
  group_by(LON, LAT) %>%
  ggplot(aes(x = LON, y = LAT, fill = ANN)) +
  geom_tile() +
  coord_fixed() +
  scale_fill_viridis_c(name = "mm") +
  labs(title = "Total Precipitation (2022–2023)", x = "Longitude", y = "Latitude") +
  theme_minimal()




