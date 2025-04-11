rm(list = ls())

#0a. functions
source("./02_code/20_functions/01_data_processing_functions.R")

#0b.Load data and set file paths
all_admin_borders <- sf::st_read("./01_raw-data/ADM2-boundary/geoBoundariesCGAZ_ADM2.geojson")
pop_raster = terra::rast("./03_processed-data/processed-pop-raster/pop_2020.tif")
countries <- c(unique(all_admin_borders$shapeGroup)) 

#1.Run process global population by ADM2 
for (raster_country in countries){
    print(raster_country)
      
    #Create raster of administrative unit boundaries
    admin_borders <- all_admin_borders |> filter(shapeGroup == raster_country) 
    .GlobalEnv$admin_borders <- admin_borders
      
    vector_admin_borders <- terra::vect(admin_borders) 
    .GlobalEnv$vector_admin_borders <- vector_admin_borders
      
    adm_template <- terra::rast(vector_admin_borders, res = 0.008333333) 
    rast_adm_data <- terra::rasterize(vector_admin_borders, adm_template, field = 'shapeID') #1-km resolution raster of ADM2 ID
      
    #Clip population raster
    clipped_pop <- clip_country_admin_function(pop_raster) #1-km raster of population 

    #Calculate population per administrative unit and convert to df 
    resample_adm_data <- terra::resample(rast_adm_data, clipped_pop) #Match population and ADM2 ID rasters
      
    adm_data_df <- c(clipped_pop, resample_adm_data) |> 
      as.data.frame() |>                          
      rename(pop = 1) |> 
      zoo::na.locf() |> 
      group_by(shapeID) |> 
      summarize(adm_pop = sum(pop))

    if(exists("results_df")){
      results_df <- bind_rows(results_df, adm_data_df)
    } else {
      results_df <- adm_data_df
  }
}

# save data
write.csv(results_df, "./03_processed-data/pop_data_by_adm2/pop_2020_by_adm2.csv")

#2. Total population and amount lost
1 - sum(results_df$adm_pop) / terra::global(pop_raster, fun = "sum") # 0.4# lost

#-------------------------------------------------------------------------------
#3. Use terra::extract and iterate over country
for (raster_country in countries) {
  print(raster_country)
  
  # Create raster of administrative unit boundaries
  admin_borders <- all_admin_borders |> filter(shapeGroup == raster_country) 
  .GlobalEnv$admin_borders <- admin_borders
  
  pop = terra::extract(pop_raster, admin_borders, weights = TRUE) %>%
    group_by(ID) %>%
    summarise(pop_sum = sum(GHS_POP_E2020_GLOBE_R2023A_4326_30ss_V1_0 * weight))
  pop_adm2_data = data.frame(shapeID = admin_borders$shapeID,
                             pop = pop$pop_sum,
                             country = admin_borders$shapeGroup,
                             adm2 = admin_borders$shapeName)
  
  if(exists("results_df")){
    results_df <- bind_rows(results_df, pop_adm2_data)
  } else {
    results_df <- pop_adm2_data
  }
}

# compute percentage of lost data
1 -  (sum(results_df$pop) / terra::global(pop_raster, fun = "sum")) # 0.01362118
