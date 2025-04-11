
#Extract country border using giscoR package
get_country_borders <- function(country) {
  country <- giscoR::gisco_get_countries(country = country,
                                         resolution = "01")
  return(country)
}

get_region_borders <- function(region) {
  country <- giscoR::gisco_get_countries(region = region,
                                         resolution = "01")
  return(region)
}

#Clip population raster to a given country
clip_country_function <- function(x) {
  terra::crop(
    x,
    terra::vect(country_borders),
    snap = "in",
    mask = T
  )
}

clip_country_admin_function <- function(x) {
  terra::crop(
    x,
    terra::vect(admin_borders),
    snap = "in",
    mask = T, touches = T
  )
}

clip_region_function <- function(x) {
  terra::crop(
    x,
    terra::vect(region_borders),
    snap = "in",
    mask = T
  )
}
