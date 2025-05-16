# This script resamples the map file to a lower resolution to make it feasible for the analysis

# install.packages(c("viridisLite", "ggpubr"), type= "binary")
# install.packages("maptools", type= "binary")

# The original map file is 100 x 100m, the resampled file is 1 x 1 km
# source("Input_data/aggregated_landcover_raster_1x1km.tif")


library(readxl)
library(ggplot2)
library(ggthemes)
library(viridis)
#library(maptools)
library(ggpubr)
library(raster)
library(rgdal)
# library(sp)



#original pixel size 100 x 100m

map=raster("Input_data/aggregated_landcover_raster_1x1km.tif")
res(map)
crs(map)

plot(map)


# Define the aggregation factor (from 100m to 1km)
agg_factor <- 50

# Aggregate the raster using the modal function
aggregated_raster <- aggregate(map, fact = agg_factor, fun = modal)

# Save the aggregated raster
writeRaster(aggregated_raster, "Input_data/aggregated_landcover_raster_50x50km.tif", format = "GTiff")

# Plot the aggregated raster
plot(aggregated_raster)
# Check the resolution of the resampled raster
res(aggregated_raster)
crs(aggregated_raster)


# Create a data frame with the aggregated raster values
df <- as.data.frame(aggregated_raster, xy = TRUE)
str(df)


unique(df$aggregated_landcover_raster_1x1km)


# FILE: How use ESRI CLC raster files in QGIS.doc shows which LU corresponds to grasslands
# 12 = arable land

Wanted_Points<-df[df[,3] %in% c(12),]

plot(Wanted_Points$y~Wanted_Points$x, pch=20, col="red", xlab="X", ylab="Y", main="Wanted Points")


str(Wanted_Points)


# Rename the land use column
colnames(Wanted_Points)[3]<- "Land_Use"

# Replace 18 by Pastures and 26 by Natural grasslands
Wanted_Points$Land_Use[Wanted_Points$Land_Use==18]<- "Pastures"
Wanted_Points$Land_Use[Wanted_Points$Land_Use==26]<- "Natural grasslands"
Wanted_Points$Land_Use[Wanted_Points$Land_Use==22]<- "Agroforestry areas"

# Store the data frame in a CSV file
write.table(Wanted_Points, "Input_data/Wanted_Grassland_Points10km.csv", row.names = FALSE,sep=";")


# Convert the coordinates from the raster CRS to geographic coordinates (WGS84) ----
# Define the source and target CRS
source_crs <- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs"
target_crs <- "+proj=longlat +datum=WGS84 +no_defs"

# Create a spatial object from the Wanted_Points data frame
coordinates(Wanted_Points) <- ~x + y
proj4string(Wanted_Points) <- source_crs

# Transform the coordinates to the target CRS (WGS84)
Wanted_Points_transformed <- spTransform(Wanted_Points, target_crs)

# Extract the transformed coordinates and add them back to the data frame
Wanted_Points$Longitude <- coordinates(Wanted_Points_transformed)[, 1]
Wanted_Points$Latitude <- coordinates(Wanted_Points_transformed)[, 2]

# Inspect the updated data frame
head(Wanted_Points)

# Plot the transformed points
plot(Wanted_Points$Latitude ~ Wanted_Points$Longitude, 
     pch = 20, col = "blue", 
     xlab = "Longitude", ylab = "Latitude", 
     main = "Wanted Points in WGS84")
