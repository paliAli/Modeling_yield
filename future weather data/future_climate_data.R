rm(list = ls())

##use geodata cmip6_world() function to download climate data######
rm(list = ls())
library(geodata)
library(raster)

?cmip6_world
#use cmip6_world() function to download climate data
tmax2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "tmax", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
tmin2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "tmin", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
prec2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "prec", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
#tav2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "tav", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
bioc2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "bio", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")

#min_longtitude <- boundary[1] #-31.3
#max_longtitude <- boundary[2] # 40.2
#min_latitude <- boundary[3] # 27.6
#max_latitude <- boundary[4] # 71.2
#climate in europe.
tmax_europe <- crop(tmax2021_2040, ext(-31.3,40.2,27.6,71.2))
tmin_europe <- crop(tmin2021_2040, ext(-31.3,40.2,27.6,71.2))
prec_europe <- crop(prec2021_2040, ext(-31.3,40.2,27.6,71.2))
#tav_europe <- crop(tav2021_2040, ext(-31.3,40.2,27.6,71.2))
bioc_europe <- crop(bioc2021_2040, ext(-31.3,40.2,27.6,71.2))

#convert to dataframe


##get future climate data from Copernicus CDS###########
##Climate indicators for Europe from 1940 to 2100 derived from reanalysis and climate projections
install.packages("ncdf4")
install.packages("raster")
library(ncdf4)
library(raster)
library(tidyverse)

#read .nc files
#tasmax(the .nc file Iill put into the shared doc)
tasmax <- "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/l1_daily_maximum_temperature-projections-monthly-mean-rcp_4_5-cclm4_8_17-mpi_esm_lr-r1i1p1-grid-v1.0.nc"
tasmax_r <- brick(tasmax)

#tasmin
tasmin <- "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/l2_daily_minimum_temperature-projections-monthly-mean-rcp_4_5-cclm4_8_17-mpi_esm_lr-r1i1p1-grid-v1.0.nc"
tasmin_r <- brick(tasmin)

#precipitation (mm)
pr <- "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/12_total_precipitation-projections-monthly-rcp_4_5-cclm4_8_17-mpi_esm_lr-r1i1p1-grid-v1.0.nc"
pr_r <- brick(pr)

#convert to dataframe
df_tasmax <- as.data.frame(tasmax_r, xy = TRUE)
df_tasmin <- as.data.frame(tasmin_r, xy = TRUE)
df_pr <- as.data.frame(pr_r, xy = TRUE)

#只选取x,y 和 X2025.01.01到X2027.12.01 column
#select the first, the second and columns from X2026.01.01 to X2027.12.01
df_tasmax <- df_tasmax %>%
  select(1,2,X2026.01.01:X2027.12.01)
df_tasmin <- df_tasmin %>%
  select(1,2,X2026.01.01:X2027.12.01)
df_pr <- df_pr %>%
  select(1,2,X2026.01.01:X2027.12.01)

#data to csv
write.csv(df_tasmax, "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/tasmax.csv", row.names = FALSE)
write.csv(df_tasmin, "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/tasmin.csv", row.names = FALSE)
write.csv(df_pr, "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/pr.csv", row.names = FALSE)

#convert to long format（but it always gives me an error, I don't know why）
layer_names <- names(tasmax_r[X2026.01.01:X2027.12.01])
time_vec <- as.Date(sub("X", "", layer_names), format = "%Y.%m.%d")
colnames(df_tasmax) <- c("lon", "lat", as.character(time_vec))
df_tasmax <- df_tasmax %>%
  pivot_longer(
    cols = -c(lon, lat),
    names_to = "time",
    values_to = "tasmax"
  )

layer_names <- names(tasmin_r)
time_vec <- as.Date(sub("X", "", layer_names), format = "%Y.%m.%d")
colnames(df_tasmin) <- c("lon", "lat", as.character(time_vec))
df_tasmin <- df_tasmin %>%
  pivot_longer(
    cols = -c(lon, lat),
    names_to = "time",
    values_to = "tasmin"
  )

layer_names <- names(pr_r)
time_vec <- as.Date(sub("X", "", layer_names), format = "%Y.%m.%d")
colnames(df_pr) <- c("lon", "lat", as.character(time_vec))
df_pr <- df_pr %>%
  pivot_longer(
    cols = -c(lon, lat),
    names_to = "time",
    values_to = "pr"
  )

#conmbine the dataframes
df <- df_tasmax  %>%
  left_join(df_tasmin, by = c("lon", "lat", "time"))  %>%
  left_join(df_pr, by = c("lon", "lat", "time"))

#save as csv

write.csv(df, "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/future_weather_data.csv", row.names = FALSE)

#define the scale of Europe(I copy the code from the previous script)
source("Input_data/LowerResolution.R")
latitudes <- Wanted_Points$y
longitudes <- Wanted_Points$x


##get future climate data using CMIP6 (2041 - 2060)###########
#very complicated
#use raster package
library(sp)
library(raster)
#download climate data from WorldClim
#read tn tx pr and bc raster
tn <- raster("C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/wc2.1_10m_tmin_ACCESS-CM2_ssp126_2041-2060.tif")
tx <- raster("C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/wc2.1_10m_tmax_ACCESS-CM2_ssp126_2041-2060.tif")
pr <- raster("C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/wc2.1_10m_prec_ACCESS-CM2_ssp126_2041-2060.tif")
bc <- raster("C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data/wc2.1_10m_bioc_ACCESS-CM2_ssp126_2041-2060.tif")

##get future cliamte data using geodata package
install.packages("geodata")
library(geodata)

#use cmip6_world() function to download climate data
tmax2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "tmax", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
prec2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "prec", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")
tmin2021_2040 <- cmip6_world("ACCESS-CM2","126","2021-2040", "tmin", 10, path = "C:/Users/Lilma wang/Desktop/新建文件夹/1 R programme/小组作业/Modeling_yield/future weather data")

#climate in europe. 
tmax_europe <- crop(tmax2021_2040,  ext(-31.3,40.2,27.6,71.2)y)
tmin_europe <- crop(tmin2021_2040,  ext(-31.3,40.2,27.6,71.2))
prec_europe <- crop(prec2021_2040,  ext(-31.3,40.2,27.6,71.2))

