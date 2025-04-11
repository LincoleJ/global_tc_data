rm(list=ls())

#0a. Load packages and functions
library(dplyr)
source("./02_code/20_functions/01_data_processing_functions.R")

#0b.Load data and set file paths
all_admin_borders <- sf::st_read("./01_raw-data/ADM2-boundary/geoBoundariesCGAZ_ADM2.geojson")
countries <- c(unique(all_admin_borders$shapeGroup)) 

#1a. generate population center for each y
for (year in 1980:2020) {
  # load pop raster at each
  print(year)
  pop_raster = terra::rast(paste0("./03_processed-data/processed-pop-raster/pop_", 
                                  year, ".tif"))
  names(pop_raster) <- "pop"
  
  for (raster_country in countries) {
    print(raster_country)
    
    # Create raster of administrative unit boundaries
    admin_borders <- all_admin_borders |> filter(shapeGroup == raster_country) 
    .GlobalEnv$admin_borders <- admin_borders
    
    # Generate grid center points, % coverage, and population
    pop_center = terra::extract(pop_raster, admin_borders, xy = TRUE, weights = TRUE) %>%
      group_by(ID) %>%
      summarise(weighted_x = sum(pop * weight * x) / 
                  sum(pop * weight),
                weighted_y = sum(pop * weight * y) / 
                  sum(pop * weight),
                pop_sum = sum(pop * weight))
    
    pop_center_data = data.frame(shapeID = admin_borders$shapeID,
                                 country = admin_borders$shapeGroup,
                                 adm2 = admin_borders$shapeName,
                                 pop = pop_center$pop_sum,
                                 weighted_x = pop_center$weighted_x,
                                 weighted_y = pop_center$weighted_y)
    
    if(exists("results_df")){
      results_df <- bind_rows(results_df, pop_center_data)
    } else {
      results_df <- pop_center_data
    }
  }
  # save data
  write.csv(results_df, 
            paste0("./03_processed-data/wtd_pop_center/pop_center_", 
                   year, ".csv"))
  rm(results_df)
}


#1a. Madagascar for 2020 population as an example
raster_country = "MDG"
print(raster_country)

# Create raster of administrative unit boundaries
admin_borders <- all_admin_borders |> filter(shapeGroup == raster_country) 
.GlobalEnv$admin_borders <- admin_borders

# Generate grid center points, % coverage, and population
pop_center = terra::extract(pop_raster, admin_borders, xy = TRUE, weights = TRUE) %>%
  group_by(ID) %>%
  summarise(weighted_x = sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight * x) / 
              sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight),
            weighted_y = sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight * y) / 
              sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight),
            pop_sum = sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight))

pop_adm2_data = data.frame(shapeID = admin_borders$shapeID,
                           country = admin_borders$shapeGroup,
                           adm2 = admin_borders$shapeName,
                           pop = pop_center$pop_sum,
                           weighted_x = pop_center$weighted_x,
                           weighted_y = pop_center$weighted_y)

