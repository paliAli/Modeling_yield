# Create a map for each coordinates showing the final WSO
str(yield_data)

only_2023 <- yield_data %>% filter(Season_ID == "2023")
write.csv(only_2023, "WSO_2023.csv", row.names = FALSE)



summary(only_2023$Final_WSO_kg_ha)

#With Europes Borders

install.packages("rnaturalearth", type = "binary")
install.packages("rnaturalearthdata", type = "binary")

library(rnaturalearth)
library(rnaturalearthdata)


countries <- ne_countries(scale = "medium", returnclass = "sf")

# Liste der EU-Staaten + Schweiz
eu_countries <- c(
  "Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia",
  "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", "Latvia",
  "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", "Romania",
  "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey"
)

# Länder filtern
europe_selected <- countries %>% 
  filter(admin %in% eu_countries)

Biomass_Europe_plot <-ggplot() +
  geom_sf(data = europe_selected, fill = NA, color = "black", size = 0.5) +  # Ländergrenzen
  geom_point(data = only_2023, aes(x = Longitude, y = Latitude, color = Final_WSO_kg_ha), size = 2) +
  scale_color_gradient(low = "chocolate", high = "darkgreen") +
  labs(title = "Biomass 2023", 
       x = "Longitude",
       y = "Latitude",
       color = "WSO [kg/ha]") +
  coord_sf(xlim = c(-20, 45), ylim = c(20, 65), expand = FALSE) +
  theme_minimal()

png("Biomass_Europe_plot.png", width = 630, height = 470)