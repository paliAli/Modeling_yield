##%######################################################%##
#                                                          #
####               Exercise Mapping in R                ####
#                                                          #
##%######################################################%##


# Teaching Block "Group Models at Scale"

#Define your Working Directory here:


# loading packages if needed
#install.packages("sf", type= "binary")
#install.packages("dplyr", type= "binary")
#install.packages("readr", type= "binary")
#install.packages("rnaturalearth", type= "binary")
#install.packages("ggplot2", type= "binary")

library(sf)
library(dplyr)
library(readr)
library(rnaturalearth)
library(ggplot2)

dat <- read_csv("WSO_2023.csv")

#Explore the Data a bit
head()
tail()
str()
#...


# 2. Bounding Box defining (bigger area around Switzerland)
lon_min <- 5.5
lon_max <- 10.7
lat_min <- 45.5
lat_max <- 48.3

# 3. Daten im Bounding Box filtern
Swiss_region_points <-  dat %>% 
  filter(Longitude >= lon_min, Longitude <= lon_max,
         Latitude  >= lat_min,  Latitude  <= lat_max) 

# 4. Als CSV speichern
write_csv(Swiss_region_points, "Swiss_region_points.csv")


##########Plot
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)


countries <- ne_countries(scale = "medium", returnclass = "sf")

# List of defined states in Europe
eu_countries <- ("Switzerland")

# Obtain data for Switzerland from the data frame countries
# Use function filter() from dplyr 
# First observe the dataset countries to see in which column are the country names
europe_selected <- # your code here

  
ggplot() +
  geom_sf(data = europe_selected, fill = NA, color = "black", size = 0.5) +  # borders of countries
  geom_point(data = Swiss_region_points, aes(x = Longitude, y = Latitude, color = Final_WSO_kg_ha), size = 2) +
  scale_color_gradient(low = "chocolate", high = "darkgreen") +
  labs(title = "Biomass 2023", 
       x = "Longitude",
       y = "Latitude",
       color = "WSO [kg/ha]") +
  coord_sf(xlim = c(5.5, 10.7), ylim = c(45.5, 48.7), expand = FALSE) +
  theme_minimal()


# Try plotting other countries as well!


#########What about the Raster?
# Schritt 1: Daten vorbereiten – gleiche wie bisher
library(dplyr)
library(readr)
library(ggplot2)
library(sf)
library(rnaturalearth)

dat <- read_csv("WSO_2023.csv")

# Bounding Box um Schweiz und Umgebung
Swiss_region_points <-  dat %>% 
  filter(Longitude >= 5.5, Longitude <= 10.7,
         Latitude  >= 45.5, Latitude  <= 48.3)

# Schritt 2: Kachelbreite in Grad (ca. 0.45° ≈ 50km in Mitteleuropa)
cell_size <- 0.45

# Schritt 3: Mittelpunkte in Rechtecke umwandeln (per Bounding Box)
Swiss_raster_tiles <- Swiss_region_points %>%
  mutate(
    xmin = Longitude - cell_size / 2,
    xmax = Longitude + cell_size / 2,
    ymin = Latitude - cell_size / 2,
    ymax = Latitude + cell_size / 2
  )

# Schritt 4: Rechtecke als sf-Polygone erzeugen
Swiss_raster_tiles_sf <- Swiss_raster_tiles %>%
  rowwise() %>%
  mutate(geometry = list(st_polygon(list(rbind(
    c(xmin, ymin),
    c(xmin, ymax),
    c(xmax, ymax),
    c(xmax, ymin),
    c(xmin, ymin)
  ))))) %>%
  st_as_sf(crs = 4326)

# Länderkarte laden
countries <- ne_countries(scale = "medium", returnclass = "sf")
europe_selected <- countries %>%
  filter(admin %in% c("Switzerland", "Germany", "Italy"))

# Plot mit Rasterflächen + Punkten
ggplot() +
  geom_sf(data = europe_selected, fill = NA, color = "black", size = 0.4) +
  # Raster (transparente Flächen)
  geom_sf(data = Swiss_raster_tiles_sf, aes(fill = Final_WSO_kg_ha), color = NA, alpha = 0.15) +
  # Punkte
  geom_point(data = Swiss_region_points, aes(x = Longitude, y = Latitude, color = Final_WSO_kg_ha), size = 2) +
  scale_color_gradient(low = "chocolate", high = "darkgreen") +
  scale_fill_gradient(low = "chocolate", high = "darkgreen") +
  labs(title = "Biomass 2023 mit 50×50km Raster",
       x = "Longitude", y = "Latitude",
       color = "WSO [kg/ha]", fill = "WSO [kg/ha]") +
  coord_sf(xlim = c(5.5, 10.7), ylim = c(45.5, 48.7), expand = FALSE) +
  theme_minimal()


