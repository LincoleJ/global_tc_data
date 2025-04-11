# process population rasters
# calculate population center from rasters
rm(list=ls())
#-------------------------------------------------------------------------------
### functions
# read pop raster datasets
read_pop_rast = function(year) {
  str_name = paste0("GHS_POP_E", year, "_GLOBE_R2023A_4326_30ss_V1_0")
  pop = terra::rast(paste0("./raw-data/pop-data/", str_name, "/", str_name, ".tif"))
  return(pop)
}
# interpolate population for 
interpolating_pop = function(pop1, pop2, t) {
  pop_interpolated = pop1 + (((pop2 - pop1) / 5) * t)
  return(pop_interpolated)
}

#-------------------------------------------------------------------------------
# process interpolated years
avbl_pop_yrs = seq(1980, 2020, 5)
n_pairs = length(avbl_pop_yrs) - 1

for (i in 1:n_pairs) {
  # read rasters
  st_yr = avbl_pop_yrs[i]
  end_yr = avbl_pop_yrs[i+1]
  st_yr_pop = read_pop_rast(st_yr)
  end_yr_pop = read_pop_rast(end_yr)
  
  # return processed & interpolated pop rasters
  for (t in 1:4) {
    pop = interpolating_pop(st_yr_pop, end_yr_pop, t)
    terra::writeRaster(pop, 
                       paste0("./process-data/processed-pop-raster/pop_",
                              st_yr + t, ".tif"),
                       overwrite=TRUE)
  }
}

#-------------------------------------------------------------------------------
# change the names of pop rasters and save into same file
for (i in 1:length(avbl_pop_yrs)) {
  pop = read_pop_rast(avbl_pop_yrs[i])
  terra::writeRaster(pop, paste0("./process-data/processed-pop-raster/pop_",
                                 avbl_pop_yrs[i], ".tif"))
}

#-------------------------------------------------------------------------------
# test case for interlopating 1980-1985
year = 1985
str_name = paste0("GHS_POP_E", year, "_GLOBE_R2023A_4326_30ss_V1_0")
pop_1985 = terra::rast(paste0("./raw-data/pop-data/", str_name, "/", str_name, ".tif"))


pop_1981_x = interpolating_pop(pop_1980, pop_1985, 1)
